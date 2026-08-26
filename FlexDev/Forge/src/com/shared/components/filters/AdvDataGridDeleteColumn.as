package com.shared.components.filters
{
	import com.shared.components.filters.renderers.DeleteIconRenderer;
	import com.shared.components.filters.renderers.DeleteAddHeaderRenderer
	
	import flash.events.Event;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	public class AdvDataGridDeleteColumn extends AdvancedDataGridColumn
	{
		public function AdvDataGridDeleteColumn(columnName:String=null)
		{
			super(columnName);
			super.headerRenderer = new ClassFactory(DeleteAddHeaderRenderer);
			super.itemRenderer = new ClassFactory(DeleteIconRenderer);
		}
	}
}