<cfif isDefined("BB_Reimbursement_ID")>
<cfset useLakebaseForDeleteReimbursement = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_reimbursement")>
<cfif useLakebaseForDeleteReimbursement>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_reimbursement",
			{
				"bb_reimbursement_id" = "eq.#BB_Reimbursement_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteReimbursement = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteReimbursement>
<cfquery name="DeleteReimbursement" datasource="#application.datasource#">
UPDATE BB_Reimbursement
SET Deleted = 1
WHERE BB_Reimbursement_ID = '#BB_Reimbursement_ID#'
</cfquery>
</cfif>
<!--- <CFOUTPUT>#Form.Referer#</CFOUTPUT> --->
<div align="Center">

<cfif isDefined("Form.Source")>
<h3>This reimbursement has been deleted.</h3>
<cfelse>
This reimbursement has been deleted.
</CFIF>

<!--- <cfoutput>#CGI.HTTPREFERER#</cfoutput> --->
<body onload="closeRefresh();">
<SCRIPT LANGUAGE="JavaScript">
function closeRefresh() {  
<cfif isDefined("Form.Source")>
    window.opener.location.href = "/billbacks/ledger/index.cfm?FinalDistributorList=<cfoutput>#Form.DistributorNumber#</cfoutput>&FinalProgramList=<cfoutput>#Form.ProgramNumber#</cfoutput>&ShowLedger=1";
	setTimeout('window.close()',2000);
</cfif>
}
</script>


<p></p>
<CFIF NOT isDefined("Form.Source")>
<CF_button
			button_name		=	""
			button_caption	=	"new"
			button_action	=	"window.location.href='/billbacks/reimbursements/index.cfm'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Enter new reimbursement"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	

<CF_button
			button_name		=	""
			button_caption	=	"home"
			button_action	=	"window.location.href='/manufacturers/home.cfm'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Go to home page."
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	
		
<!--- <CFELSE>

<CF_button
			button_name		=	""
			button_caption	=	"close"
			button_action	=	"closeRefresh();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Close Window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	 --->

</CFIF>
</div>

</cfif>
</body>