
<cfcomponent hint="MessageLog">

	<cfset this.id = "" />
	<cfset this.type = "" />
	<cfset this.to = "" />
	<cfset this.cc = "" />
	<cfset this.from = "" />
	<cfset this.subject = "" />
	<cfset this.message = "" />
	<cfset this.generatedBy = "" />
	<cfset this.appArea = "" />
	<cfset this.userId = "" />
	<cfset this.App_Area_Identifer = "" />
	<cfset this.App_Area_Sub_Identifier = "" />
	<cfset this.attachments = "" />

	
	<cffunction name="init">

		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="to" type="string" required="true" />
		<cfargument name="cc" type="string" required="true" />
		<cfargument name="from" type="string" required="true" />
		<cfargument name="subject" type="string" required="true" />
		<cfargument name="message" type="string" required="false" default="" />
		<cfargument name="generatedBy" type="string" required="true" />
		<cfargument name="appArea" type="string" required="true" />
		<cfargument name="userId" type="string" required="false" default="" />
		<cfargument name="App_Area_Identifer" type="string" required="false" default="" />
		<cfargument name="App_Area_Sub_Identifier" type="string" required="false" default="" />
		
		
		<cfset setId(arguments.id) />
		<cfset setType(arguments.type) />
		<cfset setTo(arguments.to) />
		<cfset setCc(arguments.cc) />
		<cfset setFrom(arguments.from) />
		<cfset setSubject(arguments.subject) />
		<cfset setMessage(arguments.message) />
		<cfset setGeneratedBy(arguments.generatedBy) />
		<cfset setAppArea(arguments.appArea) />
		<cfset setApp_Area_Identifer(arguments.app_area_identifier) />
		<cfset setApp_Area_Sub_Identifier(arguments.app_area_sub_identifier) />
		<cfset setUserId(arguments.userId) />
		
	</cffunction>
	
	<!---id setter--->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!---id getter--->
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!---type setter--->
	<cffunction name="setType" access="public" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset this.type = arguments.type />
	</cffunction>
	<!---type getter--->
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn this.type />
	</cffunction>
	
	<!---to setter--->
	<cffunction name="setTo" access="public" output="false">
		<cfargument name="to" type="string" required="true" />
		<cfset this.to = arguments.to />
	</cffunction>
	<!---to getter--->
	<cffunction name="getTo" access="public" returntype="string" output="false">
		<cfreturn this.to />
	</cffunction>

	<!---cc setter--->
	<cffunction name="setCc" access="public" output="false">
		<cfargument name="cc" type="string" required="true" />
		<cfset this.cc = arguments.cc />
	</cffunction>
	<!---cc getter--->
	<cffunction name="getCc" access="public" returntype="string" output="false">
		<cfreturn this.cc />
	</cffunction>
	
	<!---from setter--->
	<cffunction name="setFrom" access="public" output="false">
		<cfargument name="from" type="string" required="true" />
		<cfset this.from = arguments.from />
	</cffunction>
	<!---from getter--->
	<cffunction name="getFrom" access="public" returntype="string" output="false">
		<cfreturn this.from />
	</cffunction>
	
	<!---subject setter--->
	<cffunction name="setSubject" access="public" output="false">
		<cfargument name="subject" type="string" required="true" />
		<cfset this.subject = arguments.subject />
	</cffunction>
	<!---subject getter--->
	<cffunction name="getSubject" access="public" returntype="string" output="false">
		<cfreturn this.subject />
	</cffunction>
	
	<!---message setter--->
	<cffunction name="setMessage" access="public" output="false">
		<cfargument name="message" type="string" required="true" />
		<cfset this.message = arguments.message />
	</cffunction>
	<!---message getter--->
	<cffunction name="getMessage" access="public" returntype="string" output="false">
		<cfreturn this.message />
	</cffunction>
	
	<!---generatedBy setter--->
	<cffunction name="setGeneratedBy" access="public" output="false">
		<cfargument name="generatedBy" type="string" required="true" />
		<cfset this.generatedBy = arguments.generatedBy />
	</cffunction>
	<!---generatedBy getter--->
	<cffunction name="getGeneratedBy" access="public" returntype="string" output="false">
		<cfreturn this.generatedBy />
	</cffunction>
	
	<!---appArea setter--->
	<cffunction name="setAppArea" access="public" output="false">
		<cfargument name="appArea" type="string" required="true" />
		<cfset this.appArea = arguments.appArea />
	</cffunction>
	<!---appArea getter--->
	<cffunction name="getAppArea" access="public" returntype="string" output="false">
		<cfreturn this.appArea />
	</cffunction>
	
	<!---appAreaID setter--->
	<cffunction name="setApp_Area_Identifer" access="public" output="false">
		<cfargument name="App_Area_Identifer" type="string" required="true" />
		<cfset this.App_Area_Identifer = arguments.App_Area_Identifer />
	</cffunction>
	<!---appAreaID getter--->
	<cffunction name="getApp_Area_Identifer" access="public" returntype="string" output="false">
		<cfreturn this.App_Area_Identifier />
	</cffunction>

	<!---appAreaSubID setter--->
	<cffunction name="setApp_Area_Sub_Identifier" access="public" output="false">
		<cfargument name="App_Area_Sub_Identifier" type="string" required="true" />
		<cfset this.App_Area_Sub_Identifier = arguments.App_Area_Sub_Identifier />
	</cffunction>
	<!---appAreaSubID getter--->
	<cffunction name="getApp_Area_Sub_Identifier" access="public" returntype="string" output="false">
		<cfreturn this.App_Area_Sub_Identifier />
	</cffunction>
	
	<!---userId setter--->
	<cffunction name="setUserId" access="public" output="false">
		<cfargument name="userId" type="string" required="true" />
		<cfset this.userId = arguments.userId />
	</cffunction>
	<!---userId getter--->
	<cffunction name="getUserId" access="public" returntype="string" output="false">
		<cfreturn this.userId />
	</cffunction>
	
	<!---add attachments--->
	<cffunction name="addAttachments" access="public" output="false">
		<cfargument name="attachments" type="MessageLogAttach" required="true" />
		<cfset this.attachments = arguments.attachments />
	</cffunction>
	
	<!---commit log data to database--->
	<cffunction name="commitLog" access="public" output="true">
		
		<cfargument name="mesgLogData" type="MessageLog" required="true" />
  
		<cftransaction>
