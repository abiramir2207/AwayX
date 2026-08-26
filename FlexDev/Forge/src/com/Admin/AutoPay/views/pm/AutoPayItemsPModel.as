package com.Admin.AutoPay.views.pm
{
	import com.Admin.AutoPay.events.AutoPayEvent;
	import com.Admin.AutoPay.models.vos.Actions;
	import com.Admin.AutoPay.models.vos.AutoPayDetail;
	import com.Admin.AutoPay.models.vos.Totals;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	public class AutoPayItemsPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function AutoPayItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}	
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var arrAutoPayItemsDgCols:Array = new Array();
		[Bindable]
		public var totals:Totals;
		[Bindable]
		public var objSelectedReport:Object;
		[Bindable]
		public var lock:Lock;
		
		/*.................actions......................*/
		private var _actions:Actions = new Actions();
		[Bindable (event="actionsChanged")]
		public function get actions():Actions
		{
			return _actions;
		}
		public function set actions(act:Actions):void
		{			
			this._actions = act;
			dispatchEvent(new Event('actionsChanged'));	
		}
		
		/*.................acAutoPay......................*/
		private var _acAutoPay:ArrayCollection = new ArrayCollection();
		[Bindable (event="acAutoPayPMIChanged")]
		public function get acAutoPay():ArrayCollection
		{
			return _acAutoPay;
		}
		public function set acAutoPay(ac:ArrayCollection):void
		{			
			this._acAutoPay = ac;
			dispatchEvent(new Event('acAutoPayPMIChanged'));	
		}
		/*.................autoPayDetail......................*/
		private var _autoPayDetail:AutoPayDetail = new AutoPayDetail();
		[Bindable (event="autoPayDetailPMIChanged")]
		public function get autoPayDetail():AutoPayDetail
		{
			return _autoPayDetail;
		}
		public function set autoPayDetail(apd:AutoPayDetail):void
		{			
			this._autoPayDetail = apd;
			dispatchEvent(new Event('autoPayDetailPMIChanged'));
			
		}
		public function selectRow(apd:AutoPayDetail):void
		{			
			//Alert.show('here: ' +  ObjectUtil.toString(e.itemRenderer.data) );//e.itemRenderer.data
			this.autoPayDetail = apd;
			//update the auto Pay Report info
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.SELECT_ROW);
			evt.autoPayDetail = apd;
			this._dispatcher.dispatchEvent(evt);
			
		}
		
		public function approveReport(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.APPROVE_AUTO_PAY_REPORT);
			evt.searchParms.reportId = n;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function deleteReport(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.DELETE_AUTO_PAY_REPORT);
			evt.searchParms.reportId = n;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function copyReport(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.COPY_AUTO_PAY_REPORT);
			evt.searchParms.reportId = n;
			evt.sAction = 'copy';
			this._dispatcher.dispatchEvent(evt);
		}
		public function editReport(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.EDIT_AUTO_PAY_REPORT);
			evt.searchParms.reportId = n;
			evt.sAction = 'edit';
			this._dispatcher.dispatchEvent(evt);
		}
		public function runReport(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.RUN_AUTO_PAY_REPORT);
			evt.searchParms.reportId = n;
			this._dispatcher.dispatchEvent(evt);
		}
		public function exportUniversal(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.EXPORT_UNIVERSAL);
			evt.searchParms.reportId = n;
			this._dispatcher.dispatchEvent(evt);
		}
	
	}
}