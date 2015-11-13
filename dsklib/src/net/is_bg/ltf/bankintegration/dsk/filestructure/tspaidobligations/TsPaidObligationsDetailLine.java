package net.is_bg.ltf.bankintegration.dsk.filestructure.tspaidobligations;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.LineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;




/**
<pre>
Детайлни записи

1	Сметка на клиента	23	C	 IBAN
2	Основание           26	C	номер на транзакция, фактура и др.
3	Абонатен номер на клиента   23	C	
4	Сума на банкова операция	12	N	сумата без десетична точка, т.е. умножена по 100
5	Код за платено/отказано плащане      2	N	
6	Дата на извършване на плащането      8	N	YYYYMMDD

</pre>
 * @author lubo
 *
 */

class TsPaidObligationsDetailLine extends LineStructureBase{
	 
	//field lengths
	int ibanL = 23;
	int reasonL = 26;
	int einL = 10;
	int partidaL = 13;
	int sumL = 12;
	int code_payL = 2;
	int pay_dateL = 8;
	
	//begin & end indexes
	int ibanB = 0;         int ibanE = ibanB + ibanL;
	int reaonsB = ibanE;   int reasonE = reaonsB + reasonL;
	int einB = reasonE;    int einE = einB + einL;
	int partidaB = einE;   int partidaE = partidaB + partidaL;
	int sumB = partidaE;   int sumE = sumB + sumL;
	int code_payB = sumE;  int code_payE = code_payB + code_payL;
	int pay_dateB = code_payE;  int pay_dateE = pay_dateB + pay_dateL;
	 

	public String getPattern() {
		// TODO Auto-generated method stub
		return DskConstants.IBAN_REG_EX  + ".{49}\\d{22}";                           
	}

	
	public LineFields parseLine(String line) {
		// TODO Auto-generated method stub
		LineFields fields = new LineFields();
		
		//get data fields
		String iban = line.substring(ibanB, ibanE).trim();
		String reason = line.substring(reaonsB, reasonE);
		String ein = line.substring(einB, einE).trim();
		String partida = line.substring(partidaB, partidaE).trim();
		String sum = line.substring(sumB, sumE);
		String code_pay = line.substring(code_payB, code_payE);
		String pay_date = line.substring(pay_dateB, pay_dateE);
		
		//fill in map
		fields.map.put(DskConstants.FIELD_NAME.IBAN, (iban));
		fields.map.put(DskConstants.FIELD_NAME.REASON, reason);
		fields.map.put(DskConstants.FIELD_NAME.EIN,  (ein));
		fields.map.put(DskConstants.FIELD_NAME.PARTIDA, (partida));
		fields.map.put(DskConstants.FIELD_NAME.PAID_SUM,(sum));
		fields.map.put(DskConstants.FIELD_NAME.CODE,    (code_pay));
		fields.map.put(DskConstants.FIELD_NAME.PAY_DATE, (pay_date));
		fields.map.put(DskConstants.FIELD_NAME.ROW, line);
		
		return fields;
	}
	
}
