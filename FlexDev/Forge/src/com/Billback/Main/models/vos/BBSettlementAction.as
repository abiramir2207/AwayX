package com.Billback.Main.models.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBSettlementAction")]
    public class BBSettlementAction extends EventDispatcher
	{  
          public var balance:int;
          public var action:String;

          public function BBSettlementAction(balance:int = 0,
											 action:String = ''){
			  this.balance = balance;
			  this.action = action;			  
		  }    
	}
}
