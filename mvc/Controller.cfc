<!--- 
FILE: 		BA Application - Controller Component 	
FILENAME:   Controller.cfc 				
CREATED:  	07/01/2008 - Brad Lee MMCP/ACI
EDITED:   	03/16/2009 - Brad Lee MMCP/ACI [MVC v11]

FUNCTIONALITY: 
- This is the set of instructions that ColdFusion uses to assemble the BA Controller object.			
- The BA Controller object is THE controller for BA. --->						

<!--- COLDFUSION COMPONENT: Controller (Only the Controller extends main) this MUST be a constant value[] --->
<cfcomponent displayname="Controller" extends="mvc.main" hint="I am in charge of all addition, manipulation, retrieval, and removal of data to and from the BA business logic layer.">

	<!--- Set the initialization flag to "False" --->
	<cfparam name="this.bObjectInitialized" type="boolean" default=0>

	<!--- Set up the object skeleton --->
    <cfscript>
        // application.applicationname & 
        structInsert(this, 	"objName", 				uCase(application.applicationName) & " Application Controller");
        structInsert(this, 	"objDateTimeCreated", 	createODBCDateTime(now()));
        structInsert(this, 	"objDirectory",   		application.stMvcAppInfo.webrootMapping & "components/mvc");
        structInsert(this, 	"objParentObject",   	"Application");
        structInsert(this, 	"objParentUserID",   	"I am a Top Level Object. I am ALWAYS available but my number is unListed!");
        structInsert(this, 	"stObjectInfo",   		structNew(),true);

        this.stObjectInfo.componentPath				= application.stMvcAppInfo.componentPath;
        this.stObjectInfo.lockTimeoutSeconds		= application.stMvcAppInfo.lockTimeoutSeconds;
        this.stObjectInfo.name 						= "I am the " & Ucase(application.applicationName) & " Application CONTROLLER Object";
        this.stObjectInfo.description 				= "I govern all VIEW requests for the " & Ucase(application.applicationName) & " Application and decide whether to bring a Model object to life.";
        
        structInsert(this,	"bObjectInitialized", 	1,true);
    </cfscript>

    <!--- ::::::::::::::::::::::::::::::::::::::::::
    ::::::::: Controller Methods in alpha  :::::::::
    ::::::::::::::::::::::::::::::::: [ begin ] --->
    
    <!--- 3 methods as of 3/16/09 --->

    <!--- Controller [legacy General] METHOD: getApplicationPath() FUNCTIONALITY: I get the application local path. [begin] --->
    <cffunction name="getApplicationPath" access="public" returntype="string" output="no" hint="I get the application local path." displayname="Controller > getApplicationPath(), [aka as get_Application_Path() in General_Functions.cfc]">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <cfargument name="webrootFolderName" type="string" default="#application.stMvcAppInfo.webrootFolderName#" required="false"> 

		<!--- We MUST var all variables local to method! --->
        <cfscript>
            var var_appPath = "";
            var_appPath = createObject("component","components.general.General_Functions").Get_Application_Path(arguments.webrootFolderName);
        </cfscript>

        <!--- Return the final container to the caller (NO trailing slash) --->
        <cfreturn var_appPath/>
        
    </cffunction>
    <!--- Controller [legacy General] METHOD: getApplicationPath() FUNCTIONALITY: I get the application local path. [end] --->

    <!--- Controller [New] METHOD: selectAnyData() FUNCTIONALITY: I select any data from the db. [begin] --->
    <cffunction name="selectAnyData" access="public" returntype="query" output="no" hint="I select data from a specified table (optionally filtered) (optionally sorted)." displayname="Controller > selectAnyData()">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <cfargument name="table_name" 		required="true" 	type="string" 	hint="DB table name - required">
        <cfargument name="select_clause" 	required="true" 	type="string"	hint="SQL select statement - required">
        <cfargument name="where_clause" 	required="false" 	type="string"	hint="SQL WHERE clause - optional" default="">
        <cfargument name="order_by_clause" 	required="false" 	type="string"	hint="SQL ORDER BY clause - optional" default="">
        
        <!--- We MUST var all variables local to method! --->
        <cfset var var_qAnyData	= queryNew("col")>
        
        <cfquery name="var_qAnyData" datasource="#application.stMvcAppInfo.dsn#">
            SELECT 		#arguments.select_clause#
            FROM		#arguments.table_name#
            WHERE		1=1
            <cfif len(trim(arguments.where_clause))>
                AND		#arguments.where_clause#
            </cfif>
            <cfif len(trim(arguments.order_by_clause))>
                ORDER BY 	#arguments.order_by_clause#
            </cfif>
        </cfquery>
            
        <!--- Return the final container to the caller --->
        <cfreturn var_qAnyData>
        
    </cffunction>
    <!--- Controller [New] METHOD: selectAnyData() FUNCTIONALITY: I select any data from the db. [end] --->
    
    <!--- Controller [New] METHOD: selectAnyTableColumns() FUNCTIONALITY: I select columns from any table in the db. [begin] --->
    <cffunction name="selectAnyTableColumns" access="public" returntype="string" output="no" hint="I select columns from any table in the db." displayname="Controller > selectAnyTableColumns()">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <cfargument name="table_name" 		required="true" 	type="string" 	hint="DB table name - required">
    
    	<!--- We MUST var all variables local to method! --->
        <cfset var var_qColumns		= queryNew('cols')>
        <cfset var var_lsColumns	= ''>
        
        <cfquery name="var_qColumns" datasource="#application.stMvcAppInfo.dsn#">
            SELECT 		*
            FROM		#arguments.table_name#
            WHERE		1<>1
        </cfquery>
        
        <cfset var_lsColumns = var_qColumns.columnList>
            
        <!--- Return the final container to the caller --->
        <cfreturn var_lsColumns>
        
    </cffunction>
    <!--- Controller [New] METHOD: selectAnyTableColumns() FUNCTIONALITY: I select columns from any table in the db. [end] --->

    <!--- ::::::::::::::::::::::::::::::::::::::::::
    ::::::::: Controller Methods in alpha  :::::::::
    ::::::::::::::::::::::::::::::::::: [ end ] --->

</cfcomponent>