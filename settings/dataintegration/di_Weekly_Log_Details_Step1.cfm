<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFPARAM NAME="FORM.Log" 	DEFAULT="">
<CFPARAM NAME="URL.Log" 	DEFAULT="#FORM.Log#">
<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
</CFIF>

<CFPARAM NAME="FORM.StartRow" 	DEFAULT="1">
<CFPARAM NAME="FORM.frompage" 	DEFAULT="1">
<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=12>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR>

<CFSET diThisPage="Weekly_Log_Details">
<CFINCLUDE template="diHeader.cfm">

<CFINCLUDE template="di_weekly_Log_System_Admin.cfm">


<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function selectAll(thisObj)
	{
		var chObjs = document.all.ID;
		var bCheck = thisObj.checked;
		var i;
		if(chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					chObjs[i].checked = bCheck;
				}
			}
			else
			{
				chObjs.checked = bCheck;
			}
		}
	}
	
	function deleteSelected()
	{
		window.event.returnValue = false;
		var formObj = document.Delete_Weekly_Log;
		if(!Any_Object_Checked(formObj.ID) && formObj.EXISTING_ID.value.length == 0)
		{
			alert("You haven't select any item.");
			return false;
		}
		if(window.confirm("Do you want to delete the selected items?"))
		{
			formObj.action = "di_Weekly_Log_Delete.cfm";
			formObj.submit();
		}
		return false;
	}
	function deleteAllRecords()
	{
		window.event.returnValue = false;
		if(window.confirm("Do you want to delete all the records?"))
		{
			document.Delete_Weekly_Log.Delete_All.value = 1;
			document.Delete_Weekly_Log.action = "di_Weekly_Log_Delete.cfm";
			document.Delete_Weekly_Log.submit();
		}
	}
	
</SCRIPT>

<CFINCLUDE template="Paging_Retain_Old_Values.cfm">

