package net.is_bg.ltf.bankintegration.dsk.filestructure.base;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class LineStructureBase implements ILineStructureBase{

	
	private int startIndex = 0;
	
	public void validateLine(String line) throws DskInvalidLineException {
		// TODO Auto-generated method stub
		Pattern pattern = Pattern.compile(getPattern());
		Matcher matcher = pattern.matcher(line);
		
		boolean found = false;
        while (matcher.find()) {
           /* System.out.format("I found the text" +
                " \"%s\" starting at " +
                "index %d and ending at index %d.%n",
                matcher.group(),
                matcher.start(),
                matcher.end());*/
        	if(matcher.start() == startIndex) found = true;
            break;
        }
        if(!found){
           throw new DskInvalidLineException();
        }
	}

}
