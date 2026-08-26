package com.shared.models.entity.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.Operator")]
    public class Operator
	{  
          public var ID:String;
          public var name:String;
          public var address:Address;

          public function Operator()
	      {
		  }    
	}
}
