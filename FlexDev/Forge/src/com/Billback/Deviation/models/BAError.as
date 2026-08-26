/**
 * Error 
 */
package com.Billback.Deviation.models
{
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	/**
	* This class alerts any error message that was captured.
	*/  
	public class BAError
	{
		/*-.........................................Properties..........................................*/
		private var _BAError:String = "";
		
		public function BAError():void
		{
		}
		/*-.........................................Setters and Getters..........................................*/
		
		/**
		 * This function gets the error message that occured. 
		 */
		public function get BAErrorString():String
		{
			return _BAError;
		}
		
		/**
		 * This function set the error message.
		 */ 
		public function set BAErrorString(error:String):void
		{
			_BAError = error;
		}
		
		/**
		 * This function will show the error message in an Alert box.
		 */
		public function showBAError(event:Object):void//event:Object
		{
			Alert.show( ObjectUtil.toString("Application Error: " + _BAError + "  ::  " + event.faultString + "  ::  " + event.faultDetail));//+ event.result	+ event.toString()
		}
	}
}