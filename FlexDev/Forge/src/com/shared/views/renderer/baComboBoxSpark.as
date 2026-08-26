package com.shared.views.renderer
{
	import com.shared.views.skins.baComboBoxSparkSkin;
	
	import spark.components.ComboBox;
	
	public class baComboBoxSpark extends ComboBox
	{
		public function baComboBoxSpark()
		{
			super();
			super.height = 15;
			setStyle("skinClass", baComboBoxSparkSkin);
			
		}
	}
}