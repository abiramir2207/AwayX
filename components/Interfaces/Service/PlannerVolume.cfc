component hint="This is an PlannerVolume"
{

	property name="Distributor_ID"			type="string";
	property name="Item_Number"				type="string";
	property name="Base_Volume"	type="numeric"  default= 0;	
	property name="Incr_Volume"	type="numeric" default= 0;
	property name="UOM"						type="string";
	property name="Start_Date"				type="string";

	public function init() returntype="components.Interfaces.Service.PlannerVolume" output="false"{
	
		return this;
		
	}

}