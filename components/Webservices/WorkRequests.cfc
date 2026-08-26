<cfcomponent>

<cffunction name="UpdateWorkRequest" access="remote" hint="Web service to be updated by punchlist" output="false" returntype="string">
	<cfargument name="WRonStatus" type="string" required="true" access="private">
	<cfargument name="WRonApparea" type="string" required="true" access="private">
	<cfargument name="WRonType" type="string" required="true" access="private">
	<cfargument name="BA_Ticket_Number" type="string" required="true" access="private">
	<cfargument name="Work_Title" type="string" required="true" access="private">
	<cfargument name="Client_Reference_Number" type="string" required="true" access="private">
	<cfargument name="Estimated_Build" type="string" required="true" access="private">	
	<cfargument name="App_Area" type="string" required="true" access="private">	
	<cfargument name="Request_Type" type="string" required="true" access="private">
	<cfargument name="Item_Status" type="string" required="true" access="private">
	<!---<cfargument name="Estimated_Cost" type="string" required="true" access="private">
	<cfargument name="Estimated_Time_Required" type="string" required="true" access="private">
	<cfargument name="Test_Notes" type="string" required="true" access="private">--->
	<cfargument name="Release_Notes" type="string" required="true" access="private">
	<cfargument name="Updated_By" type="string" required="true" access="private">
	
	<cfquery name="UpdateWorkRequest" datasource="#application.datasource#">
	UPDATE 	Work_Request
	SET 	Work_Title = <cfqueryparam value="#arguments.Work_Title#" cfsqltype="CF_SQL_VARCHAR">,
			Client_Reference_Number = <cfqueryparam value="#arguments.Client_Reference_Number#" cfsqltype="CF_SQL_VARCHAR">,
			Estimated_Build = <cfqueryparam value="#arguments.Estimated_Build#" cfsqltype="CF_SQL_VARCHAR">,
			<cfif #arguments.WRonApparea# eq "1">
			App_Area = <cfqueryparam value="#arguments.App_Area#" cfsqltype="CF_SQL_VARCHAR">,
			</cfif>
			<cfif #arguments.WRonType# eq "1">
			Request_Type = <cfqueryparam value="#arguments.Request_Type#" cfsqltype="CF_SQL_VARCHAR">,
			</cfif>
			<cfif #arguments.WRonStatus# eq "1">
			Item_Status = <cfqueryparam value="#arguments.Item_Status#" cfsqltype="CF_SQL_VARCHAR">,
			</cfif>
			<!---Estimated_Cost = <cfqueryparam value="#arguments.Estimated_Cost#" cfsqltype="CF_SQL_VARCHAR">,
			Estimated_Time_Required = <cfqueryparam value="#arguments.Estimated_Time_Required#" cfsqltype="CF_SQL_VARCHAR">,
			Test_Notes = <cfqueryparam value="#arguments.Test_Notes#" cfsqltype="CF_SQL_VARCHAR">,--->
			Release_Notes = <cfqueryparam value="#arguments.Release_Notes#" cfsqltype="CF_SQL_VARCHAR">,
			Updated_By = <cfqueryparam value="#arguments.Updated_By#" cfsqltype="CF_SQL_VARCHAR">,
			Updated_On = #now()#
	WHERE 	BA_Ticket_Number = #arguments.BA_Ticket_Number#
	</cfquery>
	
	<cfset useLakebaseForGetUserCreated = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForGetUserCreated>
	<cftry>
		<cfset GetUserCreated = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"ba_ticket_number" = "eq.#arguments.BA_Ticket_Number#",
				"select" = "user_created"
			}), "user_created"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserCreated = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserCreated>
<cfquery name="GetUserCreated" datasource="#application.datasource#">
		SELECT 	User_Created
		FROM 	Work_Request
		WHERE 	BA_Ticket_Number = #arguments.BA_Ticket_Number#
	</cfquery>
