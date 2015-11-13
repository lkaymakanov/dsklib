package net.is_bg.ltf.bankintegration.dsk.filestructure.tspaidobligations;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.IFileStructure;
import net.is_bg.ltf.bankintegration.dsk.filestructure.base.ILineStructureBase;



/**
 *<pre>
 *<h1>ФАЙЛЪТ СЪС ЗАДЪЛЖЕНИЯТА, КОЙТО ИЗКАРВАМЕ И ПОДАВАМЕ НА ДСК</h1>
 * I. ФОРМАТ НА ФАЙЛ, ПРЕДАВАН ОТ КОНТРАГЕНТ В "БАНКА ДСК", ЗА ПЛАЩАНЕ НА УСЛУГИ

1. Име на файла при обработка в ЦУ - XXXXXXX_YYMMDD_CC.NN
Kъдето:
XXXXXXX -  Уникален номер на контрагента 
YY                –  последните 2 цифри от годината
ММ                –  месеца
DD                –  2 цифри ден
CC                –  код на услугата 
NN                –  пореден файл за деня
2. Формат на файлa
Данните във файла са оформени в два типа записи: 
•	заглавен запис - заглавният запис е един и се записва в началото на файла
•	детайлни записи
Всеки запис завършва с (CR)(LF), т.е. 0D0A.
Заглавен запис

1	Вид масово плащане	2	C	MP – големи букви латиница
2	Уникален номер на контрагент	7	C	Генерира се от БДСК
3	Код услуга	2	C	Генерира се от БДСК
4	Начална дата за осчетоводяване	8	N	YYYYMMDD
5	Крайна дата за осчетоводяване	8	N	YYYYMMDD
6	Период на плащане	2	N	Месец за които се отнася плащането
7	Сметка на контрагента	23	C	 IBAN
8	Име на контрагента      26	C	 Наименование на контрагента
9	Основание за плащане	26	C	
10	Код валута на банк. операция по ISO-SWIFT        	3	C	за BGN запълнено със шпации, ASCII x’20’
11	Обща сума                                           14	N	сумата без десетична точка, т.е.  умножена по 100
12	Брой детайлни записи                                6	N	запълнено с водещи нули
13	Контролен код	7C  шпации	резервирани за бъдещо ползване,


Детайлни записи

1	Сметка на клиента	        23	C	 IBAN
2	Основание                   26	C	номер на транзакция, фактура и др.
3	Абонатен номер на клиента   23	C	
4	Сума на банкова операция	12	N	сумата без десетична точка, т.е.  умножена по 100
</pre>
 * @author lubo
 *
 */

public class TsPaidObligationsFileStructure implements IFileStructure{

	TsPaidObligationsHeaderLine header = new TsPaidObligationsHeaderLine();
	TsPaidObligationsDetailLine detail = new TsPaidObligationsDetailLine();
	
	public ILineStructureBase getFileHeader() {
		// TODO Auto-generated method stub
		return header;
	}

	public ILineStructureBase getFileDetail() {
		// TODO Auto-generated method stub
		return detail;
	}

}