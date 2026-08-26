//																							
//																							
//	This code does several things:															
//	First																					
//		Makes sure that the contents 0f the input box DO match the list on line 24			
//		In this list not only numbers but also the period is allowed						
//	Second																					
//		If a certain number of characters has been typed than the focus "jumps" to			
//		the next text box. Very usefull when creating data input boxes for fixed 			
//		length strings: phone numbers, zip, Social Security numbers etc.					
//																							
//	The way to invoke this, is by adding to the text box being "protected" something like :	
//		ONKEYUP="javascript:nextBox(this, 'fieldname', 3);"									
//																							
//		This 		= the current field name												
//		fieldname	= the name of the field that the focus will jump to						
//		3 			= the number of characters that will be entered in the current field	
//																							
//				

		function nextBox(CurrentElement, NextElement, MaxSize){
			if(isValid(CurrentElement.value, valid)){
				if(CurrentElement.value.length == MaxSize){
					if(NextElement != 'NONE'){
						eval('document.all.'+NextElement+'.focus()')
					}
				}
			}
			else{
				ClearCharsUntilIntegerIsFound(CurrentElement)
			}
		}

		function ClearLastCharEnteredIfNotNumber(textObject){
			if(!isValid(textObject.value, valid)){
				newText = textObject.value.substring(0, textObject.value.length - 1)
				textObject.value = newText;
			}
		}

		var valid = '0123456789'; // define valid characters

		function isValid(string,allowed) {
		    for (var i=0; i< string.length; i++) {
		       if (allowed.indexOf(string.charAt(i)) == -1)
		          return false;
		    }
		    return true;
		}
		
		function ClearCharsUntilIntegerIsFound(textObject) {
			
			do {
				ClearLastCharEnteredIfNotNumber(textObject)
			}while (!isValid(textObject.value, valid))
			
			
			
		}
				
		
