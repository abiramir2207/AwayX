package com.Billback.Edit.events
{
	import com.Billback.Edit.models.vos.BBDeductionFilterParms;
	import com.Billback.Main.models.vos.BBClosingDetail;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Main.models.vos.BBSettlementAction;
	import com.Billback.Main.models.vos.Billback;
	import com.Billback.Main.models.vos.Payee;
	import com.shared.models.entity.vos.BillTo;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	
	public class BBEditEvent extends Event
	{
		
		/*-.........................................Constants..........................................*/
		public static const APPEND_PAYEE:String 					= 	"appendPayee";
		public static const BB_DELETE:String 						= 	"bbDelete";
		public static const BB_LOAD_APP_SETTINGS:String				=	"bbLoadAppSettings";
		public static const BILLBACK_REINTERFACE:String				=	"billbackReinterface";
		public static const BILLBACK_RESET:String					=	"resetBB";   		
		public static const BILLBACK_SUMBY:String					=	"billbackSumBy";
		public static const BILLBACK_WORKFLOW:String				=	"billbackWorkflow";
		public static const BSA_ERROR:String						=	"bsaError";	
		public static const BSA_NO_SERVICE_ERROR:String				=	"bsaNoServiceError";				
		public static const COPY_BILLBACK:String					=	"copyBillback";		
		public static const CREATE_NEW_BB:String					=	"createNewBB";
		public static const CLEAR_PROG_COMP_ITEMS:String			=	"clearProgCompItems";
		public static const CLEAR_SELECTED_VENDOR:String			=	"clearSelectedVendor";		
		public static const CLEAR_SELECTED_PAYEE:String				=	"clearSelectedPayee";		
		public static const CLEAR_PAYEE_LIST:String					=	"clearPayeeList";		
		public static const CLEAR_SELECTED_PROGRAM:String			=	"clearSelectedProgram";		
		public static const CLEAR_SELECTED_DISTRIBUTOR:String		=	"clearSelectedDistributor";		
		public static const CLEAR_DISTRIBUTOR_LIST:String			=	"clearDistributorList";
		public static const GET_LOCK_BB_EDIT:String					=	"getLockBBEdit";
		public static const GET_PROGRAM_RATES:String				=	"getProgramRates";
		public static const GET_BILLBACK_DETAILS:String				=	"getBillbackDetails";
		public static const GET_DOCUMENTS:String					=   "getDocuments";
		public static const GET_DUPLICATE_BILLBACK:String			=	"getDuplicateBillback";		
		public static const GET_PRODUCT_SEARCH:String				=	"getProductSearch";		
		public static const GET_UPDATED_BB_HEADER:String			=	"getUpdatedBBHeader";					
		public static const LOAD_BBEDIT_ANALYSTS:String				=	"loadBBEditAnalysts";
		public static const LOAD_BB_CLOSING_DETAILS:String			=	"loadBBClosingDetails";
		public static const LOAD_BBEDIT_CLOSINGMETHODS:String		=	"loadBBEditClosingMethods";
		public static const LOAD_BB_DEDUCTIONS:String				=	"loadBBDeductions";
		public static const LOAD_BB_EDIT:String						=	"loadBBEditEvent";		
		public static const LOAD_BB_PROGCUSTITEMS:String			=	"loadBBPrgCustItems";				
		public static const LOAD_BB_PROGRAMS:String					=	"loadBBPrograms";	
		public static const LOAD_BILL_TO_LIST:String				=	"loadBillToList";
		public static const LOAD_DISTRIBUTOR:String					=	"loadDistributor";
		public static const LOAD_DISTRIBUTOR_SEARCH:String			=	"loadDistributorSearch";
		public static const LOAD_DISTRIBUTOR_SELECTED:String		=	"loadDistributorSelected";
		public static const LOAD_ITEM_LIST:String					=	"loadItemList";
		public static const LOAD_OPERATOR:String					=	"loadOperator";
		public static const LOAD_OPERATOR_SEARCH:String				=	"loadOperatorSearch";
		public static const LOAD_PAYEE:String						=	"loadPayee";
		public static const LOAD_PAYEE_DISTRIBUTOR:String			= 	"loadPayeeDistributor";
		public static const LOAD_PAYEE_LIST:String					=	"loadPayeeList";
		public static const LOAD_PAYEE_SEARCH:String				=	"loadPayeeSearch";
		public static const LOAD_PRODUCTS:String					=	"loadProducts";
		public static const LOAD_PROGRAM:String						=	"loadProgram";		
		public static const LOAD_PROGRAM_LIST:String				=	"loadProgramList";		
		public static const LOAD_PROGRAM_SEARCH:String				=	"loadProgramSearch";		
		public static const LOAD_VENDOR:String						=	"loadVendor";
		public static const LOAD_VENDOR_SEARCH:String				=	"loadVendorSearch";
		public static const LOAD_UOM_DP:String						=	"loadUomDp";
		public static const LOCK_BB_EDIT:String						=	"lockBBEdit";
		public static const LOCK_DEDUCTION:String					=	"lockDeduction";	
		public static const OPEN_PRINT_PAGE:String					=	"openPrintPage";
		public static const OPEN_EMAIL_PAGE:String					=	"openEmailPage";
		public static const OPEN_BB_STATEMENT:String				=	"openBBStatement";
		public static const RUN_DEVIATIONS:String					=	"runDeviations";		
		public static const REVERSE_BILLBACK:String					=	"reverseBillback";
		public static const SAVE_BB_EDIT:String						=	"saveBBEdit";
		public static const SAVE_BB_EDIT_SETTLE:String				=	"saveBBEditSettle";
		public static const SAVE_CLOSING_DETAIL:String				=	"saveClosingDetail";
		public static const SAVE_SETTLEMENT:String					=	"saveSettlement";
		public static const SEARCH_ITEMS:String						=	"searchItems";	
		public static const SELECT_TAB:String						=	"selectTab";
		public static const SET_BB_ANALYST:String					=	"SetBBAnalyst";
		public static const SET_FOCUS_VENDOR_INPUT:String			=	"setFocusVendorInput";
		public static const SET_GRID_LOCK_UNLOCK:String				= 	"setGridLockUnlock";
		public static const SET_PAYEE_LIST:String					=	"setPayeeList";
		public static const SET_USER_ID:String						=	"setUserIdEvent";
		public static const SET_VENDOR_INPUT_CHANGE:String			=	"setVendorInputChange";
		public static const SHOW_ADJUST_BIZ_CONSIDERATIONS:String	=	"showAdjustBizConsiderations";		
		public static const SHOW_BIZ_CONSIDERATIONS:String			=	"showBizConsiderations";
		public static const SHOW_HISTORY:String						=	"showHistory";
		public static const SHOW_BB_DEVIATION_REPORT:String			=	"showBBDeviationReport";
		public static const SHOW_PROGRAM_SUMMARY:String				=	"showProgramSummary";
		public static const UNLOCK_OTHER_LOCKED_USER:String			=	"unlockOtherLockedUser";
		public static const VALIDATE_BB_EDIT_DTL:String				=	"validateBBEditDTL";
		public static const VALIDATE_BB_EDIT_HDR:String				=	"validateBBEditHdr";
		public static const LOAD_PROGRAM_PRODUCT_LIST:String		=	"loadProgramProductList";
		public static const LOAD_ITEM_LIST_SO:String				=	"loadItemListSO";
		
		//	public static const VALIDATE_BB_EDIT_COMP:String			=	"validateBBEditComp";
		
		
		/*-.........................................Properties..........................................*/		
		public var appSettings:Object;
		public var arrDeduction:Array;
		public var bbAnalysts:Array;
		public var bbClosingDetail:BBClosingDetail;
		public var bbDeductionFilterParms:BBDeductionFilterParms;
		public var bbSettlementAction:BBSettlementAction;
		public var bbHeader:BBHeader;
		public var bbId:String;
		public var bbIdInt:int;
		public var bLock:Boolean;
		public var bSetVendorText:Boolean;
		public var billback:Billback;
		public var bizConMode:String;
		public var closingMethodList:Array;
		public var distributor:Customer;
		public var distributorId:String;
		public var iIndex:int;
		public var lockIt:Boolean;
		public var oBaError:Object;
		public var operatorId:String;
		public var programId:int;
		public var programNumber:String;
		public var payeeId:String;
		public var payee:Payee;
		public var sBaError:String;
		public var settings:Settings;
		public var sState:String;
		public var userId:String;
		public var vendorId:String;
		public var vendor:Payee;
		public var payeeList:Array;
		public var payeeTypeId:Number;
		public var lProducts:String;
		public var bbtoggle:Boolean;
		public var bbUnlockExistingLockedByUser:Boolean;
		public var bbClose:Boolean;
		public var vendorSearchType:Number;
		
		
		/*-.........................................Contructor..........................................*/
		public function BBEditEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}	
	}
	
}