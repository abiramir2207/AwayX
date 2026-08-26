<!---------------------------------------------------------------------------------------------------------------------
   Template:\components\settings\InternalSettings.cfc
   Date:     2015 January
   Author:   Chris Nguyen
   Purpose:  Return internal settings (classic & 2015)

   Remarks:
         - Use this compact InternalSettings.cfc instead of ApplicationSettings.cfc to reduce memory usage for
           better performance
---------------------------------------------------------------------------------------------------------------------->

<cfcomponent output="false">

    <!--- 2015 jan 23 - chrisn: introduced new _SETTINGS table with multiple rows feature --->
    <cffunction name="get_Setting" access="public" output="false" hint="Return interal setting value.">
		<cfargument name="setting_input_name" required="true" type="string" hint="this is the setting input name in the database and also in the form">
		<cfargument name="missing_not_allowed" required="false" default="true" hint="if true generate error when setting is missing">

		<!--- application.util not available on login page - Sharon ran into this scenario in 2018 Mar 29 --->
		<cfif not StructKeyExists(application, 'util')>
			<cflock timeout="30" scope="Application" type="exclusive" throwontimeout="true">
			  <cfif not StructKeyExists(application, 'util')>
				  <cfset application.util = createObject("component", "components.UtilManager").init()>
			  </cfif>
			</cflock>
		</cfif>

		<cfreturn application.util.query.get_Setting(arguments.setting_input_name, arguments.missing_not_allowed)>
    </cffunction>

</cfcomponent>