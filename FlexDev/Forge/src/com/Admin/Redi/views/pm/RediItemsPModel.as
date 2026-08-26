package com.Admin.Redi.views.pm
{
	import com.Billback.Main.models.vos.BBHeader;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class RediItemsPModel
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function RediItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var acItemData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var bbHeader:BBHeader = new BBHeader();
		[Bindable]
		public var arrRediItemsDgCols:Array = new Array();
	}
}