package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.Uom")]
	/**
	 * Uom details
	 * @author msaunders
	 */
	public class Uom
	{
		/*-.........................................Properties..........................................*/
		public var uomId : int;
		public var description : String;
		public var abbreviation : String = '';
		public var bDefault : Boolean;
		/*-.........................................Constructor..........................................*/
		public function Uom( uom:Uom = null )
		{
			if( uom ) copy( uom );
		}
		/*-.........................................Methods..........................................*/
		public function copy( uom:Uom ):void
		{
			uomId = uom.uomId;
			description  = uom.description;
			abbreviation  = uom.abbreviation;
			bDefault = uom.bDefault;
		}
		

	}
}