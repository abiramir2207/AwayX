package com.shared.components.filters.renderers
{
	
	import mx.controls.Label;
	import mx.controls.listClasses.*;
	
	public class GridColumnText extends Label 
	{

		private const BLACK_COLOR:uint = 0x000000; // Black
		private const RED_COLOR:uint = 0xFF0000; // Red
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.setStyle('color', RED_COLOR);
		}
	}
}
