package net.is_bg.ltf.bankintegration.dsk.filestructure.filefields;

import java.util.Hashtable;
import java.util.Map;


/**
 * The returned result after parsing a line / header or detail
 * 
 * @author lubo
 *
 */
public class LineFields {
	public  Map<DskConstants.FIELD_NAME, String> map = new Hashtable<DskConstants.FIELD_NAME, String>();
}
