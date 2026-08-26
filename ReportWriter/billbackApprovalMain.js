// JavaScript Document
function sizeWin() {
	var upperPanelSize 	= 350;
	if (!divApprovalForm) return;
	if (!divApprovalForm) return;
	if (!ifApprovalForm) return;
	document.all.divApprovalTable.style.visibility = "hidden";
	document.all.divApprovalForm.style.height = upperPanelSize;
	document.all.ifApprovalForm.style.height = upperPanelSize;
}

function splitWin() {
		if (!divApprovalForm) return;
		if (!divApprovalForm) return;
		if (!ifApprovalForm) return;
		divApprovalForm.style.visibility='visible';
		divApprovalTable.style.height=280;
		divApprovalTable.document.all.ifdivApprovalTable.style.height=270;
	}
	
function showReport() {
	var queryString = "";
	queryString = buildQueryStringFromForm(ifApprovalForm.claimForm);
	ifdivApprovalTable.location.href = "billbackApprovalTable.cfm?"+queryString;
}

function WinHandler() {
	if (!divApprovalForm) return;
	if (!divApprovalForm) return;
	if (!ifApprovalForm) return;
	if (searchString(sizeimg.src) >= 0 ) {
		document.all.divApprovalForm.style.display = 'none';
		document.all.sizeimg.src = "/images/reports/normal.gif";
		resizeDivTableMaximize();
	}
	else {
		document.all.divApprovalForm.style.display = 'block';
		document.all.sizeimg.src = "/images/reports/maximize.gif";
		resizeDivTableNormal();
	}
}
function searchString(string_to_be_searched) {
   var r, re;                   //Declare variables.
   re = /maximize.gif/i;           
   r = string_to_be_searched.search(re);  
   return(r);  
}

function resizeDivTableNormal() {
	divApprovalTable.style.height=280;
	divApprovalTable.document.all.ifdivApprovalTable.style.height=270;
}

function resizeDivTableMaximize() {
	document.all.divApprovalTable.style.height = 540;
	document.all.ifdivApprovalTable.style.height = 540;
}

function buildQueryStringFromForm(theForm) {
	var tempStr = "";
	for (i=0; i < theForm.length; i++) {
		if (theForm.elements(i).name && theForm.elements(i).value )
		tempStr = tempStr + theForm.elements(i).name + "=" + theForm.elements(i).value + "&";
	}
	tempStr = tempStr.substr(0, tempStr.length-1);
	return (tempStr);
}