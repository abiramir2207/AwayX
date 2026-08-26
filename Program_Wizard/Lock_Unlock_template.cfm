<!--- Lock_Unlock_template.cfm - Locks or unlocks the template.
Called from 		-	Lock_Template.cfm
Date created 		- 	07/15/2005 by Kalyan
Date Last Modified 	-	07/20/2005 by Kalyan --->

<cfif IsDefined("url.ID")>
	<cfset ID = url.ID>
<cfelse>
	<cfset ID = 0>
</cfif>

<!--- D29904:Preventing duplicate program templates START --->
<cfset useLakebaseForgetCurrentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetCurrentID>
	<cftry>
		<cfset getCurrentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#url.ID#",
				"select" = "first_parent_id,isdominant"
			}), "first_parent_id,isdominant"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentID>
<cfquery name="getCurrentID" datasource="#application.datasource#">
      SELECT First_Parent_ID, IsDominant 
      FROM Program_Control_Panel_options
      WHERE ProgramControl_Panel_options_ID = #url.ID#
</cfquery>
</cfif>

<cfif NOT getCurrentID.IsDominant>
	<cfset useLakebaseForgetParentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetParentID>
	<cftry>
		<cfset getParentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"first_parent_id" = "eq.#getCurrentID.First_Parent_ID#",
				"isdominant" = "eq.1",
				"select" = "programcontrol_panel_options_id"
			}), "programcontrol_panel_options_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetParentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetParentID>
<cfquery name="getParentID" datasource="#application.datasource#">
	      SELECT ProgramControl_Panel_options_ID 
	      FROM Program_Control_Panel_options
	      WHERE First_Parent_ID = #getCurrentID.First_Parent_ID#
		  AND IsDominant = 1
	</cfquery>
</cfif>
      <cfset ID = getParentID.ProgramControl_Panel_Options_ID>
</cfif>
<!--- D29904:Preventing duplicate program templates END --->

<!---Gets Template Lock settings --->
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() /> 
<cfset qGetLockInfo = templateManager.getLocked(ID)>

	<cfoutput>
		<cfif #qGetLockInfo.IS_Locked# EQ 1>		<!--- if it is locked release the locks --->
			<cfset temp = templateManager.ReleaseLocks(request.AccessStructure.User_ID)>
				<cfset displayheader = 1 /> 	<!--- You display "Header Tabs" only when it is not locked by current user. --->
				<cfset LockedBy_Current_User = 0 />
				<cfset Lock_img = "ReadOnly">			
		<cfelse> <!--- else Lock Template but release locks on other templates --->
			<cfset temp = templateManager.ReleaseLocks(request.AccessStructure.User_ID)>
			<cfset temp = templateManager.LockTemplate(ID,request.AccessStructure.User_ID)>
				<cfset displayheader = 0 /> 
				<cfset LockedBy_Current_User = 1 />
				<cfset Lock_img = "Edit">		
		</cfif>
	</cfoutput>


<cflocation url="create_edit.cfm?ID=#ID#&action=EDIT&Generic_Type=""" />