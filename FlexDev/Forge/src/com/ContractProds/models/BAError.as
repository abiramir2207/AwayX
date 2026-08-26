package com.ContractProds.models
{
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import flash.events.IEventDispatcher;
	
	public class BAError
	{
		/*-.........................................Properties..........................................*/
		private var _BAError:String = "";
		
		/*-...................................... Constructor.......................................*/
		/* private var dispatcher:IEventDispatcher;
		public function BAError( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		} */
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
			Alert.show( ObjectUtil.toString("Application Error: " + _BAError + "  ::  " + event.faultString + "  ::  " + event.faultDetail));//+ event.result	+ event.toString()
		}

	}
}