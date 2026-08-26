package com.ContractProds.models
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.ContractProds.events.ComponentEvent;
	import mx.collections.ArrayCollection;
	import com.ContractProds.vos.FilterParms;
	import com.shared.vos.Settings;
	import flash.events.IEventDispatcher;
	
	public class FilterManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function FilterManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................  Properties  .......................*/
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="FMsettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			dispatchEvent(new Event('FMsettingsChanged'));
		}
		
		/*  FilterParms */
		private var _oFilterParms:FilterParms = new FilterParms();
		[Bindable (event="FMFilterParmsChanged")]
		public function get oFilterParms():FilterParms
		{
			return _oFilterParms;
		}
	/* 	public function set oFilterParms(f:FilterParms):void
		{
			this._oFilterParms = f;
			dispatchEvent(new Event('pmFilterParmsChanged'));
		} */
		
		/*-.........................................Methods..........................................*/
		public function setFilterParms(f:FilterParms):void
		{
			this._oFilterParms = new FilterParms(f);
			dispatchEvent(new Event('FMFilterParmsChanged'));
		}
		

	}
}