</cfif>
	<!---	
	<!--- Get user contact info --->
		<cfset useLakebaseForGetUserInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserInfo>
	<cftry>
		<cfset GetUserInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#GetUserCreated.User_Created#",
				"select" = "name_first,name_last,user_email,user_code,work_phone_1,work_phone_2,work_phone_3"
			}), "name_first,name_last,user_email,user_code,work_phone_1,work_phone_2,work_phone_3"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserInfo>
<cfquery name="GetUserInfo" datasource="#application.datasource#">
		SELECT Name_First, Name_Last, User_Email, User_Code, Work_Phone_1, Work_Phone_2, Work_Phone_3
		FROM _Users WHERE User_ID = '#GetUserCreated.User_Created#'
		</cfquery>
</cfif>
	
	<cfset useLakebaseForSupportEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForSupportEmail>
	<cftry>
		<cfset SupportEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "ba_support_email"
			}), "ba_support_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSupportEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSupportEmail>
<cfquery name="SupportEmail" datasource="#application.datasource#">
		SELECT BA_Support_Email
		FROM _Application_Settings
	</cfquery>
</cfif>
	
	<cfoutput>
					
	<!--- Send Email --->
	<CF_EMAILWRAPPER TO			=	"#GetUserInfo.User_Email#"
      	  FROM						=	"#SupportEmail.BA_Support_Email#"
        	SUBJECT						=	"Work Request ###arguments.BA_Ticket_Number# has been updated"
		TYPE						=	"html" 
		messagetype					=	"1" 
		generatedby					=	"2" 
		apparea						=	"10"  <!---Customer settings --->
		userid						=	"">
		
		The work request <strong>#arguments.Work_Title#</strong> has been updated by Blacksmith. 
		You can review the work request in settings, in the administrator section under "work requests".
		<p></p>

	<!--- </CFMAIL> --->
	</CF_EMAILWRAPPER>
	</cfoutput>	
	--->
	<cfreturn  #arguments.BA_Ticket_Number#>
</cffunction>

