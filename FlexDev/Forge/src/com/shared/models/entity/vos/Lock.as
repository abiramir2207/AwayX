package com.shared.models.entity.vos
{
	import flash.events.EventDispatcher;

	/**
	 * lock & unlock object
	 * @author kal 
	 **/	
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.Lock")]
	public class Lock extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var objId 		: String;	//contract_main_id; billback_id_int
		public var userId 		: String;	// userId locking the object
		public var objIdLocked	: String;	// object locked by the userId above
		public var userLocked	: User = new User();		// user object who is locking the objId above
		public var bLocked		: Boolean;
		public var bEditMode	: Boolean; //It Is locked By Me (and possibly other logic...wip?) so I can Edit it
		public var lockDate	: Date;
		public var objIdLockedDesc	: String;	// a description for the object locked by the userId above
		public var toggleLock	: Boolean;		// when the user changes lock from readonly to edit and vice-versa
		public var unlockExistingLockedByUser : Boolean // unlock existing locked billbacks for a user
		
		
		/*-.........................................Constructor..........................................*/
		public function Lock(l:Lock = null)
		{
			if( l ) copy( l );
		}
		
		/*-.........................................Methods..........................................*/
		public function copy( l:Lock ):void
		{
			this.objId = l.objId;	//contract_main_id; billback_id_int
			this.userId = l.userId;	// userId locking the object
			this.objIdLocked = l.objIdLocked;	// object locked by the userId above
			this.userLocked = l.userLocked;	// user object who is locking the objId above
			this.bLocked = l.bLocked;
			this.bEditMode = l.bEditMode;
			this.lockDate = l.lockDate;
			this.objIdLockedDesc = l.objIdLockedDesc;	// a description for the object locked by the userId above
			this.toggleLock = l.toggleLock;		// when the user changes lock from readonly to edit and vice-versa
			this.unlockExistingLockedByUser = l.unlockExistingLockedByUser;
		}
		
	}
}