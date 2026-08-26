<CFSET PAGETITLE = "PROGRAMS: Customer Types">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfparam name="url.customer_type_id" default="0">

<cfset CustTypeManager = CreateObject("component", "components.programs.business_segment.customertypemanager") />

<cfset getCustomerTypes = CustTypeManager.get(url.customer_type_id) />


<cfparam name="getCustomerTypes.Customer_Type_Desc" default="" />

<cfoutput>
<FORM name="custedit" method="post" action="customer_type_save.cfm">
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Customer type Information</LEGEND>
	<table>
	<tr>
	<td>&nbsp;</td>
	</tr>
	<TR>
			<TD ALIGN="right"><B>Customer type Description:</B></TD>
			<TD>#HTMLEditFormat(trim(getCustomerTypes.Customer_Type_Abbr))#</TD>
		</TR>	
		<TR>
			<TD ALIGN="right"><B>Customer type Description:</B></TD>
			<TD><span id="Err_Sp_Desc"></span><INPUT NAME="Customer_Type_Desc" TYPE="text" VALUE="#HTMLEditFormat(trim(getCustomerTypes.Customer_Type_Desc))#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>		
		<tr>
	<td>&nbsp;</td>
	</tr>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return validateForm();"""
			>
			<CF_smallLink 
				title = "cancel" 
				url = "customer_type_list.cfm"
				parameters = ""
			>
			</TD>
		</TR>
	</table>
</FIELDSET>
<input type="hidden" name="customer_type_id" value="#getCustomerTypes.customer_type_id#">
</FORM>
<cf_MessageWindow />
</cfoutput>
<script>
function validateForm()
{
ErrorCount = 0
	if (document.all.Customer_Type_Desc.value == "")
			{
				ErrorCount++;
				queueMessage("You must eneter a description for the customer type.", document.all.Err_Sp_Desc);
			}
			else
			{
				clearQueue(document.all.Err_Sp_Desc);
			}
		
		if(ErrorCount == 0) {
					custedit.submit();
					return false;
			}
			else {
				showMessageWindow();
				return false;
			}	
}

</script>
</Body>