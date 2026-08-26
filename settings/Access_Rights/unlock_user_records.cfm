<!--- Dev Note: drachala; D29591: List User page not sorting  START
Added/Changed: Assign URL variable to Existing Form variable START--->
<cfparam name="form.USER_ID" default="#form.USER_ID#" />
<!--- End Dev Note: drachala; D29521: List User page not sorting  --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----  Reset Session_Tracker ------->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Reset_Login_Status" datasource="#application.datasource#">
	UPDATE	Session_Tracker
	SET 	Session_ID = NULL
	WHERE	Session_User_ID		=	<cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----  End Reset Session_Tracker ------->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock programs, billbacks and projects
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFIF Len(Trim(form.USER_ID)) GT 0>
	<CFQUERY NAME="Unlock_All" DATASOURCE="#application.datasource#">
		EXEC Unlock_Invalid_Users <cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
</CFIF>

<!--- unlock all what if p&l --->
<cfscript>
	variables.whatIfCFC = createObject("component", "components.programs.whatif");
	variables.whatIfCFC.unlockAll( form.USER_ID );
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock Locks in User Profiles
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFSET getProfileLockStatus = CreateObject("component", "components.settings.profiles.profile").getProfileLockStatus()>

<CFIF getProfileLockStatus.Locked_By_User_ID EQ form.USER_ID>
	<CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(form.USER_ID,0)>
</CFIF>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock Locks in Sequence  Profiles
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFSET getSequenceProfileLockStatus = CreateObject("component", "components.settings.profiles.profile").getSequenceProfileLockStatus()>
<CFIF getSequenceProfileLockStatus.Locked_By_User_ID EQ form.USER_ID>
	<CFSET Locked = CreateObject("component", "components.settings.profiles.profile").unlocksequenceprofiles(form.USER_ID)>
</CFIF>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock Locks in BB Auto PAy Report
pass a 0 to LockReport() to unlock
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfset oBBReportUpdate	= CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
<cfset Locked = oBBReportUpdate.lockReport(form.USER_ID,0) />

<!--- Reset the Login_Status bit in the database --->
<CFQUERY NAME="Set_Login_Status" datasource="#application.datasource#">
	UPDATE	_Users
	SET 	Login_Status = 0
	WHERE	User_ID	=	<cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>



<!--- Unlock mass program change upload --->
<CFQUERY NAME="Unlock_Program_Upload" datasource="#application.datasource#">
	UPDATE		MPCU_LOCK
	SET			IS_LOCKED = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
				DELETED = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
	WHERE		IS_LOCKED = 1
	AND			DELETED = 0
	AND 		User_ID	=	<cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<!---
	Dev Notes: 23086/Anand Rao/24-May-10
	User Traffic Changes
--->
      <cfset UsersIP = CGI.Remote_Addr>
      <cfquery name="qGetUserCode" datasource="#application.datasource#">
        SELECT User_Code FROM _Users WHERE User_ID = <cfqueryparam value="#FORM.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
      </cfquery>
      <cfquery name="AddUserTransLoginReset" datasource="#application.datasource#">
        INSERT INTO Audit_User_Transactions(Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID)
        VALUES
        (
          'UNLOCK-FORCED-LOGOFF',
          <cfqueryparam value="#qGetUserCode.User_Code#" cfsqltype="CF_SQL_VARCHAR">,
          <cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">,
          <cfqueryparam value="#Request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
        )
      </cfquery>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Handle for match central
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfset oMatchCentral = createObject("component", "components.Match_Central.MatchCentral").init(form.USER_ID) />
<cfset oMatchCentral.clearWorkList() />
<!--- will unlock DD, CR, and BB's even if the XML files had somehow gotten deleted --->
<cfset oMatchCentral.unlockMatchCentralLocksByUser() />

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Log Unlock By and Date
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY NAME="Set_Login_Status" datasource="#application.datasource#">
	UPDATE	_Users
	SET 	Last_Unlock_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
			Last_Unlock_Date = getDate()
	WHERE	User_ID	=	<cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Unlock the records locked in BB_Reprocess_Lock  table
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY NAME="BBProcessLockUpdate" datasource="#application.datasource#">
	UPDATE BB_Reprocess_Lock SET Is_Locked = 0, Deleted = 1 Where User_ID = <cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Is_Locked = 1 AND Deleted = 0
</CFQUERY>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
<!--- 44787: Kraft - Alias update for invoice count in the Holding Pen/ Anand Rao/24-Sep-2014 --->
Unlock the records locked in the BB_Upload_Hold_Lock table
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFQUERY NAME="BBProcessLockUpdate" datasource="#application.datasource#">
	UPDATE BB_Upload_Hold_Lock SET Is_Locked = 0, Deleted = 1 Where User_ID = <cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Is_Locked = 1 AND Deleted = 0
</CFQUERY>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
<!--- 103971	Double Dip Report/ Anand Rao/05-Mar-2021 --->
Unlock the records locked in the BB_DblDipRpt_Lock table
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!---    --->
<cfset BBDblDipReportMgr = CreateObject("component", "mvc.Models.Billback.BillbackDblDipRpt") />
<cfset variables.processing = BBDblDipReportMgr.checkIsRunning()>
<cfif (variables.processing EQ 0)>
	<CFQUERY NAME="BBProcessLockUpdate" datasource="#application.datasource#">
		UPDATE BB_DblDipRpt_Lock SET Is_Locked = 0, Deleted = 1 Where User_ID = <cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Is_Locked = 1 AND Deleted = 0
	</CFQUERY>
</cfif>


<!--- 
	115103: Retail Planner Template - updates / Anand Rao / 31-May-2022 
		Unlock all Planner templates locked by this user.
--->
<cfset objPlannerTemplateManager = CreateObject("component", "mvc.Models.Planner.PlannerTemplateManager") />
<cfset temp = objPlannerTemplateManager.lockUnlockPlannerTemplate(form.USER_ID,0,0) />


<CFQUERY NAME="SelfServeLockUpdate" datasource="#application.datasource#">
	UPDATE Self_Serve_Lock SET Is_Locked = 0, Deleted = 1 Where User_ID = <cfqueryparam value="#form.USER_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Is_Locked = 1 AND Deleted = 0
</CFQUERY>

<cfscript>
	variables.lock_cfc = createObject("component", "components.general.lock");
	variables.lock_cfc.unlockByUser(user_id = form.user_id);
</cfscript>

<CFLOCATION URL="/index.cfm?event=settings.users.dspUsers" />
