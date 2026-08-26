package com.Admin.Redi.models.vos
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	

	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.Redi.vos.RediSettings")]
	public class RediSettings extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var sourceCode : String = '';//DOT, Sysco, Honor
		public var sourceType : int = 0;//
		public var sourceTypeDesc : String = '';//DOT, Sysco, Honor
		public var claimSourceXREFID : int = 0;//
		public var tradePartId:String;
		public var bEnabled : Boolean;
		public var bAliasItem : Boolean;
		public var bAliasDistributor : Boolean;
		public var bAliasOriginalBuyer : Boolean;
		public var sFOBPricInd : String;
		public var iInvoicePrice : int; //1 = raw file; 2= Forge Generated
		public var iInvoiceNumber : int;//1 = raw file; 2= Forge Generated
		//public var aEmailRecipients:Array;
		public var sModifiedUser:String;
		public var dModifiedDate:Date;
		
		public static const RAW_FILE_FLAG : int = 1;
		public static const FORGE_GEN_FLAG :  int = 2;
		public static const INVOICE_OPTIONS_ARRAY : ArrayList = new ArrayList([{id:0,label:''},{id:1,label:'Use raw File Value'},{id:2,label:'Forge Generated'}]);
		public static const FOB_OPTIONS_ARRAY : ArrayList = new ArrayList([{id:'',label:''},{id:'N',label:'N'},{id:'X',label:'X'},{id:'Y',label:'Y'}]);
		
		/*-.........................................Constructor..........................................*/
		public function RediSettings( rediSettings:RediSettings = null )
		{
			if( rediSettings ) copy( rediSettings );
		}
		/*-.........................................Methods..........................................*/
		public function copy( rediSettings:RediSettings ):void
		{
			this.sourceCode 		= rediSettings.sourceCode;
			this.sourceType 		= rediSettings.sourceType;
			this.sourceTypeDesc 	= rediSettings.sourceTypeDesc;
			this.claimSourceXREFID	= rediSettings.claimSourceXREFID;
			this.tradePartId 		= rediSettings.tradePartId;
			this.bEnabled 			= rediSettings.bEnabled;
			this.bAliasItem 		= rediSettings.bAliasItem;
			this.bAliasDistributor 	= rediSettings.bAliasDistributor;
			this.bAliasOriginalBuyer= rediSettings.bAliasOriginalBuyer;
			this.sFOBPricInd		= rediSettings.sFOBPricInd;
			this.iInvoicePrice		= rediSettings.iInvoicePrice;
			this.iInvoiceNumber		= rediSettings.iInvoiceNumber;
			//this.aEmailRecipients	= rediSettings.aEmailRecipients;
			this.sModifiedUser		= rediSettings.sModifiedUser;
			this.dModifiedDate		= rediSettings.dModifiedDate;
			
		}
	}
}
