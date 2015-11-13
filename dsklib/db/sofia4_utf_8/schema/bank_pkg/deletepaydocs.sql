DROP FUNCTION  IF EXISTS  bank_pkg.deletepaydocs(numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.deletepaydocs(ipfileid numeric)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
 declare
  
   --local vars
   vtransaction_id numeric;
   r record;
   vpaydoc_id numeric;
   vuser_id   numeric;
   res varchar;
  
   --select not anulated docs for transaction
   doc_ids cursor (iptransaction_id numeric)  is
   select pd.paydocument_id
   from paydocument pd 
   where 1=1
   and pd.paytransaction_id = iptransaction_id
   and pd.bin is null; --limit 10;
  


 begin
	--get pay transaction for paid file_id
	select   into vtransaction_id, vuser_id
	pf.paytransaction_id, pf.user_id
	from bank_pkg.paidfile pf 
	where 1=1
	and pf.ispaid = true
	and pf.paytransaction_id is not null
	and pf.file_id = ipfileid;

	if(vtransaction_id is null) then return; end if;


	--anulate not anulated docs
	for r in doc_ids(vtransaction_id)
	loop 
	    res := anulate(r.paydocument_id, vuser_id, current_date, 'dskstorno'); 
	end loop;


	--delete paydebts for documents in paytransaction
	delete from  paydebt debt 
	using  
	( select pd.paydocument_id 
	from paydocument d
	join paydebt pd on pd.paydocument_id = d.paydocument_id
	where 1=1
	and d.paytransaction_id = vtransaction_id 
        and d.bin =  '2' ) as  pd1   --documents for paytransaction , --1 anyliran , 2 storniran
	where   debt.paydocument_id = pd1.paydocument_id;
	
	--delete documents for transaction 
	delete 
	from paydocument pd 
	where 1=1
	and pd.paytransaction_id = vtransaction_id
	and pd.bin = '2';   --1 anyliran , 2 storniran

	--delete transaction itself
	delete from paytransaction where paytransaction_id = vtransaction_id;
 end;
 $function$
;
