package net.is_bg.ltf.bankintegration.dsk.files.interfaces;

/**
 * Provides the methods we invoke on dsk files - the major dsk file interface!!!
 * @author lubo
 *
 */
public interface IDskFile {
	
	/**Transfer file from client to application*/
	void uploadFile();
	
	/** Exports the file to client*/
	void downloadFile();
	
	/**Check if we got the right file*/
	void validateFile();
	
	/***Get the content out of file in the form of LineFields*/
	void parseFile();
	
	/**Performs logic on files*/
	void processFile();

	/**Delete the file*/
	void deleteFile();
	
}
