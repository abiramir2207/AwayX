<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the date that this setting was updated													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_This_Date" datasource="#application.datasource#">
Select	Payables_Expect_Rate_Date_Updated
From	_Users_Settings
Where	User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>

		<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
		Select		*
		From		_Users_Settings
		Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=29>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<FORM ACTION="e-rate_action.cfm" METHOD="post">



<!--- Set the update/save flag that will be passed to the next page --->
<CFIF Get_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_This_Date.Payables_Expect_Rate_Date_Updated, 'm/d/yyy')# #timeformat(Get_This_Date.Payables_Expect_Rate_Date_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>




<B>To calculate the Expected Rate for Delivered Net Price contracts, use:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
	<TD><INPUT TYPE="radio" NAME="Payables_Expect_Rate" VALUE="1"<CFIF Get_Settings.Payables_Expect_Rate EQ 1> CHECKED<CFELSE></CFIF>></TD>
	<TD>The average of all price brackets</TD>
</TR>
<TR>
	<TD>&nbsp;&nbsp;</TD>
	<TD><INPUT TYPE="radio" NAME="Payables_Expect_Rate" VALUE="2"<CFIF Get_Settings.Payables_Expect_Rate EQ 2> CHECKED<CFELSE></CFIF>></TD>
	<TD>The middle price bracket only</TD>
</TR>
<TR>
	<TD>&nbsp;&nbsp;</TD>
	<TD><INPUT TYPE="radio" NAME="Payables_Expect_Rate" VALUE="3"<CFIF Get_Settings.Payables_Expect_Rate EQ 3> CHECKED<CFELSE></CFIF>></TD>
	<TD>Purchase Order or Invoice Data</TD>
</TR>
</TABLE>

<HR WIDTH="600">

<B>To calculate the Expected Rate for FOB Net price contracts, use:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
	<TD><INPUT TYPE="text" NAME="Payables_Expect_Rate_Calc_percent_FOB" VALUE="<CFOUTPUT>#Get_Settings.Payables_Expect_Rate_Calc_percent_FOB#</CFOUTPUT>" SIZE="6"></TD>
	<TD>% over average FOB price</TD>
</TR>
<!--- 
<TR>
	<TD>&nbsp;&nbsp;</TD>
	<TD><INPUT TYPE="text" NAME="Payables_Expect_Rate_Calc_dollar_pound" VALUE="<CFOUTPUT>#Get_Settings.Payables_Expect_Rate_Calc_dollar_pound#</CFOUTPUT>" SIZE="6"></TD>
	<TD>$ per pound over average FOB price</TD>
</TR>
 ---><!--- 
<TR>
	<TD>&nbsp;&nbsp;</TD>
	<TD><INPUT TYPE="text" NAME="Payables_Expect_Rate_Calc_dollar_case" VALUE="<CFOUTPUT>#Get_Settings.Payables_Expect_Rate_Calc_dollar_case#</CFOUTPUT>" SIZE="6"></TD>
	<TD>$ per case over average FOB price</TD>
</TR>

 --->
 </TABLE>

<HR WIDTH="600">

<B>Expected Rate period:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	
	&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Rate_Period" VALUE="30"<CFIF Get_Settings.Payables_Expect_Rate_Period EQ 30> CHECKED<CFELSE></CFIF>>
	30 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Rate_Period" VALUE="60"<CFIF Get_Settings.Payables_Expect_Rate_Period EQ 60> CHECKED<CFELSE></CFIF>>
	60 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Rate_Period" VALUE="90"<CFIF Get_Settings.Payables_Expect_Rate_Period EQ 90> CHECKED<CFELSE></CFIF>>
	90 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<!--- Decide if there is a custom period instead of the default 30,60,90 days --->
	<CFIF (Get_Settings.Payables_Expect_Rate_Period EQ 30) OR (Get_Settings.Payables_Expect_Rate_Period EQ 60) OR (Get_Settings.Payables_Expect_Rate_Period EQ 90)>
		<CFSET CHECKED="">
		<CFSET customperiod="">
	<CFELSE>
		<CFSET CHECKED=" CHECKED">
		<CFSET customperiod=Get_Settings.Payables_Expect_Rate_Period>
	</CFIF>
	<INPUT TYPE="radio" NAME="Payables_Expect_Rate_Period" VALUE="1"<CFOUTPUT>#CHECKED#</CFOUTPUT>>
	Custom <INPUT TYPE="text" NAME="Payables_Expect_Rate_Period_other" VALUE="<CFOUTPUT>#customperiod#</CFOUTPUT>" SIZE="6">days
	
	
	</TD>
</TR>
</TABLE>


<HR WIDTH="600">

<B>Include Billback Period in Expected Rate period:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Rate_Include_Period" VALUE="1"<CFIF Get_Settings.Payables_Expect_Rate_Include_Period EQ 1> CHECKED<CFELSE></CFIF>>
	Yes

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Rate_Include_Period" VALUE="0"<CFIF Get_Settings.Payables_Expect_Rate_Include_Period EQ 0> CHECKED<CFELSE></CFIF>>
	No
	</TD>
</TR>
</TABLE>

<HR WIDTH="600">

<B>
	Highlight billback rates as Deviations if they exceed the Expected Rate by 
	<INPUT TYPE="text" NAME="Payables_Expect_Rate_Highlight_billback" VALUE="<CFOUTPUT>#Get_Settings.Payables_Expect_Rate_Highlight_billback#</CFOUTPUT>" SIZE="6">
	%
</B>


<BR><BR>


	<INPUT TYPE="hidden" NAME="User_ID" VALUE="<CFOUTPUT>#request.AccessStructure.User_ID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Date_Updated" VALUE="<CFOUTPUT>#createodbcdatetime(now())#</CFOUTPUT>">



<INPUT TYPE="submit" VALUE="Save Preferences...">

</FORM>



</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



