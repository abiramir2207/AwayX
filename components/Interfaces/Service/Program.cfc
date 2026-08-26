component hint="This is a Program"
{

    //property name="Legacy_Program_Id"		type="string";
	property name="Template_Description"	type="string";
	property name="Program_Title"			type="string";
	property name="Program_Start_Date"		type="string";
	property name="Program_End_date"		type="string";
	property name="Responsible_Sales_Person" type="string";
	property name="RSP_Position" 			type="string";
	property name="Creator_Position"		type="string";
	property name="Created_Date"			type="string";
	/*
	property name="RFA_ID"					type="string";
	property name="RFA_Date"				type="string";
	property name="Approval_ID"				type="string";
	property name="Approval_Date"			type="string";
	property name="Bid_Status"				type="string";
	property name="Reference_Number"		type="string";
	property name="Action_code"				type="string";
	property name="Business_Segment"		type="string";
	*/
	property name="Planner_ID"				type="string";
	property name="Performance_Start"		type="string";
	property name="Performance_End"			type="string";
	property name="Performance_Type"		type="string";

	property name="Distributors"	type="array";
	property name="Rebates"			type="array";
	property name="LumpSums"		type="array";
	property name="ItemVolume"		type="array";


	public function init() returntype="components.Interfaces.Service.Program" output="false"{
		/*this.Legacy_Program_ID=				"xxxx";
		this.Template_Description=			"template";
		this.Program_Title=					"PRG-666666";
		this.Program_Start_Date=			"2020-01-01 00:00:00";
		this.Program_End_date=				"2020-12-31 13:57:26";
		this.Responsible_Sales_Person=		"Paul" ;
		this.RSP_Position=					"CHILAY CORP. - RETAIL - John Duffy";
		this.Creator_Position=				"admin";
		this.Created_Date=					"2020-02-06 13:57:26";
		// These are all NULL so don't need them
		this.RFA_ID=						"";
		this.RFA_Date=						"";
		this.Approval_ID=					"";
		this.Approval_Date=					"";
		this.Bid_Status=					"";
		this.Reference_Number=				"";
		this.Action_code=					"";
		this.Business_Segment=				"";
		//
		this.Planner_ID=					"PlannerId";
		this.Performance_Start=				"";
		this.Performance_End=				"";
		this.Performance_Type=				"";
		*/
	
		return this;
		
	}

}