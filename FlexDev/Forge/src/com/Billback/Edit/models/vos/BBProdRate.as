package com.Billback.Edit.models.vos
{
	import com.shared.vos.Uom;
	
	import flash.events.EventDispatcher;

	/**
	 * BB Products & Rates per Distributor 
	 */	
	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBProdRate")]
	public class BBProdRate extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var isSelected:Boolean;
		public var itemGuid:String;
		public var itemNumber:String;
		public var description:String;
		public var netWeight:Number;
		public var uom:Uom;
		public var progRate:Number;
		public var rate:Number;
		public var volume:Number;
		public var amount:Number;
		public var discountType:Number;
		public var bNotOnProgram:Boolean;
		
		
		/*-.........................................Constructor..........................................*/
		/*
		public function BBProdRate( bbProdRate:BBProdRate = null )
		{
			if( bbProdRate ) copy( bbProdRate );
		}
		*/
		
		/*-.........................................Methods..........................................*/
		/*
		public function copy( bbProdRate:BBProdRate ):void
		{
			this.isSelected = bbProdRate.isSelected;
			this.itemGuid = bbProdRate.itemGuid;
			this.itemNumber = bbProdRate.itemNumber;
			this.description = bbProdRate.description;
			this.uom = new Uom(bbProdRate.uom);//so we don't get a reference
			// this.progRate = bbProdRate.rate; // rate from program
			this.rate = bbProdRate.rate;
			this.volume = bbProdRate.volume;
			this.discountType = bbProdRate.discountType ;			
			
		}
		*/
		public function BBProdRate()
		{
			// nothing here
		}
		
	}
}