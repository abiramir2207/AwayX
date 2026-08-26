package com.shared.models.entity.vos
{
	import flash.events.EventDispatcher;

	/*<cfproperty name="id" type="strin" default="0">
		<cfproperty name="idInt" type="string" default="">
		<cfproperty name="fullName" type="string" default="">*/
	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.User")]
	/**
	 * GlAccount is a child of Component.
	 * @author msaunders
	 */
	public class User extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var id : String;
		public var idInt :Number;
		public var fullName : String = '';
		/*-.........................................Constructor..........................................*/
		public function User( user:User = null )
		{
			if( user ) copy( user );
		}
		/*-.........................................Methods..........................................*/
		public function copy( user:User ):void
		{
			this.id = user.id;
			this.idInt = user.idInt;
			this.fullName = user.fullName;
		}
		
	}
}