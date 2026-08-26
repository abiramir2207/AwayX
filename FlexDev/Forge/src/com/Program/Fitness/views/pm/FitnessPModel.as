package com.Program.Fitness.views.pm
{

	import com.Program.Fitness.events.FitnessEvent;
	import com.Program.Fitness.models.vos.FitnessSearchDef;
	import com.shared.views.renderer.BaCombo;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import spark.components.DropDownList;

	[Bindable]
	public class FitnessPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function FitnessPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		public var acFitness:ArrayCollection = new ArrayCollection();
		
		/*.................oSettings......................*/
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="fPmsettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			this.dispatchEvent(new Event('fPmsettingsChanged'));
		}
		
		/*.................fitnessSearchDef......................*/
		private var _fitnessSearchDef:FitnessSearchDef = new FitnessSearchDef();
		[Bindable (event="fitnessSearchDefChangedPMod")]
		public function get fitnessSearchDef():FitnessSearchDef
		{
			return _fitnessSearchDef;
		}
		public function set fitnessSearchDef(fitnessSearchDef:FitnessSearchDef):void
		{			
	
			this._fitnessSearchDef = fitnessSearchDef;
			dispatchEvent(new Event('fitnessSearchDefChangedPMod'));
		}
		
		/*.................acFitnessItems......................*/
		private var _acFitnessItems:ArrayCollection = new ArrayCollection();
		[Bindable (event="acFitnessItemsChangedPM")]
		public function get acFitnessItems():ArrayCollection
		{
			return _acFitnessItems;
		}
		public function set acFitnessItems(ac:ArrayCollection):void
		{			
			this._acFitnessItems = ac;
			dispatchEvent(new Event('acFitnessItemsChangedPM'));	
		}
		
		/*..........................  METHODS  .............................*/
		
		public function updSearchDef(cmbo:BaCombo,s:String):void{
			this.fitnessSearchDef.Current = s;
			s = s +'Idx';
			this.fitnessSearchDef[s] = cmbo.selectedIndex;
			
			//Alert.show(ObjectUtil.toString(this.fitnessSearchDef),'AAAAAA');
			
			resetSearchDef(this.fitnessSearchDef.Current);
			
			//Alert.show(ObjectUtil.toString(this.fitnessSearchDef),'BBBBBB');
			
			if(cmbo.selectedIndex != 0){
				var evt:FitnessEvent = new FitnessEvent(FitnessEvent.LOAD_HEADER_DATA);
				evt.fitnessSearchDef = this.fitnessSearchDef;
				this._dispatcher.dispatchEvent(evt);	
			}
			
		}
		
		public function updSearchDefSpark(cmbo:DropDownList,s:String):void{
			this.fitnessSearchDef.Current = s;
			s = s +'Idx';
			this.fitnessSearchDef[s] = cmbo.selectedIndex;
			resetSearchDef(this.fitnessSearchDef.Current);
			
			if(cmbo.selectedIndex != 0){
				var evt:FitnessEvent = new FitnessEvent(FitnessEvent.LOAD_HEADER_DATA);
				evt.fitnessSearchDef = this.fitnessSearchDef;
				this._dispatcher.dispatchEvent(evt);	
			}
			
		}
		
		private function resetSearchDef(s:String):void{
			//reset details data if there is any
			if(this.acFitnessItems.length){
				var arr:Array = new Array();
				var e:FitnessEvent = new FitnessEvent(FitnessEvent.SET_DETAIL_DATA);
				e.a = arr;
				this._dispatcher.dispatchEvent(e);
			}
			
			
			//reset lower level properties
			// Get the Button control's E4X XML object description.
			var SNum:String = s.substr(s.length-1,s.length);
			var n:int = int(SNum);
			var classInfo:XML = describeType(fitnessSearchDef);
			
			// List accessors as properties.
			for each (var a:XML in classInfo..accessor) {
				for (var i:int=0;i < 6;i++){
					var ss:String = a.@name;
					var sCheck:String = ss.substr(ss.length-3,ss.length);
					if(sCheck != 'Idx'){
						var nn:int = int(ss.substr(ss.length-1,ss.length));
						//if the property comes after the one that has 'All' selected, reset
						if(nn > n){
							this.fitnessSearchDef[a.@name] = new Array();
							this.fitnessSearchDef[a.@name + 'Idx'] = 0;
						}
						/*if(nn == n){
							this.fitnessSearchDef['Current'] = a.@name;
						}*/
					}
				}
			}
			//call setter
			//this.fitnessSearchDef = _fitnessSearchDef;
			var evt:FitnessEvent = new FitnessEvent(FitnessEvent.SET_HEADER_DATA);
			evt.fitnessSearchDef = this.fitnessSearchDef;
			this._dispatcher.dispatchEvent(evt);
			
		}

		public function updSearchDefFinal(cmbo:BaCombo,s:String):void{
			this.fitnessSearchDef.Current = s;
			s = s +'Idx';
			this.fitnessSearchDef[s] = cmbo.selectedIndex;

			if(cmbo.selectedIndex != 0){
				var evt:FitnessEvent = new FitnessEvent(FitnessEvent.LOAD_Fitness);
				evt.fitnessSearchDef = this.fitnessSearchDef;
				this._dispatcher.dispatchEvent(evt);	
			}
			
		}
		
	
	}
}