package com.Billback.Main.models.vos
{
	import com.Deduction.Main.models.vos.Deduction;
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBClosingDetail")]
    public class BBClosingDetail extends EventDispatcher
	{  
          public var bbHeader:BBHeader;
		  public var closingMethod:ClosingMethod;
          public var amount:Number;
          public var deduction:Deduction;
		  public var documentNumber1:String;
		  public var documentNumber2:String;

          public function BBClosingDetail( bbClose:BBClosingDetail = null )
		  {
			  if( bbClose ) copy( bbClose );
		  }
		  /*-.........................................Methods..........................................*/
		  public function copy( bbClose:BBClosingDetail ):void
		  {
			  this.bbHeader 		= bbClose.bbHeader;
			  this.closingMethod 	= new ClosingMethod(bbClose.closingMethod);
			  this.amount 			= bbClose.amount;
			  this.deduction 		= bbClose.deduction;
			  this.documentNumber1		= bbClose.documentNumber1;
			  this.documentNumber2		= bbClose.documentNumber2;
		  }   
	}
}
