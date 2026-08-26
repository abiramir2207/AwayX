<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Message Window</TITLE>
	<SCRIPT>
		var internalMessageQueue = new Array();
		var internalObjectQueue = new Array();
		var internalClearQueue = new Array();

		initPage=function(){
			if (window.dialogArguments) {                                // chromefix
				internalMessageQueue = window.dialogArguments[0];
				internalObjectQueue  = window.dialogArguments[1];
				internalClearQueue   = window.dialogArguments[2];
			}
			else {
				internalMessageQueue = window.opener.showModalDialog_arg2[0];   // chromefix
				internalObjectQueue  = window.opener.showModalDialog_arg2[1];
				internalClearQueue   = window.opener.showModalDialog_arg2[2];
			}
			clearErrorFlagsFromPage();
		}


		<!--- clear the prior error flags from the parent form --->
		function clearErrorFlagsFromPage(){
			for(var x=0; x<internalClearQueue.length;x++){
				tempErrorObject = internalClearQueue[x];

				if(tempErrorObject != false){
					tempErrorObject.style.width = 0;
					tempErrorObject.innerHTML = "";
					tempErrorObject.style.backgroundImage = "";
				}
			}

			buildMessageTable(internalMessageQueue);
		}

		buildMessageTable=function(arrayOfMessages){
			if(arrayOfMessages.length == 0){


			}
			else {
				for(var x=0;x<arrayOfMessages.length;x++){
					tempRow = document.all.oMessageTable.insertRow();

					rowMod = x/2 + ""
					if(rowMod.indexOf(".") == -1){
						bgColor = "ffffff"
					}
					else{
						bgColor = "ccffcc"
					}

					tempRow.style.backgroundColor = bgColor

					iconCell = tempRow.insertCell();
					iconCell.className = "eventRow"
					iconCell.style.width = 21;
					iconCell.style.height = 21;
					iconCell.style.backgroundImage = "url(/images/alert_icon.gif)"
					iconCell.innerHTML = "<div align='center' style='color: Yellow; font-weight: bolder; font-size: 12px; ;'>" + (x+1) + "</div>"

					MessageTextCell = tempRow.insertCell()
					MessageTextCell.className = "eventRow"

					MessageTextCell.innerHTML = "&nbsp;&nbsp;" + arrayOfMessages[x]
					tempObject = internalObjectQueue[x]
					if(tempObject != false){
						tempObject.style.backgroundImage = "url(/images/alert_icon_small.gif)"
						alertMessage = escape(arrayOfMessages[x]);
						tempObject.innerHTML = "<div onclick=alert(unescape('" + alertMessage + "')) align='center' style='color: Yellow; font-weight: bolder; font-size: 15px; cursor:help;'>" + (x+1) + "</div>"
						tempObject.style.width = "20px"
						tempObject.style.height = "20px"
						tempObject.style.display = "inline-block"
						tempObject.style.cursor = "help"
					}
				}
			}
		}
	</SCRIPT>
	<style>
		.eventRow {
			border-bottom: solid #93BEE2 1px; font-size : 10px;
		}
	</style>
</HEAD>
<BODY onload="initPage()">
<FIELDSET STYLE="padding:2%; width:93%; border:1px solid Silver;margin:1%;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Validation Messages</LEGEND>
	<br>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" id="oMessageTable"></table>
	<br>
</FIELDSET>
</BODY>
</HTML>