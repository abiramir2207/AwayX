	var errorcount = 0
	//highlight the fields that dont have data
	function checkRequiredFields() {
		errorcount = 0
		for(var i = 0; i<document.all.MyForm.elements.length; i++){
			f = document.all.MyForm.elements[i]
			if(f.required != null){
				if(f.value.length == 0) {
					f.style.backgroundColor = "yellow";
					errorcount++;
				}
				else {
					f.style.backgroundColor = "white";
				}
			}
		}
		
		if(errorcount > 0) {
			alert("Please Enter Data in all the yellow fields")
			return false
		}
		else {
			return true
		}		
	}
	