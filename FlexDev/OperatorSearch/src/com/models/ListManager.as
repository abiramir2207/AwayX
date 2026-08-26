package com.models
{
	import com.events.*;
	import com.models.SettingsManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	public class ListManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _userOperatorList:Array;
		private var _settingsMan:SettingsManager;
		
		/*-.........................................Setters and Getters..........................................*/
		
		/**
		 * Gets user's operator lists. To call this function dispatch the userOperatorListChanged event.   
		*/
		[Bindable (event="userOperatorListChanged")]
		public function get userOperatorList():Array
		{
			return _userOperatorList;
		}

		/*-.........................................Methods..........................................*/
		public function userOperatorListResults(a:Array):void
		{	
			_userOperatorList = a as Array;
			dispatchEvent(new Event('userOperatorListChanged'));
		}
		public function saveOperatorListResults(a:Array):void
		{
			_userOperatorList = a;
			dispatchEvent(new Event('userOperatorListChanged'));
		}
		public function deleteOperatorListResults(a:Array):void
		{
			Alert.show(ObjectUtil.toString(a));
			Alert.show(ObjectUtil.toString(this._settingsMan));
		}

	}
}