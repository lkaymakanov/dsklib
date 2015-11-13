package net.is_bg.ltf.bankintegration.dsk.filestructure.activeservices;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.LineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;




/**
 * <pre>
   1	Уникален номер на контрагент	7	C	Генерира се от БДСК
   2	Сметка на контрагента	        23	С	IBAN
   3	Код услуга	                     2	C	Генерира се от БДСК
   4	Начална дата за периода	         8	N	ГГГГММДД/винаги 00000000/
   5	Крайна дата за периода	         8	N	ГГГГММДД – дата към която записите са активни
   6	Брой детайлни записи             6	N	запълнено с водещи нули
</pre>
 * @author lubo
 *
 */

class ActiveServiceHeaderLineStructure extends LineStructureBase{

	public String getPattern() {
		// TODO Auto-generated method stub
		return "\\w{7}"+  DskConstants.IBAN_REG_EX + "\\d{24}";                    //pattern is 30 chars followed by 24 digits....
	}

	public LineFields parseLine(String line) {
		// TODO Auto-generated method stub
		LineFields fields = new LineFields();
		
		//get data fields
		String contagentNo = line.substring(0, 7).trim();
		String iban = line.substring(7, 30).trim();
		String code = line.substring(30, 32).trim();
		String begin_date = line.substring(32, 40);
		String end_date = line.substring(40, 48);
		String row_count = line.substring(48, 54);
		
		//fill in map
		fields.map.put(DskConstants.FIELD_NAME.CONTRAGENT_NO,  contagentNo);
		fields.map.put(DskConstants.FIELD_NAME.IBAN,  iban);
		fields.map.put(DskConstants.FIELD_NAME.CODE,  code);
		fields.map.put(DskConstants.FIELD_NAME.BEGIN_DATE,  begin_date);
		fields.map.put(DskConstants.FIELD_NAME.END_DATE,  end_date);
		fields.map.put(DskConstants.FIELD_NAME.ROW_COUNT,  row_count);
		fields.map.put(DskConstants.FIELD_NAME.ROW,  line);
		
		return fields;
	}

}
