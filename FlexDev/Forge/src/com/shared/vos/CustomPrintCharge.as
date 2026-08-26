package com.shared.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Program.Component.vos.CustomPrintCharge")]
	/**
	 * GlAccount is a child of Component.
	 * @author msaunders
	 */
	public class CustomPrintCharge
	{
		public function CustomPrintCharge()
		{
		}
		/*-.........................................Properties..........................................*/
		public var printMakeReady:Number = 0;
		public var printPrePress:Number = 0;
		public var printPlate:Number = 0;
		public var printMinPrice:Number = 0;
		public var printMinPriceCS:Number = 0;
		public var printMinPriceLB:Number = 0;
		public var printMakeReadyBase:Number = 0;
		public var printPrePressBase:Number = 0;
		public var printPlateBase:Number = 0;
		
		public function setPrintMinPrice(nVol:Number,nColors:Number,nMarketPrice:Number):void{
			printMakeReady 	=  printMakeReadyBase / (nVol);// * nMultiplier
			printPlate		=  printPlateBase * nColors/(nVol);//* nMultiplier :: vol comes from UI so multiplier (vol is store as a weekly num in db) is not needed :: 
			printPrePress 	=  printPrePressBase / (nVol);// * nMultiplier
			printMinPrice 	=  (printMakeReady + printPlate + printPrePress + nMarketPrice);
	
		}

	}
}