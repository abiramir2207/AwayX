package com.ItemSearch.models
{
	import com.ItemSearch.events.*;
	import com.ItemSearch.models.SettingsManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	/**
	 * Load and save the array that holds the User Iiem list data.  Some User Item list logic is still in the SearchManager Class
	 ** @author msaunders
	 */	
	public class ListManager extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		
		private var _userItemList:Array;
		private var _settingsMan:SettingsManager;
		
			/*-.........................................Constructor..........................................*/
		private var dispatcher:IEventDispatcher;
		public function ListManager( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		/*-.........................................Setters and Getters..........................................*/
		
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
		public function deleteItemListResults(a:Array):void
		{
			Alert.show(ObjectUtil.toString(a));
			Alert.show(ObjectUtil.toString(this._settingsMan));
			/* delete returned, so reload the list */
			/* var event:SearchEvent = new SearchEvent(SearchEvent.GET_USERLIST);
			event.userId = _settingsMan.settings.UserId;
			this.dispatchEvent(event); */
		}

	}
}