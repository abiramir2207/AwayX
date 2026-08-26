<cfcomponent hint="User Profile">

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="settings" output="false">
		<cfargument name="columns" required="false" default="">
		<cfargument name="profileId" required="false" type="numeric" default="#request.AccessStructure.Profiles_ID#"/>

		<cfset local.result   = {}>
		<cfset local.settings = getProfileSettings( arguments.profileId )>

		<cfif arguments.columns eq "">
			<cfreturn local.settings>
		</cfif>

		<cfloop list="#local.settings.columnList#" index="local.column">
			<cfif local.column contains arguments.columns>
				<cfset local.result[ local.column ] = local.settings [ local.column ]>
			</cfif>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProfileSettings" output="false">
		<cfargument name="profileId" required="true" type="numeric" />
		<cfscript>
			if(structKeyExists( request, "_qGetUserProfile")){
				return Request._qGetUserProfile;
			}
		</cfscript>
		<cfquery name="local.qGetUserProfile" datasource="#application.datasource#">
			SELECT     	Profiles_Settings.*,
						BB_Profiles_Settings.BB_Create,
						BB_Profiles_Settings.BB_Delete,
						BB_Profiles_Settings.BB_View_Deviation,
						BB_Profiles_Settings.BB_Approve,
						BB_Profiles_Settings.BB_DevGrid_Expected,
						BB_Profiles_Settings.BB_DevGrid_ELT,
						BB_Profiles_Settings.BB_DevGrid_Claimed,
						BB_Profiles_Settings.BB_DevGrid_Selected,
						BB_Profiles_Settings.BB_Approve_Amount,
						BB_Profiles_Settings.BB_Tot_Approve_Amount,
						BB_Profiles_Settings.BB_Approve_Critical,
						BB_Profiles_Settings.BB_User_ID,
						BB_Profiles_Settings.BB_Updated_Date,
						BB_Profiles_Settings.Created_Date,
						BB_Profiles_Settings.BB_RFA_Agreed,
						BB_Profiles_Settings.BB_Pay_Req_Approval_Amount,
						BB_Profiles_Settings.Approve_Last_Date_To_Claim,
						BB_Profiles_Settings.BB_Reverse,
						BB_Profiles_Settings.Autopay_Reverse,
						BB_Profiles_Settings.BB_Apply_Rebate_Rates,
						BB_Profiles_Settings.BB_Allow_Vendor_Master_Search,
						BB_Profiles_Settings.Mass_Billback_Pay,
						BB_Profiles_Settings.BB_Apply_Pullback,
						BB_Profiles_Settings.BB_Apply_Pullback_Amount,
						BB_Profiles_Settings.BB_UnApply_Pullback,
						BB_Profiles_Settings.BB_Add_Program,
						BB_Profiles_Settings.BB_Volume_Override,
						BB_Profiles_Settings.BB_Rate_Override,
						BB_Profiles_Settings.Approve_BB_Beyond_Budget,
						BB_Profiles_Settings.BB_Search_By_Analyst,
						BB_Profiles_Settings.BB_Add_Payee_Any_Position,
						BB_Profiles_Settings.Credit_Memo_Amount,
						BB_Profiles_Settings.BB_Dev_Grid_Manual_Rate_Override_Check,
						BB_Profiles_Settings.BB_Mass_Approve,
						BB_Profiles_Settings.View_BB_CRA_Analysis_Report,
						BB_Profiles_Settings.Change_BB_Start_End_Date,
						BB_Profiles_Settings.BB_Reassign,
						BB_Profiles_Settings.Void_Credit_Request,
						BB_Profiles_Settings.Display_BB_EDI_Download,
						BB_Profiles_Settings.Display_BB_User_Download,
						BB_Profiles_Settings.Display_BB_III_Party_Download,
						BB_Profiles_Settings.Auto_Approve_Analysis,
						BB_Profiles_Settings.Allow_RFA_With_Default_Program,<!--- 61486 : Default program only when $'s equal to $0.00... --->
						BB_Profiles_Settings.BB_Display_Dist_Channel_Per_Program_Distributor, <!--- 
