package net.is_bg.ltf.bankintegration.dsk.filestructure.tsobligations;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.LineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;


/***
<pre>
Заглавен запис

1	Вид масово плащане	2	C	MP – големи букви латиница
2	Уникален номер на контрагент	7	C	Генерира се от БДСК
3	Код услуга	2	C	Генерира се от БДСК
4	Начална дата за осчетоводяване	8	N	YYYYMMDD
5	Крайна дата за осчетоводяване	8	N	YYYYMMDD
6	Период на плащане	2	N	Месец за които се отнася плащането
7	Сметка на контрагента	23	C	 IBAN
8	Име на контрагента      26	C	Наименование на контрагента
9	Основание за плащане	26	C	
10	Код валута на банк. операция по ISO-SWIFT        	3	C	за BGN запълнено със шпации, ASCII x’20’

11	Обща сума                                                                  	14	N	сумата без десетична точка, т.е. 
умножена по 100
12	 Брой детайлни записи                                               	6	N	запълнено с водещи нули
13	   Контролен код	7C шпации	резервирани за бъдещо ползване,
</pre>
* @author lubo
*/
class TsObligationsHeaderLine  extends LineStructureBase{

	
	public String getPattern() {
		// TODO Auto-generated method stub
		return "MP\\w{7}\\d{2}\\d{18}" + DskConstants.IBAN_REG_EX  + ".{55}\\d{14}\\d{6}";
	}

	public LineFields parseLine(String line) {
		// TODO Auto-generated method stub
		return null;
	}

}
