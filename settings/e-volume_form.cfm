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
<!--- Get the user settings from the database to be used by all tabs								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
Select		*
From		_Users_Settings
Where		User_ID		=		'#request.AccessStructure.User_ID#'
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the date that this setting was updated													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_This_Date" datasource="#application.datasource#">
Select	Payables_Expect_Volume_Date_Updated
From	_Users_Settings
Where	User_ID		=		'#request.AccessStructure.User_ID#'
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=30>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<FORM ACTION="e-volume_action.cfm" METHOD="post">



<!--- Set the update/save flag that will be passed to the next page --->
<CFIF Get_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_This_Date.Payables_Expect_Volume_Date_Updated, 'm/d/yyy')# #timeformat(Get_This_Date.Payables_Expect_Volume_Date_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>


<BR>



<B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> purchase period:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	
	&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Purchase_Period" VALUE="30"<CFIF Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 30> CHECKED<CFELSE></CFIF>>
	30 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Purchase_Period" VALUE="60"<CFIF Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 60> CHECKED<CFELSE></CFIF>>
	60 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Purchase_Period" VALUE="90"<CFIF Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 90> CHECKED<CFELSE></CFIF>>
	90 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<!--- Decide if there is a custom period instead of the default 30,60,90 days --->
	<CFIF (Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 30) OR (Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 60) OR (Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 90)>
		<CFSET CHECKED="">
		<CFSET customperiod="">
	<CFELSE>
		<CFSET CHECKED=" CHECKED">
		<CFSET customperiod=Get_Settings.Payables_Expect_Volume_Purchase_Period>
	</CFIF>
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Purchase_Period" VALUE="1"<CFOUTPUT>#CHECKED#</CFOUTPUT>>
	Custom <INPUT TYPE="text" NAME="Payables_Expect_Volume_Purchase_Period_Other" VALUE="<CFOUTPUT>#customperiod#</CFOUTPUT>" SIZE="6">days
	</TD>
</TR>
</TABLE>

<BR>
<HR WIDTH="600">
<BR>

<B>Billback Aggregation period:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	
	&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Aggregation_Period" VALUE="30"<CFIF Get_Settings.Payables_Expect_Volume_Aggregation_Period EQ 30> CHECKED<CFELSE></CFIF>>
	30 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Aggregation_Period" VALUE="60"<CFIF Get_Settings.Payables_Expect_Volume_Aggregation_Period EQ 60> CHECKED<CFELSE></CFIF>>
	60 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Aggregation_Period" VALUE="90"<CFIF Get_Settings.Payables_Expect_Volume_Aggregation_Period EQ 90> CHECKED<CFELSE></CFIF>>
	90 Days

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<!--- Decide if there is a custom period instead of the default 30,60,90 days --->
	<CFIF (Get_Settings.Payables_Expect_Volume_Purchase_Period EQ 30) OR (Get_Settings.Payables_Expect_Volume_Aggregation_Period EQ 60) OR (Get_Settings.Payables_Expect_Volume_Aggregation_Period EQ 90)>
		<CFSET CHECKED="">
		<CFSET customperiod="">
	<CFELSE>
		<CFSET CHECKED=" CHECKED">
		<CFSET customperiod=Get_Settings.Payables_Expect_Volume_Aggregation_Period>
	</CFIF>
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Aggregation_Period" VALUE="1"<CFOUTPUT>#CHECKED#</CFOUTPUT>>
	Custom <INPUT TYPE="text" NAME="Payables_Expect_Volume_Aggregation_Period_Other" VALUE="<CFOUTPUT>#customperiod#</CFOUTPUT>" SIZE="6">days
	</TD>
</TR>
</TABLE>


<BR>
<HR WIDTH="600">
<BR>


<B>Offset the purchase period to lag billback aggreagation:</B>
<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
	
	&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Offset_Period" VALUE="0"<CFIF Get_Settings.Payables_Expect_Volume_Offset_Period EQ 0> CHECKED<CFELSE></CFIF>>
	No, match them

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Offset_Period" VALUE="30"<CFIF Get_Settings.Payables_Expect_Volume_Offset_Period EQ 30> CHECKED<CFELSE></CFIF>>
	30 Day lag

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Offset_Period" VALUE="60"<CFIF Get_Settings.Payables_Expect_Volume_Offset_Period EQ 60> CHECKED<CFELSE></CFIF>>
	60 Day lag

	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<!--- Decide if there is a custom period instead of the default 30,60,90 days --->
	<CFIF (Get_Settings.Payables_Expect_Volume_Offset_Period EQ 0) OR (Get_Settings.Payables_Expect_Volume_Offset_Period EQ 30) OR (Get_Settings.Payables_Expect_Volume_Offset_Period EQ 60)>
		<CFSET CHECKED="">
		<CFSET customperiod="">
	<CFELSE>
		<CFSET CHECKED=" CHECKED">
		<CFSET customperiod=Get_Settings.Payables_Expect_Volume_Offset_Period>
	</CFIF>
	<INPUT TYPE="radio" NAME="Payables_Expect_Volume_Offset_Period" VALUE="1"<CFOUTPUT>#CHECKED#</CFOUTPUT>>
	Custom <INPUT TYPE="text" NAME="Payables_Expect_Volume_Offset_Period_Other" VALUE="<CFOUTPUT>#customperiod#</CFOUTPUT>" SIZE="6">day lag
	</TD>
</TR>
</TABLE>


<BR>
<HR WIDTH="600">
<BR>


<B>
	Highlight billback volumes claimed as Deviations if they exceed Expected Volume by
	<INPUT TYPE="text" NAME="Payables_Expect_Volume_Highlight" VALUE="<CFOUTPUT>#Get_Settings.Payables_Expect_Volume_Highlight#</CFOUTPUT>" SIZE="6">
	%
</B>


<BR><BR>


	<INPUT TYPE="hidden" NAME="User_ID" VALUE="<CFOUTPUT>#request.AccessStructure.User_ID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Date_Updated" VALUE="<CFOUTPUT>#createodbcdatetime(now())#</CFOUTPUT>">



<INPUT TYPE="submit" VALUE="Save Preferences...">

</FORM>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



