<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<STYLE>
.input_di_textbox_input
{
	border: 1px solid rgb(192,192,192);
	font: 12px Arial, Arial;
	font-weight: bold;
	color: Navy;
	background-color: rgb(255, 255, 255);
	text-align: left;
	width:200px;
}
</STYLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" onLoad="javascript:selectDate(document.dataIntegrationForm.enterDate);">
<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="dataIntegration_Include.cfm">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="integration_Type" DEFAULT="">
<CFPARAM NAME="integration_Option" DEFAULT="">

<CFPARAM NAME="week_day1" DEFAULT="">
<CFPARAM NAME="week_day2" DEFAULT="">
<CFPARAM NAME="week_day3" DEFAULT="">
<CFPARAM NAME="week_day4" DEFAULT="">
<CFPARAM NAME="week_day5" DEFAULT="">
<CFPARAM NAME="week_day6" DEFAULT="">
<CFPARAM NAME="week_day7" DEFAULT="">

<CFPARAM NAME="start_date" DEFAULT="">
<CFPARAM NAME="end_date" DEFAULT="">
<CFPARAM NAME="start_time" DEFAULT="">
<CFPARAM NAME="start_time_hour" DEFAULT="">
<CFPARAM NAME="start_time_min" DEFAULT="">
<CFPARAM NAME="start_time_sec" DEFAULT="">
<CFPARAM NAME="start_time_AMPM" DEFAULT="">
<CFPARAM NAME="dataIntegration_File_Types" DEFAULT="">
<CFPARAM NAME="dataIntegration_File_Names" DEFAULT="">
<CFPARAM NAME="dataIntegration_File_ID" DEFAULT="">

<CFSET Brokers=false>
<CFSET Distributors=false>
<CFSET Products=false>
<CFSET diUserName="">
<CFSET diEditDate="">
<CFSET dbBasicInfoExist = false>
<CFSET diLogExist = false>

<CFSET noAction=false>
<CFIF isDefined("action")>
	<CFIF action EQ "showError">		
		<CFSET integration_Type=Form.integration_Type>
		<CFSET integration_Option=Form.integration_Option>
		
		<CFIF Form.week_day1 EQ "1">
			<CFSET week_day1=true>
		</CFIF>
		<CFIF Form.week_day2 EQ "2">
			<CFSET week_day2=true>
		</CFIF>
		<CFIF Form.week_day3 EQ "4">
			<CFSET week_day3=true>
		</CFIF>
		<CFIF Form.week_day4 EQ "8">
			<CFSET week_day4=true>
		</CFIF>
		<CFIF Form.week_day5 EQ "16">
			<CFSET week_day5=true>
		</CFIF>
		<CFIF Form.week_day6 EQ "32">
			<CFSET week_day6=true>
		</CFIF>
		<CFIF Form.week_day7 EQ "64">
			<CFSET week_day7=true>
		</CFIF>
		
		<CFSET start_date=Form.start_date>
		<CFSET end_date=Form.end_date>
		
		<CFSET start_time=Form.start_time>
		<CFSET start_time_hour=Form.start_time_hour>
		<CFSET start_time_min=Form.start_time_min>
		<CFSET start_time_sec=Form.start_time_sec>
		<CFSET start_time_AMPM=Form.start_time_AMPM>
		
		<CFSET dataIntegration_File_Types=Form.dataIntegration_File_Types>
		<CFSET dataIntegration_File_Names=Form.dataIntegration_File_Names>
		<CFSET dataIntegration_File_ID=Form.dataIntegration_File_ID>
		
		
	<CFELSE>		
		<!----
		Show the data from database
		--->
		<CFSET noAction=true>
	</CFIF>
<CFELSE>	
	<CFSET noAction=true>
	<!----
		Show the data from database
	--->
</CFIF>

