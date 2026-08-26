package com.shared.vos
{
	import com.shared.models.entity.vos.Customer;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.ProdRate")]
	/**
	 * ProdRate is a child of Component.prodRate array
	 * @author msaunders
	 */
	public dynamic class ProdRate
	{
		/*-.........................................Properties..........................................*/
		public var itemGuid : String;
		public var itemNumber : String;
		public var description : String;
		public var netWeight :Number;
		public var uom :Uom;
		public var uomMP :Uom;
		public var rate :Number;
		public var rateMP :Number;
		//for custom price, rateMP is calculated based on MP price.  we need to store original MP
		public var rateMPOrig:Number;
		public var rateMPCS :Number;
		public var rateMPLB :Number;
		//in custom price, ui needs to hold both the MP rate and the calculated rate.  rateMPCustom is calculated
		//on SAve from ui, rateMp gets overwritten with rateMPcustom, so approval logic uses the "calculated mp rate"
		public var rateMPCustom :Number;
		public var rateConverted :Number;
		public var varianceMP :Number;
		public var variancePercMP :Number;
		public var MPApprovalVariance :Number;
		public var volume :Number = 1;
		public var bActive :Boolean;
		public var customPrint:CustomPrint = new CustomPrint();
		public var rateEz :Number;
		public var uomEz :Uom;
		/*-.........................................Constructor..........................................*/
	/*	public function ProdRate( 
									itemGuid:String = '',
									itemNumber:String = '',
									uom :Uom = null
									//,rate:Number = null
								)
		{
			this.itemGuid = itemGuid;
			this.itemNumber = itemNumber;
			this.uom = uom == null ? new Uom() : uom;
		}*/
		
		/*-.........................................Constructor..........................................*/
		public function ProdRate( pr:ProdRate = null ):void
		{
			if( pr ){
				copy( pr );
			}
			else{
				this.itemGuid = '';
				this.itemNumber = '';
				this.uom = uom == null ? new Uom() : uom;
			}
		}
		/*-.........................................Methods..........................................*/
		public function copy( pr:ProdRate ):void
		{
			itemGuid			= pr.itemGuid;
			itemNumber			= pr.itemNumber;
			description			= pr.description;
			uom					= pr.uom == null ? new Uom() : new Uom(pr.uom);
			uomMP				= new Uom(pr.uomMP);
			rate				= pr.rate;
			rateMP				= pr.rateMP;
			rateMPOrig			= pr.rateMPOrig
			rateMPCS			= pr.rateMPCS
			rateMPLB			= pr.rateMPLB
			rateMPCustom		= pr.rateMPCustom
			rateConverted		= pr.rateConverted;
			varianceMP			= pr.varianceMP;
			variancePercMP		= pr.variancePercMP;
			MPApprovalVariance	= pr.MPApprovalVariance;
			volume				= pr.volume;
			bActive				= pr.bActive;
			customPrint			= new CustomPrint(pr.customPrint);
			netWeight			= pr.netWeight;
			rateEz				= pr.rateEz;
			uomEz				= new Uom(pr.uomEz);
			
		}
		
		public function checkCustRate( arrCust:Array ):Boolean
		{
			var bCustRate:Boolean = false;
			for each(var c:Customer in arrCust){
				var s:String = 'rateCust_' + c.shipTo;
				if(this.hasOwnProperty(s) && this[s] > 0){
					bCustRate = true;
					break;
				}
			}
			return bCustRate;
		}

	}
}