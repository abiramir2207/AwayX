package com.Admin.Alias.models.vos
{

	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.Alias.vos.AliasDef")]
	/* I added the word "dynamic" so that the delete icon (first column) can be added without adding the delete property in the vos */
	public dynamic class AliasDef extends EventDispatcher
	{
/*-.........................................Properties..........................................*/
		public var isSelected:Boolean;
		public var entityType:int; /* distributors OR Items OR Programs */
		public var sourceType:int; /* EDI OR other entities like Vendor etc */
		public var sourceTypeDesc:String; /* SYSCO EDI OR USFS EDI OR CBS 3rd Party etc */
		public var sourceID:String; /* Hardcoded for EDI ID but dynamic for entities like Vendor etc */
		public var payeeID:String; /* currently, this is the vendor ID */
		public var recordID:int; /* Incremental Integer - Unique ID */
		public var aliasID : String;
		public var aliasDesc : String;
		public var aliasAddress : String;
		public var aliasRegion : String;
		public var aliasCity : String;
		public var aliasState : String;
		public var aliasZIP : String;
		public var aliasUniproNum : String;	
		public var aliasLoc : String;
		public var entityID : String;//bsa id
		public var entityDesc : String;//bsa desc
		public var entityAddress : String;
		public var bsaId : String;
		public var isAssigned:Boolean;
		public var holdInvoiceCount:int;		
		public var sourceRecordID:String;/* the id in the edi file that generated the Unassirned Alias Record */
		public var Unknown:Boolean;		
		/*-.........................................Constructor..........................................*/
		public function AliasDef( 
									isSelected :Boolean = false,
									entityType : int = 0,
									sourceType : int = 0,
									sourceTypeDesc : String = '',
									sourceID : String = '',
									payeeID : String = '',
									recordID : int = 0,
									aliasID : String = '',
									aliasDesc : String = '',
									aliasAddress : String = '',
									aliasRegion : String = '',
									aliasCity : String = '',
									aliasState : String = '',
									aliasZIP : String = '',
									aliasUniproNum : String = '',
									aliasLoc : String = '',
									entityID : String = '',
									entityDesc:String = '',
									entityAddress:String = '',
									bsaId:String = '',
									isAssigned :Boolean = false,
									holdInvoiceCount : int = 0,
									sourceRecordID:String = '',
									Unknown : Boolean = false
					 )
		{
			this.isSelected = isSelected;
			this.entityType = entityType;
			this.sourceType = sourceType;
			this.sourceTypeDesc = sourceTypeDesc;
			this.sourceID = sourceID;
			this.payeeID = payeeID;
			this.recordID = recordID;
			this.aliasID = aliasID;
			this.aliasDesc = aliasDesc;
			this.aliasAddress = aliasAddress;
			this.aliasRegion = aliasRegion;
			this.aliasCity = aliasCity;
			this.aliasState = aliasState;
			this.aliasZIP = aliasZIP;
			this.aliasUniproNum = aliasUniproNum;
			this.aliasLoc = aliasLoc;
			this.entityID = entityID;
			this.entityDesc = entityDesc;
			this.entityAddress = entityAddress;
			this.bsaId = bsaId;
			this.isAssigned = isAssigned;
			this.holdInvoiceCount = holdInvoiceCount;			
			this.sourceRecordID = sourceRecordID;
			this.Unknown = Unknown;
		}

	}
}
