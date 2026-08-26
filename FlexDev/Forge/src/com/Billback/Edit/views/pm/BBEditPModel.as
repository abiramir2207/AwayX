package com.Billback.Edit.views.pm
{
	import adobe.utils.CustomActions;
	
	import com.Billback.Edit.events.BBEditEvent;
	import com.Billback.Edit.models.vos.BBProdRate;
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.*;
	import com.shared.components.MenuItem;
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	import com.shared.models.entity.vos.Operator;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.MenuEvent;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.utils.ObjectUtil;
	import mx.validators.StringValidator;
	
	import spark.components.RichText;
	
	public class BBEditPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBEditPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		/*.................oSettings......................*/
		[Bindable] public var oSettings:Settings = new Settings();
		[Bindable] public var acBBAnalysts:ArrayCollection = new ArrayCollection();
		//	[Bindable] public var reDirector:String = 'EDIT';
		
		private var _billback:Billback = new Billback();
		//[Bindable]	public var billback:Billback = new Billback();
		//[Bindable]	public var closingMethodList:Array = new Array();
		[Bindable]	public var program:Program = new Program();
		
		[Bindable]	public var selectedPayee:Payee = new Payee();
		[Bindable]	public var selectedVendor:Payee = new Payee();
		[Bindable]	public var selectedProgram:Program = new Program();
		[Bindable]	public var selectedDistributor:Customer = new Customer();
		// [Bindable]	public var selectedOperator:Operator= new Operator();
		[Bindable]	public var objBBToolsLock:BBToolsLock = new BBToolsLock();
		
		// array collections
		[Bindable]	public var acPayee:ArrayCollection = new ArrayCollection();
		[Bindable]	public var acProgram:ArrayCollection = new ArrayCollection();
		[Bindable]	public var acDistributor:ArrayCollection = new ArrayCollection();
		// [Bindable]	public var acOperator:ArrayCollection= new ArrayCollection();
		[Bindable]	public var acComponent:ArrayCollection= new ArrayCollection();
		[Bindable]	public var acProgramProduct:ArrayCollection= new ArrayCollection();
		
		// lock variables
		private var _closingMethodList:Array = new Array();
		private var _bbLock:Lock = new Lock();
		private var _acMenuData:ArrayCollection = new ArrayCollection();
		[Bindable]	public var btnBBLockLabel:String= "edit";
		[Bindable]	public var sBBLockMsgText:String= "";
		private var menuLog:MenuItem;
		private var menuComm:MenuItem;
		private var menuDocs:MenuItem;
		private var menuActions:MenuItem;
		private var menuSubDocs:MenuItem;
		public var _modifyMenu:Boolean = false;
		public var billbackHeaderDetail:BBDetails = new BBDetails();
		[Bindable] public var nWidthContainer:Number = 1130;
		private var _panelHeight:int = 375;
		private var _initialPanelHeight:int = 375;
		//temp place holder for getVendor Alert
		private var _sPayeeId:String= "";
		
		/*.................Billback......................*/
		
		[Bindable (event="BillbackChanged")]
		public function get billback():Billback
		{
			return _billback;
		}
		public function set billback(billback:Billback):void
		{
			this._billback = billback;
			dispatchEvent(new Event('BillbackChanged'));
		}
	
		
		/*.......................  Methods  .......................*/		
		// close Billback
		public function closeBB():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB);
			if(this.billback){
				e.bbHeader  = this.billback.bbHeader;
			}
			this._dispatcher.dispatchEvent(e);
			
			// event to unlock
			var e1:BBEditEvent = new BBEditEvent(BBEditEvent.LOCK_BB_EDIT);		
			e1.bbId		= ObjectUtil.toString(this.billback.bbHeader.billbackIDInt);
			e1.userId	= this.oSettings.userId;			
			e1.bbtoggle = false;
			e1.bbUnlockExistingLockedByUser = false;
			e1.bbClose = true;
			
			/* If the billback is locked */	
			if(this.billback.bbHeader.locked)
			{
				/* Keep the billback locked */	
				e1.lockIt	= true;	
				
				/* But...if the billback is locked by the person closing the billback  */	
				if(this.billback.bbHeader.lockedBy == this.oSettings.userId)
				{
					/* unlock the billback */
					e1.lockIt	= false;	
				}
			}
			// send the event 
			this._dispatcher.dispatchEvent(e1);
		}
		
		/*.............	vendor	.............*/
		// get vendor
		public function getVendor(vendorId:String):void{
			
			var evtBBedit:BBEditEvent = new BBEditEvent(BBEditEvent.SET_VENDOR_INPUT_CHANGE);
			evtBBedit.vendorId = vendorId;
			this._dispatcher.dispatchEvent(evtBBedit);
			/*if(vendorId.length){
			//only if the vendor has changed.  this is caled from focusOut
			if(vendorId != this.selectedVendor.payeeId){
			this._sPayeeId = vendorId;
			var s:String = "By changing the payee on the billback we will remove the program, component, and item level details.   Click OK to continue or Click Cancel to cancel the action."; 
			Alert.show(s,'Payee Update Alert',Alert.OK|Alert.CANCEL,null,getVendorAction,null);
			....... chained to the end of BBEditEvent.CLEAR_PROG_COMP_ITEMS .....
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_VENDOR);
			e.vendorId  = vendorId; 
			this._dispatcher.dispatchEvent(e); 
			.......................................................................
			}
			} 
			else{
			var e2:BBEditEvent = new BBEditEvent(BBEditEvent.CLEAR_SELECTED_VENDOR);
			e2.vendor  = new Payee(); 
			this._dispatcher.dispatchEvent(e2);
			}*/
		}
		// get vendor action handles the response from the getVendor Change Alert pop up
		/*public function getVendorAction(evt:CloseEvent):void{
		//if the user clicked OK
		if(evt.detail == Alert.OK){
		//TODO:  CLEAR out program, component, and item level details
		var e:BBEditEvent = new BBEditEvent(BBEditEvent.CLEAR_PROG_COMP_ITEMS);
		e.vendorId  = this._sPayeeId; 
		this._dispatcher.dispatchEvent(e);
		}
		else{ // Alert.CANCEL
		// Put Focus in the Vendor Input Box. bSetVendorText flag will put the text back to what it was 
		var evtBBedit:BBEditEvent = new BBEditEvent(BBEditEvent.SET_FOCUS_VENDOR_INPUT);
		evtBBedit.bSetVendorText = true;
		this._dispatcher.dispatchEvent(evtBBedit);
		}
		}*/
		
		
		// search vendor
		public function getVendorSearch():void{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_VENDOR_SEARCH);
			/* VendorSearchType = 2 ==> return only the vendor with the account */
			e.vendorSearchType = 2;
			this._dispatcher.dispatchEvent(e);
		}
		
		/*.............	payee	.............*/
		// get payee
		public function getPayee(payee:Payee):void{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PAYEE);
			e.payee = payee; 
			this._dispatcher.dispatchEvent(e);
		}
		// search payee
		public function getPayeeSearch():void{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PAYEE_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}
		
		/*.............	program	.............*/
		// get program
		public function getProgram(programId:int):void{
			// load new program			
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PROGRAM);
			e.programId  = programId;
			
			if (oSettings.appSettings.Billback_Display_All_Program_Components == true){
				e.payeeTypeId = 0;
			}else{
				e.payeeTypeId = this.billback.bbHeader.payee.payeeTypeId;
			}
			
			this._dispatcher.dispatchEvent(e);
		}
		
		// search program
		public function getProgramSearch():void{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PROGRAM_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}
		
		/*.............		distributor	.............*/
		// get distributor
		public function getDistributor(distributorId:String):void{
			// if the distributor exists in the dropdown then set selectedDistributor otherwise load the new distributor
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_DISTRIBUTOR_SELECTED);
			e.distributorId  = distributorId; 
			this._dispatcher.dispatchEvent(e);
		}
		
		// search distributor
		public function getDistributorSearch():void{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_DISTRIBUTOR_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}		
		
		/*.............		operator	.............*/
		/*
		// get operator
		public function getOperator(operatorId:String):void{
		var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_OPERATOR);
		e.operatorId  = operatorId; 
		this._dispatcher.dispatchEvent(e);
		}
		
		// search operator
		public function getOperatorSearch():void{
		var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_OPERATOR_SEARCH);
		this._dispatcher.dispatchEvent(e);
		}
		*/
		
		/*.................closingMethods......................*/
		[Bindable (event="closingMethodChanged")]
		public function get closingMethodList():Array
		{			
			dispatchEvent(new Event('BillbackChanged'));			
			return _closingMethodList;
		}
		public function set closingMethodList(closingMethodList:Array):void
		{
			this._closingMethodList = closingMethodList;
			dispatchEvent(new Event('closingMethodChanged'));
		}
		
		
		/*.................bb lock check......................*/
		[Bindable (event="BBLockChanged")]
		public function get BBLock():Lock{
			return _bbLock;
		}
		public function set BBLock(obj:Lock):void{
			this._bbLock= obj;
			dispatchEvent(new Event('BBLockChanged'));
		}
		
		[Bindable (event="panelHeightChanged")]
		public function get panelHeight():int
		{
			return _panelHeight;
		}
		public function set panelHeight(numComponents:int):void
		{
			var iPanelHeight:int = 0;
			/* Set the panel height to the default panel Height. */
			iPanelHeight = this._initialPanelHeight;

			/*  We are currently showing two components in a row. The default height above exists component 1 and 2.
				We need to increase the height of the panel to see more than 2 components. The loop starts from 2 because
				the height needs to increase only from the 3rd components onwards.*/
			for (var i:int = 2; i <=numComponents; i++)
			{	
				/* Currently we show 4 rows of components (8 components). If there are more than 8, then we have vertical scrollbar
				to see the remaining components and so there is no need to increase the height of the panel */
				if(i <= 9){
					/* For component 3,5,7 (every odd number), add the height of the panel */
					if(i % 2 == 1){
						iPanelHeight = iPanelHeight + 22;
					}
				}
			}			
			this._panelHeight = iPanelHeight;
			dispatchEvent(new Event('panelHeightChanged'));
		}
		
		// lock-unlock Billback
		public function toggleBBLock():void{
			if(this.billback is Billback)
			{								
				// event to lock
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOCK_BB_EDIT);		
				e.bbId		= ObjectUtil.toString(this.billback.bbHeader.billbackIDInt);
				e.userId	= this.oSettings.userId;
				e.lockIt	= true;
				e.bbtoggle = true;
				e.bbUnlockExistingLockedByUser = false;
				e.bbClose = false;
				
				//if locked then unlock only when the locked user and this user is same
				if(this.billback.bbHeader.locked && (this.billback.bbHeader.lockedBy == this.oSettings.userId)){
					e.lockIt	= false; // unlock										
				}
				
				// send the event 
				this._dispatcher.dispatchEvent(e);
			}
		}
		
		// display the lock-unlock message
		public function displayBBLock():void
		{
			/* The billback is locked by some other user, set it to "read only" mode  */
			if(this.billback.bbHeader.lockedByOther == true && this.BBLock.bLocked){				
				this.btnBBLockLabel = "read-only";//read-only
				this.sBBLockMsgText = " (Locked by " + this.BBLock.userLocked.fullName.toUpperCase() +")";// " on: " + this.BBLock.lockDate + 
				//this.iconLockCurrent = iconLock;
			}	
				
				/* The billback is not locked, set it to "read only" mode */
			else if(this.billback.bbHeader.locked == false && !this.BBLock.bLocked){				
				this.btnBBLockLabel = "read-only";//read-only
				this.sBBLockMsgText = "";//"Click the Lock Icon to Edit this BB";
				//this.iconLockCurrent = iconLock;
			}
				
				// unlock
				/* If the billback is locked by the user (not some other user), set it to "edit" mode */
			else{
				this.btnBBLockLabel = "edit";//edit
				this.sBBLockMsgText = "";// " (Locked by " + this.BBLock.userLocked.fullName.toUpperCase() +")";// " on: " + this.BBLock.lockDate + 
				//this.iconLockCurrent = iconUnLock;
			}
		}
		
		/*.............	duplicate billbacks	.............*/
		// getDuplicateBillbacks
		public function getDuplicateBillbacks(billbackNumber:String, vendorId:String):void
		{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.GET_DUPLICATE_BILLBACK);
			e.bbHeader = this.billback.bbHeader;
			e.bbHeader.BBNumber = billbackNumber;
			e.vendorId = vendorId;
			this._dispatcher.dispatchEvent(e);
			
		} 
		
		/*.................business considerations......................*/
		public function showBizCon(mode:String=null):void
		{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.SHOW_BIZ_CONSIDERATIONS);
			if(mode){e.bizConMode = mode;}
			this._dispatcher.dispatchEvent(e);
		}
		
		/*.................history......................*/
		public function showHistory():void
		{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.SHOW_HISTORY);
			this._dispatcher.dispatchEvent(e);
		}
		
		/*.............	copy billbacks	.............*/
		public function copyBillback():void
		{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.COPY_BILLBACK);
			e.bbIdInt = this.billback.bbHeader.billbackIDInt;
			e.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(e);
			
		} 
		
		/*.............	adjustBillback billback	.............*/
		public function adjustBillback():void
		{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.SHOW_ADJUST_BIZ_CONSIDERATIONS);
			this._dispatcher.dispatchEvent(e);
		} 
		
		//[Embed(source="/assets/Images/lock_25.png")]
		//public static var iconLock:Class;
		
		//[Embed(source="/assets/Images/unLock_25.png")]
		//public static var iconUnLock:Class;
		
		//public var iconLockCurrent:Class = iconUnLock;
		
		/*.................menu data......................*/
		[Bindable (event="menuDataChanged")]
		public function get acMenuData():ArrayCollection{
			return _acMenuData;
		}
		
		public function set acMenuData(ac:ArrayCollection):void{
			// this._acMenuData= ac;
			
			//**** NOTE: Third argument is array of parameters/arguments //
			/*
			var arr:Array= new Array('0','1','2') // 
			_acMenuData.addItem(new MenuItem("test", showMe, arr));
			or 
			menuDocs.children.push(new MenuItem("one", showMe, arr));
			*/
			_acMenuData = new ArrayCollection();
			
			/* 
			NOTE: The only item added to the menu for a billback which
			has not been saved and does not have a "BBCode" as yet is "close"
			*/
			
			/* When BBCode has already been generated */  
			if(this.BBLock.objId != null){	
				/* get information about "read-only/edit/locked by" */
				displayBBLock();
				
				_acMenuData.addItem(new MenuItem(this.btnBBLockLabel + this.sBBLockMsgText, toggleBBLock,null,true,'normal',true,'',null,this.sBBLockMsgText)); //iconLockCurrent (replace second to last null)
			}
			
			_acMenuData.addItem(new MenuItem("close", closeBB));
			
			/* When BBCode has already been generated */
			if(this.BBLock.objId != null){
				menuLog = new MenuItem("log");
				menuLog.children = new Array();
				menuLog.children.push(new MenuItem("history", showHistory));
				menuLog.children.push(new MenuItem("workflow", showWorkFlow));
				
				menuLog.children.push(new MenuItem("EDI duplicate", showDuplicates, null, this.oSettings.appSettings.EnableBBDupCheck));
				
				_acMenuData.addItem(menuLog);
				
				menuComm = new MenuItem("communications");
				menuComm.children = new Array();
				menuComm.children.push(new MenuItem("business considerations", showBizCon, null, objBBToolsLock.bBusinessConsiderationsEnabled));
				menuComm.children.push(new MenuItem("email", emailBB));
				menuComm.children.push(new MenuItem((this.oSettings.appFlex.bbLabels.Summary_Report).toLowerCase(), showBBStatement, null, objBBToolsLock.bSummaryReport));
				menuComm.children.push(new MenuItem("print", printBB));
				
				menuComm.children.push(new MenuItem("compliance report", showComplianceReport, null, (this.oSettings.appSettings.EnableBBDupCheck && (this.billback.bbHeader.UploadedBillback == 2 || this.billback.bbHeader.UploadedBillback == 3))));
				
				_acMenuData.addItem(menuComm);
				
				menuDocs = new MenuItem("documents", showMe);
				menuDocs.children = new Array();
				/* When the user clicks on "upload", take the user to a CF page for document upload and add */
				menuDocs.children.push(new MenuItem("upload", uploadAndAddDocs));
				if(oSettings.user.stProfileSettings.SEARCH_DOCUMENTS == 1)
				{
					/* When the user clicks on "search, take the user to a CF page for document search/add/delete */
					menuDocs.children.push(new MenuItem("search", searchAndAddAndDeleteDocs));
				}
				
				menuSubDocs = new MenuItem("view", showMe);
				menuDocs.children.push(menuSubDocs);
				
				/* When the user clicks on "actions", call the "getActionList" function. */
				menuActions = new MenuItem("actions", getActionList);
				menuActions.children = new Array();
				/* Note: These entries are alphabetically sorted. Whenever adding a new entry, add it alphabetically. */
				menuActions.children.push(new MenuItem("adjust", adjustBillback, null, objBBToolsLock.bAdjustEnabled));
				menuActions.children.push(new MenuItem("budgets", showBudget));
				menuActions.children.push(new MenuItem("copy", copyBillback,null,this.oSettings.user.stProfileSettings.BB_CREATE == 1));
				menuActions.children.push(new MenuItem("delete", deleteConfirm, null, objBBToolsLock.bDeleteEnabled));
				menuActions.children.push(menuDocs);
				menuActions.children.push(new MenuItem("re-interface", reInterface,null, objBBToolsLock.bReinterfaceEnabled));
				menuActions.children.push(new MenuItem("reset", showBBReset, null,objBBToolsLock.bResetEnabled));
				// reverse based on profile setting and status
				menuActions.children.push(new MenuItem("reverse", reverseBB, null, objBBToolsLock.bReverseEnabled));
				menuActions.children.push(new MenuItem("sum-by", sumBy));
				_acMenuData.addItem(menuActions);
			}			
			
			dispatchEvent(new Event('menuDataChanged'));
		}
		
		/*.................MENU FUNCTIONS......................*/
		public function setMenuData():void {			
			/*
			acMenuData.addItem( new MenuItem( "close", closeBB ) );
			acMenuData.addItem( new MenuItem( "edit", showMe ) );
			acMenuData.addItem( new MenuItem( "log", showMe ) );
			
			var menuComm:MenuItemWithChildren = new MenuItemWithChildren( "communications");
			menuComm.children.push( new MenuItem( "business considerations", showMe ) );
			menuComm.children.push( new MenuItem( "print", showMe ) );
			menuComm.children.push( new MenuItem( "email", showMe ) );
			acMenuData.addItem( menuComm );
			
			var menuActions:MenuItemWithChildren = new MenuItemWithChildren( "actions" );
			menuActions.children.push( new MenuItem( "reset", showMe ) );
			menuActions.children.push( new MenuItem( "delete", showMe ) );
			menuActions.children.push( new MenuItem( "sum-by", showMe ) );
			acMenuData.addItem( menuActions );
			*/
		}
		
		/*.................menu data modified......................*/
		[Bindable (event="modifyMenuData")]
		public function get modifyMenu():Boolean{
			return _modifyMenu;
		}
		
		/* Modify entries under "VIEW" entry under "documents" */
		public function set modifyMenu(menuModify:Boolean):void
		{
			this._modifyMenu = menuModify;
			
			/* If menu data modified */
			if(menuModify == true)
			{			
				
				menuSubDocs.children = new Array();
				
				var doc_count:int = -1;				
				for each(var oBBHeaderDetails:String in billbackHeaderDetail.documentList)
				{ 
					if(oBBHeaderDetails != '')
					{
						doc_count = doc_count + 1;
						/* The array index of the document returned by CF is needed. This is needed to get the right document. */
						var doc_index:Array = new Array();
						doc_index[0] = doc_count;
						
						/* Add the documents as entries under "VIEW". Pass document index to the "openDocs" function */
						menuSubDocs.children.push(new MenuItem(oBBHeaderDetails, openDocs,doc_index));
					}	
				}
				dispatchEvent(new Event('modifyMenuData'));
			}
		}
		
		
		//**********	menu handlers	**********//
		public function menuItemHandler(event:MenuEvent):void {
			var menuItem:MenuItem =  event.item as MenuItem;
			if (event.item.args){
				menuItem.menuHandler(event.item.args);	
			}else{
				menuItem.menuHandler();	
			}
		}
		
		public function menuHandler(event:Event):void {			
		 if(event.target.hasOwnProperty('data')){
			if (event.target.data.menuHandler){
				if (event.target.data.args){
					event.target.data.menuHandler(event.target.data.args);
				}else{
					event.target.data.menuHandler();						
				}
			}
		  }
		}
		
		public function menuOverHandler(event:Event):void {
			
			if (event.target.hasOwnProperty('data')){  
				 if(event.target.data.label == 'actions'){
					this.menuHandler(event);
			}	 }
		}
		
		// dont use/delete this funtion; copy this function and rename urs
		public function showMe(arr:Array=null):void {
			if(arr){
				for each( var item:String in arr){
					trace(item);
				}
			}else{
				trace('item');
			}
		}
		
		
		/* Called when the user clicks on "actions" item on the menuList */
		public function getActionList():void {
			
			/* "GET DOCUMENTS" Action */
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.GET_DOCUMENTS);
			e.bbIdInt = this.billback.bbHeader.billbackIDInt;
			e.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(e);
			
			/* ADD MORE ACTION EVENTS HERE */
			
			/*for each(var oMenuItems:MenuItem in this.acMenuData)
			{	
			if(oMenuItems.label == 'actions')
			}*/
		}
		
		
		// email Billback
		public function emailBB():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.OPEN_EMAIL_PAGE);
			this._dispatcher.dispatchEvent(e);			
		}
		
		// print Billback
		public function printBB():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.OPEN_PRINT_PAGE);
			this._dispatcher.dispatchEvent(e);			
		}
		
		// reverse Billback
		public function reverseBB(arr:Array=null):void {
			//	business considerations
			if (oSettings.appSettings.BusinessConsiderations_On){
				this.showBizCon('11');
			}
			
			var e2:BBEditEvent 	= new BBEditEvent(BBEditEvent.REVERSE_BILLBACK);
			e2.bbIdInt 			= this.billback.bbHeader.billbackIDInt;
			e2.userId 			= this.oSettings.userId;
			this._dispatcher.dispatchEvent(e2);			
		}
		
		
		/* This function takes the user to the CF page, where the user could upload and add documents */
		private function uploadAndAddDocs() : void
		{ 				
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("saveDocs", saveDocs);
				var winjscommand:String ="/BillbackID_Wrapper.cfm?FormName=flex&FlexAppName="+currentAppName+"&Billback_ID_Int="+this.billback.bbHeader.billbackIDInt+"&Page_Relocate=/common_files/documents/create_multiple_document_details.cfm";
				var jscommand:String = "window.open('"+winjscommand+"','winPrint','height=600,width=810,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"   
				var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
				navigateToURL(url, "_self");
			}
		}
		
		
		/* This function takes the user to the CF page, where the user could search,add and delete documents */ 
		private function searchAndAddAndDeleteDocs() : void
		{ 				
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("saveDocs", saveDocs);
				var winjscommand:String ="/BillbackID_Wrapper.cfm?FormName=flex&FlexAppName="+currentAppName+"&Billback_ID_Int="+this.billback.bbHeader.billbackIDInt+"&Page_Relocate=/billbacks/capture/Attachments_Form.cfm";
				var jscommand:String = "window.open('"+winjscommand+"','winPrint','height=600,width=810,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"   
				var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
				navigateToURL(url, "_self");
			}
		}
		
		/* Pass the document index. This is used to open the correct document. */
		private function openDocs(itemIndex:Array) : void{
			var strPathName:String;
			strPathName = billbackHeaderDetail.uniqueFileName[itemIndex[0]];
			
			//var winjscommand:String ="/BillbackID_Wrapper.cfm?Billback_ID_Int="+this.billback.bbHeader.billbackIDInt+"&Page_Relocate="+billbackHeaderDetail.domainName+"/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/"+strPathName+"&ShowDocs=1";
			//var jscommand:String = "window.open('"+winjscommand+"','winPrint','height=600,width=800,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"   
			var jscommand:String = "window.open('" + billbackHeaderDetail.domainName + "/GetDocument.cfm?FilePath=data_files/uploaded/documents/uploaded_doc/" + escape(strPathName) + "');";
			var url:URLRequest = new URLRequest("javascript:" + escape(jscommand) + " void(0);");   
			navigateToURL(url, "_self");
		}
		
		/* Get a list of Billback_ID_Int after it is returned from the popup page. */
		public function saveDocs(BillbackList:String):void {
			
			for each(var i:String in BillbackList.split(","))
			{			
				/* Get the updated bbheader and reload it on "BB Search" */
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.GET_UPDATED_BB_HEADER);
				e.bbIdInt = new int( int(i));  
				this._dispatcher.dispatchEvent(e);			
			}				
			
			Alert.show("The document process is completed.");
		}
				
		public function getAdjustList():void {
			this.adjustBillback();
		}		
		
		// Billback Workflow 
		public function showWorkFlow():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.BILLBACK_WORKFLOW);
			e.bbIdInt 			= this.billback.bbHeader.billbackIDInt;
			e.userId			= this.oSettings.userId;
			this._dispatcher.dispatchEvent(e);			
		}
		
		// Billback Statement 
		public function showBBStatement():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.OPEN_BB_STATEMENT);
			this._dispatcher.dispatchEvent(e);			
		}
		
		// Billback Deviation Report 
		public function showBBDeviation():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.SHOW_BB_DEVIATION_REPORT);
			this._dispatcher.dispatchEvent(e);			
		}
		
		
		public function showBBReset():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.BILLBACK_RESET);
			e.bbIdInt 			= this.billback.bbHeader.billbackIDInt;
			e.userId			= this.oSettings.userId;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function sumBy():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.BILLBACK_SUMBY);
			this._dispatcher.dispatchEvent(e);
		}
		
		// Set BB for interface queue
		public function reInterface():void {
			var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.BILLBACK_REINTERFACE);
			e.bbIdInt = this.billback.bbHeader.billbackIDInt;			
			this._dispatcher.dispatchEvent(e);
		}
		public function isApproved():Boolean {
			return (this.billback.bbHeader.status.id >=3);
		}
		
		/* This is used to open the pop up for the budget screen */
		public function showBudget():void
		{
			var jsURL:String = "/billbacks/APPROVAL/advanced_budget_billback.cfm?Billback_ID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+ jsURL + "','winBudget','height=640,width=1300,toolbar=no,scrollbars=yes,resizable=yes');";			
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);"); 
			navigateToURL(url, "_self"); 
		}	
		
		private function deleteConfirm():void
		{
			var alertResult:Alert;
			
			alertResult = Alert.show("Do you really want to delete the " + this.oSettings.appFlex.bbLabels.Billback +"?", "Confirm Delete!", Alert.YES | Alert.NO, null, deleteBB);  
		}
		
		private function deleteBB(CloseEvent:Object) : void
		{ 
			/* CloseEvent.detail is 1 for "yes" and 2 for "no" */
			if(CloseEvent.detail == 1){				
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.BB_DELETE);					
				e.userId = this.oSettings.userId;		
				e.bbIdInt = this.billback.bbHeader.billbackIDInt;				
				this._dispatcher.dispatchEvent(e);				
			}  
		}
		
		/* This is used to open the pop up for the budget screen */
		public function showDuplicates():void
		{
			var jsURL:String = "/billbacks/common/Billback_Dup_Checker.cfm?Billback_ID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+ jsURL + "','winDuplicate','height=640,width=900,toolbar=no,scrollbars=yes,resizable=yes');";			
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);"); 
			navigateToURL(url, "_self"); 
		}	
		
		// EDIDownload.cfm?Billback_ID=#URL.BBID#&Type=#Get_Billback_Info.Uploaded_Billback
		public function showComplianceReport():void
		{
			var jsURL:String = "/billbacks/capture/EDIDownload.cfm?Billback_ID=" + this.billback.bbHeader.billbackIDGUID + "&Type=" + this.billback.bbHeader.UploadedBillback;
			var jscommand:String = "window.open('"+ jsURL + "','winDuplicate','height=640,width=900,toolbar=no,scrollbars=yes,resizable=yes');";			
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);"); 
			navigateToURL(url, "_self"); 
		}	
	}
}