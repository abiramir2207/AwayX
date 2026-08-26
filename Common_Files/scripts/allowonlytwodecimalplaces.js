function allowonlytwodecimalplaces(textObject,bAllowNeg)	{
	if(!variableDefined(bAllowNeg)){
		bAllowNeg = true;
	}
	
	var inputText = textObject.value;
	//alert(inputText);
	//strip out non-numeric
	while((!isNumber(inputText)) && inputText.length > 0 && (bAllowNeg == false || inputText != '-')){
		inputText = inputText.substr(0,inputText.length - 1);
		//alert(inputText);
	}	
	
	textObject.value = inputText;
	//check decimals
	if (inputText == ".")
	{
		textObject.value = "0.00";
		return true;
	}
	if(inputText.length != 0){
		//look for an existing decimal
		if(inputText.indexOf(".") != -1) {
			textAfterDecimal = inputText.substring(inputText.indexOf(".")+1, inputText.length)
			if(textAfterDecimal.length > 2){
				textObject.value = inputText.substring(0, inputText.indexOf(".")+3)
			}
		}
	}
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function variableDefined (name) {
	
    return typeof name !== 'undefined';
}