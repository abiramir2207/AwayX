component hint="This is a Response"
{
    property name="Planner_Id"			type="string";
    property name="Forge_Planner_Id"	type="string";
    property name="Status"				type="string";
    property name="Batch_Id"			type="string";
    property name="Details"				type="array";


    public function init() returntype="components.Interfaces.Service.CreateResponse" output="false"{
    		return this;
    }

}