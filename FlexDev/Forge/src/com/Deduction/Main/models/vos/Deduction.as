package com.Deduction.Main.models.vos
{
	import com.Billback.Main.models.vos.Payee;
	import com.shared.models.entity.vos.Lock;
	import com.shared.models.entity.vos.User;

	[RemoteClass(alias="mvc.Models.Deduction.vos.Deduction")]
    public class Deduction
	{  
          public var deductionID:String;
          public var deductionNumber:String;
          public var amount:Number;
		  public var ddDate:Date;
		  public var ddReference:String;	
		  public var ddCheckNumber:String;
		  public var spNumber:String = '';
		  public var brokerObj:Payee;
		  public var distObj:Payee;		
		  public var analystObj:User;
		  public var lockObj:Lock;
		  public var amountParent:Number;
		  public var ddSpNumberParent:String;
		  
          public function Deduction()
	      {
		  }    
	}
}