<cffunction name="UpdateWRBuildInfo" access="remote" hint="Update build info from punchlist by webservice" output="false" returntype="string">
	<cfargument name="LabelIDs" type="string" required="true" access="private">
	<cfargument name="BuiltDate" type="string" required="true" access="private">
	<cfargument name="StageOrProd" type="string" required="true" access="private">
	
	<cfquery name="setBuildInfo" datasource="#application.datasource#">
		UPDATE 	Work_Request
		<cfif #arguments.StageOrProd# eq 1>
			SET builtOnProd = '#arguments.BuiltDate#'
		<cfelse>
			SET builtOnStage = '#arguments.BuiltDate#'
		</cfif>
		WHERE 	BA_Ticket_Number in (#arguments.LabelIDs#)
	</cfquery>
	<cfset useLakebaseForsetStageToProd = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForsetStageToProd>
	<cftry>
		<cfset application.oLakebase.updateRows("work_request",
			{
				"builtonstage" = "is.null",
				"builtonprod" = "not.is.null"
			},
			{
				"builtonstage" = "builtOnProd"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsetStageToProd = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsetStageToProd>
<cfquery name="setStageToProd" datasource="#application.datasource#">
		UPDATE 	Work_Request
		SET builtOnStage = builtOnProd
		WHERE  builtOnStage is  NULL
		AND builtOnProd is NOT NULL
	</cfquery>
</cfif>
	<cfreturn  #arguments.LabelIDs#>
</cffunction>

<cffunction name="UpdateWRBuildInfoREV" access="remote" hint="Update build info from punchlist by webservice" output="false" returntype="string">
	<cfargument name="LabelIDs" type="string" required="true" access="private">
	<cfargument name="BuiltDate" type="string" required="true" access="private">
	<cfargument name="StageOrProd" type="string" required="true" access="private">
	
	<cfquery name="setBuildInfo" datasource="#application.datasource#">
		UPDATE 	Work_Request
		<cfif #arguments.StageOrProd# eq 1>
			SET builtOnProd = '#arguments.BuiltDate#'
		<cfelse>
			SET builtOnStage = '#arguments.BuiltDate#'
		</cfif>
		WHERE 	BA_Ticket_Number in (#arguments.LabelIDs#)
		<cfif #arguments.StageOrProd# eq 1>
			and  builtOnProd is  NULL
		<cfelse>
			and builtOnStage is  NULL
		</cfif>
	</cfquery>
	<cfquery name="setStageToProd" datasource="#application.datasource#">
		UPDATE 	Work_Request
		SET builtOnStage = builtOnProd
		WHERE  builtOnStage is  NULL
		AND builtOnProd is NOT NULL
	</cfquery>
	<cfreturn  #arguments.LabelIDs#>
</cffunction>

<cffunction name="UpdateWRBuildInfoSP" access="remote" hint="Update build info from punchlist by webservice" output="false" returntype="string">
	<cfargument name="LabelIDs" type="string" required="true" access="private">
	<cfargument name="BuiltDateStage" type="string" required="no" access="private">
	<cfargument name="BuiltDateProd" type="string" required="no" access="private">
	
	<cfif arguments.BuiltDateProd EQ "NA">
		<cfquery name="setBuildInfo" datasource="#application.datasource#">
			UPDATE 	Work_Request
			SET builtOnStage = '#arguments.BuiltDateStage#'
			WHERE 	BA_Ticket_Number in (#arguments.LabelIDs#)
		</cfquery>
	<cfelseif  arguments.BuiltDateStage EQ "NA">
		<cfquery name="setBuildInfo" datasource="#application.datasource#">
			UPDATE 	Work_Request
			SET builtOnProd = '#arguments.BuiltDateProd#'
			WHERE 	BA_Ticket_Number in (#arguments.LabelIDs#)
		</cfquery>
	<cfelse>
		<cfquery name="setBuildInfo" datasource="#application.datasource#">
			UPDATE 	Work_Request
			SET builtOnProd = '#arguments.BuiltDateProd#',builtOnStage = '#arguments.BuiltDateStage#'
			WHERE 	BA_Ticket_Number in (#arguments.LabelIDs#)
		</cfquery>
	</cfif>
	<cfquery name="setStageToProd" datasource="#application.datasource#">
		UPDATE 	Work_Request
		SET builtOnStage = builtOnProd
		WHERE  builtOnStage is  NULL
		AND builtOnProd is NOT NULL
	</cfquery>
	<cfreturn  #arguments.LabelIDs#>
</cffunction>

<cffunction name="UpdateWRStatus" access="remote" hint="Update WR status from punchlist by webservice" output="false" returntype="string">
	<cfargument name="BA_Ticket_Number" type="string" required="true" access="private">
	<cfargument name="Item_Status" type="string" required="true" access="private">
	
	<cfquery name="Update_WRStatus" datasource="#application.datasource#">
		UPDATE 	Work_Request
		SET 	Item_Status = <cfqueryparam value="#arguments.Item_Status#" cfsqltype="CF_SQL_VARCHAR">
		WHERE 	BA_Ticket_Number in ('#arguments.BA_Ticket_Number#')
	</cfquery>
	<cfif #arguments.Item_Status# eq "Complete">
		<cfquery name="Update_CompletedDate" datasource="#application.datasource#">
			update 	work_request
			set 	Completed_Date  = getdate()
			where 	NULLIF(Completed_Date, '') is null 	
			and 	BA_Ticket_Number in ('#arguments.BA_Ticket_Number#')
		</cfquery>
	</cfif>

	<!--- ----------------------------------------
	<cfquery name="GetUserCreated" datasource="#application.datasource#">
		SELECT 	User_Created,Work_Title
		FROM 	Work_Request
		WHERE 	BA_Ticket_Number = #arguments.BA_Ticket_Number#
	</cfquery>
	<cfif GetUserCreated.recordcount GT 0>
		<!--- Get user contact info --->
		<cfoutput>
		<cfquery name="GetUserInfo" datasource="#application.datasource#">
			SELECT Name_First, Name_Last, User_Email, User_Code, Work_Phone_1, Work_Phone_2, Work_Phone_3
			FROM _Users WHERE User_ID = '#GetUserCreated.User_Created#'
		</cfquery>
		<cfquery name="SupportEmail" datasource="#application.datasource#">
			SELECT BA_Support_Email
			FROM _Application_Settings
		</cfquery>
					
		<!--- Send Email --->
		<CF_EMAILWRAPPER 
		TO						=	"#GetUserInfo.User_Email#"
        		FROM						=	"#SupportEmail.BA_Support_Email#"
        		SUBJECT						=	"Work Request ###arguments.BA_Ticket_Number# has been updated"
		TYPE						=	"html" 
		messagetype					=	"1" 
		generatedby					=	"2" 
		apparea						=	"10"  <!---Customer settings --->
		userid						=	"">
		
		The work request <strong>#GetUserCreated.Work_Title#</strong> has been updated by Blacksmith. 
		You can review the work request in settings, in the administrator section under "work requests".
		<p></p>
		</CF_EMAILWRAPPER>
		</cfoutput>
	</cfif>
	--->
	<cfreturn  #arguments.BA_Ticket_Number#>
</cffunction>

<cffunction name="UpdatePunchID" access="remote" hint="Update WR status from punchlist by webservice" output="false" returntype="string">
	<cfargument name="BA_Ticket_Number" type="string" required="true" access="private">
	<cfargument name="WR_ID" type="string" required="true" access="private">
	<cfquery name="Update_WR" datasource="#application.datasource#">
		UPDATE 	Work_Request
		SET 	BA_Ticket_Number = <cfqueryparam value="#arguments.BA_Ticket_Number#" cfsqltype="CF_SQL_VARCHAR">
		WHERE 	Work_Request_ID = #arguments.WR_ID#
		and (BA_Ticket_Number is  NULL or BA_Ticket_Number = 0)
	</cfquery>
</cffunction>

<cffunction name="GetAppWRIDmissedPunchID" access="remote" hint="Update WR status from punchlist by webservice" output="false" returntype="string">
	<cfargument name="FromDate" type="string" required="true" access="private">
	<cfargument name="ToDate" type="string" required="true" access="private">

	<cfquery name="Get_WR" datasource="#application.datasource#">
		select work_request_ID
		from work_request
		where deleted = 0
		and Created_Date <  '#arguments.ToDate# 23:59:56'
		and Created_Date  >  '#arguments.FromDate#'
		and (BA_Ticket_Number is  NULL or BA_Ticket_Number = 0)
		order by work_request_ID
	</cfquery>
	<cfset AllWRID = ValueList(Get_WR.work_request_ID,",")>
	<cfreturn  #AllWRID#>
</cffunction>

<cffunction name="GetAppWRID" access="remote" hint="Update WR status from punchlist by webservice" output="false" returntype="string">
	<cfargument name="FromDate" type="string" required="true" access="private">
	<cfargument name="ToDate" type="string" required="true" access="private">

	<cfquery name="Get_WR" datasource="#application.datasource#">
		select work_request_ID,BA_Ticket_Number,work_Title
		from work_request
		where deleted = 0
		and Created_Date <  '#arguments.ToDate#'
		and Created_Date  >  '#arguments.FromDate#'
		order by work_request_ID
	</cfquery>
	<cfset useLakebaseForGet_Doc_Path = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGet_Doc_Path>
	<cftry>
		<cfset Get_Doc_Path = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"limit" = "1",
				"select" = "document_path"
			}), "document_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Doc_Path = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Doc_Path>
<cfquery name="Get_Doc_Path" datasource="#application.datasource#">
		select Top 1 Document_Path
		from _Application_Settings
	</cfquery>
</cfif>
	
	<cfsilent>
		<cfsavecontent variable="contentElements">
			<cfoutput QUERY="Get_WR">
				#Get_WR.work_request_ID#--#Get_WR.BA_Ticket_Number#--#Get_WR.work_Title#<br>
			</cfoutput>
		</cfsavecontent>
		<cfoutput>
		<cfif Get_Doc_Path.Document_Path EQ "">
			<cfset currentPath = getDirectoryFromPath(getCurrentTemplatePath())>
			<cfset Doc_Path =  left(trim(currentPath), find("AwayX\",currentPath)-1)>
			<cfset Get_Doc_Path.Document_Path = "#Doc_Path#AwayX\Common_Documents">
		</cfif>
		<cffile action="write" file ="#Get_Doc_Path.Document_Path#\Temp_Files\Documents\Temp_Uploaded_doc\WR\All_activeWR_#DateFormat(now(), 'yyyymmdd')#.htm" output ="#contentElements#" addnewline="yes">
		</cfoutput>
	</cfsilent>
</cffunction>

<cffunction name="GetOpenWR" access="remote" hint="Update WR status from punchlist by webservice" output="false" returntype="string">
	<cfargument name="FromDate" type="string" required="false" access="private" default="" />
	<cfargument name="ToDate" type="string" required="false" access="private" default="" />
	
	<cfquery name="Get_OpenWR" datasource="#application.datasource#">
		select BA_Ticket_Number
		from work_request
		where item_status not like '%Complete%'
		and item_status not like '%Declined%'
		and item_status not like '%Duplicate%'
		and item_status not like '%Next Service%'
		and Deleted = 0
		and BA_Ticket_Number is not NULL
		<cfif #arguments.ToDate# NEQ "">
		and Created_Date <= '#arguments.ToDate# 23:59:56'
		</cfif>
		<cfif #arguments.FromDate# NEQ "">
		and Created_Date >= '#arguments.FromDate#'
		</cfif>
		order by BA_Ticket_Number DESC
	</cfquery>
	<cfset AllOpenWR = ValueList(Get_OpenWR.BA_Ticket_Number,",")>
	<cfreturn  #AllOpenWR#>
</cffunction>

<cffunction name="GetWRPunchID_Status" access="remote" hint="Get WR status and Punch id" output="false" returntype="string">
	<cfargument name="FromDate" type="string" required="false" access="private" default="" />
	<cfargument name="ToDate" type="string"  required="false" access="private" default="" />
	
	<cfquery name="Get_WRPunchID_Status" datasource="#application.datasource#">
		select BA_Ticket_Number,Item_Status
		from work_request
		where Deleted = 0
		and BA_Ticket_Number is not NULL
		and BA_Ticket_Number > 0
		<cfif #arguments.ToDate# NEQ "">
		and Created_Date <= '#arguments.ToDate# 23:59:56'
		</cfif>
		<cfif #arguments.FromDate# NEQ "">
		and Created_Date >= '#arguments.FromDate#'
		</cfif>
		order by BA_Ticket_Number DESC
	</cfquery>
	<cfset AllWR = ValueList(Get_WRPunchID_Status.BA_Ticket_Number,",")>
	<cfset AllWR_status = ValueList(Get_WRPunchID_Status.Item_Status,",")>
	<cfset AllWR = "#AllWR#,#AllWR_status#">
	<cfreturn  #AllWR#>
</cffunction>

<cffunction name="Update_CodeChange" access="remote" hint="Update Code_Change from punchlist by webservice" output="false" returntype="string">
	<cfargument name="BA_Ticket_Number" type="string" required="true" access="private">
		
	<cfquery name="Update_CodeChange" datasource="#application.datasource#">
		UPDATE 	Work_Request
		SET 	Code_Change = 1
		WHERE 	BA_Ticket_Number in ('#arguments.BA_Ticket_Number#')
	</cfquery>
</cffunction>

</cfcomponent>
