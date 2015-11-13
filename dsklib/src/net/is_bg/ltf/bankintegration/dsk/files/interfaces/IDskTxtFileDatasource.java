package net.is_bg.ltf.bankintegration.dsk.files.interfaces;

import java.util.List;

/**
 * <pre>
 * Get file content from some source in the form of list of lines.
 * This is primarily aimed at creating a File datasource either out of File itself or an Sql Query result!
 *<b> 
 * 1.Create Datasource from file lines to be imported to DataBase.
 * 2.Create Datasource from Sql query result to be exported & saved to file.
 * </b>
 * </pre>
 * */
public interface IDskTxtFileDatasource {
	List<String> getData();
}
