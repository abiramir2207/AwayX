function formattotwodecimals(textObject)	{
	var inputText = textObject.value;
	if(inputText.length != 0){
		//look for an existing decimal
		if(inputText.indexOf(".") != -1) {
			textAfterDecimal = inputText.substring(inputText.indexOf(".")+1, inputText.length)
			switch(textAfterDecimal.length){
				case 0:
					textObject.value = textObject.value + "00"
				break;

				case 1:
					textObject.value = textObject.value + "0"
				break;

				default:
				break;
			
			}
		}
		else {
			textObject.value = inputText + ".00";
		}
	}
}

function TwoDecimalsOnBlur(oObject){
		if(trim(oObject.value).length > 0){
			if(parseFloat(oObject.value) != 0) {
				var nf = new NumberFormat();
				nf.setNumber(oObject.value);
				nf.setCommas(false);
				nf.setCurrency(false);
				nf.setPlaces(2);
				oObject.value = nf.toFormatted();
			}
			else {
				oObject.value = "0.00";
			}				
		}
	}