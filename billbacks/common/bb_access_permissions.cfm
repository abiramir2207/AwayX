<!------bb_access_permissions.cfm----->
<!------
Include this file to get the access permissions of the user

<CFINCLUDE TEMPLATE="/billbacks/common/bb_access_permissions.cfm">

The permissions can be accessed as follows 

#ACCESS_PERMISSION_BB_CREATE#
#ACCESS_PERMISSION_BB_VIEW_DEVIATION#
#ACCESS_PERMISSION_BB_APPROVE#
#ACCESS_PERMISSION_BB_APPROVE_AMOUNT#
#ACCESS_PERMISSION_BB_APPROVE_CRITICAL#
#ACCESS_PERMISSION_BB_APPROVE_CRITICAL_AMOUNT#

------->

<cfset useLakebaseForGet_Access_Permissions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_profiles_settings")>
<cfif useLakebaseForGet_Access_Permissions>
	<cftry>
		<cfset Get_Access_Permissions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_profiles_settings", {
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"deleted" = "eq.0",
				"select" = "bb_create,bb_view_deviation,bb_approve,bb_approve_amount,bb_approve_critical,bb_approve_critical_amount"
			}), "bb_create,bb_view_deviation,bb_approve,bb_approve_amount,bb_approve_critical,bb_approve_critical_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Access_Permissions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Access_Permissions>
<CFQUERY NAME="Get_Access_Permissions" DATASOURCE="#Application.Datasource#">
	SELECT	BB_Create, BB_View_Deviation, 
			BB_Approve, BB_Approve_Amount,
			BB_Approve_Critical, BB_Approve_Critical_Amount
	FROM	BB_Profiles_Settings
	WHERE	
			Profiles_ID = #request.AccessStructure.Profiles_ID#
			AND
			Deleted = 0
</CFQUERY>
</cfif>

<CFPARAM NAME="ACCESS_PERMISSION_BB_CREATE" 					DEFAULT=0>
<CFPARAM NAME="ACCESS_PERMISSION_BB_VIEW_DEVIATION" 			DEFAULT=0>
<CFPARAM NAME="ACCESS_PERMISSION_BB_APPROVE" 					DEFAULT=0>
<CFPARAM NAME="ACCESS_PERMISSION_BB_APPROVE_AMOUNT" 			DEFAULT=0>
<CFPARAM NAME="ACCESS_PERMISSION_BB_APPROVE_CRITICAL" 			DEFAULT=0>
<CFPARAM NAME="ACCESS_PERMISSION_BB_APPROVE_CRITICAL_AMOUNT" 	DEFAULT=0>

<CFIF Get_Access_Permissions.recordCount GT 0>
	<CFSET ACCESS_PERMISSION_BB_CREATE 					= Get_Access_Permissions.BB_Create>
	<CFSET ACCESS_PERMISSION_BB_VIEW_DEVIATION 			= Get_Access_Permissions.BB_View_Deviation>
	<CFSET ACCESS_PERMISSION_BB_APPROVE 				= Get_Access_Permissions.BB_Approve>
	<CFSET ACCESS_PERMISSION_BB_APPROVE_AMOUNT 			= Get_Access_Permissions.BB_Approve_Amount>
	<CFSET ACCESS_PERMISSION_BB_APPROVE_CRITICAL 		= Get_Access_Permissions.BB_Approve_Critical>
	<CFSET ACCESS_PERMISSION_BB_APPROVE_CRITICAL_AMOUNT = Get_Access_Permissions.BB_Approve_Critical_Amount>

	<CFIF NOT ACCESS_PERMISSION_BB_APPROVE>
		<CFSET ACCESS_PERMISSION_BB_APPROVE_AMOUNT = 0>
	</CFIF>
	
	<CFIF NOT ACCESS_PERMISSION_BB_APPROVE_CRITICAL>
		<CFSET ACCESS_PERMISSION_BB_APPROVE_CRITICAL_AMOUNT = 0>
	</CFIF>
</CFIF>
