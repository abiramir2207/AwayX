<!---
Name: 			SettingController.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description: 	I am the controller blueprint file for the Setting Entity. 
Date Created:	03/29/2006
--->

<cfcomponent displayname="Setting" hint="I am the Event blueprint." extends="BSA.controller.Controller">

	<cffunction name="init" access="public" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE/////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	<cfinclude template="methods/get/setting_getApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/get/setting_getCategoryApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/get/setting_getCategoryApplicationDatas.cfm" />
	
	<!---//////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	<cfinclude template="methods/save/setting_saveApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/save/setting_saveApplicationDatas.cfm" />
	
</cfcomponent>