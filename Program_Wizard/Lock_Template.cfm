<!--- Lock_template.cfm - Check if a template is locked or not and allows to Lock or unlock a template.
Called from 		-	header.cfm
Date created 		- 	07/15/2005 by Kalyan
Date Modified 	-	07/20/2005 by Kalyan
Date Last Modified 	-	04/04/2006 by Milan --->

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<!--- Dev Note - KAL: D7952: Program template Lock/unlock feature --->
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/ViewModes.css">
<TABLE BORDER="0" cellpadding="0" cellspacing="0" width="100%">
	<TR>
		<TH nowrap>
<cfoutput>
<cfif ID EQ 0 or action EQ "Copy">
		<cfset displayheader = 0 />
		<cfset LockedBy_Current_User = 1 />
		<cfset Lock_img = "Edit_Mode">
<cfelse>

<!---Gets Template Lock settings--->
<cfset qGetLockInfo = templateManager.getLocked(ID)>
<!--- <cfdump var="#qGetLockInfo#"> --->
<cfparam name="LockedBy_Current_User" default="0">
<cfparam name="Lock_img" default="ReadOnly_Mode">
<cfparam name="Locker" default="">
<cfparam name="User_Message" default="">

	<cfif #qGetLockInfo.IS_Locked# EQ 1>
		<!--- get the database setting for session timeout and use that for now as the program timeout --->
		<CFQUERY NAME="getSessionTimeoutSetting" datasource="#application.datasource#">
			SELECT Session_Expiration_Length
			FROM General_Settings
		</CFQUERY>

		<CFSET FractionOfTHeDayInactive = getSessionTimeoutSetting.Session_Expiration_Length + 1>
		<!--- get the time the user sent a request to the system last --->
		<CFQUERY NAME="getSessionTime" datasource="#application.datasource#">
			SELECT DATEDIFF(n, Session_Date_Time_Stamp, GetDate()) AS InactiveTimeSpanInMinutes
			FROM Session_Tracker
			WHERE Session_User_ID = <cfqueryparam  cfsqltype="CF_SQL_VARCHAR"  value="#qGetLockInfo.Locked_by#">
		</CFQUERY>

		<!--- what fraction of the day has the user been inactive for --->
		<CFIF getSessionTime.RecordCount GT 0>
			<CFSET InactiveTimeSpanInMinutes = getSessionTime.InactiveTimeSpanInMinutes>
			<CFSET FractionOfTHeDayInactive = InactiveTimeSpanInMinutes/1440>
		</CFIF>

		<!--- if the user been inactive longer than the setting specified unlock and recheck if locked --->
		<CFIF FractionOfTHeDayInactive GT getSessionTimeoutSetting.Session_Expiration_Length>
			<cfset temp = templateManager.ReleaseLocks(qGetLockInfo.Locked_by, ID)> <!--- Releaseing the locks by the other user as thats session has expired --->
		</CFIF>
	</cfif> <!--- End: #qGetLockInfo.IS_Locked# EQ 1 --->

<cfset qGetLockInfo = templateManager.getLocked(ID)>

	<cfif #qGetLockInfo.IS_Locked# EQ 1>		<!--- if it is locked --->
			<cfif #qGetLockInfo.Locked_by# EQ #request.AccessStructure.User_ID#>  <!--- if locked by current user --->
				<!--- You display "Header Tabs" only when it is not locked by current user. --->
				<cfif isdefined("URL.displayheader")>
					<cfset displayheader = URL.displayheader />
				<cfelse>
					<cfset displayheader = 0 />
				</cfif>
				<cfset LockedBy_Current_User = 1 />
				<cfset Lock_img = "Edit_Mode">
				<cfset User_Message = "Edit Mode">
			<cfelse> <!--- if locked by other user --->
				<cfset displayheader = 1 />
				<cfset LockedBy_Current_User = 0 />
				<cfset Lock_img = "ReadOnly_Mode">
				<cfset Locker = templateManager.GetLockerInfo(qGetLockInfo.Locked_by) />
				<cfset User_Message = "Read-Only Mode">
			</cfif>
	<cfelse> 				<!--- if not locked --->
		<cfset displayheader = 1 />
		<cfset LockedBy_Current_User = 0 />
		<cfset Lock_img = "ReadOnly_Mode">
		<cfset User_Message = "Read-Only Mode">
	</cfif>

		<cfif LockedBy_Current_User EQ 0 AND qGetLockInfo.IS_Locked EQ 1 > <!--- if locked by other users --->
			<img name="Lock" src="/images/#Lock_img#.gif" border="0" <cfif locker neq "">title="This template is currently being viewed by #ucase(Locker)#"</cfif>><BR />
				<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br />#ucase(Locker)#</span>
		<cfelse>
	<!---	Dev Note: Milan 9503 --->
			<a href="Lock_Unlock_template.cfm?ID=#ID#" style="text-decoration:none;"><img name="Lock" src="/images/#Lock_img#.gif" border="0" title="#User_Message#"><BR />
			<cfif Lock_img EQ "Edit_Mode">
				<span class="ViewModesBracket">[</span><span class="ViewModes">Click for Read Only</span><span class="ViewModesBracket">]</span>
			<cfelse>
				<span class="ViewModesBracket">[</span><span class="ViewModes">Click to Edit</span><span class="ViewModesBracket">]</span>
			</cfif>
	<!---	End Note: Milan 9503 --->
			</a>
		</cfif>
</cfif> <!--- <cfif ID EQ 0> --->
</cfoutput>
			</TH>





			   <cfif ID EQ 0>
				<cfset displayTemplateName = "#Generic_Type# Template" />
			  <cfelse>
				<cfif NOT IsDefined("template")>
					<cfset template = templateManager.get(id)>
				</cfif>
				<cfset displayTemplateName = "#template.getCreatedType()# (#application.util.query.generalLabel(template.getGenericType())#)" />
			  </cfif>





			<TH width="100%"><div align="Center" class="labelname"><cfoutput>#displayTemplateName#</cfoutput></div></TH>
		</TR>
</TABLE>
<!--- Dev Note - KAL: D7952 Ends--->