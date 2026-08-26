<!-----------------------------------------------------------------------------

FILE NAME:		ProductManager.cfc
DESCRIPTION:	General functions related to products
CREATED BY:		Deepa Kunnath
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
*******************************************************************************
<Add any modifications to this file here>
*******************************************************************************
 
------------------------------------------------------------------------------>

<cfcomponent displayname="ProductManager" hint="General functions related to products">

  <!------------------------------------------------------------------------- 
    This function returns all the Buying Groups
  --------------------------------------------------------------------------->
	<cffunction name="getAllTypeCodes" output="false" access="remote" returntype="Query">
		<cfquery name="qGetAllTypeCodes" datasource="#application.datasource#" <!---cachedwithin="#APPLICATION.masterDataCacheSpan#"--->>
			SELECT 	*
			FROM 	Type_Code_Desc
			WHERE 	Deleted = 0
			AND 	Type_Code_Desc <> ''
			ORDER BY Type_Code_Desc
		</cfquery>
		<cfreturn qGetAllTypeCodes />
	</cffunction> 
	
</cfcomponent>