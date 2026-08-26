	import mx.utils.ArrayUtil;
	import mx.controls.Alert;

	//Get TimeStamp
	public function getTimeStamp():String
	{
		var timeStamp:Date = new Date();
		var timeStampString:String = (timeStamp.getMonth() + 1) + "/" + timeStamp.getUTCDate() + "/" + timeStamp.getFullYear() + " ";
		timeStampString += String(timeStamp.getHours()) + ":" + String(timeStamp.getMinutes());
		
		return timeStampString;
	}

	// Alerts
	public function popUp(message:String):void
	{
		Alert.show(message);
	}
    
	//Log Update and Webservice Calls
	public function printApplicationVars():void
	{
		debugWindow.visible = true;
		txtAppSettings.text += "APPLICATION SETTINGS AS OF: " + getTimeStamp() + "\n";
		for (var i:String in Application.application.parameters) {
			txtAppSettings.text += i + ":" + Application.application.parameters[i] + "\n";
			}
		txtAppSettings.text += Application.application.parameters.applicationpath + "\n";
	}