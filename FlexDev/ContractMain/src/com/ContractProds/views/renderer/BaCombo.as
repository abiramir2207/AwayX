package com.ContractProds.views.renderer
{
	import com.shared.models.SettingsManager;
	import com.shared.vos.Settings;
	import mx.controls.ComboBox;
	
	public class BaCombo extends ComboBox
	{
		/*.......................  Constructor  .......................*/
		public function BaCombo()
		{
			super();
			super.height = 15;
		}
		/*.......................  Properties  .......................*/
		
		/*.......................  Methods  .......................*/
		override protected function measure():void {
            super.measure();
           // measuredHeight = SettingsManager.statSettings.UIAttributes.cfApp_comboBoxHeight;
            measuredWidth = 125;
           // measuredMinHeight=25;
        }

	}
}