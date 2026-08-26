package com.Program.Fitness.models
{

	import com.ContractProds.events.SearchEvent;
	import com.Program.Fitness.events.FitnessEvent;
	import com.Program.Fitness.models.vos.FitnessDetail;
	import com.Program.Fitness.models.vos.FitnessSearchDef;
	import com.shared.events.MainEvent;
	import com.shared.vos.FilterParms;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	public class FitnessManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function FitnessManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		
		/*.................acFitnessItems......................*/
		private var _acFitnessItems:ArrayCollection = new ArrayCollection();
		[Bindable (event="acFitnessItemsChanged")]
		public function get acFitnessItems():ArrayCollection
		{
			return _acFitnessItems;
		}
		public function set acFitnessItems(ac:ArrayCollection):void
		{			
			this._acFitnessItems = ac;
			dispatchEvent(new Event('acFitnessItemsChanged'));	
		}
		
		/*.................fitnessSearchDef......................*/
		private var _fitnessSearchDef:FitnessSearchDef = new FitnessSearchDef();
		[Bindable (event="fitnessSearchDefChanged")]
		public function get fitnessSearchDef():FitnessSearchDef
		{
			return _fitnessSearchDef;
		}
		public function set fitnessSearchDef(fitnessSearchDef:FitnessSearchDef):void
		{			
			this._fitnessSearchDef = fitnessSearchDef;
			dispatchEvent(new Event('fitnessSearchDefChanged'));	
		}
		
		/*.................funcFilterInsert......................*/
		private var _funcFilterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="funcFilterInsertChange")]
		public function get funcFilterInsert():Function
		{
			return _funcFilterInsert;
		}
		public function set funcFilterInsert(func:Function):void
		{
			this._funcFilterInsert = func;
			dispatchEvent(new Event('funcFilterInsertChange'));
		}
		/*  FilterParms From FilterPM*/
		private var _oFilterParms:FilterParms = new FilterParms();
		[Bindable (event="smFilterParmsChanged")]
		public function get oFilterParms():FilterParms
		{
			return _oFilterParms;
		}
		public function set oFilterParms(f:FilterParms):void
		{
			this._oFilterParms = f;
			dispatchEvent(new Event('smFilterParmsChanged'));
		}
		
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here:  + {ObjectUtil.toString(x)}' );
			
		}
		
		public function getData(e:MainEvent):void{
			var evt:FitnessEvent = new FitnessEvent(FitnessEvent.LOAD_Fitness);
			evt.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(evt);
		}
		public function getFitnessResults(arr:Array):void{
			this.acFitnessItems = new ArrayCollection(arr);
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			evt.oFilterParms = this.oFilterParms;
			/* dispatch the event */
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function getHeaderData(e:MainEvent):void{
			var evt:FitnessEvent = new FitnessEvent(FitnessEvent.LOAD_HEADER_DATA);
			evt.fitnessSearchDef = this.fitnessSearchDef;
			this._dispatcher.dispatchEvent(evt);
		}
		public function getFitnessHeaderResults(f:FitnessSearchDef):void{
			this.fitnessSearchDef = f;
		}
		
		public function itemFilter(event:SearchEvent=null):void 
		{
			/* update current selections */
			
			/*oFilterParms.acData = this.acComponents;
			oFilterParms.acData2 = new ArrayCollection(this.program.distributors);
			dispatchEvent(new Event('smFilterParmsChanged'));*/
			/* filter the data */
			this.funcFilterInsert = this.itemFilterFunc;
			/* broadcast updates */
			dispatchEvent(new Event('acFitnessItemsChanged'));
		}
		
		[Bindable] 
		public var itemFilterFunc:Function =
			function(item:Object):Boolean
			{ 
				/* Filter 0 volume */
				var bfilterVol:Boolean = true;
				if(this.oFilterParms.bfilterA){
					/* if group return false */
					if(item['casesNon'] == 0 && item['cases'] == 0){
						bfilterVol = false;
					}
				}
				
				return (bfilterVol == true);
			}
		public function filterReset():void
		{	this.funcFilterInsert = function(inObject:Object):Boolean{return true;};
			
		}

	}
}