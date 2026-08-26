package com.ContractProds.views.pm
{
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.vos.ClaimMechanic;
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.ComponentDef;
	import com.ContractProds.vos.GlAccount;
	import com.ContractProds.vos.PaidTo;
	import com.ContractProds.vos.Payee;
	import com.ContractProds.vos.PaymentCycle;
	import com.ContractProds.vos.ProdRate;
	import com.ContractProds.vos.Program;
	import com.ContractProds.vos.Uom;
	import com.shared.events.MainEvent;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.NumberFormatter;
	
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
		
		[Bindable (event="cbxIxChgPc")] public var paymentCycleIdx:int = 0;
		[Bindable (event="cbxIxChgPt")] public var paidToIdx:int = 0;
		[Bindable (event="cbxIxChgCm")] public var claimMechanicIdx:int = 0;
		[Bindable (event="cbxIxChgGl")] public var glAccountIdx:int = 0;
		[Bindable (event="cbxIxChgCd")] public var componentDefIdx:int = 0;
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
			/* ..........  IDx Done  ......... */
			dispatchEvent(new Event('ComponentChange'));
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
			dispatchEvent(new Event('ProgramChange'));
			
			_bPaymentCycleEdit = true;
			_bClaimMechanicEdit = true;
			
			if(prg.bRevision){
				if(prg.template.paymentFrequencyChanges == 2){
					_bPaymentCycleEdit = false;
				}
				if(prg.template.claimMechanicChanged == 2){
					_bClaimMechanicEdit = false;
				}
				
			}
			dispatchEvent(new Event('bbPaymentCycleEditChange'));
			dispatchEvent(new Event('bClaimMechanicEditChange'));
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
			this.dispatchEvent(new Event('ComponentsChange'));
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
			}
			this._acComponentDefs = acCompDef;
			this.dispatchEvent(new Event('pmComponentDefs'));
			this.setComponentDefIdx();
			this.dispatchEvent( new Event( "cbxIxChgCd" ));
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
			this.dispatchEvent(new Event('resultsLogChange'));
		}
		/*.................bClaimMechanicEdit......................*/
		private var _bClaimMechanicEdit:Boolean = true;
		[Bindable(Event="bClaimMechanicEditChange")]
		public function get bClaimMechanicEdit():Boolean
		{
			return _bClaimMechanicEdit;
		}
		/*.................bPaymentCycleEdit......................*/
		private var _bPaymentCycleEdit:Boolean = true;;
		[Bindable(Event="bbPaymentCycleEditChange")]
		public function get bPaymentCycleEdit():Boolean
		{
			return _bPaymentCycleEdit;
		}
		
		/*.................state......................*/
		private var _state:String = ComponentPM.UNSELECTED;
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
			_title = "Editing " + component.name;
			_state = ComponentPM.SELECTED;
			this._tempComponent = new Component( component );
			this._component = component;
			
			this.dispatchEvent( new Event( "stateChange" ) );
			this.dispatchEvent( new Event( "ComponentChange" ) );
			/* SELECT -> ComponentManager.setComponent() */
			var event:ComponentEvent = new ComponentEvent( ComponentEvent.SELECT );
			event.component = component;
			this.dispatcher.dispatchEvent( event );
		}
		
		/*.................addNewComponent......................*/
		public function addComponent(compDef:ComponentDef):void
		{
			_submitLabel = "add component";
			_title = "Add" + compDef.name;
			_state = ComponentPM.ADD_NEW;
			this._tempComponent = new Component( );
			this._tempComponent.bMarketPriceTemplate = this.program.bMarketPriceTemplate;
			this._tempComponent.claimMechanic = compDef.claimMechanic[0];
			this._tempComponent.componentId = compDef.componentId;
			this._tempComponent.name = compDef.name;
			this._tempComponent.paidTo = compDef.paidTo[0];
			this._tempComponent.paymentCycle = compDef.paymentCycle[0];
			this._tempComponent.glAccount = compDef.glAccount[0];
			this._tempComponent.payee = new Payee();
			//_tempComponent.prodRate = compDef.;
			this._tempComponent.type = compDef.type;
			this._tempComponent.uom = compDef.uom;
			//_component = null;
			
			var event:ComponentEvent = new ComponentEvent( ComponentEvent.SELECT );
			event.component = new Component( this._tempComponent );
			this.dispatcher.dispatchEvent( event );
			
			this.dispatchEvent( new Event( "stateChange" ) );
			this.dispatchEvent( new Event( "ComponentChange" ) );
		}
		/*.................deleteComponent......................*/
		public function deleteComponent():void
		{
			_title = "delete " + this.component.name;
			_state = ComponentPM.UNSELECTED;
			this._tempComponent = new Component( );
			//_component = null;
			
			var event:ComponentEvent = new ComponentEvent( ComponentEvent.DELETE );
			event.component = this.component;
			this.dispatcher.dispatchEvent( event );
			/* reset the component selection */
			setSelectComponentType(0);
			this.dispatchEvent( new Event( "stateChange" ) );
			this.dispatchEvent( new Event( "ComponentChange" ) );
		}
		
		/*.................save......................*/
		public function save():void
		{
			var type:String = ( state == ComponentPM.ADD_NEW ) ? ComponentEvent.ADD : ComponentEvent.UPDATE;
			var event:ComponentEvent = new ComponentEvent( type );
			event.component = this._tempComponent;
			this.dispatcher.dispatchEvent( event );

			_submitLabel = "update " + this.component.name;;
			_deleteLabel = "delete " + this.component.name;
			_title = "Editing " + this.component.name;
			_state = ComponentPM.SELECTED;
			this.dispatchEvent( new Event( "stateChange" ) );
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
		public function setRateUom(n:String,u:Uom,action:int):void
		{
			var pr:ProdRate = new ProdRate();
			pr.uom = u;
			pr.rate = parseFloat(n) as Number;
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.SET_RATE_UOM);
			event.prodRate = pr;
			event.iUomAction = action;
			this.dispatcher.dispatchEvent(event);
		}
		/*  update component.claimMechanic*/
		public function updateClaimMechanic(  value:Object ):void
		{
			this._tempComponent.claimMechanic = value as ClaimMechanic;
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

		/*  select component.payee for pay single*/
		public function selectPayee():void
		{
			//showDistributorSearch()
			//Alert.show('All Payments should go to Mark Saunders.  PayeeTypeId: ' + this.component.payee.payeeTypeId as String,'Select a Payee')
			var e:MainEvent = new MainEvent(MainEvent.SEARCH_PAYEE);
			e.payeeTypeId = this._component.claimMechanic.payeeTypeId;
			this.dispatcher.dispatchEvent(e);
		}
		/*.......................  SET SELECTEDINDEX FOR DROPDOWNS/SELECTIONS  .........................*/
		/*  update component.claimMechanic*/
		public function setClaimMechanicIdx():void
		{
			var i:int = 0;
			for each(var c:ClaimMechanic in this.componentDef.claimMechanic){
				if(c.claimMechanicId == this.component.claimMechanic.claimMechanicId){
					this.claimMechanicIdx = i;
					this.dispatchEvent( new Event( "cbxIxChgCm" ));
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
					this.paymentCycleIdx = i;
					this.dispatchEvent( new Event( "cbxIxChgPc" ));
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
					this.paidToIdx = i;
					this.dispatchEvent( new Event( "cbxIxChgPt" ));
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
						this.dispatchEvent( new Event( "cbxIxChgGl" ));
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
						this.dispatchEvent( new Event( "cbxIxChgCd" ));
						break;
					}
				i++;
			}
		}
		/* deprecated i think...used to determine enabled for id="rdoPayeeOptGroup */
		public function getPayeeOption():Boolean
		{
			var b:Boolean = (state != ComponentPM.UNSELECTED) && (this._tempComponent.payee.payeeTypeId > 0);
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