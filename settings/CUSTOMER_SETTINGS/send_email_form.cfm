<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFSET pagetitle = "SYSTEM ADMINISTRATION: CUSTOMER SETTINGS">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset useLakebaseForselect_field = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_settings_column_nature")>
<cfif useLakebaseForselect_field>
	<cftry>
		<cfset select_field = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_settings_column_nature", {
				"column_nature" = "eq.#URL.nature#",
				"select" = "column_name,dispaly_label"
			}), "column_name,dispaly_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselect_field = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselect_field>
<CFQUERY name = "select_field" datasource="#application.datasource#">
	SELECT column_name,dispaly_label from customer_settings_column_nature where column_nature = '#URL.nature#'
</CFQUERY>
</cfif>
<CFSET p_nature = "#url.nature#">


<CFIF url.nature EQ "functional">
	<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="functional_page.cfm"><B>back</B></A>
	<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
<CFELSEIF url.nature EQ "cosmetics">
	<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="cosmetic_field_page.cfm"><B>back</B></A>
	<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>

<CFELSE>
	<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="other_fields_page.cfm"><B>back</B></A>
	<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>

</CFIF>





<br><br><br><br><br>
<STYLE>
	input.small
		{
			font: 13px Arial;
			width: 250px;
		}
	input.large
		{
			font: 13px Arial;
			width: 500px;
		}
	select
		{
			font: 13px Arial;
			width: 250px;
		}
</STYLE>

<script type = "text/javascript">
	function validate()
	{
		x=document.email_entry_form
		if (x.column_name.value == "")
		{
			alert("you must select a column name")
			x.column_name.focus()
			return false
		}
	}	
</script>

<DIV STYLE="font-size:13px;border-bottom:solid navy 1px;color:grey">UPDATE FIELD REFERENCE</DIV>

<CFFORM name = "email_entry_form" action = "send_email.cfm" method = "post" onsubmit="return validate()">
<CFOUTPUT>
<INPUT type = "hidden" name = "page_name" value = "#url.nature#">
</CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" ALIGN="center">
	<TR>
		
		<CFOUTPUT>
		<TD><INPUT TYPE="HIDDEN" NAME="email_from" CLASS="large" VALUE="#request.AccessStructure.User_Email#"></TD>
		</CFOUTPUT>
	</TR>	

	<TR>
		<TD ALIGN="right" NOWRAP VALIGN="top">Select the column to be modified</TD>
		<TD><CFSELECT name = "column_name" query = "select_field" display="dispaly_label" value="column_name"><option value="" selected>Select a column name</CFSELECT></TD>
	</TR>
	<TR>
		<TD ALIGN="right" NOWRAP VALIGN="top">Refered as :</TD>
		<TD><CFINPUT TYPE="text" NAME="column_value" CLASS="large" required = "yes" message = "You must enter Value for REFERED AS"></TD>
	</TR>
	
	<TR>
		<TD ALIGN="right" NOWRAP VALIGN="top">Enter Your Message :</TD>
		<TD><TEXTAREA NAME="send_message" STYLE="width: 500px; height: 100px;"></TEXTAREA><BR><BR></TD>
	</TR>
	<TR>
		<TD ALIGN="right" NOWRAP VALIGN="top"><INPUT type = "submit" value = "send" </TD>
	</TR>
</CFFORM>


</body>
</html>
