package net.is_bg.ltf.bankintegration.dsk.filestructure.base;

public class DskInvalidFileException  extends RuntimeException {


	private static final long serialVersionUID = -3828022137855659030L;
	
	public DskInvalidFileException(){}
	
	public DskInvalidFileException(String msg){
		super(msg);
	}

}
