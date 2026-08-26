package com.shared.components.filters
{
	import com.shared.components.filters.renderers.MultiSelectRenderer;
	
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	public class DataGridFilterColumnMultiSelect extends DataGridColumn
	{
		private var _filterArray:Array = new Array();
		private var _filterVisible:Boolean = true;
		private var _editText:String= "";
		private var _editVisible:Boolean = false;
		
		
		public function DataGridFilterColumnMultiSelect(columnName:String=null)
		{
			super(columnName);
			super.headerRenderer = new ClassFactory(MultiSelectRenderer);
		}
		
		
		/**
		 * set the value stored in the filter text of the column 
		 * @param inValue
		 * 
		 */
		public function set filterArray(inValue:Array):void
		{
			_filterArray = inValue;	
		} 
		
		[Bindable]
		public function get filterArray():Array
		{
			return _filterArray;
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
			_editText = StringUtil.trim(inValue);	
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