<!---
	Copyright (c)2013 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\billbacks\Auto_BB_Report\Ajax\savecheckboxvalues.cfm
	Created:		10/30/2013
	Developer:		drachala
--->
<cfset filename = "Pullbacks_"&#replace(request.AccessStructure.user_id,'-','_','ALL')#&".txt">
<cfset filepath = "#Application.Doc_Path#\Temp_Files\Billback\AutoPayPullbacks\#filename#">
<cfif FileExists("#filepath#")>
		<cffile action="read" file="#filepath#"	variable="selectedlist">
</cfif>
<!---************************************************************************************Mass Apply************************************************************************************************************************************************************************************--->
<cfif all AND status>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<!--- Get all the Opr and Local Dis BB that are already applied to this current Dis Corp BB --->
<cfset GetBillbackstoApply = PullbackManager.GetBillbackstoApplyPullback(Dis_BB_Id=BB_ID,appliedpullbacks=type,fromcheckboxes=1)>
<!--- Check if any Growth pullback amount is applied to this current BB --->
<cfset checkifBBhasGrowth = PullbackManager.checkifBBhasGrowth(BB_Id,type)>

<cfif checkifBBhasGrowth.recordcount GT 0>
			<cfloop query="checkifBBhasGrowth">
					<cfset temp = QueryAddRow(GetBillbackstoApply)>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_billback_id", checkifBBhasGrowth.pullback_billback_id )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "contract_number",checkifBBhasGrowth.contract_number )>
			</cfloop>
</cfif>	

	<cfif FileExists("#filepath#")>
			<cffile action = "delete"   file = "#filepath#">
	</cfif>
	<cfloop Query="GetBillbackstoApply">
		<cfset  CheckboxValue="#pullback_billback_id#|#customer_id#|#contract_number#"&";">	
		<cffile action = "append"   file = "#filepath#" output="#CheckboxValue#">	
	</cfloop>
<!---*****************************************************************************************Mass Apply//Un-Apply**************************************************************************************************************************************************** --->
<cfelseif  all AND status EQ 0>	
	<cfset selectedlist = ''>
	<cffile action = "write"   file = "#filepath#" output="#selectedlist#">	
<!---*************************************************************************************Not Mass Apply and Un-Apply************************************************************************************************************************************************--->
<cfelseif  all EQ 0 AND status EQ 0>	
	<cfset CheckboxValue = CheckboxValue&";">
			<cfif findnocase(CheckboxValue, selectedlist)>
					<cfset selectedlist=	#replace(selectedlist, CheckboxValue,"")#>
			</cfif>
			 <cffile action = "write"   file = "#filepath#" output="#selectedlist#">
<!---****************************************************************************************Not Mass Apply and Apply***************************************************************************************************************************************************--->
<cfelseif  all EQ 0 AND status EQ 1>		
	<cfset CheckboxValue = CheckboxValue&";">
	<cffile action = "append"   file = "#filepath#" output="#CheckboxValue#">
</cfif>
