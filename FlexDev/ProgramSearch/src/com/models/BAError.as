package com.models
{
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import flash.external.*;
	/**
	  * This handles the error related logic
	*/
	public class BAError
	{
		/*-.........................................Properties..........................................*/
		private var _BAError:String = "";
		
		public function BAError():void
		{
		}
		/*-.........................................Setters and Getters..........................................*/
		
		public function get BAErrorString():String
		{
			return _BAError;
		}
		public function set BAErrorString(error:String):void
		{
			_BAError = error;
		}
		public function showBAError(event:Object):void//event:Object
		{
			/* Milan (24104) - When the CF session has expired, we send 'SessionExpired'
			in the detail argument of cfthrow. This will trigger the 
			"RedirectToSessionExpiredPage" function on the "ProgramSearchFx.cfm" which will
			redirect the user to the session expiry page.			
			*/
			if(event.faultDetail == 'SessionExpired')
			{
				 	var s:String;
	        			if (ExternalInterface.available) {
	           			var wrapperFunction:String = "RedirectToSessionExpiredPage";
	           			s = ExternalInterface.call(wrapperFunction);
	        			} 			
	        			else 
	        			{
	        			/* Instead of saying "External Interface" not available, I just
	        			   added this message.
	        			*/
	           			s = "Session has Expired";
	        			}        
			}
			else
			{
				Alert.show( ObjectUtil.toString("Application Error: " + _BAError + "  ::  " + event.faultString + "  ::  " + event.faultDetail));//+ event.result	+ event.toString()
			}
		}

	}
}