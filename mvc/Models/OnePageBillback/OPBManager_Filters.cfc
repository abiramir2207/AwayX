<cfcomponent>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

	<cffunction name="getAllComponents" output="false" returntype="query" hint="This Function will return all (F,R,L,G) Active compoents">
		<cfquery name="qGetAllComponents" datasource="#application.datasource#">
			SELECT 'R_'+cast(Program_Rebates_Component_Name_ID AS varchar) AS Component_ID, 'Rebate : '+Program_Rebates_Component_Name  AS Component_Name
			FROM Program_Rebates_Component_Name PRCN
			WHERE PRCN.Deleted = 0
			AND PRCN.Active = 1

			UNION

			SELECT 'F_'+cast(Program_Fixed_Component_Name_ID AS varchar) AS Component_ID, 'Fixed : '+Program_Fixed_Component_Name AS Component_Name
			FROM Program_Fixed_Component_Name PFCN
			WHERE PFCN.Deleted = 0
			AND PFCN.Active = 1

			UNION

			SELECT 'G_'+cast(Program_Growth_Components_Name_ID AS varchar) AS Component_ID, 'Growth : '+Program_Growth_Components_Name AS Component_Name
			FROM Program_Growth_Components_Name PGCN
			WHERE PGCN.Deleted = 0
			AND PGCN.Active = 1

			UNION

			SELECT 'L_'+cast(Program_Lump_sum_Name_ID AS varchar) AS Component_ID, 'LumpSum : '+Program_Lump_sum_Name AS Component_Name
			FROM Program_Lump_Sum_Name PLCN
			WHERE PLCN.Deleted = 0
			AND PLCN.Active = 1
			ORDER BY Component_Name
		</cfquery>
		<cfreturn qGetAllComponents />
	</cffunction>

	<cffunction name="getClosingMethods" output="false" returntype="query">
		<cfquery name="qGetClosingMethods" datasource="#application.datasource#">
			SELECT BCM.iBillback_Closing_Method_ID, BCM.vchBillback_Closing_Method_Desc, BPCM.Billback_Closing_Method_ID, Vendor_Required
			FROM  Billback_Closing_Methods  AS BCM
			INNER JOIN BB_Profile_Closing_Methods AS BPCM
			ON BCM.iBillback_Closing_Method_ID = BPCM.Billback_Closing_Method_ID
			AND BPCM.Profile_ID = #request.accessstructure.profiles_id#
			AND BPCM.Deleted = 0
			WHERE BCM.Deleted = 0
			AND BCM.bEnabled = 1
		</cfquery>
		<cfreturn qGetClosingMethods />
	</cffunction>

	<cffunction name="getDDReasonCode" output="false" returntype="query">
		<cfquery name="qGetDDReasonCodes" datasource="#application.datasource#">
			SELECT DD_Reason_Code_ID, DD_Reason_Code_Description
			FROM DD_Reason_Code
			WHERE Deleted = 0
		</cfquery>
		<cfreturn qGetDDReasonCodes />
	</cffunction>

	<cffunction name="getDDStatus" output="false" returntype="query">
		<CFQUERY NAME="qryGetDDStatus" DATASOURCE="#application.datasource#">
			SELECT	distinct DD_Status_ID, DD_Status_Description
			FROM 	DD_Status
			WHERE Deleted = 0
			AND DD_Status_ID NOT IN(4,5,6,7,8,9)
			Order By DD_Status_ID
		</CFQUERY>
		<cfreturn qryGetDDStatus />
	</cffunction>

	<cffunction name="getDDAnalysts" output="false" returntype="query">
		<CFQUERY NAME="Get_Analyst" datasource="#application.datasource#">
				SELECT U.user_id , U.Name_First+' '+U.Name_Last AS Name
				FROM DD_Analyst DA
				INNER JOIN _Users U
				ON U.User_ID = DA.Analyst_User_ID
				WHERE DA.Deleted = 0
		</CFQUERY>
		<cfreturn Get_Analyst>
	</cffunction>

</cfcomponent>