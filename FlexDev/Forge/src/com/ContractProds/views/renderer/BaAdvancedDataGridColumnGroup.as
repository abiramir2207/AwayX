package com.ContractProds.views.renderer
{
	import com.shared.vos.Component;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	
	public class BaAdvancedDataGridColumnGroup extends AdvancedDataGridColumnGroup
	{
		public function BaAdvancedDataGridColumnGroup(columnName:String=null)
		{
			super(columnName);
		}
		[Bindable]
		public var component:Component;
		
	}
}