component hint="This is a Distributor"
{

    //property name="Legacy_Program_ID"		type="string";
	property name="Distributor_ID"			type="string";
	property name="Group"					type="string" Default = 'DST';	

	public function init() returntype="components.Interfaces.Service.Distributor" output="false"{
	
		return this;
		
	}

}