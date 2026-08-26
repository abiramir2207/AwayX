<cfparam name="form.i_agree_status" default="0">
<CFSET URL.PageTitle="USDA NOI: RULES">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>

<!--- get NOI enabled or disabled --->
<cfset useLakebaseForGet_NOI_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGet_NOI_Status>
	<cftry>
		<cfset Get_NOI_Status = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "usdanoi_enabled"
			}), "usdanoi_enabled"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_NOI_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_NOI_Status>
<CFQUERY NAME="Get_NOI_Status" datasource="#application.datasource#">
	SELECT usdanoi_enabled
	FROM _Application_Settings
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="0">
<cfset useLakebaseForGet_EDPS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds")>
<cfif useLakebaseForGet_EDPS>
	<cftry>
		<cfset Get_EDPS = application.oLakebase.toQuery(
			application.oLakebase.selectRows("usda_noi_epds", {
				"order" = "name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_EDPS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_EDPS>
<CFQUERY NAME="Get_EDPS" datasource="#application.datasource#">
	Select		*
	From		usda_noi_epds
	Order by	Name
</CFQUERY>
</cfif>
<cfset useLakebaseForGet_LastUpdated_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("global_last_edited_by")>
<cfif useLakebaseForGet_LastUpdated_Details>
	<cftry>
		<cfset Get_LastUpdated_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("global_last_edited_by", {
				"global_last_edited_by_id" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_LastUpdated_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_LastUpdated_Details>
<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		*
	From		Global_Last_Edited_By
	WHERE		Global_Last_Edited_By_ID = 1
</CFQUERY>
</cfif>

<CFIF len(trim(Get_LastUpdated_Details.User_ID)) NEQ 0>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_LastUpdated_Details.User_ID#",
				"select" = "name_last as user_fullname"
			}), "name_last as user_fullname"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT _Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM _Users
		WHERE User_ID = '#Get_LastUpdated_Details.User_ID#'
	</CFQUERY>
</cfif>
</CFIF>

<!--- establish USDA I agrre and time --->
<cfset useLakebaseForgetCurrentSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetCurrentSettings>
	<cftry>
		<cfset getCurrentSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "usdanoi_i_agree_enabled,usdanoi_summary_time,usdanoi_summary_email"
			}), "usdanoi_i_agree_enabled,usdanoi_summary_time,usdanoi_summary_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentSettings>
<cfquery name="getCurrentSettings" datasource="#application.datasource#">
	SELECT USDANOI_I_Agree_Enabled, USDANOI_Summary_Time, USDANOI_Summary_Email
	FROM general_Settings
</cfquery>
</cfif>
<cfset  form.i_agree_status = getCurrentSettings.USDANOI_I_Agree_Enabled>

<cfset sumHour = Hour(getCurrentSettings.USDANOI_Summary_Time)>
<cfset sumMinute = Minute(getCurrentSettings.USDANOI_Summary_Time)>

<cfif sumHour LT 12>
	<cfset sumAmPm = "AM">
	
	<cfif sumHour EQ 0>
		<cfset sumHour = 12>
	</cfif>
	
<cfelse>
	<cfset sumHour = sumHour - 12>
	<cfset sumAmPm = "PM">
</cfif>

<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<script>
	function usdanoisavestatus() {
		document.all.usdanoi_enabled.value = usdanoi_enabled_chkbx.checked
		document.MyForm.submit();
	}
	
	function selectProducts() {
		NewWindow("type_code_to_usdanoi_epds_assignment.cfm?usda_noi_epds_id=" + document.all.usda_noi_epds_id.value, "typecodegroup", 800, 600, "yes", "yes")
	}
</script>
<TABLE>
	<TR>
	<td width="20%"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
	<CFIF len(trim(Get_LastUpdated_Details.User_ID)) NEQ 0>
	<TD>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
	<FONT SIZE="2"><B>Last modified on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.DateTimeStamp, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.DateTimeStamp, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
	</TD>
	</CFIF>
	</TR>
</TABLE>

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD align="center" colspan="5" valign="bottom">
				<span style="color:navy;font-weight:bold;">USDA NOI ACTIVATED <input type="Checkbox" name="usdanoi_enabled_chkbx" <cfif Get_NOI_Status.usdanoi_enabled EQ 1> checked</cfif> onclick="usdanoisavestatus()"></span>
				<HR COLOR="Blue" SIZE="1" width="40%">
			</TD>
		</TR>
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Name</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_EDPS">
					<TR>
						<TD NOWRAP><A HREF="index.cfm?RID=#usda_noi_epds_id#">#Get_EDPS.Name#</A></TD>
						<TD NOWRAP>

								<CFIF Get_EDPS.Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>
			</TD>
			<TD VALIGN="top">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				

<CFPARAM NAME="PM_Status_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.PM_Status_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.PM_Status_Deleted" DEFAULT="0">

<cfset useLakebaseForGet_Item = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds")>
<cfif useLakebaseForGet_Item>
	<cftry>
		<cfset Get_Item = application.oLakebase.toQuery(
			application.oLakebase.selectRows("usda_noi_epds", {
				"usda_noi_epds_id" = "eq.#URL.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Item = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Item>
<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		usda_noi_epds
	Where		usda_noi_epds_id	=	'#URL.RID#'
</CFQUERY>
</cfif>

<SCRIPT language="JavaScript">
function alert_and_delete()
{

	if(document.all.usda_noi_epds_id.value.length != 0){
		var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
		if (confirmdelete == true)
		{
			document.all.DeleteRecord.value=1;
			document.MyForm.submit();
		}
	}
	else
	{
		alert("You can not delete a record until it has been saved.")
	}
			
}	
</SCRIPT>
			<FORM ACTION="create_epds.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Name</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="55" NAME="Name" VALUE="#Get_Item.Name#" MAXLENGTH="50">
							</CFOUTPUT>
						</TD>
					</TR>

					<!--- YIELD --->

					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Yield</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="10" NAME="Yield" VALUE="#Get_Item.Yield#" MAXLENGTH="10" onkeyup="clenseText(this, '0213456789')">
							</CFOUTPUT>
						</TD>
					</TR>

					<!--- USDA Raw Price --->

					<TR>
						<TD VALIGN="top" ALIGN="right"><B>USDA Raw Price</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="10" NAME="Raw_Price" VALUE="#trim(numberformat(Get_Item.Raw_Price, '______.____'))#" MAXLENGTH="10" onkeyup="clenseText(this, '.0213456789'); limitXdecimalplaces(4, this);">
							</CFOUTPUT>
						</TD>
					</TR>					

					<!--- USDA Unit Of Measure --->

					<TR>
						<TD VALIGN="top" ALIGN="right"><B>USDA Unit of Measure</B></TD>
						<TD VALIGN="top">
							<select name="uom">
								<option value="1" <cfif Get_Item.UOM EQ 1> SELECTED</cfif>>Case</option>
								<option value="2" <cfif Get_Item.UOM EQ 2> SELECTED</cfif>>Net Pound</option>
								<option value="rm" <cfif Get_Item.UOM EQ "rm"> SELECTED</cfif>>Raw Materials</option>
							</select>
						</TD>
					</TR>
					
					<!--- Notes --->
					
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Notes</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<TEXTAREA NAME = "Notes" ROWS="5" COLS="57">#Get_Item.Notes#</TEXTAREA> 
							</CFOUTPUT>
						</TD>
					</TR>
	
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: selectProducts()"><B>select products</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
													
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: document.MyForm.submit()"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							
						<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							<P></P>
						</TD>
						
						
					</TR>
				</TABLE>

				<cfoutput>
					
					<input type="hidden" name="usdanoi_enabled" value="">
					<input type="Hidden" name="usda_noi_epds_id" value="#Get_Item.usda_noi_epds_id#">
				</cfoutput>

			</FORM>
				
			</TD>
		</TR>
	</TABLE>
	
	<table>
		<tr>
			<td></td>
		</tr>
	</table>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="index.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
<BR><BR>
<CFSET URL.PageTitle="USDA NOI: I Agree & Reporting">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
	<script>

var ErrorCount = 0;
function confirmCompletion()
{

	var ErrorCount = 0;
	var ValidEmail1 = replaceInvalidEmailCharsAndValidate(document.all.Recipient_Email_Address)
	var sBroker_Address = document.all.Recipient_Email_Address.value;
	
	if(sBroker_Address.length == 0)
	{
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Broker_Address);
	}
	else if(ValidEmail1!=true)
	{
		ErrorCount++;
	 	queueMessage("Invalid email Address <font size=2><b>" + ValidEmail1 + "</b></font> ! Please re-enter.", document.all.error_Broker_Address);
	}
	else
	{
		clearQueue(document.all.error_Broker_Address);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		ReportForm.submit()
		
	}
	else 
	{
		showMessageWindow()
	}	
}
</script>
<CF_MessageWindow>	

<form action="iagree_action.cfm" method="post" name="ReportForm" id="ReportForm">
<table border="0" cellspacing="2" cellpadding="2">
	<tr>
		<td align="right"><b>Enable "I Agree" Feature :</b></td>
		<td><input name="i_agree_status" type="Radio" value="1" <cfif form.i_agree_status EQ 1> checked</cfif>><b style="color:Green;">YES</b><input name="i_agree_status" type="Radio" value="0" <cfif form.i_agree_status EQ 0> checked</cfif>><b style="color:Red;">NO</b></td>
	</tr>
	
	
	<tr>
		<td align="right"><b>Send Daily Summary At :</b></td>
		<td>
			<cfoutput>
			<select name="sum_email_time_hour">
				<cfloop index="i" from="1" to="12" step="1">
					<option value="#i#" <cfif i EQ sumHour> SELECTED</cfif>>#i#</option>
				</cfloop>
			</select>
		
			<select name="sum_email_time_minute">
				<cfloop index="i" from="0" to="59" step="1">
					<cfif len(i) EQ 1>
						<cfset i = "0" & i>
					</cfif>
					<option value="#i#" <cfif sumMinute EQ i> SELECTED</cfif>>#i#</option>
				</cfloop>
			</select>
			
			<select name="sum_email_time_ampm">
					<option value="AM" <cfif sumAmPm EQ "AM"> SELECTED</cfif>>AM</option>
					<option value="PM" <cfif sumAmPm EQ "PM"> SELECTED</cfif>>PM</option>
			</select>	
			</cfoutput>		
		</td>
	</tr>

	<tr>
		<td align="right" valign="top"><b>Send Daily Summary To :</b><span id="error_Broker_Address"></span></td>
		<td>
		<table>
			<tr>
				<td><TEXTAREA NAME="Recipient_Email_Address" COLS="75" ROWS="5" STYLE="WIDTH:300px;" ONKEYPRESS="<!--- javaSCript: return Valid_Key_On_Email_Object(); --->"><cfoutput>#getCurrentSettings.USDANOI_Summary_Email#</cfoutput></TEXTAREA>
</td>
				<td>
					<CF_Email_Address_Lookup 
							Destination_Form_Name="ReportForm"
							Destination_Field_Name="Recipient_Email_Address"
							width="200"
							size="5"
							Alert="true">				
				</td>
			</tr>
		</table>		
		</td>
	</tr>
	<tr>
		<td></td>
		<td align="left"><input type="Button" value="save" style="width: 50px;" onclick="confirmCompletion()"></td>
	</tr>
</table>
</form>





