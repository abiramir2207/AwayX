component output="false" alias="mvc.Models.Billback.vos.BBProgramFlat"
{
	property name="programID" type="string" default="";
	property name="ProgramNumber" type="string" default="";
	property name="ProgramTitle" type="string" default="";
	property name="ProgramStartDate" type="date";
	property name="ProgramEndDate" type="date";
	
	// initialize
	this.ProgramID = "";
	this.ProgramNumber = "";
	this.ProgramTitle = "";
	this.ProgramStartDate = "";
	this.ProgramEndDate = "";
	
	// init function
	
	private function init(ProgramID="", ProgramNumber="", ProgramTitle="", ProgramStartDate="", 
	                      ProgramEndDate="") output="false" returntype="mvc.Models.Billback.vos.BBProgramFlat"
	{
		this.ProgramID = arguments.ProgramID;
		this.ProgramNumber = arguments.ProgramNumber;
		this.ProgramTitle = arguments.ProgramTitle;
		this.ProgramStartDate = arguments.ProgramStartDate;
		this.ProgramEndDate = arguments.ProgramEndDate;
		return this;
	}
	
}