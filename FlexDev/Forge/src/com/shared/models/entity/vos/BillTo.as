package com.shared.models.entity.vos
{
	[Bindable]
	[RemoteClass(alias="mvc.Models.Entity.vos.BillTo")]
	public class BillTo
	{   
		public var billTo:String = '';
		public var name:String = '';
		public var address:Address;
		public var billToId:String;
		public var shipTo:String = '';
		public var shipToId:String = '';
		
		public function BillTo()
		{
		}
	}
}