<!--- D29823: email log ... START--->		
		<cfset mesgLogData.to = #replace(mesgLogData.to,"<",",","All")#>
		<cfset mesgLogData.to = #replace(mesgLogData.to,">","","All")#>
		<cfset mesgLogData.to = #replace(mesgLogData.to,";",",","All")#>
<cfset to_email = "">
<cfloop list="#mesgLogData.to#" index="emails" delimiters=",">
	<cfif find('@', emails)>
		<cfset to_email = listappend(to_email, #emails#)>
	</cfif>
</cfloop>	
<cfset mesgLogData.to = to_email>		
<!--- D29823: email log ... END--->	
			<!---inset log data--->
 			<cfquery name="qCommitLog" datasource="#application.datasource#">
			
				INSERT INTO MESSAGE_LOG
					(Message_Type_Id,Message_To,Message_From,Message_CC,Message_Subject,Message,Message_Generated_By_ID,App_Area_ID,User_Id<cfif mesgLogData.appArea neq 16>,App_Area_Identifier</cfif>,App_Area_Sub_Identifier)
				VALUES
					(
					<cfqueryparam value="#mesgLogData.type#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#trim(mesgLogData.to)#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#trim(mesgLogData.from)#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#trim(mesgLogData.cc)#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#trim(mesgLogData.subject)#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#trim(mesgLogData.message)#" cfsqltype="CF_SQL_LONGVARCHAR">,
					<cfqueryparam value="#mesgLogData.generatedBy#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#mesgLogData.appArea#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#mesgLogData.userId#" cfsqltype="CF_SQL_VARCHAR">,
					<cfif mesgLogData.appArea neq 16>
					<cfqueryparam value="#mesgLogData.App_Area_Identifer#" cfsqltype="CF_SQL_VARCHAR">,
					</cfif>
					<cfqueryparam value="#mesgLogData.App_Area_Sub_Identifier#" cfsqltype="CF_SQL_VARCHAR">
					)
				SELECT SCOPE_IDENTITY() AS MESSAGE_LOG_ID	
			</cfquery>
			
			<cfset Msg_Log_ID = qCommitLog.MESSAGE_LOG_ID>
			
			<!--- For logging emails related to "claim rates report" --->
			<cfif mesgLogData.appArea eq 16>
				<cfset app_general_functions = CreateObject("component","components.general.General_Functions") />
				<cfset mesgLogData.App_Area_Identifer = app_general_functions.listRemoveDupes(mesgLogData.App_Area_Identifer,",")>
				<cfloop list="#mesgLogData.App_Area_Identifer#" index="id">
					<cfquery name="qCommitLogAttach" datasource="#application.datasource#">				
						INSERT INTO Message_Log_Multiple_App_Area_Identifier
							(Message_Log_ID, App_Area_Identifier)
						VALUES
							(
							<cfqueryparam value="#Msg_Log_ID#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#id#" cfsqltype="CF_SQL_LONGVARCHAR">
							)				
					</cfquery>	
				</cfloop>
			</cfif>
			
			<!---commit log attachments--->
			<cfif ArrayLen(mesgLogData.attachments.attachments)>
				
				<!---loop over each attachment and insert content--->
				<cfloop index="indx" from="1" to="#ArrayLen(mesgLogData.attachments.attachments)#">

					
					<cfquery name="qCommitLogAttach" datasource="#application.datasource#">
				
						INSERT INTO MESSAGE_ATTACHMENT
							(Message_Log_ID, Message_Attachment, Attachment_Desc)
						VALUES
							(
							<cfqueryparam value="#qCommitLog.Message_Log_ID#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#trim(mesgLogData.attachments.attachments[indx].attachments)#" cfsqltype="CF_SQL_LONGVARCHAR">,
							<cfqueryparam value="#trim(mesgLogData.attachments.attachments[indx].desc)#" cfsqltype="CF_SQL_VARCHAR">
							)
					
					</cfquery>
				
				</cfloop>

			</cfif>
			
		</cftransaction>
		
	</cffunction>
	
</cfcomponent>