package com.Billback.Main.models
{
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Main.models.vos.Payee;
	import com.shared.models.IModuleBa;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IUIComponent;
	
	public interface IBBEdit  extends IModuleBa //extends IUIComponent
	{
		//function setUserId(uid:String):void;
		function setBB(bbHeader:BBHeader):void;
		function getBB():BBHeader;
		function setClosingMethods(closingMethodList:Array):void;
		function setBBAnalysts(bbAnalysts:Array):void;
		function setPayeeList(payeeList:Array):void;
		function setSelectedTab(idx:int):void;
	//	function setReDirector(reDirector:String):void;
		
	}
}