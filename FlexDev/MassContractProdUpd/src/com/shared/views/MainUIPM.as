package com.shared.views
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.controls.Alert;
	
	public class MainUIPM extends EventDispatcher
	{
		//--------------------------------------------------------------------
		//    Public Constants
		//--------------------------------------------------------------------
		public static const ADMIN_STATE:String  = "adminState";
		public static const ITEM_SEARCH_STATE:String = "ItemSearchState";
		
		
		//--------------------------------------------------------------------
		//    Public Setters and Getters
		//--------------------------------------------------------------------
		
		//...........................state......................
		private var _state:String = ADMIN_STATE;
		[Bindable(Event="stateChange")]
		public function get state( ):String
		{
			return _state;
		}
		
		//............................state........................
		public function updState( state:String ):void
		{
			if( state == "ItemSearchState")
			{ _state = ITEM_SEARCH_STATE; }
			else
			{ _state = ADMIN_STATE; }
			//Alert.show("made it: " + state);
			dispatchEvent( new Event( "stateChange" ) );
		}

	}
}