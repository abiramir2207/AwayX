<!---
Name: 			SettingDatabase.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description: 	I am the database interface for Setting. 
Date Created:	03/30/2006
--->

<cfcomponent displayname="SettingDatabase" hint="I am the database interface for Setting." extends="BSA.database.Database">

	<cffunction name="init" access="public" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////DELETE///////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////EXECUTE//////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////INSERT///////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////SELECT///////////////////////////////////////////////--->
	<cfinclude template="methods/select/setting_selectApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/select/setting_selectCategoryApplicationDatas.cfm" />
	
	<!---//////////////////////////////////////////////////////UPDATE///////////////////////////////////////////////--->
	<cfinclude template="methods/update/setting_updateApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/update/setting_updateApplicationDatas.cfm" />
	
</cfcomponent>