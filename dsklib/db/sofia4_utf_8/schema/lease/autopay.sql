DROP FUNCTION  IF EXISTS  lease.autopay(); 
CREATE OR REPLACE FUNCTION lease.autopay(OUT opstatus character varying)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
declare
        cr_file cursor is
            select df.debtsfile_id,
            df.taxsubject_id,
            df.received_payment_date,
            df.paid_sum,
            df.municipality_id,
            df.pay_user_id,
            df.kinddebtreg_id
            from lease.debtsfile df
            where coalesce(df.received_payment, 0) = 1 and
              df.pay_time is null
            order by df.received_payment_date;
        cr_fileitem cursor (vdebtsfile_id numeric) is
            select di.debtsfileitem_id,
            	   di.debtsubject_id,
                   di.paysum,
                   ds.partidano
            from lease.debtsfileitem di
                 join debtsubject ds on ds.debtsubject_id = di.debtsubject_id
            where di.debtsfile_id = vdebtsfile_id and
                  coalesce(di.active, 0) = 1
            order by di.row_id;
        cr_debtinstalment cursor(vdebtsubject_id numeric) is
            select di.debtinstalment_id,
                   bdi.instsum,
                   round(bdi.interestsum, 2) interestsum,
                   coalesce(bdi.discsum,0) discsum,
                   ds.kindparreg_id,
                   ds.kinddebtreg_id,
                   ds.debtsubject_id
            from debtsubject ds
                 join debtinstalment di on di.debtsubject_id = ds.debtsubject_id
                 join baldebtinst bdi on bdi.debtinstalment_id =
                  di.debtinstalment_id
            where coalesce(ds.parent_debtsubject_id, ds.debtsubject_id) = vdebtsubject_id
            order  by di.termpay_date;
        r_file            record;
        r_fileitem            record;
        r_debtinstalment            record;
        vost         numeric;
        pgl          numeric;
        plix         numeric;
        vdsc         numeric;
        vplateno		 numeric;
        vremaininggl	 numeric;
        vremaininglix	 numeric;
        vtransaction numeric;
        vpaydocument numeric;
        vtrtype      varchar(4);
        vdocnumber   varchar(20);
        vseries      varchar(8);
        voversubject numeric;
        voversum        numeric;
        vkindpaydoc  varchar(10);
        vStat        varchar(50);
        vtaxyear     varchar(10);
        vcompany    numeric;
        vRecDocno    record;
 begin
 		vtrtype     := '2';    --(decode) trType 2 - Издължаване на посредници    превод касови пл при ежедневно приключване
        vkindpaydoc := '611';  --(decode) KindPayDoc '611'  - ПКР    приходен касов ордер
        for r_file in cr_file
        loop
        -- Loop za vseki fail
        	--paytransaction sequence
            select nextval('s_paytransaction') into   vtransaction;
            insert into paytransaction
            (paytransaction_id, transactionno, trdate, trsuma, trtype, user_date,user_id, municipality_id, office_id)
            values
            (vtransaction, vtransaction, r_file.received_payment_date, r_file.paid_sum, vtrtype, current_timestamp, r_file.pay_user_id, r_file.municipality_id, null);
            --Paydocument sequence
            select nextval('S_Paydocument') into   vpaydocument;
            --document number (nomer na dokumenta)
            vRecDocno  := Getdocnumber(r_file.municipality_id, vkindpaydoc, '1');
            vdocnumber:=vRecDocno.opdocnumber ;
            vseries:=vRecDocno.opseries;
            voversum := 0;
            -- select na company_id po taxsubject_id 
            select c.company_id into vcompany
    		from company c
         	join delegatecompany dc on dc.company_id = c.company_id
         	join agent a on a.agent_id = dc.agent_id
    		where a.agent_id = 6 and
          	c.taxsubject_id = r_file.taxsubject_id;
            --zapis v Paydocument
            insert into PayDocument
            (paydocument_id, taxsubject_id, kindpaydoc,
            documentno, series, documentdate, paydate, paytime, docsum, user_date, user_id,
            user_name,
            paytransaction_id, company_id)
            values
            (vpaydocument, r_file.taxsubject_id, vkindpaydoc,
            vdocnumber, vseries, current_date, r_file.received_payment_date, r_file.received_payment_date, r_file.paid_sum, current_timestamp, r_file.pay_user_id,
            (select u.fullname
            	from   users u
                where  u.user_id = r_file.pay_user_id),
            vtransaction, vcompany);
            for r_fileitem in cr_fileitem (r_file.debtsfile_id)
            loop
            -- Loop za vseki red ot faila
             	select Sanction_Pkg.calcdiscount(r_file.taxsubject_id, null::numeric, r_file.received_payment_date, r_fileitem.partidano, null::numeric) into vStat;
                if vStat <> 'OK'
                then
                	opstatus := '1'; -- greska pri nacislenie na otstapka
                	return;
                end if;
                for r_debtinstalment in cr_debtinstalment (r_fileitem.debtsubject_id)
                loop
                	vStat := Sanction_Pkg.CalculateInt(r_debtinstalment.debtinstalment_id, r_file.received_payment_date, r_file.pay_user_id);
                    if vStat <> 'OK'
                    then
                    	opstatus := '2'; -- greska pri nacislenie na lixva
                        return;
                    end if;
                end loop;
                vdsc           := 0;
                vost           := r_fileitem.paysum;
                vremaininggl   := 0;
                vremaininglix  := 0;
                vplateno	   := 0;
                for r_debtinstalment in cr_debtinstalment (r_fileitem.debtsubject_id)
                loop
                -- Loop za vsichki debtinstalment_ids za debtsubject-a na reda
                	pgl  := 0;
                    plix := 0;
                    vdsc := 0;
                    if vost <= 0
                    then
                    	vremaininggl := vremaininggl + (r_debtinstalment.instsum - r_debtinstalment.discsum);
                        vremaininglix := vremaininglix + r_debtinstalment.interestsum;
                    	--return;
                    else
                        if (r_debtinstalment.instsum > 0) and (vost > 0)
                        then
                            if vost >= (r_debtinstalment.instsum - r_debtinstalment.discsum)
                            then
                                pgl  := (r_debtinstalment.instsum - r_debtinstalment.discsum);
                                vdsc := r_debtinstalment.discsum;
                                if vdsc > 0
                                then
                                    --update na ostypkata v debtsubject
                                    update debtsubject
                                    set    paydiscsum = vdsc
                                    where  debtsubject_id = r_debtinstalment.debtsubject_id;
                                end if;
                            else
                                pgl := vost;
                                vremaininggl := vremaininggl + r_debtinstalment.instsum - r_debtinstalment.discsum - vost;
                            end if;
                            vost := vost - pgl;
                        end if;
                        if (vost > 0) and (r_debtinstalment.interestsum > 0)
                        then
                            if vost >= r_debtinstalment.interestsum
                            then
                                plix := r_debtinstalment.interestsum;
                            else
                                plix := vost;
                                vremaininglix = vremaininglix + r_debtinstalment.interestsum - vost;
                            end if;
                            vost := vost - plix;
                        end if;
                        -- zapis plastane
                        insert into PayDebt
                        (paydebt_id, kinddebtreg_id, paydocument_id, debtinstalment_id,
                        payinstsum, payinterestsum, paydiscsum, balinstsum, balinterestsum,
                        kindparreg_id)
                        values
                        (nextval('S_PayDebt'), r_debtinstalment.kinddebtreg_Id, vpaydocument, r_debtinstalment.debtinstalment_id,
                        pgl, plix, vdsc, r_debtinstalment.instsum, r_debtinstalment.interestsum, r_debtinstalment.kindparreg_id);
                        --aktualizaciq na balansa
                        update Baldebtinst
                        set
                        instsum = instsum - pgl - vdsc,
                        interestsum = interestsum - plix, discsum = null
                        where  debtinstalment_id = r_debtinstalment.DebtInstalment_Id;
                        vplateno := vplateno + pgl - vdsc + plix;
                    end if;
                end loop;
                -- end Loop za vsichki debtinstalment_ids za debtsubject-a na reda
                if vost < 0
                then
                	vost := 0;
                end if;
                if vost > 0
                then
                    voversum := voversum + vost;
                end if;
                update lease.debtsfileitem set paidsum = vplateno, remaining_inst = vremaininggl, remaining_int = vremaininglix, oversum = vost
                where debtsfileitem_id = r_fileitem.debtsfileitem_id;
            end loop;
            -- end Loop za vseki red ot faila
            if voversum > 0
            then
            	--zapis nadvnesena
                select nextval('s_oversubject') into   voversubject;
                insert into OverSubject
                (oversubject_id, kinddebtreg_id, taxsubject_id, overpaysum, partidano, municipality_id, debtsubject_id)
                values
                (voversubject, r_file.kinddebtreg_id, r_file.taxsubject_id, voversum, null, r_file.municipality_id, null);
                insert into Baloverinst (oversubject_id, oversum)
                values
                (voversubject, voversum);
                update paydocument
                set 
                oversubject_id = voversubject, overpaysum = voversum, over_kinddebtreg_id = r_file.kinddebtreg_id
                where paydocument_id = vpaydocument;
            end if;
            
            -- zapis na pay_time v debtsfile
            update lease.debtsfile
            set pay_time = statement_timestamp(),
            paytransaction_id = vtransaction
            where debtsfile_id = r_file.debtsfile_id;
        end loop;
        -- end Loop za vseki fail
end;
$function$
;
