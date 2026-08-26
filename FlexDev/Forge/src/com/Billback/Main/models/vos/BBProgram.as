package com.Billback.Main.models.vos
{

	import com.Billback.Main.models.vos.*;
	
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBProgram")]
    public class BBProgram extends EventDispatcher
	{  
          public var programId:Number;
          public var number:String;
          public var title:String;
          public var startDate:Date;
          public var endDate:Date;
		  public var effectiveStartDate:Date;
		  public var effectiveEndDate:Date;
		  public var bIsLatestVersion:Boolean;

          public function BBProgram()
	      {	
			  // nothing here
		  }
	}
}
