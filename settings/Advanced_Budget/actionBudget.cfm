
<cfinclude template="actionFormat.cfm"> 
<cfoutput>	

<cfif isDefined("FORM.selActions2") and FORM.selActions2 NEQ "">
<cfset FORM.selActions = FORM.selActions2 />
</cfif>

	<cfif isDefined("FORM.selActions")>
 	<cfswitch expression="#FORM.selActions#">
		<!--- Delete Selected  --->
		<cfcase value="1">
			<cfif FORM.Deleteable_Budget_Ids EQ "">
				<cfset qBudgetsSelected  = getSelectedBudgets(FORM.ChkBudgetID) />
				<!--- <cfdump var="#qBudgetsSelected#"/> --->
				<cfset iCounter1 = 1 />
				<cfset iCounter2 = 1 />
				<cfset strCannotDelete = "" />
				<cfset strCanDelete	   = "" />
				<cfset lsBudgetsCanDelete = "" />
				<cfloop query = "qBudgetsSelected">
					<cfif (qBudgetsSelected.committed_dollar OR qBudgetsSelected.actual_dollar)>
						<cfset strCannotDelete = strCannotDelete & iCounter1 & " ." & qBudgetsSelected.Budget_Code & " - " & qBudgetsSelected.Budget_Desc & "<br>" />
						<cfset iCounter1++ />
					<cfelse>
						<cfset strCanDelete = strCanDelete & iCounter2 & " ." & qBudgetsSelected.Budget_Code & " - " & qBudgetsSelected.Budget_Desc & "<br>" />
						<cfset lsBudgetsCanDelete = ListAppend(lsBudgetsCanDelete, qBudgetsSelected.Budget_ID, ",")>
						<cfset iCounter2++ />
					</cfif>
				</cfloop>
				<br><br>
				<cfif (strCannotDelete NEQ "")>
					<strong>ATTENTION:</strong><br>There are programs committed for the below budget.<br>'
					  	    	'You will need cancel them to remove the commitments.<br><br>'
				       			'If actual payments have been made, you cannot delete a budget.<br>
								<br>
								#strCannotDelete#
				</cfif>		
				<cfif (strCanDelete NEQ "")> 
				<br>
					<b>Are you sure you want to delete the below Budgets?</b><br><br>
					
					#strCanDelete#
					
					<a href="##" onclick="javascript:submitApplyAction('Delete','#lsBudgetsCanDelete#');">#LCase(ActionText("Yes"))#</a>
					<a href="index.cfm">#LCase(ActionText("No"))#</a>
				</cfif>		
			<cfelse><!--- ELSE Condition for <cfif FORM.Deleteable_Budget_Ids NEQ ""> --->
				<cfquery name="vars.delete" datasource="#application.datasource#">
				  UPDATE Budget
				     SET Deleted = 1
				   WHERE Budget.Budget_Id IN (#form.Deleteable_Budget_Ids#)
				</cfquery>
				<cflocation URL="/Settings/Advanced_Budget/index.cfm?showAlert=deleted" />				
			</cfif>
		</cfcase>
		
		<!--- Copy Selected --->
		<cfcase value="2">
			<cfset iCounter = 0>
			<cfloop index = "BudgetID" list = "#FORM.ChkBudgetID#"> 
				<cfstoredproc procedure="ADV_BUDGET_COPY" datasource="#application.datasource#">
					<cfprocparam type="In" 	cfsqltype="CF_SQL_INTEGER "	dbvarname="@original_budget_id"	value="#BudgetID#">
					<cfprocparam type="Out"	cfsqltype="CF_SQL_INTEGER"	dbvarname="@new_budget_id"		variable="new_budget_id">	
				</cfstoredproc>
				<cfset iCounter++ />
			</cfloop>	
<!--- 			<script language="javascript">
				alert("The selected budgets were copied!");
			</script>	 --->
			<cflocation URL="/Settings/Advanced_Budget/index.cfm?showAlert=copied" />
		</cfcase>
		
		<!--- Copy ALL --->		
		<cfcase value="3">
			<cflocation url="massCopy.cfm" />
		</cfcase>
		
		<!--- Deactivate Selected --->		
		<cfcase value="4">
			
			<cfif FORM.Deactivate_Budget_Ids EQ "">
				<cfset qBudgetsSelected  = getSelectedBudgets(FORM.ChkBudgetID) />
				<!--- <cfdump var="#qBudgetsSelected#"/> --->
				<cfset iCounter1 = 1 />
				<cfset iCounter2 = 1 />
				<cfset strConfirmDeactivate = "" />
				<cfset strCanDeactivate	   = "" />
				<cfset lsBudgetsCanDeactivate = "" />
				<cfloop query = "qBudgetsSelected">
					<cfif (qBudgetsSelected.committed_dollar)>
						<cfset strConfirmDeactivate = strConfirmDeactivate & iCounter1 & " ." & qBudgetsSelected.Budget_Code & " - " & qBudgetsSelected.Budget_Desc & "<br>" />
						<cfset iCounter1++ />
					<cfelse>
						<cfset strCanDeactivate = strCanDeactivate & iCounter2 & " ." & qBudgetsSelected.Budget_Code & " - " & qBudgetsSelected.Budget_Desc & "<br>" />
						<cfset lsBudgetsCanDeactivate = ListAppend(lsBudgetsCanDeactivate, qBudgetsSelected.Budget_ID, ",")>
						<cfset iCounter2++ />
					</cfif>
				</cfloop>
				<br><br>
				<cfif (strConfirmDeactivate NEQ "")>
					<strong>WARNING:<br>There are programs committed for the selected budget.<br>
								<br>
								#strConfirmDeactivate#
				</cfif>		
				<cfif (strCanDeactivate NEQ "")>	
				<br>
					<b>Are you sure you want to deactivate the below Budgets?</b><br><br>
					#strCanDeactivate#
					
					<a href="##" onclick="javascript:submitApplyAction('Deactivate','#lsBudgetsCanDeactivate#');">#LCase(ActionText("Yes"))#</a>
					<a href="index.cfm">#LCase(ActionText("No"))#</a>
				</cfif>		
			<cfelse><!--- ELSE Condition for <cfif FORM.Deactivate_Budget_Ids NEQ ""> --->
				<cfquery name="vars.deactivate" datasource="#application.datasource#">
					UPDATE Budget
			       SET Active = 0
				   WHERE Budget.Budget_Id IN (#form.Deactivate_Budget_Ids#)
				</cfquery>
				<cflocation URL="/Settings/Advanced_Budget/index.cfm?showAlert=deactivated" />
			</cfif>
			
		</cfcase>
		
		<!--- Activate Selected --->		
		<cfcase value="5">
			 <cfquery name="vars.activate" datasource="#application.datasource#">
			 	UPDATE Budget
			    	SET Active = 1
			    WHERE Budget.Budget_Id IN (#FORM.ChkBudgetID#)
			 </cfquery>
			 <cflocation URL="/Settings/Advanced_Budget/index.cfm?showAlert=activated" />
		</cfcase>
		
		
	</cfswitch>	
 
 </cfif>
 
 </cfoutput>			
 
<cffunction name="getSelectedBudgets" output="false">
	<cfargument name="selectedBudgetRows" type="any" required="true" hint="Passing all the selected Budget IDs">
  <cfset var vars = {}>
  	<cfquery name="vars.qBudget" datasource="#application.datasource#">
     	SELECT   b.Budget_ID
           , b.Budget_Code
           , b.Budget_Desc
           , b.Active
           , b.Budget_Status
           , ISNULL(b.Budget_Dollar, 0) AS Budget_Dollar
           , ISNULL(b.Committed_Dollar, 0) AS Committed_Dollar
           , ISNULL(b.Actual_Dollar, 0) AS Actual_Dollar
           , bcft.Contribution_Factor_Type
           , bcft.Budget_Contribution_Factor_Type_ID
           , bc.Budget_Class_Desc
           , bg.Budget_Group_Desc
           , bs.Business_Unit_Desc
      	FROM Budget b
            <!--- <cfif URL.segmentIsOn eq '1' and URL.userBusinessSegments eq '1'>
                    INNER JOIN User_Business_Segment ubs
                      ON ubs.Business_Segment_Id = b.Business_Segment_Id
                          AND ubs.Deleted = 0
                          AND ubs.User_Id = '#request.AccessStructure.User_ID#'
            </cfif> --->
            LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
            LEFT JOIN Budget_Contribution_Factor_Type bcft ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
            LEFT JOIN Budget_Group bg ON b.Budget_Group_ID = bg.Budget_Group_ID
            LEFT JOIN Business_Segment bs ON b.business_segment_id = bs.business_segment_id
     	WHERE b.Deleted = 0
            AND  b.Budget_ID in ( <cfqueryparam value="#arguments.selectedBudgetRows#" cfsqltype="cf_sql_integer" list="yes"> )
	</cfquery>

	<cfreturn vars.qBudget />
</cffunction>			
<cfoutput>
	<script language="javascript">
		function submitApplyAction(ActionType,IDsPassed)
		{
			
			if (ActionType == 'Delete')
			{
				document.forms[budget_form].Deleteable_Budget_Ids.value = IDsPassed;
			}
			else if (ActionType == 'Deactivate')
			{
				document.forms[budget_form].Deactivate_Budget_Ids.value = IDsPassed;
			}
			
			document.forms[budget_form].selActions2.value = "#FORM.selActions#";
			document.forms[budget_form].command.value = "actionBudget";
			document.forms[budget_form].submit();
		}
	</script>
</cfoutput>