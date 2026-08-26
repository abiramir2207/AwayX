package com.shared.components
{
	import mx.controls.ToolTip;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	public class HTMLToolTip extends ToolTip
	{
		public function HTMLToolTip()
		{    
			super(); 
		}
		
		/***
		  commitProperties is called whenever the tooltip text is changed
		 ***/		
		override protected function commitProperties():void
		{
			super.commitProperties();
			textField.htmlText = text;
		}	
	}
}
 
 