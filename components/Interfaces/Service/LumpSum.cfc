component hint="This is a LumpSum" accessors='true'
{
	//property name="Legacy_Program_Id"		type="string";
	property name="Item_Number"				type="string";
	property name="LS_Amount"				type="Numeric";
	property name="Lump_Sum_Description"	type="string";
	property name="LS_component_Name"		type="string";
	property name="GL_Account"				type="string" Default = '';
	property name="LS_Pays_To"				type="string" Default = 'D';
	property name="Payment_frequency"		type="string";
	property name="Claim_Mechanic"			type="string";
	property name="Payee"					type="string" Default = '';
	property name="Payee_Eligibility"		type="string" Default = '';
	property name="Currency"				type="string";
	property name="Group"					type="string" Default = '0';

	public function init() returntype="components.Interfaces.Service.LumpSum" output="false"{
		// this.Legacy_Program_ID 		= '';
		// this.Item_Number 			= '';
		// this.Rebate_Amount 			= '';
		// this.Rebate_Unit_of_Measure = 'CS';
		// this.External_Component_ID 	= 'D';
		// this.GL_Account 			= 'Upon Due';
		// this.Pays_To 				= '';
		// this.Payment_frequency 		= '';
		// this.Claim_Mechanic 		= '';
		// this.Empty_Field_1 			= '';
		// this.Empty_Field_2 			= '';
		// this.Currency 				= '';
		// this.Group 					= '0';

		return this;
	}

}