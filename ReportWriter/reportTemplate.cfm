<!--------------------------------reportTemplate.cfm------------------------------------------>

<cfoutput>
<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/Reports/savereport.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
<BR><BR>
<TABLE ALIGN="center" BORDER="0" CELLPADDING="0" CELLSPACING="1" WIDTH="95%">
	<TR>
		<TD VALIGN="TOP">
		<span id="error_ReportName"></span>&nbsp;<strong>Report Name</strong><br>
		<INPUT TYPE="textbox" NAME="rName" ID="rName" VALUE="#rName#" CLASS="input_textbox_input" MAXLENGTH="50">
		</TD>
		<TD VALIGN="TOP">
		<cfif NOT isDate(rStartDate)>
			<cfset rStartDate="">
		</cfif>
		<cfif NOT isDate(rEndDate)>
			<cfset rEndDate="">
		</cfif>
		<b>Start Date</b>&nbsp;<span id="error_Start_Date"></span> <CF_EASYDATE FORMNAME="#thisFormName#" FIELDNAME="rStartDate" FORMAT="mm/dd/yyyy" DEFAULT="#rStartDate#">
		<div id="divEndDate">
		<b>End Date</b> <span id="error_End_Date"></span>&nbsp;<CF_EASYDATE FORMNAME="#thisFormName#" FIELDNAME="rEndDate" FORMAT="mm/dd/yyyy" DEFAULT="#rEndDate#">
		</div>
		</TD>
		<TD VALIGN="TOP">
		<span id="error_Start_Time"></span> <strong>Time</strong>
		<cf_restrictedTime name="rStartTime" hhmmss="#rStartTime#" mdelta="5" Form="#thisFormName#" ImagesDir="/images/" width="70" showSeconds="false">	
		</TD>
		<TD VALIGN="TOP">
		<strong>Interval</strong><br>
		<SELECT ID="rInterval" NAME="rInterval" onChange="javascript:intervalSelection(this);">
		<cfloop index="i" list="#rIntervals#" delimiters=",">
			<OPTION VALUE="#i#"<cfif i EQ rInterval> SELECTED</cfif>>#i#</OPTION>
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
		If you are selecting Start Date as #DateFormat(Now(),"mm/dd/yyyy")#, select a Start Time greater than <CF_clock time="#thisTime#" color="red" name="reportTime" firstTime="#TimeFormat(thisTimeFull,"hh:mm:ss tt")#">
		</font>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2" ALIGN="LEFT" VALIGN="TOP">
		<span id="error_Email_Address"></span> <strong>Email Address</strong>
		<br><font class="di_warning">Separate with ( ; ) if more then one Email Address</font><br>
		<TEXTAREA COLS="60" ROWS="5" NAME="rEmailAddress">#rEmailAddress#</TEXTAREA>
		</TD>
		<TD COLSPAN="2" ALIGN="LEFT" VALIGN="TOP">
		<!-----------------------------------------------------------------------
		Get Email Address from DB
		--------------------------------------------------------------------------->
		<cfset useLakebaseForq_getEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForq_getEmail>
	<cftry>
		<cfset q_getEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_email" = "neq.",
				"deleted" = "eq.0",
				"order" = "user_email.asc",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_getEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_getEmail>
<CFQUERY NAME="q_getEmail" datasource="#application.datasource#">
		Select	User_Email
		From	_Users
		Where	User_Email<>'' AND Deleted=0
		Order By User_Email
		</CFQUERY>
</cfif>
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
		<!------<SELECT ID="sEmailIds" SIZE="5" NAME="sEmailIds" onChange="javascript:addToEmailAddress(this,document.#thisFormName#);">
		<cfloop query="q_getEmail">
		<OPTION VALUE="#User_Email#">#User_Email#</OPTION>
		</cfloop>
		</SELECT>----->
		<INPUT TYPE="hidden" ID="reportType" NAME="reportType" VALUE="#repType#">
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="4" ALIGN="CENTER">
		<cfif isDefined("rID")>
			<cfset bCaption="edit report">
			<INPUT TYPE="HIDDEN" ID="rID" NAME="rID" VALUE="#rID#">
		<cfelse>
			<cfset bCaption="save report">			
		</cfif>
		<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"#bCaption#"
			BUTTON_ACTION	=	"javascript:saveReport(document.#thisFormName#,\'#repType#\');"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
		</TD>
	</TR>
</TABLE>
</cfoutput>