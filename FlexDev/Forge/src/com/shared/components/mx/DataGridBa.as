package com.shared.components.mx
{

	import com.shared.views.skins.DataGridHeaderBackgroundSkinBa;
	import com.shared.views.skins.DataGridHeaderSeparatorSkinBa;
	
	import mx.skins.spark.DataGridHeaderBackgroundSkin;
	import mx.skins.spark.DataGridHeaderSeparatorSkin;
	
	import mx.controls.DataGrid;
	
	
	public class DataGridBa extends DataGrid
	{
		public function DataGridBa()
		{
			super();
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();	
			//Set Custom Styles if teh default style has not been overridden
			if(this.getStyle('headerBackgroundSkin') == DataGridHeaderBackgroundSkin ){
				this.setStyle("headerBackgroundSkin", Class(DataGridHeaderBackgroundSkinBa));
			}
			if(this.getStyle('headerSeparatorSkin') == DataGridHeaderSeparatorSkin ){
				this.setStyle("headerSeparatorSkin", Class(DataGridHeaderSeparatorSkinBa));
			}
		}
	}
}