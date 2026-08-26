<cfcomponent name="programScore" access="public" description="Gets programs and statuses for scorecard">

<cfset variables.version = 1.0 />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getProgramScore" access="remote" returntype="query" output="false" description="Returns a query with Programs">
			<cfargument name="searchStatus" type="numeric" required="false" default="99" />
			<cfargument name="searchAgree_id" type="numeric" required="false" default="99" />
			<cfargument name="searchShowExpired" type="numeric" required="false" default="0" />
			<cfargument name="searchArg" type="struct" required="false" default="structNew()" />
			<cfif structKeyExists(arguments.searchArg, "scorecardStatus") and arguments.searchStatus neq 99>
				<cfset temp = structUpdate(arguments.searchArg, "scorecardStatus", searchStatus)>
			</cfif>
			<cfif structKeyExists(arguments.searchArg, "agreeStatusId") and arguments.searchAgree_id neq 99>
				<cfset temp = structUpdate(arguments.searchArg, "agreeStatusId", searchAgree_id)>
			</cfif>
			<cfset get_This_Status_Programs = CreateObject("component", "components.programs.ProgramManager").search2(arguments.searchArg)>
			<cfreturn get_This_Status_Programs />
	</cffunction>

<!---		::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->

	<cffunction name="getProgramStatus" access="remote" returntype="query" output="false" description="Get the different statuses and their descriptions for the Flash Scorecard Status Viewer">
		<cfset var qGetStatus = CreateObject("component", "components.programs.ProgramManager").getProgramStatus()>
		<cfreturn qGetStatus />
			
	</cffunction>
	
<!---		::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->

	<cffunction name="getProgramPreview" access="remote" returntype="string" output="false" description="Get the Program preview Display">
		<cfargument name="prog" type="struct" required="false" />
		<!---<cfset var tmp = arguments.prog>--->
		<cfsavecontent variable="htmlDisplay">
			<CFINCLUDE TEMPLATE="../display_Program_List.cfm">
		</cfsavecontent>
		
		<cfreturn htmlDisplay />
			
	</cffunction>
	
	<cffunction name="getProgramPreview2" access="remote" returntype="string" output="false" description="Get the Program preview Display">
		<cfargument name="CID" type="numeric"required="yes" />
		<cfargument name="accessStructure" type="struct" required="yes" />
		<cfargument name="prog" type="struct" required="yes">
		<cfset noCrp = "1">
		<cfset URL.CID = arguments.CID>
		<cfset request.accessStructure = arguments.accessStructure>
		<cfset TheQuery = prog>
		<cfset TheQuery.recordcount = prog.TheCount>
		<cfset appsettings = application.appsettingsget>
		<cfset maxrows = 1>
		<cfsavecontent variable="htmlDisplay">
			<CFINCLUDE TEMPLATE="../display_Program_List.cfm">
			<!---<CFINCLUDE TEMPLATE="../program_display.cfm">--->
			<!---<CFINCLUDE TEMPLATE="../test.cfm">--->
		</cfsavecontent>
		
		<cfreturn left(htmlDisplay, 500) />
			
	</cffunction>


