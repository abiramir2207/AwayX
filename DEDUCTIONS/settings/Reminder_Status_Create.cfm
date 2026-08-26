<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfparam name="blnSubmit" default="0">

<cfif blnSubmit IS 1>

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseFordelete_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminder_type")>
	<cfif useLakebaseFordelete_Data>
		<cftry>
			<cfset application.oLakebase.deleteRows("dd_reminder_type", { "dd_reminder_type_id" = "eq.#Form.DD_Reminder_Type_ID#" })>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordelete_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordelete_Data>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM DD_Reminder_Type  
		WHERE		DD_Reminder_Type_ID			=	'#Form.DD_Reminder_Type_ID#'
	</CFQUERY>
	</cfif>

<cfelseif Form.DD_Reminder_Type_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminder_type")>
	<cfif useLakebaseForSave_Data>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_reminder_type", {
				"dd_type_name" = DD_Type_Name,
				"dd_type_of_reminder_id" = 1,
				"date_created" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"date_updated" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"updated_by" = request.AccessStructure.User_ID,
				"deleted" = Deleted
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSave_Data = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSave_Data>
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		DD_Reminder_Type
						(DD_Type_Name, DD_Type_Of_Reminder_ID, Date_Created, Date_Updated, Updated_By, Deleted)
		Values			('#DD_Type_Name#', 1, #now()#, #now()#, '#request.AccessStructure.User_ID#', #Deleted#)
	</CFQUERY>
	</cfif>
<CFELSE>
<!--- Update the record --->
	<cfset useLakebaseForSave_Data2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminder_type")>
	<cfif useLakebaseForSave_Data2>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_reminder_type",
				{ "dd_reminder_type_id" = "eq.#Form.DD_Reminder_Type_ID#" },
				{
					"dd_type_name" = Form.DD_Type_Name,
					"date_updated" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"updated_by" = request.AccessStructure.User_ID,
					"deleted" = Form.Deleted
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSave_Data2 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSave_Data2>
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		DD_Reminder_Type
		SET 		DD_Type_Name 		=	'#Form.DD_Type_Name#',
					Date_Updated		=	#Now()#,
					Updated_By			=	'#request.AccessStructure.User_ID#',
					Deleted				=	#Form.Deleted#
					
		WHERE		DD_Reminder_Type_ID			=	'#Form.DD_Reminder_Type_ID#'
	</CFQUERY>
	</cfif>

</CFIF>
</cfif>

<CFSET URL.PageTitle="Deductions: Reminder Type Management">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		DD_Reminder_Type.*, DD_Type_Of_Reminder.DD_Type_Of_Reminder_Desc
	From		DD_Reminder_Type
	LEFT JOIN 	DD_Type_Of_Reminder
	ON			DD_Type_Of_Reminder.DD_Type_Of_Reminder_ID = DD_Reminder_Type.DD_Type_Of_Reminder_ID
	Order by	DD_Type_Name
</CFQUERY>


<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Existing Reminder Types</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Type</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Data">
					<TR>
						<TD NOWRAP><A HREF="Reminder_Status_Create.cfm?RID=#DD_Reminder_Type_ID#">#DD_Type_Name#</A></TD>
						<TD NOWRAP>#DD_Type_Of_Reminder_Desc#</TD>
						<TD NOWRAP>
								<CFIF Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>

				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
				
			</TD>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">
			
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFPARAM NAME="DD_Type_Name" DEFAULT="">
<CFPARAM NAME="DD_Reminder_Type_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		DD_Reminder_Type.*, DD_Type_Of_Reminder.DD_Type_Of_Reminder_Desc
	From		DD_Reminder_Type
	LEFT JOIN 	DD_Type_Of_Reminder
	ON			DD_Type_Of_Reminder.DD_Type_Of_Reminder_ID = DD_Reminder_Type.DD_Type_Of_Reminder_ID
	Where		DD_Reminder_Type_ID	like	'#URL.RID#'	
</CFQUERY>

<SCRIPT language="JavaScript">
function alert_and_delete()
{
 
	var confirmdelete = confirm("Click OK to permanently delete this record. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}
}	
function Validate()
{
	if (document.all.DD_Type_Name.value == "")
	{
		alert("Please enter some description.");
		document.all.DD_Type_Name.focus();
	}
	else
	{
		document.MyForm.submit()
	}
}
</SCRIPT>			




			<FORM ACTION="reminder_status_create.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="DD_Type_Name" VALUE="#Get_Item.DD_Type_Name#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="DD_Reminder_Type_ID" VALUE="#Get_Item.DD_Reminder_Type_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Type</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>#Get_Item.DD_Type_Of_Reminder_Desc#</CFOUTPUT>
							<font color="red"> (Inactivate option is unavailable)</font>
						</TD>
					</TR>					
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

						<!--- Is this record deleted? --->
						<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>
						
						<!------ Do not let them inactivate (set deleted=1) in the following cases ----->
						<cfset InactiveDisableString = "" />
						<cfif Get_Item.DD_Type_Of_Reminder_ID NEQ 1>
							<cfset InactiveDisableString = " DISABLED" />							
						</cfif>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted" #active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted" #inactive# #InactiveDisableString#>Inactive 
						</CFOUTPUT>

						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: Validate()"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							
						<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>							
						</TD>
					</TR>
				</TABLE>
				<input type="hidden" name="blnSubmit" value="1">
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="Reminder_Status_Create.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

