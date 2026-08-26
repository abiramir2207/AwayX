<cfcomponent output="false">

<cffunction name="onIncomingMessage" output="false" returnType="void">
   <cfargument name="cfEvent" type="struct" required="yes">

   <cfscript>
   if(not structKeyExists(arguments.cfEvent.data, "file")) arguments.cfEvent.Data.file="defaultEventLog";
   if(not structKeyExists(arguments.cfEvent.data, "type")) arguments.cfEvent.Data.type="info";
   </cfscript>

 <cfif structKeyExists(arguments.cfevent.data, "datasource")>
<!------ <CFSET VARIABLESTOCHECK = "AccessStructure,Application,Attributes,Caller,CFCATCH,CGI,Client,Cookie,Error,File,Form,Request,Server,Session,ThisTag,URL"> ----->
<!------ we are not going to store every thin gin database, becaus eit takes to long to write it, so we will write just the necessary structure ----->

<CFSET VARIABLESTOCHECK = "BSAApplication,BSAError,Form,Session,URL">

<CFQUERY NAME="saveErrorStructsToDB" datasource="#arguments.cfEvent.data.datasource#">
UPDATE CFML_Error_Log
		SET File_Name = '#arguments.cfEvent.data.File_Name#',
		File_Directory = '#arguments.cfEvent.data.File_Directory#'
		<CFLOOP INDEX="ThisStructure" LIST="#VariablesToCheck#">
		<CFSET THISSTRUCTURE1 = 'arguments.cfEvent.Data.#THISSTRUCTURE#'>
			<CFIF ISDEFINED(THISSTRUCTURE1)>
			,<cfif ThisStructure1 EQ "arguments.cfEvent.Data.BSAError">Error_Structure<cfelseif ThisStructure1 EQ "arguments.cfEvent.Data.BSAApplication">Application_Structure<cfelse>#ThisStructure#_Structure</cfif>
				=
				<CFWDDX ACTION="CFML2WDDX" INPUT="#evaluate("#THISSTRUCTURE1#")#" OUTPUT="#ThisStructure#_STRUCTURE_IN_WDDX_FORM" USETIMEZONEINFO="Yes">
				<CFSET TEMPWDDXPACKET = EVALUATE("#ThisStructure#_STRUCTURE_IN_WDDX_FORM")>
				<CFSET TEMPWDDXPACKET = REPLACENOCASE(TEMPWDDXPACKET, "'", "''", 'ALL')>
				'#TempWDDXPacket#'
			</CFIF>
		</CFLOOP>
		,EMPTYFIELD = 0
		WHERE CFML_Error_Log_ID = '#arguments.cfEvent.data.CFML_Error_Log_ID#'
	</CFQUERY>

	<!---
		REMOVE  "VARIABLE" STRUCTURE KEYS:
		REMOVING THESE KEYS FROM THE VARIABLES SCOPE TO REDUCE FILE SIZE OF THE .htm ERROR REPORTS,
		ALL OF THESE ARE DUPLICATES OF OTHER INFORMATION OR ARE SIMPLY JUST NOT NEEDED FOR DEBUG PURPOSES.

		- GENSETTINGSMANAGER
		- APPSETTINGS

		- BSAAPPLICATION_STRUCTURE_IN_WDDX_FORM
		- BSAERROR_STRUCTURE_IN_WDDX_FORM
		- SESSION_STRUCTURE_IN_WDDX_FORM
		- URL_STRUCTURE_IN_WDDX_FORM

	<CFIF StructKeyExists(Variables, "BSAError")>
		<cfset StructDelete(Variables,"BSAError")>
	</CFIF>
	<CFIF StructKeyExists(Variables, "BSAApplication")>
		<cfset StructDelete(Variables,"BSAApplication")>
	</CFIF>
	--->

	<cfif StructKeyExists(arguments.cfEvent.data.Vars, "GENSETTINGSMANAGER")>
		<cfset StructDelete(arguments.cfEvent.data.Vars, "GENSETTINGSMANAGER")>
	</cfif>
	<cfif StructKeyExists(arguments.cfEvent.data.Vars, "APPSETTINGS")>
		<cfset StructDelete(arguments.cfEvent.data.Vars, "APPSETTINGS")>
	</cfif>

	<!--- Remove WDDX structs --->
	<cfif StructKeyExists(Variables, "BSAApplication_STRUCTURE_IN_WDDX_FORM")>
		<cfset StructDelete(arguments.cfEvent.data.Vars, "BSAApplication")>
	</cfif>
	<cfif StructKeyExists(Variables, "BSAError_STRUCTURE_IN_WDDX_FORM")>
		<cfset StructDelete(arguments.cfEvent.data.Vars, "BSAError")>
	</cfif>
	<cfif StructKeyExists(Variables, "Session_STRUCTURE_IN_WDDX_FORM")>
		<cfset StructDelete(arguments.cfEvent.data.Vars, "Session")>
	</cfif>
	<cfif StructKeyExists(Variables, "URL_STRUCTURE_IN_WDDX_FORM")>
		<cfset StructDelete(arguments.cfEvent.data.Vars, "URL")>
	</cfif>
	<!--- END: REMOVE  WDDX structs --->

 <!--- Uncomment this if in the office --->
 <CFSET VARIABLESTOCHECK = "BSAError,Form,URL,BSAApplication,Attributes,Caller,CFCATCH,CGI,Client,Cookie,File,Server,Session,Variables">

	<!--- Output if it is us... --->
	<CFSAVECONTENT VARIABLE = "Error_Body_Top">
	 	<CFIF IsDefined("arguments.cfEvent.data.BSAError.RootCause.Message")>
			<CFOUTPUT>
				<H3 style="color:Red;">
					#arguments.cfEvent.data.BSAError.RootCause.Message#<br>
					<cfif ArrayLen(arguments.cfEvent.data.BSAError.RootCause.TagContext) gte 1>
					IN: #arguments.cfEvent.data.BSAError.RootCause.TagContext[1].template#<br>
					LINE: #arguments.cfEvent.data.BSAError.RootCause.TagContext[1].line#<br>
					</cfif>
				</H3>
			</CFOUTPUT>
		</CFIF>
	</CFSAVECONTENT>
	 	<CFSAVECONTENT VARIABLE = "Error_Body">
			<CFOUTPUT>
			#Error_Body_Top#
			</CFOUTPUT>
		<!--- Since the Evaluate function is an overhead, I have hardcoded the scopes --->
			<CFIF IsDefined("arguments.cfEvent.data.BSAError")>
			<H1>BSAError</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.BSAError#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.Form")>
			<H1>Form</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.Form#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.BSAApplication")>
			<H1>BSAApplication</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.BSAApplication#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.Attributes")>
			<H1>Attributes</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.Attributes#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.Caller")>
			<H1>Caller</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.Caller#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.CFCATCH")>
			<H1>CFCATCH</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.CFCATCH#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.CGI")>
			<H1>CGI</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.CGI#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.Client")>
			<H1>Client</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.Client#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.Cookie")>
			<H1>Cookie</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.Cookie#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.File")>
			<H1>File</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.File#">
			</CFIF>
			<CFIF IsDefined("arguments.cfEvent.data.Server")>
			<H1>Server</H1>
				<CFDUMP VAR="#arguments.cfEvent.data.Server#">
			</CFIF>
			<H1>Session</H1>
			<CFIF IsDefined("arguments.cfEvent.data.Session")>
				<CFDUMP VAR="#arguments.cfEvent.data.Server#">
			</CFIF>
			<H1>Variables</H1>
			<!--- Do not inclue "PROPS". It contains everything. We just need 'Vars' --->
			<cfset StructDelete(arguments.cfEvent.data.Vars, "PROPS")>
				<CFDUMP VAR="#arguments.cfEvent.data.Vars#">
	</CFSAVECONTENT>

