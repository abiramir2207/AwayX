<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfparam name="blnSubmit" default="0">
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFPARAM NAME="form.PR_Operator_Category" 	DEFAULT="0">
<CFPARAM NAME="form.PR_Operator_Priority" 	DEFAULT="0">
<CFPARAM NAME="form.PR_Date_Range"			DEFAULT="0">
<CFPARAM NAME="form.Mass_Prog_Change"			DEFAULT="0">
<CFPARAM NAME="form.Allow_Change_On_Revision"		DEFAULT="0">
<CFPARAM NAME="form.List_Features"			DEFAULT="0"><!--- 70947 --->

<cfif blnSubmit IS 1>

	<!--- Delete record --->
	<CFIF FORM.DeleteRecord EQ 1>

		<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
			DELETE FROM Program_Perf_Req
			WHERE		Program_Perf_Req_ID			=	'#Form.Program_Perf_Req_ID#'

			DELETE FROM Program_Perf_Req_Labels
			WHERE		Program_Perf_Req_ID			=	'#Form.Program_Perf_Req_ID#'
		</CFQUERY>

	<cfelseif Form.Program_Perf_Req_ID EQ "">

		<!--- Insert the record --->
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#" result="SaveData">
			INSERT INTO Program_Perf_Req
				(Requirement_Name,PR_Operator_Category,PR_Operator_Priority,PR_Date_Range,Mass_Prog_Change,Date_Created,Date_Updated,Updated_By,Deleted,Allow_Change_On_Revision,List_Features)
			VALUES
				('#Requirement_Name#',#form.PR_Operator_Category#,#form.PR_Operator_Priority#,#form.PR_Date_Range#,#form.Mass_Prog_Change#,#now()#,#now()#,'#request.AccessStructure.User_ID#',#Deleted#,#Form.Allow_Change_On_Revision#,#form.List_Features#)
		</CFQUERY>
		<cfif form.List_Features>
			<!--- Insert Labels Record --->
			<CFQUERY NAME="Save_Labels_Data" datasource="#application.datasource#">
				<cfloop from="1" to="#form.List_Features#" index="A">
				INSERT INTO Program_Perf_Req_Labels(Program_Perf_Req_ID,Perf_Req_Label,Perf_Req_Label_ID)
				VALUES (#SaveData["GENERATEDKEY"]#,'#Evaluate("form.List_Feature_Label_#A#")#',#A#)
				</cfloop>
			</CFQUERY>
		</cfif>
	<CFELSE>

		<!--- Update the record --->
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			UPDATE 		Program_Perf_Req
			SET 	 Requirement_Name 		= '#Form.Requirement_Name#'
						,PR_Operator_Category 	= #form.PR_Operator_Category#
						,PR_Operator_Priority 	= #form.PR_Operator_Priority#
						,PR_Date_Range			= #form.PR_Date_Range#
						,Mass_Prog_Change	= #form.Mass_Prog_Change#
						,Allow_Change_On_Revision	= #form.Allow_Change_On_Revision#
						,Date_Updated			= #Now()#
						,Updated_By				= '#request.AccessStructure.User_ID#'
						,Deleted					= #Form.Deleted#
						,List_Features = #form.List_Features#
			WHERE		Program_Perf_Req_ID		= '#Form.Program_Perf_Req_ID#'
		</CFQUERY>

		<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
			DELETE FROM Program_Perf_Req_Labels
			WHERE		Program_Perf_Req_ID			=	'#Form.Program_Perf_Req_ID#'
		</CFQUERY>
		<cfif form.List_Features>
			<!--- Insert Labels Record --->
			<CFQUERY NAME="Save_Labels_Data" datasource="#application.datasource#">
				<cfloop from="1" to="#form.List_Features#" index="A">
				INSERT INTO Program_Perf_Req_Labels(Program_Perf_Req_ID,Perf_Req_Label,Perf_Req_Label_ID)
				VALUES (#Form.Program_Perf_Req_ID#,'#Evaluate("form.List_Feature_Label_#A#")#',#A#)
				</cfloop>
			</CFQUERY>
		</cfif>

	</CFIF>

</cfif>

<cfset labelComp 			= CreateObject("component", "components.settings.labels.labels").init() />
<cfset qGetCategoryLabel 	= labelComp.GetGeneralLabels('Operator Category') />
<cfset qGetPriorityLabel 	= labelComp.GetGeneralLabels('Operator Priority') />


<CFQUERY NAME="Get_LastUpdated_Details" datasource="#application.datasource#">
	Select		TOP 1*
	From		Program_Perf_Req
	<CFIF URL.RID NEQ 0>
	Where		Program_Perf_Req_ID = '#URL.RID#'
	</CFIF>
	Order by	Date_Updated Desc
</CFQUERY>

<CFIF Get_LastUpdated_Details.Recordcount GT 0>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_LastUpdated_Details.Updated_By#",
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
		SELECT 	_Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM 	_Users
		WHERE 	User_ID = '#Get_LastUpdated_Details.Updated_By#'
	</CFQUERY>
</cfif>
</CFIF>

<CFSET URL.PageTitle="Performance Requirements">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<tr><td>
<CFIF Get_LastUpdated_Details.RecordCount GT 0>
	<FONT SIZE="2"><B>This <cfif url.RID NEQ 0>file <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Get_LastUpdated_Details.Date_Updated, 'm/d/yyy')# #timeformat(Get_LastUpdated_Details.Date_Updated, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT></td></tr></table>
</CFIF>
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_perf_req")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_perf_req", {
				"order" = "program_perf_req_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		*
	From		Program_Perf_Req
	Order by	Program_Perf_Req_ID
</CFQUERY>
</cfif>
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
	<TR>
		<TD VALIGN="top">
			<SPAN CLASS="title2">Existing Performance Requirements</SPAN>
			<HR COLOR="Blue" SIZE="1">

			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
				<TR>
					<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
				</TR>
				<CFOUTPUT QUERY="Get_Data">
				<TR>
					<TD NOWRAP><A HREF="performance_requirements.cfm?RID=#Program_Perf_Req_ID#">#Requirement_Name#</A></TD>
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

			<CFPARAM NAME="DD_Type_Name" DEFAULT="">
			<CFPARAM NAME="DD_Reminder_Type_ID" DEFAULT="">
			<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">

			<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
				Select		*
				From		Program_Perf_Req
				Where		Program_Perf_Req_ID	like	'#URL.RID#'
			</CFQUERY>

			<cfset form.PR_Operator_Category 	= Get_Item.PR_Operator_Category />
			<cfset form.PR_Operator_Priority 	= Get_Item.PR_Operator_Priority />
			<cfset form.PR_Date_Range			= Get_Item.PR_Date_Range />
			<cfset form.Mass_Prog_Change			= Get_Item.Mass_Prog_Change />
			<cfset form.Allow_Change_On_Revision 	= Get_Item.Allow_Change_On_Revision />
			<cfset form.List_Features 	= Get_Item.List_Features /><!--- 70947 --->

			<SCRIPT language="JavaScript">
				function alert_and_delete()
				{
					var confirmdelete = confirm("Click OK to permanently delete this record. You won't be able to undo this change...");
					if (confirmdelete == true)
					{
						document.all.DeleteRecord.value=1;
						document.all.Deleted.value=1;
						document.MyForm.submit();
					}
				}

				function SubmitForm()
				{
					var isError = 0;
					var re = /\s/g;
					var strRequirement_Name = document.MyForm.Requirement_Name.value.replace(re, "");
					if (strRequirement_Name.length == 0)
					{
						alert("Please enter a description.");
						isError = 1;
					}
					if (isError == 0)
					{
						MyForm.submit();
					}
					return false;
				}

			</SCRIPT>
			<FORM ACTION="performance_requirements.cfm" METHOD="post" NAME="MyForm">
			<TABLE CELLSPACING="5" CELLPADDING="0" border="0">
				<cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
					<TD VALIGN="top">
						<INPUT SIZE="62" NAME="Requirement_Name" VALUE="#Get_Item.Requirement_Name#" MAXLENGTH="70">
						<INPUT TYPE="hidden" NAME="Program_Perf_Req_ID" VALUE="#Get_Item.Program_Perf_Req_ID#">
					</TD>
				</TR>

				<TR>
					<TD VALIGN="top" ALIGN="right" nowrap="nowrap">
						<B>Operator Category</B><br />
						<cfif qGetCategoryLabel.RecordCount>
							(#qGetCategoryLabel.General_Labels_Label#)
						</cfif>
					</TD>
					<TD VALIGN="top">
						<input name="PR_Operator_Category" type="checkbox" value="1" <cfif form.PR_Operator_Category eq 1>checked</cfif> />
					</TD>
				</TR>

				<TR>
					<TD VALIGN="top" ALIGN="right" nowrap="nowrap">
						<B>Operator Priority</B><br />
						<cfif qGetPriorityLabel.RecordCount>
							(#qGetPriorityLabel.General_Labels_Label#)
						</cfif>
					</TD>
					<TD VALIGN="top">
						<input name="PR_Operator_Priority" type="checkbox" value="1" <cfif form.PR_Operator_Priority eq 1>checked</cfif> />
					</TD>
				</TR>

				<TR>
					<TD VALIGN="top" ALIGN="right" nowrap="nowrap"><B>Date Range</B></TD>
					<TD VALIGN="top">
						<input name="PR_Date_Range" type="checkbox" value="1" <cfif form.PR_Date_Range eq 1>checked</cfif> />
					</TD>
				</TR>
				</cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right" nowrap="nowrap"><B>Mass Prog Change</B></TD>
					<TD VALIGN="top">
						<input name="Mass_Prog_Change" type="checkbox" value="1" <cfif form.Mass_Prog_Change eq 1>checked</cfif> />
					</TD>
				</TR>
				<TR>
					<TD VALIGN="top" ALIGN="right" nowrap="nowrap"><B>Allow Change On Revision</B></TD>
					<TD VALIGN="top">
						<input name="Allow_Change_On_Revision" type="checkbox" value="1" <cfif (form.Allow_Change_On_Revision eq 1) OR (form.Allow_Change_On_Revision eq "")>checked</cfif> />
					</TD>
				</TR>
				<!--- 70947 START --->
				<TR>
					<TD VALIGN="top" ALIGN="right" nowrap="nowrap"><B>List Feature</B></TD>
					<TD VALIGN="top">
						<select name="List_Features" class="List_Features">
							<option value="0" <cfif form.List_Features EQ 0>Selected</cfif>>Off</option>
							<option value="3" <cfif form.List_Features EQ 3>Selected</cfif>>3 Lists</option>
							<option value="6" <cfif form.List_Features EQ 6>Selected</cfif>>6 Lists</option>
						</select>
					</TD>
				</TR>
				<tr id="List_Features_Labels" <cfif form.List_Features EQ 0 OR len(form.List_Features) EQ 0>style="display: none;"</cfif>>
					<td colspan="2" align="center">
						<CFQUERY NAME="Get_Labels" datasource="#application.datasource#">
							Select		*
							From		Program_Perf_Req_Labels
							Where		Program_Perf_Req_ID	like	'#URL.RID#'
							and 		Deleted = 0
						</CFQUERY>

						<cfloop from="1" to="6" index="tb">
							<cfoutput>
							<span id="List_Feature_Label_#tb#">
								<b>Label #tb#:</b>
								<input type="text" name="List_Feature_Label_#tb#" value="#Get_Labels.Perf_Req_Label[tb]#" ><br>
							</span>
							</cfoutput>
						</cfloop>
					</td>
				</tr>
				<!--- 70947 END --->
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
					<TD VALIGN="top">
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<!--- Get the number of projects that have this phase: If there is at least 1 project that is active and has this phase, then I will not allow the user to delete this phase --->
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
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive
						</CFOUTPUT>
					</TD>
				</TR>
				<TR>
					<TD VALIGN="top" ALIGN="right"></TD>
					<TD VALIGN="top">
						<CF_button
							button_name	=	""
							button_caption	=	"save data"
							button_action	=	"return SubmitForm();"
							button_type	=	"javascript_link"
							button_width	=	"75"
							button_color	=	"Navy"
							button_tip	=	""
							font_color	=	"White"
							font_size		=	"12"
							font_weight	=	"bold"
						>
						<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
						<cfif Get_Item.Recordcount GT 0>
							<cfquery name="RequirementIsUsed" datasource="#application.datasource#">
								SELECT  One_Program_Perf_Mapping.Contract_Main_ID
								FROM 	One_Program_Perf_Mapping
										INNER JOIN Contract_Main
										ON One_Program_Perf_Mapping.Contract_Main_ID = Contract_Main.Contract_Main_ID
								WHERE 	One_Program_Perf_Mapping.Program_Perf_Req_ID = #Get_Item.Program_Perf_Req_ID#
								AND 	Contract_Main.Deleted = 0
							</cfquery>

							<CFIF  RequirementIsUsed.Recordcount LT 1>
								<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
								<A HREF="javascript: alert_and_delete();"><B>delete data</B></A>
								<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>
							<cfif RequirementIsUsed.Recordcount GT 0>
								<br><br>This requirement has been used in a program, and cannot be deleted.
							</cfif>
						</cfif>
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
	<A HREF="performance_requirements.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
<cfset jQuery.version = '1.12.4'>
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript">
	$(".List_Features").change(function () {
		var counter = $( this ).val();
		if(counter ==0){
			$("#List_Features_Labels").hide();
		}
		else{
			$("#List_Features_Labels").show();
		}
		hideTextbox(counter)
	});
	function hideTextbox(counter){
		for(i=4; i<=6; i++){
			if(counter ==3){
				$("#List_Feature_Label_"+i).hide();
			}
			else{
				$("#List_Feature_Label_"+i).show();
			}
		}
	}
window.onload = function() {
  hideTextbox(<cfoutput>#form.List_Features#</cfoutput>);
};
</script>
