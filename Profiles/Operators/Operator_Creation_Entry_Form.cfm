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

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=34>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Operator_Location_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Operator_Location_Type>
	<cftry>
		<cfset Get_Operator_Location_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"deleted" = "eq.0",
				"select" = "operator_location_type"
			}), "operator_location_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Location_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Location_Type>
<CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#">
Select	distinct Operator_Location_Type
From	BSA_Operator
Where	deleted = 0
</CFQUERY>
</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---------------------------------------------------------------------------- 
  Dev Notes: D19761 -Anand Rao 07/28/09
  Changed to query to have a where clause to look for active = 1 and 
  Deleted = 0 and pick the records from awayx_Operator_type table
------------------------------------------------------------------------------>
<cfset useLakebaseForGet_Operator_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("awayx_operator_type")>
<cfif useLakebaseForGet_Operator_Type>
	<cftry>
		<cfset Get_Operator_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("awayx_operator_type", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "operator_type"
			}), "operator_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Type>
<CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#">
  SELECT	Distinct Operator_Type
  FROM awayX_Operator_Type
  WHERE Active = 1 AND Deleted = 0
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>




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


<DIV CLASS="title2">Create a new <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></DIV>
<HR COLOR="Orange">



<CFFORM action="Operator_Creation_Entry_Action.cfm" method="post">

<B>bold items are required</B><BR><BR>

<INPUT TYPE="hidden" NAME="deleted" VALUE="0">

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">

    <TR>
    <TD valign="top" ALIGN="right" ALIGN="right" ALIGN="right"><B> <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name </B></TD>
    <TD>
		<CFINPUT TYPE="Text" NAME="Operator_Name" MESSAGE="You must enter the name of the Operator..." REQUIRED="Yes" MAXLENGTH="510" STYLE="width:400px;">
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"><B> Address </B></TD>
    <TD>
		<CFINPUT TYPE="Text" NAME="Operator_Address" MESSAGE="You must enter the address of the Operator..." REQUIRED="Yes" MAXLENGTH="510" STYLE="width:400px;">
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"><B> City, State, ZIP </B></TD>
    <TD>

		<CFINPUT TYPE="Text" NAME="Operator_City" MESSAGE="You must enter the city..." REQUIRED="Yes" MAXLENGTH="510">
		<SELECT NAME="Operator_State" STYLE="width:123px;">
		<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#">#State_Name#</OPTION></CFOUTPUT>
		</SELECT>
		<CFINPUT TYPE="Text" NAME="Operator_Zip" MESSAGE="You must enter the Zip code..." REQUIRED="Yes" MAXLENGTH="510" STYLE="width:70px;">

	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"><B> Number of Locations </B></TD>
    <TD>
		<CFINPUT TYPE="Text" NAME="Operator_Number_Of_Locations" MESSAGE="You must enter the number of locations..." VALIDATE="integer" REQUIRED="Yes" MAXLENGTH="8">
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"><B> Type & Location </B></TD>
    <TD>
		<SELECT NAME="Operator_Type">
		<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#">#Operator_Type#</OPTION></CFOUTPUT>
		</SELECT>
		<SELECT NAME="Operator_Location_Type">
		<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#">#Operator_Location_Type#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"> Doing business as... </TD>
    <TD>
		<TEXTAREA COLS="48" ROWS="5" NAME="Operator_DBA"></TEXTAREA>
	</TD>
	</TR>
</TABLE>
<P>
<INPUT type="submit" value="Save Data" STYLE="width:100px;">

</CFFORM>

<FONT COLOR="Red"><B>[</B> </FONT>
<A HREF="Operator_Search_Form.cfm">Search Operator Database</A>
<FONT COLOR="Red"><B>]</B> </FONT>


</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
