package com.Program.MarketPrice.models
{
	import com.Program.MarketPrice.events.MPEvent;
	import com.shared.vos.Component;
	import com.shared.vos.ProdRate;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;

	public class MPManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function MPManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		/*..... program .....*/
		private var _program:Program;
		[Bindable (event="programChange")]
		public function get program():Program{
			return _program;
		}
		/*..... maxVariancePercent .....*/
		private var _maxVariancePercent:Number = 0;
		[Bindable (event="varPercChange")]
		public function get maxVariancePercent():Number{
			return _maxVariancePercent;
		}
		/*.................acItems......................*/
		private var _acItems:ArrayCollection = new ArrayCollection();
		[Bindable (event="itemsChange")]
		public function get acItems():ArrayCollection
		{
			return _acItems;
		}
		public function set acItems(items:ArrayCollection):void
		{
			this._acItems = items;
			dispatchEvent(new Event('itemsChange'));
		}
		
		/*.........  Data Returned from Server GET Event ..............*/
		public function acItemResults(prg:*):void{
			this._program = prg;
			var arr:Array = new Array();
			for each(var c:Component in _program.components){
				//if fixed
				if(c.type == 1){
					arr = arr.concat(c.prodRate)
				}
			}
			this._acItems = new ArrayCollection(arr);
			for each(var pr:ProdRate in this._acItems ){
				if(pr.rateMP != 0){
					pr.varianceMP = pr.rateMP - pr.rate;
					pr.variancePercMP = (pr.rateMP - pr.rate)/pr.rateMP *100;
					if(pr.variancePercMP > this.maxVariancePercent){
						this._maxVariancePercent = pr.variancePercMP
					}
				}
				else{
					pr.varianceMP = 0;
					pr.variancePercMP = 0;
				}
				if(!pr.MPApprovalVariance){
					//trace(pr.MPApprovalVariance.toString() + ' :: mpApprovalVar');
				}
				//If it is a group
				if(pr.itemNumber == pr.itemGuid){
					pr.itemNumber = 'Group';
				}
			}
			var eMPEvent:MPEvent = new MPEvent(MPEvent.FILTER);
			var rateSort:SortField = new SortField("variancePercMP",false,true);
			this.acItems.sort = new Sort();
			this.acItems.sort.fields = [rateSort];
			eMPEvent.bFilter = true;
			this.filter(eMPEvent);
			dispatchEvent(new Event('varPercChange'));
			dispatchEvent(new Event('itemsChange'));
			dispatchEvent(new Event('programChange'));
		}
		
		/*-.........................................Methods..........................................*/
		public function filter(event:MPEvent):void{
			/* filter the data */
			if(event.bFilter){
				this.acItems.filterFunction = this.itemFilterFunc;
			}
			else{
				this.acItems.filterFunction = null;
			}
			
			this.acItems.refresh();
		}
		
		private function itemFilterFunc(item:Object):Boolean
		{	var pr:ProdRate = item as ProdRate;
			var bRet:Boolean = false;
			if(oSettings.user.hasOwnProperty('stProfileSettings')){
				if( (pr.MPApprovalVariance != pr.variancePercMP || pr.variancePercMP != 0) && item.rateMP != 0){  // || item.variancePercMP > this.oSettings.user.stProfileSettings.MARKET_PRICE_VARIANCE
					bRet = true;
				}
			}
			return bRet;
		}
		/*...  action  ...*/
		public function action(event:MPEvent):void{
			
		}
		/*...  cancel  ...*/
		public function cancel(event:MPEvent):void{
			
		}
		
	}
}