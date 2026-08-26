package com.Billback.Edit.models.vos
{
	import com.shared.vos.Payee;
	
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBDeductionFilterParms")]
    public class BBDeductionFilterParms extends EventDispatcher
	{  
		  
		  public var iBillbackId:int 			= 0;												
		  public var bAmount:Boolean			= false;
		  public var bDistributor:Boolean 		= false;
		  public var bBalance:Boolean			= false;
		  public var sKeyword:String 			= "";
		  public var nBalance:Number			= 0;
		  public var strDistributorId:String	= "";

          public function BBDeductionFilterParms(iBillbackId:int = 0,
												 bAmount:Boolean = false,
												 bDistributor:Boolean 	= false,
												 bBalance:Boolean		= false,
												 sKeyword:String 		= "",
												 nBalance:Number		= 0,
												 strDistributorId:String = ""){
			  this.iBillbackId = iBillbackId;
			  this.bAmount		= bAmount;
			  this.bDistributor = bDistributor;
			  this.bBalance = bBalance;
			  this.sKeyword = sKeyword;
			  this.nBalance = nBalance;
			  this.strDistributorId = strDistributorId;
		  }    
	}
}
