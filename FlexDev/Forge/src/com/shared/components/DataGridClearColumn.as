package com.shared.components
{
	import com.shared.components.filters.renderers.ClearIconRenderer;
	
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	public class DataGridClearColumn extends DataGridColumn
	{
		public function DataGridClearColumn(columnName:String=null)
		{
			super(columnName);
			super.itemRenderer = new ClassFactory(ClearIconRenderer);
		}
		
		
	}
}