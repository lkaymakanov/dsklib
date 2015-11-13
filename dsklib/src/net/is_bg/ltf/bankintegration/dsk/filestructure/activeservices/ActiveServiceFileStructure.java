package net.is_bg.ltf.bankintegration.dsk.filestructure.activeservices;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.IFileStructure;
import net.is_bg.ltf.bankintegration.dsk.filestructure.base.ILineStructureBase;

/**
 * <pre>
 * <h1>ПЪРВИЯТ ФАЙЛ, КОЙТО ПОЛУЧАВАМЕ ОТ БДСК С ЕГН - ТА И ПАРТИДИ НА ХОРАТА, ЗАЯВИЛИ ДИРЕКТЕН ДЕБИТ</h1>
 * 
 * IV. ФОРМАТ НА ФАЙЛ, СЪДЪРЖАЩ АКТИВНИТЕ УСЛУГИ 

Банка ДСК изпраща на контрагента файл, съдържащ активните заявени услуги при поискване. 


1. Име на файла при централизирана обработка XXXXXXX AU.TXT
Където:
XXXXXXX       - уникален номер на контрагента 
A,U           - буквите A и U 
ТХТ           – буквите Т, Х и Т

2. Формат на файла
Данните във файла са оформени в два типа записи: 
•	заглавен запис - заглавният запис е един и се записва в началото на файла
•	детайлни записи
Всеки запис завършва с (CR)(LF), т.е. 0D0A.

Заглавен запис

1	Уникален номер на контрагент	7	C	Генерира се от БДСК
2	Сметка на контрагента	23	С	 IBAN
3	Код услуга	2	C	Генерира се от БДСК
4	Начална дата за периода	8	N	ГГГГММДД/винаги 00000000/
5	Крайна дата за периода	8	N	ГГГГММДД – дата към която записите са активни
6	Брой детайлни записи                                                        	6	N	



Детайлни записи

1	Абонатен номер на клиента                            	23	C	
2	Банкова сметка на клиента	23	C	 IBAN
4	Код състояние ( 00 или 99 )	2	N	00 – открита услуга за сметката
5	Име на титуляра на с/ката                                                    	40	C	
6	Дата                                                     	8	N	ГГГГММДД – дата на откриване на услугата



 * </pre>
 * 
 * @author lubo
 *
 */
public class ActiveServiceFileStructure implements IFileStructure{
	
	private  ActiveServiceHeaderLineStructure header = new ActiveServiceHeaderLineStructure();
	private  ActiveServiceDetailLineStructure detail = new ActiveServiceDetailLineStructure();
	
	public ILineStructureBase getFileHeader() {
		// TODO Auto-generated method stub
		return header;
	}

	public ILineStructureBase getFileDetail() {
		// TODO Auto-generated method stub
		return detail;
	}

}
