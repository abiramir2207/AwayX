package com.Billback.Main.models.vos
{
	import com.shared.models.entity.vos.Address;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.Payee")]
	/**
	 * @author Milan
	 */
	public class Payee
	{
		/*-.........................................Properties..........................................*/
		public var payeeTypeId : Number = 0;
		public var name : String = '';
		public var payeeId : String = '';
		public var address :Address;
		public var payeeUUId :String = '';
		
		/*-.........................................Constructor..........................................*/
		public function Payee( payee:Payee = null )
		{
			if( payee ) copy( payee );
		}
		/*-.........................................Methods..........................................*/
		public function copy(payee:Payee):void
		{
			this.payeeTypeId = payee.payeeTypeId;
			this.name = payee.name;
			this.payeeId = payee.payeeId;
			this.address= payee.address;
			this.payeeUUId = payee.payeeUUId;
			
		}
	}
}