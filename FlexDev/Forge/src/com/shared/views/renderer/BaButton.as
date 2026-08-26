package com.shared.views.renderer
{
	import spark.components.Button;

	//import com.shared.models.SettingsManager;
	
	public class BaButton extends Button
	{
		/*.......................  Constructor  .......................*/
		public function BaButton()
		{
			super();
			super.height = 16;
		}
		/*.......................  Properties  .......................*/
		
		/*.......................  Methods  .......................*/
		override protected function measure():void {
            super.measure();
           // measuredHeight= SettingsManager.statSettings.UIAttributes.cfApp_buttonHeight;
           // measuredMinHeight=25;
        }
	}
}