package com.Admin.model
{
	import mx.collections.ArrayCollection;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.shared.vos.GridData;
	
	public class AdminManager extends EventDispatcher 
	{
		public function AdminManager()
		{
		}
		private var _adminData:ArrayCollection= new ArrayCollection();
		/*-.........................................Methods..........................................*/

		/* some method*/ 
		public function storeData(arr:Array):void 
			{
				/* loop over arr and cast records as a GridData() object */
				if( arr is Array )
	    		{
		    		for each(var gd:GridData in arr){  }
					/*set the public var*/
					this._adminData = new ArrayCollection(arr);
			    }
				dispatchEvent(new Event('usersChange'));
			
			}
			
		//.................selectedUser......................
		private var _selectedUser:*;
		[Bindable(Event="selectedUserChange")]
		public function get selectedUser():*
		{
			return "MARK";//_selectedUser;
		}
		
		//.................users......................
		private var _users:ArrayCollection;
		[Bindable(Event="usersChange")]
		public function get users():ArrayCollection
		{
			return _adminData;//_users;
		}

	}
}