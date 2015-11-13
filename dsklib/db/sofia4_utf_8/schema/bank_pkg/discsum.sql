DROP FUNCTION  IF EXISTS  bank_pkg.discsum(numeric, date, character varying, numeric); 
CREATE OR REPLACE FUNCTION bank_pkg.discsum(iptaxsubject_id numeric, ippaydate date, ippartno character varying, ipkinddebtreg_id numeric)
 RETURNS numeric
 LANGUAGE sql
AS $function$
  --( 
  SELECT  --ds.partidano,
  	--ds.taxperiod_id,
  	--ds.kinddebtreg_Id,	
  	Round ((SUM (COALESCE (ds.totaltax, 0)) * d.percent) / 100, 2) - SUM (COALESCE (pd.paydiscsum, 0)) discsum--,
   --	max(bdi.debtinstalment_id) debtinstalment_id
   
  FROM
  	debtsubject ds
  	JOIN taxdoc td--декларация
  		ON   td.taxdoc_id = ds.document_id
  	JOIN config c --текуща година
  		ON   c.municipality_id = ds.municipality_id
  		AND c.name = 'TAXYEAR'
  	LEFT JOIN config c2 --да има ли отстъпка за придобити МПС-та в срок на плащане за текуща година
  		ON   c2.municipality_id = ds.municipality_id
  		AND c2.name = 'MPS60' || c.configvalue
  	JOIN taxperiod tp --данъчен период
  		ON   tp.begin_date = to_date ('01.01.' || c.configvalue, 'dd.mm.yyyy')
  		AND tp.taxperkind = '0'
  		AND ds.taxperiod_id = tp.taxperiod_id
  	JOIN discount d --процент и дата на отстъпката
  		ON   (
  		     	d.documenttype_id = td.documenttype_id
  		     	AND d.taxperiod_id = tp.taxperiod_id
  		     	AND COALESCE (d.percent, 0) > 0
  		     	AND (
  		     	    	 (d.kinddebtreg = ds.kinddebtreg_id)
  		     	    	OR (d.kinddebtreg IS NULL)
  		     	    )
  		     	AND trunc (trunc (ippaydate)) <= d.termdisc --дата trunc (ippaydate) за изчисляване отстъпката да е по-малка от крайна дата на отстъпка
  		     )
  	LEFT JOIN (
  	     	SELECT
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		MAX (COALESCE (pd.paydate, to_date ('01-01-1970', 'dd.mm.yyyy'))) paydate,
  	     		SUM (COALESCE (pdt.paydiscsum, 0)) paydiscsum
  	     	FROM
  	     		paydebt pdt
  	     		JOIN paydocument pd
  	     			ON   pd.paydocument_id = pdt.paydocument_id
  	     			AND pd.null_date IS NULL
  	     		JOIN debtinstalment di
  	     			ON   di.debtinstalment_id = pdt.debtinstalment_id
  	     		JOIN debtsubject ds
  	     			ON   ds.debtsubject_Id = di.debtsubject_Id
  	     			AND ds.taxsubject_id = iptaxsubject_id
  	     	WHERE
  	     		ds.kinddoc = '1'
  	     		AND COALESCE (pdt.paydiscsum, 0) > 0
  	     	GROUP BY
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		ds.taxsubject_id
  	     	UNION ALL 
  	     	SELECT
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		MAX (COALESCE (o.oper_date, to_date ('01-01-1970', 'dd.mm.yyyy'))) paydate,
  	     		SUM (COALESCE (opd.discsum, 0)) paydiscsum
  	     	FROM
  	     		operdebt opd
  	     		JOIN "operation" o
  	     			ON   o.operation_id = opd.operation_id
  	     			AND o.null_date IS NULL
  	     		JOIN debtinstalment di
  	     			ON   di.debtinstalment_id = opd.debtinstalment_id
  	     		JOIN debtsubject ds
  	     			ON   ds.debtsubject_id = di.debtsubject_id
  	     			AND ds.taxsubject_id = iptaxsubject_id
  	     	WHERE
  	     		ds.kinddoc = '1'
  	     		AND COALESCE (opd.discsum, 0) > 0
  	     	GROUP BY
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		ds.taxsubject_id
  	     ) pd
  		ON   (
  		     	pd.taxperiod_id = ds.taxperiod_id
  		     	AND pd.kinddebtreg_id = ds.kinddebtreg_id
  		     	AND pd.partidano = ds.partidano
  		     )
  	 LEFT  JOIN debtinstalment di on di.debtsubject_Id = ds.debtsubject_id
  	    and di.instno = 	(
  	SELECT
  			MAX (dno.instno)
  		FROM
  			baldebtinst bno
  			JOIN debtinstalment dno
  				ON   dno.debtinstalment_id = bno.debtinstalment_id and coalesce(dno.instsum,0) > 0
  			JOIN debtsubject dsno
  				ON   dsno.taxsubject_id = iptaxsubject_id
  				AND dsno.kinddoc = '1'
  				AND dsno.kinddebtreg_id = ds.kinddebtreg_Id
  				AND dsno.taxperiod_id = ds.taxperiod_id
  				AND dsno.partidano = ds.partidano
  				AND dsno.debtsubject_id = dno.debtsubject_id
  		WHERE
  			COALESCE (bno.instsum, 0) > 0
  		GROUP BY
  			dsno.partidano,
  			dsno.taxperiod_id,
  			dsno.kinddebtreg_id,
  			dsno.taxsubject_id
  	)  
  	left join baldebtinst bdi on bdi.debtinstalment_id = di.debtinstalment_id and coalesce(bdi.instsum,0) > 0 --and bdi.instsum = 367.17000
  		AND bdi.instsum = (SELECT MAX (bsum.instsum)
  												FROM
  													baldebtinst bsum
  													JOIN debtinstalment dsum
  														ON   dsum.debtinstalment_id = bsum.debtinstalment_id   and dsum.instno = di.instno
  													JOIN debtsubject dsm
  														ON   dsm.debtsubject_id = dsum.debtsubject_id
  														AND dsm.taxsubject_id = iptaxsubject_id
  														AND dsm.kinddoc = '1'
  														AND dsm.kinddebtreg_id = ds.kinddebtreg_Id
  														AND dsm.taxperiod_id = ds.taxperiod_id
  														AND dsm.partidano = ds.partidano
  												WHERE     coalesce(bsum.instsum,0) >0) 
  WHERE	ds.taxsubject_id =  iptaxsubject_id
  	AND ds.partidano = (
  			CASE 
  				WHEN ippartno IS NULL THEN ds.partidano
  				WHEN ippartno = '0' THEN ds.partidano
  				ELSE ippartno
  			END 
  		    )
  	AND ds.kinddebtreg_id = (
  			CASE 
  				WHEN ipkinddebtreg_id IS NULL THEN ds.kinddebtreg_id
  				WHEN ipkinddebtreg_id = 0 THEN ds.kinddebtreg_id
  				ELSE ipkinddebtreg_id
  			END 
  		    )
  	AND td.documenttype_id NOT IN (26, 27, 28, 29)--без ПС
  	AND ds.kinddoc = '1'
   
  GROUP BY
  	ds.partidano,
  	d.percent,
  	d.termdisc,
  	ds.kinddebtreg_Id,	
  	ds.taxperiod_id,
  	ds.taxsubject_id
  HAVING
  	SUM (COALESCE (ds.totaltax, 0)) > 0 
  	AND Round ((SUM (COALESCE (ds.totaltax, 0)) * d.percent) / 100, 2) > SUM (COALESCE (pd.paydiscsum, 0)) 
  	AND max(di.termpay_date) >= trunc (ippaydate)  --максимален срок на вноската да е по-голям от срок на отстъпка????
  	AND coalesce(max(pd.paydate),to_date('01-01-1970', 'dd.mm.yyyy')) <= d.termdisc -- дата последното плащане,за което е направено отстъпка <= срок на отстъпка????
  	AND max(bdi.instsum) >= Round ((SUM (COALESCE (ds.totaltax, 0)) * d.percent) / 100, 2)-SUM (COALESCE (pd.paydiscsum, 0)) 
        
  UNION ALL
  SELECT 	--ds.partidano,
  	--ds.taxperiod_id,
  	--ds.kinddebtreg_Id,	
  	Round ((SUM (COALESCE (ds.totaltax, 0)) * d.percent) / 100, 2) - SUM (COALESCE (pd.paydiscsum, 0)) discsum--,
   	--max(bdi.debtinstalment_id) debtinstalment_id
  	
  FROM
  	debtsubject ds
  	JOIN taxdoc td--декларация
  		ON   td.taxdoc_id = ds.document_id
  	JOIN transport tr ON tr.taxdoc_id = td.taxdoc_id	
  	JOIN config c --текуща година
  		ON   c.municipality_id = ds.municipality_id
  		AND c.name = 'TAXYEAR'
  	LEFT JOIN config c2 --да има ли отстъпка за придобити МПС-та в срок на плащане за текуща година
  		ON   c2.municipality_id = ds.municipality_id
  		AND c2.name = 'MPS60' || c.configvalue
  	JOIN taxperiod tp --данъчен период
  		ON   tp.begin_date = to_date ('01.01.' || c.configvalue, 'dd.mm.yyyy')
  		AND tp.taxperkind = '0'
  		AND ds.taxperiod_id = tp.taxperiod_id
  	JOIN discount d --процент и дата на отстъпката
  		ON   (
  		     	d.documenttype_id = td.documenttype_id
  		     	AND d.taxperiod_id = tp.taxperiod_id
  		     	AND COALESCE (d.percent, 0) > 0
  		     	AND (
  		     	    	 (d.kinddebtreg = ds.kinddebtreg_id)
  		     	    	OR (d.kinddebtreg IS NULL)
  		     	    )
  		     	AND trunc (trunc (ippaydate)) <= d.termdisc --дата trunc (ippaydate) за изчисляване отстъпката да е по-малка от крайна дата на отстъпка
  		     )
  	LEFT JOIN (
  	     	SELECT
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		MAX (COALESCE (pd.paydate, to_date ('01-01-1970', 'dd.mm.yyyy'))) paydate,
  	     		SUM (COALESCE (pdt.paydiscsum, 0)) paydiscsum
  	     	FROM
  	     		paydebt pdt
  	     		JOIN paydocument pd
  	     			ON   pd.paydocument_id = pdt.paydocument_id
  	     			AND pd.null_date IS NULL
  	     		JOIN debtinstalment di
  	     			ON   di.debtinstalment_id = pdt.debtinstalment_id
  	     		JOIN debtsubject ds
  	     			ON   ds.debtsubject_Id = di.debtsubject_Id
  	     			AND ds.taxsubject_id = iptaxsubject_id
  	     	WHERE
  	     		ds.kinddoc = '1'
  	     		AND COALESCE (pdt.paydiscsum, 0) > 0
  	     	GROUP BY
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		ds.taxsubject_id
  	     	UNION ALL 
  	     	SELECT
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		MAX (COALESCE (o.oper_date, to_date ('01-01-1970', 'dd.mm.yyyy'))) paydate,
  	     		SUM (COALESCE (opd.discsum, 0)) paydiscsum
  	     	FROM
  	     		operdebt opd
  	     		JOIN "operation" o
  	     			ON   o.operation_id = opd.operation_id
  	     			AND o.null_date IS NULL
  	     		JOIN debtinstalment di
  	     			ON   di.debtinstalment_id = opd.debtinstalment_id
  	     		JOIN debtsubject ds
  	     			ON   ds.debtsubject_id = di.debtsubject_id
  	     			AND ds.taxsubject_id = iptaxsubject_id
  	     	WHERE
  	     		ds.kinddoc = '1'
  	     		AND COALESCE (opd.discsum, 0) > 0
  	     	GROUP BY
  	     		ds.partidano,
  	     		ds.taxperiod_id,
  	     		ds.kinddebtreg_id,
  	     		ds.taxsubject_id
  	     ) pd
  		ON   (
  		     	pd.taxperiod_id = ds.taxperiod_id
  		     	AND pd.kinddebtreg_id = ds.kinddebtreg_id
  		     	AND pd.partidano = ds.partidano
  		     )
  	LEFT JOIN debtinstalment di on di.debtsubject_Id = ds.debtsubject_id
  	    and di.instno = 	(
  		SELECT
  			MAX (dno.instno)
  		FROM
  			baldebtinst bno
  			JOIN debtinstalment dno
  				ON   dno.debtinstalment_id = bno.debtinstalment_id and coalesce(dno.instsum,0) > 0
  			JOIN debtsubject dsno
  				ON   dsno.taxsubject_id = iptaxsubject_id
  				AND dsno.kinddoc = '1'
  				AND dsno.kinddebtreg_id = ds.kinddebtreg_Id
  				AND dsno.taxperiod_id = ds.taxperiod_id
  				AND dsno.partidano = ds.partidano
  				AND dsno.debtsubject_id = dno.debtsubject_id
  		WHERE
  			COALESCE (bno.instsum, 0) > 0
  		GROUP BY
  			dsno.partidano,
  			dsno.taxperiod_id,
  			dsno.kinddebtreg_id,
  			dsno.taxsubject_id
  	)    
  	left join baldebtinst bdi on bdi.debtinstalment_id = di.debtinstalment_id AND coalesce(bdi.instsum,0)> 0 AND bdi.instsum = (SELECT MAX (bsum.instsum)
  												FROM
  													baldebtinst bsum
  													JOIN debtinstalment dsum
  														ON   dsum.debtinstalment_id = bsum.debtinstalment_id     and dsum.instno = di.instno
  													JOIN debtsubject dsm
  														ON   dsm.debtsubject_id = dsum.debtsubject_id
  														AND dsm.taxsubject_id = iptaxsubject_id 
  														AND dsm.kinddoc = '1'
  														AND dsm.kinddebtreg_id = ds.kinddebtreg_Id
  														AND dsm.taxperiod_id = ds.taxperiod_id
  														AND dsm.partidano = ds.partidano
  												WHERE      coalesce(bsum.instsum,0) >0) 
  WHERE	ds.taxsubject_id =  iptaxsubject_id
  	AND ds.partidano = (
  			CASE 
  				WHEN ippartno IS NULL THEN ds.partidano
  				WHEN ippartno = '0' THEN ds.partidano
  				ELSE ippartno
  			END 
  		    )
  	AND ds.kinddebtreg_id = (
  			CASE 
  				WHEN ipkinddebtreg_id IS NULL THEN ds.kinddebtreg_id
  				WHEN ipkinddebtreg_id = 0 THEN ds.kinddebtreg_id
  				ELSE ipkinddebtreg_id
  			END 
  		    ) 
  	AND td.documenttype_id IN (26, 27, 28, 29)--  ПС
  	AND (
  	    	(
  	    		to_char (COALESCE (td.earn_date, to_date ('01-01-1970', 'dd.mm.yyyy')), 'yyyy') 
  	    		<> to_char (trunc (ippaydate), 'yyyy') 
  	    		/* AKO ДАТА ПРИДОБИВАНЕ НЕ Е ТАЗИ ГОДИНА*/
  	    	)
  	    	OR 
  		( 
  			COALESCE (c2.configvalue, '0') = '1'  --OTСТЪПКА ЗА НОВОПРИДОБИТИ Е ВКЛЮЧЕНА
  			AND (COALESCE (td.earn_date, to_date ('01-01-1970', 'dd.mm.yyyy')) > COALESCE (tr.paidpodate,to_date ('01-01-1970', 'dd.mm.yyyy'))) 
  			)
  			/* ДАТА ПРИДОБИВАНЕ Е ПО-МАЛКА ОТ ДАТА ПЛАТЕНО ДО,АКО НЯМА ПЛАТЕНО ДО */
  		)
  	AND ( 
  		td.endtaxdate IS NULL --не са закрити
  		OR 
  		( td.endtaxdate >= to_date(to_char(trunc (ippaydate), 'yyyy')||'-12-31', 'yyyy-mm-dd') ) 
  		--закрити след
  	)
  	AND ds.kinddoc = '1'
  GROUP BY
  	ds.taxsubject_id,
  	ds.partidano,
  	d.percent,
  	d.termdisc,
  	ds.kinddebtreg_Id,
  	ds.taxperiod_id
  HAVING
  	SUM (COALESCE (ds.totaltax, 0)) > 0 
  	AND Round ((SUM (COALESCE (ds.totaltax, 0)) * d.percent) / 100, 2) > SUM (COALESCE (pd.paydiscsum, 0)) 
  	AND max(di.termpay_date) >= trunc (ippaydate)  --максимален срок на вноската да е по-голям от срок на отстъпка????
  	AND coalesce(max(pd.paydate),to_date('01-01-1970', 'dd.mm.yyyy')) <= d.termdisc -- дата последното плащане,за което е направено отстъпка <= срок на отстъпка????
  	AND max(bdi.instsum) >= Round ((SUM (COALESCE (ds.totaltax, 0)) * d.percent) / 100, 2)-SUM (COALESCE (pd.paydiscsum, 0)) 
  	--)  discsum
  	$function$
;
