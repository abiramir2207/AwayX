package com.Billback.Upload.views.pm
{
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class BBUploadFilterPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBUploadFilterPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var bbUploadHeader:BBUploadHeader = new BBUploadHeader();
		[Bindable]
		public var iFrmHeight:int = 20;
		
		
	}
}