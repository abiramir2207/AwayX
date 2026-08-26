package com.ContractProds.models
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.ContractProds.events.ComponentEvent;
	import mx.collections.ArrayCollection;
	import com.ContractProds.vos.ComponentDef;
	import flash.events.IEventDispatcher;
	import com.ContractProds.vos.ClaimMechanic;
	import com.ContractProds.vos.PaidTo;
	import com.ContractProds.vos.PaymentCycle;
	import com.ContractProds.vos.Uom;
	
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
		/*-.........................................Methods..........................................*/
		public function setComponentDefs(event:ComponentEvent):void
		{
			var i:int = event.typeId;
			if(i == ComponentManager.FIXED_TYPE_ID){
				this._acComponentDefs = this._acComponentDefsFix
			}
			else if(i == ComponentManager.REBATE_TYPE_ID){
				this._acComponentDefs = this._acComponentDefsReb
			}
			dispatchEvent(new Event('ComponentDefsChange'));
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
			dispatchEvent( new Event("ComponentDefsChange") );
		}

	}
}