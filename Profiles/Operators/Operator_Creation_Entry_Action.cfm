<CFINSERT datasource="#application.datasource#" tableName="BSA_Operator">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Title Goes Here</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0"><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>

<BR>


<style>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
input,select, TEXTAREA
	{
		width:	200px;
		font-size: 10px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 10px;
	}
</style>

<BR><BR>


<B>The following information was saved to the database</B>
<BR><BR>

<TABLE>


    <TR>
    <TD valign="top"><B> <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Name#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> Address: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Address#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> City, State, Zip Code: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_City#</CFOUTPUT>, 
		<CFOUTPUT>#Form.Operator_State#</CFOUTPUT>, 
		<CFOUTPUT>#Form.Operator_Zip#</CFOUTPUT>
	</TD>
	</TR>

	<TR>
    <TD valign="top"><B> Number of locations: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Number_Of_Locations#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> Type & Location: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_Type#</CFOUTPUT>, 
		<CFOUTPUT>#Form.Operator_Location_Type#</CFOUTPUT>
	</TD>
	</TR>

    <TR>
    <TD valign="top"><B> Operator_DBA: </B></TD>
    <TD>
		<CFOUTPUT>#Form.Operator_DBA#</CFOUTPUT>
	</TD>
	</TR>
</TABLE>



<A HREF="operatorcreation_entryform.cfm">Create a new <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></A>
&nbsp;&nbsp;&nbsp;
<A HREF="OperatorSearch_Form.cfm">Search <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Database</A>



</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
