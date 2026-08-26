package com.Billback.Upload.views.pm
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Upload.events.BBUploadEvent;
	
	import com.Billback.Upload.models.vos.BBRawEDIHeader;
	import com.Billback.Upload.models.vos.BBRawEDIDetail;
	
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.components.filters.FilterDatagrid;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.DataGridEvent;
	import mx.utils.ObjectUtil;
	
	public class BBRawEDIItemsPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBRawEDIItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var arrBBRawEDIItemsDgCols:Array = new Array();
		
		/*.................bbUploadHeader......................*/
		private var _bbRawEDIHeader:BBRawEDIHeader = new BBRawEDIHeader();
		[Bindable (event="iPMbbRawEDIHeaderChanged")]
		public function get bbRawEDIHeader():BBRawEDIHeader
		{
			return _bbRawEDIHeader;
		}
		public function set bbRawEDIHeader(bbREH:BBRawEDIHeader):void
		{
			var bSetArrError:Boolean = (this.bbRawEDIHeader.bbRawEDIDetail != bbREH.bbRawEDIDetail);
			this._bbRawEDIHeader = bbREH;
			if(bbREH.bbRawEDIDetail.length && bSetArrError){
				this.selectRow(this.bbRawEDIHeader.bbRawEDIDetail[0]);
			}
			dispatchEvent(new Event('iPMbbRawEDIHeaderChanged'));
		}
		
		/*.................bbUploadDetail......................*/
		private var _bbRawEDIDetail:BBRawEDIDetail = new BBRawEDIDetail();
		[Bindable (event="bbRawEDIDetailChanged")]
		public function get bbRawEDIDetail():BBRawEDIDetail
		{
			return _bbRawEDIDetail;
		}
		public function set bbRawEDIDetail(bbRawEDIDetail:BBRawEDIDetail):void
		{
			this._bbRawEDIDetail = bbRawEDIDetail;
			dispatchEvent(new Event('bbRawEDIDetailChanged'));
		//	this.setArrDetailError();
		}
		
		/*...................   arrDetailError  .....................*/
/*		private var _arrDetailError:Array = new Array();
		[Bindable (event="arrDetailErrorChanged")]
		public function get arrDetailError():Array
		{
			return _arrDetailError;
		}
		public function set arrDetailError(inValue:Array):void
		{
			_arrDetailError = inValue;
			dispatchEvent(new Event('arrDetailErrorChanged'));
		}*/
		
		/*...................   arrDetailErrorAll  .....................*/
/*		private var _arrDetailErrorAll:Array = new Array();
		[Bindable (event="arrDetailErrorAllChanged")]
		public function get arrDetailErrorAll():Array
		{
			return _arrDetailErrorAll;
		}
		public function set arrDetailErrorAll(inValue:Array):void
		{
			_arrDetailErrorAll = inValue;
			dispatchEvent(new Event('arrDetailErrorAllChanged'));
		}	*/	
		
		
		[Bindable] public var filterInsert:Function =
			function():Boolean{
				return true;
			};
 
		public function updateCols():void{
			//hello
		}
		
		public function selectRow(bbRawEDIDetail:BBRawEDIDetail):void{
			this.bbRawEDIDetail = bbRawEDIDetail;
		}
		
		private function clearError():void{
			
		}
		
/*		private function highlightError(rndr:TextInput):void{
			//setStyle("color", 0xFF0000);
		}*/

	}
}