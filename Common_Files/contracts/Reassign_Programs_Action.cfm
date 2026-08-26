<CFSET PAGE_TITLE="Reassign Programs">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFOUTPUT>
<CFSET Locked_Program_List = "">
<CFSET Locked_Program_ID_List = "">
<CFIF isdefined("FORM.SelectedITEMS")>

<cfset useLakebaseForGet_Session_Window = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGet_Session_Window>
	<cftry>
		<cfset Get_Session_Window = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "session_expiration_length"
			}), "session_expiration_length"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Session_Window = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Session_Window>
<CFQUERY NAME="Get_Session_Window" datasource="#application.datasource#">
	Select   Session_Expiration_Length
	From     General_Settings
</CFQUERY>
</cfif>
<CFSET session_time=Get_Session_Window.Session_Expiration_Length>

<CFLOOP INDEX="item" LIST="#Form.SelectedITEMS#" DELIMITERS=",">

	<cfparam name="FORM.responsibleUser_#item#" 	default="0">
	<cfset FORM.responsibleUser = Evaluate("FORM.responsibleUser_#item#") />

	<cfset useLakebaseForFind_Contract_Number = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForFind_Contract_Number>
	<cftry>
		<cfset Find_Contract_Number = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Item#",
				"select" = "contract_number,programtype_id,contract_main_id"
			}), "contract_number,programtype_id,contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForFind_Contract_Number = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFind_Contract_Number>
<CFQUERY NAME="Find_Contract_Number" DATASOURCE="#Application.Datasource#">
		SELECT Contract_Number, ProgramType_ID, Contract_Main_ID FROM Contract_Main WHERE Contract_Main_ID = #Item#
	</CFQUERY>
</cfif>
	<CFQUERY NAME="Check_islocked" DATASOURCE="#Application.Datasource#">
		SELECT 	Contract_Main.*,
				DateDiff(s, ISNULL(Contract_Lock_Date, GetDate()), GetDate()) AS qSession_delta
		FROM Contract_Main
		WHERE 	Contract_Is_Locked = 1
				AND Contract_Locked_By_User_ID <> '#request.AccessStructure.User_ID#'
				AND Contract_Number = '#Find_Contract_Number.Contract_Number#'
				AND Deleted = 0 	<!--- D28675 : Program cannot be reassign because it is locked --->
	</CFQUERY>
	<CFSET CheckIsLock = 0>
	<CFLOOP QUERY="Check_islocked">
		<CFSET session_delta = qSession_delta/(24*60*60)>
		<CFIF session_delta GT session_time>
			<CFSET CheckIsLock = 0>
		<CFELSE>
			<CFSET CheckIsLock = 1>
		</CFIF>
	</CFLOOP>

	<CFIF CheckIsLock EQ 0>

		<!--- lock the program --->
		<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.User_ID#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="#Find_Contract_Number.Contract_Number#">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
		</cfstoredproc>


		<CFQUERY NAME="Reassign_creator" DATASOURCE="#Application.Datasource#">
			UPDATE 		Contract_Main
			SET 		Creating_User_Position_ID = #To_Position#
						<cfif FORM.responsibleUser NEQ 0>
						, Responsible_User_Id = '#FORM.responsibleUser#'
						</cfif>
            <cfif (From_Position NEQ "")>
						, Original_Creating_User_Position_ID = #From_Position#
            </cfif>
			WHERE 		Contract_Number = '#Find_Contract_Number.Contract_Number#'
		</CFQUERY>

		<!--- Add program owner info here --->
		<CFQUERY NAME="insProgramOwner" DATASOURCE="#application.datasource#">
		 INSERT INTO Program_Owner(Contract_Main_ID, Contract_Number, Responsible_User_ID, Creating_User_Position_ID, Reassigned_By)
		  VALUES('#Item#', '#Find_Contract_Number.Contract_Number#', '#FORM.responsibleUser#', '#To_Position#', '#request.AccessStructure.User_ID#')
		</CFQUERY>

		<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.User_ID#">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
			<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
			<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
			<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="#Find_Contract_Number.Contract_Number#">
		</cfstoredproc>


			<!--- D38387 Programs not routing for approval START --->
				<cfif Check_islocked.Contract_Status_Type_IDX EQ 2>
					<CFQUERY NAME="Update_Program_Agree" DATASOURCE="#Application.Datasource#">
						UPDATE Program_Agree
						SET deleted = 1
						WHERE ProgramID = #Item#
					</CFQUERY>
					<cfset useLakebaseForUpdate_Program_Type_code = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_type_code_approval_info")>
