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
<CFSET helpfilenumber=35>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Market Area																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Market_Area" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Market_Area
	FROM BSA_Foodservice_Brokers
	WHERE deleted = 0
</CFQUERY>







<style>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
input,select, TEXTAREA
	{
		width:	300px;
		font-size: 10px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 10px;
	}
</style>



<DIV CLASS="title2">Create a new Broker</DIV>
<HR COLOR="Orange">

<B>bold items are required</B><BR><BR>


<CFFORM action="Broker_Creation_Entry_Action.cfm" method="post" NAME="MyForm">

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">
    <TR>
    <TD ALIGN="right"><B>Region Shared:</B></TD>
    <TD>
		<CFINPUT TYPE="Text" NAME="Region_Shard" MAXLENGTH="510" MESSAGE="You must enter a Region Shared Code" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Region Legacy Shared:</B></TD>
    <TD>
		<CFINPUT type="text" name="Region_Legcy_Shard" maxLength="510" MESSAGE="You must enter a Region Legacy Shared Code" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Market Area:</B></TD>
    <TD>
		<SELECT NAME="Market_Area">
			<CFOUTPUT QUERY="Get_Market_Area"><OPTION VALUE="#Market_Area#">#Market_Area#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Broker Shared:</B></TD>
    <TD>
		<CFINPUT type="text" name="Broker_Shard" maxLength="510" MESSAGE="You must enter a Broker Shared Code" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Broker Legacy Shared:</B></TD>
    <TD>
		<CFINPUT type="text" name="Broker_Legcy_Shard" maxLength="510" MESSAGE="You must enter a Broker Legacy Shared Code" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Broker Name:</B></TD>
    <TD>
		<CFINPUT type="text" name="Broker_Name" maxLength="510" MESSAGE="You must enter a Broker Name" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Address:</B></TD>
    <TD>
		<CFINPUT type="text" name="Address" maxLength="510" MESSAGE="You must enter the Address" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>City, State, Postal:</B></TD>
    <TD>
		<CFINPUT type="text" name="City" maxLength="510" STYLE="width: 100" MESSAGE="You must enter the City" REQUIRED="Yes">
		<SELECT NAME="State" STYLE="width: 100">
			<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#">#State_Name#</OPTION></CFOUTPUT>
		</SELECT>
		<CFINPUT TYPE="Text" NAME="Zip" MESSAGE="You must enter the Postal Code" REQUIRED="Yes" MAXLENGTH="510" STYLE="width: 95">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Broker CSR:</B></TD>
    <TD>
		<CFINPUT type="text" name="Broker_CSR" maxLength="510" MESSAGE="You must enter the Broker CSR" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Account Executive:</B></TD>
    <TD>
		<CFINPUT type="text" name="Account_Exec" maxLength="510" MESSAGE="You must enter the Account Executive" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Phone, Fax, Email:</B></TD>
    <TD>
		<CFINPUT TYPE="Text" NAME="Phone_Number" MESSAGE="You must enter the Phone Number" VALIDATE="telephone" REQUIRED="Yes" MAXLENGTH="510" STYLE="width: 95">
		<CFINPUT TYPE="Text" NAME="Fax_Number" MESSAGE="You must enter the Fax Number" VALIDATE="telephone" REQUIRED="Yes" MAXLENGTH="510" STYLE="width: 95">
		<CFINPUT type="text" name="E_Mail" maxLength="510" MESSAGE="You must enter the EMail address" REQUIRED="Yes" STYLE="width: 105">
	</TD>
	</TR>
<!--- 
    <TR>
    <TD ALIGN="right"><B>Fax Number:</B></TD>
    <TD>
		<CFINPUT type="text" name="Fax_Number" maxLength="510" MESSAGE="You must enter the Fax Number" REQUIRED="Yes">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>EMail:</B></TD>
    <TD>
		<CFINPUT type="text" name="E_Mail" maxLength="510" MESSAGE="You must enter the EMail address" REQUIRED="Yes">
	</TD>
	</TR>
 --->
    <TR>
    <TD ALIGN="right"><B>Line of Business:</B></TD>
    <TD>
		<CFINPUT type="text" name="Line_Of_Business" maxLength="510" MESSAGE="You must enter the Line of Business" REQUIRED="Yes">
	</TD>
	</TR>
</TABLE>
<P>
<INPUT type="submit" value="Insert Data" STYLE="width: 100" >
<INPUT type="hidden" name="Deleted" value="0">
</CFFORM>





<FONT COLOR="Red"><B>[</B> </FONT>
<A HREF="OperatorSearch_Form.cfm">Search <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Database</A>
<FONT COLOR="Red"><B>]</B> </FONT>


</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
