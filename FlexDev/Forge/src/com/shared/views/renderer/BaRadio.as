package com.shared.views.renderer
{
	import mx.controls.RadioButton;
	
	public class BaRadio extends RadioButton
	{
		/*.......................  Constructor  .......................*/
		public function BaRadio()
		{
			super();
			super.height = 16;
		}
		/*.......................  Properties  .......................*/
		
		/*.......................  Methods  .......................*/
		override protected function measure():void {
            super.measure();
            //measuredHeight= SettingsManager.statSettings.UIAttributes.cfApp_buttonHeight;
           // measuredMinHeight=25;
            
        }
	}
}