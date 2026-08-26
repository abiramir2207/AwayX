package com.ContractProds.views.renderer
{
	import mx.controls.Label;
	import com.shared.models.SettingsManager;
	
	public class BaLabel extends Label
	{
		/*.......................  Constructor  .......................*/
		public function BaLabel()
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