package com.shared.components.mx
{
	import com.shared.views.skins.DataGridHeaderBackgroundSkinBa;
	import com.shared.views.skins.DataGridHeaderSeparatorSkinBa;
	
	import mx.controls.AdvancedDataGrid;
	import mx.skins.halo.AdvancedDataGridHeaderHorizontalSeparator;
	import mx.skins.spark.DataGridHeaderBackgroundSkin;
	import mx.skins.spark.DataGridHeaderSeparatorSkin;
	
	public class AdvancedDataGridBa extends AdvancedDataGrid
	{
		public function AdvancedDataGridBa()
		{
			super();
		}
		override public function stylesInitialized():void {
			super.stylesInitialized();	
			//Set Custom Styles if the default style has not been overridden
		}
	}
}