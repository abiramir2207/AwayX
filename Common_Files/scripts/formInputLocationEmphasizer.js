previousEmphasizedElement = new Object;
eventElement = new Object;
emphasisColor="#ccffff"
previousEmphasizedElementPriorColor = ""

function formInputLocationEmphasizer(){
	if(previousEmphasizedElement.style != null){
		previousEmphasizedElement.style.backgroundColor = previousEmphasizedElementPriorColor //restore the color of the previous select element
	}

	eventElement = event.srcElement
	
	switch(eventElement.tagName) {
		case "INPUT":
			previousEmphasizedElementPriorColor = eventElement.style.backgroundColor	//store original color
			eventElement.style.backgroundColor = emphasisColor	//change current color to emphasis color
			previousEmphasizedElement = eventElement;	//save event object

		break;

		case "TEXTAREA":
			previousEmphasizedElementPriorColor = eventElement.style.backgroundColor	//store original color
			eventElement.style.backgroundColor = emphasisColor	//change current color to emphasis color
			previousEmphasizedElement = eventElement;//save event object
		break;

		case "SELECT":
			window.status=eventElement.tagName
			previousEmphasizedElementPriorColor = eventElement.style.backgroundColor
			eventElement.style.backgroundColor = emphasisColor	//change current color to emphasis color
			previousEmphasizedElement = eventElement;	//save event object	
		break;
	}
}
document.onclick=formInputLocationEmphasizer