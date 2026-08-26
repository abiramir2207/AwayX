package com.shared.models.entity.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.Customer")]
	public class Customer extends EventDispatcher
	{   
        public var shipTo:String = '';
        public var name:String = '';
        public var address:Address;
		public var aliasShipTo:String = '';
		public var aliasName:String = '';
		public var aliasAddress:Address;
		public var aliasRecordId:int;
        public var customerId:String; //db id
        
		/*-.........................................Constructor..........................................*/
        public function Customer(c:Customer = null)
		{
			if( c ) copy( c );
		}
	
		/*-.........................................Methods..........................................*/
		public function copy( c:Customer ):void
		{
			this.shipTo = c.shipTo;
			this.name = c.name;
			this.address = new Address(c.address);
			this.aliasShipTo = c.name;
			this.aliasName =  c.aliasName;
			this.aliasAddress = new Address(c.aliasAddress);
			this.aliasRecordId = c.aliasRecordId;
			this.customerId = c.customerId;
		}
	}
}
