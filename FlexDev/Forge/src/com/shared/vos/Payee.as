package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.Payee")]
	/**
	 * Payee is a child of Component.
	 * @author msaunders
	 */
	public dynamic class Payee
	{
		/*-.........................................Properties..........................................*/
		public var payeeTypeId : int;
		public var name : String;
		public var payeeId : String;
		public var address : String;
		/*-.........................................Constructor..........................................*/
		public function Payee( 	payeeTypeId : int = 0,
								name : String = '',
								payeeId : String = '',
								address : String = ''
							)
		{
			this.payeeTypeId = payeeTypeId;
			this.name = name;
			this.payeeId = payeeId;
			this.address = address;
		}

	}
}