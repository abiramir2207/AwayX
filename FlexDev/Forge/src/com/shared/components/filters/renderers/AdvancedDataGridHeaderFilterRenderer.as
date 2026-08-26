package com.shared.components.filters.renderers
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.collections.ICollectionView;
	import mx.containers.VBox;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridSortItemRenderer;
	import mx.events.CollectionEvent;
	
	
	public class AdvancedDataGridHeaderFilterRenderer extends AdvancedDataGridHeaderRenderer{
		
		public function AdvancedDataGridHeaderFilterRenderer(columnName:String=null){
			
			super(columnName);
		}
	}
}