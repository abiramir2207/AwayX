package com.Billback.Upload.views.pm
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Upload.events.BBUploadEvent;
	import com.Billback.Upload.models.vos.BBRawEDIFilterParams;
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.Billback.Upload.models.vos.BBUploadLog;
	import com.Billback.Upload.views.BBRawEDIGrid;
	import com.Billback.Upload.views.BBUploadHistoryForm;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.components.filters.FilterDatagrid;
	import com.shared.events.MainEvent;
	import com.shared.vos.Settings;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.DateField;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.formatters.DateFormatter;
	import mx.utils.ObjectUtil;
	
	public class BBCorrectionsPModel extends EventDispatcher
	{
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var arrBBCorrections:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var arrBBRawEDI:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var arrBBRawEDIDgCols:Array = new Array();
		[Bindable]
		public var arrBBCreated:Array = new Array();
		[Bindable]
		public var bbUploadHeader:BBUploadHeader = new BBUploadHeader();
		[Bindable]
		public var arrBBCorrectionsDgCols:Array = new Array();
		[Bindable]
		public var iFrmHeight:int = 20;
		//UPLAOD HISTORY
		[Bindable]
		public var arrBBUploadHistoryDgCols:Array = new Array();
		[Bindable]
		public var bbUploadLog:BBUploadLog;
		[Bindable]
		public var sFileData:String = '';
		
		public static const millisecondsPerDay:int = 1000 * 60 * 60 * 24;
		// sets the start date to today - 1.5 year
		[Bindable]
		//public var startDate:Date = new Date(new Date().getTime() - (534 * millisecondsPerDay)); 
		public var startDate:Date = new Date(); 
		[Bindable]
		public var endDate:Date = new Date();
		[Bindable]	
		public var bbCorrectionsDate:String = new String();
		[Bindable]	
		public var bbUploadDate:String = new String();
		[Bindable]	
		public var bBtnRefreshEnabled:Boolean;
		[Bindable]	
		public var bBtnSearchEnabled:Boolean;
		[Bindable]
		public var objBBFilterParams:BBRawEDIFilterParams = new BBRawEDIFilterParams();
		
		public var _dtFormatDateTime:DateFormatter = new DateFormatter();
		public var _DateField:DateField = new DateField();
		/*.................arrBBUploadHistory......................*/
		private var _arrBBUploadHistory:Array = new Array();
		[Bindable (event="arrBBUploadHistoryChange")]
		public function get arrBBUploadHistory():Array
		{
			return _arrBBUploadHistory;
		}
		public function set arrBBUploadHistory(arr:Array):void
		{
			this._arrBBUploadHistory = arr;	
			selectHistory(arr[0]);
			dispatchEvent(new Event("arrBBUploadHistoryChange"));
		}
		
		/*.................BBRawEDIFilterParams......................*/
		private var _bbRawEDIFilterParams:BBRawEDIFilterParams = new BBRawEDIFilterParams();
		[Bindable (event="bbRawEDIFilterParamsChanged")]
		public function get bbRawEDIFilterParams():BBRawEDIFilterParams
		{
			return _bbRawEDIFilterParams;
		}
		public function set bbRawEDIFilterParams(bbRawEDIFilterParams:BBRawEDIFilterParams):void
		{
			this._bbRawEDIFilterParams = bbRawEDIFilterParams;
			dispatchEvent(new Event('bbRawEDIFilterParamsChanged'));
		}
		
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBCorrectionsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		public function selectCorrection(bbUploadHeader:BBUploadHeader):void{
			//edit the selected row
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB_UPLOAD);
			e.bbUploadHeader = bbUploadHeader;
			this._dispatcher.dispatchEvent(e);
		}
		
		/* EDI Selection */
		public function selectEDIRow(selRow:Object):void
		{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.LOAD_BB_RAW_EDI_DETAIL);
			var bbRawEDIHdr:BBRawEDIHeader = new BBRawEDIHeader();
			var strDateVal:String = selRow.Claim_Date;
			bbRawEDIHdr.UploadID 			= selRow.Upload_ID;
			bbRawEDIHdr.BBUploadIIIPHID 	= selRow.Billback_Upload_III_PH_ID;	
			bbRawEDIHdr.BBNumber 			= selRow.Claim_Num; 
			bbRawEDIHdr.BBDate 				= DateField.stringToDate(strDateVal,"MM/DD/YYYY"); 
			bbRawEDIHdr.vendorNumber 		= selRow.Vendor_ID; 
			bbRawEDIHdr.vendorName 			= selRow.Vendor_Name; 
			bbRawEDIHdr.payeeNumber 		= selRow.Distributor_ID;
			bbRawEDIHdr.payeeName 			= selRow.Distributor_Name;
			bbRawEDIHdr.agreementNumber 	= selRow.Agreement_Num;
			bbRawEDIHdr.agreementName 		= selRow.Agreement_Name;
			bbRawEDIHdr.ETotalClaimedAmt 	= selRow.E_Total_Claimed_Amt;
			bbRawEDIHdr.TotVolume 			= selRow.Tot_Volume;
			bbRawEDIHdr.DeletedBy 			= selRow.Deleted_By;
			bbRawEDIHdr.DeletedDate 		= DateField.stringToDate(selRow.Deleted_Date,"MM/DD/YYYY"); 
			
			
			e.bbRawEDIHeader = bbRawEDIHdr;
			this._dispatcher.dispatchEvent(e);
		// Alert.show(ObjectUtil.toString(selRow);
		 
		}	
		
		/**************   Show EDI Vendor Search  *******************/
		
		public function showEDIVendorSearch():void 
		{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveVendor", saveEDIVendor);
			var winjscommand:String = "/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=flex&FlexAppName="+currentAppName+"&RebateRecipient_On=1&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch";
			var jscommand:String = "window.open('"+winjscommand+"', 'vendorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// Handle vendor search pop up return
		public function saveEDIVendor(id:String,name:String):void 
		{
			this.objBBFilterParams.vendorName = name;
		}		
		
		public function selectHistory(bbUploadLog:BBUploadLog):void{
			//edit the selected row
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SELECT_BB_UPLOAD_LOG);
			e.bbUploadLog = bbUploadLog;
			this._dispatcher.dispatchEvent(e);
			//this.bbUploadLog = bbUploadLog;
		}
		/*public function resetFilter(dg:FilterDatagrid):void{
			dg.resetFilters();
		}
		public function displayHeaderOptions(dg:FilterDatagrid,bFilter:Boolean,bEdit:Boolean):void{
			//var ac:ArrayCollection = dg.dataProvider as ArrayCollection;
			//ac.disableAutoUpdate();
			dg.displayHeaderOptions(bFilter,bEdit);
		}*/
		public function uploadFile():void{
			var e:MainEvent = new MainEvent(MainEvent.UPLOAD_FILE);
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			e.sURL = oSettings.sURL + '/flex/com/Billback/Upload/uploadOneFile.cfm';
			this._dispatcher.dispatchEvent(e);
		}
		public function refreshCorrectionsData():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_BB_CORRECTIONS);
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			this._dispatcher.dispatchEvent(e);
		}
		public function refreshUploadHistoryData():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_BB_UPLOAD_HISTORY);
			this.bBtnRefreshEnabled = false;
			e.dtStart = this.startDate;
			e.dtEnd = this.endDate;
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			this._dispatcher.dispatchEvent(e);
		}

		
		public function getCreatedBillbacks():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_CREATED_BILLBACKS);
			e.uploadId = this.bbUploadLog.uploadID;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function bbHeaderLabelFunc(obj:Object):String{
			var bbh:BBHeader;
			var s:String;
			if(obj){
				bbh = obj as BBHeader;
				if(bbh){
					s = bbh.BBCode;
				}
				else{
					s = obj.toString();
				}
			}
			return s;
		}
		//NOT USED :: READER CAN NOT READ .XLSX FILES
		public function readFile():void{
			var sFileName:String = this.bbUploadLog.headerFileName;
			var e:MainEvent = new MainEvent(MainEvent.READ_FILE);
			var s:String = this.oSettings.appSettings.bbUploadFilePath + sFileName;
			e.sURL = oSettings.sURL + s;
			this._dispatcher.dispatchEvent(e);
			
		}
		
		public function downloadFile(sFileName:String = ''):void{
			if(!sFileName.length){
				sFileName = this.bbUploadLog.headerFileName;
			}
			var e:MainEvent = new MainEvent(MainEvent.DOWNLOAD_FILE);
			var s:String = this.oSettings.appSettings.bbUploadFilePath + sFileName;
			e.sState = sFileName;
			e.sURL = oSettings.sURL + s;// + sfileName;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function selectBB(bbH:BBHeader):void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB);
			e.bbHeader = bbH;
			//	e.reDirector = reDirector;
			//oSettings.sBBDeviationSource = '';
			e.payeeList = new Array(bbH.payee);
			//e.closingMethodList = objLookupData.closingMethodList; // Send in the closingMethod List too for the edit screen dropdown instead of loading from CF.
			//e.bbAnalysts = objLookupData.analystList; // Send in the analysts List too for the edit screen dropdown instead of loading from CF.
			this._dispatcher.dispatchEvent(e);
		}
		
		public function dtStartHandler(dt:Date):void{
			this.startDate = dt
		}
		
		public function dtEndHandler(dt:Date):void{
			this.endDate = dt;
		}
		
		// Function for Raw EDI
		
		public function searchBBRawEDIData():void{
			
			if (this.objBBFilterParams.BBNumberKeyword == "" && this.objBBFilterParams.BBDateKeyboard == null && 
				this.objBBFilterParams.vendorNumber == "" &&
				this.objBBFilterParams.vendorName == "" &&
				this.objBBFilterParams.payeeNumber == "" &&
				this.objBBFilterParams.payeeName == "" &&
				this.objBBFilterParams.agreementNumber == "" &&
				this.objBBFilterParams.agreementName == "")
				{
					Alert.show("Please Enter a search criteria!", "Raw EDI Search Alert!!");
				}
			else
			{	
				this.bBtnSearchEnabled = false;
				var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.LOAD_RAW_EDI_DATA_SEARCH);
				e.oBBEDIFilterParams = this.objBBFilterParams;
				this._dispatcher.dispatchEvent(e);
			}
		}
			
		public function updatePayableNumber(payableNumber:String):void{
			this.objBBFilterParams.BBNumberKeyword = payableNumber;
		}
		
		public function updatePayableDate(dtBBDate:Date):void{
			this.objBBFilterParams.BBDateKeyboard = dtBBDate;
		}
		
		public function updateVendorId(vendorNumber:String):void{
			this.objBBFilterParams.vendorNumber = vendorNumber;
		}

		public function updateVendorName(vendorName:String):void{
			this.objBBFilterParams.vendorName = vendorName;
		}

		public function updatePayeeNumber(payeeNumber:String):void{
			this.objBBFilterParams.payeeNumber = payeeNumber;
		}

		
		public function updatePayeeName(payeeName:String):void{
			this.objBBFilterParams.payeeName = payeeName;
		}

		public function updateAgreementNumber(agreementNumber:String):void{
			this.objBBFilterParams.agreementNumber = agreementNumber;
		}
		
		public function updateAgreementName(agreementName:String):void{
			this.objBBFilterParams.agreementName = agreementName;
		}
		
		public function deleteSelected():void
		{
			var winAlert:Alert;
			winAlert = Alert.show('Are you sure you want to delete selected record(s)?', "Confirm", Alert.OK | Alert.CANCEL,this as Sprite, alertCapturer, null, Alert.OK);
		}

		public function alertCapturer(eventObj:CloseEvent):void {
			// Check to see if the OK button was pressed.
			var lsUploadIds:String = "";
			if (eventObj.detail==Alert.OK){
				//loop through the data provider to check for selected records
				for(var i:uint = 0; i < this.arrBBCorrections.length; null ){
					var obj:Object = Object(this.arrBBCorrections[i])
					//remove from the dataprovider if a record was selected
					if(obj.isSelected == true){
						if (lsUploadIds != "")
						{
							// lsUploadIds = lsUploadIds + "," + obj.uploadID;
							lsUploadIds = lsUploadIds + "," + obj.bbHeaderID;
						}	
						else
						{
							// lsUploadIds = obj.uploadID;
							lsUploadIds = obj.bbHeaderID;
						}
						this.arrBBCorrections.removeItemAt(this.arrBBCorrections.getItemIndex(obj));
					}
					else{
						i++;
					}
				}
				var e:MainEvent = new MainEvent(MainEvent.DELETE_CORRECTION_ROW);
				e.uploadIDList = lsUploadIds;
				this._dispatcher.dispatchEvent(e);
			}
		}
		
	}
}