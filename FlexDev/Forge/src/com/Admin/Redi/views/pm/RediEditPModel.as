package com.Admin.Redi.views.pm
{
	import com.Admin.AutoPay.events.AutoPayEvent;
	import com.Admin.AutoPay.models.vos.Actions;
	import com.Admin.Redi.events.RediEvent;
	import com.Admin.Redi.models.vos.RediCorrectionHeader;
	import com.Admin.Redi.models.vos.RediSettings;
	import com.Billback.Main.models.vos.BBHeader;
	import com.shared.components.MenuItem;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.Address;
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.CustomerAttr;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.events.MenuEvent;
	
	public class RediEditPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function RediEditPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			//RESET MENU OPTIONS
			//this.acMenuData = new ArrayCollection();
			this.lock = new Lock();
		}
		
		
		/*.......................  Properties  .......................*/
		[Bindable]
		public var iPadding:Number = 0;
		[Bindable]
		public var iWidth:Number = 1028;
		[Bindable]
		public var iHeight:Number = 17;
		[Bindable]
		public var iPaddingfrm:Number = 3;
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var sourceTypes:Array = new Array();
		[Bindable]
		public var rediSettings:RediSettings = new RediSettings();
		/*[Bindable]
		public var bIsLocked:Boolean = true;*/
		[Bindable]
		public var arrRediEditDgCols:Array = new Array();
		
		[Embed(source="/assets/Images/lock_25.png")]
		public static var iconLock:Class;
		
		[Embed(source="/assets/Images/unLock_25.png")]
		public static var iconUnLock:Class;
		
		public var iconLockCurrent:Class = iconLock;
		private var sLockText:String = '';
		
		[Bindable]
		public var actions:Actions = new Actions();
		/*.................rediCorrectionHeader......................*/
		private var _rediCorrectionHeader:RediCorrectionHeader;
		[Bindable (event="pmRediCorrectionHeaderChanged")]
		public function get rediCorrectionHeader():RediCorrectionHeader
		{
			return _rediCorrectionHeader;
		}
		public function set rediCorrectionHeader(rch:RediCorrectionHeader):void
		{
			_rediCorrectionHeader = rch;
			dispatchEvent(new Event('pmRediCorrectionHeaderChanged'));
		}
		/*.................acRediEditItems......................*/
		private var _acRediEditItems:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediEditItemsChanged")]
		public function get acRediEditItems():ArrayCollection
		{
			return _acRediEditItems;
		}
		public function set acRediEditItems(ac:ArrayCollection):void
		{			
			this._acRediEditItems = ac;
			dispatchEvent(new Event('acRediEditItemsChanged'));	
		}
		/*.................arrItemSearch......................*/
		private var _arrItemSearch:Array = new Array();
		[Bindable (event="pmarrItemSearchChanged")]
		public function get arrItemSearch():Array
		{
			return _arrItemSearch;
		}
		public function set arrItemSearch(ac:Array):void
		{			
			this._arrItemSearch = ac;
			dispatchEvent(new Event('pmarrItemSearchChanged'));	
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
			
			var menuCreate:MenuItem = new MenuItem("close", closeCorrection,null,true,'',true,'',null,'Close this redistribution correction.');
			_acMenuData.addItem(menuCreate);
			
			var menuValidate:MenuItem = new MenuItem("validate", validateRedi,null,this.lock.bEditMode,'',true,'',null,'Save and submit this redistribution correction for validation.');
			_acMenuData.addItem(menuValidate);
			/*
			var menuEX:MenuItem = new MenuItem("export");
			menuEX.children = new Array();
			var menuExport:MenuItem = new MenuItem("report data", exportUniversal, [this.autoPayDetail.reportId],this.actions.bExport,'',true,'',null,this.actions.sExportTip);
			var menuExPullback:MenuItem = new MenuItem(this.actions.pullbackLabel + " data", exportPullbacks, [this.autoPayDetail.reportId],this.actions.bExport,'',true,'',null,this.actions.sExportTip);
			menuEX.children.push(menuExport);
			menuEX.children.push(menuExPullback);
			_acMenuData.addItem(menuEX);*/
			
			dispatchEvent(new Event('menuDataChanged'));
		}
		[Bindable]
		public var bEditMode:Boolean;
		
		public function getFinalBuyerAliasAddress():String{
			var s:String = '';
			var a:Address = this.rediCorrectionHeader.finalCustomer.aliasAddress;
			s = a.addressLine1 + ' ' + a.city + ' ' + a.state + ' ' + a.zipCode;
			return s;
		}
		public function getFinalBuyerAddress():String{
			var s:String = '';
			var a:Address = this.rediCorrectionHeader.finalCustomer.address;
			s = a.addressLine1 + ' ' + a.city + ' ' + a.state + ' ' + a.zipCode;
			return s;
		}
		public function getAddress(a:Address):String{
			var s:String = '';
			s = a.addressLine1 + ' ' + a.city + ' ' + a.state + ' ' + a.zipCode;
			return s;
		}
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
			if(lock.bEditMode){
				//Locked by Me
				iconLockCurrent = iconUnLock;
			}
			dispatchEvent(new Event('lockPMChanged'));
			//reset menuData where icon is stored
			this.acMenuData = new ArrayCollection();
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
			var evt:RediEvent = new RediEvent(RediEvent.GET_CORRECTION_LOCK);
			this._lock.toggleLock = true;
			evt.lock = this.lock;
			evt.rch = this.rediCorrectionHeader;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function closeCorrection():void{
			var evt:RediEvent = new RediEvent(RediEvent.CALL_CLOSE_CORRECTION);
			//evt.rediId = this.parent.id;
			//this.parent.dispatchEvent(e);
			//evt.rch = this.rediCorrectionHeader;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function validateRedi():void{
			/*if(){
				
			}*/
			var evt:RediEvent = new RediEvent(RediEvent.VALIDATE_REDI);
			//evt.rediId = this.parent.id;
			//this.parent.dispatchEvent(e);
			this.rediCorrectionHeader.arrRediCorrectionItems = this.acRediEditItems.source;
			evt.rch = this.rediCorrectionHeader;
			this._dispatcher.dispatchEvent(evt);
		}
		
		/*  select component.payee for pay single*/
		public function selectPayee(c:Customer,s:String):void
		{
			//showDistributorSearch()
			var e:MainEvent = new MainEvent(MainEvent.SEARCH_PAYEE);
			e.payeeTypeId = 1;
			e.customer = c;
			e.settings= this.oSettings;
			e.settings.programId = 0;
			e.sSource = s;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function searchCustomer(s:String,sShipTo:String):void
		{
			//showDistributorSearch()
			var e:RediEvent = new RediEvent(RediEvent.SEARCH_CUSTOMER);
			e.sItem = sShipTo;
			e.rediId = s;
			this._dispatcher.dispatchEvent(e);
			
		}
		
	}
	
}