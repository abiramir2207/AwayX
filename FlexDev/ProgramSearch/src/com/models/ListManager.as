package com.models
{
	import com.events.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.utils.ObjectUtil;
	/**
	  * This handles the user favorite programs.
	*/
	public class ListManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _userItemList:Array;
		private var _settingsMan:ProgramSettingsManager;
		
		/*-.........................................Setters and Getters..........................................*/
		/**
		  * Call this event to get a list of favorite programs for a user.
		*/
		[Bindable (event="userItemListChanged")]
		public function get userItemList():Array
		{
			return _userItemList;
		}

		/*-.........................................Methods..........................................*/
		public function userItemListResults(a:Array):void
		{
			_userItemList = a as Array;
			dispatchEvent(new Event('userItemListChanged'));
		}
		public function saveItemListResults(a:Array):void
		{
			_userItemList = a;
			dispatchEvent(new Event('userItemListChanged'));
		}
		/*
		public function deleteItemListResults(a:Array):void
		{
			 var event:SearchProgramEvent = new SearchProgramEvent(SearchProgramEvent.GET_USERLIST);		
			
			 this.dispatchEvent(event); 
		}
		*/
	}// Class End
}//Package End