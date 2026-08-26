<cfcomponent>

	<cffunction name="getActive" output="false" returntype="query">

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT Work_Request.*,c.Name_First,  c.Name_Last, c.user_email, u.Name_First +  ' ' + u.Name_Last AS UpdatedBy
			,REPLACE(REPLACE(cast(Notes as varchar(max)), char(13)+char(10), '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'),':&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',': ') as NotesSpace
			FROM 	Work_Request
			LEFT JOIN  _Users c on Work_Request.User_Created = c.User_ID
			LEFT JOIN  _Users u on Work_Request.Updated_By = u.User_ID
			WHERE 	Work_Request.Deleted = 0
			and Item_Status <> 'Complete'
			and Item_Status <> 'Declined'
			and Item_Status <> 'Duplicate'
			ORDER BY 	Work_Request_ID DESC
		</cfquery>

		<cfreturn qGetActiveComps />

   	</cffunction>

	<cffunction name="search" output="false" returntype="query">
		<cfargument name="Request_Desc" required="false" default="" />
		<cfargument name="Request_Type" required="false" default="0"  />
		<cfargument name="App_Area" required="false" default="0"  />
		<cfargument name="Client_Priority" required="false" default="0"  />
		<cfargument name="Item_status" required="false" default="0"  />
		<cfargument name="Built_To" required="false" default="0"  />
		<cfargument name="Created_Since_Date" required="false" default=""  />

		<cfif IsDate(arguments.Created_Since_Date) >
			<cfset CreatedSinceDate = #DateFormat(arguments.Created_Since_Date, "mm/dd/yyyy")#/>
		<cfelse>
			<cfset CreatedSinceDate = ""/>
		</cfif>
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT Work_Request.*,c.Name_First,  c.Name_Last, c.user_email, u.Name_First +  ' ' + u.Name_Last AS UpdatedBy
			,REPLACE(REPLACE(cast(Notes as varchar(max)), char(13)+char(10), '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'),':&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',': ') as NotesSpace
			FROM 	Work_Request
			LEFT JOIN  _Users c on Work_Request.User_Created = c.User_ID
			LEFT JOIN  _Users u on Work_Request.Updated_By = u.User_ID
			WHERE Work_Request.Deleted = 0
			<cfif len(trim(arguments.Request_Desc)) GT 0>
			AND
				(
					 Work_Title LIKE '%#arguments.Request_Desc#%'
				OR
					Client_Reference_Number LIKE '%#arguments.Request_Desc#%'
				OR
					Notes LIKE '%#arguments.Request_Desc#%'
				OR
					BA_Ticket_Number LIKE '%#arguments.Request_Desc#%'
				)
			</cfif>
			<cfif len(trim(arguments.Request_Type)) GT 0 AND arguments.Request_Type NEQ 0>
			AND Request_Type LIKE '#arguments.Request_Type#'
			</cfif>
			<cfif len(trim(arguments.App_Area)) GT 0 AND arguments.App_Area NEQ 0>
			AND App_Area LIKE '#arguments.App_Area#'
			</cfif>
			<cfif len(trim(arguments.Client_Priority)) GT 0 AND arguments.Client_Priority NEQ 0>
			AND Client_Priority LIKE '#arguments.Client_Priority#'
			</cfif>
			<cfif (len(trim(arguments.Item_Status))) GT 0 >
				<cfset temp_index = 0>
				AND (
				<cfloop index = "ListElement" list = "#arguments.Item_Status#">
					<cfif temp_index eq 0>
						Item_Status LIKE '#ListElement#'
						<cfset temp_index = 1>
					<cfelse>
						OR   Item_Status LIKE '#ListElement#'
					</cfif>
				</cfloop>
				)
			</cfif>
			<cfif (trim(arguments.Built_To NEQ 0) and  #arguments.Built_To# neq "1,3"  and  #arguments.Built_To# neq "2,4")>

				<cfset build_index = 0>
				AND (

				<cfloop index = "ElementBuild" list = "#arguments.Built_To#">
					<cfif build_index eq 0>
						<cfswitch expression="#Trim(ElementBuild)#">
    						<cfcase value="1">
       							BuiltOnProd > '2000/01/01'
   				 		</cfcase>
    						<cfcase value="2">
       							BuiltOnStage > '2000/01/01'
    						</cfcase>
						<cfcase value="3">
        							BuiltOnProd IS NULL
    						</cfcase>
						<cfcase value="4">
        							BuiltOnStage IS NULL
    						</cfcase>
						</cfswitch>

						<cfset build_index = 1>
					<cfelse>
						<cfswitch expression="#Trim(ElementBuild)#">
   						<cfcase value="1">
       							and BuiltOnProd > '2000/01/01'
    						</cfcase>
    						<cfcase value="2">
       							and BuiltOnStage > '2000/01/01'
    						</cfcase>
						<cfcase value="3">
       							and  BuiltOnProd IS NULL
    						</cfcase>
						<cfcase value="4">
        							and BuiltOnStage IS NULL
    						</cfcase>
						</cfswitch>
					</cfif>
				</cfloop>
				)
			</cfif>
			<cfif len(trim(CreatedSinceDate)) GT 0>
			AND Created_Date >=  '#CreatedSinceDate#'
			</cfif>
			ORDER BY 	Work_Request_ID DESC
		</cfquery>

		<cfreturn qGetActiveComps />

	</cffunction>

	<cffunction name="add" output="false" hint="Function used to add a new component.">
		<cfargument name="Work_Title" required="true" />
		<cfargument name="Request_Type" required="true" />
		<cfargument name="App_Area" required="true" />
		<cfargument name="User_Created" required="true" />
		<cfargument name="Installation_URL" required="true" />
		<cfargument name="Client_Priority" required="true">
		<cfargument name="Client_Reference_Number" required="false">
		<cfargument name="Company_Name" required="true">
		<cfargument name="URLEnvironment" required="true" />
		<cfargument name="ProgBBDDIDs" required="true" />
		<cfargument name="UserInfo" required="true" />
		<cfargument name="ErrorEvent" required="true" />
		<cfargument name="CurrentBehavior" required="true" />
		<cfargument name="ExpectedBehavior" required="true" />
		<cfargument name="MatchAttch" required="false" default=""  />
		<cfset Description ="#arguments.CurrentBehavior#" />

		<!--- Insert into db --->
		<cfquery name="InsertWorkRequest" datasource="#application.datasource#">
		INSERT INTO Work_Request
		(
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
		)
		VALUES
		(
			'#arguments.Work_Title#',

			'#arguments.Request_Type#',
			'#arguments.App_Area#',
			'#arguments.User_Created#',
			'#arguments.Client_Priority#',
			'#arguments.Client_Reference_Number#',
			'1 - Open',
			'#arguments.URLEnvironment#',
			'#arguments.ProgBBDDIDs#',
			'#arguments.UserInfo#',
			'#arguments.ErrorEvent#',
			'#arguments.CurrentBehavior#',
			'#arguments.ExpectedBehavior#'
		)
		SELECT @@Identity AS Work_Request_ID
		</cfquery>


		<!--- Get user contact info --->
		<cfquery name="GetUserInfo" datasource="#application.datasource#">
		SELECT Name_First, Name_Last, User_Email, User_Code, Work_Phone_1, Work_Phone_2, Work_Phone_3
		FROM _Users WHERE User_ID = '#arguments.User_Created#'
		</cfquery>

		<!--- Get Release version --->
		<cfquery name="GetForgeRelease" datasource="#application.datasource#">
			SELECT TOP 1 LEFT(LTRIM(RTRIM(Patch_Number)),3) As Release_Version
			FROM Application_Installation
			ORDER BY Release_Version DESC
		</cfquery>

		<cfquery name="SupportEmail" datasource="#application.datasource#">
			SELECT BA_Support_Email,MapPunchCompany,WRinsertByMail
			FROM _Application_Settings
		</cfquery>


		<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>
		<!--- Send to Punchlist db --->
			<cfif #arguments.MatchAttch# NEQ "">

				<CFQUERY NAME="GetAttachDocs" datasource="#application.datasource#">
					select 	WR_Document_Name,Actual_File_Name
					from	Work_Request_Document
					where 	MatchAttch = '#arguments.MatchAttch#'
					and 	deleted = 0
				</CFQUERY>
			</cfif>
			<cfset AttchDocName =  #ValueList(GetAttachDocs.WR_Document_Name, ",")#>
			<cfset AttchDocActualName =  #ValueList(GetAttachDocs.Actual_File_Name, ",")#>
			<cfset  FilePathInApp = "#Application.Doc_Path#"/>



		<CFTHREAD ACTION="RUN"  name="WR_add_#GetUserInfo.Name_First##GetUserInfo.Name_Last#_#timeFormat(now(), 'HHmmsstt')##DateFormat(now(), 'yyyymmdd')#"  Work_Request_ID="#InsertWorkRequest.Work_Request_ID#"  Installation_URL="#arguments.Installation_URL#"  Company_Name="#arguments.Company_Name#"  AttchDocName="#AttchDocName#"  AttchDocActualName="#AttchDocActualName#"  FilePathInApp="#FilePathInApp#">
			<cfinclude template="work_request_add_thread.cfm">
			<cflog file="WRLog" application="no" text="Insert #Work_Request_ID# to PunchList from #Installation_URL#">
		</CFTHREAD>

<!---
		<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">

		<!--- should we replace with a periodically exeucted function like clear cache instead of executing every single time? --->
		<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>

		<cfinvoke
			webservice="#Punchlist_URL#"
			method="CreateNewWorkRequest"
			returnvariable="Punch_ID"
			timeout = "300">
				<cfinvokeargument name="Work_Title" value="#arguments.Work_Title#">
	           			<cfinvokeargument name="Work_Request_ID" value="#InsertWorkRequest.Work_Request_ID#"> <!--- int --->
	           		 	<cfinvokeargument name="Work_Description" value="#Description#"> <!--- text --->
				<cfinvokeargument name="App_Area" value="#arguments.App_Area#"><!--- varchar 20 --->
				<cfinvokeargument name="Request_Type" value="#arguments.Request_Type#"><!--- varchar 20 --->
				<cfinvokeargument name="User_Created" value="#GetUserInfo.Name_First# #GetUserInfo.Name_Last#"><!--- nvarchar 100 --->
				<cfinvokeargument name="Client_Priority" value="#arguments.Client_Priority#"><!--- nvarchar 20 --->
				<cfinvokeargument name="Client_Reference_Number" value="#arguments.Client_Reference_Number#"><!--- varchar 50 --->
				<cfinvokeargument name="Installation_URL" value="#arguments.Installation_URL#"><!--- varchar 50 --->
				<cfinvokeargument name="Company_Name" value="#arguments.Company_Name#">
				<cfinvokeargument name="User_Email" value="#GetUserInfo.User_Email#">
				<cfinvokeargument name="User_Phone_Number" value="#GetUserInfo.Work_Phone_1#-#GetUserInfo.Work_Phone_2#-#GetUserInfo.Work_Phone_3#">
				<cfinvokeargument name="ErrorEvent" value="#arguments.ErrorEvent#">
				<cfinvokeargument name="ExpectedBehavior" value="#arguments.ExpectedBehavior#">
				<cfinvokeargument name="ProgBBDDIDs" value="#arguments.ProgBBDDIDs#">
				<cfinvokeargument name="UserLogInInfo" value="#arguments.UserInfo#">
				<cfinvokeargument name="Release_Version" value="#GetForgeRelease.Release_Version#">
				<cfinvokeargument name="MapPunchCompany" value="#SupportEmail.MapPunchCompany#">
				<cfinvokeargument name="BA_Support_Email" value="#SupportEmail.BA_Support_Email#">
				<cfinvokeargument name="URLEnvironment" value="#arguments.URLEnvironment#">
				<cfinvokeargument name="AttchDocName" value="#AttchDocName#">
				<cfinvokeargument name="AttchDocActualName" value="#AttchDocActualName#">
				<cfinvokeargument name="FilePathInApp" value="#FilePathInApp#">
		</cfinvoke>

		<!--- Update with punchlist ID --->
		<cfquery name="UpdatePunchlist" datasource="#application.datasource#">
		UPDATE Work_Request
		SET BA_Ticket_Number = #Punch_ID#
		WHERE Work_Request_ID = #InsertWorkRequest.Work_Request_ID#
		</cfquery>
		<!--- end send to punchlist --->
--->
		<cfoutput>
		<cfsilent>
		<cfsavecontent variable="contentElements">
			#dateformat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'HH:mm:sstt')#<br>
			cfinvokeargument name="Work_Title" value="#arguments.Work_Title#"<br>
	       		cfinvokeargument name="Work_Request_ID" value="#InsertWorkRequest.Work_Request_ID#"<br>
	        		cfinvokeargument name="Work_Description" value="#Description#"<br>
			cfinvokeargument name="App_Area" value="#arguments.App_Area#"<br>
			cfinvokeargument name="Request_Type" value="#arguments.Request_Type#"<br>
			cfinvokeargument name="User_Created" value="#GetUserInfo.Name_First# #GetUserInfo.Name_Last#"<br>
			cfinvokeargument name="Client_Priority" value="#arguments.Client_Priority#"<br>
			cfinvokeargument name="Client_Reference_Number" value="#arguments.Client_Reference_Number#"<br>
			cfinvokeargument name="Installation_URL" value="#arguments.Installation_URL#"<br>
			cfinvokeargument name="Company_Name" value="#arguments.Company_Name#"<br>
			cfinvokeargument name="User_Email" value="#GetUserInfo.User_Email#"<br>
			cfinvokeargument name="User_Phone_Number" value="#GetUserInfo.Work_Phone_1#-#GetUserInfo.Work_Phone_2#-#GetUserInfo.Work_Phone_3#"<br>
			cfinvokeargument name="ErrorEvent" value="#arguments.ErrorEvent#"<br>
			cfinvokeargument name="ExpectedBehavior" value="#arguments.ExpectedBehavior#"<br>
			cfinvokeargument name="ProgBBDDIDs" value="#arguments.ProgBBDDIDs#"<br>
			cfinvokeargument name="UserLogInInfo" value="#arguments.UserInfo#"<br>
			cfinvokeargument name="Release_Version" value="#GetForgeRelease.Release_Version#"<br>
			cfinvokeargument name="MapPunchCompany" value="#SupportEmail.MapPunchCompany#"<br>
			cfinvokeargument name="BA_Support_Email" value="#SupportEmail.BA_Support_Email#"<br>
			cfinvokeargument name="URLEnvironment" value="#arguments.URLEnvironment#"<br>
			cfinvokeargument name="AttchDocName" value="#AttchDocName#"<br>
			cfinvokeargument name="AttchDocActualName" value="#AttchDocActualName#"<br>
			cfinvokeargument name="FilePathInApp" value="#FilePathInApp#"<br>
		</cfsavecontent>
		</cfsilent>
		<cffile action="write" file ="#Application.Doc_Path#\Data_Files\Uploaded\settings\work_request\WR\#InsertWorkRequest.Work_Request_ID#.htm" output ="#contentElements#" addnewline="yes">

		<cfif SupportEmail.WRinsertByMail EQ 1>
			<CFMAIL
				TO      ="Workrequest@bigredflame.com;jwei@bigredflame.com"
				FROM	="#application.oApplicationAppSettingsManager.getApplicationAppSettings().getDifferent_From_Address()#"
				SUBJECT	="New Work Request created by  #GetUserInfo.Name_First# #GetUserInfo.Name_Last# for #arguments.Installation_URL#"
				TYPE	=	"html"
				>
				today is #dateformat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'HH:mm:sstt')#<br>
				New Work Request created by  #GetUserInfo.Name_First# #GetUserInfo.Name_Last# for #arguments.Installation_URL#<br>
				Please check punchlist if we have this request recorded.<br>
				#Application.Doc_Path#\Data_Files\Uploaded\settings\work_request\WR\#InsertWorkRequest.Work_Request_ID#.htm<br>
				#contentElements#<br>
			</CFMAIL>
		<cfelse>
			<CFMAIL
				TO 		="jwei@bigredflame.com"
				FROM	="#application.oApplicationAppSettingsManager.getApplicationAppSettings().getDifferent_From_Address()#"
				SUBJECT	="New Work Request created by  #GetUserInfo.Name_First# #GetUserInfo.Name_Last# for #arguments.Installation_URL#"
				TYPE	=	"html"
				>
				today is #dateformat(now(), 'mm/dd/yyyy')# #timeFormat(now(), 'HH:mm:sstt')#<br>
				New Work Request created by  #GetUserInfo.Name_First# #GetUserInfo.Name_Last# for #arguments.Installation_URL#<br>
				Please check punchlist if we have this request recorded.<br>
				#Application.Doc_Path#\Data_Files\Uploaded\settings\work_request\WR\#InsertWorkRequest.Work_Request_ID#.htm<br>
				#contentElements#<br>
			</CFMAIL>
		</cfif>
		</cfoutput>
	<CFELSE>
		<!--- insert to punchlist using DSN--->
		<!--- find punch values that match user selections --->
		<cfparam name="Punch_Priority_ID" default="1">
		<cfquery name="GetPriorityID" datasource="punchlist">
			SELECT Punch_Priority_ID
			FROM Punch_Priority
			WHERE Punch_Priority_Desc LIKE '#trim(arguments.Client_Priority)#'
			AND Punch_Priority_Deleted = 0
		</cfquery>
		<cfif GetPriorityID.Recordcount EQ 1>
			<cfset Punch_Priority_ID = GetPriorityID.Punch_Priority_ID>
		</cfif>

		<cfparam name="Punch_Function_ID" default="50">
		<cfquery name="GetFunctionID" datasource="punchlist">
			SELECT Punch_Function_ID
			FROM Punch_Function
			WHERE Punch_Function_Desc LIKE '%#trim(arguments.App_Area)#%'
			AND Punch_Function_Deleted = 0
		</cfquery>
		<cfif GetFunctionID.Recordcount EQ 1>
			<cfset Punch_Function_ID = GetFunctionID.Punch_Function_ID>
		</cfif>

		<cfparam name="Punch_Type_ID" default="8">
		<cfquery name="GetTypeID" datasource="Punchlist">
			SELECT Punch_Type_ID
			FROM Punch_Type
			WHERE Punch_Type_Desc LIKE '%#trim(arguments.Request_Type)#%'
			AND Punch_Type_Deleted = 0
		</cfquery>
		<cfif GetTypeID.Recordcount EQ 1>
			<cfset Punch_Type_ID = GetTypeID.Punch_Type_ID>
		</cfif>
		<cfparam name="Punch_Company_ID" default="1">
		<!---<cfquery name="GetMapPunchCompany" datasource="#application.datasource#">
			SELECT MapPunchCompany FROM Customer_Settings
		</cfquery>--->
		<CFIF SupportEmail.MapPunchCompany EQ 0 OR SupportEmail.MapPunchCompany EQ "">
			<!---Company name isn't going to be a perfect match for the db, so only use the left bit --->
		<cfset CompanyNameForCompare = left(arguments.Company_Name, 11)>
		<cfquery name="GetCompanyID" datasource="punchlist">
			SELECT Punch_Company_ID
			FROM Punch_Company
			WHERE Punch_Company_Desc LIKE '%#trim(CompanyNameForCompare)#%'
			AND Punch_Company_Deleted = 0
		</cfquery>
		<cfif GetCompanyID.Recordcount EQ 1>
			<cfset Punch_Company_ID = GetCompanyID.Punch_Company_ID>

		<!--- If there's more than one match add back in the rest of the company name --->
		<cfelseif GetCompanyID.Recordcount GT 1>
			<cfquery name="GetCompanyID2" datasource="punchlist">
			SELECT Punch_Company_ID
			FROM Punch_Company
			WHERE Punch_Company_Desc LIKE '%#trim(arguments.Company_Name)#%'
			</cfquery>
				<cfif GetCompanyID2.Recordcount EQ 1>
					<cfset Punch_Company_ID = GetCompanyID2.Punch_Company_ID>
				</cfif>

		<!--- If there's less than one match try fewer characters and see if we get a hit --->
		<cfelse>
			<cfset CompanyNameForCompare2 = left(arguments.Company_Name, 6)>
		 	<cfquery name="GetCompanyID3" datasource="punchlist">
			SELECT Punch_Company_ID
			FROM Punch_Company
			WHERE Punch_Company_Desc LIKE '%#trim(CompanyNameForCompare2)#%'
			</cfquery>
				<cfif GetCompanyID3.Recordcount EQ 1>
					<cfset Punch_Company_ID = GetCompanyID3.Punch_Company_ID>
				</cfif>
		</cfif>
		<CFELSE>
			<cfset Punch_Company_ID = SupportEmail.MapPunchCompany>
		</CFIF>
		<!--- SET DEFAULTS AS FROM MANUAL ENTRY --->
		<cfset DefaultPunchStatusID = 1>
		<cfset DefaultPunchSourceID = 1>
		<cfset DefaultUser = 10>
		<cfset ClientUser = 61>
		<cfset DefaultRelease = 4>
		<cfparam name="GetForgeVersionID.Punch_cvsCiStatus_ID" default=2>
		<cfquery name="GetForgeVersionID" datasource="punchlist">
			Select		Punch_cvsCiStatus_ID
			from 		Punch_cvsCiStatus
			where 		Punch_cvsCiStatus_deleted = 0
			and Punch_cvsCiStatus_DESC like '%#GetForgeRelease.Release_Version#%'


		</cfquery>
		<cfif GetForgeVersionID.Punch_cvsCiStatus_ID GT 2>
			<cfquery name="BuildToID" datasource="punchlist">
				Select		Punch_cvsCiStatus_ID
				from 		Punch_cvsCiStatus
				where 		Punch_cvsCiStatus_deleted = 0
				and		Punch_cvsCiStatus_ID >= #GetForgeVersionID.Punch_cvsCiStatus_ID#
			</cfquery>
			<cfset BuildToIDs = ValueList(BuildToID.Punch_cvsCiStatus_ID,",")>
		<cfelse>
			<cfset BuildToIDs = #GetForgeVersionID.Punch_cvsCiStatus_ID#>
		</cfif>

		<!--- INSERT INTO THE PUNCH DB --->
		<cfquery name="InsertWorkRequestToPunch" datasource="punchlist">
		INSERT INTO Punch
		(
			Punch_Date,
			Punch_Created,
			Punch_Desc,
			Punch_Status_ID,
			Punch_Priority_ID,
			Punch_Function_ID,
			Punch_Type_ID,
			Punch_Title,
			WR_ID,
			Punch_ErrorID,
			Punch_Creator_ID,
			Punch_Owner_ID,
			Punch_Developer_ID,
			Punch_Source_ID,
			Punch_Company_ID,
			Punch_Related_To,
			Work_Request_URL,
			Punch_Origin,
			ExpectedBehavior,
			AssociatedTo,
			Punch_UserID,
			Punch_Last_UpdatedBy,
			Punch_cvsCiStatus_IDs
		)
		VALUES
		(
			getdate(),
			getdate(),
			'#Description#',
			'#DefaultPunchStatusID#',
			'#Punch_Priority_ID#',
			'#Punch_Function_ID#',
			'#Punch_Type_ID#',
			'#arguments.Work_Title#',
			'#InsertWorkRequest.Work_Request_ID#',
			'#arguments.ErrorEvent#',
			'#ClientUser#',
			'#DefaultUser#',
			'#DefaultUser#',
			'#DefaultPunchSourceID#',
			'#Punch_Company_ID#',
			'#arguments.Client_Reference_Number#',
			'#arguments.URLEnvironment#',
			2,
			'#arguments.ExpectedBehavior#',
			'#arguments.ProgBBDDIDs#',
			'#arguments.UserInfo#',
			'#GetUserInfo.Name_First# #GetUserInfo.Name_Last#',
			'0,2,#BuildToIDs#,'
		)
		SELECT @@Identity AS Punch_ID
		</cfquery>


		<!--- Insert into Punch_Work_Request --->
		<cfquery name="InsertToPunchWorkRequest" datasource="punchlist">
		INSERT INTO Punch_Work_Request
		(
			Punch_ID,
			Created_User_Name,
			Created_User_Email,
			Created_User_Phone,
			Requesting_URL,
			BA_Support_Email,
			App_Work_Request_ID,
			URLEnvironment
		)
		VALUES
		(
			'#InsertWorkRequestToPunch.Punch_ID#',
			'#GetUserInfo.Name_First# #GetUserInfo.Name_Last#',
			'#GetUserInfo.User_Email#',
			'#GetUserInfo.Work_Phone_1#-#GetUserInfo.Work_Phone_2#-#GetUserInfo.Work_Phone_3#',
			'#arguments.Installation_URL#',
			'#SupportEmail.BA_Support_Email#',
			'#InsertWorkRequest.Work_Request_ID#',
			'#arguments.URLEnvironment#'
		)
		</cfquery>
		<!--- end insert to punchlist using DSN--->


		<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>
			<cfset Punch_ID  = #Punch_ID# >
		<CFELSE>
			<cfset Punch_ID   = #InsertWorkRequestToPunch.Punch_ID# >
		</CFIF>

		<!--- Update with punchlist ID --->
		<cfquery name="UpdatePunchlist" datasource="#application.datasource#">
		UPDATE Work_Request
		SET BA_Ticket_Number = #Punch_ID#
		WHERE Work_Request_ID = #InsertWorkRequest.Work_Request_ID#
		</cfquery>
	</CFIF>
		<!---
		<cfquery name="InsertToPunchWorkRequestHistory" datasource="punchlist">
			INSERT INTO Punch_Work_Request_History (
				Punch_ID,
				Punch_Desc,
				Punch_Status_ID,
				Punch_Priority_ID,
				Punch_Function_ID,
				Punch_Type_ID,
				Punch_Title,
				Punch_ErrorID,
				Punch_Related_to,
				Work_Request_URL,
				ExpectedBehavior,
				AssociatedTo,
				Punch_Priority_BA_ID,
				Punch_Last_UpdatedBy,
				Punch_Release_Notes

			)
			SELECT Punch_ID,
				Punch_Desc,
				Punch_Status_ID,
				Punch_Priority_ID,
				Punch_Function_ID,
				Punch_Type_ID,
				Punch_Title,
				Punch_ErrorID,
				Punch_Related_to,
				Work_Request_URL,
				ExpectedBehavior,
				AssociatedTo,
				Punch_Priority_BA_ID,
				Punch_Last_UpdatedBy,
				Punch_Release_Notes
			FROM Punch
			WHERE Punch_ID =  #Punch_ID#
		</cfquery>
		--->
		<cfquery name="SupportEmail" datasource="#application.datasource#">
		SELECT BA_Support_Email
		FROM _Application_Settings
		</cfquery>
		<cfif #arguments.MatchAttch# NEQ "">
			<CFQUERY NAME="Get_WR_Document" datasource="#application.datasource#">
				select WR_Document_Name
				from Work_Request_Document
				where 	MatchAttch = '#arguments.MatchAttch#'
				and 	deleted = 0
			</CFQUERY>
			<!--- Update Work Request Document --->
			<cfif Get_WR_Document.recordcount GT 0>
				<CFQUERY NAME="Save_WR_Document" datasource="#application.datasource#">
					update	Work_Request_Document
					set 	Work_Request_ID = 	'#InsertWorkRequest.Work_Request_ID#'
					where 	MatchAttch = '#arguments.MatchAttch#'
				</CFQUERY>
				<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 0>

				<cfquery name="UpdatePunch_File" datasource="punchlist">
					update 	Punch_File
					set	Punch_ID = '#InsertWorkRequestToPunch.Punch_ID#'
					where 	MatchAttch = '#arguments.MatchAttch#'
				</cfquery>
				</CFIF>
			</cfif>
		</cfif>

		<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 0>
		<cfset Punch_ID = "#InsertWorkRequestToPunch.Punch_ID#">

		<cfset emailFrom = "#GetUserInfo.User_Email#">
		<cfset emailTo ="#SupportEmail.BA_Support_Email#">
		<cfset emailSubjetDetails = "The following work request has been submitted by #GetUserInfo.Name_First# #GetUserInfo.Name_Last# for #arguments.Installation_URL# on #dateformat(now(), 'mm/dd/yyyy')#.">
		<cfinclude template="WR_emailFormat_add.cfm">

		<cfset emailTo = "#GetUserInfo.User_Email#">
		<cfset emailFrom ="#SupportEmail.BA_Support_Email#">
		<cfset emailSubjetDetails = "You submitted the following request. It has been assigned Blacksmith number #Punch_ID#.">

		<cfinclude template="WR_emailFormat_add.cfm">
	</CFIF>




		<cflocation url="index.cfm">

   	</cffunction>

	<cffunction name="getComp" output="false" returntype="query" hint="Returns one result">

   		<cfargument name="compId" required="false" default=0 />

		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Work_Request
			WHERE 	Work_Request_ID = #arguments.compId#
		</cfquery>

		<cfreturn qGetComp />

   	</cffunction>

	<cffunction name="delete" output="true" hint="Function used to delete components.">

		<cfargument name="compIds" required="false" default="" />

		<cfquery name="DeletedPunchInfo" datasource="#application.datasource#">
			SELECT BA_Ticket_Number, Work_Title, User_Created
			FROM Work_Request
			WHERE Work_Request_ID IN(#arguments.compIds#)
		</cfquery>

		<CFIF  DeletedPunchInfo.BA_Ticket_Number EQ "" OR DeletedPunchInfo.BA_Ticket_Number EQ 0>
			<cfquery name="diffCreatedTime" datasource="#application.datasource#">
				select DATEDIFF(HOUR, Created_Date,GETDATE()) AS HourDiff,*
				from work_request
				where BA_Ticket_Number is NULL
				and Work_Request_ID IN(#arguments.compIds#)
			</cfquery>
			<cfif diffCreatedTime.HourDiff GT 2>
				<cfquery name="UpdateWR" datasource="#application.datasource#">
					UPDATE 	Work_Request
					SET	Deleted = 1, Deleted_By='#request.AccessStructure.User_ID#',Deleted_On =#now()#,Updated_By='#request.AccessStructure.User_ID#',Updated_On =#now()#
					WHERE	Work_Request_ID IN(#arguments.compIds#)
				</cfquery>
			<cfelse>
				<script type="text/javascript">
					alert("We are processing the selected work request now, please come back a few minutes later.");
				</script>
			</cfif>
		<CFELSE>
		<cfquery name="UpdateWR" datasource="#application.datasource#">

			UPDATE 	Work_Request
			SET		Deleted = 1, Deleted_By='#request.AccessStructure.User_ID#',Deleted_On =#now()#,Updated_By='#request.AccessStructure.User_ID#',Updated_On =#now()#
			WHERE	Work_Request_ID IN(#arguments.compIds#)
		</cfquery>

		<cfquery name="DeletedPunchInfo" datasource="#application.datasource#">
			SELECT BA_Ticket_Number, Work_Title, User_Created
			FROM Work_Request
			WHERE Work_Request_ID IN(#arguments.compIds#)
		</cfquery>

		<cfquery name="SupportEmail" datasource="#application.datasource#">
		SELECT BA_Support_Email
		FROM _Application_Settings
		</cfquery>

		<cfquery name="GetUserInfo" datasource="#application.datasource#">
			SELECT Name_First, Name_Last, User_Email,Work_Phone_1, Work_Phone_2, Work_Phone_3
			FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#'
		</cfquery>
	<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>

			<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">
			<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>
			<cfinvoke
			webservice="#Punchlist_URL#"
			method="WorkRequestDeletedByClient"
			timeout = "300">
				<cfinvokeargument name="BA_Ticket_Number" value="#DeletedPunchInfo.BA_Ticket_Number#"> <!--- text --->
				<cfinvokeargument name="User_Deleted" value="#GetUserInfo.Name_First# #GetUserInfo.Name_Last#">
				<cfinvokeargument name="User_Email" value="#GetUserInfo.User_Email#">
				<cfinvokeargument name="User_Phone" value="#GetUserInfo.Work_Phone_1#">
			</cfinvoke>
		<CFELSE>
			<cfoutput>

		<cfquery name="Get_Punch_Resolution" datasource="punchlist">
			select Punch_Resolution,Punch_Release_Notes
			From Punch
			where Punch_ID = '#Trim(DeletedPunchInfo.BA_Ticket_Number)#'
		</cfquery>
		<cfset Resolution_Modified = "#Get_Punch_Resolution.Punch_Resolution#"&"
The work request ###DeletedPunchInfo.BA_Ticket_Number# -- #DeletedPunchInfo.Work_Title# has been deleted by #GetUserInfo.Name_First# #GetUserInfo.Name_Last#.  #DateFormat(now(), 'mm/dd/yy')# #timeFormat(now(), 'hh:mm')# ET
Contact information: Email: #GetUserInfo.User_Email#; Phone:  #GetUserInfo.Work_Phone_1#">
		<cfset ReleaseNote_Modified = "#Get_Punch_Resolution.Punch_Release_Notes#"&"
The work request ###DeletedPunchInfo.BA_Ticket_Number# -- #DeletedPunchInfo.Work_Title# has been deleted by #GetUserInfo.Name_First# #GetUserInfo.Name_Last#.  #DateFormat(now(), 'mm/dd/yy')# #timeFormat(now(), 'hh:mm')# ET">

		<cfquery name="AddDeletedInfoPunch" datasource="punchlist">
			update Punch
			set 	Punch_Resolution = '#Resolution_Modified#',
				Punch_Release_Notes = '#ReleaseNote_Modified#',
				Punch_Status_ID = '22',
				Punch_Last_UpdatedBy = '#GetUserInfo.Name_First# #GetUserInfo.Name_Last#'
			where Punch_ID = '#Trim(DeletedPunchInfo.BA_Ticket_Number)#'
		</cfquery>

		<cfquery name="PunchInformation" datasource="punchlist">
		SELECT Punch.*,  Punch_Status.Punch_Status_Desc,Punch_Function.Punch_Function_Desc, Punch_Type.Punch_Type_Desc,Punch_Priority.Punch_Priority_Desc
		FROM 	Punch
			LEFT JOIN Punch_Status 	ON Punch.Punch_Status_ID = Punch_Status.Punch_Status_ID
			LEFT JOIN Punch_Function  ON Punch.Punch_Function_ID = Punch_Function.Punch_Function_ID
			LEFT JOIN Punch_Type ON Punch.Punch_Type_ID = Punch_Type.Punch_Type_ID
			LEFT JOIN Punch_Priority ON Punch.Punch_Priority_ID = Punch_Priority.Punch_Priority_ID
			LEFT JOIN Punch_Priority_BA ON Punch.Punch_Priority_BA_ID = Punch_Priority_BA.Punch_Priority_BA_ID
		WHERE  Punch_ID = '#Trim(DeletedPunchInfo.BA_Ticket_Number)#'
		</cfquery>
		<cfset emailSubjet = "Work Request ###DeletedPunchInfo.BA_Ticket_Number# has been deleted">
		<cfset emailSubjetDetails = 	"The work request ###DeletedPunchInfo.BA_Ticket_Number# -- #DeletedPunchInfo.Work_Title# has been deleted by #GetUserInfo.Name_First# #GetUserInfo.Name_Last#.
		You should update the punchlist to reflect this, if necessary.">


<cfinclude template="WR_emailFormat.cfm">


		</cfoutput>
	</CFIF>
	</CFIF>
   	</cffunction>

	<cffunction name="GetListOfRequests" output="true" hint="Use this to return details on a list of work requests -- for primary use in export to XL">
		<cfargument name="WorkRequestList" required="false" default="" />
		<cfdump var="#WorkRequestList#">
		<cfquery name="WorkRequestDetails" datasource="#application.datasource#">
		SELECT Work_Request.*, User_Created.Name_First +  ' ' + User_Created.Name_Last AS Created_By
		FROM Work_Request
			INNER JOIN _Users User_Created
			ON User_Created.User_ID = Work_Request.User_Created
		WHERE Work_Request.Deleted = 0
		AND Work_Request.Work_Request_ID IN (#arguments.WorkRequestList#)
		ORDER BY 	Work_Request.Work_Request_ID DESC
		</cfquery>

		<cfreturn WorkRequestDetails />
	</cffunction>

	<cffunction name="UpdatePunchlistDoc" output="false" hint="Function">
		<cfargument name="InsertStatus" required="true" />
		<cfargument name="BA_Ticket_Number" required="true" />
		<cfargument name="WR_Document_Name" required="true" />
		<cfargument name="Actual_file_name" required="true" />
		<cfargument name="User_ID" required="true" />
		<cfargument name="FilePathInApp" required="true" />
		<cfargument name="sizeoffile" required="true" />
		<cfargument name="MatchAttch" required="false" default=""  />

		<CFIF application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>

		<!--- Send to Punchlist db --->
		<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">

		<!--- should we replace with a periodically exeucted function like clear cache instead of executing every single time? --->
		<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>

		<cfinvoke
			webservice="#Punchlist_URL#"
			method="InsertWorkRequestDoc"

			timeout = "300">
			<cfinvokeargument name="InsertStatus" value="#arguments.InsertStatus#" />
			<cfinvokeargument name="BA_Ticket_Number" value="#arguments.BA_Ticket_Number#" />
			<cfinvokeargument name="WR_Document_Name" value="#arguments.WR_Document_Name#" />
			<cfinvokeargument name="Actual_file_name" value="#arguments.Actual_file_name#" />
			<cfinvokeargument name="User_ID" value="#arguments.User_ID#" />
			<cfinvokeargument name="FilePathInApp" value="#arguments.FilePathInApp#" />
			<cfinvokeargument name="sizeoffile" value="#arguments.sizeoffile#" />

		</cfinvoke>
		<!--- end send to punchlist --->
		<CFELSE>
			<!--- update punchlist using DSN --->
			<!--- INSERT/UPDATE Punch_File --->
			<cfif #arguments.InsertStatus# eq "1">
			<cfquery name="InsertToPunch_File" datasource="punchlist">
				INSERT INTO Punch_File
				(
					Punch_ID,
					Punch_File_Name,
					Punch_File_Name_Saved_As,
					Uploaded_By,
					FilePathInApp,
					Punch_File_Size,
					MatchAttch

				)
				VALUES
				(
				'#arguments.BA_Ticket_Number#',
				'#arguments.WR_Document_Name#',
				'#arguments.Actual_file_name#',
				'#arguments.User_ID#',
				'#arguments.FilePathInApp#',
				'#arguments.sizeoffile#',
				'#arguments.MatchAttch#'
				)
			</cfquery>
			<cfelse>
			<cfquery name="UpdatePunch_File" datasource="punchlist">
				Update Punch_File
				set deleted = 1
				where Punch_ID = '#arguments.BA_Ticket_Number#'
				and 	Punch_File_Name ='#arguments.WR_Document_Name#'
				and 	Punch_File_Name_Saved_As ='#arguments.Actual_file_name#'
			</cfquery>
			</cfif>
		</CFIF>
		<!--- end punchlist using DSN --->
	</cffunction>

</cfcomponent>