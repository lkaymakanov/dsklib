package net.is_bg.ltf.bankintegration.dsk.files.impl;

import java.util.ArrayList;
import java.util.List;

import net.is_bg.ltf.bankintegration.dsk.files.interfaces.IDskTxtFileDatasource;
import net.is_bg.ltf.bankintegration.dsk.filestructure.base.IFileStructure;
import net.is_bg.ltf.bankintegration.dsk.filestructure.base.ILineStructureBase;
import net.is_bg.ltf.bankintegration.dsk.filestructure.base.DskInvalidLineException;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.DskConstants;
import net.is_bg.ltf.bankintegration.dsk.filestructure.filefields.LineFields;


public abstract class DskFileValidator extends DskFileAdapter{

	/*** file Structure*/
	protected  IFileStructure fileStruct;
	protected  List<String>  lines;
	protected  IDskTxtFileDatasource datasource;
	protected  List<LineFields> fileData;
	private int MAX_ERR_LINES = 20;
	private String errInvalidHeader = DskConstants.MSG_BANKDSK.getString("err.invalid.header");
	private String errInvalidRow = DskConstants.MSG_BANKDSK.getString("err.invalid.detailline");
	private String errInvalidDatasource = DskConstants.MSG_BANKDSK.getString("err.empty.datasource");
	
	/** Validate File content - header & details just validate against the REGEX.*/
	protected void validateLines(){
		StringBuilder invalidLines  = new StringBuilder(1);
		int i = 0;
		int errCnt = 0;
		try{
			//validate header
			fileStruct.getFileHeader().validateLine(lines.get(i));
		}
		catch (DskInvalidLineException e) {
			invalidLines.append(errInvalidHeader);
		}
			
		//validate details
		for(i = 1; i < lines.size(); i++)
		{
			if(errCnt >= MAX_ERR_LINES)   break;  
			try{
				fileStruct.getFileDetail().validateLine(lines.get(i));	
			}catch (DskInvalidLineException e) {
				// TODO: handle exception
				invalidLines.append(String.format(errInvalidRow, i+1));
				errCnt++;
			}
		}
		
		//check if we have errors
		if(invalidLines.capacity() > 1){
			throw new DskInvalidLineException(invalidLines.toString());
		}
	}
	
	/**parse the file content*/
	protected void parseLines(){
		fileData = new ArrayList<LineFields>();
		
		//parse header
		LineFields  fields = fileStruct.getFileHeader().parseLine(lines.get(0));
		fileData.add(fields);
		
		//get detail line structure
		ILineStructureBase detailLineStruct = fileStruct.getFileDetail();
		
		//parse the details
		for(int i = 1; i < lines.size(); i++){
		   fields = detailLineStruct.parseLine(lines.get(i));
		   fileData.add(fields);
		}
	}
	

	public void validateFile() {
		// TODO Auto-generated method stub
		if(datasource == null || datasource.getData() == null || datasource.getData().isEmpty()){
			throw new RuntimeException(errInvalidDatasource);
		}
		
		//get file content
		lines = datasource.getData();
		
		//validate lines
		validateLines();
		
		//parse lines 
	    parseLines();
		
		//check header row columns  if valid
		validateHeaderFields();
	}
	
	protected abstract void validateHeaderFields();
	
}
