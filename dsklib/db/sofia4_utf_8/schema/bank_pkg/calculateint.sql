DROP FUNCTION  IF EXISTS  bank_pkg.calculateint(numeric, date, numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.calculateint(ipdebtinstalment numeric, ipto date, ipuser_id numeric)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
  declare
    crintper cursor(vtodate date) is
      select *
      from   interestpct ip
      where  ip.begin_date between
             (select max(ib.begin_date)
              from   interestpct ib
              where  ib.begin_date <= vtodate) and
             (select max(ie.begin_date)
              from   interestpct ie
              where  ie.begin_date <= ipto)
      order  by ip.begin_date;
  
  
    rintper          record;
    vBDate           date;
    vEDate           date;
    crPCT            numeric;
    vIntSum          numeric;
    vinterestoper_id numeric;
    vpersum          numeric;
    vtodate          date;
    basesum          numeric;
    vintdebt_id      numeric;
    ipto1            date;
  begin
    ipto1 := ipto;
    select max(di.debtinstalment_id), max(di.todate)
    into   vintdebt_id, vtodate
    from   interestdebt di
    where  di.debtinstalment_id = ipdebtinstalment;
    if vintdebt_id is null
    then
  
      select di.intbegindate
      into   vtodate
      from   debtinstalment di
      where  di.debtinstalment_id = ipdebtinstalment;
      --   select s_interestdebt.nextval into vintdebt_id from dual;
    else
      vtodate := vtodate + interval '1 day';
    end if;
    if vtodate <= ipto1
    then
      select min(bd.instsum)
      into   basesum
      from   baldebtinst bd
      where  bd.debtinstalment_id = ipdebtinstalment;
  
      basesum := coalesce(basesum, 0);
      if basesum <> 0.0
      then
        vIntSum := 0.0;
        open crintper(vtodate);
        fetch crintper
          into rintper;
        if not found
        then
          vIntSum := 0.0;
          return('OK');
        end if;
        vBDate := vtodate;
        crPCT  := rintper.interestpct + coalesce(rintper.interestpctadd,0);
        loop
          fetch crintper
            into rintper;
          exit when not found;
          vEdate  := rintper.begin_date::date - interval '1 day';
          vpersum := round(((vEdate - vBDate) + 1) * crPCT * BaseSum / 36000.0, 5);
          vIntSum := vIntSum + vpersum;
          select nextval('s_interestoper')
          into   vinterestoper_id;
          insert into interestoper
            (interestoper_id, DEBTINSTALMENT_ID, kindoper, oper_date, begin_date,
             end_date, instsum, intpct, interestsum, user_date, user_id)
          values
            (vinterestoper_id, ipdebtinstalment, '10', ipto1, vBDate, vEdate,
             basesum, crPCT, vpersum, current_date, ipuser_id);
          crPCT  := rintper.interestpct + coalesce(rintper.interestpctadd, 0);
          vBDate := rintper.begin_date;
        end loop;
        close crintper;
        vpersum := round((ipto1 - vBDate + 1) * crPCT * BaseSum / 36000.0, 5);
        vIntSum := vIntSum + vpersum;
        if vIntSum <> 0.0
        then
          if vintdebt_id is null
          then
            insert into interestdebt
              (intdebtsum, debtinstalment_id, user_date, todate)
            values
              (0, ipdebtinstalment, current_timestamp, ipto1);
          end if;
          select nextval('s_interestoper')
          into   vinterestoper_id;
          insert into interestoper
            (interestoper_id, DEBTINSTALMENT_ID, kindoper, oper_date, begin_date,
             end_date, instsum, intpct, interestsum, user_date, user_id)
          values
            (vinterestoper_id, ipdebtinstalment, '10', ipto1, vBDate, ipto1,
             basesum, crPCT, vpersum, current_timestamp, ipuser_id);
  
          update baldebtinst
          set    interestsum = COALESCE(interestsum, 0) + round(vIntSum, 5)
          where  debtinstalment_id = ipdebtinstalment;
        end if;
  
      update interestdebt
      set    intdebtsum = intdebtsum + vIntSum, todate = ipto1
      where  debtinstalment_id = ipdebtinstalment;
      ----commit;
       end if;
    end if;
    return('OK');
  exception
    when others then
      ----rollback;
      return('errOrclDB' || sqlerrm);
  end;
  $function$
;
