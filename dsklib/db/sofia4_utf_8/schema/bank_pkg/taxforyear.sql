DROP FUNCTION  IF EXISTS  bank_pkg.taxforyear(); 
CREATE OR REPLACE FUNCTION bank_pkg.taxforyear(OUT opstat character varying, OUT operrn integer)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
declare
    --all the distinct partidas for active services not interested in the documenttype
    docs cursor (iptaxper_id numeric, ipmunicipality_id numeric) is 
	select td.*
	from (select distinct(partidano) 
	from bank_pkg.filecnt fc join bank_pkg.file f on  f.file_id = fc.file_id
        where f.filetypereg_id = 1) par
	join taxdoc td on  par.partidano = td.partidano
	where 1=1
     
    and td.municipality_id = ipmunicipality_id
	and not exists (select *
              from   debtsubject ds
              where  ds.document_id = td.taxdoc_id
              and    ds.taxperiod_id = iptaxper_id
	      and    ds.municipality_id = ipmunicipality_id);

     
     munIds cursor is 
     select distinct(coalesce(municipality_id, -1))  from config;
      

     tdrow taxdoc%rowtype;
     cyear         varchar(10);
     msg           varchar(300);
     vbegintaxdate date;
     vtotalval     numeric;
     vtotaltax     numeric;
     vtbotax       numeric;
     countrec      numeric;
     vtaxper_id    numeric;
     vcity_id      numeric;
     ipmunicipality_id numeric;
     firmpropertyrec record;
     munId record;
  

  begin
     opstat := 'OK';
     operrn := 0;
     cyear  := null;
	
     --obchtinata na potrebitelq
     select min(u.municipality_id) into ipmunicipality_id
     from users u
     where u.user_id = ipuser_id;
     if ipmunicipality_id is null then opstat :='Липсва община за потребителя'; return; end if;

     --tekushtata godina TAXYEAR ot config
     select c.configvalue
     into   cyear
     from   config c
     where  c.name = 'TAXYEAR'
     and c.municipality_id = ipmunicipality_id;

     
     if cyear is null
     then
       return;
     end if;
 
     --2014 get the fucken period
     select taxperiod_id into vtaxper_id  FROM TAXPERIOD where taxperkind = '0' and to_char(begin_date, 'yyyy') = cyear;

     --for all municipalities	
     for munId in munIds 
     loop
	
     --loop through the fucken cursor
     open docs(vtaxper_id, munId);
      loop
        fetch docs
          into tdrow;
        exit when not FOUND;
        begin
          if (tdrow.begintaxdate is not null) and
             (to_char(tdrow.begintaxdate, 'yyyy') = cyear)
          then
            vbegintaxdate := tdrow.begintaxdate;
          else
            vbegintaxdate := to_date('01.01.' || cyear, 'dd.mm.yyyy');
          end if;

          -- if vdoccode = '54L' then
          if tdrow.documenttype_id in (26, 27, 28, 29)
          then
            msg := taxvaluation.Taxtransport(tdrow.taxdoc_id, vbegintaxdate,
                         coalesce(tdrow.close_date,
                              to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
                         ipuser_id, 0);
            --commit;
            if msg <> 'OK'
            then
              -- dbms_output.put_line(tdrow.taxdoc_id || ' ' || msg);
              operrn := operrn + 1;
            end if;
          end if;
          if tdrow.documenttype_id = 21
          then
            select count(pt.promtbo_id)
            into   countrec
            from   promtbo pt
            where  pt.taxperiod_id = vtaxper_id;
            if nvl(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            select count(n.normdni_id)
            into   countrec
            from   normdni n
            where  n.taxperiod_id = vtaxper_id
            --  and n.municipality_id =
            ;
            if nvl(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            if coalesce(tdrow.decl14to17, 0.0) <> 1
            then
            if coalesce(tdrow.decl14to17, 0) = 2 then
              msg := Firmprop14(tdrow.taxdoc_id, vbegintaxdate,
                coalesce(tdrow.close_date,to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
               ipuser_id, 1, 0);
             else
              msg := taxvaluation.Taxproperty(tdrow.taxdoc_id, vbegintaxdate,
                          coalesce(tdrow.close_date,
                               to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
                          ipuser_id, 1);
              end if;
              --commit;
              if msg <> 'OK'
              then
                --dbms_output.put_line(tdrow.taxdoc_id || ' ' || msg);
                operrn := operrn + 1;
              end if;
            end if;
          end if;
          if tdrow.documenttype_id = 22
          then
            select count(pt.promtbo_id)
            into   countrec
            from   promtbo pt
            where  pt.taxperiod_id = vtaxper_id;
            if coalesce(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            select count(n.normdni_id)
            into   countrec
            from   normdni n
            where  n.taxperiod_id = vtaxper_id
            --  and n.municipality_id =
            ;
            if coalesce(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;

            select into firmpropertyrec * from taxvaluation.Firmproperty(tdrow.taxdoc_id, vbegintaxdate,
                         coalesce(tdrow.close_date,
                              to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
                         ipuser_id, 1, 0);
            msg := firmpropertyrec.ipstatus;
            vtotalval := firmpropertyrec.optotalval;
            vtotaltax := firmpropertyrec.optotaltax;
            vtbotax := firmpropertyrec.optbototaltax;
            --commit;
            if msg <> 'OK'
            then
              operrn := operrn + 1;
            else
              perform taxvaluation.upd_doc14(tdrow.taxdoc_id);
            end if;
          end if;
          if tdrow.documenttype_id = 32
          then
            -------------------
            select min(a.city_id) into vcity_id
             from address a
             where a.address_id = tdrow.decl_perm_addr
             ;
            select count(*)
            into  countrec
            from ChargeReg cr, ChargePrice cp
            where cr.DocumentType_Id = 32
            and coalesce(cp.city_id, -1) in
                 (case when
                  (select count(cp1.city_id)
                     from ChargePrice cp1
                    where cp1.TaxPeriod_Id = vtaxper_id
                      and coalesce(cp1.city_id, -1) = coalesce(vcity_id, -1)
                      ) = 1 then
                  vcity_id else - 1 end)
             and cr.ChargeReg_Id = cp.ChargeReg_Id
             and cp.TaxPeriod_Id = vtaxper_id;
            ------------------------
            if coalesce(countrec, 0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            msg := ivan_valuations.DogValuation(tdrow.taxdoc_id,ipuser_id,msg);
            --commit;
            if msg <> 'OK'
            then
              operrn := operrn + 1;
            end if;
          end if;
        exception
          when others then
            return;
        end;
      end loop;
      close docs;
     end loop;
end;
$function$
;
DROP FUNCTION  IF EXISTS  bank_pkg.taxforyear(numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.taxforyear(ipuser_id numeric, OUT opstat character varying, OUT operrn integer)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
declare
    --all the distinct partidas for active services not interested in the documenttype
    docs cursor (iptaxper_id numeric, ipmunicipality_id numeric) is 
	select td.*
	from (select distinct(partidano) 
	from bank_pkg.filecnt fc join bank_pkg.file f on  f.file_id = fc.file_id
        where f.filetypereg_id = 1) par
	join taxdoc td on  par.partidano = td.partidano
	where 1=1
     
    and td.municipality_id = ipmunicipality_id
	and not exists (select *
              from   debtsubject ds
              where  ds.document_id = td.taxdoc_id
              and    ds.taxperiod_id = iptaxper_id
	      and    ds.municipality_id = ipmunicipality_id);

     
     munIds cursor is 
     select distinct(coalesce(municipality_id, -1))  from config;
      

     tdrow taxdoc%rowtype;
     cyear         varchar(10);
     msg           varchar(300);
     vbegintaxdate date;
     vtotalval     numeric;
     vtotaltax     numeric;
     vtbotax       numeric;
     countrec      numeric;
     vtaxper_id    numeric;
     vcity_id      numeric;
     ipmunicipality_id numeric;
     firmpropertyrec record;
     munId record;
  

  begin
     opstat := 'OK';
     operrn := 0;
     cyear  := null;
	
     --obchtinata na potrebitelq
     select min(u.municipality_id) into ipmunicipality_id
     from users u
     where u.user_id = ipuser_id;
     if ipmunicipality_id is null then opstat :='Липсва община за потребителя'; return; end if;

     --tekushtata godina TAXYEAR ot config
     select c.configvalue
     into   cyear
     from   config c
     where  c.name = 'TAXYEAR'
     and c.municipality_id = ipmunicipality_id;

     
     if cyear is null
     then
       return;
     end if;
 
     --2014 get the fucken period
     select taxperiod_id into vtaxper_id  FROM TAXPERIOD where taxperkind = '0' and to_char(begin_date, 'yyyy') = cyear;

     --for all municipalities	
     for munId in munIds 
     loop
	
     --loop through the fucken cursor
     open docs(vtaxper_id, ipmunicipality_id);
      loop
        fetch docs
          into tdrow;
        exit when not FOUND;
        begin
          if (tdrow.begintaxdate is not null) and
             (to_char(tdrow.begintaxdate, 'yyyy') = cyear)
          then
            vbegintaxdate := tdrow.begintaxdate;
          else
            vbegintaxdate := to_date('01.01.' || cyear, 'dd.mm.yyyy');
          end if;

          -- if vdoccode = '54L' then
          if tdrow.documenttype_id in (26, 27, 28, 29)
          then
            msg := taxvaluation.Taxtransport(tdrow.taxdoc_id, vbegintaxdate,
                         coalesce(tdrow.close_date,
                              to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
                         ipuser_id, 0);
            --commit;
            if msg <> 'OK'
            then
              -- dbms_output.put_line(tdrow.taxdoc_id || ' ' || msg);
              operrn := operrn + 1;
            end if;
          end if;
          if tdrow.documenttype_id = 21
          then
            select count(pt.promtbo_id)
            into   countrec
            from   promtbo pt
            where  pt.taxperiod_id = vtaxper_id;
            if nvl(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            select count(n.normdni_id)
            into   countrec
            from   normdni n
            where  n.taxperiod_id = vtaxper_id
            --  and n.municipality_id =
            ;
            if nvl(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            if coalesce(tdrow.decl14to17, 0.0) <> 1
            then
            if coalesce(tdrow.decl14to17, 0) = 2 then
              msg := Firmprop14(tdrow.taxdoc_id, vbegintaxdate,
                coalesce(tdrow.close_date,to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
               ipuser_id, 1, 0);
             else
              msg := taxvaluation.Taxproperty(tdrow.taxdoc_id, vbegintaxdate,
                          coalesce(tdrow.close_date,
                               to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
                          ipuser_id, 1);
              end if;
              --commit;
              if msg <> 'OK'
              then
                --dbms_output.put_line(tdrow.taxdoc_id || ' ' || msg);
                operrn := operrn + 1;
              end if;
            end if;
          end if;
          if tdrow.documenttype_id = 22
          then
            select count(pt.promtbo_id)
            into   countrec
            from   promtbo pt
            where  pt.taxperiod_id = vtaxper_id;
            if coalesce(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            select count(n.normdni_id)
            into   countrec
            from   normdni n
            where  n.taxperiod_id = vtaxper_id
            --  and n.municipality_id =
            ;
            if coalesce(countrec, 0.0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;

            select into firmpropertyrec * from taxvaluation.Firmproperty(tdrow.taxdoc_id, vbegintaxdate,
                         coalesce(tdrow.close_date,
                              to_date('31.12.' || cyear, 'dd.mm.yyyy'))::date,
                         ipuser_id, 1, 0);
            msg := firmpropertyrec.ipstatus;
            vtotalval := firmpropertyrec.optotalval;
            vtotaltax := firmpropertyrec.optotaltax;
            vtbotax := firmpropertyrec.optbototaltax;
            --commit;
            if msg <> 'OK'
            then
              operrn := operrn + 1;
            else
              perform taxvaluation.upd_doc14(tdrow.taxdoc_id);
            end if;
          end if;
          if tdrow.documenttype_id = 32
          then
            -------------------
            select min(a.city_id) into vcity_id
             from address a
             where a.address_id = tdrow.decl_perm_addr
             ;
            select count(*)
            into  countrec
            from ChargeReg cr, ChargePrice cp
            where cr.DocumentType_Id = 32
            and coalesce(cp.city_id, -1) in
                 (case when
                  (select count(cp1.city_id)
                     from ChargePrice cp1
                    where cp1.TaxPeriod_Id = vtaxper_id
                      and coalesce(cp1.city_id, -1) = coalesce(vcity_id, -1)
                      ) = 1 then
                  vcity_id else - 1 end)
             and cr.ChargeReg_Id = cp.ChargeReg_Id
             and cp.TaxPeriod_Id = vtaxper_id;
            ------------------------
            if coalesce(countrec, 0) = 0
            then
              opstat := 'Липсват нормативи за периода';
              return;
            end if;
            msg := ivan_valuations.DogValuation(tdrow.taxdoc_id,ipuser_id,msg);
            --commit;
            if msg <> 'OK'
            then
              operrn := operrn + 1;
            end if;
          end if;
        exception
          when others then
            return;
        end;
      end loop;
      close docs;
     end loop;
end;
$function$
;