<CFIF noAction EQ true>
	<!----
	<CFINCLUDE template="dataIntegration_Include.cfm">
	---->
	<CFIF ISDefined("URL.diType")>
		<CFIF ListFindNoCase("Brokers,Distributors,Products",URL.diType,",")>
			<CFSET integration_Type=URL.diType>
		<CFELSE>
			<CFSET integration_Type="Brokers">
		</CFIF>
	<CFELSE>
		<CFSET integration_Type="Brokers">
	</CFIF>
	<!-----ISDefined("URL.diType")------->

	<CFQUERY NAME="q_Data_Integration_Read" datasource="#application.datasource#">
		Select 		di.*,u.Name_First + ' ' + u.Name_Last as uName 
		From 		Data_Integration di,_users u
		where 		u.user_id = di.User_ID
						and
					di.Data_Integration_ID in
			(Select 	max(Data_Integration_ID)
			From 		Data_Integration 
			where 		Integration_Type='#integration_Type#')
	</CFQUERY>
		
	<CFIF q_Data_Integration_Read.recordCount GT 0>
		<CFSET integration_Option=q_Data_Integration_Read.integration_Option>
		<CFSET diUserName=q_Data_Integration_Read.uName>
		<CFSET diEditDate=q_Data_Integration_Read.Created_Date>
				
		<CFIF integration_Option EQ "8">				
			<CFSCRIPT>
				week_day1=false;
				week_day2=false;
				week_day3=false;
				week_day4=false;
				week_day5=false;
				week_day6=false;
				week_day7=false;
				daysList = q_Data_Integration_Read.Days;
			</CFSCRIPT>
			<cfloop index="lIndex" list="#daysList#" delimiters=",">
				<cfswitch expression="#lIndex#">
					<cfcase value="1">
						<cfset week_day1=true>
					</cfcase>
					<cfcase value="2">
						<cfset week_day2=true>
					</cfcase>
					<cfcase value="4">
						<cfset week_day3=true>
					</cfcase>
					<cfcase value="8">
						<cfset week_day4=true>
					</cfcase>
					<cfcase value="16">
						<cfset week_day5=true>
					</cfcase>
					<cfcase value="32">
						<cfset week_day6=true>
					</cfcase>
					<cfcase value="64">
						<cfset week_day7=true>
					</cfcase>
				</cfswitch>
			</cfloop>
		</CFIF>
		<!--------integration_Option EQ "8"---------->

		<CFSET tStart_date=q_Data_Integration_Read.start_date>
		<CFSET tEnd_date=q_Data_Integration_Read.end_date>
		
		<CFSET start_date=Left(tStart_date,4) & "/" & Mid(tStart_date,5,2) & "/" & Mid(tStart_date,7,2)>
		<CFSET end_date=Left(tEnd_date,4) & "/" & Mid(tEnd_date,5,2) & "/" & Mid(tEnd_date,7,2)>
		
		<CFIF NOT IsDate(start_date)>
			<CFSET start_date="">
		</CFIF>
		<CFIF NOT IsDate(end_date)>
			<CFSET end_date="">
		</CFIF>

		<CFSET tempStart_time=q_Data_Integration_Read.start_time>
		<CFSET start_time="#Left(tempStart_time,2)#:#Mid(tempStart_time,3,2)#:#Mid(tempStart_time,5,2)#">

		<CFSET start_time_hour=Val(Mid(q_Data_Integration_Read.start_time, 1, 2))>
		<CFSET start_time_min=Val(Mid(q_Data_Integration_Read.start_time, 3, 2))>
		<CFSET start_time_sec=Val(Mid(q_Data_Integration_Read.start_time, 5, 2))>
		<CFIF start_time_hour GT 12>
			<CFSET start_time_hour=start_time_hour-12>
			<CFSET start_time_AMPM="pm">
		<CFELSE>
				<CFSET start_time_AMPM="am">
		</CFIF>
		<!------start_time_hour GT 12-------->
			
	</CFIF>
	<!-------q_Data_Integration_Read.recordCount GT 0----->
	<CFQUERY NAME="q_dataIntegration_Files" datasource="#application.datasource#">
		Select 		*
		From		dataIntegration_Files
		Where		dataIntegration_Category='<cfoutput>#Integration_Type#</cfoutput>'
	</CFQUERY>

	<cfloop query="q_dataIntegration_Files">
		<cfset dataIntegration_File_Names=ListAppend(dataIntegration_File_Names, q_dataIntegration_Files.dataIntegration_File_Name ,",")>
		<cfset dataIntegration_File_Types=ListAppend(dataIntegration_File_Types, q_dataIntegration_Files.dataIntegration_File_Type ,",")>
		<cfset Variables.dataIntegration_File_ID=ListAppend(Variables.dataIntegration_File_ID, q_dataIntegration_Files.DataIntegration_File_ID ,",")>
	</cfloop>
	<!----query_name.columnList---->
</CFIF>


<!-----------------------------------------
Get DataIntegration Basic Information from database
------------------------------------------>
<CFQUERY NAME="q_Data_Integration_Read" datasource="#application.datasource#">
		Select 		di.Dataint_setting_ID
		From 		DataInt_Settings di
</CFQUERY>

<CFIF q_Data_Integration_Read.recordCount GT 0>
	<CFSET dbBasicInfoExist = true>
</CFIF>
	
<!-----------------------------------------
End - Get DataIntegration Basic Information from database
------------------------------------------>

