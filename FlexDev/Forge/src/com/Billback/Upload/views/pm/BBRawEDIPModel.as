package com.Billback.Upload.views.pm
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Upload.events.BBUploadEvent;
	import com.Billback.Upload.models.vos.BBUploadLog;
	import com.Billback.Upload.views.BBUploadHistoryForm;
	// import com.Billback.Upload.views.BBRawEDIGrid;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.components.filters.FilterDatagrid;
	import com.shared.events.MainEvent;
	import com.shared.components.MenuItem;
	import com.shared.vos.Settings;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import com.Billback.Upload.views.pm.BBRawEDIFilterPModel;
	import com.Billback.Upload.models.vos.BBRawEDIFilterParams;
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import mx.events.MenuEvent;
	import flash.net.URLRequest;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.navigateToURL;
	
	
	public class BBRawEDIPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		
		public function BBRawEDIPModel( dispatcher:IEventDispatcher ):void
		{
			//dispatcher:IEventDispatcher;  
			this._dispatcher = dispatcher;
		}
		
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var arrBBRawEDI:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var arrBBCreated:Array = new Array();
		/*[Bindable]
		public var bbUploadHeader:BBUploadHeader = new BBUploadHeader();*/
		[Bindable]
		public var arrBBCorrectionsDgCols:Array = new Array();
		[Bindable]
		public var iFrmHeight:int = 20;
		//UPLAOD HISTORY
		[Bindable]
		public var arrBBRawEDIHeaderDgCols:Array = new Array();
		[Bindable]
		public var bbUploadLog:BBUploadLog;
		[Bindable]
		public var sFileData:String = '';
 		
		private var _objBBFilterParams:BBRawEDIFilterParams = new BBRawEDIFilterParams();
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
		public var objBBFilterParams:BBRawEDIFilterParams = new BBRawEDIFilterParams();
 
		
		private var _acEDIDMenuData:ArrayCollection = new ArrayCollection();
		/* [Bindable]
		public var bbRawEDIGrid:BBRawEDIGrid; 
		*/
		
		/*.................arrBBUploadHistory......................*/
/*		private var _arrBBRawEDI:Array = new Array();
		[Bindable (event="arrBBRawEDIChange")]
		public function get arrBBRawEDI():Array
		{
			return _arrBBRawEDI;
		}
		public function set arrBBRawEDI(arr:Array):void
		{
			this._arrBBRawEDI = arr;	
			selectHistory(arr[0]);
			dispatchEvent(new Event("arrBBRawEDIChange"));
		}
	*/	
		
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
		//	this.setArrHeaderError();
		//	this.calcVolume();
		}
		
		
 		public function updatePayableNumber(payableNumber:String):void
		{	
			
		//	Alert.show("in payableNumber: " + payableNumber);
		//	Alert.show("in BBNumberKeyword: " +this.objBBFilterParams.BBNumberKeyword);
			this.objBBFilterParams.BBNumberKeyword = payableNumber;
		}
 
		
/*		public function selectCorrection(bbUploadHeader:BBUploadHeader):void{
			//edit the selected row
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB_UPLOAD);
			e.bbUploadHeader = bbUploadHeader;
			this._dispatcher.dispatchEvent(e);
		}
*/		
/*		public function selectHistory(bbUploadLog:BBUploadLog):void{
			//edit the selected row
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.SELECT_BB_UPLOAD_LOG);
			e.bbUploadLog = bbUploadLog;
			this._dispatcher.dispatchEvent(e);
			//this.bbUploadLog = bbUploadLog;
		}*/
 
		
		public function closeRawEDIDetail():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB_RAW_EDI_DETAIL);
			e.bbRawEDIHeader = this.bbRawEDIHeader;
			this._dispatcher.dispatchEvent(e);
		}	
 
		public function downloadMenuEDIFile():void{
			var BBNumber:String = this.bbRawEDIHeader.BBNumber;
			var textFilter:FileFilter = new FileFilter("CSV Files (*.csv)", "*.csv");
			try {
				// The path below is also hardcoded in the CFC file  - CF way to download file IBBUpload 
				var winjscommand:String = "/downloadEDIFile.cfm?BBNumber=" + BBNumber;
				var jscommand:String = "window.open('"+winjscommand+"', 'FileDownload', 'height=200,width=350,toolbar=no,scrollbars=yes,resizable=yes');"
				var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
				navigateToURL(url,'_self');
			} catch (err:*) {
				Alert.show('Unable to download the file.' + winjscommand,'Download Error');
			}
		}
		
/*		public function refreshCorrectionsData():void{
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
		}*/
		
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
		
		public function deleteSelected():void
		{
			var winAlert:Alert;
			winAlert = Alert.show('Are you sure you want to delete selected record(s)?', "Confirm", Alert.OK | Alert.CANCEL,this as Sprite, alertCapturer, null, Alert.OK);
		}

		/*.................menu data......................*/
		[Bindable (event="menuDataChanged")]
		public function get acEDIDMenuData():ArrayCollection{
			return _acEDIDMenuData;
		}
	
		public function set acEDIDMenuData(ac:ArrayCollection):void{
		 
			_acEDIDMenuData = new ArrayCollection();
			_acEDIDMenuData.addItem(new MenuItem("Close", closeRawEDIDetail));
			_acEDIDMenuData.addItem(new MenuItem("Download", downloadMenuEDIFile));
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
		public function menuOverHandler(event:Event):void {
			
			if (event.target.hasOwnProperty('data')){  
				if(event.target.data.label == 'actions'){
					this.menuHandler(event);
				}	 }
		}
		
		public function alertCapturer(eventObj:CloseEvent):void {
			// Check to see if the OK button was pressed.
			var lsUploadIds:String = "";
			if (eventObj.detail==Alert.OK){
				//loop through the data provider to check for selected records
				for(var i:uint = 0; i < this.arrBBRawEDI.length; null ){
					var obj:Object = Object(this.arrBBRawEDI[i])
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
						this.arrBBRawEDI.removeItemAt(this.arrBBRawEDI.getItemIndex(obj));
					}
					else {
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