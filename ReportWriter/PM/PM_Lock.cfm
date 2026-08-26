<CFIF 
	(IsDefined("FORM.LOCK_RID") AND Len(FORM.LOCK_RID) GT 0)
	OR
	(IsDefined("URL.LOCK_RID") AND Len(URL.LOCK_RID) GT 0)>
	
	<CFPARAM NAME="URL.LOCK_RID" 	DEFAULT="">
	<CFPARAM NAME="FORM.LOCK_RID" 	DEFAULT="#URL.LOCK_RID#">
	<CFPARAM NAME="PRESENT_LOCK_STATUS" 	DEFAULT="1">
	
	<CFPARAM NAME="URL.FID" 	DEFAULT="">
	<CFPARAM NAME="FORM.FID" 	DEFAULT="#URL.FID#">
	<CFIF PRESENT_LOCK_STATUS EQ 1>
	<!----- unlock it if locked by me ----->
		<CFQUERY NAME="Lock_Project" DATASOURCE="#application.datasource#">
			UPDATE	PM_Item_Master
			SET		PM_Locked	=	0,
					PM_Locked_By_User_ID = NULL,
					PM_Locked_Date = NULL
			WHERE	
					PM_Item_Master_ID = '#FORM.LOCK_RID#'
					AND
					PM_Locked = 1
					AND
					PM_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
		</CFQUERY>
	<CFELSE>
	<!---- lock it --->
	
	<!---- first unlock others which are locked by me ---->
		<CFQUERY NAME="unlock_Other_Project" DATASOURCE="#application.datasource#">
			UPDATE	PM_Item_Master
			SET		PM_Locked	=	0,
					PM_Locked_By_User_ID = NULL,
					PM_Locked_Date = NULL
			WHERE	
					PM_Locked = 1
					AND
					PM_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
		</CFQUERY>
		
	<!---- unlock it, if some one who has locked has invalid session ---->			
		<CFQUERY NAME="Unlock_Project" DATASOURCE="#application.datasource#">
			UPDATE	PM_Item_Master
			SET	PM_Item_Master.PM_Locked = 0
			From		
					PM_Item_Master
					LEFT JOIN _Users
					ON
					PM_Item_Master.PM_Locked_By_User_ID = _Users.User_ID					
					LEFT JOIN Session_Tracker
					ON 
					Session_Tracker.Session_User_ID = _Users.User_ID
					INNER JOIN General_Settings
					ON 1=1
			WHERE
					PM_Item_Master_ID = '#FORM.LOCK_RID#'					
					AND
					(
					Session_ID IS NULL
					--No Valid Session
					OR
					(CAST(DateDiff(s, Session_Date_Time_Stamp, GetDate()) AS FLOAT)/(24.00*60.00*60.00)) > Session_Expiration_Length
					--session is no longer valid
					)
		</CFQUERY>
		
	<!---- then lock it, if it is already unlocked ---->	
		<CFQUERY NAME="Lock_Project" DATASOURCE="#application.datasource#">
			UPDATE	PM_Item_Master
			SET		PM_Locked	=	1,
					PM_Locked_By_User_ID = '#request.AccessStructure.User_ID#',
					PM_Locked_Date = GetDate()
			WHERE	
					PM_Item_Master_ID = '#FORM.LOCK_RID#'
					AND
					(PM_Locked = 0 OR PM_Locked IS NULL)
		</CFQUERY>
	</CFIF>	
	<CFIF NOT IsDefined("No_Redirect")>		
		<CFLOCATION URL="PM_Create.cfm?RID=#FORM.LOCK_RID#&FID=#FORM.FID#" ADDTOKEN="No">
	</CFIF>
<CFELSE>
	<CFPARAM NAME="URL.RID" 	DEFAULT="">
	<CFQUERY NAME="Check_Lock" DATASOURCE="#application.datasource#">
		SELECT	PM_Locked, PM_Locked_By_User_ID, _Users.Name_First + ' ' + _Users.Name_Last AS Full_Name
		FROM	PM_Item_Master
				LEFT JOIN _Users
				ON
				_Users.User_ID = PM_Item_Master.PM_Locked_By_User_ID
				AND
				PM_Item_Master.PM_Locked = 1
		WHERE	
				<CFIF URL.RID NEQ ""><!--- if create, locked is defaulted to 1 --->
				PM_Item_Master_ID = '#URL.RID#'
				<CFELSE>
				1=2
				</CFIF>
	</CFQUERY>
	
	<CFSET PM_IS_LOCKED = 1>
	<CFSET lock_Yes = "/images/Deviations/BB_Edit.gif">
	<CFSET lock_No = "/images/Deviations/BB_Readonly.gif">
	<CFSAVECONTENT VARIABLE="Lock_String">
	<CFOUTPUT>
	<CFIF Check_Lock.RecordCount GT 0>
	<FORM ACTION="PM_Lock.cfm" METHOD="POST">
		<INPUT TYPE="Hidden" NAME="LOCK_RID" VALUE="#URL.RID#">
		<CFIF Check_Lock.PM_Locked EQ 1 AND Check_Lock.PM_Locked_By_User_ID EQ request.AccessStructure.User_ID>
		<!---- locked by me ---->
			<CFSET PM_IS_LOCKED = 1>			
			<INPUT TYPE="Image" SRC="#lock_Yes#" ONMOUSEOVER="this.src='#lock_No#';" ONMOUSEOUT="this.src='#lock_Yes#';">
		<div align="center">	<B>[<font color="red">Click for <br> Read Only</font>]</B></div>
		<CFELSEIF Check_Lock.PM_Locked EQ 1 AND Check_Lock.PM_Locked_By_User_ID NEQ "">
		<!---- locked by someone else ---->
			<CFSET PM_IS_LOCKED = 0>
			<IMG SRC="#lock_No#">
			<BR><B>LOCKED BY<BR>#Check_Lock.Full_Name#</B>
		<CFELSE>
		<!----- not locked by anyone --->
			<CFSET PM_IS_LOCKED = 0>
			<INPUT TYPE="Image" SRC="#lock_No#" ONMOUSEOVER="this.src='#lock_Yes#';" ONMOUSEOUT="this.src='#lock_No#';">
			<div align="center"><B>[<font color="red">Click to Edit</font>]</B></div>
		</CFIF>	
		<INPUT TYPE="Hidden" NAME="PRESENT_LOCK_STATUS" VALUE="#PM_IS_LOCKED#">
		<INPUT TYPE="Hidden" NAME="FID" VALUE="#FORM.FID#">	
	</FORM>
	</CFIF>
	</CFOUTPUT>
	</CFSAVECONTENT>
</CFIF>