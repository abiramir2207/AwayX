package com.Billback.Main.models
{
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	public class BBMainManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		/*private var _dispatcher:IEventDispatcher;
		public function BBSearchManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}*/
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		
		
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here:  + {ObjectUtil.toString(x)}' );
			
		}		
	}
}