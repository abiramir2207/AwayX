component hint="This is an Error"
{
    property name="Planner_Id"					type="string";
    property name="Legacy_Program_Id"			type="string";
    property name="Description"					type="string";
    property name="Batch_Id"					type="numeric";
    property name="Detail_Id"					type="numeric"; //  Y_DEAL_UI_Upload_ID


    public function init() returntype="components.Interfaces.Service.Error" output="false"{
    		return this;
    }

}