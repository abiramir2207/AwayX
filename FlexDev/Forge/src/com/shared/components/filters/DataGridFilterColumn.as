package com.shared.components.filters
{
	import com.shared.components.filters.renderers.TextInputRenderer;
	
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;

	public class DataGridFilterColumn extends DataGridColumn
	{
		private var _filterText:String= "";
		private var _filterVisible:Boolean = true;
		private var _editText:String= "";
		private var _editVisible:Boolean = false;
		
		
		public function DataGridFilterColumn(columnName:String=null)
		{
			super(columnName);
			super.headerRenderer = new ClassFactory(TextInputRenderer);
		}
		
		
		/**
		 * set the value stored in the filter text of the column 
		 * @param inValue
		 * 
		 */	
		public function set filterText(inValue:String):void
		{
			_filterText = inValue;	
		} 
		
		[Bindable]
		public function get filterText():String
		{
			return _filterText;
		}
		
		public function set filterVisible(inValue:Boolean):void
		{
			_filterVisible = inValue;
			dispatchEvent(new Event('filterVisibleChanged'));
		} 
		
		[Bindable (event="filterVisibleChanged")]
		public function get filterVisible():Boolean
		{
			return _filterVisible;
		}
		
		//EDIT Functionality ............................................
		public function set editText(inValue:String):void
		{
			_editText = inValue;	
		} 
		
		[Bindable]
		public function get editText():String
		{
			return _editText;
		}
		
		public function set editVisible(inValue:Boolean):void
		{
			_editVisible = inValue;	
		} 
		
		[Bindable]
		public function get editVisible():Boolean
		{
			var b:Boolean;
			b = (this.editable && _editVisible);
			return b;
		}
		
		
	}
}