77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/12-Jun-2018 --->
						BB_Profiles_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount, <!--- 76536: BB Oper Location Level - dup check - Anand Rao/09-Aug-2018 --->
						BB_Profiles_Settings.View_Deviated_Items_Only_OnLoad,  <!--- 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->
						BB_Profiles_Settings.View_Count_Column_In_Deviation_Grid,
						Planner_Profiles_Settings.*,
						Deductions_Profiles_Settings.*,
						P.Profiles_Desc
						,BB_Profiles_Settings.Settlements
						,BB_Profiles_Settings.AQP_Max_Overspend
						,BB_Profiles_Settings.AQP_Available
			FROM        Profiles_Settings
			INNER JOIN Profiles P ON P.profiles_Id = Profiles_Settings.Profiles_id AND P.Deleted = 0
			LEFT JOIN BB_Profiles_Settings ON Profiles_Settings.Profiles_ID = BB_Profiles_Settings.Profiles_ID
			LEFT JOIN Deductions_Profiles_Settings ON Deductions_Profiles_Settings.Profiles_ID = Profiles_Settings.Profiles_ID
			LEFT JOIN Planner_Profiles_Settings ON Planner_Profiles_Settings.Profiles_ID = Profiles_Settings.Profiles_ID
			WHERE Profiles_Settings.Profiles_ID	=	<cfqueryparam value=#arguments.profileId#>
		</cfquery>

		<cfset Request._qGetUserProfile = local.qGetUserProfile>
		<cfreturn local.qGetUserProfile />
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getCusttypeProfileSettings" output="false" returntype="query">

		<cfargument name="profileId" required="true" type="numeric" />
		<cfargument name="Customer_Type" required="false" type="string" />
		<cfscript>
		 var qGetUserCustTypeProfile = '';
		</cfscript>
		<cfquery name="qGetUserCustTypeProfile" datasource="#application.datasource#">
			SELECT 	distinct
					ISNULL(Profile_Customer_Type_Settings.Profile_Customer_Type_Value,0) as Profile_Customer_Type_Value,
					Customer_Type.Customer_Type, dbo.Customer_Type.Customer_Type_ID, Customer_Type.Customer_Type_Desc
			FROM    Customer_Type
					LEFT JOIN	Profile_Customer_Type_Settings
					ON
					Profile_Customer_Type_Settings.Customer_Type_Id = Customer_Type.Customer_Type_ID
			AND 	Profile_Customer_Type_Settings.Profiles_Id = #arguments.profileId#
			WHERE	dbo.Customer_Type.Deleted = 0
			<CFIF isdefined("arguments.Customer_Type")>
			AND 	Customer_Type_Belong = '#arguments.Customer_Type#'
			</CFIF>
			ORDER BY dbo.Customer_Type.Customer_Type
		</cfquery>

		<cfreturn qGetUserCustTypeProfile />

	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProfileName" output="false">

		<cfargument name="profileId" required="true" type="numeric" />
		<cfscript>
		 	var sName = '';
			var qGtProfileName = '';
		</cfscript>

		<cfquery name="qGtProfileName" datasource="#application.datasource#">
			SELECT 	Profiles_Desc, Profiles_Short_Desc
			FROM    Profiles
			WHERE	Profiles_ID = #arguments.profileId#
		</cfquery>

		<cfset sName = qGtProfileName.Profiles_Desc>

		<cfreturn sName>

	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getUserSettingsPanel" output="false">
		<cfargument name="profileId" required="true" type="numeric" />
		<cfscript>
			var qGetSettings_Panel = '';
		</cfscript>
		<cfquery name="qGetSettings_Panel" datasource="#application.datasource#">
			SELECT Settings_Panel
			FROM    Profiles_Settings
			Where	Profiles_ID	=	#arguments.profileId#
		</cfquery>

		<cfreturn qGetSettings_Panel />
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getCreateViewBudgetSetting" output="false">
		<cfargument name="profileId" required="true" type="numeric" />

		<cfquery name="local.qGetCreateBudget" datasource="#application.datasource#">
			SELECT 	BB_Create AS Create_Budget
			  FROM 	BB_Profiles_Settings         <!--- 47143 --->
			 WHERE	Profiles_ID	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.profileId#">
		</cfquery>

		<cfreturn local.qGetCreateBudget />
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------->

	<cffunction name="profilesList" output="false" hint="Returns a list of profile IDs that meet the selection criteria.">
		<cfargument name="selection_criteria" required="false" default="">
		<cfargument name="profile_category"   required="false" default="">

		<cfquery name="local.Profiles" datasource="#application.datasource#">
			SELECT 	Profiles_ID
			  FROM 	<cfif arguments.profile_category eq "planner">
			  			Planner_Profiles_Settings
			  		<cfelseif arguments.profile_category eq "billback">
			  			BB_Profiles_Settings
			  		<cfelseif arguments.profile_category eq "deduction">
			  			Deductions_Profiles_Settings
			  		<cfelse>
			  			Profiles_Settings
			  		</cfif>
			 WHERE	Deleted = 0
			 		<cfif arguments.selection_criteria neq "">
			 			AND ( #arguments.selection_criteria# )
			 		</cfif>
		</cfquery>

		<cfreturn valueList( local.Profiles.profiles_ID )>
	</cffunction>

</cfcomponent>