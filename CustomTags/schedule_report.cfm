
<cfparam name="thisFormName" default="Myform">
<cfparam name="rStartDate" default="">
<cfparam name="rEndDate" default="">
<CFPARAM NAME="Attributes.rvStartDate" 	DEFAULT="">
<CFPARAM NAME="Attributes.rvEndDate" 			DEFAULT="">
<CFPARAM NAME="Attributes.rEmailAddress" 	DEFAULT="">
<CFPARAM NAME="Attributes.rName" 	DEFAULT="">
<CFPARAM NAME="Attributes.rInterval" 	DEFAULT="">
<CFPARAM NAME="Attributes.starttime" 	DEFAULT="">
<CFPARAM NAME="Attributes.actionpage" default="">
<cfparam name="Attributes.report_id" default="">
<cfparam name="Attributes.report_schedule_path" default="">



<cfset rIntervals="Once,Daily,Weekly,Monthly">
 
<cfinclude template="/reportwriter/performance_reports/report_include.cfm">

<cfif Attributes.starttime NEQ "" and Trim(Attributes.rInterval) NEQ "once">
<cfset rStartTime = Attributes.starttime>
<cfelse>
<CFSET rStartTime=getMilitaryTime(thisTime)>
</cfif>

<SCRIPT language="JavaScript" src="/validate.js"></SCRIPT> 
<SCRIPT language="JavaScript" src="/ReportWriter/rCommonFunctions.js"></SCRIPT> 
<SCRIPT language="JavaScript" src="/ReportWriter/invoiceCommon.js"></SCRIPT>
<cfoutput>

<cfform name="#thisFormName#" action="#Attributes.actionpage#" method="post">
	<TABLE ALIGN="center" BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="95%">
		<TR>
			<TD VALIGN="TOP">
				<span id="error_ReportName"></span>&nbsp;<strong>Report Name</strong><br>
				<INPUT TYPE="textbox" NAME="rName" ID="rName" VALUE="#Attributes.rName#" CLASS="input_textbox_input" MAXLENGTH="50">
			</TD>
			<TD VALIGN="TOP">
				
				<b>Start Date</b>&nbsp;<span id="error_Start_Date"></span> <CF_EASYDATE FORMNAME="#thisFormName#" FIELDNAME="rvStartDate" FORMAT="mm/dd/yyyy" DEFAULT="#attributes.rvStartDate#">
				<div id="divEndDate">
					<b>End Date</b> <span id="error_End_Date"></span>&nbsp;<CF_EASYDATE FORMNAME="#thisFormName#" FIELDNAME="rvEndDate" FORMAT="mm/dd/yyyy" DEFAULT="#attributes.rvEndDate#">
				</div>
			</TD>
			
			<TD VALIGN="TOP">
				<span id="error_Start_Time"></span> <strong>Time</strong>
				<cf_restrictedTime name="rStartTime" hhmmss="#rStartTime#" mdelta="5" Form="#thisFormName#" ImagesDir="/images/" width="70" showSeconds="false">	
			</TD>
			
			<TD VALIGN="TOP">
				<strong>Frequency</strong><br>
				<SELECT ID="rInterval" NAME="rInterval" onChange="javascript:intervalSelection(this);">
					<cfloop index="i" list="#rIntervals#" delimiters=",">
						<OPTION VALUE="#i#"<cfif i EQ Attributes.rInterval> SELECTED</cfif>>#i#</OPTION>
					</cfloop>
				</SELECT>
			</TD> 
		</TR>
		<TR>
			<TD COLSPAN="2">
				<font class="di_warning">
				Should select a Start Date greater than <b>#DateFormat(Now(),"mm/dd/yyyy")#</b>
				</font>
			</TD>
			<TD COLSPAN="2">
				<font class="di_warning">
				If you are selecting Start Date as #DateFormat(Now(),"mm/dd/yyyy")#, select a Start Time greater than <CF_clock time="#thisTime#" color="red" name="reportTime" firstTime="#TimeFormat(Now(),"hh:mm:ss tt")#">
				</font>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2" ALIGN="LEFT" VALIGN="TOP">
				<span id="error_Email_Address"></span> <strong>Email Address</strong>
				<br><font class="di_warning">Separate with ( ; ) if more then one Email Address</font><br>
				<TEXTAREA COLS="60" ROWS="5" NAME="rEmailAddress">#Attributes.rEmailAddress#</TEXTAREA>
			</TD>
			<TD COLSPAN="2" ALIGN="LEFT" VALIGN="TOP">
				<!-----------------------------------------------------------------------
				Get Email Address from DB
				--------------------------------------------------------------------------->
				<CFQUERY NAME="q_getEmail" datasource="#application.datasource#">
				Select	User_Email
				From	_Users
				Where	User_Email<>'' AND Deleted=0
				Order By User_Email
				</CFQUERY>
				<!-----------------------------------------------------------------------
				End - Get Email Address from DB
				--------------------------------------------------------------------------->
				<b>Email Address lookup</b>
				<BR><BR>
				<CF_Email_Address_Lookup 
					Destination_Form_Name="all"
					Destination_Field_Name="rEmailAddress"
					width="200"
					size="5"
					Alert="true">
			</TD>
		</TR>
		<TR>
		
			<TD COLSPAN="4" ALIGN="CENTER">
				<cfif isDefined("Attributes.report_id")>
					<cfset bCaption="edit report">
					<INPUT TYPE="HIDDEN" ID="report_id" NAME="report_id" VALUE="#Attributes.report_id#">
				<cfelse>
					<cfset bCaption="save report">			
				</cfif>
	<input type="hidden" name="report_schedule_path" value="#Attributes.report_schedule_path#">
				<br>
				<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"Schedule Report"
					BUTTON_ACTION	=	"javascript:savethisReport(document.#thisFormName#);"
					BUTTON_TYPE		=	"link"
					BUTTON_WIDTH	=	"150"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">
			</TD> 
		</TR>
	</TABLE></cfform>
</cfoutput>

