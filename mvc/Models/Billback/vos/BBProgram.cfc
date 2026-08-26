component output="false" alias="mvc.Models.Billback.vos.BBProgram" accessors="false"
{
	property name="programId" type="string" default="";
	property name="number" type="string" default="";
	property name="title" type="string" default="";
	property name="startDate" type="date";
	property name="endDate" type="date";
	property name="effectiveStartDate" type="date";
	property name="effectiveEndDate" type="date";
	property name="bIsLatestVersion" type="boolean";

	// initialize
	this.programId = "";
	this.number = "";
	this.title = "";
	this.startDate = "#now()#";
	this.endDate = "#now()#";
	this.effectiveStartDate = "#now()#";
	this.effectiveEndDate = "#now()#";
	this.bIsLatestVersion = 1;

	// init function

	public function init(programId="", number="", title="", startDate="#now()#", endDate="#now()#", effectiveStartDate="#now()#", effectiveEndDate="#now()#", bIsLatestVersion=1) output="false" returntype="mvc.Models.Billback.vos.BBProgram"
	{
		this.programId 	= arguments.programId;
		this.number 	= arguments.title;
		this.title 	= arguments.title;
		this.startDate 	= arguments.startDate;
		this.endDate 	= arguments.endDate;
		this.effectiveStartDate 	= arguments.effectiveStartDate;
		this.effectiveEndDate 	= arguments.effectiveEndDate;
		this.bIsLatestVersion = arguments.bIsLatestVersion;
		return this;
	}

}