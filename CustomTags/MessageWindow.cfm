<script>
	//Holds Messages
	var messageQueue    = new Array()
	   ,objectQueue     = new Array()
	   ,clearErrorQueue = new Array()
	   ,winSizeQueue    = new Array()
	   ,objectToPass    = new Array();     // chromefix

	queueMessage=function(MessageText, oHTMLObject, WinSize){
		messageQueue[messageQueue.length] = MessageText;
		if(oHTMLObject != null) {
			objectQueue[objectQueue.length] = oHTMLObject;
		}
		else {
			objectQueue[objectQueue.length] = false;
		}

		if(WinSize != 'undefined' && WinSize != null) {
			winSizeQueue[winSizeQueue.length] = WinSize+'px';
		}
		else {
			winSizeQueue[winSizeQueue.length] = '500px';
		}
	}

	clearQueue=function(oSpanObject){
		if(oSpanObject != null){
			clearErrorQueue[clearErrorQueue.length] = oSpanObject;
		}
		else {
			clearErrorQueue[clearErrorQueue.length] = false;
		}
	}


	clearMessageQueue=function(){
		messageQueue.length = 0;
	}
	clearObjectQueue=function(){
		objectQueue.length = 0;
	}
	clearClearQueue=function(){
		clearErrorQueue.length = 0;
	}

	showMessageWindow=function() {
		objectToPass[0] = messageQueue.slice();        // chromefix - copy by value to avoid loosing value by clearing functions at the end
		objectToPass[1] = objectQueue.slice();         // chromefix
		objectToPass[2] = clearErrorQueue.slice();     // chromefix
		objectToPass[3] = winSizeQueue.slice();        // chromefix

		var winArg = "dialogHeight: 500px; dialogWidth:" + objectToPass[3] +"; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;"
		window.showModalDialog("/common_files/messagewindow/messagewindowgenerator.cfm",objectToPass,winArg);

		clearMessageQueue();
		clearObjectQueue();
		clearClearQueue();
	}
</script>
