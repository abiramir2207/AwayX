<cfquery name="GetInfo" datasource="#application.datasource#">
SELECT BB_Reimbursement.*, BSA_Foodservice_Customers.Name, Contract_Main.Contract_Number, Contract_Main.Contract_Title,  Contract_Status_Types.Contract_Status_Type_Desc, BB_Reimbursement_Type.Reimbursement_Type_Description
FROM BB_Reimbursement
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_Reimbursement.Distributor_ID
	INNER JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = BB_Reimbursement.Contract_Main_ID
	INNER JOIN Contract_Status_Types
	ON Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
	INNER JOIN BB_Reimbursement_Type
	ON BB_Reimbursement_Type.BB_Reimbursement_Type_ID = BB_Reimbursement.Reimbursement_Type
WHERE BB_Reimbursement.BB_Reimbursement_ID = '#BB_Reimbursement_ID#'
</cfquery>
<cfoutput>

<cfparam name="ShowLinks" default="1">
<cfparam name="tablewidth" default="800">

<font size="+2" color="navy">Reimbursements</font>
<hr width="100%" color="orange">
<cfif NOT isDefined("url.source")>
<cfset tablewidth = 800>
<cfif ShowLinks IS NOT 0>
<TABLE ALIGN="center" WIDTH="90%" CELLPADDING="5" BORDER="0">
<TR>
	<TD NOWRAP><strong><font color="red">[</font> <font color="blue"><a target = "mywindowname" href="index.cfm">Choose Another #application.returned_customer_setting.distributor_label_singular#/Program</a></font> <font color="red">]</font></strong></TD>
	<TD NOWRAP ALIGN="center"><strong><font color="red">[</font> <font color="blue"><a target = "mywindowname" href="index.cfm?ProgramList=<cfoutput>#GetInfo.Contract_Main_ID#</cfoutput>&ShowLedger=0">Choose Another #application.returned_customer_setting.distributor_label_singular#</a></font> <font color="red">]</font></strong></TD>
	<TD NOWRAP ALIGN="right"><strong><font color="red">[</font> <font color="blue"><a target = "mywindowname" href="index.cfm?DistributorList=<cfoutput>#GetInfo.Distributor_ID#</cfoutput>&ShowLedger=0">Choose Another Program</a></font> <font color="red">]</font></strong></TD>
<TD NOWRAP ALIGN="right"><strong><font color="red">[</font> <font color="blue"><a target = "mywindowname" href="/billbacks/ledger/index.cfm?FinalDistributorList=<cfoutput>#GetInfo.Distributor_ID#</cfoutput>&FinalProgramList=<cfoutput>#GetInfo.Contract_Main_ID#</cfoutput>&ShowLedger=1">Go to <cfoutput>#application.returned_customer_setting.Trade_Label#</cfoutput> Checkbook</a></font> <font color="red">]</font></strong></TD>
</TR>
</TABLE>
</cfif>
<cfelse>
 <cfset tablewidth = 400>
</cfif>
<table width="#tablewidth#" border="0" cellpadding="1" cellspacing="2">
	<!---Distributor--->
	<Tr>
		<td align="Right" valign="top"><strong>#application.returned_customer_setting.distributor_label_singular#</strong></td>
		<td rowspan="7" bgcolor="orange"><img src="/Images/CLEAR.GIF" width="1" height="1" alt="" border="0"></td>
		<td>#GetInfo.Name#
		</td>
	</TR>
	
	<!---Program--->
	<Tr>
		<td align="Right" valign="top"><strong>Contract</strong></td>
			<td>#GetInfo.Contract_Number# -- #GetInfo.Contract_Title# (#GetInfo.Contract_Status_Type_Desc#)
		</td>
	</TR>
	
	
	<!---Reimbursement types--->
	<Tr>
		<td align="Right" valign="top"><strong>Reimbursement Type</strong></td>
		<td>
		#GetInfo.Reimbursement_Type_Description#
		</td>
	</TR>
	<!---Reimbursement amount--->
	<tr>
		<td  align="right" valign="top"><strong>Amount</strong><span id="error_ReimbursementAmount"></span></td>
		<td>#lscurrencyformat(GetInfo.Reimbursement_Amount)#</td>
	</tr>
	<!---Reference number--->
	<tr>
		<td  align="right" valign="top"><strong>Number</strong><span id="error_ReimbursementNumber"></span></td>
		<td>#GetInfo.Reimbursement_Number#</td>
	</tr>
	<!---Date--->
	<tr>
		<td  align="right" valign="top"><strong>Date</strong><span id="error_ReimbursementDate"></span></td>
		<td>#dateformat(GetInfo.Reimbursement_Date, 'MM/DD/YYYY')#</td>
	</tr>
	<!---Comments--->
	<tr>
		<td  align="right" valign="top"><strong>Comments</strong><span id="error_ReimbursementComments"></span></td>
		<td>#GetInfo.Reimbursement_Comments#</td>
	</tr>
	
</table></cfoutput>
<p></p>
<cfif ShowLinks IS NOT 0>
<div align="center" >
<table border="0" width="<cfoutput>#tablewidth#</cfoutput>">
<tr>
	
	<Td width="30%">&nbsp; </TD>
	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('/billbacks/reimbursements/utilities/printer_friendly.cfm?pagename=/billbacks/reimbursements/detail.cfm&BB_Reimbursement_ID=#BB_Reimbursement_ID#','name','800','600','Yes', 'Yes')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Print this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>

	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='/billbacks/reimbursements/utilities/email_create.cfm?BB_Reimbursement_ID=#BB_Reimbursement_ID#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Email this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='/billbacks/reimbursements/utilities/fax_create.cfm?BB_Reimbursement_ID=#BB_Reimbursement_ID#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
 --->
	<Td width="70%">&nbsp; </TD>
	</tr><tr>
	<Td width="30%">&nbsp; </TD>
	<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"edit"
			button_action	=	"window.location.href='/billbacks/reimbursements/index.cfm?BB_Reimbursement_ID=#BB_Reimbursement_ID#&FinalProgramlist=#GetInfo.Contract_Main_ID#&FinalDistributorlist=#GetInfo.Distributor_ID#&ShowLedger=1'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
	
		<TD align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"delete"
			button_action	=	"confirmDeletion();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
	
	<TD align="center">
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
	</TD>
</td><Td width="70%">&nbsp; </TD>
</tr>

</table>
</cfif>

<cfoutput>
<form name="DeleteReimbursement" action="/billbacks/reimbursements/delete.cfm" method="post">
<input type="hidden" name="BB_Reimbursement_ID" value="#BB_Reimbursement_ID#">
<CFIF isdefined("url.source")>
<input type="hidden" name="Source" value="#url.source#">
<input type="hidden" name="DistributorNumber" value="#GetInfo.Distributor_ID#">
<input type="hidden" name="ProgramNumber" value="#GetInfo.Contract_Main_ID#">
</CFIF>
</form>
</cfoutput>

<script>
function confirmDeletion()
{
	if(confirm("Are you positive you want to delete this reimbursement?"))
	{
		DeleteReimbursement.submit()
	}
}

</script>