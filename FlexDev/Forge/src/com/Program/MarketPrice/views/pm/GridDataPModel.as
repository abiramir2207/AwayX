package com.Program.MarketPrice.views.pm
{
	import com.Program.MarketPrice.events.MPEvent;
	import com.shared.components.StringUtils;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.NumberFormatter;
	import mx.utils.ObjectUtil;
	
	public class GridDataPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function GridDataPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			_decTwoFormat.precision = 2;
			_decTwoFormat.useNegativeSign = false;
		}
		
		/*.......................  Properties  .......................*/
		//[Bindable] public var oSettings:Settings;
		[Bindable] public var arrDgItemsCols:Array;
		[Bindable] public var program:Program;
		[Bindable] public var maxVariancePercent:Number;
		public var _decTwoFormat:NumberFormatter =  new NumberFormatter();
		//[Bindable] public var actionLabel:String = 'cancel';
		//this.oSettings.user.stProfileSettings.MARKET_PRICE_VARIANCE = "9.6000"
		/*.................oSettings......................*/
		private var _oSettings:Settings = new Settings();
		[Bindable (event="settingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(settings:Settings):void
		{
			this._oSettings = settings;
			//since user object with MARKET_PRICE_VARIANCE is updated, update Button Label
			this.setActionLabel();
			if(_oSettings.user.hasOwnProperty('stProfileSettings')){
				this.setsMarketPriceVariance(settings.user.stProfileSettings.MARKET_PRICE_VARIANCE);
			}
			dispatchEvent(new Event('settingsChanged'));
		}
		/*.....  actionLabel .....*/
		private var _actionLabel:String = '';
		[Bindable (event="actionLabelChanged")]
		public function get actionLabel():String
		{
			return this._actionLabel;
		}
		/*.....  showMessage .....*/
		private var _showMessage:Boolean = false;
		[Bindable (event="showMessageChanged")]
		public function get showMessage():Boolean
		{
			return this._showMessage;
		}
		/*.....  actionToolTip .....*/
		private var _actionToolTip:String = '';
		[Bindable (event="actionToolTipChanged")]
		public function get actionToolTip():String
		{
			return this._actionToolTip;
		}
		public function setActionLabel():void
		{
			if(this.checkApprovalPermissions()){
				this._actionLabel = 'approve';
				this._actionToolTip = '';//Approve Market Price variances and continue with approval process.
				this._showMessage = false;
			}
			else{
				this._actionLabel = 'agree';
				this._showMessage = true;
				if(_oSettings.user.hasOwnProperty('stProfileSettings')){
					this._actionToolTip = 'Current Market Price approval threshold (Profile ' + _oSettings.user.stProfileSettings.PROFILES_DESC + ') does not allow Market Price approval.  You may "Agree" to Market Price and Continue with approval process.  Depending on Template and Profile settings, additional approval may be required.';
				}
				else{
					this._actionToolTip = 'Current Market Price approval threshold (profile setting) does not allow Market Price approval.  Agree to Market Price Continue with approval process.  Depending on Template and Profile settings, additional approval may be required.';
					
					//You do not have approriate permission to approve Market Price.  If you have Margin approval permissions, The Program will still be in Agree status until Market Price gets approved
				}
				
			}
			dispatchEvent(new Event('actionLabelChanged'));
			dispatchEvent(new Event('actionToolTipChanged'));
			dispatchEvent(new Event('showMessageChanged'));
		}
		/*.................MarketPriceVariance......................*/
		private var _sMarketPriceVariance:String = new String();
		[Bindable (event="sMarketPriceVarianceChanged")]
		public function get sMarketPriceVariance():String
		{
			return _sMarketPriceVariance;
		}
		public function setsMarketPriceVariance(n:Number):void
		{
			if(n == 99999){
				this._sMarketPriceVariance = '*' ;
			}
			else{
				this._sMarketPriceVariance = this._decTwoFormat.format(n).toString() + '%';
			}
			dispatchEvent(new Event('sMarketPriceVarianceChanged'));
		}
		/*.................acItems......................*/
		private var _acItems:ArrayCollection = new ArrayCollection();
		[Bindable (event="ItemsChange")]
		public function get acItems():ArrayCollection
		{
			return _acItems;
		}
		public function checkApprovalPermissions():Boolean{
			var bAllow:Boolean = false;
			if(_oSettings.user.hasOwnProperty('stProfileSettings') && StringUtils.roundDec(_oSettings.user.stProfileSettings.MARKET_PRICE_VARIANCE,2) >= StringUtils.roundDec(maxVariancePercent,2)){
				bAllow = true;
			}
			return bAllow;
		}
		public function set acItems(items:ArrayCollection):void
		{
			this._acItems = items;
			//since maxvariance gets updated with items, update the Button label
			this.setActionLabel();
			dispatchEvent(new Event('ItemsChange'));
		}
		
		/*.......................  Methods  .......................*/
		public function filter(bFilter:Boolean):void{
			/*... Dispatch the Fiter event ...*/
			var e:MPEvent = new MPEvent(MPEvent.FILTER);
			e.bFilter = bFilter;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function actionClick():void{
			/*... Dispatch the Fiter event ...*/
			if(this.checkApprovalPermissions()){
				var e:MPEvent = new MPEvent(MPEvent.APPROVE);
				e.programId = this.oSettings.programId;
				this._dispatcher.dispatchEvent(e);
			}
			else{
				this.continueClick();
			}
		}
		
		public function approveHandler(oApproved:Object):void{
			/*... handle result from server ...*/
			if(oApproved.BAPPROVED){
				this.continueClick();
			}
			else{
				Alert.show('Approval failed: ' + oApproved.MESSAGE);
			}
		}
		
		
		public function cancelClick():void{
			/*... call the close window on the wrapper cfm page ...*/
			this.callWrapper('closeMPApprovalEdit');
		}
		
		public function continueClick():void{
			/*... call the continue to next window on the wrapper cfm page ...*/
			this.callWrapper('continueMPApprovalEdit');
		}
		
		private function callWrapper(sWrapperFunction:String):void{
			/*... call the close window on the wrapper cfm page ...*/
			var s:String;
			if (ExternalInterface.available) {
				s = ExternalInterface.call(sWrapperFunction);
			} else {
				s = "Wrapper not available";
			}
		}
		
	}
}