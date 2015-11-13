package net.is_bg.ltf.bankintegration.dsk.filestructure.activeservices;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.LineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;

/**
 * <pre>
  	1	Абонатен номер на клиента    23	C	 EGN i partida
	2	Банкова сметка на клиента	 23	C	 IBAN
	4	Код състояние 	              2	N	00 – открита услуга за сметката
	5	Име на титуляра на с/ката   40	C	
	6	Дата                     8	N	ГГГГММДД – дата на откриване на услугата
	7	Допълнителна информация	18	N	Попълнени или празни позиции
</pre>
 * @author lubo
 *
 */

class ActiveServiceDetailLineStructure extends  LineStructureBase{
	
	//field lengths
	int einL = 10;
	int partidaL = 13;
	int ibanL = 23;
	int codeL = 2;
	int tsnameL = 40;
	
	//
	int einB= 0;           int einE = einB + einL; 
	int partidaB = einE;   int partidaE = partidaB + partidaL;
	int ibanB = partidaE;  int ibanE = ibanB + ibanL;
	int codeB = ibanE;     int codeE = codeB + codeL;
	int tsnameB = codeE;   int tsnameE = tsnameB + tsnameL;

	public String getPattern() {
		// TODO Auto-generated method stub
		return ".{23}" + DskConstants.IBAN_REG_EX + "\\d{2}.{40}";                     //EIN(10) + partida(13) + IBAN(23) = 46, 2 digits is the code, ts_name = 40  - don't care about the rest
	}

	public LineFields parseLine(String line) {
		// TODO Auto-generated method stub
		LineFields fields = new LineFields();
		
		//get data fields
		String ein = line.substring(einB, einE).trim();
		String partida = line.substring(partidaB, partidaE).trim();
		String iban = line.substring(ibanB, ibanE).trim();
		String code = line.substring(codeB, codeE).trim();
		String tsname = line.substring(tsnameB, tsnameE).trim();
		
		//fill in map
		fields.map.put(DskConstants.FIELD_NAME.EIN, ein);
		fields.map.put(DskConstants.FIELD_NAME.IBAN, iban);
		fields.map.put(DskConstants.FIELD_NAME.PARTIDA, partida);
		fields.map.put(DskConstants.FIELD_NAME.CODE, code);
		fields.map.put(DskConstants.FIELD_NAME.TS_NAME, tsname);
		fields.map.put(DskConstants.FIELD_NAME.ROW, line);
		
		return fields;
	}

}
