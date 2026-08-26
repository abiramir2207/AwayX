package com.shared.models.entity.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.Address")]
    public class Address extends EventDispatcher
	{  
          public var addressLine1:String;
          public var addressLine2:String;
          public var city:String;
          public var state:String;
          public var zipCode:String;
		  /*-.........................................Constructor..........................................*/
          public function Address(a:Address = null)
	      {
			  if( a ) copy( a );
		  }
		  /*-.........................................Methods..........................................*/
		  public function copy( a:Address ):void
		  {
			  this.addressLine1 = a.addressLine1;
			  this.addressLine2 = a.addressLine2;
			  this.city = a.city;
			  this.state = a.state;
			  this.zipCode = a.zipCode;
		  }
	}
}
