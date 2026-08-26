<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<CFPARAM NAME="FORM.Rule_Name" 			DEFAULT="">
<CFPARAM NAME="FORM.Number_Of_Comms" 	DEFAULT="1">

<CFPARAM NAME="FORM.RID" DEFAULT="">
<CFIF len(trim(FORM.RID)) GT 0>
	<cf_cryp type="de" key="#request.key#" string="#FORM.RID#" Return="RuleReturn">
	<cfset useLakebaseForgetSavedRuleInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rules")>
<cfif useLakebaseForgetSavedRuleInfo>
	<cftry>
		<cfset getSavedRuleInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_rules", {
				"program_formula_pricing_rule_id" = "eq.#RuleReturn.value#",
				"select" = "rule_name,number_of_comms"
			}), "rule_name,number_of_comms"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSavedRuleInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSavedRuleInfo>
<CFQUERY NAME="getSavedRuleInfo" datasource="#application.datasource#">
		SELECT Rule_Name,Number_Of_Comms
		FROM Program_Formula_Pricing_Rules
		WHERE Program_Formula_Pricing_Rule_ID = '#RuleReturn.value#'
	</CFQUERY>
</cfif>

	<CFIF getSavedRuleInfo.recordCount GT 0>
		<CFSET FORM.Rule_Name 		= getSavedRuleInfo.Rule_Name>
		<CFSET FORM.Number_Of_Comms = getSavedRuleInfo.Number_Of_Comms>
	<CFELSE>
		<CFSET FORM.RID = "">
	</CFIF>
</CFIF>


<CFSET PAGE_TITLE="Formula pricing Rule : Step 1">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<CFSET Help_URL="/help_files/manual/createprogram/page13.cfm##pr">
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfinclude template="minimal_contract_info.cfm">
<!------<CFIF Len(FORM.RID) EQ 0>
	<FORM ACTION="Contract_Forumla_Rule_Step_1_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<CFELSE>
	<FORM ACTION="Contract_Forumla_Confirm_Step_1.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
</CFIF>----->
<FORM ACTION="Contract_Forumla_Rule_Step_1_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	
	
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rule Information</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Rule Name:</B></TD>
			<TD><INPUT TYPE="text" NAME="Rule_Name" ID="Rule_Name" SIZE="64" MAXLENGTH="254" VALUE="<CFOUTPUT>#FORM.Rule_Name#</CFOUTPUT>"></TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Number Of Commodities In This Rule:</B></TD>
			<TD>
				<SELECT NAME="Number_Of_Comms">
					<CFOUTPUT>
					<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
						<option VALUE="#i#" <CFIF i EQ FORM.Number_Of_Comms>selected</CFIF>>#i#</option>
					</CFLOOP>
					</CFOUTPUT>
				</select>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"submitForm();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
	</FIELDSET>
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="PROGRAM_ID" ID="PROGRAM_ID" VALUE="#URL.CID#">

	<CFIF len(trim(FORM.RID)) GT 0>
		<INPUT TYPE="hidden" NAME="UPDATE" ID="UPDATE" VALUE="1">
		<INPUT TYPE="hidden" NAME="Rule_ID" ID="Rule_ID" VALUE="#FORM.RID#">
		<INPUT TYPE="hidden" NAME="Original_Rule_Name" ID="Original_Rule_Name" VALUE="#FORM.Rule_Name#">
		<INPUT TYPE="hidden" NAME="Original_Comm_Count" ID="Rule_ID" VALUE="#FORM.Number_Of_Comms#">
	<CFELSE>
		<INPUT TYPE="hidden" NAME="UPDATE" ID="UPDATE" VALUE="0">	
	</CFIF>

	</CFOUTPUT>
</FORM>
<script>
	function submitForm(){
		if(document.all.Rule_Name.value.length == 0){
			alert("Please Name This Rule.")
		}
		else {
			document.all.MyForm.submit();
		}
	}
</script>

<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
