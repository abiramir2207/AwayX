<!-----------------------------------------------------------------------
Author 	 :	Your Name
Date     :	September 25, 2005
Description :
	This is a ColdBox event handler where all implicit methods can go.
	Thus its the main handler.

Please note that the extends needs to point to the eventhandler.cfc
in the ColdBox system directory.
extends = coldbox.system.eventhandler

----------------------------------------------------------------------->
<cfcomponent name="main" extends="coldbox.system.eventhandler" output="false">

	<!--- This init format is mandatory if you are writing init code else is optional,
	      include the super.init(arguments.controller).
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<!--- Any constructor code here --->
		<cfreturn this>
	</cffunction>
	--->

	<cffunction name="onAppInit" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- ON Application Start Here --->
        <cfset var appSettingsObj = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset var getAppSettings = appSettingsObj.get() />
		<cfset getColdboxOCM().set("appSettings",getAppSettings) />
    </cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- On Request Start Code Here --->
		<cfset var appSettings = getColdboxOCM().get("appSettings") />
		<cfif not isStruct(appSettings)>
			<cfset onAppInit(Event) />
        </cfif>
	</cffunction>

	<cffunction name="onRequestEnd" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- ON Request End Here --->
	</cffunction>

	<cffunction name="onException" access="public" returntype="void" output="false">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<!--- ON Exception Handler Here --->
		<cfscript>
			//Grab Exception From request collection, placed by ColdBox
			var exceptionBean = event.getValue("ExceptionBean");
			//Place exception handler below:
		</cfscript>
		<cfquery name="saveErrorStructsToDB" datasource="#application.datasource#">
          SET NOCOUNT ON
			INSERT INTO CFML_Error_Log
	        (
		     File_Name,
		     File_Directory,
             Error_Structure,
             EMPTYFIELD
	        )
	        VALUES
	        (
		     '#GetFileFromPath(CGI.CF_TEMPLATE_PATH)#',
		     '#GetDirectoryFromPath(CGI.CF_TEMPLATE_PATH)#',
             '',
		     0
	        )
           SELECT CFML_Error_Log_ID = @@IDENTITY
           SET NOCOUNT OFF
       </cfquery>
         <cfset event.setValue('error_id', saveErrorStructsToDB.CFML_Error_Log_ID) />

		<cfmail to="#getColdboxOCM().get('appSettings').getRemoteEventsEmail()#"
		        from="#getColdboxOCM().get('appSettings').getDifferent_From_Address()#"
		        SUBJECT="Event" TYPE="HTML">

          <cfif isStruct(exceptionBean.getExceptionStruct()) >
		     <strong>Error Messages:</strong>
		     #exceptionBean.getmessage()#<br />
		  <cfif exceptionBean.getExtendedINfo() neq "">
			#exceptionBean.getExtendedInfo()#<br />
	 	  </cfif>
	 	  <cfif len(exceptionBean.getDetail()) neq 0>
		 	#exceptionBean.getDetail()#
		  </cfif>
	     </cfif>

	     <cfif ArrayLen(exceptionBean.getTagContext()) >
		   <cfset arrayTagContext = exceptionBean.getTagContext()>
		  <tr>
			<th colspan="2" >IN:</th>
		  </tr>
		  <cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
		   <tr>
			<td align="right" class="fw_errorTablesTitles">Template:</td>
		    <td>#arrayTagContext[i].Template#</td>
		   </tr>
		   <tr>
			<td align="right" class="fw_errorTablesTitles">LINE:</td>
		    <td >#arrayTagContext[i].LINE#</td>
		   </tr>

		  </cfloop>
	</cfif>
		</cfmail>
	</cffunction>


</cfcomponent>