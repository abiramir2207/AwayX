package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.GlAccount")]
	/**
	 * GlAccount is a child of Component.
	 * @author msaunders
	 */
	public class GlAccount
	{
		public function GlAccount()
		{
		}
		/*-.........................................Properties..........................................*/
		public var glAccountId : int;
		public var description : String;

	}
}