		<!------ lumpsumAccessValues.cfm ----->
<cfoutput>
<cfparam name="url.profileId" 	default="">
<cfif NOT isNumeric(url.profileId) OR url.profileId EQ 0>
	<cfabort>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Approval Group Values</title>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>	
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<script language="JavaScript">
	function clenseTextBuffer(textObject,validlist){
		var decimalPlaces = 2;
		if(textObject.value.indexOf("*") != -1){
			textObject.value = "*";
		}
		else{
			clenseText(textObject,validlist)
			limitXdecimalplaces(decimalPlaces, textObject);
		}
	}
	
	function applyApprovalValueForall(input_name_start, iValue, checkbox_name_Start)
	{
		var fValue = parseFloat(iValue);
		if(iValue == '*' || !isNaN(fValue))
		{		
			ApplyValueForAll(input_name_start, iValue, checkbox_name_Start);
		}
	}
		/* The character at a certain position ('_position') cannot be what is passed as ('_char1') and ('_char2') 
		   Currently, it is being used for making sure that the first letter is not a decimal and 
			 the number cannot be less than zero (zero is an exception).
		*/
		function getLetterAtPosition(_word,_char1,_char2,_position)
		{
			var fieldname;
		 if(_word.value != '')
		 {
		 /*
			The first letter cannot be a decimal and the first letter cannot be zero (if the value has a decimal)
		 */
			 if(_word.value.charAt(_position) == _char1 || (_word.value.charAt(_position) == _char2  && _word.value.indexOf ('.') != -1))
			 {
				 alert("The value entered needs to be greater or equal to 1");
				_word.value = '';
			 }
		 }
	  }
	</script>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
</head>

<body>

<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<cfinclude template ="profile_qry_include.cfm">

