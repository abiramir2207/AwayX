<CFIF isdefined("request.AccessStructure.name_first")>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</CFIF>
<cfparam name="EncryptedCID" default="">
<cfparam name="CSL_Export_Sales_Agreement_ID" default="">

<cfset useLakebaseForCSLGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForCSLGetContractInfo>
	<cftry>
		<cfset CSLGetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#CSL_Export_Sales_Agreement_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCSLGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCSLGetContractInfo>
<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT	*
	FROM 	Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID = '#CSL_Export_Sales_Agreement_ID#'
</CFQUERY>
</cfif>

<CFIF isdefined("request.AccessStructure.name_first")>
<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>

<CFIF CSL_Export_Sales_Agreement_ID NEQ "">
<CF_CRYP type="en" string="#CSL_Export_Sales_Agreement_ID#" key="#request.key#" return="Enc">
<CFSET EncryptedCID = Enc.value>
</CFIF>


<!--- Flag This Contract As Locked As Long As This User Is Using It --->
<cfset useLakebaseForisContractCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForisContractCurrentlyLocked>
	<cftry>
		<cfset isContractCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#CSLGetContractInfo.Export_Sales_Agreement_ID#",
				"select" = "sales_agreement_is_locked,sales_agreement_locked_by_user_id,export_sales_agreement_id"
			}), "sales_agreement_is_locked,sales_agreement_locked_by_user_id,export_sales_agreement_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisContractCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisContractCurrentlyLocked>
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
	SELECT Sales_Agreement_Is_Locked, Sales_Agreement_Locked_By_User_ID, Export_Sales_Agreement_ID
	FROM Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID ='#CSLGetContractInfo.Export_Sales_Agreement_ID#'
</cfquery>
</cfif>
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