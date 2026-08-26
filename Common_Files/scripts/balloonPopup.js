function getAttributesWindow(title, debugObject) {
	/* lists all the attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<' + 'SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">\n');
	msgWindow.document.write('function stopError() {return true}\n');
	msgWindow.document.write('window.onerror = stopError;\n');
	msgWindow.document.write('<' + '/SCRIPT>\n');
	msgWindow.document.write('&lt;' + title + '&gt;\n<OL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			var strValueString = '"' + valueString + '"';
			msgWindow.document.write('\t<LI CLASS="OITEM">' + strValueString + ' <b>[' + i + ']</b><OL TYPE="a">\n');
			if(strValueString!='"null"') {
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(typeof(valueString2) == 'string') {
						// var ltRE = new RegExp(String.fromCharCode(60), "g");
						// if(valueString2.match(ltRE)) {valueString2 = valueString2.replace(ltRE, "&lt;");}
						// var gtRE = new RegExp(String.fromCharCode(62), "g");
						// if(valueString2.match(gtRE)) {valueString2 = valueString2.replace(gtRE, "&gt;");}
						// }
					// msgWindow.document.write('\t\t<LI CLASS="OITEM">"' + valueString2 + '" <b>' + i + '.' + j + '</b></LI>\n');
					// }
				}
			msgWindow.document.write('</OL></LI>\n');
			}
		else {
			if(typeof(valueString) == 'string') {
				var ltRE = new RegExp(String.fromCharCode(60), "g");
				if(valueString.match(ltRE)) {valueString = valueString.replace(ltRE, "&lt;");}
				var gtRE = new RegExp(String.fromCharCode(62), "g");
				if(valueString.match(gtRE)) {valueString = valueString.replace(gtRE, "&gt;");}
				}
			msgWindow.document.write('\t<LI CLASS="OITEM">"' + valueString + '" <b>' + i + '</b></LI>\n');
			}
		}
	msgWindow.document.write('</OL>\n');
	}

//<body ONLOAD="buildHelpBalloons(); showAllBalloons();">

balloonString = "<DIV ID='Balloon' STYLE='position:absolute; Z-INDEX:21;visibility: hidden;background-color : transparent;' onclick='popBalloon(this)'>"
balloonString = balloonString + "<TABLE WIDTH=120 BORDER=0 CELLPADDING=0 CELLSPACING=0 STYLE='background-color: transparent;'>";
balloonString = balloonString + "<TR>"
balloonString = balloonString + "<TD width='100%'>"
balloonString = balloonString + "<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 width='200' STYLE='background-color: transparent;'>"
balloonString = balloonString + "<TR>"
balloonString = balloonString + "<TD><IMG ID='leftPoint' SRC='/images/baloon1/images/leftPoint.gif' width=27 height=19></TD>"
balloonString = balloonString + "<TD background='/images/baloon1/images/baloon_02.gif' width='100%'>&nbsp;</TD>"
balloonString = balloonString + "<TD><IMG ID='rightPoint' SRC='/images/baloon1/images/baloon_03.gif' width=26 height=19></TD>"
balloonString = balloonString + "</TR>"
balloonString = balloonString + "</TABLE>"
balloonString = balloonString + "</TD>"
balloonString = balloonString + "</TR>"

balloonString = balloonString + "<TR>"
balloonString = balloonString + "<TD width='100%'>"
balloonString = balloonString + "<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 width='200'>"
balloonString = balloonString + "<TR>"
balloonString = balloonString + "<TD background='/images/baloon1/images/baloon_04.gif'><IMG SRC='/images/baloon1/images/baloon_04.gif' width=6 height=33></TD>"
balloonString = balloonString + "<TD width='100%' background='/images/baloon1/images/baloon_05.gif' ID='balloonText'>"
balloonString = balloonString + "</TD>"
balloonString = balloonString + "<TD background='/images/baloon1/images/baloon_06.gif'><IMG SRC='/images/baloon1/images/baloon_06.gif' width=6 height=33></TD>"
balloonString = balloonString + "</TR>"
balloonString = balloonString + "</TABLE>"
balloonString = balloonString + "</TD>"
balloonString = balloonString + "</TR>"

balloonString = balloonString + "<TR>"
balloonString = balloonString + "<TD width='100%'>"
balloonString = balloonString + "<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 width='200'>"
balloonString = balloonString + "<TR>"
balloonString = balloonString + "<TD><IMG SRC='/images/baloon1/images/baloon_07.gif' WIDTH=6 HEIGHT=6></TD>"
balloonString = balloonString + "<TD background='/images/baloon1/images/baloon_08.gif' width='100%'><IMG border='0' src='/images/baloon1/images/baloon_08.gif' width='108' height='6'></TD>"
balloonString = balloonString + "<TD><IMG SRC='/images/baloon1/images/baloon_09.gif' width=6 height=6></TD>"
balloonString = balloonString + "</TR>"
balloonString = balloonString + "</TABLE>"
balloonString = balloonString + "</TD>"
balloonString = balloonString + "</TR>"
balloonString = balloonString + "</TABLE>"
balloonString = balloonString + "</DIV>"


	//custom object to house the info needed to display the balloon
	function helpBalloon(windowObjectID, balloonText, pixelLeft, pixelTop){
		this.windowObjectID = windowObjectID;
		this.balloonText = balloonText;
		this.pixelLeft = pixelLeft;
		this.pixelTop = pixelTop;
	}


function coor() {
window.status = "X=" + window.event.x + " Y=" +window.event.y;
}
//document.onmousemove = coor


	balloonQueueArray = new Array();
	function queueHelpBalloon(windowObject, balloonText) {
		
		//get x location for the layer based on the object for which it was created
	
		temp = eval("document.all." + windowObject)
				
		newPixelLeft = temp.offsetParent.offsetLeft + temp.offsetLeft + (temp.clientWidth/8);

<!--- 		newPixelTop = temp.offsetParent.offsetParent.offsetTop + temp.offsetParent.offsetTop + temp.offsetTop + (temp.clientHeight/2); --->
		
		newPixelTop = temp.offsetParent.offsetParent.offsetTop + temp.offsetParent.offsetTop + temp.offsetTop + 18;
		
		
		//getAttributesWindow('', temp.offsetParent)
		balloonQueueArray[balloonQueueArray.length]	= new helpBalloon(windowObject, balloonText, newPixelLeft, newPixelTop);
	}

	function buildHelpBalloons() {
		for(var x=0; x<balloonQueueArray.length; x++){
			
			//add layer to the page
			
			document.body.insertAdjacentHTML("afterBegin", balloonString);
			//rename layer to the name of the object for which it was created with "_balloon" appended to it
			document.all.Balloon.id = balloonQueueArray[x].windowObjectID + "_balloon";
			
			
			
			//Add the message text to the layer
			eval("document.all." + balloonQueueArray[x].windowObjectID + "_balloon.all.balloonText.innerHTML = '" + balloonQueueArray[x].balloonText + "'")

			//locate it properly on the screen
			eval("document.all." + balloonQueueArray[x].windowObjectID + "_balloon.style.pixelLeft =" + 
balloonQueueArray[x].pixelLeft)
			eval("document.all." +  balloonQueueArray[x].windowObjectID + "_balloon.style.pixelTop =" + balloonQueueArray[x].pixelTop)
			moveBalloonOnScreen(balloonQueueArray[x].windowObjectID + "_balloon",balloonQueueArray[x].pixelLeft,balloonQueueArray[x].pixelTop)

		}
	}
	
	
	function popBalloon(ballonLayer){
		internal_temp = ballonLayer.id.split("_");
		if(internal_temp[internal_temp.length-1] == "balloon"){
			ballonLayer.style.visibility = 'hidden'
		}
		
	}
	function showAllBalloons(){
		for(var x=0; x<balloonQueueArray.length; x++){
			showBalloon(balloonQueueArray[x].windowObjectID + "_balloon")
		}
	}

	function hideAllBalloons(){
		for(var x=0; x<balloonQueueArray.length; x++){
			hideBalloon(balloonQueueArray[x].windowObjectID + "_balloon")
		}
	}	
	function showBalloon(balloonID){
		eval("document.all." + balloonID + ".style.visibility = 'visible'")
	}
	function hideBalloon(balloonID){
		eval("document.all." + balloonID + ".style.visibility = 'hidden'")
	}
	
	function moveBalloonOnScreen(balloonID, internalX, internalY){
		BalloonLayerID = balloonID;
		//Find out how close the mouse is to the corner of the window
		var rightedge=document.body.clientWidth-internalX
		
		var bottomedge=document.body.clientHeight-internalY


		//if the horizontal distance isn't enough to accomodate the width of the context menu
		if (rightedge<eval(BalloonLayerID + '.offsetWidth')) {
		//move the horizontal position of the menu to the left by it's width
			eval(BalloonLayerID + ".style.left=document.body.scrollLeft+internalX-eval(BalloonLayerID + '.offsetWidth')")
			eval(BalloonLayerID + ".all.leftPoint.src='/images/baloon1/images/baloon_01.gif'")
			eval(BalloonLayerID + ".all.rightPoint.src='/images/baloon1/images/rightPoint.gif'")

		}
		else
		//position the horizontal position of the menu where the mouse was clicked
		eval(BalloonLayerID + '.style.left=document.body.scrollLeft+internalX')
		
		//same concept with the vertical position
		if (bottomedge<eval(BalloonLayerID + '.offsetHeight'))
		eval(BalloonLayerID + ".style.top=document.body.scrollTop+internalY-eval(BalloonLayerID + '.offsetHeight')-document.body.scrollTop")
		else
		eval(BalloonLayerID + '.style.top=document.body.scrollTop+internalY-document.body.scrollTop')		
	}

/*
<script LANGUAGE="JavaScript">
	queueHelpBalloon("LastCell", "More Bad Stuff");
</script>
*/



