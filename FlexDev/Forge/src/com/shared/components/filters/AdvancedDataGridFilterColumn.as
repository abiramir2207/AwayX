package com.shared.components.filters
{
	
	import com.shared.components.filters.renderers.AdvancedInputRenderer;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	/**
	 * AdvancedDataGridHeaderRenderer which include a TextInput filter
	 */
	public class AdvancedDataGridFilterColumn extends AdvancedDataGridColumn
	{
		private var _filterText:String= "";
		private var _filterVisible:Boolean = true;
		private var _editText:String= "";
		private var _editVisible:Boolean = false;
		private var _filterComboText:String= "";
		private var _filterComboVisible:Boolean = false;
		private var _filterComboDp:ArrayList= new ArrayList();
		private var _chkBFilterVisible:Boolean = false;
		
		
		public function AdvancedDataGridFilterColumn(columnName:String=null)
		{
			super(columnName);
			super.headerRenderer = new ClassFactory(AdvancedInputRenderer);
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
			dispatchEvent(new Event('editVisibleChanged'));
		} 
		
		[Bindable (event="editVisibleChanged")]
		public function get editVisible():Boolean
		{
			return _editVisible;
			
			/* Dev Note; 30780. Not using this as of now. Might be used if we need to hide or disable the editable checkbox 
			(program and assoc dist) on the BB item grid
			
			var b:Boolean;
			b = (this.editable && _editVisible);
			return b;
			*/
	
		}
		
		public function set chkBFilterVisible(inValue:Boolean):void
		{
			_chkBFilterVisible = inValue;
			dispatchEvent(new Event('chkBFilterVisibleChanged'));
		} 
		
		[Bindable (event="chkBFilterVisibleChanged")]
		public function get chkBFilterVisible():Boolean
		{
			return _chkBFilterVisible;
		}
		
		//FILTER COMBO BOX
		public function set filterComboText(inValue:String):void
		{
			_filterComboText = inValue;
			if(!_filterComboText){_filterComboText = ''}
			dispatchEvent(new Event('filterComboTextChanged'));
		} 
		
		[Bindable (event="filterComboTextChanged")]
		public function get filterComboText():String
		{
			return _filterComboText;
		}
		
		public function set filterComboVisible(inValue:Boolean):void
		{
			_filterComboVisible = inValue;
			dispatchEvent(new Event('filterComboVisibleChanged'));
		} 
		
		[Bindable (event="filterComboVisibleChanged")]
		public function get filterComboVisible():Boolean
		{
			return _filterComboVisible;
		}
		//DP
		
		public function set filterComboDp(inValue:ArrayList):void
		{
			_filterComboDp = inValue;
			dispatchEvent(new Event('filterComboDpChanged'));
			// if a dp changes, update the comboBox selections (after we dispatch the dp update!) ........
			if (filterComboText != '')
				{ filterComboSelectedIndex = 1;}
			else
				{filterComboSelectedIndex = 0;}
			dispatchEvent(new Event('filterComboSelectedChanged'));
		} 
		
		[Bindable (event="filterComboDpChanged")]
		public function get filterComboDp():ArrayList
		{
			return _filterComboDp;
		}
		//SELECTED ITEM INDEX
		[Bindable (event="filterComboSelectedChanged")]
		public var filterComboSelectedIndex:int = 0;
		
		
		
		private var _dataFieldComplex:String = '';
		[Bindable (event="dataFieldComplexChanged")]
		public function get dataFieldComplex():String
		{
			return _dataFieldComplex;
		}
		public function set dataFieldComplex(s:String):void
		{
			_dataFieldComplex = s;
			dispatchEvent(new Event('dataFieldComplexChanged'));
		} 
		
		private var _toolTip:String = '';
		[Bindable (event="toolTipChanged")]
		public function get toolTip():String
		{
			return _toolTip;
		}
		public function set toolTip(s:String):void
		{
			_toolTip = s;
			dispatchEvent(new Event('toolTipChanged'));
		}
		
		
		
		public function cloneFC():AdvancedDataGridFilterColumn
		{
			// make a new column
			var col:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn();
			
			// copy the properties
			super.copyProperties(col);
			this.copyPropertiesFC(col);
			
			return col;
		}
		protected function copyPropertiesFC(col:AdvancedDataGridFilterColumn):void
		{
			// copy properties
			col.editVisible = this.editVisible;
			col.filterText = this.filterText;
			col.filterVisible = this.filterVisible;
			col.editText = this.editText;
			col.filterComboText = this.filterComboText;
			col.filterComboVisible = this.filterComboVisible;
			col.filterComboDp = this.filterComboDp;
			col.dataFieldComplex = this.dataFieldComplex;
			col.toolTip = this.toolTip;
		}
	}
	
}
