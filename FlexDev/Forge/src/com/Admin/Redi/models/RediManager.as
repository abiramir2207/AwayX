package com.Admin.Redi.models
{
	import com.Admin.AutoPay.events.AutoPayEvent;
	import com.Admin.Redi.events.RediEvent;
	import com.Admin.Redi.models.vos.RediCorrectionHeader;
	import com.Admin.Redi.models.vos.RediSettings;
	import com.shared.events.MainEvent;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	public class RediManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function RediManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		
		/*.................acRediOpen......................*/
		private var _acRediOpen:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediOpenChanged")]
		public function get acRediOpen():ArrayCollection
		{
			return _acRediOpen;
		}
		public function set acRediOpen(ac:ArrayCollection):void
		{			
			this._acRediOpen = ac;
			dispatchEvent(new Event('acRediOpenChanged'));	
		}
		
		/*.................acRediHistory......................*/
		private var _acRediHistory:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediHistoryChanged")]
		public function get acRediHistory():ArrayCollection
		{
			return _acRediHistory;
		}
		public function set acRediHistory(ac:ArrayCollection):void
		{			
			this._acRediHistory = ac;
			dispatchEvent(new Event('acRediHistoryChanged'));	
		}
		
		/*.................acRediSettings......................*/
		private var _acRediSettings:ArrayCollection = new ArrayCollection();
		[Bindable (event="acRediSettingsChanged")]
		public function get acRediSettings():ArrayCollection
		{
			return _acRediSettings;
		}
		public function set acRediSettings(ac:ArrayCollection):void
		{			
			this._acRediSettings = ac;
			dispatchEvent(new Event('acRediSettingsChanged'));	
		}
		
		/*.................funcFilterInsert......................*/
		private var _funcFilterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="funcFilterInsertChange")]
		public function get funcFilterInsert():Function
		{
			return _funcFilterInsert;
		}
		public function set funcFilterInsert(func:Function):void
		{
			this._funcFilterInsert = func;
			dispatchEvent(new Event('funcFilterInsertChange'));
		}
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here:  + {ObjectUtil.toString(x)}' );
			
		}
	/*	public function getRediEditResults(Redi:*):void{
			this._acRediOpen = Redi;
			dispatchEvent(new Event('acRediOpenChanged'));
		}
	*/
		//dispatched from event map after (listnerinjector) MainEvent.LOAD_MODS_MAIN is fired.  SettingsManager dispatches this after the settings have been loaded
		public function getData(e:MainEvent):void{
			var evt:RediEvent = new RediEvent(RediEvent.LOAD_REDI_OPEN);
			evt.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(evt);
			
			var eRedi:RediEvent = new RediEvent(RediEvent.LOAD_REDI_HISTORY);
			eRedi.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(eRedi);
			
			var re:RediEvent = new RediEvent(RediEvent.GET_REDI_SETTINGS);
			//re.userId = this.oSettings.userId;
			this._dispatcher.dispatchEvent(re);
		}
		
		public function getRediHistoryResults(arr:Array):void{
			this.acRediHistory =  new ArrayCollection(arr);
		}
		
		public function getRediOpenResults(arr:Array):void{
			this.acRediOpen = new ArrayCollection(arr);
		}
		public function reprocessRediOpenResults(obj:Object):void{
			var s:String = 'Invoices Created:';
			var crlf:String = String.fromCharCode(13, 10);
			var arrId:Array = obj.ARRID;
			var arrInvNum:Array = obj.ARRINVNUM;
			var arrLoop:Array = acRediOpen.source.concat();
			for each(var rch:RediCorrectionHeader in arrLoop){
				var i:int = arrId.indexOf(rch.rediCorrectionHeaderId);
				if(i > -1){
					var sInv:String = arrInvNum[i]["invoiceNumber"];
					if(sInv.indexOf('error') == -1 && sInv != ''){
						acRediOpen.removeItem(rch);
						s = s + crlf + sInv;
					}else{
						rch.errorMessage = arrInvNum[i].errorMessage;
						rch.bReprocess = false;
						s = s + crlf + 'error: ' + arrInvNum[i].errorMessage + ' '  + arrInvNum[i].poNum;
					}
					
				}
			}
			acRediOpen.refresh();
			Alert.show(s,"VALIDATION RESULTS");
		}
		
		public function getRediSettingsResults(arr:Array):void{
			var rs:RediSettings;
			this.acRediSettings = new ArrayCollection(arr);
		}
		
		public function filter(b:Boolean):void{
			if(b){
				this.funcFilterInsert = this.filterReprocessFunc;
			}
			else{
				this.funcFilterInsert = function(inObject:Object):Boolean{return true;};
				this.acRediOpen.refresh();
			}
		}
		
		[Bindable] 
		public var filterReprocessFunc:Function =
		function(o:Object):Boolean
		{
			var h:RediCorrectionHeader = o as RediCorrectionHeader;
			return h.bReprocess == true;
		}
		
		public function exportCorrections(e:RediEvent):void{
			//Open the popup window
			var winjscommand:String ="/flex/com/Admin/Redi/OpenCorrectionsExtract.cfm?Display=1";
			var jscommand:String = "window.open('"+winjscommand+"','Redi','height=350,width=350,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes,status=1');"   
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");
		}
		//this.funcFilterInsert = function(inObject:Object):Boolean{return true;};
		/*public function deleteCorrectionResults(arr:Array):void{
			
		}*/
	}
}