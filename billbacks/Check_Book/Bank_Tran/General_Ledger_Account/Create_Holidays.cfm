<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET URL.PageTitle="Billback: Manage Holidays">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="0">
<cfset useLakebaseForGet_Holidays = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("holidays")>
<cfif useLakebaseForGet_Holidays>
	<cftry>
		<cfset Get_Holidays = application.oLakebase.toQuery(
			application.oLakebase.selectRows("holidays", {
				"order" = "holiday_date.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Holidays = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Holidays>
<CFQUERY NAME="Get_Holidays" datasource="#application.datasource#">
	Select		*
	From		Holidays
	Order by	Holiday_Date
</CFQUERY>
</cfif>

<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1*
	From		Holidays
	<CFIF URL.RID NEQ 0>
	Where		Holiday_ID = '#URL.RID#'
	</CFIF>
	Order by	Updated_Date Desc
</CFQUERY>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
	SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
	FROM _Users
	WHERE User_ID = '#Get_LastUpdated_Details.Updated_UserId#'
</CFQUERY>
</CFIF>

<CFIF IsDefined("getUserName")>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.Updated_Date, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.Updated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
</CFIF>

<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="320" CLASS="Maintable">
					<TR>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Date</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Holidays">
					
					<TR>
						<TD><A HREF="create_holidays.cfm?RID=#Holiday_ID#">#Holiday_Desc#</A></TD>
						<TD  NOWRAP>#DateFormat(Holiday_Date,"mm/dd/yyyy")#</TD>
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
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record<BR>
				
			</TD>
			<TD VALIGN="top">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				


<CFPARAM NAME="Get_Item.Holiday_Desc" DEFAULT="">
<CFPARAM NAME="Get_Item.Holiday_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		TOP 1*
	From		Holidays
	Where		Holiday_ID	like	'#URL.RID#'
</CFQUERY>



<cfset useLakebaseForCheck_For_Existance = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("holidays")>
<cfif useLakebaseForCheck_For_Existance>
	<cftry>
		<cfset Check_For_Existance = application.oLakebase.toQuery(
			application.oLakebase.selectRows("holidays", {
				"order" = "holiday_date.asc",
				"select" = "holiday_date,holiday_desc"
			}), "holiday_date,holiday_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_For_Existance = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_For_Existance>
<CFQUERY NAME="Check_For_Existance" DATASOURCE="#Application.Datasource#">
	SELECT Holiday_Date,Holiday_Desc FROM Holidays ORDER BY Holiday_Date
</CFQUERY>
</cfif>

<CFOUTPUT>
<script type = "text/javascript">
var H_Date = new Array(#Check_For_Existance.recordcount#)
var H_Desc = new Array(#Check_For_Existance.recordcount#)
</script>
</CFOUTPUT>

<CFOUTPUT query = "Check_For_Existance">
<script type = "text/javascript">	
	H_Date[#currentrow#-1]="#DateFormat(Holiday_Date,"mm/dd/yyyy")#"
	H_Desc[#currentrow#-1]="#Holiday_Desc#"
</script>
</CFOUTPUT>



<SCRIPT language="JavaScript">
function alert_and_delete()
{
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}
			
}	
function validate()
{
	var x=document.MyForm;
	var submit_ok=1;
	
	if (x.Holiday_date.value == "")
	{
		alert("Please enter a date in the Date Box.");
		x.Holiday_date.focus();
		submit_ok=0;
	}
	else
	{	
		if(x.Holiday_ID.value == "")
		{
			var count = <cfoutput>#Check_For_Existance.recordcount#</cfoutput>
			for(i=0;i<count;i++)
			{	
				if (x.Holiday_date.value == H_Date[i])
				{
					
					alert("Date " + H_Date[i] + " with description as " + H_Desc[i] + " already exist in holiday list")
					x.Holiday_date.focus()
					submit_ok=0;
				}
				
			}
		}
	}
	if (x.Holiday_Desc.value == "")
	{
		alert ("Please enter some description about the holiday.");
		x.Holiday_Desc.focus();
		submit_ok=0;
	}

	if (submit_ok==1)
	{
		document.MyForm.submit();
	}
}
</SCRIPT>

			<FORM ACTION="save_Holidays.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Date:</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Holiday_date" FORMAT="mm/dd/yyyy" DEFAULT="#Get_Item.Holiday_date#">														
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Description:</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="57" NAME="Holiday_Desc" VALUE="#Get_Item.Holiday_Desc#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Holiday_ID" VALUE="#Get_Item.Holiday_ID#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the number of projects that have this status: If there is at least 1 project that is active and has this status, then I will not allow the user to delete this status --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

					
					
					
						<!--- Is this record deleted? --->
						<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive 
						</CFOUTPUT>						

						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: validate()"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							
						<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>														
						</TD>
					</TR>
				</TABLE>
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="create_Holidays.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
