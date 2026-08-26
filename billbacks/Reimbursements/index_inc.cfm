<!---The form for entering information regarding reimbursements--->
<cfparam name="ReimbursementType" default="1">
<cfparam name="ReimbursementAmount" default="">
<cfparam name="ReimbursementNumber" default="">
<cfparam name="ReimbursementDate" default="">
<cfparam name="ReimbursementComments" default="">
<cfparam name="action" default="create">
<form name="SaveReimbursement" action="index_inc_action.cfm" method="post">
<cfoutput>
<!---Set as saved amounts if updating--->
<cfif isDefined("BB_Reimbursement_ID")>
	<cfquery name="GetReimbursementInfo" datasource="#application.datasource#">
		SELECT *
		FROM BB_Reimbursement
		WHERE BB_Reimbursement.BB_Reimbursement_ID = '#BB_Reimbursement_ID#'
	</cfquery>
	
	<cfset ReimbursementType = GetReimbursementInfo.Reimbursement_Type>
	<cfset ReimbursementAmount = GetReimbursementInfo.Reimbursement_Amount>
	<cfset ReimbursementNumber = GetReimbursementInfo.Reimbursement_Number>
	<cfset ReimbursementDate = GetReimbursementInfo.Reimbursement_Date>
	<cfset ReimbursementComments = GetReimbursementInfo.Reimbursement_Comments>

	<cfset FinalProgramList = GetReimbursementInfo.Contract_Main_ID>
	<cfset FinalDistributorList = GetReimbursementInfo.Distributor_ID>
	<cfset action = "edit">
	<input type="hidden" name="BB_Reimbursement_ID" value="#GetReimbursementInfo.BB_Reimbursement_ID#">
	
</cfif>

<!---Gets user friendly names--->
<cfquery name="GetDistributorName" datasource="#application.datasource#">
SELECT Name 
FROM BSA_Foodservice_Customers 
WHERE BSA_Foodservice_Customers_ID = '#FinalDistributorList#'
</cfquery>

<!---Gets program number--->
<cfquery name="GetProgramNumber" datasource="#application.datasource#">
SELECT Contract_Main.Contract_Title, Contract_Main.Contract_Number, Contract_Status_Types.Contract_Status_Type_Desc 
FROM Contract_Main
	INNER JOIN Contract_Status_Types
	ON Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
WHERE Contract_Main_ID = #FinalProgramList#
</cfquery>


	<SCRIPT language="JavaScript" src="/Common_Files/scripts/numberValidation.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>	
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
	<CF_MessageWindow>

<div align="center">
<input type="hidden" name="Distributor_ID" value="#FinalDistributorList#">
<input type="hidden" name="Contract_Main_ID" value="#FinalProgramList#">
<table width="800" border="0" cellpadding="1" cellspacing="2">
	<!---Distributor--->
	<Tr>
		<td align="Right" valign="top"><strong>#application.returned_customer_setting.distributor_label_singular#</strong></td>
		<td rowspan="7" bgcolor="orange"><img src="/Images/CLEAR.GIF" width="1" height="1" alt="" border="0"></td>
		<td>#GetDistributorName.Name#
		</td>
	</TR>
	
	<!---Program--->
	<Tr>
		<td align="Right" valign="top"><strong>Contract</strong></td>
			<td>#GetProgramNumber.Contract_Number# -- #GetProgramNumber.Contract_Title# (#GetProgramNumber.Contract_Status_Type_Desc#)
		</td>
	</TR>
	
	
	<!---Reimbursement types--->
	<Tr>
		<td align="Right" valign="top"><strong>Reimbursement Type</strong></td>
		<td>
		<cfquery name="GetReimbursementTypes" datasource="#application.datasource#">
		SELECT * FROM BB_Reimbursement_Type ORDER BY BB_Reimbursement_Type_ID
		</cfquery>
		
		<select name="ReimbursementType">
		<cfloop query="GetReimbursementTypes">
			<option value="#BB_Reimbursement_Type_ID#" <cfif BB_Reimbursement_Type_ID IS ReimbursementType>selected</cfif>>#Reimbursement_Type_Description#</option>
		</cfloop>
		</select>
		
		</td>
	</TR>
	<!---Reimbursement amount--->
	<tr>
		<td  align="right" valign="top"><strong>Amount</strong><span id="error_ReimbursementAmount"></span></td>
		<td><input type="text" size="10" maxlength="10" name="ReimbursementAmount" value="#ReimbursementAmount#" onkeyup="clenseText(this, '0123456789');"></td>
	</tr>
	<!---Reference number--->
	<tr>
		<td  align="right" valign="top"><strong>Number</strong><span id="error_ReimbursementNumber"></span></td>
		<td><input type="text" size="20" maxlength="20" name="ReimbursementNumber" onKeyUp="clenseText(this, '0123456789');" value="#ReimbursementNumber#"></td>
	</tr>
	<!---Date--->
	<tr>
		<td  align="right" valign="top"><strong>Date</strong><span id="error_ReimbursementDate"></span></td>
		<td><CF_EASYDATE FORMNAME="SaveReimbursement" FIELDNAME="ReimbursementDate" FORMAT="mm/dd/yyyy" DEFAULT="#ReimbursementDate#"></td>
	</tr>
	<!---Comments--->
	<tr>
		<td  align="right" valign="top"><strong>Comments</strong><span id="error_ReimbursementComments"></span></td>
		<td><textarea name="ReimbursementComments" cols="60" rows="6">#trim(ReimbursementComments)#</textarea></td>
	</tr>
	
	<tr><td colspan="2">&nbsp; </td>
		<td >
			<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"confirmCompletion();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Save this information"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	
		</td>
	</tr>
	
</table>
</div>
<input type="hidden" name="Action" value="#action#">

</form>
</cfoutput>

<script>
function confirmCompletion(){
	
	ErrorCount = 0
	
	<!--- Amount --->
		if(document.all.ReimbursementAmount.value.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter a reimbursement amount.", document.all.error_ReimbursementAmount);
		}
		else
		{
			clearQueue(document.all.error_ReimbursementAmount);
		}

		<!--- Number --->
		if(document.all.ReimbursementNumber.value.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter a reimbursement/check number.", document.all.error_ReimbursementNumber);
		}
		else
		{
			clearQueue(document.all.error_ReimbursementNumber);
		}

		<!--- Date --->
		if(document.all.ReimbursementDate.value.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter a reimbursement date.", document.all.error_ReimbursementDate);
		}
		else
		{
			clearQueue(document.all.error_ReimbursementDate);
		}
	
		<!--- Comments--->
		if(document.all.ReimbursementComments.value.length > 1000)	{
			ErrorCount++;
			queueMessage("Comments cannot exceed 1000 characters. Your comments currently have " + document.all.ReimbursementComments.value.length + " characters.", document.all.error_ReimbursementComments);
		}
		else
		{
			clearQueue(document.all.error_ReimbursementDate);
		}

			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
				SaveReimbursement.submit()
			}
			else {
				showMessageWindow()
			}	

		}
</script>