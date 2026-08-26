component hint="This is a Planner"
{
    property name="Planner_Id"					type="string";
    property name="Start_Date"					type="string";
    property name="End_Date"					type="string";
    property name="Responsible_Sales_Person"	type="string";
	property name="RSP_Position"				type="string";
    property name="Programs"					type="array";
    property name="PlannerVolume"				type="array";


    public function init() returntype="components.Interfaces.Service.Planner" output="false"{
    		return this;
    }

}