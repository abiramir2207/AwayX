package com.Billback.Upload.views.pm
{
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Upload.events.BBUploadEvent;
	import com.Billback.Upload.models.vos.BBUploadDetail;
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.Billback.Upload.models.vos.BBUploadHeaderError;
	import com.shared.components.MenuItem;
	import com.shared.components.StringUtils;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import com.Billback.Upload.models.vos.BBRawEDIFilterParams;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DateField;
	import mx.controls.Menu;
	import mx.events.MenuEvent;
	import mx.utils.ObjectUtil;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class BBUploadPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBUploadPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		
		/*.................oSettings......................*/
		[Bindable] public var oSettings:Settings = new Settings();
		//[Bindable] //public var bbUploadHeader:BBUploadHeader = new BBUploadHeader();
		[Bindable] public var iFrmHeight:int = 20;
		[Bindable] public var formatString:String = 'MM/DD/YYYY';
		[Bindable] public var nVolume:Number = 0;
		[Bindable] public var btnBBLockLabel:String= "edit";
		[Bindable] public var sBBLockMsgText:String= "";
		[Bindable] public var objBBToolsLock:BBToolsLock = new BBToolsLock();
		[Bindable] public var nHeightContainer:Number = 210;		
		[Bindable] public var nWidthContainer:Number = 1025;
		
		[Bindable]
		public var objBBFilterParams:BBRawEDIFilterParams = new BBRawEDIFilterParams();
		
		private var _bbLock:Lock = new Lock();
		private var _acMenuData:ArrayCollection = new ArrayCollection();
		
		public function getDecimal2(s:String):String
		{
			var s:String = bbUploadHeader.BBAmount;
			if (String(parseFloat(bbUploadHeader.BBAmount)) == bbUploadHeader.BBAmount) {
				s = StringUtils.getDecimal2(bbUploadHeader.BBAmount);
			} 
			else
			{
				var iPointPos:Number = s.indexOf(".");
				var chrToCheck:String = s.substr(iPointPos+3,1);
				var strWholePart:String = s.substr(0,iPointPos);
				var strTwoDecimals:String = s.substr(iPointPos+1,2);
				if (iPointPos != -1)
				{
					if (chrToCheck != "")
					{
						s = strWholePart + "." + strTwoDecimals;
					}
				}
			}
			return s;
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
			this.setArrHeaderError();
			this.calcVolume();
		}
		
		/*...................   sPayeeError  .....................*/
		private var _sPayeeError:String = '';
		[Bindable (event="sPayeeErrorChanged")]
		public function get sPayeeError():String
		{
			return _sPayeeError;
		}
		public function set sPayeeError(inValue:String):void
		{
			_sPayeeError = inValue;
			dispatchEvent(new Event('sPayeeErrorChanged'));
		}
		
		/*...................   arrHeaderError  .....................*/
		private var _arrHeaderError:Array = new Array();
		[Bindable (event="arrHeaderErrorChanged")]
		public function get arrHeaderError():Array
		{
			return _arrHeaderError;
		}
		public function set arrHeaderError(inValue:Array):void
		{
			_arrHeaderError = inValue;
			dispatchEvent(new Event('arrHeaderErrorChanged'));
		}
		
		/*...................   arrDetailError  .....................*/
		/*private var _arrDetailError:Array = new Array();
		[Bindable (event="arrDetailErrorChanged")]
		public function get arrDetailError():Array
		{
		return _arrDetailError;
		}
		public function set arrDetailError(inValue:Array):void
		{
		_arrDetailError = inValue;
		dispatchEvent(new Event('arrDetailErrorChanged'));
		}*/
		
		public function setArrHeaderError():void{
			var arr:Array = new Array();
			var errObj:BBUploadHeaderError = this.bbUploadHeader.errObj; 
			
			var o:Object = ObjectUtil.getClassInfo(errObj);
			for each(var obj:Object in o.properties) {
				var prop:String = obj.localName;
				var s:String = errObj[prop];
				if(s.length){
					arr.push(s);
				}
			}
			this.arrHeaderError = arr;
		}
		
		public function calcVolume():void{
			var arr:Array = new Array();
			var nCalcVolume:Number = 0;
			for each(var bbDtl:BBUploadDetail in this.bbUploadHeader.bbUploadDetail){
				var vol:Number = Number(bbDtl.BBProductQuantity);
				if(! isNaN(vol)){
					nCalcVolume = nCalcVolume + vol;
				}
			}
			//Tim Ford - 03/16/2012: Label Validation Error on Volume in Ecorrection 
			//Not sure if nVolume is getting set from anywhere else so modified calcVolume() to increment local var nCalcVolume
			//if nCalcVolume is not equal to nVolume then set nVolume to nCalcVolume
			if (nVolume != nCalcVolume){
				nVolume = nCalcVolume;	
			}
		}
		
		/* 
			passing a parameter sAction 
			sAction = "1" -- SAVE
			sAction = "2" -- VALIDATE
		*/
		public function validate():void{
			
			gridAndMenuLock();
			
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.VALIDATE);
			//make a copy so we don't overwrite bbUploadDetail property
			e.bbUploadHeader = new BBUploadHeader(this.bbUploadHeader);
			//only send edited rows
			e.bbUploadHeader.bbUploadDetail = this.getEditedDetaisl();
			e.sAction		= "2";
			this._dispatcher.dispatchEvent(e)
		}
		
		public function fnSave():void{
			
			gridAndMenuLock();
			
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.VALIDATE);
			//make a copy so we don't overwrite bbUploadDetail property
			e.bbUploadHeader = new BBUploadHeader(this.bbUploadHeader);
			//only send edited rows
			e.bbUploadHeader.bbUploadDetail = this.getEditedDetaisl();
			e.sAction		= "1";
			this._dispatcher.dispatchEvent(e)
		}
		//returns an array of BBUploadDetail (rows of this.bbUploadHeader.bbUploadDetail with bEdited true)
		private function getEditedDetaisl():Array{
			var arrRet:Array = new Array();
			for each(var bbd:BBUploadDetail in this.bbUploadHeader.bbUploadDetail){
				if(bbd.bEdited){
					arrRet.push(bbd);
				}
			}
			return arrRet;
		}
		
		
		private function deleteConfirm():void
		{
			var alertResult:Alert;			
			alertResult = Alert.show("Are you sure you want to delete this record?", "Confirm Delete!", Alert.YES | Alert.NO, null, deleteRecord);   
		}
		
		public function deleteRecord(CloseEvent:Object):void{			
			/* CloseEvent.detail is 1 for "yes" and 2 for "no" */
			if(CloseEvent.detail == 1){
				/*var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.DELETE_BB_UPLOAD);
				e.bbUploadHeader = this.bbUploadHeader;
				this._dispatcher.dispatchEvent(e);*/
				var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.DELETE_CORRECTION_ROW);
				e.uploadIDList = this.bbUploadHeader.bbHeaderID.toString();
				this._dispatcher.dispatchEvent(e);
			}
			
			/* Once the record is deleted, unlock that record in the db. */
			var e1:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOCK_BB_EDIT);		
				e1.bbHeaderID = this.bbUploadHeader.bbHeaderID;
				e1.userId = this.oSettings.userId;			
				e1.bbtoggle = false;
				/* There is no need to unlock any other records while deleting a record */
				e1.bbUnlockExistingLockedByUser = false;
				/* This will ensure that the resultHandler function does not take any action 
				as in this case only the lock needs to unlock in the db */
				e1.bbClose = true;
				/* unlock the record */
				e1.lockIt = false;
				// send the event 
				this._dispatcher.dispatchEvent(e1);
		}
		
		public function dummyFn():void{
			/* DO NOTHING */
		}
		
		public function closeBB():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB_UPLOAD);
			e.bbUploadHeader = this.bbUploadHeader;
			this._dispatcher.dispatchEvent(e);
			
			// event to unlock
			var e1:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOCK_BB_EDIT);		
			e1.bbHeaderID		 = this.bbUploadHeader.bbHeaderID;
			e1.userId	= this.oSettings.userId;			
			e1.bbtoggle = false;
			e1.bbUnlockExistingLockedByUser = false;
			e1.bbClose = true;
			
			/* If the billback is locked */	
			if(this.bbUploadHeader.locked)
			{
				/* Keep the billback locked */	
				e1.lockIt	= true;	
				
				/* But...if the billback is locked by the person closing the billback  */	
				if(this.bbUploadHeader.lockedUser.id == this.oSettings.userId)
				{
					/* unlock the billback */
					e1.lockIt	= false;	
				}
			}
			// send the event 
			this._dispatcher.dispatchEvent(e1);
		}
		
		public function uploadFile():void{
			var e:MainEvent = new MainEvent(MainEvent.UPLOAD_FILE);
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			e.sURL = this.oSettings.sURL + '/flex/com/Billback/Upload/uploadOneFile.cfm';
			this._dispatcher.dispatchEvent(e);
		}
		
	 	public function getVendorSearch():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_VENDOR_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}		
 
		public function getDistributorSearch():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_DISTRIBUTOR_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}			
		
		public function getOperatorSearch():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_OPERATOR_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}			
		
		/* This is used to open the pop up for the budget screen */
		public function showDuplicates():void
		{
			var jsURL:String = "/billbacks/common/Billback_Dup_Checker.cfm?uploadID="+ this.bbUploadHeader.uploadID.toString() + "&bbHeaderID=" + this.bbUploadHeader.bbHdrCounter.toString();
			var jscommand:String = "window.open('"+ jsURL + "','winDuplicate','height=640,width=900,toolbar=no,scrollbars=yes,resizable=yes');";			
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);"); 
			navigateToURL(url, "_self"); 
		}	
		
		/*..................................................................
		........................ CHANGE HANDLERS ...........................
		....................................................................*/
		
		
		/*......................... COMMON CHANGE HANDLERS ..........................*/
		public function dtFieldDateChange(df:DateField,sProp:String):void{
			var bError:Boolean = false;
			var s:String = '';
			var d:Date;
			var sDate:String = df.value.toString();
			//clear error
			if(df.selectedDate){
				d = df.selectedDate;
			}
			/*else{
			d = new Date(sDate.substr(0,4),sDate.substr(5,2),sDate.substr(7,2));
			}*/
			var nDate:Number = Date.parse(d);
			var toDay:Date = new Date();
			//this.bbUploadHeader.errObj[sProp] = '';
			//upd header
			if(Date.parse(d)){	
				//var m:int = d.month+1
				//s = m.toString() + '/' + d.date.toString() + '/' + d.fullYear.toString();
				s = sDate;
				//switch s and run validations
				switch(df.name)
				{
					case 'invoiceDate':
						if(d > toDay){
							bError = true;
							s = 'invoice date greater than today';
						}
						break;
					case 'receiptDate':
						if(d > toDay){
							bError = true;
							s = ' receipt date greater than today.';
						}
						if( !isNaN(Date.parse(this.bbUploadHeader.endDate)) &&  d < DateField.stringToDate(this.bbUploadHeader.endDate,formatString)){
							bError = true;
							s =  s + ' receipt date greater than end date.';
						}
						break;
					case 'startDate':
						if(d > toDay){
							bError = true;
							s = ' start date greater than today.';
						}
						if( !isNaN(Date.parse(this.bbUploadHeader.endDate)) &&  nDate > Date.parse(this.bbUploadHeader.endDate)){
							bError = true;
							s = ' start date greater than end date.';
						}
						break;
					case 'endDate':
						if(d > toDay){
							bError = true;
							s = ' end date greater than today.';
						}
						if( !isNaN(Date.parse(this.bbUploadHeader.startDate)) &&  nDate < Date.parse(this.bbUploadHeader.startDate)){
							bError = true;
							s = ' end date less than start date.';
						}
						break;
					case 'postmarkDate':
						if(d > toDay){
							bError = true;
							s = ' postmark date greater than today.';
						}
						if( !isNaN(Date.parse(this.bbUploadHeader.endDate)) &&  nDate < Date.parse(this.bbUploadHeader.endDate)){
							bError = true;
							s = ' postmark date less than end date.';
						}
						break;
					default:
						//s = '';
						break;
				}		
			}
			else{
				bError = true;
			}
			//allow nulls (empty string) for these fields
			switch(df.name)
			{
				case 'receiptDate,postmarkDate':
					if(d.toString() == ''){
						bError = false;
					}
					break;
				default:
					//trace("Out of range");
					break;
			}
			
			if(bError){
				s = 'invalid date: ' + s
				setError(s,sProp);
				//this.bbUploadHeader[sProp] = '';
				//this.bbUploadHeader.errObj[sProp] = 'invalid date';
			}
			else{
				
				//this.bbUploadHeader[sProp] = s;
				clearError(s,sProp);
			}
			
		}
		public function tiTextInputChange(s:String,sProp:String):void{
			var bError:Boolean = false;
			var sError:String = 'please enter a valid ' + sProp;
			//switch s and run validations
			switch(s)
			{
				case 'vendor':
					if(s.length < 1){
						bError = true;
					}
					break;
				case 'referenceNumber':
					if(s.length < 1){
						bError = true;
					}
					break;
				case 'payeeType':
					if(s.length < 1){
						bError = true;
					}
					break;
				case 'distributorID':
					if(s.length < 1){
						bError = true;
					}
					break;
				case 'billbackTitle':
					if(s.length < 1){
						bError = true;
					}
					break;
				case 'closingMethod':
					if(s.length < 1){
						bError = true;
					}
					break;
				case 'referenceNum':
					if(s.length < 1){
						bError = true;
					}
					break;
				/*case 'xxx';
				if(s.length < 1){
				bError = true;
				}
				break;*/
				
				default:
					//trace("Out of range");
					break;
			}
			if(bError){
				setError(s,sProp);
			}
			else{
				clearError(s,sProp);
			}
			
		}
		private function setError(s:String,sProp:String):void{
			//set error
			this.bbUploadHeader.errObj[sProp] = s;
			//DON'T upd header
			//this.bbUploadHeader[sProp] = '';
			dispatchEvent(new Event('bbUploadHeaderChanged'));
			setArrHeaderError();
		}
		private function clearError(s:String,sProp:String):void{
			//clear error
			this.bbUploadHeader.errObj[sProp] = '';
			//upd header
			this.bbUploadHeader[sProp] = s;
			dispatchEvent(new Event('bbUploadHeaderChanged'));
			setArrHeaderError();
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
		
		// lock-unlock Billback
		public function toggleBBLock():void{

			// event to lock
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOCK_BB_EDIT);		
			e.bbHeaderID	= this.bbUploadHeader.bbHeaderID;
			e.userId	= this.oSettings.userId;
			e.lockIt	= true;
			e.bbtoggle = true;
			e.bbUnlockExistingLockedByUser = false;
			e.bbClose = false;
			
			//if locked then unlock only when the locked user and this user is same
			if(this.bbUploadHeader.locked && (this.bbUploadHeader.lockedUser.id == this.oSettings.userId)){
				e.lockIt	= false; // unlock										
			}
			
			// send the event 
			this._dispatcher.dispatchEvent(e);
		}
		
		// display the lock-unlock message
		public function displayBBLock():void
		{
			/* The billback is locked by some other user, set it to "read only" mode  */
			if(this.bbUploadHeader.lockedByOther == true){				
				this.btnBBLockLabel = "read-only";
				this.sBBLockMsgText = " (Locked by " + this.BBLock.userLocked.fullName.toUpperCase() + ")";				
			}
				//this.bbUploadHeader.lockedUser.fullName.toUpperCase()
				/* The billback is not locked, set it to "read only" mode */
			else if(this.bbUploadHeader.locked == false){				
				this.btnBBLockLabel = "read-only";
				this.sBBLockMsgText = "";
			}
				
				// unlock
				/* If the billback is locked by the user (not some other user), set it to "edit" mode */
			else{
				this.btnBBLockLabel = "edit";
				this.sBBLockMsgText = "";
			}
		}
		
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
			
			/* get information about "read-only/edit/locked by" */
			displayBBLock();
			
			_acMenuData.addItem(new MenuItem(this.btnBBLockLabel + this.sBBLockMsgText, toggleBBLock));
			
			if(objBBToolsLock.bBBUploadEditScreenEnabled){
				_acMenuData.addItem(new MenuItem("save", fnSave));
			}

			_acMenuData.addItem(new MenuItem("close", closeBB));
			
			if(objBBToolsLock.bBBUploadEditScreenEnabled){
			_acMenuData.addItem(new MenuItem("validate", validate));
			}
			
			if (this.oSettings.appSettings.EnableBBDupCheck)
			{
				_acMenuData.addItem(new MenuItem("EDI Duplicate", showDuplicates));
			}
			
			if(objBBToolsLock.bBBUploadEditScreenEnabled){
				_acMenuData.addItem(new MenuItem("   |   ", dummyFn));
			}
	
			if(objBBToolsLock.bBBUploadEditScreenEnabled){
				_acMenuData.addItem(new MenuItem("delete", deleteConfirm));
			}
			dispatchEvent(new Event('menuDataChanged'));
	
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
			if (event.target.data.menuHandler){
				if (event.target.data.args){
					event.target.data.menuHandler(event.target.data.args);
				}else{
					event.target.data.menuHandler();						
				}
			}
		}
		
		private function gridAndMenuLock():void{			
			/* Disable the grid and hide the menu options as the data is being validated/saved and we do not want the users 
			to take any other action.The grid will be enabled and the menu options like (save,delete,validate) will be 
			available after the validation/save.
			*/
			var e1:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SET_GRID_LOCK_UNLOCK);
			e1.lockIt = false;
			this._dispatcher.dispatchEvent(e1);
			
			var oBBToolsLock:BBToolsLock = new BBToolsLock();	
			oBBToolsLock.bBBUploadEditScreenEnabled = false;
			
			// Inside the "objBBToolsLock" function (BBUploadManager), we trigger the call to build the menu.
			var e2:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SET_BB_TOOLS_LOCK);
			e2.bbToolsLock = oBBToolsLock;
			this._dispatcher.dispatchEvent(e2);			
		}		
	}
}