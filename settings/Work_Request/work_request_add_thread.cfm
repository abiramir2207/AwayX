
<cfoutput>
	<cfset useLakebaseForGetWorkRequest = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForGetWorkRequest>
	<cftry>
		<cfset GetWorkRequest = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"work_request_id" = "eq.#Work_Request_ID#",
				"select" = "work_title,request_type,app_area,user_created,client_priority,client_reference_number,item_status,urlenvironment,progbbddids,userinfo,errorevent,currentbehavior,expectedbehavior"
			}), "work_title,request_type,app_area,user_created,client_priority,client_reference_number,item_status,urlenvironment,progbbddids,userinfo,errorevent,currentbehavior,expectedbehavior"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetWorkRequest = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetWorkRequest>
<cfquery name="GetWorkRequest" datasource="#application.datasource#">
		select 
			Work_Title,
			Request_Type,
			App_Area,
			User_Created,
			Client_Priority,
			Client_Reference_Number,
			Item_Status,
			URLEnvironment,
			ProgBBDDIDs,
			UserInfo,
			ErrorEvent,
			CurrentBehavior,
			ExpectedBehavior
		from  Work_Request
		where Work_Request_ID = #Work_Request_ID#
	</cfquery>
</cfif>

	<cfset useLakebaseForGetUserInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserInfo>
	<cftry>
		<cfset GetUserInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#GetWorkRequest.User_Created#",
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
		FROM _Users WHERE User_ID = '#GetWorkRequest.User_Created#'
	</cfquery>
</cfif>

	<cfquery name="GetForgeRelease" datasource="#application.datasource#">
			SELECT TOP 1 LEFT(LTRIM(RTRIM(Patch_Number)),3) As Release_Version
			FROM Application_Installation
			ORDER BY Release_Version DESC
	</cfquery> 

	<cfquery name="SupportEmail" datasource="#application.datasource#">
			SELECT BA_Support_Email,MapPunchCompany
			FROM _Application_Settings
	</cfquery>
</cfoutput>

	<!--- send to punchlist --->
	<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">
	<!--- should we replace with a periodically exeucted function like clear cache instead of executing every single time? --->
	<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>
	
		<cfinvoke
			webservice="#Punchlist_URL#"
			method="CreateNewWorkRequest"
			returnvariable="Punch_ID"
			timeout = "300">
				<cfinvokeargument name="Work_Title" value="#GetWorkRequest.Work_Title#">
	           			<cfinvokeargument name="Work_Request_ID" value="#Work_Request_ID#"> <!--- int --->
	           		 	<cfinvokeargument name="Work_Description" value="#GetWorkRequest.CurrentBehavior#"> <!--- text --->
				<cfinvokeargument name="App_Area" value="#GetWorkRequest.App_Area#"><!--- varchar 20 --->
				<cfinvokeargument name="Request_Type" value="#GetWorkRequest.Request_Type#"><!--- varchar 20 --->
				<cfinvokeargument name="User_Created" value="#GetUserInfo.Name_First# #GetUserInfo.Name_Last#"><!--- nvarchar 100 --->
				<cfinvokeargument name="Client_Priority" value="#GetWorkRequest.Client_Priority#"><!--- nvarchar 20 --->
				<cfinvokeargument name="Client_Reference_Number" value="#GetWorkRequest.Client_Reference_Number#"><!--- varchar 50 --->
				<cfinvokeargument name="Installation_URL" value="#Installation_URL#"><!--- varchar 50 --->
				<cfinvokeargument name="Company_Name" value="#Company_Name#">
				<cfinvokeargument name="User_Email" value="#GetUserInfo.User_Email#">
				<cfinvokeargument name="User_Phone_Number" value="#GetUserInfo.Work_Phone_1#-#GetUserInfo.Work_Phone_2#-#GetUserInfo.Work_Phone_3#">
				<cfinvokeargument name="ErrorEvent" value="#GetWorkRequest.ErrorEvent#">
				<cfinvokeargument name="ExpectedBehavior" value="#GetWorkRequest.ExpectedBehavior#">
				<cfinvokeargument name="ProgBBDDIDs" value="#GetWorkRequest.ProgBBDDIDs#">
				<cfinvokeargument name="UserLogInInfo" value="#GetWorkRequest.UserInfo#">
				<cfinvokeargument name="Release_Version" value="#GetForgeRelease.Release_Version#">
				<cfinvokeargument name="MapPunchCompany" value="#SupportEmail.MapPunchCompany#">
				<cfinvokeargument name="BA_Support_Email" value="#SupportEmail.BA_Support_Email#">
				<cfinvokeargument name="URLEnvironment" value="#GetWorkRequest.URLEnvironment#">
				<cfinvokeargument name="AttchDocName" value="#AttchDocName#">
				<cfinvokeargument name="AttchDocActualName" value="#AttchDocActualName#">
				<cfinvokeargument name="FilePathInApp" value="#FilePathInApp#">
		</cfinvoke>

		<!--- Update with punchlist ID --->
		<cfset useLakebaseForUpdatePunchlist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForUpdatePunchlist>
	<cftry>
		<cfset application.oLakebase.updateRows("work_request",
			{
				"work_request_id" = "eq.#Work_Request_ID#"
			},
			{
				"ba_ticket_number" = "#Punch_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdatePunchlist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdatePunchlist>
<cfquery name="UpdatePunchlist" datasource="#application.datasource#">
		UPDATE Work_Request
		SET BA_Ticket_Number = #Punch_ID#
		WHERE Work_Request_ID = #Work_Request_ID#
		</cfquery>
</cfif>
		<!--- end send to punchlist --->