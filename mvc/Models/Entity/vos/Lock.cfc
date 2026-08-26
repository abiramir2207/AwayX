component output="false" alias="mvc.Models.Entity.vos.Lock"
{
	property name="objId" type="string" default="";
	property name="userId" type="string" default="";
	property name="objIdLocked" type="string" default="";
	property name="userLocked" type="mvc.Models.Entity.vos.User";
	property name="bLocked" type="boolean";
	property name="lockDate" type="date";
	property name="objIdLockedDesc" type="string" default="";
	property name="toggleLock" type="boolean";
	property name="unlockExistingLockedByUser" type="boolean";

	
	// initialize
	this.objId = "";
	this.userId = "";
	this.objIdLocked = "";
	this.userLocked = CreateObject("component","mvc.Models.Entity.vos.User").init();
	this.bLocked = 0;
	this.lockDate = now();
	this.objIdLockedDesc = "";
	this.toggleLock = 0;
	this.unlockExistingLockedByUser = 0;
	
	// init function
	
	public function init(objId="", userId="", objIdLocked="", userLocked="",bLocked = 0,lockDate = '', objIdLockedDesc = '', toggleLock = 0, unlockExistingLockedByUser = 0) output="false" returntype="mvc.Models.Entity.vos.Lock"
	{
		this.objId = arguments.objId;
		this.userId = arguments.userId;
		this.objIdLocked = arguments.objIdLocked;
		this.userLocked = arguments.userLocked;
		this.bLocked = bLocked;
		this.lockDate = lockDate;
		this.objIdLockedDesc = objIdLockedDesc;
		this.toggleLock = toggleLock;
		this.unlockExistingLockedByUser = unlockExistingLockedByUser;
		return this;
	}
	
}