component hint="This is Response Detail"
{
    property name="Legacy_Program_Id"			type="string";
    property name="Forge_Program_Id"			type="string";
    property name="Description"					type="string";
    property name="Detail_Id"					type="String"; //  Y_DEAL_UI_Upload_ID


    public function init() returntype="components.Interfaces.Service.Detail" output="false"{
    		return this;
    }

}