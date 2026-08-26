package com.shared
{
	import mx.core.IUIComponent;

	public interface IModuleInterface extends IUIComponent
	{
		function get programId():int;
		function set programId(value:int):void;
	
		function get customerId():String;
		function set customerId(value:String):void;
		
		function get oneDistSelection():Boolean;
		function set oneDistSelection(value:Boolean):void;
		
		function saveSettings():void;
	}

}