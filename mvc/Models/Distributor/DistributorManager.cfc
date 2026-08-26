<!-----------------------------------------------------------------------------

FILE NAME:		DistributorManager.cfc
DESCRIPTION:	General functions related to distributors
CREATED BY:		Deepa Kunnath
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
*******************************************************************************
<Add any modifications to this file here>
*******************************************************************************
 
------------------------------------------------------------------------------>

<cfcomponent displayname="DistributorManager" hint="General functions related to distributors">

  <!------------------------------------------------------------------------- 
    This function returns all the Buying Groups
  --------------------------------------------------------------------------->
	<cffunction name="getAllBuyingGroups" output="false" access="remote" returntype="Query">
		<cfquery name="qGetAllBuyingGroups" datasource="#application.datasource#" <!---cachedwithin="#APPLICATION.masterDataCacheSpan#"--->>
			SELECT 	*
			FROM 	Distributor_Buying_Groups
			WHERE 	Deleted = 0
			AND		Active_Code = 'A'
			AND 	Buying_Group_Name <> ''
			ORDER BY Buying_Group_Name
		</cfquery>
		<cfreturn qgetallbuyinggroups />
	</cffunction> 
	
  <!--------------------------------------------------------------------------- 
    This function returns all the Family Names
  ----------------------------------------------------------------------------->
	<cffunction name="getAllFamilyNames" output="false" access="remote" returntype="Query">
		<cfquery name="qGetAllFamilyNames" datasource="#application.datasource#" <!---cachedwithin="#APPLICATION.masterDataCacheSpan#"--->>
			SELECT 	*
			FROM 	Distributor_Family
			WHERE 	Deleted = 0
			AND 	Family_Name <> ''
			ORDER BY Family_Name
		</cfquery>
		<cfreturn qgetallfamilynames />
	</cffunction> 

</cfcomponent>