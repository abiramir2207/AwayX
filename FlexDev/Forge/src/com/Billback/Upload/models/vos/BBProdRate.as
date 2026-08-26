package com.Billback.Upload.models.vos
{
	import com.shared.vos.Uom;
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBProdRate")]
	public class BBProdRate extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var itemGuid:String;
		public var isSelected:Boolean;;
		public var itemNumber:String;
		public var description:String;
		public var uom:Uom;
		public var rate:Number;
		public var volume:Number;
		public var uomDp:Array;
		/*-.........................................Constructor..........................................*/
		public function BBProdRate( bbProdRate:BBProdRate = null )
		{
			if( bbProdRate ) copy( bbProdRate );
		}
		/*-.........................................Methods..........................................*/
		public function copy( bbProdRate:BBProdRate ):void
		{
			this.itemGuid = bbProdRate.itemGuid;
			this.isSelected = bbProdRate.isSelected;
			this.itemNumber = bbProdRate.itemNumber;
			this.description = bbProdRate.description;
			this.uom = new Uom(bbProdRate.uom);//so we don't get a reference
			this.rate = bbProdRate.rate;
			this.volume = bbProdRate.volume;
			this.uomDp = bbProdRate.uomDp;
			
		}
	}
}