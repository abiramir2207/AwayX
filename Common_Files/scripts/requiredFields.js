	var errorcount = 0
	//highlight the fields that dont have data
	function checkRequiredFields() {
		errorcount = 0
		for(var i = 0; i<document.all.MyForm.elements.length; i++){
			f = document.all.MyForm.elements[i]
			if(f.required != null){
				if(f.value.length == 0) {
					f.style.backgroundColor = "khaki";
					errorcount++;
				}
				else {
					f.style.backgroundColor = "white";
				}
			}
		}
		

		if(window.addUnauthorizedProductsFlag || window.addUnknownProductFlag){
			if(window.addUnauthorizedProductsFlag){
				window.addUnauthorizedProductsFlag = false;
			}

			if(window.addUnknownProductFlag){
				window.addUnknownProductFlag = false;
			}
			if(errorcount > 0) {
				alert("Please Enter Data in all the highlighted fields before adding another product")
				return false
			}

			return true
		}
		else{
			if(errorcount > 0) {
				alert("Please Enter Data in all the highlighted fields")
				return false
			}
			else {
				return true
			}		
		}
	}
	