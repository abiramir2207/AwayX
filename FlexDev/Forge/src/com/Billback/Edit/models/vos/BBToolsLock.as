package com.Billback.Edit.models.vos
{
	
	import flash.events.EventDispatcher;
	[Bindable]
	//[RemoteClass(alias="mvc.Models.Billback.vos.BBToolsLock")]
	public class BBToolsLock extends EventDispatcher
	{  		
		/* The billback create/edit screen should enabled by default */
		public var bEditScreenEnabled:Boolean = true;						
		public var bSettlementScreenEnabled:Boolean = false;
		public var bAdjustEnabled:Boolean = false;
		public var bReverseEnabled:Boolean = false;
		public var bResetEnabled:Boolean = false;
		public var bReassignEnabled:Boolean = false;
		public var bDeleteEnabled:Boolean = false;
		public var bBusinessConsiderationsEnabled:Boolean = false;
		public var bSummaryReport:Boolean = false;
		public var bBBUploadEditScreenEnabled:Boolean = false;
		public var bDeviationEnabled:Boolean = false;
		public var bReinterfaceEnabled:Boolean = false;
		public var bEditScreenDateSaveEnabled:Boolean = true;
		
		public function BBToolsLock(bEditScreenEnabled:Boolean = true,
									bSettlementScreenEnabled:Boolean = false,
									bAdjustEnabled:Boolean = false,
									bReverseEnabled:Boolean = false,
									bResetEnabled:Boolean = false,
									bReassignEnabled:Boolean = false,
									bDeleteEnabled:Boolean = false,
									bBusinessConsiderationsEnabled:Boolean = false,
									bSummaryReport:Boolean = false,
									bBBUploadEditScreenEnabled:Boolean = false,
									bDeviationEnabled:Boolean = false,
									bReinterfaceEnabled:Boolean = false,
									bEditScreenDateSaveEnabled:Boolean = true){
			
			this.bEditScreenEnabled = bEditScreenEnabled;
			this.bSettlementScreenEnabled 	= bSettlementScreenEnabled;
			this.bAdjustEnabled = bAdjustEnabled;
			this.bReverseEnabled = bReverseEnabled;
			this.bResetEnabled = bResetEnabled;
			this.bReassignEnabled = bReassignEnabled;
			this.bDeleteEnabled = bDeleteEnabled;
			this.bBusinessConsiderationsEnabled = bBusinessConsiderationsEnabled;
			this.bSummaryReport = bSummaryReport;
			this.bBBUploadEditScreenEnabled = bBBUploadEditScreenEnabled;
			this.bDeviationEnabled = bDeviationEnabled;
			this.bReinterfaceEnabled = bReinterfaceEnabled;
			this.bEditScreenDateSaveEnabled = bEditScreenDateSaveEnabled;
		}    
	}
}