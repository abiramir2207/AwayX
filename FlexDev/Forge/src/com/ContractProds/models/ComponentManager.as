package com.ContractProds.models
{
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.vos.ComponentDef;
	import com.ContractProds.vos.ResultLogItem;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Component;
	import com.shared.vos.Item;
	import com.shared.vos.ProdRate;
	import com.shared.vos.ProductAttr;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	import com.shared.vos.Uom;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
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
		public static const FIXED_CUST_RATE_TYPE_ID : int = 3;
		public static const REBATE_TYPE_ID : int = 2;
		public static const DISTRIBUTOR_PAYEE : String = 'Distributor';
		public static const VENDOR_PAYEE : String = 'Vendor';
		public static const DISTRIBUTOR_TYPE_ID : int = 1;
		public static const VENDOR_TYPE_ID : int = 5;
		public static const TYPE_GROUP_DESC:String = "NONE";
		public static const CUSTOM_PRINT_BRAND :String = 'Local Print';
		/* boound from searchManager.itemList -> dp for grid */
		[Bindable] public var items:ArrayCollection = new ArrayCollection();
		/* bound to GriddataPM -> the show hide check box */
		[Bindable] public var bShowFixed:Boolean;
		[Bindable] public var bShowRebate:Boolean;
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="compMansettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			dispatchEvent(new Event('compMansettingsChanged'));
		}
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
		public function set program(prg:Program):void
		{
			this._program = prg;
			dispatchEvent(new Event('ProgramChange'));
			//program has property arrPrdAttr.  this determines prod attr columns added to grid.
			//this event rebuilds the checkboxes that show hide the columns.
			var e:SearchEvent = new SearchEvent(SearchEvent.BUILD_SHOW_HIDE_CHK);
			this._dispatcher.dispatchEvent(e);
		}
		
		private var _componentDef:ComponentDef = new ComponentDef();
		[Bindable (event="cmComponentDefChange")]
		public function get componentDef():ComponentDef
		{
			return _componentDef;
		}
		public function set componentDef(CompDef:ComponentDef):void
		{
			this._componentDef = CompDef;
			dispatchEvent(new Event('cmComponentDefChange'));
			/*....... update the selected IDx for the combo box selections ....... */
		}
		
		/*.................acComponentDefs......................*/
		private var _acComponentDefs:ArrayCollection;
		[Bindable (event="cmComponentDefsAc")]
		public function get acComponentDefs():ArrayCollection
		{
			return _acComponentDefs;
		}
		public function set acComponentDefs(acCompDef:ArrayCollection):void
		{
			this._acComponentDefs = acCompDef;
			dispatchEvent(new Event('cmComponentDefsAc'));
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
			
			//var evt:SearchEvent = new SearchEvent(SearchEvent.BUILD_SHOW_HIDE_CHK);
			//this._dispatcher.dispatchEvent(evt);
			
		}
		
		/*.................addComponent......................*/
		public function addComponent( comp:Component ):void
		{
			if(comp)
			{
				//default payee to default payee of the claimMechanic -> "Pay Single"
				if(comp.programId == 0 && comp.claimMechanic){
					comp.payee.payeeTypeId = comp.claimMechanic.payeeTypeId;
				}
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
			if( _acComponents && _acComponents.length )
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
			var oPrdAttr:ProductAttr = new ProductAttr();
			var arr:Array = o.components;
			this.program = o;
			//  Hack.   Update the Name to include ship_to On list of distributors.  DAO and Object are used by other functions.  need hack HERE!
			for each(var cust:Customer in this.program.distributors){
				cust.name = "(" + cust.shipTo + ") " + cust.name;
			}
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
			// weneed customers to get Item prices from gross_Margin table
			if(this.program.distributors.length == 0 && this.oSettings.iMpId == 0){
				Alert.show('There are no Customers selected for this program. As a result, item prices (which are customer specific) are not available.');
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
				if( (pr.itemGuid == prodRate.itemGuid) || (pr.itemNumber.toLowerCase() == prodRate.itemNumber.toLowerCase() && prodRate.itemNumber != '') )
				{
					comp.prodRate.splice(i,1);
					break;
					
				}
				i++;
			}
			dispatchEvent( new Event("ComponentChange") );
		}
		
		/*.................getProdRate......................*/
		public function getProdRate( prodRate:ProdRate,comp:Component = null ):Number
		{	
			var n:Number;
			if(!comp){
				comp = this.component
			}
			
			for each( var pr:ProdRate in comp.prodRate)
			{
				if( pr.itemGuid == prodRate.itemGuid)
				{
					n= pr.rate;
					break;
					
				}
			}
			
			return n;
		}
		/*.................setSelectedRateUom......................*/
	/*	public function setSelectedRateUom( p:ProdRate,sId:String = '',iAction:int=0 ):void
		{
			var comp:Component;
			var bRateNotNum:Boolean = isNaN(p.rate);
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
					var pr:ProdRate = i[sId].prodRate;//new ProdRate(p.itemGuid,p.itemNumber,i[sId].prodRate.uom);
					//handle for mass apply the uom with no rate entered
					if(bRateNotNum){
						p.itemGuid = i.itemGuid;
						p.rate = getProdRate(p,comp);
					}
					
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
						case 6:
							//eq Ez Rate
							pr.rate = i.rateEz;
							setRateUom(pr,i,sId);
							break;
						default:
							trace("Not 0, 1, 2, 3, or 4");
					}
				}
			}
		}*/
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
				//Alert.show(ObjectUtil.toString(p));
				/* if uom is not selected, default to first one or the default from the template */
				if(p.uom.uomId == 0){
					p.uom = i[sId].uomDp[0];
					for each(var u:Uom in i[sId].uomDp){
						if(u.bDefault){
							p.uom = u;
						}
					}
				}
				
				//Set Price based on UOM
				var varianceMp:Number;
				if(p.uom.uomId == 2){
					p.rateMP = p.rateMPLB;
				}
				else{
					p.rateMP = p.rateMPCS;
				}
				if(p.rateMPCustom > 0 && p.customPrint.bCustomPrint){	//if custom prin, use MIN Price
					if(comp.type == 1){
						p.varianceMP = p.rateMPCustom - p.rate;
						varianceMp = (p.varianceMP/p.rateMPCustom)*100;
						p.variancePercMP = varianceMp;
					}
					else{
						p.varianceMP = p.rate;
						varianceMp = (p.varianceMP/p.rateMPCustom)*100;
						p.variancePercMP = varianceMp;
					}
				}
				else if(p.rateMP > 0){	//USE MPrate
					if(comp.type == 1){
						p.varianceMP = p.rateMP - p.rate;
						varianceMp = (p.varianceMP/p.rateMP)*100;
						p.variancePercMP = varianceMp;
					}
					else{
						if(p.uom.uomId == 3){
							p.varianceMP = p.rateMP * (p.rate/100);
							varianceMp = p.rate;
							p.variancePercMP = varianceMp;
						}
						else{
							p.varianceMP = p.rate;
							varianceMp = (p.varianceMP/p.rateMP)*100;
							p.variancePercMP = varianceMp;
						}
					}
				}
				p.rateConverted = p.rate * this.program.conversionFactor;
				p.rateEz = i.rateEz;
				
				/* we don't want dupes so remove it if it is in list */
				removeProdRate(p,comp);
				/* add it to the component */
				if(!comp.prodRate){
					comp.prodRate = new Array();
				}
				/* IF both the rate and uom are valid add the prodrate to the components array OR
				 IT HAS Customer Level rates	*/
				var bCustRate:Boolean = false;
				if(comp.fixedType == com.ContractProds.models.ComponentManager.FIXED_CUST_RATE_TYPE_ID){
					bCustRate = p.checkCustRate(this.program.distributors);
				}
				if(p.rate >= 0 || bCustRate){
					if(isNaN(p.rate))p.rate= 0;
					comp.prodRate.push(p); //dispatchEvent(new Event('ComponentChange'));
				}
				//Alert.show(ObjectUtil.toString(p));
			
		}
		/*.................setRate......................*/
		public function setRate( r:String,i:Item,sId:String ):void
		{
			//THIS STEP iS OBSOLETE NOW. i[sId].prodRate is up to date, so pass it along.
			this.setComponent(findComponentById(sId));
			var pr:ProdRate = i[sId].prodRate;
			/* add it to the component */ 
			setRateUom(pr,i);
			/* we may have tabbed to a new component */
			selectComponentDef(sId);
			
		}
		/*.................setUom......................*/
		public function setUom( u:Uom,i:Item,sId:String ):void
		{

			this.setComponent(findComponentById(sId));
			var pr:ProdRate =  i[sId].prodRate;
			pr.uom = u;
			/* add it to the component */ 
			setRateUom(pr,i);
			/* we may have tabbed to a new component */
			selectComponentDef(sId);
		}
		/*.................SetVol.....................*/
		public function setVol( vol:Number,i:Item, adg:FilterAdvancedDatagrid ):void
		{
			var sId:String = '';
			for each(var c:Component in this.acComponents){
				sId = getSelectedCompId(c);
				var pr:ProdRate = i[sId].prodRate;
					pr.volume = Number(vol) as Number;
					if(pr.customPrint.bCustomPrint){
						i.customPrintCharge.setPrintMinPrice(pr.volume,pr.customPrint.iColors,pr.rateMP);
						pr.rateMPCustom = i.customPrintCharge.printMinPrice;
						i.volume = pr.volume;
						if(c.type == 1){
							pr.varianceMP = pr.rateMPCustom - pr.rate;
							pr.variancePercMP = (pr.varianceMP/pr.rateMPCustom)*100;
						}
						else{
							pr.varianceMP = pr.rate;
							pr.variancePercMP = (pr.varianceMP/pr.rateMPCustom)*100;
						}
						var scroll:int= adg.verticalScrollPosition;
						adg.validateNow();
						adg.selectedItem = i;
						adg.verticalScrollPosition = scroll;
					}
					//i[sId].prodRate.volume = pr.volume;
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
			var sIdCurrent:String = ComponentManager.getSelectedCompId(this.component);
			if(sIdCurrent != sId){
				var evt:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_TYPE);
				evt.typeId = this.component.type;
				this._dispatcher.dispatchEvent(evt);
			}
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