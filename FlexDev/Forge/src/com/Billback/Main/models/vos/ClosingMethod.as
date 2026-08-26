package com.Billback.Main.models.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.ClosingMethod")]
	/**
	 * @author Milan
	 */
	public class ClosingMethod
	{
		/*-.........................................Properties..........................................*/
		
		public var id : Number = 0;
		public var idList : String = '';
		public var description : String = '';
		public var abbreviation : String = '';
		public var bDefault : Boolean;
		
		public static var DEDUCTION_ID:int = 2;
		public static var DESCRIPTION:String = 'Deduction';
		
		public static var PAYMENT_ID:int = 1;
		public static var PAYMENT_EFT_ID:int = 8;
		public static var WRITEOFF_ID:int = 9;
		public static var REINSTATE_ID:int = 10;
		public static var DEBIT_ID:int = 6;
		public static var CREDIT_ID:int = 4;
		
		public static var CLOSING_METHOD_ORDER:Array = [1,8,2,10,9,5,6,4,7];
		/* Closing method list for Operator Payee */
		public static var CLOSING_METHOD_ORDER_OPERATOR:Array = [1,8,4,7,5,6]; // Dev Note: KAL; 31075; operator doesnt need re-instate
		/*-.........................................Constructor..........................................*/
		
		public function ClosingMethod(cm:ClosingMethod = null){
			
			if( cm ) copy( cm );
		}
		
		/*-.........................................Methods..........................................*/
		public function copy(cm:ClosingMethod):void
		{
			this.id = cm.id;
			this.idList = cm.idList;
			this.description = cm.description;
			this.abbreviation = cm.abbreviation;
			this.bDefault = cm.bDefault;
			
		}
		
	}
}

