package net.is_bg.ltf.bankintegration.dsk.filestructure.filefields;

import java.util.ResourceBundle;



/**
 * All the names of the fields found in all the files +  other constants
 * 
 * @author lubo
 *
 */
public class DskConstants {
	
	   /**IBAN REGULAR EXPRESSION*/
	   public static String IBAN_REG_EX = "[\\D\\S]{2}\\d{2}[\\D\\S]{4}\\d{14}[\\D\\S]{1}";
	   public static ResourceBundle MSG_BANKDSK = ResourceBundle.getBundle("dsk");
	   
	   public static final String ACTIVE_SERVICE_FTYPE = "ACTIVE_SERVICE";
	   public static final String PAYMENT_FTYPE = "PAYMENT";
	   
	  
	   public enum CODE_OF_FAVOUR{
		   DNI("80", "2100"),
		   TBO("81","2400"),
		   MPS("82","2300"),
		   DOG("83","8013"),
		   
		   UNKNOWN("", "");
		   
		   CODE_OF_FAVOUR(String dskVal, String mateusVal){
			   this.dskVal = dskVal;
			   this.mateusVal = mateusVal;
		   }
		   
		   private String dskVal;
		   private String mateusVal;
		   
		   public String getDskVal(){return dskVal;}
		   public String getMateusVal(){return mateusVal;}
		   
		   public static CODE_OF_FAVOUR toCodeOfVavFavour(String code){
			   CODE_OF_FAVOUR c =  UNKNOWN;
			   
			   if(code == null) return c;
			   
			   CODE_OF_FAVOUR [] codes  = values();
			   for(int i=0; i < codes.length ; i++ ){
				   if(codes[i].getDskVal().equals(code) || codes[i].getMateusVal().equals(code))
					   return codes[i];
			   }
			   
			   return c;
		   }
		   
	   };
	   
	   
	
	   public enum CODE_OF_PAYMENT_STATUS{
		   
		   /**Платените услуги се маркират с код 99, а отказаните съгласно номенклатурата:*/
		   SUCCESSFUL_PAYMENT("99"),
		   
		   /*** -	01 – няма такава сметка в Банката*/
		   NO_ACCOUNT("01"),
		   
		   /**-	02 – сметката не може да се дебитира/блокирана сметка/*/
		   BLOCKED_ACCOUNT("02"),
		   
		   /**-	03 – липсват средства по сметката на клиента*/
		   NO_MONEY("03"),
		   
		   /**-	04 – сметката на клиента е заемна*/
		   OTHER_ACCOUNT("04"),
		   
		   /**-	05 – сметката на клиента е от друга валута*/
		   WRONG_CURRENCY("05"),
		   
		   /**-	06 – сметката на клиента не е разплащателна*/
		   NO_PAYMENT_ACCOUNT("06"),
		   
		   /**-	07 – не е заявено плащане от тази сметка*/
		   NO_PAYMENT_REQUEST("07"),
		   
		   /**-	08 – плащане с бъдещ вальор не се допуска */
		   NO_FUTURE_VALUE_PAYMENT_ALLOWED("08"),
		   
		   /**-	09 – спряна услуга от клиента*/
		   STOPPED_FAVOUR("09"),
		   
		   /**-	10 – грешна сметка на клиент*/
		   WRONG_ACCOUNT("10");

		   
		   CODE_OF_PAYMENT_STATUS(String val){
			   this.val = val;
		   }
		   
		   private String val;
		   public String getVal(){return val;}
	   };
	   
	   public enum FIELD_NAME {

		   /***
		    * Either code of favour or code of payment
		    */
		    CODE,
		    
		   /*** MP constant*/
		    MP,
		    
		   /**OP Constant*/
		    OP,
		   
		   /**EIN*/
		    EIN,
		   
		   /**IBAN */
		    IBAN,
		   
		   /**NAME of taxsubject*/
		    TS_NAME,
		   
		   /**The sum paid by client*/
		    PAID_SUM ,
		   
		    PARTIDA ,
		   
		   /*** Unikalen nomer na kontragent*/
		    CONTRAGENT_NO ,
		   
		   /**PAY STATUS - successful or not  99 indicates successful payment, all others not!!!!!! */
		    PAY_STATUS,
		   
		   /**Data na otkrivane na usluga*/
		    DATE_SERVICE,
		   
		   /*** broi detailni zapisi*/
		    ROW_COUNT,

		   /**nachalna data na perioda*/
		    BEGIN_DATE,
		   
		   /**kraina data na perioda*/
		    END_DATE,
		   
		   /**Data na plashtane*/
		    PAY_DATE,
		   
		   /**Period na plashtane*/
		    PAY_PERIOD ,
		   
		    ACTIVE_SERVICE_FTYPE,
		   
		    PAYMENT_FTYPE ,
		   
		    REASON,
		   
		   /**
		    * The original file row
		    */
		    ROW 
	}

	  
	   
	   /**scripts constants*/
	   public static final String SCRIPT_PROLOG = "do \n   $$declare \n"; // dskfile_id numeric;  \n begin  ";											
	   public static final String SCRIPT_EPILOG = " end$$; \n";
	
}
