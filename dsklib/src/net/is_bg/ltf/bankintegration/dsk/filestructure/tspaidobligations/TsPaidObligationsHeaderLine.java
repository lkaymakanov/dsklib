package net.is_bg.ltf.bankintegration.dsk.filestructure.tspaidobligations;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.LineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;


/**
<pre>
Заглавен запис
1	Вид масово плащане	2	C	OP – големи букви латиница
2	Уникален номер на контрагент	7	C	Генерира се от БДСК
3	Код услуга	2	C	Генерира се от БДСК
4	Начална дата за осчетоводяване	8	N	YYYYMMDD
5	Крайна дата за осчетоводяване	8	N	YYYYMMDD
6	Период на плащане	2	N	Месец за които се отнася плащането
7	Сметка на контрагента 	23	C	 IBAN
8	Име на контрагента                                                   	26	C	Наименование на контрагента
9	Основание за плащане	26	C	
10	Код валута на банк. операция по ISO-SWIFT        	3	C	за BGN запълнено със шпации, ASCII x’20’
11	Обща сума                                                                  	14	N	сумата без десетична точка, т.е. умножена по 100
12	Брой детайлни записи                                               	6	N	запълнено с водещи нули
13	Контролен код	7	C	резервирани за бъдещо ползване, 7 шпации

</pre>
 * @author lubo
 *
 */

class TsPaidObligationsHeaderLine  extends LineStructureBase{
	
	
	//field lengths
	int opL = 2;    
	int contragentL = 7;   
	int codefavourL = 2;
	int begin_dateL = 8;
	int end_dateL = 8;
	int pay_periodL = 2;
	int ibanL = 23;
	int contragent_nameL = 26;
	int reasonL = 26;
	int code_valutaL = 3;
	int sumL = 14;
	int rowCntL = 6;
	 
	//begin & end indexes
	int opB = 0;                    int opE = opB + opL;
	int contragentB = opE;          int contragentE = contragentB + contragentL;
	int codefavourB = contragentE;  int  codefavourE = codefavourB + codefavourL;
	int begin_dateB = codefavourE;  int begin_dateE = begin_dateB + begin_dateL;
	int end_dateB = begin_dateE;    int end_dateE = end_dateB + end_dateL;
	int pay_periodB = end_dateE;    int pay_periodE = pay_periodB + pay_periodL;
	int ibanB = pay_periodE;        int ibanE = ibanB + ibanL;
	int contragent_nameB = ibanE;   int contragent_nameE = contragent_nameB + contragent_nameL;
	int reasonB = contragent_nameE; int reasonE = reasonB + reasonL;
	int code_valutaB = reasonE;     int code_valutaE = code_valutaB + code_valutaL;
	int sumB = code_valutaE;        int sumE = sumB + sumL;
	int rowCntB = sumE;             int rowCntE = rowCntB + rowCntL;
	
	

	public String getPattern() {
		// TODO Auto-generated method stub
		return DskConstants.FIELD_NAME.OP + "\\w{7}\\d{20}" + DskConstants.IBAN_REG_EX  + ".{55}\\d{20}";
	}

	public LineFields parseLine(String line) {
		// TODO Auto-generated method stub
		LineFields fields = new LineFields();
		

		//get data fields
		//String op = line.substring(opB, opE);
		String contragent_no = line.substring(contragentB, contragentE).trim();
		String code = line.substring(codefavourB , codefavourE).trim();
		String begin_date = line.substring(begin_dateB, begin_dateE);
		String end_date = line.substring(end_dateB, end_dateE);
		String pay_period = line.substring(pay_periodB, pay_periodE);
		String iban = line.substring(ibanB, ibanE);
		/*
		String contragent_name = line.substring(contragent_nameB, contragent_nameE);
		String reason = line.substring(reasonB, reasonE);
		String code_valuta = line.substring(code_valutaB, code_valutaE);*/
		
		String sum = line.substring(sumB, sumE);
		String rowCcnt = line.substring(rowCntB, rowCntE);
		
		//fill in map
		fields.map.put(DskConstants.FIELD_NAME.CONTRAGENT_NO, (contragent_no));
		fields.map.put(DskConstants.FIELD_NAME.CODE,          (code));
		fields.map.put(DskConstants.FIELD_NAME.BEGIN_DATE,    (begin_date));
		fields.map.put(DskConstants.FIELD_NAME.END_DATE,      (end_date));
		fields.map.put(DskConstants.FIELD_NAME.PAY_PERIOD,    (pay_period));
		fields.map.put(DskConstants.FIELD_NAME.IBAN,          (iban));
		fields.map.put(DskConstants.FIELD_NAME.PAID_SUM,      (sum));
		fields.map.put(DskConstants.FIELD_NAME.ROW_COUNT,     (rowCcnt));
		fields.map.put(DskConstants.FIELD_NAME.ROW,  line);
		
		return fields;
	}

}
