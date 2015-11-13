DROP FUNCTION  IF EXISTS  bank_pkg.payfile(numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.payfile(ipdskfile_d numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
 declare
     --CURSOR ZA PLATENITE ZADYLJENIQ OT DSK
     dskpaidf cursor  is 
     
     select 
     p.file_id, 
     ts.taxsubject_id, p.idn, pf.user_id, f.municipality_id, f. kinddebtreg_id, 
     p.paydate, p.paysum, p.partidano, f.company_id from bank_pkg.file f
     join bank_pkg.filecnt p on  f.file_id = p.file_id
     join taxsubject ts on p.idn = ts.idn 
     join bank_pkg.paidfile pf on pf.file_id = f.file_id
     where f.file_id = ipdskfile_d and p.paycode = '99';

     r	record;
     res record;
     stat varchar (100);
     vtransaction numeric;
     vtrtype varchar(3);  
 begin
   --IN ipuser_id numeric, IN ipmunicipality_id numeric, IN ippaydate date, IN ippaysum numeric, IN ipkinddebtreg numeric, IN iptaxsubject_id numeric, IN ippartidano character varying, IN ipcompany_id numeric DEFAULT NULL::numeric, OUT opdocno character varying, OUT opstatus character varying)
   stat:= 'OK';
   vtrtype:= '2';

    --paytransaction sequence
   select nextval('s_paytransaction') into   vtransaction;

   --zapis v paytransaction za celiq fail i celiq ama celiq vytre suh, suh, suh, suh, suh............................
   insert  into paytransaction  (paytransaction_id, transactionno, trdate, trsuma, trtype, user_date, user_id, municipality_id, office_id) 
   (select vtransaction, vtransaction, current_date, f.sum, vtrtype,  current_date,  pf.user_id, m.municipality_id , null  
     from bank_pkg.file f
     join municipality m on f.municipality_id = m.municipality_id
     join bank_pkg.paidfile pf on pf.file_id = f.file_id
     where f.file_id = ipdskfile_d);
   
  
   --call the procedure for each row
   for r in dskpaidf
   loop
	res := bank_pkg.autopaytaxyear(r.user_id, r.municipality_id, r.paydate, r.paysum, r.kinddebtreg_id, r.taxsubject_id, r.partidano, r.company_id, vtransaction);  
   end loop;

   --update paidfile with transaction_id & current time& update the status to paid
   update bank_pkg.paidfile set paytransaction_id = vtransaction, ispaid  = true, paydate = current_timestamp  where file_id = ipdskfile_d;
   return stat;
 end;
 $function$
;
