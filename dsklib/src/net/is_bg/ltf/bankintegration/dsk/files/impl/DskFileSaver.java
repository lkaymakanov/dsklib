package net.is_bg.ltf.bankintegration.dsk.files.impl;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.List;



/**
 * Write output file to servlet OutputStream or to a File!!!!
 * @author lubo
 *
 */
public class DskFileSaver {

	private File f;
	private List<String> lines;
	
	public DskFileSaver(String filename, List<String> lines){
		this(new File(filename), lines);
	}
	
	public DskFileSaver(File file, List<String> lines){
		f = file;
		this.lines = lines;
	}
	
	
	
	public void save() throws FileNotFoundException {
		PrintWriter writer = new PrintWriter(f);
		for(int i =0 ;i < lines.size(); i++) {
			writer.write(lines.get(i) + "\n");
		}
		writer.flush();
		writer.close();
	}
	
	public void save(OutputStream out, String lineSeparator){
		//FileUtil.saveFileAsText(lines, f.getName(), "\n");
		
		try {
            for (int i = 0; i < lines.size(); i++) {
            	//System.out.println(list.get(i));
				out.write(lines.get(i).getBytes("Cp1251"));
				if(lineSeparator != null) out.write(lineSeparator.getBytes("Cp1251"));
			}
		   //response.flushBuffer();
		   } catch (IOException e1) {
		      System.out.println("exception occured: "+ e1.getMessage());
		   } 
 	       
 	      finally{
			    try {
					out.flush();
					out.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
		   }
		
	}
}


