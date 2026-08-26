

<CFSET PAGETITLE = "PROGRAMS: Customer Types">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset CustTypeManager = CreateObject("component", "components.programs.business_segment.customertypemanager") />

<cfset getCustomerTypes = CustTypeManager.getCustomerTypes() />

List of Customer Types.
<p>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
	<TD STYLE="font-size:11px;">
			<b>Customer type Id</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Customer type</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Edit</b>
		</TD>
	</TR>
	<cfif not getCustomerTypes.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<CFOUTPUT QUERY="getCustomerTypes">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
		<TD>#Customer_Type_Abbr#</TD>
		<TD>#Customer_Type_Desc#</TD>
		<td><a href="customer_type_edit.cfm?customer_type_id=#Customer_Type_ID#">(edit)</a></td>
	</TR>	
	</CFOUTPUT>
</TABLE>
<br>
</body>

