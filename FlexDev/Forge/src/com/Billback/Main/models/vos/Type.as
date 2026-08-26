package com.Billback.Main.models.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.Type")]
	/**
	 * @author Milan
	 */
	public class Type
	{
		/*-.........................................Properties..........................................*/
		public var id : Number 			= 0;
		public var description : String 	= '';

		/*-.........................................Constructor..........................................*/
		public function Type(type:Type = null)
		{
			if( type ) copy( type );
			
		}
		
		/*-.........................................Methods..........................................*/
		public function copy(type:Type):void
		{
			this.id 			= type.id;
			this.description 	= type.description
		}

	}
}