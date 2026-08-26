package com.Billback.Main.models.vos
{
	import com.Billback.Edit.models.vos.BBProdRate;
	import com.Billback.Main.models.vos.BBProgram;
	import com.shared.models.entity.vos.Customer;
	
	import flash.events.EventDispatcher;
	


	
	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBPrgDistItemRate")]
	public dynamic class BBPrgDistItemRate extends EventDispatcher
	{
		public var isSelected:Boolean;
		public var bbProgram:BBProgram;
		public var bbDistributor:Customer;
		public var bbProdRate:BBProdRate;
		public var uomDp:Array = new Array();
		public var message:String = '';
		public var bFirstTime:Boolean;
		
		public function BBPrgDistItemRate()
		{
		  // nothing here
		}    
	}
}
