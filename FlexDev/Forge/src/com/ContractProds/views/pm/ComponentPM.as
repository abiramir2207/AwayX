package com.ContractProds.views.pm
{
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.vos.ComponentDef;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.ClaimMechanic;
	import com.shared.vos.Component;
	import com.shared.vos.CustomPrint;
	import com.shared.vos.GlAccount;
	import com.shared.vos.Item;
	import com.shared.vos.PaidTo;
	import com.shared.vos.Payee;
	import com.shared.vos.PaymentCycle;
	import com.shared.vos.ProdRate;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	import com.shared.vos.Uom;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.IUITextField;
	import mx.core.mx_internal;
	import mx.formatters.NumberFormatter;
	import mx.utils.ObjectUtil;

	public class ComponentPM extends EventDispatcher
	{
		/*...................................... Constants.......................................*/
		public static const UNSELECTED:String 	= "unselected";
		public static const SELECTED:String 	= "selected";
		public static const ADD_NEW:String 		= "addNew";
		public static const LOADING:String 	= "addLoading";
		public static const SAVE_LOADING:String = "saveLoading";
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function ComponentPM( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		/*.......................  Properties  .......................*/
		public var uom:Uom;
		public var itemList:ArrayCollection;
		
		[Bindable (event="cbxIxChgPc")] public var paymentCycleIdx:int = 0;
		[Bindable (event="cbxIxChgPt")] public var paidToIdx:int = 0;
		[Bindable (event="cbxIxChgCm")] public var claimMechanicIdx:int = 0;
		[Bindable (event="cbxIxChgGl")] public var glAccountIdx:int = 0;
		[Bindable (event="cbxIxChgCd")] public var componentDefIdx:int = 0;
		[Bindable] public var sLbaleColor:String = '0xffbf5f';//'0xDFDFDF'; , '0xffffff' 
		[Bindable] public var nBgAlpha:Number = 0.3;
		[Bindable]
		public var arrGraphics:Array = new Array('A','B','C');
		[Bindable]
		public var arrColors:Array = new Array(1,2,3,4,5,6,7,8,9);
		
		/* arrPrintGroup used for the Convert Custom Print Function */
		private var _arrPrintGroup:Array = new Array();
		[Bindable (event="arrPrintGroupChange")] 
		public function get arrPrintGroup():Array
		{	return _arrPrintGroup; }
		public function set arrPrintGroup(arr:Array):void{
			this._arrPrintGroup = arr;
			dispatchEvent(new Event('arrPrintGroupChange'));
		}
		
		private var _arrSelectedCustomer:Array = new Array();
		[Bindable (event="arrSelectedCustomerChange")] 
		public function get arrSelectedCustomer():Array
		{	return _arrSelectedCustomer; }
		public function set arrSelectedCustomer(arr:Array):void{
			this._arrSelectedCustomer = arr;
			dispatchEvent(new Event('arrSelectedCustomerChange'));
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.SHOW_HIDE_CUST_RATE);
			event.arr1 = arr;
			this.dispatcher.dispatchEvent(event);
		}
		
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="pmsettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			dispatchEvent(new Event('pmsettingsChanged'));
			//fire setter that has logic baked in
			this.bShowCustomPrintQuotes = false;
		}
		
		/* Component Def */
		private var _componentDef:ComponentDef = new ComponentDef();
		//private var _tmpComponentDef:ComponentDef = new ComponentDef();
		[Bindable (event="pmComponentDef")]
		public function get componentDef():ComponentDef
		{
			return _componentDef;
		}
		public function set componentDef(CompDef:ComponentDef):void
		{
			this._componentDef = CompDef;
			dispatchEvent(new Event('pmComponentDef'));
			dispatchEvent(new Event('selectedUomIdxChange'));
			if(this.component.componentId > 0){
				this.setClaimMechanicIdx();
				this.setPaidToIdx();
				this.setPaymentCycleIdx();
				this.setGlAccountIdx();
				this.setComponentDefIdx();
			}
			//fire setter that has logic baked in
			this.bShowCustomPrintQuotes = false;
			/* the comDef has the dp for the cbo's...if it changes, the selectedIndex is lost -> dispatch change again */
			/*....... update the selected IDx for the combo box selections ....... */
		}
		/*...................... Component ......................*/
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
			this.setClaimMechanicIdx();
			this.setPaidToIdx();
			this.setPaymentCycleIdx();
			this.setGlAccountIdx();
			this.setComponentDefIdx();
			//fire setter that has logic baked in
			this.bShowCustomPrintQuotes = false;
			//this.arrSelectedCustomer = new Array();
			/* ..........  IDx Done  ......... */
			dispatchEvent(new Event('ComponentChange'));
			dispatchEvent(new Event('bShowCustRateChange'));
		}
		/*...................... Program ......................*/
		private var _program:Program = new Program();
		[Bindable (event="ProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		public function set program(prg:Program):void
		{
			this._program = prg;
			var arr:Array = new Array();
			for each(var c:Customer in prg.distributors){
				arr.push(c);
			}
			this.arrSelectedCustomer =arr;
			dispatchEvent(new Event('ProgramChange'));
			//fire setter that has logic baked in
			this.bShowCustomPrintQuotes = false;
			
		}
		/*.................acComponents......................*/
		private var _acComponents:ArrayCollection = new ArrayCollection;
		[Bindable (event="ComponentsChange")]
		public function get acComponents():ArrayCollection
		{
			return _acComponents;
		}
		public function set acComponents(comps:ArrayCollection):void
		{
			this._acComponents = comps;
			dispatchEvent(new Event('ComponentsChange'));
		}
		
		/*.................acComponentDefs......................*/
		private var _acComponentDefs:ArrayCollection;
		[Bindable (event="pmComponentDefs")]
		public function get acComponentDefs():ArrayCollection
		{
			return _acComponentDefs;
		}
		public function set acComponentDefs(acCompDef:ArrayCollection):void
		{
			/* since the list of defs changed, select the first one */
			
			if(acCompDef.length){
				var setCompDef:ComponentDef = acCompDef[0];
				for each(var compDef:ComponentDef in acCompDef){
					if(this.component.type == compDef.type && this.component.componentId == compDef.componentId){
						setCompDef = compDef;
						break;
					}
				}
				/* fall through to default -> pick the first one */
				setSelectedComponentDef(setCompDef);
				//defsult val for label when no comps are selected
				//KRAFT TODO: Keep inserting default.  new setting for def. comp.
				if( this.deleteLabel == "delete component" && this.acComponents.length == 0 && setCompDef.bDefaultComp){
					this.save();
				}
			}
			this._acComponentDefs = acCompDef;
			dispatchEvent(new Event('pmComponentDefs'));
			this.setComponentDefIdx();
			dispatchEvent( new Event( "cbxIxChgCd" ));
		}
		/*.................resultsLog......................*/
		private var _acResultsLog:ArrayCollection = new ArrayCollection;
		[Bindable (event="resultsLogChange")]
		public function get acResultsLog():ArrayCollection
		{
			return _acResultsLog;
		}
		public function set acResultsLog(resultsLog:ArrayCollection):void
		{
			this._acResultsLog = resultsLog;
			dispatchEvent(new Event('resultsLogChange'));
		}
		
		/*.................Show Customer Level Rates.....................*/
		private var _bShowCustRate:Boolean = false;
		[Bindable(Event="bShowCustRateChange")]
		public function get bShowCustRate():Boolean
		{
			_bShowCustRate = this.component.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID  && 
							!this.oSettings.bMarketPrice;
			return _bShowCustRate;
		}
		
		/*.................Show Custom Print Quotes.....................*/
		private var _bShowCustomPrintQuotes:Boolean = false;
		[Bindable(Event="bShowCustomPrintQuotes")]
		public function get bShowCustomPrintQuotes():Boolean
		{
			return _bShowCustomPrintQuotes;
		}
		//fake setter since the logic does not use the Boolean passed in
		public function set bShowCustomPrintQuotes(b:Boolean):void
		{
			_bShowCustomPrintQuotes = this.program.template.bCustomPrint &&
				this.component.fixedType != com.ContractProds.models.ComponentManager.FIXED_CUST_RATE_TYPE_ID &&
				this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups  && 
				this.component.type == 1   && 
				!this.oSettings.bMarketPrice;
			dispatchEvent(new Event('bShowCustomPrintQuotes'));
		}
		
		/*.................state......................*/
		private var _state:String = UNSELECTED;
		[Bindable(Event="stateChange")]
		public function get state():String
		{
			return _state;
		}
		
		/*.................title......................*/
		private var _title:String = "Component";
		[Bindable(Event="stateChange")]
		public function get title():String
		{
			return _title;
		}
		/*.................status......................*/
		private var _status:String = "";
		[Bindable(Event="stateChange")]
		public function get status():String
		{
			return _status;
		}
		
		/*.................submitLabel......................*/
		private var _submitLabel:String = "add component";
		[Bindable(Event="stateChange")]
		public function get submitLabel():String
		{
			return _submitLabel;
		}
		/*.................deleteLabel......................*/
		private var _deleteLabel:String = "delete component";
		[Bindable(Event="stateChange")]
		public function get deleteLabel():String
		{
			return _deleteLabel;
		}
		/*.................selectedUomIdx......................*/
		private var _selectedUomIdx:Number = 0;
		[Bindable(Event="selectedUomIdxChange")]
		public function get selectedUomIdx():Number
		{
			var i:Number = 0;
			_selectedUomIdx = i;
			for each(var u:Uom in this.componentDef.uom){
				if(u.bDefault){
					_selectedUomIdx = i;
					break;
				}
				i++
			}
			return _selectedUomIdx;
		}
		/*.......................  Methods  .......................*/
		public function setSelectedComponentDef(compDef:Object):void
		{
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_DEF);
			event.compDef = compDef as ComponentDef;
			this.dispatcher.dispatchEvent(event);
			
			var comp:Component = findComponent(compDef as ComponentDef);
			if(comp){
				selectComponent(comp);
			}
			else{
				addComponent(compDef as ComponentDef);
			}
		}
		 
		public function setSelectComponentType(i:int):void
		{
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.SELECT_COMPONENT_TYPE);
			event.typeId = i;
			this.dispatcher.dispatchEvent(event);
		}

		/*.................selectComponent......................*/
		public function selectComponent( component:Component ):void
		{
			_submitLabel = "update " + component.name;
			_deleteLabel = "delete " + component.name;
			_title = "EDITING " + component.name;
			_state = SELECTED;
			_tempComponent = new Component( component );
			_component = component;
			
			dispatchEvent( new Event( "stateChange" ) );
			dispatchEvent( new Event( "ComponentChange" ) );
			/* SELECT -> ComponentManager.setComponent() */
			var event:ComponentEvent = new ComponentEvent( ComponentEvent.SELECT );
			event.component = component;
			dispatcher.dispatchEvent( event );
		}
		
		/*.................addNewComponent......................*/
		public function addComponent(compDef:ComponentDef):void
		{
			_submitLabel = "add component";
			_title = "ADD " + compDef.name;
			_state = ADD_NEW;
			var payCyc:PaymentCycle = compDef.paymentCycle[0];
			var pdTo:PaidTo = compDef.paidTo[0];
			//set default PaymentCycle (from template if there is one)
			for each(var c:PaymentCycle in compDef.paymentCycle){
				if(c.bDefault){
					payCyc = c;
					break;
				}
			}
			_tempComponent = new Component( );
			_tempComponent.bMarketPriceTemplate = this.program.bMarketPriceTemplate;
			_tempComponent.claimMechanic = compDef.claimMechanic[0];
			_tempComponent.componentId = compDef.componentId;
			_tempComponent.name = compDef.name;
			
			for each(var p:PaidTo in compDef.paidTo){
				if(p.bDefault){
					pdTo = p;
					break;
				}
			}
			_tempComponent.paidTo = pdTo;
			
			_tempComponent.paymentCycle = payCyc;
			_tempComponent.glAccount = compDef.glAccount[0];
			_tempComponent.payee = new Payee();
			//_tempComponent.prodRate = compDef.;
			_tempComponent.type = compDef.type;
			_tempComponent.fixedType = compDef.fixedType;
			_tempComponent.uom = compDef.uom;
			_tempComponent.componentDef = compDef;
			//_component = null;
			
			var event:ComponentEvent = new ComponentEvent( ComponentEvent.SELECT );
			event.component = new Component( _tempComponent );
			dispatcher.dispatchEvent( event );
			
			dispatchEvent( new Event( "stateChange" ) );
			dispatchEvent( new Event( "ComponentChange" ) );
		}
		/*.................deleteComponent......................*/
		public function deleteComponent():void
		{
			_title = "DELETE " + component.name;
			_state = UNSELECTED;
			_tempComponent = new Component( );
			//_component = null;
			
			var event:ComponentEvent = new ComponentEvent( ComponentEvent.DELETE );
			event.component = component;
			dispatcher.dispatchEvent( event );
			/* reset the component selection */
			setSelectComponentType(0);
			dispatchEvent( new Event( "stateChange" ) );
			dispatchEvent( new Event( "ComponentChange" ) );
		}
		
		/*.................save......................*/
		public function save():void
		{
			var type:String = ( state == ADD_NEW ) ? ComponentEvent.ADD : ComponentEvent.UPDATE;
			var event:ComponentEvent = new ComponentEvent( type );
			event.component = _tempComponent;
			dispatcher.dispatchEvent( event );

			_submitLabel = "update " + component.name;;
			_deleteLabel = "delete " + component.name;
			_title = "EDITING " + component.name;
			_state = SELECTED;
			dispatchEvent( new Event( "stateChange" ) );
		}
		
		/*.................findComponent......................*/
		public function findComponent( comp:ComponentDef ):Component
		{
			var compFound:Component;
			for each( var currentComp:Component in acComponents)
			{
				if( comp.componentId == currentComp.componentId &&  comp.type == currentComp.type)
				{
					compFound = currentComp;
					break;
				}
			}
			return compFound;
		}
		/*.................apply Rate/Uom......................*/
		public function setRateUom(n:String,u:Uom,action:int,adg:FilterAdvancedDatagrid):void
		{
			var pr:ProdRate = new ProdRate();
			pr.uom = u;
			pr.rate = parseFloat(n) as Number;
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RATE_UOM);
			event.prodRate = pr;
			event.iUomAction = action;
			event.adg = adg;
			this.dispatcher.dispatchEvent(event);
		}
		/*  update component.claimMechanic*/
		public function updateClaimMechanic(  value:Object ):void
		{
			this._tempComponent.claimMechanic = value as ClaimMechanic;
			if(_tempComponent.claimMechanic){
				_tempComponent.payee.payeeTypeId = _tempComponent.claimMechanic.payeeTypeId;
			}
			//dispatchEvent( new Event( "ComponentChange" ) );
			save();
		}
		/*  update component.*/
		public function updateComponentId(  value:int):void
		{
			this._tempComponent.componentId = value;
			save();
		}
		/*  update component.name*/
		public function updateName(  value:String):void
		{
			this._tempComponent.name = value;
			save();
		}
		/*  update component.paidTo*/
		public function updatePaidTo(  value:Object):void
		{
			this._tempComponent.paidTo = value as PaidTo;
			save();
		}
		/*  update component.payee*/
		public function updatePayee(  value:Object):void
		{
			this._tempComponent.payee.payeeTypeId = value.value;
			this._tempComponent.payee.payeeId = '';
			this._tempComponent.payee.name = '';
			save();
		}
		/*  update component.paymentCycle*/
		public function updatePaymentCycle(  value:Object):void
		{
			this._tempComponent.paymentCycle = value as PaymentCycle;
			save();
		}
		/*  update component.prodRate*/
		public function updateProdRate(  value:Array):void
		{
			this._tempComponent.prodRate = value;
			save();
		}
		/*  update component.type*/
		public function updateType(  value:int):void
		{
			this._tempComponent.type = value;
			save();
		}
		/*  update component.glAccount*/
		public function updateGlAccount(  value:Object):void
		{
			this._tempComponent.glAccount = value as GlAccount;
			save();
		}
		/*  update component.uom THIS Property has A Public Var UNLIKE the others*/
		public function updateUom(  value:Object):void
		{
			this.uom = value as Uom;
			save();
		}
		
		/*  update CUSTOM PRINT PrintChargeColors  */
		public function updatePrintChargeColors(  value:int):void
		{
			//this.PrintChargeColors = value as PrintChargeColors;
			this._tempComponent.customPrint.iColors = value;
			save();
			//this.updatePrintCharge(value);
		}
		/*  update CUSTOM PRINT PrintChargeGraphics  */
		public function updatePrintChargeGraphics(value:String):void
		{
			//this.PrintChargeGraphics = value as PrintChargeGraphics;
			this._tempComponent.customPrint.sGraphics = value;
			save();
			//this.updatePrintCharge(value);
		}
		/*  update CUSTOM PRINT PrintChargeArt  */
		public function updatePrintChargeDigital( value:*):void
		{
			//this.PrintChargeArt= value as PrintChargeArt;
			this._tempComponent.customPrint.bDigital = new Boolean(value);
			save();
			//this.updatePrintCharge(value);
		}
		
		/*  update CUSTOM PRINT  */
		public function updatePrintCharge(value:*):void
		{
			var b:Boolean = true;
			var s:String = 'Missing selections:';
			if(this._tempComponent.customPrint.iColors == 0){
				s = s + '<li>Please select a # of colors.</li>';
				b = false;
			}
			
			if(this._tempComponent.customPrint.sGraphics == ''){
				s = s + '<li>Please select a graphics complexity.</li>';
				b = false;
			}
			
			var arrItems:Array = new Array();
			for each(var i:Item in this.itemList.source){
				if(i.isSelected && i.customPrint.bCustomPrint){
					var obj:Object = new Object();
					obj.itemGuid = i.itemGuid;
					obj.volume	= i.volume;
					arrItems.push(obj);
				}
			}
			if(arrItems.length == 0){
				s = s + "<li>Please select (check) '" + ComponentManager.CUSTOM_PRINT_BRAND + "' products to apply custom print options to.</li>";
				b = false;
			}
			
			if(b){
				this._tempComponent.customPrint.bCustomPrint = true;
				save();
				var event:ComponentEvent = new ComponentEvent( ComponentEvent.INSERT_CUSTOM_PRINT_COLS );
				event.component = this.component;
				event.arr1 = arrItems;
				dispatcher.dispatchEvent( event );	
				/* SearchEvent.GET_PROGRAM_PRODUCTS which loads Custom print charges based on settings
				is Called after (chained) from INSERT_CUSTOM_PRINT_COLS -> GridManager.as insertCustomPrintCols()*/
			}
			else{
				var alert:Alert = Alert.show(s);
				use namespace mx.core.mx_internal;
				IUITextField(alert.alertForm.textField).htmlText = s;
			}
		}
		
		/*  Remove CUSTOM PRINT  */
		public function removePrintCharge(value:*):void
		{
			this._tempComponent.customPrint = new CustomPrint();
			save();
			//Alert.show('Remove Cust Print :: ' + value.toString());
		}
		/*  get CUSTOM PRINT Print Groups available to convert */
		public function getPrintGroups():void
		{
			var arrItems:Array = new Array();
			var arrItemsTmp:Array = new Array();
			var arrItemsPartType:Array = new Array();
			var sId:String = '';
			sId = ComponentManager.getSelectedCompId(this.component);
			//Get Type_Code_desc (Part Type) for the groups with rates and "None"
			for each(var i:Item in this.itemList.source){
				var pr:ProdRate = i[sId].prodRate as ProdRate;
				if(i.isGroup && pr.rate > 0 && arrItemsPartType.indexOf(i.Type_Code_desc) == -1 && i.Type_Group_desc == ComponentManager.TYPE_GROUP_DESC){
					arrItemsPartType.push(i.Type_Code_desc);
				}
			}
			//arrItemsTmp is used to check for dupes
			//get all groups that have the same Type_Code_desc (Part Type) as the ones with rates (that need to be converted).
			// Brand_Name == 'Local Print' only for custom Print
			for each(var i:Item in this.itemList.source){
				if(i.isGroup && i.Brand_Name == 'Local Print'){
					if(arrItemsTmp.indexOf(i.Type_Group_desc)== -1 && 
						arrItemsPartType.indexOf(i.Type_Code_desc) != -1 && 
						i.Type_Group_desc != ComponentManager.TYPE_GROUP_DESC){
							arrItems.push(i);
							arrItemsTmp.push(i.Type_Group_desc);
					}
				}
				
			}
			arrItems.sortOn('Type_Group_desc');
			this.arrPrintGroup = arrItems;
			//Alert.show('Remove Cust Print :: ' + value.toString());
		}
		
		/*  get CUSTOM PRINT Print Groups available to convert */
		public function convertPrintGroups(i:Item):void
		{
			//Alert.show(ObjectUtil.toString(x));
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.CONVERT_ITEMS);
			e.item = i;
			this.dispatcher.dispatchEvent(e);
			//Alert.show(i.Type_Code_desc + ' :: ' + i.Brand_Name);
		}

		/*  select component.payee for pay single*/
		public function selectPayee():void
		{
			//showDistributorSearch()
			//Alert.show('All Payments should go to Mark Saunders.  PayeeTypeId: ' + this.component.payee.payeeTypeId as String,'Select a Payee')
			var e:MainEvent = new MainEvent(MainEvent.SEARCH_PAYEE);
			e.payeeTypeId = this._component.claimMechanic.payeeTypeId;
			e.settings= this.oSettings;
			this.dispatcher.dispatchEvent(e);
		}
		
		public function clickBorderBox(e:Event):void{
			e.clone();
		}
		/*.......................  SET SELECTEDINDEX FOR DROPDOWNS/SELECTIONS  .........................*/
		/*  update component.claimMechanic*/
		public function setClaimMechanicIdx():void
		{
			var i:int = 0;
			for each(var c:ClaimMechanic in this.componentDef.claimMechanic){
				if(c.claimMechanicId == this.component.claimMechanic.claimMechanicId){
					claimMechanicIdx = i;
					dispatchEvent( new Event( "cbxIxChgCm" ));
					break;
				}
				i++;
			}
		}
		/*  update component.paymentCycle*/
		public function setPaymentCycleIdx():void
		{
			var i:int = 0;
			
			for each(var c:PaymentCycle in this.componentDef.paymentCycle){
				if(c.paymentCycleId == this.component.paymentCycle.paymentCycleId){
					paymentCycleIdx = i;
					dispatchEvent( new Event( "cbxIxChgPc" ));
					break;
				}
				i++;
			}
		}
		/*  update component.paidTo*/
		public function setPaidToIdx():void
		{
			var i:int = 0;
			for each(var c:PaidTo in this.componentDef.paidTo){
				if(c.paidToId == this.component.paidTo.paidToId){
					paidToIdx = i;
					dispatchEvent( new Event( "cbxIxChgPt" ));
					break;
				}
				i++;
			}
		}
		/*  update component.glAccount*/
		public function setGlAccountIdx():void
		{
			var i:int = 0;
			for each(var c:GlAccount in this.componentDef.glAccount){
				if(this.component.glAccount && this.component.glAccount.hasOwnProperty("glAccountId")){
					if(c.glAccountId == this.component.glAccount.glAccountId){
						this.glAccountIdx = i;
						dispatchEvent( new Event( "cbxIxChgGl" ));
						break;
					}
					
				}
				i++;
			}
		}
		/*  update component.componentDef*/
		public function setComponentDefIdx():void
		{
			var i:int = 0;
			for each(var c:ComponentDef in this._acComponentDefs){
					if(this.component.type == c.type && this.component.componentId == c.componentId){
						this.componentDefIdx = i;
						dispatchEvent( new Event( "cbxIxChgCd" ));
						break;
					}
				i++;
			}
		}
		/* deprecated i think...used to determine enabled for id="rdoPayeeOptGroup */
		public function getPayeeOption():Boolean
		{
			var b:Boolean = (state != ComponentPM.UNSELECTED) && (_tempComponent.payee.payeeTypeId > 0);
			return b;
		}
		
		public var _decFormat:NumberFormatter =  new NumberFormatter();
        public function formatDecimal(s:String):String 
	    {
	    	_decFormat.precision = 4
	    	if(!isNaN(Number(s))){
	    		return _decFormat.format(s);
	    	}
	    	else{
	    		return '';
	    	}
			
	    }
	    
	    /* .................................... IMPORT/EXPORT PRODRATES ....................................... */
	    
	    public function exportProdRates():void
		{
			/* do simething */
		}
		public function importProdRates():void
		{
			/* do simething */
		}

	}
}