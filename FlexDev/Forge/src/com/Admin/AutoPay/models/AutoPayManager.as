package com.Admin.AutoPay.models
{
	import com.Admin.AutoPay.events.AutoPayEvent;
	import com.Admin.AutoPay.models.vos.Actions;
	import com.Admin.AutoPay.models.vos.AutoPayDetail;
	import com.Admin.AutoPay.models.vos.SearchParms;
	import com.Admin.AutoPay.models.vos.Totals;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	
	public class AutoPayManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function AutoPayManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		
		/*.................acAutoPay......................*/
		private var _acAutoPay:ArrayCollection = new ArrayCollection();
		[Bindable (event="acAutoPayChanged")]
		public function get acAutoPay():ArrayCollection
		{
			return _acAutoPay;
		}
		public function set acAutoPay(ac:ArrayCollection):void
		{			
			this._acAutoPay = ac;
			this.calculateTotals(new MainEvent(MainEvent.FILTER_DATAGRID_COMPLETE));
			dispatchEvent(new Event('acAutoPayChanged'));
			
			/*this.autoPayDetail = acAutoPay[0] as AutoPayDetail;
			//update the auto Pay Report info
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.GET_REPORT_SUMMARY);
			evt.searchParms.reportId = this.autoPayDetail.reportId;
			this._dispatcher.dispatchEvent(evt);*/
			
		}
		/*.................autoPayDetail......................*/
		private var _autoPayDetail:AutoPayDetail = new AutoPayDetail();
		[Bindable (event="autoPayDetailChanged")]
		public function get autoPayDetail():AutoPayDetail
		{
			return _autoPayDetail;
		}
		public function set autoPayDetail(apd:AutoPayDetail):void
		{			
			this._autoPayDetail = apd;
			dispatchEvent(new Event('autoPayDetailChanged'));
			
		}
		/*.................actions......................*/
		private var _actions:Actions = new Actions();
		[Bindable (event='actionsChanged')]
		public function get actions():Actions
		{
			return _actions;
		}
		public function set actions(act:Actions):void
		{			
			this._actions = act;
			dispatchEvent(new Event('actionsChanged'));	
		}
		/*.................searchParms......................*/
		private var _searchParms:SearchParms = new SearchParms();
		[Bindable (event="searchParmsChanged")]
		public function get searchParms():SearchParms
		{
			return _searchParms;
		}
		public function set searchParms(sp:SearchParms):void
		{			
			this._searchParms = sp;
			dispatchEvent(new Event('searchParmsChanged'));	
		}
		/*.................totals......................*/
		private var _totals:Totals = new Totals();
		[Bindable (event="totalsChanged")]
		public function get totals():Totals
		{
			return _totals;
		}
		public function set totals(t:Totals):void
		{			
			this._totals = t;
			dispatchEvent(new Event('totalsChanged'));	
		}
		[Bindable]
		public var objSelectedReport:Object;
		//[Bindable]
		//public var actions:Actions = new Actions();
		/*.................lock......................*/
		private var _lock:Lock = new Lock();
		[Bindable (event="lockChanged")]
		public function get lock():Lock
		{
			return _lock;
		}
		public function set lock(lock:Lock):void
		{			
			this._lock = lock;
			this._lock.objIdLockedDesc = '[READ ONLY MODE] ' + lock.userLocked.fullName + ' Lock The Auto Pay Report Admin Tool For Exclusive Processing.';
			this.actions.bEditMode = false;
			if(lock.bLocked){
				//Locked by Me
				if(this.lock.userLocked.id == this.oSettings.userId){
					this._lock.objIdLockedDesc = '[EDIT MODE] Locked by ' + lock.userLocked.fullName;
					actions.bEditMode = true;
				}
					//locked by another user
				else{
					this._lock.objIdLockedDesc = '[READ ONLY MODE] Locked by ' + lock.userLocked.fullName;
				}
			}
			dispatchEvent(new Event('lockChanged'));
		}
		
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here: ' +  ObjectUtil.toString(x) );
			
		}
		public function getAutoPayResults(arr:Array):void{
			var apd:AutoPayDetail = new AutoPayDetail();
			this.acAutoPay = new ArrayCollection(arr);
		}
		
		public function setSearchParms(sp:SearchParms):void{
			this.searchParms = sp;
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.GET_DATA);
			evt.searchParms = sp;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function getReportSummaryResults(obj:*):void{
			if(obj.ID != ''){
				this.objSelectedReport = obj;
				this.autoPayDetail.reportStatus.id = obj.STATUS;
				//Need Actions OBJECT -> list of bools to turn actions on and off
				// decide which actions are available
				this.actions.setPermissions(this.autoPayDetail.reportStatus.id, this.autoPayDetail.reportId);
				dispatchEvent(new Event('actionsChanged'));
				dispatchEvent(new Event('autoPayDetailChanged'));
			}
			
		}
		
		public function selectRow(apd:AutoPayDetail):void
		{			
			//Alert.show('here: ' +  ObjectUtil.toString(e.itemRenderer.data) );//e.itemRenderer.data
			this.autoPayDetail = apd;
			//update the auto Pay Report info
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.GET_REPORT_SUMMARY);
			evt.searchParms.reportId = this.autoPayDetail.reportId;
			this._dispatcher.dispatchEvent(evt);
			
		}
		
		public function approveAutoPayReportResult(reportId:Number):void{
			var apd:AutoPayDetail;
			//Then Load the new/edited Report from the server
			getReportByID(reportId);
		}
		
		public function deleteAutoPayReportResult(reportId:Number):void{
			var apd:AutoPayDetail;
			//report is gone fron db now, so remove the report from the grid
			for (var i:int = this.acAutoPay.length - 1; i >= 0; i--) {
				apd = this.acAutoPay.getItemAt(i) as AutoPayDetail;
				if(apd.reportId == reportId){
					this.acAutoPay.removeItemAt(i);
				}
			}
			//select the top row (after delete)
			if(this.acAutoPay.length){
				this.acAutoPay.refresh();
				this.selectRow(this.acAutoPay[0] as AutoPayDetail);
			}
			else{
				//get all reports
				getReportByID(0);
			}
			
		}
		
		public function runAutoPayReportResult(obj:Object):void{
			var apd:AutoPayDetail;
			// After a report runs we need to unlock the ui
			// so another report can get processed
			getReportLockResult(obj.LOCK);
		}
		
		public function updateReportById(event:AutoPayEvent):void{
			//after a report is run we update all of the reords for that report.
			//  First remove them, then add the array of AutoPayDetail to the dp.
			var apd:AutoPayDetail;
			for (var i:int = this.acAutoPay.length - 1; i >= 0; i--) {
				apd = this.acAutoPay.getItemAt(i) as AutoPayDetail;
				if(apd.reportId == event.reportId){
				this.acAutoPay.removeItemAt(i);
				}
			}
			this.acAutoPay.addAll(new ArrayCollection(event.arr));
		}
		
		public function copyEditAutoPayReport(e:AutoPayEvent):void{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			//register the callback method so we know when copyEdit() is done
			if (ExternalInterface.available)
				ExternalInterface.addCallback("copyEditReportCallBack", copyEditReportCallBack);
			//Open the popup window
			var winjscommand:String ="/billbacks/Auto_BB_Report/BB_Auto_Report_Create_Report.cfm?Report_ID="+e.searchParms.reportId+"&Action="+e.sAction+"&fx=1&FlexAppName="+currentAppName;
			var jscommand:String = "window.open('"+winjscommand+"','AutoPay','height=400,width=800,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes,status=1');"   
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");
		}
		
		public function copyEditReportCallBack(reportId:Number):void{
			//set the report ID of SearchParams to the current edit/copy/create id
			//Then Load the new/edited Report from the server
			getReportByID(reportId);
			
		}
		
		public function getReportByID(reportId:Number):void{
			
			//populate the searchParms Object
			var sp:SearchParms = new SearchParms(this.searchParms);
			sp.reportId = reportId
			//dispatch the event. The Set_Serach_Parms event in turn fires GET_DATA (from server)
				// based on the search parms
			var ape:AutoPayEvent = new AutoPayEvent(AutoPayEvent.SET_SEARCH_PARMS);
			ape.searchParms = sp;
			this._dispatcher.dispatchEvent(ape);
		}
		
		public function getReportLockResult(lock:Lock):void{
			this.lock = lock;
		}
		
		public function exportUniversal(e:AutoPayEvent):void{
			//Open the popup window
			var winjscommand:String ="/billbacks/Auto_BB_Report/BB_Auto_Report_Export_Universal.cfm?ReportID="+e.searchParms.reportId+"&Disp=detail&Del=0";
			var jscommand:String = "window.open('"+winjscommand+"','AutoPay','height=500,width=700,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes,status=1');"   
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");
		}


		
		public function calculateTotals(e:MainEvent):void{;
			this.totals.bbAmount = 0;
			this.totals.recaptureAmount = 0;
			this.totals.deviationAmount = 0;
			
			this.totals.billbackCount = 0;
			this.totals.programCount = 0;
			this.totals.reportCount = 0;
			
			var arrB:Array = new Array();
			var arrP:Array = new Array();
			var arrR:Array = new Array();
			
			for each(var o:AutoPayDetail in this.acAutoPay){
				if(o.bbAmount && !isNaN(o.bbAmount)){
					this.totals.bbAmount+=  Number(o.bbAmount);
					this.totals.recaptureAmount += Number(o.pullbackAmount);
					this.totals.deviationAmount += Number(o.deviationAmount);
					//if not tallied yet, increment
					if(arrB.indexOf(o.bbCode) == -1){
						arrB.push(o.bbCode);
						this.totals.billbackCount += 1;
					}
					//if not tallied yet, increment
					if(arrP.indexOf(o.contractId) == -1){
						arrP.push(o.contractId);
						this.totals.programCount += 1;
					}
					//if not tallied yet, increment
					if(arrR.indexOf(o.reportId) == -1){
						arrR.push(o.reportId);
						this.totals.reportCount += 1;
					}	
				}
				else{
					o.bbAmount = 0//here
				}
			}
			//fire setter
			this.totals = new Totals(this.totals);
			//select the first row
			if(this.acAutoPay.length){
				this.selectRow(this.acAutoPay[0] as AutoPayDetail);
			}
			
		}
	}
}