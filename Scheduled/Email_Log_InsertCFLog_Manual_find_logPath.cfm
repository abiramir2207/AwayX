

<cfoutput>


  <!--- Step 1. archive mailsent.log file --->
  <cfset variable.logfolder = archiveMailSent()>

 variable.logfolder ====== #variable.logfolder#
  
</cfoutput>

<!---------------------------------------------------------------------------------------------------------------------->
<cffunction name="archiveMailSent" output="false">
    <cfscript>
          local.adminObj = createObject("component","cfide.adminapi.administrator");
		  local.cf_admin = application.util.query.cf_admin();
		  if ( local.adminObj.login( local.cf_admin.password, local.cf_admin.username ) ) {
                local.myObj = createObject("component","cfide.adminapi._servermanager.servermanager");
                local.myObj.archiveLogFile( "mailSent.log" );
                local.debugger = createObject("component", "cfide.adminapi.debugging");
                local.logfolder = local.debugger.getLogProperty("logdirectory");
            	return(local.logfolder);
          }
          	return('');
    </cfscript>
</cffunction>
