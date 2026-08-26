package com.Admin.ui.presenters
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
    import mx.core.IFlexDisplayObject;
    import com.Admin.ui.views.ItemSearchWindow;
    import com.shared.events.MainEvent;
    import com.asfusion.mate.events.Dispatcher;
	
	//import com.shared.vos.Settings;
	//import com.shared.views.*;
	import com.shared.vos.GridData;
	
	//import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import flash.display.DisplayObject;
	public class AdminPM extends EventDispatcher
	{
		
		//--------------------------------------------------------------------
		//    Constructor
		//--------------------------------------------------------------------
		
		private var dispatcher:IEventDispatcher;
		public function AdminPM( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		
		//--------------------------------------------------------------------
		//    Public Setters and Getters
		//--------------------------------------------------------------------
		
		//.................title......................
		private var _title:String;
		[Bindable(Event="selectedUserChange")]
		public function get title():String
		{
			return _title;
		}
		
		//.................selectedUser......................
		private var _tempUser:*;
		private var _selectedUser:*;
		[Bindable(Event="selectedUserChange")]
		public function get selectedUser():*
		{
			return _selectedUser;
		}
		public function set selectedUser( value:* ):void
		{
			
			 	_selectedUser = value ;
			 	dispatchEvent( new Event( "selectedUserChange" ) );

		}
		
		//.................users......................
		private var _users:ArrayCollection;
		[Bindable(Event="usersChange")]
		public function get users():ArrayCollection
		{
			return _users;
		}
		public function set users( value:ArrayCollection ):void
		{
			_users = value;
			dispatchEvent( new Event( "usersChange" ) );
		}
		//.................UOM......................
		private var _uom:Array;
		[Bindable(Event="uomChange")]
		public function get uom():Array
			{
				this._uom = [
	               {label:'CS',	data:'1'},
	               {label:'LB',	data:'2'},
	               {label:'%',	data:'3'}];
				
				return _uom;
			}
			//.................Template......................
		private var _templateDP:Array;
		[Bindable(Event="templateDP")]
		public function get templateDP():Array
			{
				this._templateDP = [
	            {label:'Distributor Pricing', data:'123'},
	            {label:'Distributo Group',data:'124'},
	            {label:'Bid Contract',data:'130'},
	            {label:'Food Shows',data:'127'},
	            {label:'National Accounts',data:'188'},
	            {label:'Bid Contract',data:'199'},
	            {label:'Brokerage',data:'211'},
	            {label:'Regional Operator',data:'222'}];
				
				return _templateDP;
			}
			
			//.................Status......................
		private var _statusDP:Array;
		[Bindable(Event="statusDPChange")]
		public function get statusDP():Array
			{
				this._statusDP = [
					{label:'[ALL]',data:'0'},
		        	{label:'WIP',data:'1'},
		            {label:'RFA',data:'2'},
		            {label:'Pending',data:'3'},
		            {label:'Approved',data:'4'},
		            {label:'Expiring',data:'5'},
		            {label:'Expired',data:'6'}];
				
				return _statusDP;
			}
			
			//.................Program......................
		private var _programsDP:Array;
		[Bindable(Event="programsDPChange")]
		public function get programsDP():Array
			{
				this._programsDP = [
	               {label:'[ALL]',data:'0'},
		           {label:'PRG-104849',data:'600'},
		           {label:'PRG-105723',data:'620'},
		           {label:'PRG-106321',data:'617'},
		           {label:'PRG-107818',data:'633'},
		           {label:'PRG-108741',data:'629'},
		           {label:'PRG-109654',data:'688'},
		           {label:'PRG-106987',data:'733'},
		           {label:'PRG-107654',data:'729'},
		           {label:'PRG-108321',data:'788'}];
				
				return _programsDP;
			}
		//.................tiWidth......................
		private var _tiWidth:int;
		[Bindable(Event="uomChange")]
		public function get tiWidth():int
			{
				this._tiWidth = 120;
				
				return _tiWidth;
			}
		
		//--------------------------------------------------------------------
		//    Public Methods
		//--------------------------------------------------------------------
		public function showAction() : void 
				{
					Alert.show("Click Actions:\r * Lock this criteria pane for read only \r" + 
							"* Go to DB for Programs that meet criteria \r" + 
							"* Insert Mass_Contract_Prod_Update Record \r" + 
							"* Update Left hand Pending list to include this new action");
				}
		public function showApplyAllAction() : void 
				{
					Alert.show("Click Actions:\r * Apply rate to all Discounts.  Does not submit to DB.  Update all" + 
							"rows in Object MassUpdateContractProductRates");
				}
		

         public function showItemSearch(win:DisplayObject):void {
                // Create a non-modal TitleWindow container.
                /* var helpWindow:IFlexDisplayObject =
                    PopUpManager.createPopUp(win, ItemSearchWindow, false); */
                    
           		var event:MainEvent = new MainEvent(MainEvent.SEARCH_ITEMS);
           		event.sState = "ItemSearchState";
				var d:Dispatcher = new Dispatcher();
				d.dispatchEvent(event);
            }

	}
}