<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND Get_Profile_Settings.Fund_Setting_Access EQ 1>


<CFSET URL.PageTitle="Payables: Fund Settings">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>


<!--- 
<CFQUERY NAME="GetARSetting" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE Deleted = 0
</CFQUERY>
 --->
<CFSET VarYear3Back = YEAR(DateAdd("yyyy",-3,now()))>
<CFSET VarYear2Back = YEAR(DateAdd("yyyy",-2,now()))>
<CFSET VarYear1Back	= YEAR(DateAdd("yyyy",-1,now()))>
<CFSET VarYearNow = YEAR(now())>
<CFSET VarYear1Plus = YEAR(DateAdd("yyyy",1,now()))>
<CFSET VarYear2Plus	= YEAR(DateAdd("yyyy",2,now()))>
<CFSET VarYear3Plus = YEAR(DateAdd("yyyy",3,now()))>

<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Fund_Setting WHERE AR_From_Fiscal_Year IN (#VarYear3Back#,#VarYear2Back#,#VarYear1Back#,#VarYearNow#,#VarYear1Plus#,#VarYear2Plus#,#VarYear3Plus#) AND Deleted = 0
</CFQUERY>

<CFSET VarYear3BackStatus = 1>
<CFSET VarYear2BackStatus = 1>
<CFSET VarYear1BackStatus = 1>
<CFSET VarYearNowStatus = 1>	
<CFSET VarYear1PlusStatus = 1>
<CFSET VarYear2PlusStatus = 1>
<CFSET VarYear3PlusStatus = 1>

<CFLOOP QUERY="GetStatus">
	<CFIF AR_From_Fiscal_Year EQ VarYear3Back>
		<CFSET VarYear3BackStatus = AR_Status>
	<CFELSEIF AR_From_Fiscal_Year EQ VarYear2Back>
		<CFSET VarYear2BackStatus = AR_Status>
	<CFELSEIF AR_From_Fiscal_Year EQ VarYear1Back>
		<CFSET VarYear1BackStatus = AR_Status>
	<CFELSEIF AR_From_Fiscal_Year EQ VarYearNow>
		<CFSET VarYearNowStatus = AR_Status>
	<CFELSEIF AR_From_Fiscal_Year EQ VarYear1Plus>
		<CFSET VarYear1PlusStatus = AR_Status>
	<CFELSEIF AR_From_Fiscal_Year EQ VarYear2Plus>
		<CFSET VarYear2PlusStatus = AR_Status>
	<CFELSEIF AR_From_Fiscal_Year EQ VarYear3Plus>
		<CFSET VarYear3PlusStatus = AR_Status>
	</CFIF>
</CFLOOP>

<CFOUTPUT>
<FORM NAME="YearSwitch" ACTION ="Fund_Management_Action.cfm" METHOD="POST">
	<INPUT TYPE="Hidden" NAME="Year3Back" VALUE="#VarYear3Back#"> 
	<INPUT TYPE="Hidden" NAME="Year3BackSwitchStatus" VALUE="#VarYear3BackStatus#">
	<INPUT TYPE="Hidden" NAME="Year2Back" VALUE="#VarYear2Back#"> 
	<INPUT TYPE="Hidden" NAME="Year2BackSwitchStatus" VALUE="#VarYear2BackStatus#">
	<INPUT TYPE="Hidden" NAME="Year1Back" VALUE="#VarYear1Back#">
	<INPUT TYPE="Hidden" NAME="Year1BackSwitchStatus" VALUE="#VarYear1BackStatus#">
	<INPUT TYPE="Hidden" NAME="YearNow" VALUE="#VarYearNow#">
	<INPUT TYPE="Hidden" NAME="YearNowSwitchStatus" VALUE="#VarYearNowStatus#">
	<INPUT TYPE="Hidden" NAME="Year1Plus" VALUE="#VarYear1Plus#">
	<INPUT TYPE="Hidden" NAME="Year1PlusSwitchStatus" VALUE="#VarYear1PlusStatus#">
	<INPUT TYPE="Hidden" NAME="Year2Plus" VALUE="#VarYear2Plus#">
	<INPUT TYPE="Hidden" NAME="Year2PlusSwitchStatus" VALUE="#VarYear2PlusStatus#">
	<INPUT TYPE="Hidden" NAME="Year3Plus" VALUE="#VarYear3Plus#">
	<INPUT TYPE="Hidden" NAME="Year3PlusSwitchStatus" VALUE="#VarYear3PlusStatus#">
	
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" STYLE="Border-bottom: 1px solid Navy; Border-Top: 1px solid Navy; Border-Left: 1px solid Navy; Border-Right: 1px solid Navy;">
		<TR>
			<TD><B><FONT COLOR="Navy" SIZE="2">Manage AR based on fiscal year</FONT></B></TD>
		</TR>
		<TR>
			<TD>
				<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
					<TR>
						<TD>
							<CFIF VarYear3BackStatus EQ 1>
								<B>#VarYear3Back#</B>
							<CFELSE>
								#VarYear3Back#
							</CFIF>	
						</TD>
						<TD>
							<CFIF VarYear3BackStatus EQ 1>
								<INPUT TYPE="button" NAME="Year3BackSwitch" <CFIF VarYear3BackStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(-3)">
							<CFELSE>
								off
							</CFIF>
						</TD>							
					</TR>
					<TR>
						<TD>
							<CFIF VarYear2BackStatus EQ 1>
								<B>#VarYear2Back#</B>
							<CFELSE>
								#VarYear2Back#
							</CFIF>
						</TD>
						<TD>
							<CFIF VarYear2BackStatus EQ 1>
								<INPUT TYPE="button" NAME="Year2BackSwitch" <CFIF VarYear2BackStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(-2)">
							<CFELSE>
								off
							</CFIF>
						</TD>
					</TR>
					<TR>
						<TD>
							<CFIF VarYear1BackStatus EQ 1>
								<B>#VarYear1Back#</B>
							<CFELSE>
								#VarYear1Back#
							</CFIF>
						</TD>
						<TD>
							<CFIF VarYear1BackStatus EQ 1>
								<INPUT TYPE="button" NAME="Year1BackSwitch" <CFIF VarYear1BackStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(-1)">
							<CFELSE>
								off
							</CFIF>	
						</TD>
					</TR>
					<TR>
						<TD>
							<CFIF VarYearNowStatus EQ 1>
								<B>#VarYearNow#</B>
							<CFELSE>
								#VarYearNow#
							</CFIF>
						</TD>
						<TD>
							<CFIF VarYearNowStatus EQ 1>
								<INPUT TYPE="button" NAME="YearNowSwitch" <CFIF VarYearNowStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(0)">
							<CFELSE>
								off
							</CFIF>
						</TD>
					</TR>
					<TR>
						<TD>
							<CFIF VarYear1PlusStatus EQ 1>
								<B>#VarYear1Plus#</B>
							<CFELSE>
								#VarYear1Plus#
							</CFIF>
						</TD>
						<TD>
							<CFIF VarYear1PlusStatus EQ 1>
								<INPUT TYPE="button" NAME="Year1PlusSwitch" <CFIF VarYear1PlusStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(1)">
							<CFELSE>
								off
							</CFIF>	
						</TD>
					</TR>
					<TR>
						<TD>
							<CFIF VarYear2PlusStatus EQ 1>
								<B>#VarYear2Plus#</B>
							<CFELSE>
								#VarYear2Plus#
							</CFIF>
						</TD>
						<TD>
							<CFIF VarYear2PlusStatus EQ 1>
								<INPUT TYPE="button" NAME="Year2PlusSwitch" <CFIF VarYear2PlusStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(2)">
							<CFELSE>
								off
							</CFIF>	
						</TD>
					</TR>
					<TR>
						<TD>
							<CFIF VarYear3PlusStatus EQ 1>
								<B>#VarYear3Plus#</B>
							<CFELSE>
								#VarYear3Plus#
							</CFIF>
						</TD>
						<TD>
							<CFIF VarYear3PlusStatus EQ 1>
								<INPUT TYPE="button" NAME="Year3PlusSwitch" <CFIF VarYear3PlusStatus EQ 1>VALUE="ON"<CFELSE>VALUE="OFF"</CFIF> ONCLICK="Javascript: switchOnOff(3)">
							<CFELSE>
								off
							</CFIF>	
						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>	
		<TR>
			<TD ALIGN="Center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"save data"
					button_action	=	"validate()"
					button_type		=	"javascript_link"
					button_width	=	"70"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"		>
			</TD>
		</TR>	
	</TABLE>
	<BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="500">
		<TR>
			<TD VALIGN="top"><B><FONT COLOR="red">**</FONT></B>&nbsp;&nbsp;</TD>
			<TD><B><FONT COLOR="red">Click on the link  'save data', so that the program templates will display the AR's that are turned ON. Turning OFF a fiscal year will turn off access to the funds from that fiscal year within the program wizard, all existing program templates created and associated with that fiscal year's AR's and will accelerate all outstanding payment requests to expired.</FONT></B></TD>
		</TR>
	</TABLE>
</FORM>
</CFOUTPUT>

<SCRIPT language="JavaScript">
function switchOnOff(year)
{	
	if (year == -3)
	{
		if (document.all.Year3BackSwitchStatus.value == 1)
		{
			document.all.Year3BackSwitchStatus.value = 0;
			document.all.Year3BackSwitch.value = "Off";			
		}
		else
		{
			document.all.Year3BackSwitchStatus.value = 1;
			document.all.Year3BackSwitch.value = "On";			
		}
	}
	else if (year == -2)
	{
		if (document.all.Year2BackSwitchStatus.value == 1)
		{
			document.all.Year2BackSwitchStatus.value = 0;
			document.all.Year2BackSwitch.value = "Off";	
		}
		else
		{
			document.all.Year2BackSwitchStatus.value = 1;
			document.all.Year2BackSwitch.value = "On";
		}
	}
	else if (year == -1)
	{
		if (document.all.Year1BackSwitchStatus.value == 1)
		{
			document.all.Year1BackSwitchStatus.value = 0;
			document.all.Year1BackSwitch.value = "Off";
		}
		else
		{
			document.all.Year1BackSwitchStatus.value = 1;
			document.all.Year1BackSwitch.value = "On";
		}
	}
	else if (year == 0)
	{
		if (document.all.YearNowSwitchStatus.value == 1)
		{
			document.all.YearNowSwitchStatus.value = 0;
			document.all.YearNowSwitch.value = "Off";
		}
		else
		{
			document.all.YearNowSwitchStatus.value = 1;
			document.all.YearNowSwitch.value = "On";
		}
	}
	else if (year == 1)
	{
		if (document.all.Year1PlusSwitchStatus.value == 1)
		{
			document.all.Year1PlusSwitchStatus.value = 0;
			document.all.Year1PlusSwitch.value = "Off";			
		}
		else
		{
			document.all.Year1PlusSwitchStatus.value = 1;
			document.all.Year1PlusSwitch.value = "On";
		}
	}	
	else if (year == 2)
	{
		if (document.all.Year2PlusSwitchStatus.value == 1)
		{
			document.all.Year2PlusSwitchStatus.value = 0;
			document.all.Year2PlusSwitch.value = "Off";			
		}
		else
		{
			document.all.Year2PlusSwitchStatus.value = 1;
			document.all.Year2PlusSwitch.value = "On";
		}
	}	
	else if (year == 3)
	{
		if (document.all.Year3PlusSwitchStatus.value == 1)
		{
			document.all.Year3PlusSwitchStatus.value = 0;
			document.all.Year3PlusSwitch.value = "Off";			
		}
		else
		{
			document.all.Year3PlusSwitchStatus.value = 1;
			document.all.Year3PlusSwitch.value = "On";
		}
	}	
}

function validate()
{
	var fundRecordCount = "<CFOUTPUT>#GetStatus.RecordCount#</CFOUTPUT>";
	var Year_3 ="<CFOUTPUT>#VarYear3Back#</CFOUTPUT>";
	var Year_2 = "<CFOUTPUT>#VarYear2Back#</CFOUTPUT>";
	var Year_1 = "<CFOUTPUT>#VarYear1Back#</CFOUTPUT>";
	var Year0 = "<CFOUTPUT>#VarYearNow#</CFOUTPUT>";
	var Year1 = "<CFOUTPUT>#VarYear1Plus#</CFOUTPUT>";
	var Year2 = "<CFOUTPUT>#VarYear2Plus#</CFOUTPUT>";
	var Year3 = "<CFOUTPUT>#VarYear3Plus#</CFOUTPUT>";
	
	var OnToOff = "";	
	if (document.all.Year3BackSwitchStatus.value == 0 && document.all.Year3BackSwitch)
	{
		OnToOff = Year_3 +";";
	}
	if (document.all.Year2BackSwitchStatus.value == 0 && document.all.Year2BackSwitch)
	{
		OnToOff = OnToOff + " " + Year_2 +";";		
	}
	if (document.all.Year1BackSwitchStatus.value == 0 && document.all.Year1BackSwitch)
	{
		OnToOff = OnToOff + " " + Year_1 +";";
	}
	if (document.all.YearNowSwitchStatus.value == 0 && document.all.YearNowSwitch)
	{
		OnToOff = OnToOff +  " " + Year0 + ";";
	}
	if (document.all.Year1PlusSwitchStatus.value == 0 && document.all.Year1PlusSwitch)
	{
		OnToOff = OnToOff + " " + Year1 + ";";
	}
	
	if (document.all.Year2PlusSwitchStatus.value == 0 && document.all.Year2PlusSwitch)
	{
		OnToOff = OnToOff + " " + Year2 + ";";
	}
	if (document.all.Year3PlusSwitchStatus.value == 0 && document.all.Year3PlusSwitch)
	{
		OnToOff = OnToOff + " " + Year3 + ";";
	}
	if (OnToOff != "")
	{// 3. Will deleteaccelerate all outstanding payment requests to expired.
		if(confirm("Turning OFF a fiscal year will: \n 1. Turn off access to the funds from that fiscal year within the program wizard. \n 2. Turn off access to all existing program templates created and associated with that fiscal year's AR's.  \n 3. Will delete all outstanding payment requests with that fiscal year's AR's. \n\nPress OK to turn off fiscal year(s): "+ OnToOff))
		{
			document.all.YearSwitch.submit()
		}	
	}
	else if (fundRecordCount  != 7)
	{
		document.all.YearSwitch.submit()
	}
}
</SCRIPT>


<CFELSE>
	<SCRIPT language="JavaScript">
	window.parent.location.href = "/settings/index2.cfm";
	</SCRIPT>
</CFIF>
</body>
</html>
