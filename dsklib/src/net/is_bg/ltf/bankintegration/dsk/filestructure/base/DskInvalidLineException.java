package net.is_bg.ltf.bankintegration.dsk.filestructure.base;

public class DskInvalidLineException extends RuntimeException {


	private static final long serialVersionUID = -3828022137855659030L;
	
	public DskInvalidLineException(){}
	
	public DskInvalidLineException(String msg){
		super(msg);
	}

}
