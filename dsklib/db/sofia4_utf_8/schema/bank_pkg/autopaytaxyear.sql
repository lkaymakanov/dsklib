DROP FUNCTION  IF EXISTS  bank_pkg.autopaytaxyear(numeric, numeric, date, numeric, numeric, numeric, character varying, numeric, numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.autopaytaxyear(ipuser_id numeric, ipmunicipality_id numeric, ippaydate date, ippaysum numeric, ipkinddebtreg numeric, iptaxsubject_id numeric, ippartidano character varying, ipcompany_id numeric DEFAULT NULL::numeric, iptransaction_id numeric DEFAULT NULL::numeric, OUT opdocno character varying, OUT opstatus character varying)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
                                 declare
                                    cr cursor is
                                     select ds.debtsubject_id debtsubject_id,
                                          di.debtinstalment_id debtinstalment_id,
                                          bdi.instsum instsum,
                                          bdi.discsum discsum,
                                          ds.kinddebtreg_id kinddebtreg_id,
                                          ds.kindparreg_id kindparreg_id
                                   from debtsubject ds
                                        join debtinstalment di on di.debtsubject_id = ds.debtsubject_id
                                        join baldebtinst bdi on bdi.debtinstalment_id = di.debtinstalment_id
                                        join config c on c.municipality_id = ds.municipality_id and c.name =
                                         'TAXYEAR'
                                        join taxperiod tp on tp.taxperkind = '0' AND to_char(tp.begin_date, 'yyyy') = c.configvalue
                                   where
                                         ds.taxsubject_id = iptaxsubject_Id and
                                         ds.municipality_id = ipmunicipality_Id and
                                         ds.kinddebtreg_id = ipKinddebtreg and
                                         coalesce(ds.partidano, '*') = ippartidano and
                                         coalesce(bdi.instsum, 0) + coalesce(round(bdi.interestsum, 2), 0) > 0
                                         order by di.termpay_date,
                                                  ds.partidano;
                                   r            record;
                                   vost         numeric;
                                   pgl          numeric;
                                   --plix         numeric;
                                   vdsc         numeric;
                                   vtransaction numeric;
                                   vpaydocument numeric;
                                   vtrtype      varchar(4);
                                   vdocnumber   varchar(20);
                                   vseries      varchar(8);
                                   voversubject numeric;
                                   vkindpaydoc  varchar(10);
                                   vStat        varchar(50);
                                   vbaccount    numeric;
                                   vtaxyear     varchar(10);
 			          vRecDocno    record;
                                 begin
                                   if (ipTaxsubject_Id is null) or (ipKinddebtreg is null)
                                   then
                                     opstatus := '0'; -- Lipsva danacen subekt
                                     return;
                                   end if;
                                   vtrtype     := '2';    --(decode) trType 2 - Издължаване на посредници	превод касови пл при ежедневно приключване
                                   vkindpaydoc := '611';  --(decode) KindPayDoc '611'  - ПКР	приходен касов ордер
                                   -- otstapka
                                   vStat:= bank_pkg.calcdiscount(ipTaxSubject_id, null, ipPayDate,  ippartidano, ipkinddebtreg);
                                   if vStat <> 'OK'
                                   then
                                     opstatus := '1'; -- greska pri nacislenie na otstapka
                                     return;
                                   end if;
                                   vdsc         := 0;
                                   vost         := ippaysum;
                                   voversubject := null;

				   
                                 
                                   --insert into paytransaction if no iptransaction_id
				   if(iptransaction_id is null)  then begin
					   --paytransaction sequence
					   select nextval('s_paytransaction') into   vtransaction;

					   insert into paytransaction
					     (paytransaction_id, transactionno, trdate, trsuma, trtype, user_date,
					      user_id, municipality_id, office_id)
					   values
					     (vtransaction, vtransaction, ippaydate, ippaysum, vtrtype, current_date,
					      ipuser_Id, ipmunicipality_Id, null);
				   end;
				   else begin 
					vtransaction :=  iptransaction_id; 
				   end;
				   end if;
				
				   --Paydocument sequence
                                   select nextval('S_Paydocument')
                                   into   vpaydocument;

				   --document number (nomer na dokumenta)
                                   vRecDocno  := Getdocnumber(ipmunicipality_Id, vkindpaydoc, '1');
 				  					vdocnumber:=vRecDocno.opdocnumber ;
 				  					vseries:=vRecDocno.opseries;
                                   
 
 
				   --smetkata na obshtinata
                                   select b.baccount_id into vbaccount from baccount b where b.isactive = 1 and b.isbase = 1 and b.municipality_id = ipmunicipality_id;

				   --godina za koqto se plashta		
                                   select c.configvalue into vtaxyear from config c where c.municipality_id = ipmunicipality_id and c.name = 'TAXYEAR';
				
				 --zapis v Paydocument
                                 insert into PayDocument
                                     (paydocument_id, baccount_id, taxsubject_id, kindpaydoc,
                                      documentno, series, documentdate, paydate, docsum, user_date, user_id,
                                      user_name, docfromdate, doctodate,
                                      paytime, paytransaction_id, partidano, company_id)
                                   values
                                     (vpaydocument, vbaccount, iptaxsubject_id, vkindpaydoc,
                                      vdocnumber, vseries, current_date, ipPayDate, ipPaysum, current_date, ipUser_Id,
                                      (select u.fullname
                                        from   users u
                                        where  u.user_id = ipUser_Id),
                                      to_date('01.01' || vtaxyear,'dd.mm.yyyy'), to_date('31.12' || vtaxyear,'dd.mm.yyyy'), ipPayDate, vtransaction, ippartidano, ipcompany_id);
                                   open cr;
                                   loop
                                     fetch cr
                                       into r;
                                     exit when not FOUND;
                                     pgl  := 0;
                                     vdsc := 0;
                                     if vost <= 0
                                     then
                                       exit;
                                     end if;
                                     if (r.instsum > 0) and (vost > 0)
                                     then
                                       if vost >= (r.instsum - r.discsum)
                                       then
                                         pgl  := (r.instsum - r.discsum);
                                         vdsc := r.discsum;
                                         if vdsc > 0
                                         then
					   --update na ostypkata v debtsubject
                                           update debtsubject set    paydiscsum = vdsc where  debtsubject_id = r.debtsubject_id;
                                         end if;
                                       else
                                         pgl := vost;
                                       end if;
                                       vost := vost - pgl;
                                     end if;
 
                                     ---- zapis v paydebt
                                     insert into PayDebt
                                       (paydebt_id, kinddebtreg_id, paydocument_id, debtinstalment_id,
                                        payinstsum, payinterestsum, paydiscsum, balinstsum, balinterestsum,
                                        kindparreg_id)
                                     values
                                       (nextval('S_PayDebt'), r.kinddebtreg_Id, vpaydocument, r.debtinstalment_id,
                                        pgl, 0, vdsc, r.instsum, 0, r.kindparreg_id)
                                     ;

				     --aktualizaciq na balansa
                                     update Baldebtinst
                                     set    instsum = instsum - pgl - vdsc, discsum = null
                                     where  debtinstalment_id = r.debtinstalment_id;
                                   end loop;
                                   close cr;
                                   if vost < 0
                                   then
                                     vost := 0;
                                   end if;
                                   if vost > 0    -- ako ostatykyt e po - golqm ot 0 zapis v nadvnesena
                                   then
                                     --oversubject sequence
                                     select nextval('s_oversubject')  into   voversubject;

				     --zapis OverSubject
                                     insert into OverSubject
                                       (oversubject_id, kinddebtreg_id, taxsubject_id, overpaysum, partidano,
                                        municipality_id)
                                     values
                                       (voversubject, ipkinddebtReg, iptaxsubject_id, vost, ipPartidano,
                                        ipMunicipality_id);
				    
				     --zapis Baloverinst
                                     insert into Baloverinst
                                       (oversubject_id, oversum)
                                     values
                                       (voversubject, vost);
                                       update paydocument set oversubject_id = voversubject, overpaysum = vost, over_kinddebtreg_id = ipkinddebtReg
                                       where paydocument_id = vpaydocument;
                                   end if;
                                   --commit;
                                   opDocno  := vdocnumber;
                                   opStatus := 'OK';
                                 exception
                                   when no_data_found then
                                     opStatus := '3'; --lipsvat danni
                                     --rollback;
                                   when others then
                                     --rollback;
                                     opStatus := '4'; --greska
                                 end;
 $function$
;
