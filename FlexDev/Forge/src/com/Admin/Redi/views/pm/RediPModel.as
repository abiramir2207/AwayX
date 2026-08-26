package com.Admin.Redi.views.pm
{
	import com.Admin.Redi.events.RediEvent;
	import com.Admin.Redi.models.vos.RediCorrectionHeader;
	import com.Admin.Redi.models.vos.RediSettings;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBHeader;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.views.renderer.BaButton;
	import com.shared.vos.GlAccount;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	public class RediPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function RediPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		
		/*.................oSettings......................*/
		[Bindable]
		public var iPadding:Number = 0;
		[Bindable]
		public var iWidth:Number = 880;
		[Bindable]
		public var iHeight:Number = 17;
		[Bindable]
		public var iPaddingfrm:Number = 3;
		[Bindable]
		public var acRedi:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var arrRediOpenDgCols:Array = new Array();
		[Bindable]
		public var arrRediHistoryDgCols:Array = new Array();
		[Bindable]
		public var sourceTypes:Array = new Array();
		[Bindable]
		public var rediSettings:RediSettings = new RediSettings();
		
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="rediPMMansettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			//updateGridColsHeaderText();
			dispatchEvent(new Event('rediPMMansettingsChanged'));
			if(s.appSettings.hasOwnProperty('Distributor_Label_Singular')){
				
			}
		}
		
		/*.................acRediOpen......................*/
		private var _acRediOpen:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediOpenPMIChanged")]
		public function get acRediOpen():ArrayCollection
		{
			return _acRediOpen;
		}
		public function set acRediOpen(ac:ArrayCollection):void
		{			
			this._acRediOpen = ac;
			dispatchEvent(new Event('acRediOpenPMIChanged'));
			//pass the count to the display
			this.recordCountLabel = ac.length.toString();
			if(ac.length){
				this.rediCorrectionHeader = ac[0];
			}
			else{
				this.rediCorrectionHeader = new RediCorrectionHeader();
			}
		}
		
		/*.................acRediHistory......................*/
		private var _acRediHistory:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediHistoryPMIChanged")]
		public function get acRediHistory():ArrayCollection
		{
			return _acRediHistory;
		}
		public function set acRediHistory(ac:ArrayCollection):void
		{			
			this._acRediHistory = ac;
			dispatchEvent(new Event('acRediHistoryPMIChanged'));	
		}
		
		/*.................acRediSettings......................*/
		private var _acRediSettings:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediSettingsPMIChanged")]
		public function get acRediSettings():ArrayCollection
		{
			return _acRediSettings;
		}
		public function set acRediSettings(ac:ArrayCollection):void
		{			
			this._acRediSettings = ac;
			dispatchEvent(new Event('acRediSettingsPMIChanged'));	
		}
		
		/*.................recordcount......................*/
		private var _sRecordCountLabel:String = '';
		[Bindable (event="sRecordCountLabelChanged")]
		public function get recordCountLabel():String
		{
			return _sRecordCountLabel;
		}
		public function set recordCountLabel(s:String):void
		{
			this._sRecordCountLabel = '(' + s + ' records)';
			dispatchEvent(new Event('sRecordCountLabelChanged'));
		}
		/*.................rediCorrectionHeader......................*/
		private var _rediCorrectionHeader:RediCorrectionHeader;
		[Bindable (event="rpmRediCorrectionHeaderChanged")]
		public function get rediCorrectionHeader():RediCorrectionHeader
		{
			return _rediCorrectionHeader;
		}
		public function set rediCorrectionHeader(rch:RediCorrectionHeader):void
		{
			_rediCorrectionHeader = rch;
			dispatchEvent(new Event('rpmRediCorrectionHeaderChanged'));
		}
		/*.................funcFilterInsert......................*/
		private var _funcFilterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="pmfuncFilterInsertChange")]
		public function get funcFilterInsert():Function
		{
			return _funcFilterInsert;
		}
		public function set funcFilterInsert(func:Function):void
		{
			this._funcFilterInsert = func;
			dispatchEvent(new Event('pmfuncFilterInsertChange'));
		}
		
		/*  update sourceType */
		public function updateOpenSourceType(rs:RediSettings):void
		{
			this.rediSettings = rs;
		}
		/*  update sourceType*/
		public function updateHistorySourceType(  value:Object):void
		{
			var s:* = value;
		}
		
		public function loadRediOpen():void{
			var evt:RediEvent = new RediEvent(RediEvent.LOAD_REDI_OPEN);
			this._dispatcher.dispatchEvent(evt)
		}
		
		public function loadRediHistory():void{
			var evt:RediEvent = new RediEvent(RediEvent.LOAD_REDI_HISTORY);
			this._dispatcher.dispatchEvent(evt)
		}
		
		public function openCorrectionEdit(h:RediCorrectionHeader,event:*):void{
			if(h && event && event.hasOwnProperty("target") && ( (event.target.hasOwnProperty("data") && event.target.data is RediCorrectionHeader) || event.target is BaButton)){
				var evt:RediEvent = new RediEvent(RediEvent.EDIT_CORRECTION);
				evt.rch = h;
				this._dispatcher.dispatchEvent(evt)
			}
			else if(!h){
				Alert.show("Please select (click) an invoice correction to edit in the data grid.");
			}
			
		}
		
		public function deleteSelectedCorrection():void{
			var arr:Array = new Array();
			for each(var rch:RediCorrectionHeader in this.acRediOpen.source){
				if(rch.isSelected == true){
					arr.push(rch);
				}
			}
			if(arr && arr.length){
				var evt:RediEvent = new RediEvent(RediEvent.DELETE_CORRECTION);
				evt.arr = arr;
				this._dispatcher.dispatchEvent(evt);
			}
			else{
				Alert.show("Please select (using check box) invoice correction(s) to delete in the data grid.");
			}
		}
		
		public function deleteCorrection(rch:RediCorrectionHeader):void{
			var arr:Array = new Array();
			arr.push(rch);
			var evt:RediEvent = new RediEvent(RediEvent.DELETE_CORRECTION);
			evt.arr = arr;
			this._dispatcher.dispatchEvent(evt)
		}
		
		public function selectCorrectionEdit(h:RediCorrectionHeader):void{
			
			this.rediCorrectionHeader = h;
			/*var evt:RediEvent = new RediEvent(RediEvent.EDIT_CORRECTION);
			evt.rch = h;
			this._dispatcher.dispatchEvent(evt)*/
		}
		
		public function reprocess():void{
			var arr:Array = new Array();
			for each(var rch:RediCorrectionHeader in this.acRediOpen){
				if(rch.isSelected == true && rch.bReprocess == true){
					arr.push(rch);
				}
			}
			if(arr && arr.length){
				var evt:RediEvent = new RediEvent(RediEvent.VALIDATE_MULTIPLE_REDI);
				evt.arr = arr;
				this._dispatcher.dispatchEvent(evt);
			}
			else{
				Alert.show("Please select (using check box) invoice correction(s) to reprocess in the data grid.");
			}
		}
		
		public function filterReprocess(b:Boolean):void{
			var evt:RediEvent = new RediEvent(RediEvent.FILTER);
			evt.b = b;
			this._dispatcher.dispatchEvent(evt);
		}
		
		
		
		/*  handler for when a user presses enter on a DG row */
		public function enterRow(event:KeyboardEvent,rch:RediCorrectionHeader):void 
		{  
			//event.preventDefault();              
			if (event.keyCode == Keyboard.ENTER) {
				//if the enter came from the grid
				var afdg:FilterAdvancedDatagrid = event.currentTarget as FilterAdvancedDatagrid;
				if(afdg){
					/* ITEM_DOUBLE_CLICK calls selectRow()   */  
					openCorrectionEdit(rch,event); 
				}
			}
			//dgItems.dispatchEvent(new ListEvent(ListEvent.ITEM_DOUBLE_CLICK));
		}
		
		public function saveRediSettings():void{
			var evt:RediEvent = new RediEvent(RediEvent.SAVE_REDI_SETTINGS);
			evt.arr = this.acRediSettings.source;
			evt.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(evt);
		}
		
		public function extract():void{
			var evt:RediEvent = new RediEvent(RediEvent.EXTRACT_OPEN_REDI);
			this._dispatcher.dispatchEvent(evt);
		}
		
	}
}