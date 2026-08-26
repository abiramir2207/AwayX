<cfparam name="HTTPServiceSessionExpired" default="0">

<cfset SessionExpired = 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!-----  Check session against Session_Tracker ------->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET sessionOK=false>
	<CFSET thisSessionID=Session.SessionID>

	<!--- set in Application_Vars.cfm - :: populated from General_Settings.Session_Expiration_Length field --->
	<CFSET session_time = Application.Session_Expiration_Length >

	<CFQUERY NAME="Get_Session_Status" datasource="#application.datasource#">
		SELECT		Session_ID, DateDiff(s, Session_Date_Time_Stamp, GetDate()) AS session_delta
		FROM		Session_Tracker
		WHERE		Session_User_ID	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	
	<CFIF Get_Session_Status.recordCount GT 0>
		<CFIF Get_Session_Status.Session_ID EQ thisSessionID>
			<CFSET sessionOK = true>
		</CFIF>
	</CFIF>
	
	<!--- check for a valid profile id --->
	<cfquery name="getProfileData" datasource="#application.datasource#">
		SELECT Profiles_id
		FROM Profiles
		WHERE Profiles_id = <cfqueryparam value="#request.Accessstructure.Profiles_ID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfif getProfileData.recordcount EQ 0>
		<cfset sessionOK=false>
	</cfif>

	<!--- auto log out :: Mark S 9/15/22 - Not sure if this has ever been used or how it works--->
	<!--- <cfinclude template="/user_auto_logout.cfm"> --->
	
	<CFIF NOT sessionOK>
		 <!--- Milan (24104) - CGI.SCRIPT_NAME IS "/", when a call is made from flex to mvc.models directly.
      		Clicking on "Details" link and saving favorites on program search are such examples. In these cases
			also, we need to know if the session has expired. Since, calls made directly to mvc.models do not understand
			cflocation, this condition is being used.
			--->
		<cfif CGI.SCRIPT_NAME NEQ "/" AND CGI.SCRIPT_NAME neq "/flex/HTTPService/program/getHTTPServiceData.cfm">
			<CFLOCATION URL="/session_expired.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">
		</cfif>
	</CFIF>

	<CFSET session_delta=Get_Session_Status.session_delta>
	<CFSET session_delta=session_delta/(24*60*60)>

		<!--- Test how long since the last activity time stamp --->
		<CFIF session_delta GT session_time>
			<!--- If the session time stamp is greater than session_time, bark... --->
		  <!--- Milan (24104) - CGI.SCRIPT_NAME IS "/", when a call is made from flex to mvc.models directly.
      		Clicking on "Details" link and saving favorites on program search are such examples. In these cases
			also, we need to know if the session has expired. Since, calls made directly to mvc.models do not understand
			cflocation, this condition is being used.
			--->
			<cfif CGI.SCRIPT_NAME NEQ "/" AND CGI.SCRIPT_NAME neq "/flex/HTTPService/program/getHTTPServiceData.cfm">
				<CFLOCATION URL="/session_expired.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">
			</cfif>
		<CFELSE>
			<CFIF NOT ListContains(CGI.SCRIPT_NAME, "xm/Message_Find.cfm")>
				<!--- Otherwise record the current time --->
				<CFQUERY NAME="Update_Session_Status" datasource="#application.datasource#">
					UPDATE	Session_Tracker
					SET		Session_Date_Time_Stamp	=	GetDate()
					WHERE	Session_User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
			</CFIF>
		</CFIF>	

	<!--- Milan (24104)  - If CF session has expired AND CGI.SCRIPT_NAME IS "/" (CGI.SCRIPT_NAME IS "/", when a call is made 
			from flex to mvc.models directly.)
			SessionExpired is set to 1. application.cfc on mvc.models is extending the application.cfc on the web root.
			application.cfc on mvc.models has an "OnError" function which gets fired whenever there is an error. I am purposely 
			calling an undefined variable (PassSessionExpiredToFlex) here, and then using try/catch and cfthrow. We need all 
			these to trigger the "OnError" function on mvc.models.
			The HTTPservice call (refresh data from flex) does not trigger the error in flex with the "site_wide_error_handler.cfm"
			in the CF Admin. That is why we set HTTPServiceSessionExpired to 1 in that case.
	--->	
	<cfif (sessionOK eq false OR session_delta GT session_time) AND (CGI.SCRIPT_NAME EQ "/" OR CGI.SCRIPT_NAME eq "/flex/HTTPService/program/getHTTPServiceData.cfm")>
	<cfif CGI.SCRIPT_NAME eq "/flex/HTTPService/program/getHTTPServiceData.cfm">
			<cfset HTTPServiceSessionExpired = 1>
		<cfelse>	
			<cfset SessionExpired = 1>
			<!--- Throw an error. This will call the "Onerror" function on mvc/models/Application.cfc --->
			<cfthrow type="Any" detail="SessionTimeout" message="Session has Timed out" />						
		</cfif>
	</cfif>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!-----  End Check session against Session_Tracker ------->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->