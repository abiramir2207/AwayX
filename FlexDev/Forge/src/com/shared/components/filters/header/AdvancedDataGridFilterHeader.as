package com.shared.components.filters.header
{
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	public class AdvancedDataGridFilterHeader extends AdvancedDataGridHeaderRenderer
	{
		public function AdvancedDataGridFilterHeader()
		{
			super();
		}
		
		
		/**
		 *re-position the sort icon 
		 * 
		 */	
		/*
		override protected function placeSortArrow():void
		{
			super.placeSortArrow();
	        if(sortArrow)
	        {
		        var hh:Number = cachedHeaderHeight;
		       sortArrow.y = (hh - sortArrow.measuredHeight - 8) > 0 ? 10: 0;
				//sortArrow.y = 20
	        	if(sortArrow.visible)
	        	{
		        	var n:int = headerItems.length;
		            for (var i:int = 0; i < n; i++)
		            {
		            	if(visibleColumns[i].colNum == dataGrid.sortIndex)
		            	{
		            		headerItems[i].setActualSize(visibleColumns[i].width - sortArrow.measuredWidth + 5, headerItems[i].height);
		            	}
		            }
	        	 }
	        }
		}
		*/
	}
}