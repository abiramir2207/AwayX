package com.Billback.Search.views.pm
{
	import com.Billback.Search.events.BBSearchEvent;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import com.Billback.Search.vos.BBFilterDef;
	
	public class BBSearchPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBSearchPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		/*.................acData......................*/
		/*private var _acData:ArrayCollection = new ArrayCollection();
		[Bindable (event="acDataChanged")]
		public function get acData():ArrayCollection
		{
		return _acData;
		}
		public function set acData(acData:ArrayCollection):void
		{
		this.acData = acData;
		dispatchEvent(new Event('acDataChanged'));
		}*/
		/*.................oSettings......................*/
		/*private var _oSettings:Settings = new Settings();
		[Bindable (event="settingsChanged")]
		public function get oSettings():Settings
		{
		return _oSettings;
		}
		public function set oSettings(settings:Settings):void
		{
		this._oSettings = settings;
		dispatchEvent(new Event('settingsChanged'));
		}*/
		[Bindable]
		public var acData:ArrayCollection = new ArrayCollection();
		//[Bindable]
		//public var acLookupData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var oSettings:Settings = new Settings();			
	}
}