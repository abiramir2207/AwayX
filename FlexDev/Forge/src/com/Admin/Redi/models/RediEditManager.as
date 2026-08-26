package com.Admin.Redi.models
{
	import com.Admin.Redi.events.RediEvent;
	import com.Admin.Redi.models.vos.RediCorrectionDetail;
	import com.Admin.Redi.models.vos.RediCorrectionHeader;
	import com.ContractProds.events.ComponentEvent;
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.utils.ObjectUtil;
	
	public class RediEditManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function RediEditManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var bEditMode:Boolean;
		[Bindable]
		public var currentCustomerEdit:Customer;
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
		/*.................rediCorrectionHeader......................*/
		private var _rediCorrectionHeader:RediCorrectionHeader;
		[Bindable (event="manRediCorrectionHeaderChanged")]
		public function get rediCorrectionHeader():RediCorrectionHeader
		{
			return _rediCorrectionHeader;
		}
		public function set rediCorrectionHeader(rch:RediCorrectionHeader):void
		{
			_rediCorrectionHeader = rch;
			dispatchEvent(new Event('manRediCorrectionHeaderChanged'));
		}
		/*.................arrItemSearch......................*/
		private var _arrItemSearch:Array = new Array();
		[Bindable (event="arrItemSearchChanged")]
		public function get arrItemSearch():Array
		{
			return _arrItemSearch;
		}
		public function set arrItemSearch(ac:Array):void
		{			
			this._arrItemSearch = ac;
			dispatchEvent(new Event('arrItemSearchChanged'));	
		}
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
			this._lock.objIdLockedDesc = '[READ ONLY MODE] ' + lock.userLocked.fullName + ' Lock Redi Correction For Exclusive Processing.';
			this.bEditMode = false;
			if(lock.bLocked){
				//Locked by Me
				if(this.lock.userLocked.id == this.oSettings.userId){
					this._lock.objIdLockedDesc = '[EDIT MODE] Locked by ' + lock.userLocked.fullName;
					bEditMode = true;
					this._lock.bEditMode = true;
				}
					//locked by another user
				else{
					this._lock.objIdLockedDesc = '[READ ONLY MODE] Locked by ' + lock.userLocked.fullName;
				}
			}
			rediCorrectionHeader.lock = _lock;
			dispatchEvent(new Event('lockChanged'));
		}
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here:  + {ObjectUtil.toString(x)}' );
			
		}
		
		public function getRediLockResults(h:RediCorrectionHeader):void{
			this.lock = h.lock;
			this.rediCorrectionHeader = h;
		}
		
		public function getRediEditResults(rch:RediCorrectionHeader):void{
			this.rediCorrectionHeader = rch;
			this.acRediEditItems = new ArrayCollection(rch.arrRediCorrectionItems);
			this.lock = rch.lock;
		}
		
		public function validateRediResults(rch:RediCorrectionHeader):void{
			this.rediCorrectionHeader = rch;
			//this.acRediEditItems = new ArrayCollection(rch.arrRediCorrectionItems);
			this.lock = rch.lock;
			if(rch.errorMessage != ''){
				Alert.show(rch.errorMessage,"VALIDATION RESULTS",4,null,validateCloseHandler);
			}
			else{
				Alert.show('Created Invoice: ' + rch.invoiceNumber,"VALIDATION RESULTS",4,null,validateCloseHandler);
			}
			
		}
		public function validateCloseHandler(e:CloseEvent):void{
			trace('xxx');
			if(this.rediCorrectionHeader.bReprocess){
				//SUCCESS -> Close
				var evt:RediEvent = new RediEvent(RediEvent.CALL_CLOSE_CORRECTION);
				evt.rch = this.rediCorrectionHeader;
				this._dispatcher.dispatchEvent(evt);
			}
		}
		public function lookupItemsResults(arr:Array):void{
			this.arrItemSearch = arr;
			/*for each(var rcd:RediCorrectionDetail in this.acRediEditItems.source){
				if(rcd.aliasItem = '454545'){
					//HOW DO I UPDATE AN ITEM RENDERER???
					Alert.show(ObjectUtil.toString(arr[0]));
					Alert.show(ObjectUtil.toString(arr.length));
				}
			}*/
			//Alert.show('Validation Complete.');
		}
		
		
		/*.................setPayee......................*/
		public function setPayee( event:ComponentEvent ):void
		{
			/*this.rediCorrectionHeader.finalCustomer.shipTo = event.payee.payeeId;
			this.rediCorrectionHeader.finalCustomer.name = event.payee.name;*/
			currentCustomerEdit.shipTo = event.payee.payeeId;
			currentCustomerEdit.name = event.payee.name;
			//dispatchEvent( new Event("ComponentChange") );
		}
		public function setCurrentcustomer( s:String ):void
		{
			if(s == 'finalCustomer'){
				this.currentCustomerEdit = this.rediCorrectionHeader.finalCustomer;
			}
			else if(s == 'originalCustomer'){
				this.currentCustomerEdit = this.rediCorrectionHeader.originalCustomer;
			}
		}
		
		public function setShipTo( s:String ):void
		{
			this.currentCustomerEdit.shipTo = s;
		}
		
		/*.................Distributor Info Results......................*/
		public function getDistributorInfoResults(c:Customer):void
		{		
			this.currentCustomerEdit.address = c.address;
			this.currentCustomerEdit.name = c.name;
			//don't overwrite what the user typed if is not in db
			//this.currentCustomerEdit.shipTo = s;
			this.currentCustomerEdit.customerId = c.customerId;
			//fire setter
			//this.currentCustomerEdit = currentCustomerEdit
		}
		
		
		
	}
}