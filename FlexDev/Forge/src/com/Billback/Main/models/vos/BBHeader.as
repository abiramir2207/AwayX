package com.Billback.Main.models.vos
{
	import com.shared.models.entity.vos.BillTo;
	import com.shared.models.entity.vos.User;
	
	import flash.events.EventDispatcher;
	
	/**
	 * @author Milan
	 */
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBHeader")]
	public class BBHeader extends EventDispatcher		
	{
		/*-.........................................Properties..........................................*/
		public var isSelected : Boolean;	
		public var billbackIDInt :int 			= 0;
		public var billbackIDGUID :String		= '';
		public var BBCode : String				= '';
		public var BBNumber : String			= '';
		public var referenceNumber : String	= '';
		public var UploadedBillback: Number		= 0;
		public var searchableBBCode:String		= '';
		public var title : String				= '';
		public var amount: Number				= 0;
		public var approvedAmount: Number		= 0;
		public var finalSelectedAmount: Number	= 0;
		public var expectedAmt: Number			= 0;
		public var createdDate: Date;
		public var requestApprovalDate: Date;
		public var BBDate:Date;
		public var BBReceivedDate:Date;
		public var startDate: Date;
		public var endDate: Date;
		public var approvedDate: Date;
		public var paidDate: Date;
		public var documentAttached: Boolean;
		public var checkNumber: String			= '';
		public var documentNumber1: String		='';
		public var documentNumber2: String		='';
		public var status: Status = new Status();
		public var closingMethod:ClosingMethod;
		public var BBtype: Type;
		public var analyst: User;
		public var creator:User;
		public var requestApproval:User;
		public var disagree: User;
		public var reset: User;
		public var approved: User;
		public var payee: Payee;
		public var vendor: Payee;
		public var resetAllowed:Boolean;
		public var deleteAllowed:Boolean;
		public var releaseAllowed:Boolean;
		public var holdAllowed:Boolean;
		public var massApproveAllowed:Boolean;
		public var deviationAllowed:Boolean;
		public var locked:Boolean;
		public var lockedByOther:Boolean = false;
		public var lockedBy:String				= '';
		//public var documentList:Array;
		public var details:BBDetails;
		public var deviated:Boolean;
		public var bbSettlement:BBSettlement = new BBSettlement();
		public var checkDate: Date;
		public var checkAmount: Number = 0;
		public var reassignAllowed:Boolean;
		public var billTo:BillTo;
		public var copyAction:Boolean = false;
		public var notAcknowledged:Boolean = false;
		public var bDisplaySettlement:Boolean = false;
		public var strDefaultProgram:String = '';
		public var UploadID: Number = 0;
		public var BBUploadDupGroupID: Number = 0;
		public var strErrorMessage:String = '';
		
		/*-.........................................Constructor..........................................*/
		public function BBHeader( bbh:BBHeader = null)
		{
			if( bbh ) copy( bbh );
		}
		/*-.........................................Methods..........................................*/
		public function copy(bbh:BBHeader):void
		{
			this.isSelected = bbh.isSelected;   
			this.billbackIDInt = bbh.billbackIDInt;
			this.billbackIDGUID = bbh.billbackIDGUID,
				this.BBCode = bbh.BBCode;     
			this.BBNumber = bbh.BBNumber; 
			this.referenceNumber = bbh.referenceNumber;
			this.UploadedBillback = bbh.UploadedBillback;
			this.searchableBBCode = bbh.searchableBBCode;      
			this.title = bbh.title;       
			this.amount = bbh.amount;     
			this.approvedAmount = bbh.approvedAmount;
			this.finalSelectedAmount = bbh.finalSelectedAmount;
			this.expectedAmt = bbh.expectedAmt;
			this.createdDate = bbh.createdDate;
			this.requestApprovalDate = bbh.requestApprovalDate;
			this.BBDate = bbh.BBDate;    
			this.BBReceivedDate = bbh.BBReceivedDate;
			this.startDate = bbh.startDate;    
			this.endDate = bbh.endDate;   
			this.approvedDate = bbh.approvedDate;  
			this.paidDate = bbh.paidDate;
			this.documentAttached = bbh.documentAttached;      
			this.checkNumber = bbh.checkNumber;
			this.checkDate = bbh.checkDate;
			this.checkAmount = bbh.checkAmount;
			this.documentNumber1 = bbh.documentNumber1;
			this.documentNumber2 = bbh.documentNumber2;
			this.status = new Status(bbh.status);     
			this.closingMethod = new ClosingMethod(bbh.closingMethod);
			this.BBtype = new Type(bbh.BBtype);     
			this.analyst = new User(bbh.analyst);   
			this.creator = new User(bbh.creator);   
			this.requestApproval = new User(bbh.requestApproval);        
			this.disagree = new User(bbh.disagree); 
			this.reset = new User(bbh.reset);       
			this.approved = new User(bbh.approved); 
			this.payee = new Payee(bbh.payee);       
			this.vendor = new Payee(bbh.vendor);     
			this.resetAllowed = bbh.resetAllowed;  
			this.deleteAllowed = bbh.deleteAllowed;
			this.releaseAllowed = bbh.releaseAllowed;
			this.holdAllowed = bbh.holdAllowed;
			this.massApproveAllowed = bbh.massApproveAllowed;
			this.deviationAllowed = bbh.deviationAllowed;      
			this.locked = bbh.locked,     
				this.lockedByOther = bbh.lockedByOther;
			this.lockedBy = bbh.lockedBy; 
			//this.documentList = bbh.documentList;
			this.details = new BBDetails(bbh.details);   
			this.deviated = bbh.deviated; 
			this.bbSettlement = new BBSettlement(bbh.bbSettlement);
			this.reassignAllowed = bbh.reassignAllowed;
			this.billTo = bbh.billTo;
			this.copyAction = bbh.copyAction;
			this.notAcknowledged = bbh.notAcknowledged;
			this.bDisplaySettlement = bbh.bDisplaySettlement;
			this.strDefaultProgram = bbh.strDefaultProgram;
			this.UploadID = bbh.UploadID;
			this.BBUploadDupGroupID = bbh.BBUploadDupGroupID;
			this.strErrorMessage = bbh.strErrorMessage;
		}
		
	}
}		