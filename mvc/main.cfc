<!--- 
FILE: 		Main Object Component for BA applications	
FILENAME:   main.cfc										
CREATED:  	5/09/2008 - Brad Lee MMCP/ACI
EDITED:		03/18/2009 - RBL [MVC v10]

FUNCTIONALITY: 
- Creates all base-level OBJECT-related functions extended ONLY by oController.		

NOTE: 
I am NOT an actual instantiated object (I am never alive). I am THE omnipresent included base-class containing 		
methods required by The Controller for the BA universe. (Only the Controller extends main)		
--->

<!--- Begin defining the component --->
<cfcomponent displayname="main" hint="I am the ultimate parent OBJECT blueprint (uninstantiated) for the entire universe of BA objects.">

	<!--- :::::::::::::::::::::::::
	:::: main OBJECT Methods in alpha ::::
	::::: [create|kill|exist] :--->
    
    <!--- 11 OBJECT methods as of 3/16/09 --->
    
    <!--- main Private METHOD: appendCreatedObjectArray() FUNCTIONALITY: I append the Objects Array of Legacy & Model user-created objects. [begin] --->
    <cffunction name="appendCreatedObjectArray" access="private" output="no" hint="I append the Objects Array of Legacy & Model user-created objects." returntype="void" displayname="main > appendCreatedObjectArray()">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- 1.) --->
        <cfargument name="object_cfcName" 			type="string" required="true" 	hint="full CFC name without suffix">

		<cfscript>
			var var_stCreatedObject = structNew();
		
			if (isDefined("application.stMVCAppInfo.aCreatedObjects"))
			{
				// create our structure for this created object
				structInsert(var_stCreatedObject,"objectName",trim(arguments.object_cfcName),true);
				
				if (isDefined("session.stMVCUserInfo.User_ID"))
				{
					structInsert(var_stCreatedObject,"userID",session.stMVCUserInfo.User_ID,true);
				}
				else
				{
					structInsert(var_stCreatedObject,"userID",application.applicationName,true);
				}
				structInsert(var_stCreatedObject,"timeStamp",createODBCDateTime(now()),true);

				// append the structure to our Objects Array of Legacy & Model user-created objects that SHOULD ALWAYS Exist...
				arrayAppend(application.stMVCAppInfo.aCreatedObjects,var_stCreatedObject);
			}
        </cfscript>
    
    </cffunction>
    <!--- main Private METHOD: appendCreatedObjectArray() FUNCTIONALITY: I append the Objects Array of Legacy & Model user-created objects. [end] --->
    
    <!--- main Private METHOD: appendKilledObjectArray() FUNCTIONALITY: I append the Objects Array of Legacy & Model application-killed objects. [begin] --->
    <cffunction name="appendKilledObjectArray" access="private" output="no" hint="I append the Objects Array of Legacy & Model application-killed objects." returntype="void" displayname="main > appendKilledObjectArray()">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- 1.) --->
        <cfargument name="object_cfcName" 			type="string" 	required="true" 	hint="full CFC name without suffix">
        <!--- 2.) --->
        <cfargument name="JVMMemoryPercentageUsed" 	type="numeric" 	required="false" 	hint="only known within onSessionEnd()" default="0">

		<cfscript>
			var var_stKilledObject = structNew();
			
			if (isDefined("application.stMVCAppInfo.aKilledObjects"))
			{
				// create our structure for this killed object
				structInsert(var_stKilledObject,"objectName",trim(arguments.object_cfcName),true);
				
				if (isDefined("session.stMVCUserInfo.User_ID"))
				{
					structInsert(var_stKilledObject,"userID",session.stMVCUserInfo.User_ID,true);
				}
				else
				{
					structInsert(var_stKilledObject,"userID",application.applicationName,true);
				}
				structInsert(var_stKilledObject,"timeStamp",createODBCDateTime(now()),true);
				structInsert(var_stKilledObject,"JVMMemoryPercentageUsed",arguments.JVMMemoryPercentageUsed,true);

				// append the structure to our Objects Array of Legacy & Model application-killed objects that SHOULD ALWAYS Exist...
				arrayAppend(application.stMVCAppInfo.aKilledObjects,var_stKilledObject);
			}
        </cfscript>
    
    </cffunction>
    <!--- main Private METHOD: appendKilledObjectArray() FUNCTIONALITY: I append the Objects Array of Legacy & Model application-killed objects. [end] --->
    
    <!--- main Public METHOD: getObject() FUNCTIONALITY: I return a Legacy OR Model Object, bringing the CFC Object to life as necessary (insert into application scope's structure) aka [components.*]. [begin] --->
    <cffunction name="getObject" access="public" output="no" hint="I return a Legacy OR Model Object, bringing the CFC Object to life as necessary (insert into application scope's structure) aka [components.*]." returntype="any" displayname="main > getObject()">
    
    	<!--- SAMPLE CALLS [begin]
		<cfinvoke component="#application.oController#"
			method="getObject"
			path="REQUIRED"
			com="OPTIONAL - DEFAULTS TO component"
			name="OPTIONAL - DEFAULTS TO LISTLAST OF REQUIRED COMPONENT PATH"
			stArgs="OPTIONAL - DEFAULTS TO AN EMPTY STRUCTURE"
			bInit="OPTIONAL - DEFAULTS TO 0"> --->
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- 1.) class path (BA MVC Model path is mvc.Models.*) --->
        <cfargument name="path" type="string" 	required="true"
        	hint="dot syntax Class path including full CFC name without suffix">
        <!--- 2.) [.net, com, component, corba, java, web service] (BA MVC Model objects are all based of type - component) --->
        <cfargument name="com" 				type="string" 	required="false" 	default="component"
        	hint="BA MVC Model objects are all based of type - component.">
        <!--- 3.) BA MVC Model names will be obtained from the required arguments.path,
		however the developer may need to override this when working with multiple same-named CFC's in different /component/ subfolders... --->
        <cfargument name="name" 			type="string" 	required="false" 	default="#listLast(arguments.path,'.')#"
        	hint="full CFC name without suffix">
        <!--- 4.) [empty structures will be transparent] --->
        <cfargument name="stArgs" 			type="struct" 	required="false" 	default="#structNew()#"
        	hint="Some objects may employ an incoming structure of name-value pairs that can be utilized with the argumentsCollection attribute. (empty structures will be transparent)">
        <!--- 5.) use objects init() method? --->
        <cfargument name="bInit" 					type="boolean" 	required="false" 	default="0"
        	hint="Some objects may require an init() method.">

		<!--- 6.) relaod object emoploying killObject() --->
        <cfargument name="bReload"	type="boolean" 	required="false" 	default="0" hint="For development, pass the reload flag to refresh the object in memory.">

        <!--- let's set our initial values --->
        <cfscript>
			var var_bCreateStatus = 0;
        	var var_name = "";
        	var var_oObject = "";
        	var_name = arguments.name;
		</cfscript>

		<!--- Clear the object from memory if it exists and the bReload flag is passed --->
		<cfif arguments.bReload AND objectExists(arguments.name)>
        	<cfscript>
				killObject(arguments.name);
			</cfscript>					
		</cfif>

        <!--- IF we already have our Legacy OR Model Object in application scope... --->    
        <cfif objectExists(arguments.name)>  
        
        	<cfset var_oObject = application["o#trim(arguments.name)#"]>

		<!--- NO object yet, CREATE our requested object! --->
        <cfelse>

        	<!--- Note: No Beans in v10 --->
            
            <!--- privacy please...  and keep our locks very specifically named by Legacy BA or Model Object in focus --->
            <cflock timeout="#this.stObjectInfo.lockTimeoutSeconds#" type="exclusive" name="#trim(arguments.name)#">
            
            	<cfscript>
					// with init()
					if (arguments.bInit)
					{
						// with argumentsCollection
						if (structCount(arguments.stArgs))
						{
							application["o#trim(arguments.name)#"] = createObject(arguments.com,arguments.path).init(arguments.stArgs);
						}
						// no argumentsCollection
						else
						{
							application["o#trim(arguments.name)#"] = createObject(arguments.com,arguments.path).init();
						}
					}
					// no init()
					else
					{
						application["o#trim(arguments.name)#"] = createObject(arguments.com,arguments.path);
					}
					
					//IF we just Now successfully created our Legacy OR Model Object in application scope... --->
					if (objectExists(arguments.name))
					{
						//IF birth was successful...
						var_oObject = application["o#trim(arguments.name)#"];
						//1.) add the object name to the user's childObject array
						appendCreatedObjectArray(trim(arguments.name));
						//2.) change our createStatus to true 
						var_bCreateStatus= 1;
					}
					else
					{
						var_oObject = "noLegacyOrModelObjectAvailable";
					}
				</cfscript>

            </cflock>

            <cfif isDefined("session.stMVCUserInfo.User_ID")>
            
            	<cfif not isObject(var_oObject)>
                	<cflog text="Legacy OR Model Object NOT Created: #arguments.name# User: #session.stMVCUserInfo.User_ID#" type="information" log="application" file="#application.applicationName#" application="yes">
                </cfif>

            <cfelse>
            
            	<cfif not isObject(var_oObject)>
                	<cflog text="Legacy OR Model Object NOT Created: #arguments.name# User: na" type="information" log="application" file="#application.applicationName#" application="yes">
                </cfif>

            </cfif>

        </cfif>

        <cfreturn var_oObject>
    
    </cffunction>
    <!--- main Public METHOD: getObject() FUNCTIONALITY: I return a Legacy OR Model Object, bringing the CFC Object to life as necessary (insert into application scope's structure) aka [components.*]. [end] --->

	<!--- main Public METHOD: killObject() FUNCTIONALITY: I kill a Legacy or Model Object (delete from application scope's structure). [begin] --->
    <cffunction name="killObject" access="public" output="no" hint="I kill a Legacy or Model Object (delete from application scope's structure)." returntype="boolean" displayname="main > killObject()">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- 1.) --->
        <cfargument name="object_cfcName" 			type="string" 	required="true" 	hint="full CFC name without suffix">
        <!--- 2.) --->
        <cfargument name="JVMMemoryPercentageUsed" 	type="numeric" 	required="false" 	hint="only known within onSessionEnd()" default="0">

        <!--- let's set our initial values --->
        <cfset var var_bKillStatus= 0>
    
    	<!--- IF we ARE already in application scope... --->
        <cfif objectExists(arguments.object_cfcName)>

			<!--- privacy please...  and keep our locks very specifically named by Legacy BA or Model Object in focus --->
            <cflock timeout="#this.stObjectInfo.lockTimeoutSeconds#" type="exclusive" name="#trim(arguments.object_cfcName)#">

				<cfscript>
					structDelete(application,"o" & trim(arguments.object_cfcName),false);
					
					//IF assassination was successful...

					//1.) add the object name to the application's killedObject array
					appendKilledObjectArray(trim(arguments.object_cfcName),arguments.JVMMemoryPercentageUsed);
					
					//2.) change our killStatus to true 
                    var_bKillStatus= 1;
				</cfscript>
    
            </cflock>
        
        </cfif>
        
        <cfreturn var_bKillStatus>
    
    </cffunction>
    <!--- main Public METHOD: killObject() FUNCTIONALITY: I kill a Legacy or Model Object (delete from application scope's structure). [end] --->

	<!--- main Private METHOD: objectExists() FUNCTIONALITY: I check to see if a Legacy or Model Object is alive in application scope [begin] --->
    <cffunction name="objectExists" access="public" output="no" hint="I check to see if a Legacy or Model Object is alive in application scope." returntype="boolean" displayname="main > objectExists()">
    
        <!--- Parameters associated with this method (Function-level variables are prefixed with "var_") --->
        <!--- 1.) --->
        <cfargument name="object_cfcName" 	type="string" required="true" 	hint="full CFC name without suffix">
    
    	<!--- let's set our initial values --->
        <cfset var var_bObjectExists = 0>
        
        <!--- If the Legacy or Model Object DOES exist... --->
        <cfif structKeyExists(application,"o" & trim(arguments.object_cfcName))>
            
            <!--- It is ALIVE! --->
            <cfset var_bObjectExists = 1>
        
        </cfif>
    
        <!--- Return the final container to the caller --->
        <cfreturn var_bObjectExists>
    
    </cffunction>
    <!--- main Private METHOD: objectExists() FUNCTIONALITY: I check to see if a Legacy or Model Object is alive in application scope [end] --->

</cfcomponent>