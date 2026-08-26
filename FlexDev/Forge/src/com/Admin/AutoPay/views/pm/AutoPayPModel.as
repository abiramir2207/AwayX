package com.Admin.AutoPay.views.pm
{
	import com.Admin.AutoPay.events.AutoPayEvent;
	import com.Admin.AutoPay.models.vos.Actions;
	import com.Admin.AutoPay.models.vos.AutoPayDetail;
	import com.Admin.AutoPay.models.vos.SearchParms;
	import com.shared.components.MenuItem;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.MenuEvent;
	import mx.utils.ObjectUtil;
	
	public class AutoPayPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function AutoPayPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			this.acMenuData = new ArrayCollection();
		}
		/*.......................  Properties  .......................*/
		
		[Embed(source="/assets/Images/lock_25.png")]
		public static var iconLock:Class;
		
		[Embed(source="/assets/Images/unLock_25.png")]
		public static var iconUnLock:Class;
		
		public var iconLockCurrent:Class = iconLock;
		private var sLockText:String = '';
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var actions:Actions = new Actions();
		[Bindable]
		public var reportId:String;
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
			
			this.reportId = _searchParms.reportId.toString();
			if(_searchParms.reportId == 0){
				this.reportId = '';
			}
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
			//RESET MENU OPTIONS
			this.acMenuData = new ArrayCollection();
			
		}
		/*.................menu data......................*/
		private var _acMenuData:ArrayCollection = new ArrayCollection();
		[Bindable (event="menuDataChanged")]
		public function get acMenuData():ArrayCollection{
			return _acMenuData;
		}
		
		public function set acMenuData(ac:ArrayCollection):void{
			_acMenuData = new ArrayCollection();
			//_acMenuData.addItem(new MenuItem(this.btnBBLockLabel + this.sBBLockMsgText, toggleBBLock,null,true,'normal',true,'',null,this.sBBLockMsgText));
			
			var menuLock:MenuItem = new MenuItem('', this.toggleLock,null,true,'normal',true,'',iconLockCurrent,this.lock.objIdLockedDesc);
			_acMenuData.addItem(menuLock);
			
			/*var menuRun:MenuItem = new MenuItem("run", test, ['run']);
			_acMenuData.addItem(menuRun);*/
			
			var menuCreate:MenuItem = new MenuItem("create", createReport,null,this.actions.bEditMode,'',true,'',null,'Create a new Auto Pay Report');
			_acMenuData.addItem(menuCreate);
			
			var menuExport:MenuItem = new MenuItem("export", exportUniversal, [this.autoPayDetail.reportId],this.actions.bExport,'',true,'',null,this.actions.sExportTip);
			_acMenuData.addItem(menuExport);
			
			dispatchEvent(new Event('menuDataChanged'));
		}
		
		[Bindable]
		public var bEditMode:Boolean;
		/*.................lock......................*/
		private var _lock:Lock = new Lock();
		[Bindable (event="lockPMChanged")]
		public function get lock():Lock
		{
			return _lock;
		}
		public function set lock(lock:Lock):void
		{			
			this._lock = lock;
			iconLockCurrent = iconLock;
			if(lock.bLocked && this.lock.userLocked.id == this.oSettings.userId){
				//Locked by Me
				iconLockCurrent = iconUnLock;
			}
			dispatchEvent(new Event('lockPMChanged'));
			//reset menuData where icon is stored
			this.acMenuData = new ArrayCollection();
		}
		
		/*.....................................................................*/
		/*.............................  METHODS  .............................*/
		/*.....................................................................*/
		public function test(x:*):void{
			Alert.show('here: ' + ObjectUtil.toString(x) );
			
		}
		
		//**********	menu handlers	**********//
		public function menuItemHandler(event:MenuEvent):void {
			var menuItem:MenuItem =  event.item as MenuItem;
			if(menuItem.enabled){
				if (event.item.args){
					menuItem.menuHandler(event.item.args);	
				}else{
					menuItem.menuHandler();	
				}
			}
		}
		
		public function menuHandler(event:Event):void {
			
			if (event.target.hasOwnProperty('data')){
				if(event.target.data.enabled){
					if (event.target.data.menuHandler){
						if (event.target.data.args){
							event.target.data.menuHandler(event.target.data.args);
						}else{
							event.target.data.menuHandler();						
						}
					}
				}
			}
		}
		
		public function menuOverHandler(event:Event):void {
			
			if (event.target.hasOwnProperty('data') &&  event.target.data.label == 'actions'){
				this.menuHandler(event);
			}
		}
		
		public function toggleLock():void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.GET_REPORT_LOCK);
			this._lock.toggleLock = true;
			evt.lock = this.lock;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function search(r:Number,s:Date,e:Date,i:String):void{
			var sp:SearchParms = new SearchParms();
			sp.dStart = s;
			sp.dEnd = e;
			sp.reportId = r;
			sp.invoiceNumber = i;
			this.searchParms = sp;
			//set searchparms at source (AutoPayMAnager)
			//The handler for SET_SEARCH_PARMS fires the get data.
			var ape:AutoPayEvent = new AutoPayEvent(AutoPayEvent.SET_SEARCH_PARMS);
			ape.searchParms = sp;
			this._dispatcher.dispatchEvent(ape);
		}
		
		public function createReport():void{
			if(this.actions.bEditMode){
				var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.MODIFY_AUTO_PAY_REPORT);
				//evt.searchParms.reportId = n;
				evt.sAction = 'create';
				this._dispatcher.dispatchEvent(evt);
			}
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
		
		public function filterEmptyPayPeriodt(b:Boolean):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.FILTER_EMPTY_PAY_PERIOD);
			evt.b = b;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function exportUniversal(n:Number):void{
			var evt:AutoPayEvent = new AutoPayEvent(AutoPayEvent.EXPORT_UNIVERSAL);
			evt.searchParms.reportId = n;
			this._dispatcher.dispatchEvent(evt);
		}
		
	}
}