<cfif useLakebaseForUpdate_Program_Type_code>
	<cftry>
		<cfset application.oLakebase.updateRows("program_type_code_approval_info",
			{
				"program_id" = "eq.#Item#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Program_Type_code = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Program_Type_code>
<CFQUERY NAME="Update_Program_Type_code" DATASOURCE="#Application.Datasource#">
						UPDATE Program_Type_Code_Approval_Info
						SET deleted = 1
						WHERE Program_ID = #Item#
					</CFQUERY>
</cfif>
				</cfif>

					<cfstoredproc procedure="Populate_Program_Approvable_Positions" datasource="#application.datasource#">
							<cfprocparam type="In" CFSQLType="CF_SQL_Integer" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Item#">
					</cfstoredproc>
			<!--- D38387 Programs not routing for approval END --->

		<!--- Dev Note: KAL; D20839: Budget should get reassigned when program gets reassigned, if the app setting Budgets_Functionality_On is on --->
		<!---
		We no longer need to call budget proc here as it will get called at the bottom of this page save_budgets()
		<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() >
			<!--- 25715: Budgeting --->
			<cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').updateBudgetForProgramReassign(programId = Item) />
		</cfif>
		 --->
		<!--- End Note: KAL; D20839: Budget should get reassigned when program gets reassigned --->

	<CFELSE>
		<CFIF Locked_Program_List EQ "">
			<CFSET Locked_Program_List = "#Check_islocked.Contract_Number#">
			<CFSET Locked_Program_ID_List = "#Check_islocked.Contract_Main_ID#">
			<CFSET pos = ListFind(Form.SelectedITEMS, #Item#)>
			<CFSET FORM.SelectedITEMS = ListDeleteAt(Form.SelectedITEMS,"#pos#",",")>

		<CFELSE>
			<CFSET Locked_Program_List = "#Locked_Program_List#,#Check_islocked.Contract_Number#">
			<CFSET Locked_Program_ID_List = "#Locked_Program_ID_List#,#Check_islocked.Contract_Main_ID#">
			<CFSET pos = ListFind(Form.SelectedITEMS, #Item#)>
			<CFSET FORM.SelectedITEMS = ListDeleteAt(Form.SelectedITEMS,"#pos#",",")>
		</CFIF>
	</CFIF>
	<!---set the full path--->
	<cfif fileexists("#Application.Doc_Path#\Temp_Files\Program\View_Program_#item#.htm")>
		<cffile action = "delete" file = "#Application.Doc_Path#\Temp_Files\Program\View_Program_#item#.htm">
	</cfif>
</CFLOOP>
<!---D33624:Mass Reassign - Budget Picker --->
<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
	<cfset createObject('component','mvc.Models.AdvancedBudget.BudgetManager').save_budgets(form, 1)>
</cfif>
<!---D33624:Mass Reassign - Budget Picker --->
</CFIF>


<BR><BR><BR><BR>


<CFIF isdefined("FORM.SelectedITEMS")>
<CFIF Locked_Program_List NEQ "">

	<SCRIPT language="JavaScript">
	var unsuccessful= "<CFOUTPUT>#Locked_Program_List#</CFOUTPUT>";
	alert("Program(s) [" + unsuccessful + "] can't be reassigned (This program / revision is currently locked).");
	window.setTimeout('goBackToOtherPage()', 0);
	</SCRIPT>

</CFIF>
</CFIF>

</CFOUTPUT>


<CFIF Locked_Program_List EQ "">

<cfset UnAssigned_Contract_Number ="">
<!--- Dev Note:11511;Milan- If a program has not been re-assigned due to class code restrictions(11403 - Conagra wants to reassign a
			program when all the class codes for a program match the reassigned RSP's class codes), then redirect the user to the previous page
			with all the programs which could not be re-assigned. --->
	<cfif ListLen(Contract_Number) neq ListLen(SelectedItems)>
			<cfloop list="#Contract_Number#" index="Prog_ID">
				<cfif ListFindNoCase(SelectedItems,Prog_ID) eq 0>
					<cfset UnAssigned_Contract_Number = ListAppend(UnAssigned_Contract_Number,Prog_ID)>
				</cfif>
			</cfloop>

		<cfset Contract_Number= UnAssigned_Contract_Number>

			<form action="Reassign_Programs.cfm" name="ReassignFrm" method="post">
				<cfoutput>
				<CFLOOP COLLECTION="#Form#" ITEM="FormItem">
					 <CFIF FindNoCase("ResponsibleUser", FormItem) eq 0 AND FindNoCase("Contract_Number", FormItem) eq 0>
						<CFIF IsDefined("Form.#FormItem#")>
						 <INPUT TYPE="HIDDEN" ID="#FormItem#" NAME="#FormItem#" VALUE="#Evaluate("Form.#FormItem#")#">
						 </CFIF>
					 </CFIF>
				</CFLOOP>
						 <INPUT TYPE="HIDDEN" ID="Contract_Number" NAME="Contract_Number" VALUE="#Contract_Number#">
				</cfoutput>
	</form>

<script language="javascript">
	document.ReassignFrm.submit();
</script>

	<cfelse>
    <script>
      alert('Reassigning was successful!!');
    </script>
    <cfif (isDefined("FORM.Reassign_Type") AND FORM.Reassign_Type EQ "3")>
     <!--- D33624:Mass Reassign - Budget Picker 	WE PROVIDE AN OPTION TO PICK BUDGET IN REASSIGN TOOL NO LONGER NEEDED THIS
     <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
      <cfif appSettings.getBudgetsFunctionalityOn()>   <!--- 30902 --->
        <script>
      		window.location = <cfoutput>'/Common_Files/contracts/budget_display.cfm?Program_ID=#Find_Contract_Number.Contract_Main_ID#&reassign=1'</cfoutput>;
      	</script>
      <cfelse>

      </cfif> --->
      <!--- D33624:Mass Reassign - Budget Picker --->
      <script>
          window.close();
          opener.location.reload();
        </script>
      <!--- D33624:Mass Reassign - Budget Picker --->
    <cfelse>
	    <cflocation addtoken="No" url="Reassign_Programs.cfm">
  	</cfif>
  </cfif>

</CFIF>

<SCRIPT LANGUAGE="JavaScript">
function goBackToOtherPage()
{
		window.location.href = "Reassign_Programs.cfm";
}
<CFIF Locked_Program_List EQ "">
	window.setTimeout('goBackToOtherPage()', 0);
</CFIF>
</SCRIPT>


<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>


</body>
</html>
