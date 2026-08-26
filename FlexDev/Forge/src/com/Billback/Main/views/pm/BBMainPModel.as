package com.Billback.Main.views.pm
{
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class BBMainPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		/*public function BBMainPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}*/
		
		
		/*.......................  Properties  .......................*/
		
		
		/*.................oSettings......................*/
		private var _oSettings:Settings = new Settings();
		[Bindable (event="bbMainsettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(settings:Settings):void
		{
			this._oSettings = settings;
			//since user object with MARKET_PRICE_VARIANCE is updated, update Button Label
			dispatchEvent(new Event('bbMainsettingsChanged'));
		}
		
		/*.......................  Methods  .......................*/
		
		
	}
}