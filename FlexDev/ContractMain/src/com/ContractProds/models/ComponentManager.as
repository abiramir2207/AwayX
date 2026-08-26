package com.ContractProds.models
{
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.FilterParms;
	import com.ContractProds.vos.Item;
	import com.ContractProds.vos.ProdRate;
	import com.ContractProds.vos.Program;
	import com.ContractProds.vos.ResultLogItem;
	import com.ContractProds.vos.Uom;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.charts.chartClasses.StackedSeries;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	
	public class ComponentManager extends EventDispatcher
	{

		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function ComponentManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			/* the results log will always have this filter applied */
			this._acResultsLog.filterFunction = this.resultsLogFilter;
		}
		
		/*.......................................  Properties  ......................................*/
		public static const FIXED_NAME : String = 'Fixed';
		public static const REBATE_NAME : String = 'Rebate';
		public static const FIXED_TYPE_ID : int = 1;
		public static const REBATE_TYPE_ID : int = 2;
		public static const DISTRIBUTOR_PAYEE : String = 'Distributor';
		public static const VENDOR_PAYEE : String = 'Vendor';
		public static const DISTRIBUTOR_TYPE_ID : int = 1;
		public static const VENDOR_TYPE_ID : int = 5;
		/* boound from searchManager.itemList -> dp for grid */
		[Bindable] public var items:ArrayCollection = new ArrayCollection();
		/* bound to GriddataPM -> the show hide check box */
		[Bindable] public var bShowFixed:Boolean;
		[Bindable] public var bShowRebate:Boolean;
		//.................selectedComponent......................
		/* Component */
		private var _component:Component = new Component();
		private var _tempComponent:Component = new Component();
		[Bindable (event="ComponentChange")]
		public function get component():Component
		{
			return _component;
		}
		 public function set component(comp:Component):void
		{
			this._component = comp;
			dispatchEvent(new Event('ComponentChange'));
		}
		
		/*.................components......................*/
		private var _acComponents:ArrayCollection = new ArrayCollection;
		[Bindable (event="ComponentsChange")]
		public function get acComponents():ArrayCollection
		{
			return _acComponents;
		}
		
		/*.................resultsLog......................*/
		private var _acResultsLog:ArrayCollection = new ArrayCollection;
		[Bindable (event="resultsLogChange")]
		public function get acResultsLog():ArrayCollection
		{
			return _acResultsLog;
		}
		/* Program */
		private var _program:Program = new Program();
		[Bindable (event="ProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		
		/*-.........................................Methods..........................................*/
		
		public function setComponent(comp:Component):void
		{
			this._component = comp;
			dispatchEvent(new Event('ComponentChange'));
			/* we are now editing a different comp -> tell the ui */
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RESULT_LOG);
				e.sResult = 'Editing: ';
   			this._dispatcher.dispatchEvent(e);
			
		}
		
		/*.................addComponent......................*/
		public function addComponent( comp:Component ):void
		{
			if(comp)
			{
				_acComponents.addItem( comp );
				_component = comp;
				if(comp.type == ComponentManager.FIXED_TYPE_ID){
					this.bShowFixed = true;
				}
				if(comp.type == ComponentManager.REBATE_TYPE_ID){
					this.bShowRebate = true;
				}
				dispatchEvent( new Event("ComponentChange") );
				dispatchEvent( new Event("ComponentsChange") );
				/* added component -> tell the ui */
				var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RESULT_LOG);
					e.sResult = 'Added : ';
				this._dispatcher.dispatchEvent(e);
			}
		}
		
		/*.................updateComponent......................*/
		public function updateComponent( comp:Component ):void
		{
			if( _acComponents )
			{
				var compToUpdate:Component = findComponent( comp );
				compToUpdate.copy( comp );
				dispatchEvent( new Event("ComponentChange") );
				/* user clicked update -> log it and tell the ui */
				var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RESULT_LOG);
					e.sResult = 'Updated: ';
	   			this._dispatcher.dispatchEvent(e);
			}
		}
		
		/*.................deleteComponent......................*/
		public function deleteComponent( comp:Component ):void
		{
			if(comp)
			{
				var i:int = 0;
				for each(var c:Component in _acComponents){
					if(c.componentId == comp.componentId && c.type == comp.type){
						_acComponents.removeItemAt(i);
						/* user clicked delete -> log it and tell the ui */
						var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RESULT_LOG);
							e.sResult = 'Deleted: '
			   			this._dispatcher.dispatchEvent(e);
						break;
					}
					i++;
				}
				dispatchEvent( new Event("ComponentsChange") );
			}
		}
		
		/*.................storeComponents......................*/
		public function saveComponents( o:* ):void
		{
			var arr:Array = o.components;
			_program = o;
			dispatchEvent( new Event("ProgramChange") );
			/* Now we have to update the grid */
			for each(var c:Component in arr){
				/* dispatch ADD -> insert comp into grid and add to acComps 
					FIXED and REBATE Only  */
				if(c.type == 1 || c.type ==2){
					var e:ComponentEvent = new ComponentEvent(ComponentEvent.ADD);
					e.component = c;
					this._dispatcher.dispatchEvent(e);
				}
			}
			/* dispatch the load prod rates event */
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.LOAD_PROD_RATE);
			this._dispatcher.dispatchEvent(event); 
			/* Now select the last component (or we could select NONE) */
			if(c){
				var evt:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_TYPE);
				evt.typeId = c.type;
				this._dispatcher.dispatchEvent(evt);
			}
			/* After the Prodrates are saved, lets filter and show them 
			var oFilterParms:FilterParms = new FilterParms();
				oFilterParms.bfilterRates = true;
				var eSvFParm:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
				eSvFParm.oFilterParms = oFilterParms;
			this._dispatcher.dispatchEvent(eSvFParm);*/
			
			/* Now filter...done here so we don't filter for each component imported */
			//var seEv:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			/* dispatch the event */
			//this._dispatcher.dispatchEvent(seEv);
			
			/* var event:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_DEF);
			event.compDef = compDef as ComponentDef;
			this.dispatcher.dispatchEvent(event); */	
		}
		
		/*.................findComponent......................*/
		public function findComponent( comp:Component ):Component
		{
			var componentFound:Component;
			for each( var currentComponent:Component in acComponents)
			{
				if( comp.componentId == currentComponent.componentId &&  comp.type == currentComponent.type)
				{
					componentFound = currentComponent;
					break;
				}
			}
			return componentFound;
		}
		/*.................findComponentById......................*/
		public function findComponentById( sId:String ):Component
		{
			var componentFound:Component;
			for each( var currentComponent:Component in acComponents)
			{
				var s:String = '';
				s = s + currentComponent.type as String;
				s = s + currentComponent.componentId as String; 
				if( sId == s)
				{
					componentFound = currentComponent;
					break;
				}
			}
			return componentFound;
		}
		/*.................removeProdRate......................*/
		public function removeProdRate( prodRate:ProdRate,comp:Component = null ):void
		{	
			if(!comp){
				comp = this.component
			}
			var i:int = 0;
			for each( var pr:ProdRate in comp.prodRate)
			{
				if( pr.itemNumber == prodRate.itemNumber)
				{
					comp.prodRate.splice(i,1);
					break;
					
				}
				i++;
			}
		}
		/*.................setSelectedRateUom......................*/
		public function setSelectedRateUom( p:ProdRate,sId:String = '',iAction:int=0 ):void
		{
			var comp:Component;
			if(sId == ''){
				comp = this.component
				sId = getSelectedCompId(comp);
			}
			else{
				comp = findComponentById(sId)
			}
			
			var arr:Array = new Array();
			for each(var i:Item in this.items){
				if(i.isSelected){
					var pr:ProdRate = new ProdRate(p.itemGuid,p.itemNumber,i[sId].prodRate.uom);
					switch (iAction) {
						case 0:
							//absolute
							setRateUom(p,i,sId);
							break;
						case 1:
							//percent
							pr.rate = i[sId].prodRate.rate + (i[sId].prodRate.rate * (p.rate * .01));
							setRateUom(pr,i,sId);
							break;
						case 2:
							//incremental
							pr.rate = i[sId].prodRate.rate + p.rate;
							setRateUom(pr,i,sId);
							break;
						case 3:
							//MP percent
							pr.rate = i.marketPrice + (i.marketPrice * (p.rate * .01));
							setRateUom(pr,i,sId);
							break;
						case 4:
							//MP incremental
							pr.rate = i.marketPrice + p.rate;
							setRateUom(pr,i,sId);
							break;
						case 5:
							//eq MP Rate
							pr.rate = i.marketPrice;
							setRateUom(pr,i,sId);
							break;
						default:
							trace("Not 0, 1, 2, 3, or 4");
					}
					
					//pr = i[component.componentId].prodRate;
					//arr.push(pr);
				}
			}
			//component.prodRate = arr;
		}
		/*.................setRateUom......................*/
		public function setRateUom( p:ProdRate,i:Item,sId:String = ''):void
		{
				var comp:Component;
				if(sId == ''){
					comp = this.component
					sId = getSelectedCompId(comp);
				}
				else{
					comp = findComponentById(sId)
				}
				
				/* if uom is not selected, default to first one */
				if(p.uom.uomId == 0){p.uom = i[sId].uomDp[0]};
				var pr:ProdRate = new ProdRate();
					pr.rate = p.rate;
					pr.uom  = p.uom;
					if (p.uom.uomId == 2){
						pr.rateMP = i.marketPriceLB;
					}
					else{
						pr.rateMP = i.marketPriceCS;
					}
					pr.rateMPCS = i.marketPriceCS;
					pr.rateMPLB = i.marketPriceLB;
					//pr.uomMP  = p.uomMP;
					pr.itemGuid = i.itemGuid;
					pr.itemNumber = i.baItem;
					pr.volume = i.volume;
				/* we don't want dupes so remove it if it is in list */
				removeProdRate(pr,comp);
				/* add it to the component */
				if(!comp.prodRate){
					comp.prodRate = new Array();
				}
				/* IF both the rate and uom are valid add the prodrate to the components array*/
				if(p.rate >= 0 && p.uom.uomId > 0){
					comp.prodRate.push(pr);
				}
			
		}
		/*.................setRate......................*/
		public function setRate( r:String,i:Item,sId:String ):void
		{
			//var sId:String = '';
			//sId = getSelectedCompId(this.component);
			this.setComponent(findComponentById(sId));
			var pr:ProdRate = new ProdRate();
				pr.rate = parseFloat(r) as Number;
				pr.uom  = i[sId].prodRate.uom;
				//pr.rateMP = i[sId].prodRate.rateMP;
				//pr.uomMP  = i[sId].prodRate.uomMP;
				pr.itemGuid = i.itemGuid;
				pr.itemNumber = i[sId].prodRate.itemNumber;
			/* add it to the component */ 
			setRateUom(pr,i);
			/* we may have tabbed to a new component */
			selectComponentDef(sId);
			
		}
		/*.................setUom......................*/
		public function setUom( u:Uom,i:Item,sId:String ):void
		{
			//var sId:String = '';
			//sId = getSelectedCompId(this.component);
			this.setComponent(findComponentById(sId));
			var pr:ProdRate = new ProdRate();
				pr.rate = i[sId].prodRate.rate;
				//pr.rateMP = i[sId].prodRate.rateMP;
				//pr.uomMP  = i[sId].prodRate.uomMP;
				pr.uom  = u;
				pr.itemGuid = i.itemGuid;
				pr.itemNumber = i[sId].prodRate.itemNumber;
			/* add it to the component */ 
			setRateUom(pr,i);
			/* we may have tabbed to a new component */
			selectComponentDef(sId);
		}
		/*.................SetVol.....................*/
		public function setVol( vol:Number,i:Item ):void
		{
			var sId:String = '';
			for each(var c:Component in this.acComponents){
				sId = getSelectedCompId(c);
				var pr:ProdRate = new ProdRate();
					pr.rate = i[sId].prodRate.rate;
					pr.uom  = i[sId].prodRate.uom;
					pr.itemGuid = i[sId].prodRate.itemGuid;
					pr.itemNumber = i[sId].prodRate.itemNumber;
					pr.volume = Number(vol) as Number;
					if (i[sId].prodRate.uom.uomId == 2){
						pr.rateMP = i.marketPriceLB;
					}
					else{
						pr.rateMP = i.marketPriceCS;
					}
					
					i.volume = pr.volume;
					i[sId].prodRate.volume = pr.volume;
				/* we don't want dupes so remove it if it is in list */
				removeProdRate(pr,c);
				/* add it to the component */
				if(!c.prodRate){
					c.prodRate = new Array();
				}
				/* IF both the rate and uom are valid add the prodrate to the components array*/
				if(pr.rate > 0 && pr.uom.uomId > 0){
					c.prodRate.push(pr);
				}
			}
		} 
		private function selectComponentDef(sId:String):void{
			/* since we may have tabbed to a differnt component, select that one */
			 var evt:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_TYPE);
			evt.typeId = this.component.type;
			this._dispatcher.dispatchEvent(evt);
			
			/* var event:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_DEF_BYID);
			event.sId = getSelectedCompId(findComponentById(sId));
			this._dispatcher.dispatchEvent(event); */
		}
		/*.................setResultLog......................*/
		public function setResultLog(event:ComponentEvent):void
		{
			var d:Date = new Date();
			var sDate:String = '';
				sDate = sDate + StringUtils.leadingZero(d.hours) + ':' + StringUtils.leadingZero(d.minutes) + ':' + StringUtils.leadingZero(d.seconds);
			var comp:Component = this.component;
			var resultLogItem:ResultLogItem = new ResultLogItem();
				resultLogItem.componentId 	= comp.componentId;
				resultLogItem.componentName = comp.name;
				resultLogItem.type			= comp.type;
				resultLogItem.sResult		= event.sResult + _component.name + ' ' + sDate;
			this._acResultsLog.addItemAt(resultLogItem,0);
			this._acResultsLog.refresh();
			dispatchEvent(new Event('resultsLogChange'));
		}
		/*.................setPayee......................*/
		public function setPayee( event:ComponentEvent ):void
		{
			this._component.payee = event.payee;
			this.updateComponent(this._component);
			//dispatchEvent( new Event("ComponentChange") );
		}
		/*.................filter results log for current component ......................*/
		private function resultsLogFilter(item:Object):Boolean{
			return ( item.componentId == this.component.componentId &&  item.type == this.component.type)
		}
		
		public static function getSelectedCompId(c:Component):String{
			var s:String = '';
			s = s + c.type as String;
			s = s + c.componentId as String;
			return s;
		}
		/* After the Save close the caller page */
		public function callWrapper():void {
			var s:String;
			if (ExternalInterface.available) {
				var wrapperFunction:String = "closeCompProdRateEdit";
				s = ExternalInterface.call(wrapperFunction);
			} else {
				s = "Wrapper not available";
			}
		}
		
		

		
		
	}
}