<CFIF Len(Trim(URL.Log)) GT 0>

	<CFSET logIndex = ListFindNoCase(logItems, URL.Log, ",")>
	<CFSET logItemName = URL.Log>
	<CFIF logIndex Gt 0>
		<CFSET weeklyLogTable = ListGetAt(originalDB, logIndex, ",")>
		<CFQUERY NAME="Q_Weekly_log_Entries" DATASOURCE="#application.datasource#">
			SELECT	*
			FROM	#weeklyLogTable#
			WHERE
					Weekly_Check >= #Weekly_log_Max_Count#
					AND
					Deleted = 0
		</CFQUERY>
		<CF_DI_CUST_SETTING_NAME 
			DI_keyword="#logItemName#" 
			ReturnField="Cust_Setting_Item_Name">
		<CFOUTPUT>
		<FORM NAME="Delete_Weekly_Log" ACTION="di_Weekly_Log_Details_Step1.cfm" METHOD="post">
		<TABLE CELLSPACING="0" CELLPADDING="4" BORDER="0" ALIGN="CENTER" WIDTH="80%">
		<CAPTION ALIGN="left">
		<B STYLE="font-size:14px;font-weight:bold;">
		Weekly Log - #Cust_Setting_Item_Name#
		</B>
		<CFIF Q_Weekly_log_Entries.RecordCount GT 0>
		<CFIF Current_User_Is_SysAdmin>
		&nbsp;&nbsp;&nbsp;
		<B STYLE="font-size:12px;"><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="javaScript: return deleteSelected();">delete selected</a><FONT COLOR="FF0000">]</FONT></B>
		&nbsp;&nbsp;&nbsp;
		<B STYLE="font-size:12px;"><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="javaScript: return deleteAllRecords();">delete all (#Q_Weekly_log_Entries.RecordCount#) records</a><FONT COLOR="FF0000">]</FONT></B>
		<CFELSE>
		&nbsp;&nbsp;&nbsp;
		<B STYLE="font-size:12px;color:silver;"><FONT COLOR="FF0000">[</FONT>delete selected<FONT COLOR="FF0000">]</FONT></B>
		&nbsp;&nbsp;&nbsp;
		<B STYLE="font-size:12px;color:silver;"><FONT COLOR="FF0000">[</FONT>delete all (#Q_Weekly_log_Entries.RecordCount#) records<FONT COLOR="FF0000">]</FONT></B>
		</CFIF>
		</CFIF>
		</CAPTION>
		<CFSET Field_Names = Evaluate("Original_DB_Weekly_Log_Fields_#LogItemName#")>
		<THEAD>
			<TR VALIGN="top" BGCOLOR="FFCE84">
				<TD>
				<CFIF Current_User_Is_SysAdmin>
				<INPUT TYPE="CHECKBOX" NAME="Check_All" VALUE="" onClick="javaScript: selectAll(this);">
				<CFELSE>
				<INPUT TYPE="CHECKBOX" DISABLED>
				</CFIF>
				&nbsp;
				</TD>
				<TD>&nbsp;</TD>
				<CFLOOP LIST="#Field_Names#" DELIMITERS="," INDEX="thisField">
					<CFIF IsDefined("Q_Weekly_log_Entries.#ListLast(thisField, ".")#")>
					<TD><B>#UCASE(ListLast(thisField, "."))#</B></TD>
					</CFIF>
				</CFLOOP>
			</TR>
		</THEAD>
		</CFOUTPUT>
		<CFOUTPUT QUERY="Q_Weekly_log_Entries" startrow="#StartRow#" maxrows="#MaxRows#">
			<CFSET IDField = Evaluate("Original_DB_ID_#logItemName#")>
			<CFSET IDFieldValue = Evaluate(IDField)>
			<A HREF="di_Weekly_Log_Details_Step2.cfm?Log=#LogItemName#&ID=#IDFieldValue#">
			<TR VALIGN="top" STYLE="cursor:pointer;"<cfif (Q_Weekly_log_Entries.currentRow mod 2) NEQ 1> BGCOLOR="ccffcc"</cfif>>
				<TD><CFIF Current_User_Is_SysAdmin><INPUT TYPE="CHECKBOX" NAME="ID" VALUE="#IDFieldValue#"<CFIF ListFindNoCase(FORM.EXISTING_ID, IDFieldValue, ",")> CHECKED<CFSET FORM.AlreadySelectedItems=ListAppend(FORM.AlreadySelectedItems, IDFieldValue, ",")></CFIF>><CFELSE><INPUT TYPE="CHECKBOX" DISABLED></CFIF>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<CFLOOP LIST="#Field_Names#" DELIMITERS="," INDEX="thisField">
					<CFIF IsDefined("#ListLast(thisField, ".")#")>
					<TD>
					<A HREF="di_Weekly_Log_Details_Step2.cfm?Log=#LogItemName#&ID=#IDFieldValue#">#Evaluate(ListLast(thisField, "."))#</A>
					</TD>
					</CFIF>
				</CFLOOP>
			</TR>
			</A>
		</CFOUTPUT>
		<TABLE>
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
		<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
		<INPUT TYPE="Hidden" NAME="Log" VALUE="#URL.Log#">
		<INPUT TYPE="Hidden" NAME="Delete_All" VALUE="0">
		<INPUT TYPE="Hidden" NAME="EXISTING_ID" VALUE="#FORM.EXISTING_ID#">
		<INPUT TYPE="Hidden" NAME="AlreadySelectedItems" VALUE="#FORM.AlreadySelectedItems#">
		</CFOUTPUT>
		</FORM>
	</CFIF>
</CFIF>

<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
	<TR>
	<TD>
	<CF_Next_Previous_For_Forms
	formname="Delete_Weekly_Log"
	query="Q_Weekly_log_Entries"
	maxpages="30"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
	addparams="">
	</TD>
	</TR>
	</TABLE>
<CFOUTPUT>
<!------<FORM ACTION="#CGI.SCRIPT_NAME#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="Log" VALUE="#URL.Log#">
<INPUT TYPE="Hidden" NAME="EXISTING_ID" VALUE="#FORM.EXISTING_ID#">
<INPUT TYPE="Hidden" NAME="AlreadySelectedItems" VALUE="#FORM.AlreadySelectedItems#">
</FORM>----->
</CFOUTPUT>
</BODY>
</HTML>
