
<!------ sales_agreement_get_user_position_contact.cfm ----->
<cfparam name="CSL_Export_Sales_Agreement_ID" default="0">

<cfparam name="CheckApprovalAccess" 	default="0">
				
<cfquery name="userPositionContactInfo" datasource="#application.datasource#">
	SELECT distinct  User_Positions.User_Positions_ID, User_Positions.Position_Label, ltrim(rtrim(_Users.User_Email)) User_Email, Profiles_Settings.Program_Scorecard_Restrict_Created_By
	FROM       	_Users 
				INNER JOIN	User_Position_Holders 
				ON _Users.User_ID = User_Position_Holders.User_ID 
				<!---BJF D10073 -- app setting to only email primary, vs primary and secondary positions --->
				<cfif appSettings.getsendsecondaryemail() EQ 0>
				AND User_Position_Holders.User_Position_Type <> 'S'
				</cfif>
				INNER JOIN	User_Positions 
				ON User_Position_Holders.User_Positions_ID = User_Positions.User_Positions_ID
				<!---Checks profile permissions--->
				INNER JOIN Profiles_Settings 
				ON Profiles_Settings.Profiles_ID = _Users.Profiles_ID
	WHERE     
				User_Positions.Deleted = 0
				AND User_Position_Holders.deleted = 0
				AND _Users.Deleted = 0
				AND User_Positions.User_Positions_ID = <cfqueryparam value="#RFAUserPositionID#" cfsqltype="CF_SQL_INTEGER">
			 <!---This checks to make sure the profile can see programs for other users in the position, or is the creating user
				AND (Profiles_Settings.Program_Scorecard_Restrict_Created_By = 0 <Cfif isDefined("getThisProgramsStatusEmail.Creator_ID")>OR _Users.User_ID =  '#getThisProgramsStatusEmail.Creator_ID#'</CFIF>) --->
			<cfif CheckApprovalAccess EQ 1>
			<!---AND	Profiles_Settings.Cont_Prog_View_Margins = 1--->
			AND Profiles_Settings.Approve_Export_Agreements = 1
			AND _Users.Profiles_ID != <cfqueryparam value="#RFAuserProfile#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
</cfquery>

<cfset CheckApprovalAccess = 0 />
