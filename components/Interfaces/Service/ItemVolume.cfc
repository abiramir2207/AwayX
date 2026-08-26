component hint="This is an ItemVolume"
{

   // property name="Legacy_Program_Id"		type="string";
	property name="Item_Number"				type="string";
	property name="Program_Volume_Cases"	type="numeric";	
	property name="Program_Volume_Pounds"	type="numeric" default= 0;	

	public function init() returntype="components.Interfaces.Service.ItemVolume" output="false"{
	
		return this;
		
	}

}