<!--- index.cfm - Copyright (c) 2004 Blacksmith Applications, Inc.--->
<!--- Created By: Tim Ford on 05/12/2005 --->
<!--- This is the entry point for Billback By Payment Cycle actions --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title></title>
</head>
<STYLE TYPE="text/css">
.DataTitleCell {
	text-align : right;
	font-weight : bold;
	vertical-align : top;
}
TABLE.UnderLined TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>
<body>

<!---initialize the Auto Billback Manager--->
<cfset AutoBillbackManager = CreateObject("component", "components.Billback.BillbackAutoManager") />
<!---default command--->
<cfparam name="form.command" default="selDistProgram" />

<!---////////////////// Prefix Legend ////////////////////////////
sel - select
sv - save
///////////////////////////////////////////////////////////////--->

<!---switch/case for command--->
<cfswitch expression="#form.command#">
	<!---select distributor/program--->
	<cfcase value="selDistProgram">
		<cfinclude template="select_distributor_program.cfm" />	
	</cfcase>
	<!---select component combinations for payment cycles--->
	<cfcase value="selComponent">
		<cfinclude template="select_component.cfm" />	
	</cfcase>
	<!---save billback for payment cycle--->
	<cfcase value="svBillback">
	
		<cfset returnedBBID = AutoBillbackManager.saveBillback(Evaluate("form.program_id_#form.billback_component#"), Evaluate("form.start_date_#form.billback_component#"), Evaluate("form.end_date_#form.billback_component#"), Evaluate("form.component_id_#form.billback_component#"), Evaluate("form.program_component_id_#form.billback_component#"), Evaluate("form.discount_type_id_#form.billback_component#"), FORM.Distributor_List) />
		
		<!---if we get a billback id then redirect to the billback summary page--->
		<cfif Len(trim(returnedBBID))>
			<cfset AutoBillbackManager.setBillbackCreated(returnedBBID, Evaluate("form.start_date_#form.billback_component#"), Evaluate("form.end_date_#form.billback_component#"), Evaluate("form.program_id_#form.billback_component#"), Evaluate("form.discount_type_id_#form.billback_component#"), Evaluate("form.Payment_Cycle_ID_#form.billback_component#"), Evaluate("form.component_id_#form.billback_component#"), Evaluate("form.program_component_id_#form.billback_component#")) />
			<cfoutput>
			<script>
				window.parent.location.href = "/billbacks/capture/INDEX.CFM?bbid=#returnedBBID#";
			</script>
			</cfoutput>
		<cfelse>
			<p align="center"><font color="#FF0000" size="+1">
				<!--- Either a Billback for this Distributor and Program already exists or the Distributor selected is not a valid Rebate Recipient for this Program! --->
				This Program has no accruals to apply to a billback.  Please verify the invoice data and program span!
			</font></p>
		</cfif>

		
	</cfcase>
</cfswitch>

</body>
</html>