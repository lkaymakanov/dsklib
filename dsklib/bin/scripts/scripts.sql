 --script for discount table - transfers discounts from 2013 to 2014
/**
insert into discount 
(select d.discount_id + 7, d.documenttype_id, 29, to_date(to_char(d.termdisc, 'dd.mm.') || '2014', 'dd.mm.yyyy'),
d.percent, d.condition, d.kinddebtreg
from discount d where d.taxperiod_id = 28 
and not exists(select * from discount d where d.taxperiod_id = 29));*/
 

--script for taxperiodpay table - transfers taxperiodpay from 2013 to 2014
/* 
insert into taxperiodpay
select snextval('s_taxperiodpay'), tp.documenttype_id, 
29, 
tp.instalmentnumber, 
to_date(to_char(tp.termpaydate,'dd.mm.')  || '2014', 'dd.mm.yyyy'), tp.kinddebtreg_id
from taxperiodpay tp where taxperiod_id = 28
and not exists (select * from taxperiodpay t where t.taxperiod_id = 29)
;*/
 
 
--update config taxyear to 2013, 2014 
/**
update   config   set configvalue = '2014' where name = 'TAXYEAR' and municipality_id = 1185;
update   config   set configvalue = '2014' where name = 'TAXYEAR14' and municipality_id = 1185;
update   config   set configvalue = '2014' where name = 'TAXYEAR17' and municipality_id =  1185;
*/
 
 
 ---restore 
 /*
delete  from taxperiodpay  where taxperiod_id = 29;
delete  from discount  where taxperiod_id = 29;

update   config   set configvalue = '2013' where name = 'TAXYEAR' and municipality_id = 1185;
update   config   set configvalue = '2013' where name = 'TAXYEAR14' and municipality_id = 1185;
update   config   set configvalue = '2013' where name = 'TAXYEAR17' and municipality_id =  1185;

 */