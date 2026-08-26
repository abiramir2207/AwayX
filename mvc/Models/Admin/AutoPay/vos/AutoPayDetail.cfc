<cfcomponent>
	
	<cfproperty name="reportId" 	type="numeric" default=""/>
	<cfproperty name="reportStatus" type="mvc.Models.AutoPay.vos.Status" default=""/>
	<cfproperty name="Billback_id" 	type="String" default=""/>
	<cfproperty name="bbCode" 		type="String" default=""/>
	<cfproperty name="bbTitle" 		type="String" default=""/>
	<cfproperty name="reportTitle" 		type="String" default=""/>
	<cfproperty name="bbAmount" 	type="numeric" default=""/>
	<cfproperty name="pullbackAmount" 	type="numeric" default=""/>
	<cfproperty name="deviationAmount" 	type="numeric" default=""/>
	<cfproperty name="exclusionAmount" 	type="numeric" default=""/>	
	<cfproperty name="startDate"	type="" default=""/>
	<cfproperty name="endDate" 		type="Date" default=""/>
	<cfproperty name="updDate" 		type="Date" default=""/>
	<cfproperty name="firstName" 	type="String" default=""/>
	<cfproperty name="lastName" 	type="String" default=""/>
	<cfproperty name="contractTitle" type="String" default=""/>
	<cfproperty name="contractNumber"type="String" default=""/>
	<cfproperty name="compName"		type="String" default=""/>
	<cfproperty name="contractId" 	type="numeric" default=""/>
	<cfproperty name="payeeName" 	type="String" default=""/>
	<cfproperty name="payeeId" 		type="String" default=""/>

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.reportId = '0';
		this.reportStatus = CreateObject("component","mvc.Models.AutoPay.vos.Status");
		this.Billback_id = '';
		this.bbCode = '';
		this.bbTitle = '';
		this.reportTitle = '';
		this.bbAmount = '0';
		this.pullbackAmount  = '0';
		this.deviationAmount = '0';
		this.exclusionAmount = '0';
		this.startDate = '';
		this.endDate = '';
		this.updDate = '';
		this.firstName = '';
		this.lastName = '';
		this.contractTitle = '';
		this.compName = '';
		this.contractNumber = '';
		this.contractId = '0';
		this.payeeName = '';
		this.payeeId = '';
	</cfscript>
	
	<cffunction name="init" output="false" returntype="Item">
		<cfreturn this>
	</cffunction>

</cfcomponent>