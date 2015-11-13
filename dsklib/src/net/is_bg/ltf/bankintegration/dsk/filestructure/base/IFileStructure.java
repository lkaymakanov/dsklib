package net.is_bg.ltf.bankintegration.dsk.filestructure.base;

public interface IFileStructure {
	/** Structure of header line !*/
	public ILineStructureBase getFileHeader();
	
	/**The structure of detail line !*/
	public ILineStructureBase getFileDetail();
	
	
}
