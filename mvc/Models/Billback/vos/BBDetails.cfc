<cfcomponent output="false" displayname="BBDetails" alias="mvc.Models.Billback.vos.BBDetails">
	<cfproperty name="billbackIDInt" type="int">
	<cfproperty name="lockedBy" type="string">
	<cfproperty name="documentList" type="Array">
	<cfproperty name="domainName" type="String">
	<cfproperty name="uniqueFileName" type="Array">
	<cfproperty name="interfaceMessage" type="String">
	<cfproperty name="expectedAmount" type="numeric">
	<cfproperty name="paidAmount" type="numeric">
	<cfproperty name="claimedVsExpected" type="numeric">
	<cfproperty name="claimedVsPaid" type="numeric">
	<cfproperty name="expectedVsPaid" type="numeric">
	<cfproperty name="CRADetails" type="query">
	<cfproperty name="workflowAction" type="query">
	<cfproperty name="NRADetails" type="query">

	<cfscript>
		//Initialize the CFC with the default properties values.
		
		this.billbackIDInt = 0;
		this.lockedBy = '';
		this.documentList = ArrayNew(1);
		this.domainName = '';
		this.uniqueFileName = ArrayNew(1);
		this.interfaceMessage = '';
		this.expectedAmount = 0;
		this.paidAmount = 0;
		this.claimedVsExpected = 0;
		this.claimedVsPaid = 0;
		this.expectedVsPaid = 0;
		//this.CRADetails = querynew('x');
		//this.workflowAction = querynew('x');
		//this.NRADetails = querynew('x');
	</cfscript>

	<cffunction name="init" output="false" returntype="BBDetails">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>