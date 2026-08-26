package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.Payee")]
	/**
	 * Payee is a child of Component.
	 * @author msaunders
	 */
	public class Payee
	{
		/*-.........................................Properties..........................................*/
		public var payeeTypeId : int;
		public var name : String;
		public var payeeId : String;
		/*-.........................................Constructor..........................................*/
		public function Payee( 	payeeTypeId : int = 0,
								name : String = '',
								payeeId : String = ''
							)
		{
			this.payeeTypeId = payeeTypeId;
			this.name = name;
			this.payeeId = payeeId;
		}

	}
}