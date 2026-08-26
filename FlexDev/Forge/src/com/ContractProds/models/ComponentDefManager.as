package com.ContractProds.models
{
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.vos.ComponentDef;
	import com.shared.vos.ClaimMechanic;
	import com.shared.vos.Component;
	import com.shared.vos.PaidTo;
	import com.shared.vos.PaymentCycle;
	import com.shared.vos.Uom;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class ComponentDefManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function ComponentDefManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			//this.saveComponentDefs();
			//this.saveComponentDefsFix();
		}
		
		/*.......................................  Properties  ......................................*/
		private var _acComponentDefsFix:ArrayCollection = new ArrayCollection();
		private var _acComponentDefsReb:ArrayCollection = new ArrayCollection();
		//.................ComponentDef......................
		private var _componentDef:ComponentDef = new ComponentDef();
		[Bindable (event="ComponentDef")]
		public function get componentDef():ComponentDef
		{
			return _componentDef;
		}
		//.................acComponentDefs......................
		private var _acComponentDefs:ArrayCollection = new ArrayCollection();;
		[Bindable (event="ComponentDefsChange")]
		public function get acComponentDefs():ArrayCollection
		{
			return _acComponentDefs;
		}
		public function set acComponentDefs(acComdefs:ArrayCollection):void
		{
			this._acComponentDefs = acComdefs;
			dispatchEvent(new Event('ComponentDefsChange'));
		}
		/* Component */
		private var _component:Component = new Component();
		[Bindable (event="CompDefComponentChange")]
		public function get component():Component
		{
			return _component;
		}
		public function set component(comp:Component):void
		{
			this._component = comp;
			dispatchEvent(new Event('CompDefComponentChange'));
		}
		/*-.........................................Methods..........................................*/
		public function setComponentDefs(event:ComponentEvent):void
		{
			var i:int = event.typeId;
			if(i == 0){
				var cDef:ComponentDef =  acComponentDefs[0] as ComponentDef;
				i = cDef.type;
			}
			if(i == ComponentManager.FIXED_TYPE_ID){
				this.acComponentDefs = this._acComponentDefsFix
			}
			else if(i == ComponentManager.REBATE_TYPE_ID){
				this.acComponentDefs = this._acComponentDefsReb
			}
		}
		//.................setSelectedcomponentDef......................
		public function setComponentDef(compDef:ComponentDef):void
		{
			this._componentDef = compDef;
			dispatchEvent(new Event('ComponentDef'));
		}
		//.................selectComponentDef......................
		public function selectComponentDef(sId:String):void
		{
			for each(var compDef:ComponentDef in _acComponentDefs){
				var s:String = '';
				s = s + compDef.type as String;
				s = s + compDef.componentId as String;
				if(s == sId){
					setComponentDef(compDef);
				}
			}
		}
		//.................storeComponentDefs......................
		public function saveComponentDefs( arr:Array = null ):void
		{
			/* loop over and cast members */
			for each(var cd:ComponentDef in arr){
				//compDef = cd as ComponentDef;
				//this._acComponentDefs.addItem(new ComponentDef(compDef));
				if(cd.type == ComponentManager.FIXED_TYPE_ID){
					_acComponentDefsFix.addItem(cd);
				}
				else if(cd.type == ComponentManager.REBATE_TYPE_ID){
					_acComponentDefsReb.addItem(cd);
				}
			}
			if(this.component.type != 0){ //if a comp exists select the def for it
				var s:String = '';
				s = s + this.component.type as String;
				s = s + this.component.componentId as String;
				if(this.component.type == 1){
					this.acComponentDefs = this._acComponentDefsFix
				}
				else if(this.component.type == 2){
					this.acComponentDefs = this._acComponentDefsReb
				}
				this.selectComponentDef(s);
			}
			else{ //pick the default
				for each( var cDef:ComponentDef in this._acComponentDefsReb){
					if(cDef.bDefaultComp){
						this.acComponentDefs = this._acComponentDefsReb
					}
				}
				for each( var cDef:ComponentDef in this._acComponentDefsFix){
					if(cDef.bDefaultComp){
						this.acComponentDefs = this._acComponentDefsFix
					}
				}
				if(this.acComponentDefs.length){
					setComponentDef(this.acComponentDefs[0]);
				}
			}
			
		}

	}
}