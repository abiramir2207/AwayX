<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Data Integration</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFPARAM NAME="URL.Log" 	DEFAULT="">
<CFPARAM NAME="URL.ID" 	DEFAULT="">

<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
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

<BR>
<CFSET diThisPage="Weekly_Log_Details">
<CFINCLUDE template="diHeader.cfm">

<CFINCLUDE template="di_weekly_Log_System_Admin.cfm">

<SCRIPT LANGUAGE="JavaScript">
	function deleteSelected()
	{
		window.event.returnValue = false;
		if(window.confirm("Do you want to delete this record?"))
		{
			document.Delete_Weekly_Log.submit();
		}
	}
</SCRIPT>
<CFIF Len(Trim(URL.Log)) GT 0 AND Len(Trim(URL.ID)) GT 0>
	<CFSET logIndex = ListFindNoCase(logItems, URL.Log, ",")>
	<CFSET logItemName = URL.Log>
	<CFIF logIndex Gt 0>
		<CFSET IDField = Evaluate("Original_DB_ID_#logItemName#")>
			
		<CFSET weeklyLogTable = ListGetAt(originalDB, logIndex, ",")>
		<CFQUERY NAME="Q_Weekly_log_Entry_Detail" DATASOURCE="#application.datasource#">
			SELECT	*
			FROM	#weeklyLogTable#
			WHERE
					#IDField# = '#URL.ID#'					
		</CFQUERY>
		<CFQUERY NAME="Table_Schema_Info" datasource="#application.datasource#">
			SELECT lower(column_name) as column_name, data_type
		    FROM information_schema.columns 
		    WHERE table_name='#weeklyLogTable#'
		</CFQUERY>
		
		<CFSET restricted_Field_Names_List = "deleted,active_code,log_check,day_check,weekly_check,created_date">
		<CFLOOP QUERY="Table_Schema_Info">
			<CFIF Table_Schema_Info.data_type EQ "uniqueidentifier">
				<CFSET restricted_Field_Names_List = ListAppend(restricted_Field_Names_List, Table_Schema_Info.column_name, ",")>
			</CFIF>
		</CFLOOP>
		
		<CF_DI_CUST_SETTING_NAME 
			DI_keyword="#logItemName#" 
			ReturnField="Cust_Setting_Item_Name">
		<CFIF Q_Weekly_log_Entry_Detail.recordCount GT 0>
		<CFOUTPUT>
			<FORM NAME="Delete_Weekly_Log" ACTION="di_Weekly_Log_Delete.cfm" METHOD="post">
			<INPUT TYPE="Hidden" NAME="Log" VALUE="#URL.Log#">
			<INPUT TYPE="Hidden" NAME="ID" VALUE="#URL.ID#">
			<TABLE CELLSPACING="0" CELLPADDING="4" BORDER="0" ALIGN="CENTER" WIDTH="80%">
			<CAPTION STYLE="border-bottom:2px orange solid;" ALIGN="left">
			<B STYLE="font-size:14px;font-weight:bold;">
			Weekly Log - #Cust_Setting_Item_Name#
			</B>
			<CFIF Current_User_Is_SysAdmin>
			&nbsp;&nbsp;&nbsp;
			<B STYLE="font-size:12px;"><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="javaScript: return deleteSelected();">delete this record</a><FONT COLOR="FF0000">]</FONT></B>
			<CFELSE>
			&nbsp;&nbsp;&nbsp;
			<B STYLE="font-size:12px;color:silver;"><FONT COLOR="FF0000">[</FONT>delete this record<FONT COLOR="FF0000">]</FONT></B>
			</CFIF>
			</CAPTION>
				<!------<TR BGCOLOR="FFCE84">
					<TD><B>Field</B></TD>
					<TD><B>Value</B></TD>		
				</TR>----->
				<CFSET FieldsList = Q_Weekly_log_Entry_Detail.columnList>
				<CFSET IDIndex = ListFindNoCase(FieldsList, IDField, ",")>
				<CFIF IDIndex GT 0>
					<CFSET FieldsList = ListDeleteAt(FieldsList, IDIndex, ",")>
				</CFIF>
				
				<CFLOOP LIST="#FieldsList#" DELIMITERS="," INDEX="FieldName">
				<CFIF NOT ListFindNoCase(restricted_Field_Names_List, FieldName, ",")>
				<TR>
					<TD><B>#UCASE(FieldName)#</B></TD>
					<TD>#Evaluate("Q_Weekly_log_Entry_Detail.#FieldName#")#</TD>
				</TR>
				</CFIF>
				</CFLOOP>				
			</TABLE>
			</FORM>
		</CFOUTPUT>
		<CFELSE>
			No Entry Found
		</CFIF>
		
	</CFIF>
</CFIF>


</BODY>
</HTML>
