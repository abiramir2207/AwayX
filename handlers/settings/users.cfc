<cfcomponent name="users" extends="coldbox.system.eventhandler" output="false">

	<!--- This init format is mandatory if you are writing init code else is optional, 
	      include the super.init(arguments.controller). --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<!--- Any constructor code here --->
		<cfset variables.userObj = createObject("component", "#getSetting('ModelLocation')#.user.ajaxUserManager").init(application.datasource) />
		<cfset variables.authoritySequenceObj = createObject('component', '#getSetting('ModelLocation')#.user.AuthoritySequenceManager').init(application.datasource) />
		<cfreturn this />
	</cffunction>
	
   <cffunction name="dspUsers" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfset var rc = Event.getCollection() />
		<cfset Event.showdebugPanel( false ) />
		
		<cfset rc.userPositionList = variables.userObj.populateUsrPosSelect() />
		<cfset rc.userProfileList = variables.userObj.populateProfileSelect() />
		<cfset rc.authSequence = variables.authoritySequenceObj.getAll() />
		<cfset Event.setView("settings/list_users") />
	</cffunction>
    
	<cffunction name="autoSuggest" access="public" returntype="any" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- Do Your Logic Here to prepare a view --->
		<cfset var rc = Event.getCollection() />
		<cfset rc.userList = variables.userObj.autoCompleteData(Event.getValue('q')) />
        <!--- Append Ajax View to display dropdown --->
		<cfset event.setView("settings/vAjaxcall",true) />
	</cffunction>
	
	<cffunction name="listUsers" access="public" returntype="any" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" />
		<!--- Do Your Logic Here to prepare a view --->
		<cfset var sql_sort_by = Event.getValue("SQL_Sort_By") />
		<cfset var searchstring = Event.getValue("searchstring") />
		<cfset var type = Event.getValue("type") />
		<cfset var position = Event.getValue("position") />
		<cfset var position_id = Event.getValue("positionId") />
		<cfset var profile_id = Event.getValue("profile_id") />
		<cfset var authoritySequence = Event.getValue("authoritySequence") />
		<!--- <cfset var appsettings = getColdboxOCM().get("appSettings") /> --->
		
		<cfset var users = 
				   variables.userObj.getusersList(
				   	                 sql_sort_by,searchstring,type,position,
				   	                 position_id,profile_id,authoritySequence) />

		<cfreturn users />
	</cffunction>
	
	<cffunction name="printUsers" access="public" returntype="any" output="false">
	  <cfargument name="Event" type="coldbox.system.beans.requestContext" required="true" />
	  <cfset var rc = Event.getCollection() />
	  <cfset var sql_sort_by =  "name_last" />
	  <cfset var searchstring = "" />
	  <cfset var type = "0" />
	  <cfset var position = "P" />
	  <cfset var position_id = "0" />
	  <cfset var profile_id = "0" />
	  <cfset var authoritySequence = "0" />
	  <cfset var appsettings = getColdboxOCM().get("appSettings") />
	  <cfset rc.userList = variables.userObj.getusersList(
				   	                 sql_sort_by,searchstring,type,position,
				   	                 position_id,profile_id,authoritySequence,appsettings) />
	  

	  
	  <cfset Event.setView('settings/print_users') />
	</cffunction>
	
	
</cfcomponent>