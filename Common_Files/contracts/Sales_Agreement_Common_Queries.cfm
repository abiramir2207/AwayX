<CFIF isdefined("request.AccessStructure.name_first")>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</CFIF>
<cfparam name="EncryptedCID" default="">
<cfparam name="CSL_Export_Sales_Agreement_ID" default="">

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT	*
	FROM 	Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID = '#CSL_Export_Sales_Agreement_ID#'
</CFQUERY>

<CFIF isdefined("request.AccessStructure.name_first")>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>

<CFIF CSL_Export_Sales_Agreement_ID NEQ "">
<CF_CRYP type="en" string="#CSL_Export_Sales_Agreement_ID#" key="#request.key#" return="Enc">
<CFSET EncryptedCID = Enc.value>
</CFIF>


<!--- Flag This Contract As Locked As Long As This User Is Using It --->
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
	SELECT Sales_Agreement_Is_Locked, Sales_Agreement_Locked_By_User_ID, Export_Sales_Agreement_ID
	FROM Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID ='#CSLGetContractInfo.Export_Sales_Agreement_ID#'
</cfquery>
<!--- END Flag This Contract As Locked As Long As This User Is Using It --->

<!---  check position tree for  user access--->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<CFSET DisAllowAccessBasedOnPosition = 0>
<cfif CSLGetContractInfo.Creating_User_Position_ID NEQ "">
	<cfquery name="qGetMyPositionsListSameAsCreating_User_Position_ID" datasource="#application.datasource#">
		#GP_Position_List_From_My_Position_Down#
		AND Below_User_Positions_ID = #CSLGetContractInfo.Creating_User_Position_ID#
	</cfquery>
	<CFIF qGetMyPositionsListSameAsCreating_User_Position_ID.recordCount EQ 0>
		<CFSET DisAllowAccessBasedOnPosition = 1>
	</CFIF>
</cfif>
</CFIF>
<!--- decide if this program is a revision of an existing one --->
<CFSET Program_Is_A_Revision = 0>
<CFIF len(trim(CSLGetContractInfo.Parent_Revised_Export_Sales_Agreement_ID)) NEQ 0 AND len(trim(CSLGetContractInfo.Revision_of_Export_Sales_Agreement_ID)) NEQ 0>
	<CFSET Program_Is_A_Revision = 1>
</CFIF>
<CFIF isdefined("request.AccessStructure.name_first")>
	<CFSET DisAllowAccessBasedOnLockStatus = 0>
	<CFSET TabsAreActive = 0>
	
	<!------ Check Access Profile ----->
	<cfset DisAllowAccessBasedOnProfile = 0>
	<cfset DisAllowApproveBasedOnProfile = 0>
	<CFIF Get_Profile_Settings.Create_Export_Agreements NEQ 1 AND Get_Profile_Settings.Create_Approve_Export_Agreements NEQ 1>
		<cfset DisAllowAccessBasedOnProfile = 1>
	<CFELSE>
		<cfif NOT isDefined("appSettings")>
			<!---Gets application settings--->
			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset appSettings = genSettingsManager.get()>
		</cfif>
	</CFIF>
	<CFIF Get_Profile_Settings.Approve_Export_Agreements NEQ 1  AND Get_Profile_Settings.Create_Approve_Export_Agreements NEQ 1>
		<cfset DisAllowApproveBasedOnProfile = 1>
	</CFIF>
</CFIF>