<cfif NOT DirectoryExists("#arguments.cfEvent.data.Use_App_Path#\Data_Files\Created\error_files")>
	<CFDIRECTORY ACTION="CREATE" DIRECTORY="#arguments.cfEvent.data.Use_App_Path#\Data_Files\Created\error_files">
</cfif>

<cfset fileRelativePath = "Data_Files/Created/error_files/error_#arguments.cfEvent.data.CFML_Error_Log_ID#.htm" />

<cfset floc = "#arguments.cfEvent.data.Use_App_Path#/#fileRelativePath#">

<cffile action="WRITE" file="#floc#" output="#Error_Body#" addnewline="Yes">

<!---
 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Check for the level of access																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET Send_Mail_To_User = true>
	<CFSET Send_Mail_To_Us = true>
	<CFIF arguments.cfEvent.data.AccessStructureExist>
		<CFIF arguments.cfEvent.data.USER_RIGHTS_ID EQ 9999>
			<CFSET Send_Mail_To_User = false>
			<CFSET Send_Mail_To_Us = true>
		</CFIF>
	<CFELSE>
		<CFSET Send_Mail_To_User = false>
	</CFIF>
	<CFIF NOT Send_Mail_To_User>
		<CFOUTPUT>#Error_Body#</CFOUTPUT>
	<CFELSE>
		<!--- TO="#AccessStructure.User_Email#" --->
		<!--- Email to the user a confirmation that we received the information arguments.cfEvent.data.User_Email --->
		<CFMAIL to="#AccessStructure.User_Email#" FROM="#appSettings.getDifferent_From_Address()#" SUBJECT="Event #arguments.cfEvent.data.CFML_Error_Log_ID#" TYPE="HTML">
			<FONT FACE="Arial, Helvetica, sans-serif">
			We have received event <B>#arguments.cfEvent.data.CFML_Error_Log_ID#</B><BR>
			This event has been logged and is being addressed.<BR>
			We apologize for the inconvenience.<BR><BR>
			#arguments.cfEvent.data.CompanyName#<BR><BR><BR>
			Note: This is an automatically generated message. Please do not reply to this message.
			</FONT>
		</CFMAIL>
	</CFIF>
	<CFIF Send_Mail_To_Us>
		<!--- Email it to us if it is them --->
		<!--- TO="#appSettings.getRemoteEventsEmail()#" --->
  		<CFMAIL to="#appSettings.getRemoteEventsEmail()#" FROM="#appSettings.getDifferent_From_Address()#" SUBJECT="Event #arguments.cfEvent.data.CFML_Error_Log_ID#" TYPE="HTML">
		<cfif arguments.cfEvent.data.AppErrorEmailLinkAlone EQ 1>
		#Error_Body_Top#<br><br>
		<a href="http://#arguments.cfEvent.data.CGI_Server_Name#/scheduled/getDocument.cfm?filePath=#fileRelativePath#" style="font-weight:bold;">click here to view the error details</a>
		<cfelse>#Error_Body#
		</cfif>
		</CFMAIL>
	</CFIF>

</cfif>

</cffunction>
<cffunction name="DuplicateStruct" output="false" returnType="struct">
	<cfargument name="oSourceStruct" required="true" type="struct" />
	<cfargument name="sDeleteKeyList" required="true" type="string" />

	<cfset var oDestStruct = StructNew() />
	<cfset var sStructKeyList = StructKeyList(arguments.oSourceStruct) />

	<cfloop list="#sStructKeyList#" index="thisKey">
		<cfif ListFindNoCase(arguments.sDeleteKeyList, thisKey)>
			<cfset thisKeyValue = "The value has been removed from the error message on purpose" />
		<cfelse>
			<cfset thisKeyValue = Evaluate("arguments.oSourceStruct.#thisKey#") />
		</cfif>
		<cfset StructInsert(oDestStruct, thisKey, thisKeyValue, true) />
	</cfloop>

	<cfreturn oDestStruct />

</cffunction>
</cfcomponent>