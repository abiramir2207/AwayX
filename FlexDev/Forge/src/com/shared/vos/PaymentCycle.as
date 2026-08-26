package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.PaymentCycle")]
	/**
	 * PaymentCycle is a child of Component.
	 * @author msaunders
	 */
	public class PaymentCycle
	{
		/*-.........................................Properties..........................................*/
		public var paymentCycleId : int;
		public var description : String;
		public var bDefault:Boolean;

	}
}