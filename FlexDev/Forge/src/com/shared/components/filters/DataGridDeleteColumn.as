package com.shared.components.filters
{
	import com.shared.components.filters.renderers.DeleteIconRenderer;
	import com.shared.components.filters.renderers.DeleteAddHeaderRenderer;
		
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	public class DataGridDeleteColumn extends DataGridColumn
	{
		public function DataGridDeleteColumn(columnName:String=null)
		{
			super(columnName);
			super.headerRenderer = new ClassFactory(DeleteAddHeaderRenderer);
			super.itemRenderer = new ClassFactory(DeleteIconRenderer);
		}
		
		
	}
}