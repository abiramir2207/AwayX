package com.vos
{
	
	public class AppFlex
	{
		/*-.........................................Properties..........................................*/
		private var _sBrokerLabel : String;
		private var _sRegionLabel : String;
		private var _sFamilyLabel : String;
		private var _sBuyingGroupLabel : String;
		private var _sTypecodeLabel : String;
		private var _sOperatorLabel : String;
		private var _sItemLabel : String;
		private var _sShardShiptoLabel : String;
		private var _sDistributorLabel : String;
		
		
		/*-.........................................Constructor..........................................*/
		public function AppFlex()
		{
			// default values
			brokerlabel = "Broker 1";
			regionlabel = "Region";
			familylabel = "Family";
			buyinggrouplabel = "Buying Group";
			typecodelabel = "Type Code";
			operatorlabel = "Operator";
			itemlabel = "Item";
			shardshiptolabel = "Ship To";
			distributorlabel = "Distributor";
		}
			
		
		public function get brokerlabel():String
		{
				return _sBrokerLabel;
		}
		public function set brokerlabel(str:String):void
		{
				this._sBrokerLabel = str;								
		}
		
		public function get regionlabel():String
		{
				return _sRegionLabel;
		}
		public function set regionlabel(str:String):void
		{
				this._sRegionLabel = str;				
		}
		
		public function get familylabel():String
		{
				return _sFamilyLabel;
		}
		public function set familylabel(str:String):void
		{
				this._sFamilyLabel = str;				
		}
		
		public function get buyinggrouplabel():String
		{
				return _sBuyingGroupLabel;
		}
		public function set buyinggrouplabel(str:String):void
		{
				this._sBuyingGroupLabel = str;				
		}
		
		public function get typecodelabel():String
		{
				return _sTypecodeLabel;
		}
		public function set typecodelabel(str:String):void
		{
				this._sTypecodeLabel = str;				
		}
		
		public function get operatorlabel():String
		{
				return _sOperatorLabel;
		}
		public function set operatorlabel(str:String):void
		{
				this._sOperatorLabel = str;				
		}
		
		public function get itemlabel():String
		{
				return _sItemLabel;
		}
		public function set itemlabel(str:String):void
		{
				this._sItemLabel = str;				
		}
		
		public function get shardshiptolabel():String
		{
				return _sShardShiptoLabel;
		}
		public function set shardshiptolabel(str:String):void
		{
				this._sShardShiptoLabel = str;				
		}
		
		public function get distributorlabel():String
		{
				return _sDistributorLabel;
		}
		public function set distributorlabel(str:String):void
		{
				this._sDistributorLabel = str;				
		}
		
		/*-.........................................Methods..........................................*/
		public function load(newAppFlex:AppFlex):void 
		{
			this.brokerlabel = newAppFlex.brokerlabel;
			this.regionlabel = newAppFlex.regionlabel;
			this.familylabel = newAppFlex.familylabel;
			this.buyinggrouplabel = newAppFlex.buyinggrouplabel;
			this.typecodelabel = newAppFlex.typecodelabel;
			this.operatorlabel = newAppFlex.operatorlabel;
			this.itemlabel = newAppFlex.itemlabel;
			this.shardshiptolabel = newAppFlex.shardshiptolabel;
			this.distributorlabel = newAppFlex.distributorlabel;
		}

	}
}