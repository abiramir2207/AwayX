package com.Billback.Search.models
{
	//import com.events.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	//import com.Billback.Search.vos.BBFilterParams;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	/**
	  * This handles the user favorite programs.
	*/
	public class ListManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _userItemList:Array;
		
		/*-.........................................Setters and Getters..........................................*/
		/**
		  * Call this event to get a list of favorite billbacks for a user.
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
	}// Class End
}//Package End