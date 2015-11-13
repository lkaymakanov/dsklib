DROP FUNCTION  IF EXISTS  bank_pkg.paypendingfiles(); 
CREATE OR REPLACE FUNCTION bank_pkg.paypendingfiles()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
 declare
     --CURSOR ZA FAILOVETE ZAQWENI ZA RAZNASQNE
     pending cursor  is 
     select pf.file_id
     from bank_pkg.paidfile pf where 1=1 
     and ispaid = false
     and ispending = true;

     r	record;
     res varchar;

 begin
   --IN ipuser_id numeric, IN ipmunicipality_id numeric, IN ippaydate date, IN ippaysum numeric, IN ipkinddebtreg numeric, IN iptaxsubject_id numeric, IN ippartidano character varying, IN ipcompany_id numeric DEFAULT NULL::numeric, OUT opdocno character varying, OUT opstatus character varying)
   for r in pending
   loop
	--call the procedure for each file
	res:= bank_pkg.payfile(r.file_id);	
   end loop;

 end;
 $function$
;
