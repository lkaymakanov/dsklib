package net.is_bg.ltf.bankintegration.dsk.utils;

import net.is_bg.ltf.bankintegration.dsk.filestructure.base.DskInvalidLineException;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants.CODE_OF_FAVOUR;

public class DskUtils {

	/**Removes the file path from filename if filename contains file path.*/
	public static String extractFileName(String filePathName ){
		  if(filePathName == null) return filePathName;
		  int lastSlash=  filePathName.lastIndexOf("\\");
		  if(lastSlash > -1)  return filePathName.substring(lastSlash+1);
		  return filePathName;
	}
	
	
	/**Padding up to fixed length with intervals or zeroes in front of string or after string.*/
	public static String getPadding(String st, String paddingSymbol, int upto, boolean left){
		//StringBuilder sb = new StringBuilder(st);
		
		if(st != null && upto >= st.length()){
			int diff = upto - st.length();
			for(int i = 0; i < diff; i ++ ){
				if(left)  st = paddingSymbol + st;
				else      st = st + paddingSymbol;
			}
		}
		return st;
	}
	
	/**remove  file extension from file name*/
	public static String removeFileExtension(String filenamePath){
		 if(filenamePath == null) return filenamePath;
		 int lastDot =  filenamePath.lastIndexOf(".");
		 if(lastDot > -1) return filenamePath.substring(0, filenamePath.indexOf("."));
		 return filenamePath;
	}
	
	
	/**
	 * Validate code of favour!!!
	 * @param code
	 */
	public static void validateCodeofFavour(CODE_OF_FAVOUR code){
		
		if(code == null) throw new DskInvalidLineException("Header Line - unknown code favour...");
		
		switch (code) {
			case DNI:
				break;
			case TBO:
				break;
			case MPS:
				break;
			case DOG:
				break;
		default:
			throw new DskInvalidLineException("Header Line - unknown code favour...");
		}
	}
	
	
}
