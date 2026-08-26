package com.Billback.Upload.models
{
	
	import com.Billback.Edit.models.vos.*;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.*;
	import com.Billback.Upload.BBUpload;
	import com.Billback.Upload.events.BBUploadEvent;
	import com.Billback.Upload.models.vos.BBProdRate;
	import com.Billback.Upload.models.vos.BBUploadDetail;
	import com.Billback.Upload.models.vos.BBUploadDetailError;
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.Billback.Upload.models.vos.BBUploadHeaderError;
	import com.Billback.Upload.models.vos.BBUploadLog;
	import com.Billback.Upload.views.pm.BBUploadPModel;
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import com.shared.components.StringUtils;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	import com.shared.models.entity.vos.Operator;
	import com.shared.vos.Settings;
	import com.Billback.Upload.models.vos.BBRawEDIFilterParams; 
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.utils.ObjectUtil;
	
	
	public class BBUploadManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function BBUploadManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		private var _acMenuData:ArrayCollection = new ArrayCollection();
		private var _acEDIDMenuData:ArrayCollection = new ArrayCollection();
		private var _bbLock:Lock = new Lock();
		private var _BBToolsLock:BBToolsLock = new BBToolsLock();
	
		private var _selectedVendor:Payee = new Payee();	// vendor obj same as payee
		private var _selectedPayee:Payee = new Payee();	
		private var _sPayeeId:String= "";
		private var _bbCorrectionsLastSavedDate:Date;
		private var _bbUploadLastSavedDate:Date;
		private var _bBtnRefreshEnabled:Boolean = true;
		private var _bBtnSearchEnabled:Boolean = true;
		
		[Bindable]
		public var pModel:BBUploadPModel;
		
		[Bindable (event="vendorChanged")]
		public function get selectedVendor():Payee
		{
			return _selectedVendor;
		}
		public function set selectedVendor(selectedVendor:Payee):void
		{
			this._selectedVendor = selectedVendor;
			dispatchEvent(new Event('vendorChanged'));			
		}	
		
		/*.................bbUploadHeader......................*/
		private var _bbUploadHeader:BBUploadHeader = new BBUploadHeader();
		[Bindable (event="bbUploadHeaderChanged")]
		public function get bbUploadHeader():BBUploadHeader
		{
			return _bbUploadHeader;
		}
		public function set bbUploadHeader(bbUploadHeader:BBUploadHeader):void
		{
			this._bbUploadHeader = bbUploadHeader;
			dispatchEvent(new Event('bbUploadHeaderChanged'));
		}
		
		/*.................bbUploadHeader......................*/
		private var _bbRawEDIHeader:BBRawEDIHeader = new BBRawEDIHeader();
		[Bindable (event="bbRawEDIHeaderChanged")]
		public function get bbRawEDIHeader():BBRawEDIHeader
		{
			return _bbRawEDIHeader;
		}
		public function set bbRawEDIHeader(bbRawEDIHeader:BBRawEDIHeader):void
		{
			this._bbRawEDIHeader = bbRawEDIHeader;
			dispatchEvent(new Event('bbRawEDIHeaderChanged'));
		}		
		
		/*.................bbUploadLog......................*/
		private var _bbUploadLog:BBUploadLog = new BBUploadLog();
		[Bindable (event="bbUploadLogChanged")]
		public function get bbUploadLog():BBUploadLog
		{
			return _bbUploadLog;
		}
		public function set bbUploadLog(bbUploadLog:BBUploadLog):void
		{
			this._bbUploadLog = bbUploadLog;
			dispatchEvent(new Event('bbUploadLogChanged'));
		}
		
		/*.................arrBBCorrections......................*/
		private var _arrBBCorrections:ArrayCollection = new ArrayCollection();
		[Bindable (event="arrBBCorrectionsChanged")]
		public function get arrBBCorrections():ArrayCollection
		{
			return _arrBBCorrections;
		}
		public function set arrBBCorrections(arrBBCorrections:ArrayCollection):void
		{
			this._arrBBCorrections = arrBBCorrections;
			dispatchEvent(new Event('arrBBCorrectionsChanged'));
		}
		
		/*.................arrBBRawEDI......................*/
		private var _arrBBRawEDI:ArrayCollection = new ArrayCollection();
		[Bindable (event="arrBBRawEDIChanged")]
		public function get arrBBRawEDI():ArrayCollection
		{
			return _arrBBRawEDI;
		}
		public function set arrBBRawEDI(arrBBRawEDI:ArrayCollection):void
		{
			this._arrBBRawEDI = arrBBRawEDI;
			dispatchEvent(new Event('arrBBRawEDIChanged'));
		}
		
		/*.................arrBBUploadHistory......................*/
		private var _arrBBUploadHistory:Array = new Array();
		[Bindable (event="arrBBUploadHistoryChanged")]
		public function get arrBBUploadHistory():Array
		{
			return _arrBBUploadHistory;
		}
		public function set arrBBUploadHistory(arrBBUploadHistory:Array):void
		{
			this._arrBBUploadHistory = arrBBUploadHistory;
			dispatchEvent(new Event('arrBBUploadHistoryChanged'));
		}
		
		/*.................arrBBCreated......................*/
		private var _arrBBCreated:Array = new Array();
		[Bindable (event="arrBBCreatedChanged")]
		public function get arrBBCreated():Array
		{
			return _arrBBCreated;
		}
		public function set arrBBCreated(arrBBCreated:Array):void
		{
			this._arrBBCreated = arrBBCreated;
			dispatchEvent(new Event('arrBBCreatedChanged'));
		}
		
		/*.................sFileData......................*/
		private var _sFileData:String = '';
		[Bindable (event="sFileDataChanged")]
		public function get sFileData():String
		{
			return _sFileData;
		}
		public function set sFileData(sFileData:String):void
		{
			this._sFileData = sFileData;
			dispatchEvent(new Event('sFileDataChanged'));
		}		
		
		/*.................bb lock check......................*/
		[Bindable (event="bbLockObjChanged")]
		public function get BBLock():Lock{
			return _bbLock;
		}
		public function set BBLock(oBBLock:Lock):void{
			this._bbLock = oBBLock;
			dispatchEvent(new Event('bbLockObjChanged'));			
		}
		
		/*.................acMenuChanged.....................*/
		[Bindable (event="acMenuDataChanged")]
		public function get acMenuData():ArrayCollection
		{
			return _acMenuData;
		}
		
		public function set acMenuData(acMenuData:ArrayCollection):void
		{
			this._acMenuData = acMenuData;
			dispatchEvent(new Event('acMenuDataChanged'));
		}
		
		/*.................acEDIDMenuChanged.....................*/
		[Bindable (event="acEDIDMenuDataChanged")]
		public function get acEDIDMenuData():ArrayCollection
		{
			return _acEDIDMenuData;
		}
		
		public function set acEDIDMenuData(acEDIDMenuData:ArrayCollection):void
		{
			this._acEDIDMenuData = acEDIDMenuData;
			dispatchEvent(new Event('acEDIDMenuDataChanged'));
		}
		
		/*.................BB Tools.....................*/
		[Bindable (event="objBBToolsLockChanged")]
		public function get objBBToolsLock():BBToolsLock
		{
			return _BBToolsLock;
		}
		
		public function set objBBToolsLock(objBBToolsLock:BBToolsLock):void
		{
			this._BBToolsLock = objBBToolsLock;
			dispatchEvent(new Event('objBBToolsLockChanged'));
			//fire the menu to rebuild -> injectors wil trigger the setter in pModel
			acMenuData = new ArrayCollection();
		}
		
		/*.................bBtnRefreshEnabled......................*/
		[Bindable (event="bBtnRefreshEnabled")]
		public function get bBtnRefreshEnabled():Boolean
		{
			return _bBtnRefreshEnabled;
		}
		public function set bBtnRefreshEnabled(bBtnRefreshEnabled:Boolean):void
		{
			this._bBtnRefreshEnabled = bBtnRefreshEnabled;
			dispatchEvent(new Event('bBtnRefreshEnabled'));
		}	
		
		/*.................bBtnSearchEnabled......................*/
		[Bindable (event="bBtnSearchEnabled")]
		public function get bBtnSearchEnabled():Boolean
		{
			return _bBtnSearchEnabled;
		}
		public function set bBtnSearchEnabled(bBtnSearchEnabled:Boolean):void
		{
			this._bBtnSearchEnabled = bBtnSearchEnabled;
			dispatchEvent(new Event('bBtnSearchEnabled'));
		}	
		
		
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here:  + {ObjectUtil.toString(x)}' );
			
		}
		
		/* format the bb correction data's refresh date/time */
		[Bindable (event="eBBCorrectionslastSavedDate")]
		public function get bbCorrectionsLastSavedDate():String
		{
			var s:String;
			s = StringUtils.getUSDate(_bbCorrectionsLastSavedDate);
			s = s + ' ' + StringUtils.getUSClockTime(_bbCorrectionsLastSavedDate.getHours(), _bbCorrectionsLastSavedDate.getMinutes());
			return s;
		}
		
		/* format the bb upload data's refresh date/time */
		[Bindable (event="eBBUploadlastSavedDate")]
		public function get bbUploadLastSavedDate():String
		{
			var s:String;
			s = StringUtils.getUSDate(_bbUploadLastSavedDate);
			s = s + ' ' + StringUtils.getUSClockTime(_bbUploadLastSavedDate.getHours(), _bbUploadLastSavedDate.getMinutes());
			return s;
		}
		
		public function getBillbackResults(bbh:BBUploadHeader):void{
			var bbUploadHeader:BBUploadHeader;
			//if it is not a full 'reLoad' then we need to persist the detail level data that is on the client (for performance of large uploads).
			if(bbh.errMsg != 'reLoad'){
				bbh.bbUploadDetail = this.bbUploadHeader.bbUploadDetail;
			}
			this.bbUploadHeader = bbh;
			
			var e:BBUploadEvent	= new BBUploadEvent(BBUploadEvent.GET_LOCK_BB_EDIT);		
			e.bbHeaderID		= this.bbUploadHeader.bbHeaderID;
			this._dispatcher.dispatchEvent(e);
			
			//if empty, then success.  close window
			if(bbh && bbh.bbHeaderID == 0){
				//Alert.show('No Errors!',);
				Alert.show('No validation errors to correct.  Upload has been removed or validated already.', bbh.billbackTitle + ' validation',2,null, closeErrorCorrection)
				
			}
			
		}
		
		public function getBBRawEDIDetailResults(bbREH:BBRawEDIHeader):void{
			var bbRawEDIHeader:BBRawEDIHeader;
			//if it is not a full 'reLoad' then we need to persist the detail level data that is on the client (for performance of large uploads).
			/*if(bbh.errMsg != 'reLoad'){
				bbh.bbUploadDetail = this.bbUploadHeader.bbUploadDetail;
			}*/
			this.bbRawEDIHeader = bbREH;
			//if empty, then success.  close window
			if(bbREH && bbREH.BBUploadIIIPHID == 0){
				//Alert.show('No Errors!',);
				Alert.show('No validation errors to correct.  Upload has been removed or validated already.', bbREH.BBNumber + ' validation',2,null, closeErrorCorrection)
				
			}
			
		}
		
		public function getBillbackResultsFromValidate(bbh:BBUploadHeader,sAction:String):void{
			
			if(bbh.errMsg != 'reLoad'){
				bbh.bbUploadDetail = this.bbUploadHeader.bbUploadDetail;
			}

			this.bbUploadHeader = bbh;
			//if empty, then success. close window
			if(sAction == "2")
			{
				if(bbh && bbh.bbHeaderID == 0){
				//Alert.show('No Errors!',);
					Alert.show('Validation completed Successfully.  Billback is queued for creation.', bbh.billbackTitle + ' validation',mx.controls.Alert.OK,null, closeErrorCorrection);
				}
				else
				{
					Alert.show('Validation completed with errors.', bbh.billbackTitle + ' validation',mx.controls.Alert.OK);
				}
			}
			else
			{	
				Alert.show('Successfully Saved.', bbh.billbackTitle + ' saved',mx.controls.Alert.OK);
			} 
			
			/* Enable the grid. The grid was locked (disabled) when the user clicked on "save" or "validate".
			"save" or "validate" action (whichever was called) is complete now.
			*/
			var e1:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SET_GRID_LOCK_UNLOCK);
			e1.lockIt = true;
			this._dispatcher.dispatchEvent(e1);
						

			var oBBToolsLock:BBToolsLock = new BBToolsLock();			
			oBBToolsLock.bBBUploadEditScreenEnabled = true;
			
			/* Show the available options on the menu. The available options like "Save", "validate", "delete" 
			were removed from the view, when the user clicked on "save" or "validate". 
			"save" or "validate" action (whichever was called) is complete now.
			*/
			var e2:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SET_BB_TOOLS_LOCK);
			e2.bbToolsLock = oBBToolsLock;
			this._dispatcher.dispatchEvent(e2);
		}
		
		public function deleteBBUploadDetailResult(e:*):void{
			var x:* = e;
			if(x == e){
				trace('delete row done');
			}
			
		}
		//flag the row as edited so we update it in DB
		public function updateRow(e:MainEvent):void{
			var bbUploadDetail:BBUploadDetail = e.objRowData as BBUploadDetail;
			bbUploadDetail.bEdited = true;
		}
		public function getBillbackResultsFromDelete(bbh:BBUploadHeader):void{
			//this.bbUploadHeader = bbh;
			//if empty, then success. close window
			if(bbh && bbh.bbHeaderID == 0){
				//Alert.show('No Errors!',);
				Alert.show('Uploaded Billback deleted', bbh.billbackTitle + ' Delete',mx.controls.Alert.OK,null, closeErrorCorrection);
			}else{
				Alert.show('Delete Error', bbh.billbackTitle + ' Delete',mx.controls.Alert.OK);
			}
			
		}
		
		private function closeErrorCorrection(event:CloseEvent):void{
			
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB_UPLOAD);
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			e.bbId = 'delete';
			e.bbUploadHeader = this.bbUploadHeader;
			this._dispatcher.dispatchEvent(e);
			
		}
		
		/* Get the bb correction data and the refresh date/time */
		public function getSummaryResults(objData:Object):void{
			this.arrBBCorrections = new ArrayCollection(objData.BBARR);
			this._bbCorrectionsLastSavedDate = objData.REFRESHTIME;
			dispatchEvent(new Event('eBBCorrectionslastSavedDate'));
		}
		
		public function addBBCorrections(event:BBUploadEvent):void{
			
			//var bInsert:Boolean = true;
			for each(var bbUploadHeader:BBUploadHeader in event.arrBBcorrrections){
				if(this.arrBBCorrections.source.indexOf(bbUploadHeader) == -1 ){
					this.arrBBCorrections.addItemAt(bbUploadHeader,0);
				}
			}
			dispatchEvent(new Event('arrBBCorrectionsChanged'));
			/*if(bInsert){
			this.arrBBCorrections = this.arrBBCorrections.unshift(event.arrBBcorrrections);
			}*/
		}
		
		public function removeBBCorrection(event:BBUploadEvent):void{
			var eBBh:BBUploadHeader = event.bbUploadHeader;
			var idx:int = 0;
			for each(var bbh:BBUploadHeader in this.arrBBCorrections){
				if(bbh.bbHeaderID == eBBh.bbHeaderID && bbh.uploadID == eBBh.uploadID){
					this.arrBBCorrections.removeItemAt(idx);
					dispatchEvent(new Event('arrBBCorrectionsChanged'));
					break;
				}
				idx++;
			}
		}
		
		/* Get the bb upload data and the refresh date/time */
		public function getUploadHistoryResults(objData:Object):void{
			this.arrBBUploadHistory = objData.BBARR;
			this._bbUploadLastSavedDate = objData.REFRESHTIME;
			this.bBtnRefreshEnabled = true;
			dispatchEvent(new Event('eBBUploadlastSavedDate'));
			
		}
		
		public function getBBRawEDIResults(objQryData:ArrayCollection):void{
			this.arrBBRawEDI = objQryData;
			this.bBtnSearchEnabled = true;
			if (this.arrBBRawEDI.length == 0)
			{
				Alert.show("Your Search Criteria returned no results. Please retry with different criteria!", "Raw EDI Result Alert!!");
			}
			//this._bbUploadLastSavedDate = objData.REFRESHTIME;
			//this.bBtnRefreshEnabled = true;
			// dispatchEvent(new Event('eBBUploadlastSavedDate'));
			//Alert.show(ObjectUtil.toString(this.arrBBRawEDI));
			
		}
		
		public function selectHistory(bbUploadLog:BBUploadLog):void{
			//set the selected log item
			this.bbUploadLog = bbUploadLog;
		}
		public function getCreatedBillbackResults(arr:Array):void{
			if(arr.length == 0){
				arr.push('No Billbacks');
			}
			this.arrBBCreated = arr;
			this.bbUploadLog.bbUploadHeader = arr;
			dispatchEvent(new Event('bbUploadLogChanged'));
		}
		
		public function downloadFileComplete(e:MainEvent):void{
			//Alert.show('here: ' + ObjectUtil.toString(e.sState) );
			sFileData = e.sState;
		}
		
		// reload billback edit
		public function reloadBillbackEdit():void {
			var bbh:BBUploadHeader = new BBUploadHeader(this.bbUploadHeader);
				//don't send details in reload event
				bbh.bbUploadDetail = new Array();
			var e:BBUploadEvent= new BBUploadEvent(BBUploadEvent.LOAD_BB_EDIT);
			e.bbUploadHeader = bbh;
			this._dispatcher.dispatchEvent(e);
		}
		
		// get lockBB object 
		public function getLockBB(obj:Lock,bbClose:Boolean = false):void{
			
			/* When the user closes a billback, the billback gets unlocked in the db. No need to take any action in flex */
			if(bbClose == false){
				var sMsg:String = "";
				var alertResult:Alert; 
				this.BBLock = obj;
				
				dispatchEvent(new Event('bbLockObjChanged'));
				
				/* set the default lock properties for the BBheader  */
				this.bbUploadHeader.locked = false;
				this.bbUploadHeader.lockedByOther = false;
				this.bbUploadHeader.lockedUser.id = '';
				
				/* if billbacks are not the same - prompt the user [user has another BB locked]. The user has now the option
				to unlock that billback
				*/
				if((this.BBLock.objId != this.BBLock.objIdLocked) && (this.BBLock.objIdLocked.length)) {
					sMsg = sMsg + "Please unlock the uploaded records you have locked below before continuing.";
					/* Call "unlockAlreadyLockedBB" to unlock existing opened billbacks (in flex) by the same user. */
					alertResult = Alert.show(sMsg, "Unlock now!", Alert.OK | Alert.CANCEL, null, unlockAlreadyLockedBB);
				}
				
				// if users are not the same
				if((this.oSettings.userId != this.BBLock.userLocked.id) && (this.BBLock.userLocked.id.length)){
					this.bbUploadHeader.locked = true;
					this.bbUploadHeader.lockedByOther = true;
					this.bbUploadHeader.lockedUser.id = this.BBLock.userLocked.id;					
				}	
				
				// if the billbacks are same and users are same then lock the billback
				if((this.BBLock.objId == this.BBLock.objIdLocked) && (this.BBLock.userId == this.BBLock.userLocked.id)){
					this.bbUploadHeader.locked = true;
					this.bbUploadHeader.lockedUser.id = this.BBLock.userLocked.id;
				}
				
				// unlock
				// if the locked BB and locked user are blank and this BB is still locked, then unlock this BB
				if((this.BBLock.objIdLocked.length == 0) && (this.BBLock.userLocked.id.length == 0) && (this.bbUploadHeader.locked)){
					// unlock	
					this.bbUploadHeader.locked = false;
					this.bbUploadHeader.lockedUser.id = "";
				}
				
				/* If the billback is locked by the user (not some other user) and the request to lock comes from "toggle lock" 
				(edit/read-only toggle) functionality, then reload the billback information.
				Note: when the user switches from edit to read-only, then "this.billback.bbHeader.locked" is false and so we do not
				fire the code below. There is no need to reload data when the user switches to read-only mode. */				
				if(this.bbUploadHeader.locked == true && this.bbUploadHeader.lockedByOther == false && this.BBLock.toggleLock == true)
				{
					reloadBillbackEdit();
				}
				
				/*  When the user requests to lock a billback, the other opened and locked billback(s) in flex need to be unlocked.
				Note: "this.BBLock.unlockExistingLockedByUser" =  true means that the code to unlock "opened and locked" billbacks in db has 
				already been executed and now the same billback(s) need to be unlocked (set to read-only) in flex and then 
				the billback on which the user requested the lock needs to be locked. */
				if(this.BBLock.unlockExistingLockedByUser == true)
				{
					/* Unlock (set to read-only) other opened and locked billback(s) (in flex) */
					var e1:BBMainEvent = new BBMainEvent(BBMainEvent.UNLOCK_BB_UPLOAD);
					e1.bbUploadHeader = this.bbUploadHeader;					
					this._dispatcher.dispatchEvent(e1);
					
					/* This code locks the billback on which the user requested the lock. */
					lockBB(this.bbUploadHeader.bbHeaderID,true,true,false,false);
				}
				
				/* Set the MENU for user selection */
				setObjBBToolsLock(obj);	
			}
		}
		
		private function unlockAlreadyLockedBB(mesgEventObj:CloseEvent):void
		{	
			/*  If the user clicks on "OK" to unlock existing locked billbacks by the same user. This way the lock can be 
			created on the requested billback. 
			*/			
			var iobjIdLocked:int = new int(this.BBLock.objIdLocked);
			
			if (mesgEventObj.detail==Alert.OK){	
				/* "this.BBLock.objIdLocked" is the locked billback which needs to be unlocked, so that the user requested billback can be locked */
				lockBB(iobjIdLocked,false,true,true,false);
			}
		}
		
		public function unlockOtherLockedUser(bbh:BBUploadHeader):void{
			/* if the billback is locked by the current user (not by some other user) and opened in flex, then unlock it */
			if(bbh.locked = true && bbh.lockedByOther == false)
			{
				bbh.locked = false;
				bbh.lockedUser.id = '';
				bbh.lockedByOther = false;
				dispatchEvent(new Event('bbLockObjChanged'));
				
				/* Unlock the billback. The objective here is to set the billback to "read only" mode in flex. */
				lockBB(bbh.bbHeaderID,false,true,false,false);
			}
		}
		
		private function lockBB(objId:int, lock:Boolean,toggleBB:Boolean, bbUnlockExistingLockedByUser:Boolean, bbClose:Boolean):void
		{					 		  
			// event to unlock
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOCK_BB_EDIT);		
			e.bbHeaderID	= objId;
			e.userId	= this.oSettings.userId;
			e.lockIt	= lock;
			e.bbtoggle 	= toggleBB; // did the request come from toggle bb (edit/read-only)
			e.bbUnlockExistingLockedByUser = bbUnlockExistingLockedByUser; // when the user's other opened and locked billbacks need to be unlocked
			e.bbClose = bbClose;
			// send the event 
			this._dispatcher.dispatchEvent(e);
		}
		
		public function showVendorSearch():void 
		{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveVendor", saveVendor);
			var winjscommand:String = "/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=flex&FlexAppName="+currentAppName+"&RebateRecipient_On=1&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch";
			var jscommand:String = "window.open('"+winjscommand+"', 'vendorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// Handle vendor search pop up return
		public function saveVendor(id:String,name:String):void 
		{
			this.bbUploadHeader.vendorId = id;
			this.bbUploadHeader.vendorName = name;
			dispatchEvent(new Event('bbUploadHeaderChanged'));
		}

		/*.................distributor search......................*/
		// distributor search 
		public function showDistributorSearch():void 
		{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveDistributor", saveDistributor);
			var winjscommand:String = "/billbacks/search_screens/PM_select_distributors.cfm?Formname=flex&FlexAppName="+currentAppName+"&OnlyDistributorsUnderMe=0";
			var jscommand:String = "window.open('"+winjscommand+"', 'distributorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		// distributor search return
		public function saveDistributor(sDistributorID:String):void 
		{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_DISTRIBUTOR);
			e.distributorId = sDistributorID;  
			this._dispatcher.dispatchEvent(e);
		}
		
		public function setDistributorInfo(aDistributor:Array):void
		{
			if(aDistributor.length){
				for each (var newDist:Customer in aDistributor){
					this.bbUploadHeader.shipTo = newDist.shipTo;
					break;
				}
			}
			dispatchEvent(new Event('bbUploadHeaderChanged'));
		}
 
		/*.................operator search......................*/
		// distributor search 
		public function showOperatorSearch():void 
		{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveOperator", saveOperator);
			var winjscommand:String = "/billbacks/search_screens/PM_select_operators.cfm?Formname=flex&FlexAppName="+currentAppName+"&SelectSingleSearchResultOnly=1&flexModule=upload";
			var jscommand:String = "window.open('"+winjscommand+"', 'operatorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		// distributor search return
		public function saveOperator(sOperatorID:String):void 
		{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_OPERATOR);
			e.operatorId = sOperatorID;  
			this._dispatcher.dispatchEvent(e);
		}
		
		public function setOperatorInfo(aOperator:Array):void
		{
			if(aOperator.length){
				for each (var newOpr:Operator in aOperator){
					this.bbUploadHeader.operatorLegacyID = newOpr.ID;
					break;
				}
			}
			dispatchEvent(new Event('bbUploadHeaderChanged'));
		}		
		
		public function setObjBBToolsLock(obj:Lock):void
		{
			var oBBToolsLock:BBToolsLock = new BBToolsLock();
			
			if(obj.bLocked == true && this.bbUploadHeader.lockedByOther == false){
				oBBToolsLock.bBBUploadEditScreenEnabled = true;
			}
			else{
				oBBToolsLock.bBBUploadEditScreenEnabled = false;
			}
			
			// Inside the "objBBToolsLock" function, we trigger the call to build the menu
			var e2:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SET_BB_TOOLS_LOCK);
			e2.bbToolsLock = oBBToolsLock;
			this._dispatcher.dispatchEvent(e2);
			
			//this.objBBToolsLock = oBBToolsLock;
			
			/* Lock/Unlock the grid. */
			var e1:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SET_GRID_LOCK_UNLOCK);
			e1.lockIt = oBBToolsLock.bBBUploadEditScreenEnabled;
			this._dispatcher.dispatchEvent(e1);
		}
		
		public function callobjBBToolsLock(obj:BBToolsLock):void{
			this.objBBToolsLock = obj;
		}
	}
}