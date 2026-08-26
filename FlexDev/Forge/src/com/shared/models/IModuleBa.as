package com.shared.models
{
	import com.shared.vos.Settings;
	
	import flash.events.IEventDispatcher;
	
	public interface IModuleBa extends IEventDispatcher
	{
		//function setUserId(uid:String):void;
		function setSettings(settings:Settings):void;
	}
}