DROP FUNCTION  IF EXISTS  bank_pkg.deletefile(numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.deletefile(ipfile_id numeric DEFAULT (-1))
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
  delete from bank_pkg.paidfile pf where  pf.file_id = ipfile_id;
  delete from bank_pkg.filecnt ac where  ac.file_id = ipfile_id;
  delete from bank_pkg.file f where  f.file_id = ipfile_id;
  

end
$function$
;
