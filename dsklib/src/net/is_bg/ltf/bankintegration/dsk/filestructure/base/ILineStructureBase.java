package net.is_bg.ltf.bankintegration.dsk.filestructure.base;

import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;


public interface ILineStructureBase {
	public abstract String getPattern();
	public abstract void validateLine(String line) throws DskInvalidLineException;
	public abstract LineFields parseLine(String line);
	
}
