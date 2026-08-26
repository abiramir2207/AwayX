<!---
Name: 			ApplicationSetting.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description: 	I am the ApplicationSetting blueprint. 
Date Created:	04/10/2006
--->

<cfcomponent displayname="Setting" hint="I am the ApplicationSetting blueprint." extends="BSA.model.setting.Setting">

	<cffunction name="init" access="public" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<!---//////////////////////////////////////////////////////BOOLEAN///////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////DELETE////////////////////////////////////////////--->
	
	<!---//////////////////////////////////////////////////////GET///////////////////////////////////////////////--->
	<cfinclude template="methods/get/setting_getApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/get/setting_getCategoryApplicationDatas.cfm" />
	
	<!---/////////////////////////////////////////////////////SAVE///////////////////////////////////////////////--->
	<cfinclude template="methods/save/setting_saveApplicationCategoryDatas.cfm" />
	<cfinclude template="methods/save/setting_saveApplicationDatas.cfm" />
	
</cfcomponent>