<cfset sProfileName = CreateObject("component", "components.user.Profile").getProfileName(url.profileId)>
<font COLOR="Navy" SIZE="+1">
#Application.LumpsumLabel# Access / Approve for #sProfileName#
</font>		
<HR COLOR="orange">
<table cellpadding="5" cellspacing="0" align="center">
<tr>
	<td><B>Check All</B>
	<input type="checkbox" name="checkValueAll" id="checkValueAll" value="1" onClick="CHSelectAll('Check_',this.checked)">
	</td>
	<td><B>Approval Amount</B>
	<input type="Text" name="approvalValueAll" onkeyup="clenseTextBuffer(this, '*.02134567890');getLetterAtPosition(this,'.',0,0)" size="3">
	<CF_smallLink 
		title = "apply" 
		url = "##"
		parameters = "onClick=""javascript: applyApprovalValueForall('Program_Lump_Sum_Name_', document.all.approvalValueAll.value, 'Check_');
		applyApprovalValueForall('Total_LS_Approval_Amount', document.all.approvalValueAll.value, 'Check_Total_LS_Approval_Amount');
		applyApprovalValueForall('Inactive_LS_Approval_Amount', document.all.approvalValueAll.value, 'Check_Inactive_LS_Approval_Amount');
		applyApprovalValueForall('Lump_Sum_Approval_Amount', document.all.approvalValueAll.value, 'Check_Lump_Sum_Approval_Amount');
		return false;"""
	>
	</td>
</tr>
</table>
<cfset maxCols = 2>
<cfset bgColor = "ffdead">
<cfset checkBoxDisabled = val(Evaluate("Get_#url.profileId#_Settings.Cont_Prog_Approval_Rights"))>
<form method="post" name="frmlumpsumAccessApprove" action="lumpsumAccessValuesAction.cfm">
<table align="center" cellpadding="3" cellspacing="1" bgcolor="c0c0c0">
	<thead bgcolor="c0c0c0">
		<cfloop index="i" from="1" to="#maxCols#">
		<td><B>select</B></td>
		<td><B>#Application.LumpsumLabel# Component Name</B></td>
		<td><B>Approval Amount</B></td>
		</cfloop>
	</thead>

	<tr bgcolor="FFFFFF">	
	<!---Loop through active, non-deleted lump sum amounts--->
	<cfloop query="GetLumpSums">
		<cfset lsNameID = GetLumpSums.Program_Lump_Sum_Name_ID>
			
		<cfset useLakebaseForGetApprovalAmountforProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_ls_approval")>
<cfif useLakebaseForGetApprovalAmountforProfile>
	<cftry>
		<cfset GetApprovalAmountforProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_ls_approval", {
				"profiles_id" = "eq.#url.profileId#",
				"program_lump_sum_name_id" = "eq.#lsNameID#",
				"select" = "approval_amount"
			}), "approval_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetApprovalAmountforProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetApprovalAmountforProfile>
<cfquery name="GetApprovalAmountforProfile" datasource="#application.datasource#">
			SELECT 	Approval_Amount
			FROM 	Profile_LS_Approval
			WHERE 	Profiles_ID = #url.profileId#
			AND 	Program_Lump_Sum_Name_ID = #lsNameID#
		</cfquery>
</cfif>

		<td bgcolor="#bgColor#"><input type="checkbox" value="1" name="Check_#lsNameID#"></td>
		<td bgcolor="#bgColor#">#Program_Lump_Sum_Name#</td>
		<td bgcolor="#bgColor#"><INPUT TYPE="text" SIZE="5" NAME="Program_Lump_Sum_Name_#lsNameID#" ID="Program_LSN_#lsNameID#" SIZE="5" VALUE="<cfif GetApprovalAmountforProfile.Approval_Amount IS "*">#GetApprovalAmountforProfile.Approval_Amount#<cfelse>#numberformat(GetApprovalAmountforProfile.Approval_Amount, '_.__')#</cfif>" onkeyup="clenseTextBuffer(this, '*.02134567890');getLetterAtPosition(this,'.',0,0)" #checkBoxDisabled#></td>	
	<cfif not currentRow mod maxCols and currentRow neq recordCount></tr><tr bgcolor="FFFFFF"></cfif>
		<cfset x = currentRow>
	</cfloop>
	<cfif Evaluate((x mod maxCols)) NEQ 0>
	<cfloop index="i" from="#Evaluate((x mod maxCols)+1)#" to="#maxCols#">
	<td bgcolor="#bgColor#">&nbsp;</td><td bgcolor="#bgColor#">&nbsp;</td ><td bgcolor="#bgColor#">&nbsp;</td>
	</cfloop>
	</cfif>
	</tr>
	<TR bgcolor="FFFFFF">
		<td bgcolor="#bgColor#"><input type="checkbox" value="1" name="Check_Total_LS_Approval_Amount"></td>
		<td bgcolor="#bgColor#">Total #Application.LumpsumLabel# Approval</TD>
		<td bgcolor="#bgColor#" colspan="4"><input TYPE="text" NAME="Total_LS_Approval_Amount" SIZE="5" VALUE="<cfif evaluate("Get_#url.profileId#_Settings.Total_LS_Approval_Amount") IS "*">#evaluate("Get_#url.profileId#_Settings.Total_LS_Approval_Amount")#<cfelse>#numberformat(evaluate("Get_#url.profileId#_Settings.Total_LS_Approval_Amount"), '_.__')#</cfif>" onkeyup="clenseTextBuffer(this, '*.02134567890');getLetterAtPosition(this,'.',0,0)" #checkBoxDisabled#></TD>
	</TR>
	<TR bgcolor="FFFFFF">
		<td bgcolor="#bgColor#"><input type="checkbox" value="1" name="Check_Inactive_LS_Approval_Amount"></td>
		<td bgcolor="#bgColor#">Inactive #Application.LumpsumLabel# Approval</TD>
		<td bgcolor="#bgColor#" colspan="4"><input TYPE="text" NAME="Inactive_LS_Approval_Amount" SIZE="5" VALUE="<cfif evaluate("Get_#url.profileId#_Settings.Inactive_LS_Approval_Amount") IS "*">#evaluate("Get_#url.profileId#_Settings.Inactive_LS_Approval_Amount")#<cfelse>#numberformat(evaluate("Get_#url.profileId#_Settings.Inactive_LS_Approval_Amount"), '_.__')#</cfif>" onkeyup="clenseTextBuffer(this, '*.02134567890');getLetterAtPosition(this,'.',0,0)" #checkBoxDisabled#></TD>
	</TR>
	<TR bgcolor="FFFFFF">
		<td bgcolor="#bgColor#"><input type="checkbox" value="1" name="Check_Lump_Sum_Approval_Amount"></td>
		<td bgcolor="#bgColor#">Growth #Application.LumpsumLabel# Approval</TD>
		<td bgcolor="#bgColor#" colspan="4"><input TYPE="text" NAME="Lump_Sum_Approval_Amount" SIZE="5" VALUE="<cfif evaluate("Get_#url.profileId#_Settings.Lump_Sum_Approval_Amount") IS "*">#evaluate("Get_#url.profileId#_Settings.Lump_Sum_Approval_Amount")#<cfelse>#numberformat(evaluate("Get_#url.profileId#_Settings.Lump_Sum_Approval_Amount"), '_.__')#</cfif>" onkeyup="clenseTextBuffer(this, '*.02134567890');getLetterAtPosition(this,'.',0,0)" #checkBoxDisabled#></TD>
	</TR>
</table>
<input type="hidden" name="Profile_ID" value="#url.profileId#">
<br>
<table>
<TR>
		<TD colspan="100%">
		<cfinclude template="Select_GroupLevelAccess_Profiles.cfm" />
		</TD>
		</TR>
</table>
<br>
<div align="center">
	<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"save"
		BUTTON_ACTION	=	"document.frmlumpsumAccessApprove.submit();"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
</div>
</form>
</body>
</html>

</cfoutput>