package net.is_bg.ltf.bankintegration.dsk.filestructure.tsobligations;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.LineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;




/**
<pre>
Детайлни записи
1	Сметка на клиента	        23	C	IBAN
2	Основание                   26	C	номер на транзакция, фактура и др.
3	Абонатен номер на клиента   23	C	
4	Сума на банкова операция	12	N	сумата без десетична точка, т.е.  умножена по 100
</pre>
* @author lubo
*
*/

class TsObligationsDetailLine extends LineStructureBase{

	public String getPattern() {
		// TODO Auto-generated method stub
		return DskConstants.IBAN_REG_EX + ".{49}\\d{12}";
	}

	public LineFields parseLine(String line) {
		// TODO Auto-generated method stub
		return null;
	}
	
}
