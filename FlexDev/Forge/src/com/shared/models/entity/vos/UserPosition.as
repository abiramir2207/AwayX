package com.shared.models.entity.vos
{
	import flash.events.EventDispatcher;

	[RemoteClass(alias="mvc.Models.Entity.vos.UserPosition")]
    public class UserPosition extends EventDispatcher
	{  
		/*-.........................................Properties..........................................*/
          public var userPositionsId:int;
          public var positionLabel:String;

		  /*-.........................................Constructor..........................................*/
		  public function UserPosition(userPosition:UserPosition = null)
		  {
			  if( userPosition ) copy( userPosition );
		  }
		  /*-.........................................Methods..........................................*/
		  public function copy( userPosition:UserPosition ):void
		  {
			  this.userPositionsId = userPosition.userPositionsId;
			  this.positionLabel = userPosition.positionLabel;
			  
		  }
	}
}