<cffunction name="getProgramPreview3" access="remote" returntype="string" output="false" description="Get the Program preview Display">
		<cfargument name="CID" type="numeric"required="yes" />
		<cfargument name="accessStructure" type="struct" required="yes" />
		<cfargument name="prog" type="struct" required="yes">
		<cfset URL.CID = arguments.CID>
		<cfset request.accessStructure = arguments.accessStructure>
		<cfset TheQuery = prog>
		<cfset TheQuery.recordcount = prog.TheCount>
		<cfset appsettings = application.appsettingsget>
	<!---BJF D8904: I need to see if there are any revisions of this program and show an icon to indicate their existance if there are--->
		<cfsilent>
			<cfquery name="AreThereRevisions" datasource="#application.datasource#">
			SELECT count(Contract_Main_ID) AS numberofrevisions FROM Contract_Main WHERE Revision_of_Contract_Main_ID = #TheQuery.contract_main_id#
			</cfquery>
		</cfsilent>
		
			<!--- Dev Note: KAL; 9962 : whats the logic behind gray and red triangles  --->
			<cfif AreThereRevisions.numberofrevisions GT 0>
				<cfset imgsrc = "/images/delta_gray.gif">
				<cfset imgclick = "STYLE=""cursor:pointer;"" onclick=""javascript:showrevisiondetails('#TheQuery.contract_main_id#','#TheQuery.Contract_Status_Type_IDX#');""">
				<cfset imgALT = "This program has been Revised..." >
			<cfelseif Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<cfif appSettings.getPgmScorecardRevisionReport() EQ 1>
					<cfset imgsrc = "/images/delta.gif">
					<cfset imgclick = "STYLE=""cursor:pointer;"" onclick=""javascript:showrevisiondetails('#TheQuery.contract_main_id#','#TheQuery.Contract_Status_Type_IDX#');""">
				<cfelse>
					<cfset imgsrc = "/images/repeat.gif">
					<cfset imgclick = "">
				</cfif>
				<cfset imgALT = "This is a Revision..." >
			<cfelse>
				<cfset imgsrc = "/images/fill.gif">
				<cfset imgclick = "">
				<cfset imgALT = "" >
			</cfif>	
		<cfsavecontent variable="htmlDisplay2">
			<IMG SRC="#imgsrc#" BORDER="0" TITLE="#imgALT#" #imgclick#>
			
			<cfif IsRollOver EQ 1><IMG SRC="/images/roll_over.gif" width="10" height="10" BORDER="0" TITLE="This is a Rollover..."></cfif>
			<!---Displays icon if the program is cancelled--->
			<cfif Contract_Status_Type_IDX IS 7 AND len(trim(Cancelled_Date)) GT 0>
			<img src="/images/delete.gif" TITLE="Cancelled by #Cancelled_Name#">
			</cfif>			
		<cfif appsettings.getSend_to_SAP()>
			<cfif Sent_To_External_Client EQ 1 OR error_from_external_client EQ 1>
			<cfif Sent_To_External_Client EQ 1>
				<cfset helpmessage = "This program is being sent to SAP">
			<cfelseif Error_From_External_Client EQ 1>
				<cfset helpmessage = "Errors in sending data to SAP">
			</cfif>
		<A HREF="javascript:showSAPDetails('#TheQuery.Contract_Main_ID#')"> <CF_SmallHelp
				imgWidth = "10"
				imgHeight = "10"
				imgPath="/images/exclamation.gif"
				dropdownCheck="0">#helpmessage#</CF_SmallHelp></A>
			</cfif>
		<cfelseif Cancel_Sent_to_Client EQ 1>
			<IMG SRC="/images/arrow2_red.gif" width="10" height="10" title="This program has been cancelled in ERP #chr(13)##chr(10)#Cancel Date: #Cancelled_Date# #chr(13)##chr(10)#Cancel Acknowledge Date: #External_Client_Cancel_Ack_Date#">
		<cfelseif Sent_To_External_Client EQ 1>
			<IMG SRC="/images/arrow2.gif" width="10" height="10" title="This program has been successfully loaded in ERP #chr(13)##chr(10)#Send Date: #last_extract_date# #chr(13)##chr(10)#Acknowledge Date: #External_Client_Ack_Date#">
		<cfelseif Sending_To_External_Client EQ 1>
			<IMG SRC="/images/arrow1.gif" width="10" height="10" title="This program is being sent to ERP #chr(13)##chr(10)#Send Date: #last_extract_date# #chr(13)##chr(10)#Acknowledge Date: #External_Client_Ack_Date#">
		<cfelseif Unsuccessful_Ack_From_External_Client EQ 1>
			<IMG SRC="/images/process_failed.gif" width="10" height="10" title="#Unsuccessful_Ack_Reason_From_External_Client#">
		<cfelse>
			<IMG SRC="/images/fill.gif" width="10" height="10">
		</cfif>
		</cfsavecontent>
		
		<cfreturn left(htmlDisplay2, 500) />
			
	</cffunction>
	
	<cffunction name="insertFavorites" access="remote" output="false" hint="wrapper to insert programs in to the users list of favorites" returntype="void">
		<cfargument name="items" type="array" required="yes">
		<cfargument name="user_id" type="uuid" required="yes">
		<cfset var insFav = CreateObject("component", "components.programs.ProgramManager").insertFavorites(arguments.items,arguments.user_id)>
	
	</cffunction>
	
	<cffunction name="removeFavorites" access="remote" output="false" hint="wrapper to insert programs in to the users list of favorites" returntype="void">
		<cfargument name="items" type="array" required="yes">
		<cfargument name="user_id" type="uuid" required="yes">
		<cfset var insFav = CreateObject("component", "components.programs.ProgramManager").removeFavorites(arguments.items,arguments.user_id)>
	
	</cffunction>
	
	<cffunction name="getFavorites" access="remote" output="false" hint="wrapper to insert programs in to the users list of favorites" returntype="query">
		<cfargument name="user_id" type="uuid" required="yes">
		<cfset var insFav = CreateObject("component", "components.programs.ProgramManager").getFavorites(arguments.user_id)>
		<cfreturn insFav />
	</cffunction>
	
	<cffunction name="cryp" access="remote" output="false" hint="wrapper to insert programs in to the users list of favorites" returntype="string">
		<cfargument name="program_id" type="numeric" required="yes">
		<cfargument name="user_id" type="uuid" required="yes">
		<cfset var app_general_functions = CreateObject("component","components.general.General_Functions") />
		<cfset var key = app_general_functions.GenerateKey(arguments.user_id) />
		<cf_cryp type="en" string="#arguments.Program_ID#" key="#key#">
		<cfreturn cryp.value />
	</cffunction>
</cfcomponent>