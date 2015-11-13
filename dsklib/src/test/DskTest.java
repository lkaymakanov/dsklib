package test;


import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;


public class DskTest {

	public static void main(String [] arg){
		 String errInvalidHeader = DskConstants.MSG_BANKDSK.getString("err.invalid.header");
		 String errInvalidRow = DskConstants.MSG_BANKDSK.getString("err.invalid.detailline");
		 String errInvalidDatasource = DskConstants.MSG_BANKDSK.getString("err.empty.datasource");
		
		 System.out.println(errInvalidDatasource); 
		 System.out.println(errInvalidHeader); 
		 System.out.println(errInvalidRow); 
	}
}
