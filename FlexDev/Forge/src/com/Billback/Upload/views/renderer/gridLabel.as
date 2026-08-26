package com.Billback.Upload.views.renderer{
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.*;
	import flash.display.Graphics;
	
	public class gridLabel extends Label{
		private const POSITIVE_COLOR:uint = 0x000000; // Black
		private const NEGATIVE_COLOR:uint = 0xFF0000; // Red
	//	private const POSITIVE_BGCOLOR:uint = 0xFFFFFF; // white
	//	private const NEGATIVE_BGCOLOR:uint = 0xFFFF00; // yellow
		private var _listData:DataGridListData;
		public function gridLabel() 
		{
			super();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			var listData:DataGridListData = this.listData as DataGridListData;
			/* get error string for this property */
			var s:String = data.errObj[listData.dataField];
			/* Set the font color based on the errObj. */
			this.toolTip = s;
			setStyle("color", (s.length > 0) ? NEGATIVE_COLOR : POSITIVE_COLOR);
		//	setStyle("backgroundColor", (s.length > 0) ? NEGATIVE_BGCOLOR : POSITIVE_BGCOLOR);
			var g:Graphics = this.graphics;
			g.clear();
			if (s.length > 0)
			{
				g.beginFill(0xFFFF00);
			}
			else if (s.length == 0 && this.inheritingStyles.backgroundColor == '16776960') // this is checking to see if the background is yellow
			{
				g.beginFill(0xFFFFFF);
			}
			g.drawRect(0,0,unscaledWidth,unscaledHeight);
			g.endFill();
		}
	}
}