package net.is_bg.ltf.bankintegration.dsk.files.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import net.is_bg.ltf.bankintegration.dsk.files.interfaces.IDskTxtFileDatasource;



/**
 * Creates data Source out of a FileStream!
 * @author lubo
 *
 */
public class DskFileImportDataSource implements IDskTxtFileDatasource{

	List<String> list;
	
	/**No-arg constructor delay the reading up to invoking fillFileList*/
	public DskFileImportDataSource(){
		
	}
	
	/**Create datasource by file name
	 * @throws IOException */
	public DskFileImportDataSource(String filename) throws IOException{
		fillFileList(new  File(filename));
	}
	
	/**Create datasource by file object
	 * @throws IOException */
	public DskFileImportDataSource(File file) throws IOException{
		fillFileList(file);
	}
	
	
	/**
	 * Fill the line list by reading File line by line!
	 * @param file
	 * @throws IOException
	 */
	public  void fillFileList(File file) throws IOException
	{
		BufferedReader reader = null;
		try{
			list =  new ArrayList<String>();
			reader = new BufferedReader(new FileReader(file));
			String line;
			
			//read line by line & put in the list
			while((line = reader.readLine()) !=null) {
				list.add(line.trim());
			}
		}finally{
			reader.close();
		}
		
	}
	
	
	
	public List<String> getData() {
		// TODO Auto-generated method stub
		return list;
	}

}