<!--------------------------------------
Check whether there is entry for brokers, distributors and products
----------------------------------->
<cfset useLakebaseForq_Data_Integration_Exists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration")>
<cfif useLakebaseForq_Data_Integration_Exists>
	<cftry>
		<cfset q_Data_Integration_Exists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration", {
				"select" = "integration_type"
			}), "integration_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_Data_Integration_Exists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_Data_Integration_Exists>
<CFQUERY NAME="q_Data_Integration_Exists" datasource="#application.datasource#">
		select distinct Integration_Type
		From Data_Integration
	</CFQUERY>
</cfif>
	
	<cfloop query="q_Data_Integration_Exists">
		<cfswitch expression="#Integration_Type#">
				<cfcase value="Brokers">
					<CFSET Brokers=true>
				</cfcase>
				<cfcase value="Distributors">
					<CFSET Distributors=true>
				</cfcase>
				<cfcase value="Products">
					<CFSET Products=true>
				</cfcase>
		</cfswitch>
		<!-----
		<cfif q_Data_Integration_Exists.Integration_Type EQ variables.integration_Type>
			<cfset alreadyExist=true>
		</cfif>
		------->		
</cfloop>
<!----------------------------------------
End - Check whether there is entry for brokers, distributors and products
----------------------------------------------->

<!--------------------------------------
Get DILogExist from database
--------------------------------------->

<CFOUTPUT>
<CFQUERY NAME="q_DILog_Exists" datasource="#application.datasource#">
select (select count(*) from #ListChangeDelims(logTables, " ) + ( select count(*) from ",",")#) as cnt
</CFQUERY>
</CFOUTPUT>
<CFIF q_DILog_Exists.recordCount GT 0>
	<CFIF q_DILog_Exists.cnt>
		<CFSET diLogExist=true>
	</CFIF>
</CFIF>
<!--------------------------------------
End Get DILogExist from database
--------------------------------------->

<SCRIPT LANGUAGE="Javascript">
<cfoutput>
thisDate = new Date(#Year(Now())#,#Month(Now())#-1,#Day(Now())#);
thisTime = "#thisTime#";

var TimeGLimit = "#TimeGLimit#";
var TimeSLimit = "#TimeSLimit#";

var TimeSelectLimit = "#TimeSelectLimit#";
var DateSelectLimit = "#DateSelectLimit#";

</cfoutput>
</SCRIPT>

<SCRIPT language="JavaScript" SRC="../../validate.js"></SCRIPT>
<!-----<SCRIPT language="JavaScript" SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>------->
<SCRIPT language="JavaScript" SRC="commonFunctions.js"></SCRIPT>
<SCRIPT language="JavaScript" SRC="isDataClear.js"></SCRIPT>


<CFSET diThisPage="#diPage#">
<CFINCLUDE template="diHeader.cfm">

<CFIF isDefined("sErr")>
	<BR>
	<TABLE BGCOLOR="Red" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Update failed. Some of the fields are either missing or invalid.
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
	</TABLE>
<CFELSE>
	<BR>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		<CFIF Len(diUserName) GT 0>
		The Data Integration settings for #integration_Type# were last updated on #diEditDate# by #diUserName#
		<CFELSE>
		No Data Integration settings for #integration_Type# found
		</CFIF>
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
	</TABLE>
</CFIF>



<cfform action="#diActionpage#" method="POST" name="dataIntegrationForm">
<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="80%" BGCOLOR="cccccc">
<TR BGCOLOR="Whitesmoke">
	<TD ALIGN="left" VALIGN="top">
	<span id="error_Integration_Option"></span>&nbsp;<b>Integration Option</b>
	</TD>
	<TD ALIGN="left" VALIGN="top" WIDTH="60%">
		<input type="hidden" name="integration_Type" value="<cfoutput>#integration_Type#</cfoutput>">
		&nbsp;&nbsp;<input type="Radio" name="integration_Option" value="4" onClick="javascript:optionIs(4,'tr_week_days');" <CFIF integration_Option EQ "4">CHECKED</CFIF> >Daily
		&nbsp;&nbsp;<input type="Radio" name="integration_Option" value="8" onClick="javascript:optionIs(8,'tr_week_days');" <CFIF integration_Option EQ "8">CHECKED</CFIF> >Weekly
	</TD>	
</TR>
<TR BGCOLOR="Whitesmoke" ID="tr_week_days">
	<TD ALIGN="left" VALIGN="top">
	<span id="error_Week_Days"></span>&nbsp;<b>Select Weekdays</b>
	</TD>
	<TD ALIGN="left" VALIGN="top" WIDTH="60%">
	<div id="div_week_days" style="margin-left:10px">
	<table border="0" width="90%">
	<tr>
	<td>
	<input type="Checkbox" name="week_day1" value="1" <CFIF week_day1 EQ true>CHECKED</CFIF> >Sunday
	</td>
	<td>
	<input type="Checkbox" name="week_day2" value="2" <CFIF week_day2 EQ true>CHECKED</CFIF> >Monday
	</td>
	<td>
	<input type="Checkbox" name="week_day3" value="4" <CFIF week_day3 EQ true>CHECKED</CFIF> >Tuesday
	</td>
	</tr>
	<tr>
	<td>
	<input type="Checkbox" name="week_day4" value="8" <CFIF week_day4 EQ true>CHECKED</CFIF> >Wednesday
	</td>	
	<td>
	<input type="Checkbox" name="week_day5" value="16" <CFIF week_day5 EQ true>CHECKED</CFIF> >Thursday
	</td>
	<td>
	<input type="Checkbox" name="week_day6" value="32" <CFIF week_day6 EQ true>CHECKED</CFIF> >Friday
	</td>	
	</tr>
	<tr>
	<td>
	<input type="Checkbox" name="week_day7" value="64" <CFIF week_day7 EQ true>CHECKED</CFIF> >Saturday
	</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</tr>
	</table>
	</div>
	</TD>
</TR>
<TR BGCOLOR="Whitesmoke">
	<TD ALIGN="left" VALIGN="top" COLSPAN="2">
	<font class="di_warning">If you don't specify a Start Date and an End Date, the process will be scheduled from today onwards.</font>
	<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" BGCOLOR="Whitesmoke">
	<TD>	
	<INPUT TYPE="checkbox" ID="enterDate" NAME="enterDate" VALUE="yes" onClick="javascript: selectDate(this);"<cfif end_date NEQ "9999/12/31"> CHECKED</cfif>><b>Specify Date</b>
	</TD>
	<TD>
		<DIV ID="div_start_end">
		<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" BGCOLOR="Whitesmoke">
		<TR>
		<TD>
		<span id="error_Start_End_Date"></span>&nbsp;<span id="error_Start_Date"></span>&nbsp;<b>Start date:</b> <CF_EASYDATE FORMNAME="dataIntegrationForm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="#start_date#">
		</TD>
		<TD>
		<span id="error_End_Date"></span>&nbsp;<b>End date:</b> <CF_EASYDATE FORMNAME="dataIntegrationForm" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="#end_date#">
		</TD>
		</TR>
		</TABLE>	
		</DIV>
	</TD>	
	</TABLE>	
	</TD>
</TR>
<TR BGCOLOR="Whitesmoke">
	<TD ALIGN="left" VALIGN="top" COLSPAN="2">
	<TABLE ALIGN="center" BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" BGCOLOR="Whitesmoke">
	<TD>&nbsp;
	
	</TD>
	<TD>
	<NOBR><span id="error_Start_Time"></span>&nbsp;<b>Start Time: (HHMMSS AM/PM)</b></NOBR><br>
	
	<!---<cfinput type="Text" name="start_time" size="10" required="No" onBlur="javascript: checkTime(this);">--->
	<!---<input type="hidden" name="start_time">--->
	<cf_restrictedTime name="start_time" hhmmss="#start_time#" minInterval="#TimeGLimit#" maxInterval="#TimeSLimit#" mdelta="5" Form="dataIntegrationForm" ImagesDir="/images/" width="70" showSeconds="false">	
	</TD>
	<TD>
	<CFOUTPUT>
	<CFSET showTimeSelectLimit="#TimeSelectLimit#">
	<font class="di_warning">
	Always specify time in the interval <b>#getAMPMTime(TimeGLimit,"")#</b> to <b>#getAMPMTime(TimeSLimit,"")#</b><br>
	<!------
	 #TimeSelectLimit# #thisTime# 
	 <cfset aaTimeSelectLimit=ListToArray(shiftTimeFrame(TimeSLimit,TimeSelectLimit),":")>
	 <cfset aathisTime=ListToArray(shiftTimeFrame(TimeSLimit,thisTime),":")>
	 <cfif checkTimelessThan(aaTimeSelectLimit,aathisTime)>
	 --->
	 <CFIF Val(Left(TimeSelectLimit,2)) LT Val(Left(thisTime,2))>
	 You'll have to select a date greater than #DateSelectLimit# to select any avaiable time slot.
	 <CFELSE>
	If you specify Start Date as #DateSelectLimit#, you <span>should</span> select a time greater than or equal to <b><cfif not selctTimeisThisTime>#getAMPMTime(showTimeSelectLimit,"")#<cfelse><CF_clock time="#showTimeSelectLimit#" color="red" name="diTime" firstTime="#getAMPMTime(showTimeSelectLimit,"")#"></cfif></b>
	 </CFIF>
	 </font>
	</CFOUTPUT>
	</TD>
	</TABLE>
	</TD>
</TR>
<!----
<CFIF q_dataIntegration_Files.RecordCount GT 0>
---->
<CFIF ListLen(dataIntegration_File_Types) GT 0>
<TR BGCOLOR="Whitesmoke">
	<TD ALIGN="left" VALIGN="top" COLSPAN="2">
	<TABLE CELLSPACING="3" CELLPADDING="0" BORDER="0" ALIGN="CENTER" WIDTH="100%">
		<TR>
		<TD ALIGN="CENTER" COLSPAN="100%">
		<span id="error_FileNames"></span>&nbsp;<B>Filenames</B>
		</TD>
		</TR>
		<TR>
			<TD CLASS="labelStyle"></TD>
			<TD ROWSPAN="100%" BGCOLOR="Navy" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
			<TD></TD>
			<!----<CFIF q_dataIntegration_Files.RecordCount GT 1>--->
			<CFIF ListLen(dataIntegration_File_Types) GT 1>
			<TD CLASS="labelStyle"></TD>
			<TD ROWSPAN="100%" BGCOLOR="Navy"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
			<TD></TD>
			</CFIF>
		</TR>
		<cfoutput>
	<!-----<cfloop query="q_dataIntegration_Files">---->
		<cfset iIndex = 1>
		<cfloop index="lIndex" list="#dataIntegration_File_Types#" delimiters=",">
		<CFSET newRow=iIndex MOD 2>
		<CFIF newRow EQ 1>
		</TR>
		<TR>
		</CFIF>
			<TD> <b><CFIF lIndex EQ "Broker">
					#application.returned_customer_setting.broker_label_singular#
				 <CFELSEIF lIndex EQ "Region">
					#application.returned_customer_setting.region_label_singular#
				<CFELSEIF lIndex EQ "Line_Of_Business">
					#application.returned_customer_setting.lob_label_singular#							
				<CFELSEIF lIndex EQ "Zone">
					#application.returned_customer_setting.zone_label_singular# 
				<CFELSEIF lIndex EQ "Buying_Groups">
					#application.returned_customer_setting.buying_group_label_plural#
				<CFELSEIF lIndex EQ "Family">
					#application.returned_customer_setting.family_name_label_singular#
				<CFELSEIF lIndex EQ "Type_Group">
					#application.returned_customer_setting.type_group_label_singular#
				<CFELSEIF lIndex EQ "Type">
					#application.returned_customer_setting.type_code_label_singular#
				<CFELSEIF lIndex EQ "Q_Brand">
					#application.returned_customer_setting.q_brand_label_singular#
				<CFELSE>
					#lIndex#
				</CFIF> <!--- <b>#lIndex#</b> --->  </b></TD>
			<TD>			
			<INPUT TYPE="hidden" ID="dataIntegration_File_Types" NAME="dataIntegration_File_Types" VALUE="#lIndex#">
			<INPUT TYPE="hidden" ID="dataIntegration_File_ID" NAME="dataIntegration_File_ID" VALUE="#ListGetAt(dataIntegration_File_ID, iIndex,",")#">
			<INPUT TYPE="text" MAXLENGTH="100" ID="dataIntegration_File_Names" NAME="dataIntegration_File_Names" CLASS="input_di_textbox_input" VALUE="#ListGetAt(dataIntegration_File_Names, iIndex,",")#">
			</TD>
			<cfset iIndex = iIndex+1>
		</TR></cfloop>
		</cfoutput>
		
	</TABLE>
	</TD>
</TR>
</CFIF>
<TR BGCOLOR="Whitesmoke">
	<TD COLSPAN="2" ALIGN="center">
	<DIV ALIGN="center">
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"Save Settings"
			BUTTON_ACTION	=	"javascript:isDataClear();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</DIV>
	</TD>
</TR>

</TABLE>
</cfform>
<script language="javascript">
if(dataIntegrationForm.integration_Option[1].checked)
{
	optionIs(8,'tr_week_days');
}
else
{
	optionIs(4,'tr_week_days');
}
disableDiv('div_start_end',!dataIntegrationForm.enterDate.checked,false);
</script>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_MessageWindow>
<CFIF isDefined("sErr")>
	<SCRIPT LANGUAGE="JavaScript">
		showError();		
	</SCRIPT>
</CFIF>
</BODY>
</HTML>
