<CFSILENT>
<!------Application_Common.cfm----->

<!---------
Which is the Application Home Page and login page
Is used throughout the application, so it's better to keep it in a variable that to be hardcoded
------------->
<cfscript>
    if (structKeyExists(application, "HomePage") eq false) {
        application.HomePage          = "/Manufacturers/home.cfm";
        application.MainFrameHomePage = "/Manufacturers/home_new.cfm";
        application.LoginPage         = "/index.htm";
    }
</cfscript>
<cfparam name="DoNotShowJS" default="0">

<cfset request.TemplateName = replace( listLast(cgi.script_name, '/'), '/', '' )>
<!--- Dev Note: drachala; D28791&D28739: Search by id does not return results for distributors on the bb payee page  START
Added/Changed: Added condition in if statement to prevent add JS to results from CFC.--->
<cfif arrayFindNoCase([ 'ez_button_programs.cfm'   <!---32419--->
                       ,'csv.cfm'
                       ,'processing.cfm'
                       ,'uploadOneFile.cfm'
                       ,'home_new.cfm'
                       ,'Ded_ExportData.cfm' ], request.TemplateName) or (cgi.script_name contains "/MatchCentral") or (cgi.script_name contains "/ajax") OR (cgi.script_name contains ".cfc")>
	<cfset DoNotShowJS = 1 />
</cfif>
<!------
The application variables which was in this file
have been moved to the file /Application_Vars.cfm
which is included in /application_datasource.cfm
The purpose of this is so that the files which are outside of the main Application.cfm in the root dir,
also can access these variables.
----->
</CFSILENT>

<cfparam name="Session.DoNotRunThisApplicationCFM" default="0">
<CFIF Session.DoNotRunThisApplicationCFM EQ 0>
<cfif DoNotShowJS eq 0>
<!--- Link to the main style sheet	--->
<!---
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2015 jun 29 :: added modification time stamp to .css, .js href to refresh browser caching automatically when changes are made
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--->
<cfset variables.includeFiles = "/common_files/main_style.css, /script/javascript/default.js">
<cfif findNoCase("Chrome", CGI.HTTP_User_Agent)>   <!--- chromefix --->
	<cfset variables.includeFiles = variables.includeFiles & ", /script/javascript/nonIE.js">
</cfif>
<!---  71856 - retail-237: fix problems in window resizing on home page and retail pages --->
<cfset variables.extraElements = "">
<cfoutput><cfsavecontent variable="variables.htmlHead"><cfmodule template="/customTags/include.cfm" file_to_include="#variables.includeFiles#"/> <link rel="SHORTCUT ICON" href="#application.appsettingsget.getFaviconPath()#"/>#variables.extraElements#</cfsavecontent></cfoutput>
<!--- <cfdump var="#variables.htmlHead#" abort="true"> --->
<!---2011 Jul 12 - ChrisN - inserted common styles & common js into html head--->
<cfhtmlhead text="#variables.htmlHead#">
</cfif>
<CFSILENT>
<!--- Delimited list of trusted files that we don't want application.cfm acting upon --->
<CFSET TrustList="
		/index.cfm,
		/index2.cfm,
		/enter.cfm,
		/getie.cfm,
		/reset_login_status.cfm,
		/session_expired.cfm,
		/logoff.cfm,
		/components/webservices/RemoteReleaseTracker.cfc,
		/flex/HTTPService/program/getHTTPServiceData.cfm,
		/flex/HTTPService/Report/get_csv_data_for_user.cfm,
		/BBUploadListener.cfc,
		/blacksmithlogin.cfm,
		/blacksmithlogin_enter.cfm,
	   	/Customer_Profile/customer_profile.cfm">

<!--- If current page is not in the list of the trusted files execute application.cfm	--->
<!--- Milan (24104) - CGI.SCRIPT_NAME IS "/", when a call is made from flex to mvc.models directly.
      Clicking on "Details" link and saving favorites on program search are such examples. In these cases
	    also, we need to know if the session has expired.
--->

<!--- ********************************************************************************************
 83860 Sugar Customer Profile
******************************************************************************************** ---->
<!--- Delimited list of trusted files For Customer Profile, we only want these files accessible by users --->
<CFSET CustomerProfileTrustList="
		/Customer_Profile/customer_profile.cfm,
		/mvc/Models/Program/ProgramManager.cfc,
		/mvc/Models/Program/Search_Program.cfc,
		/Programs/ajax/program_data.cfm,
		/Programs/program_search.cfm,
		/Scorecard/program_display.cfm,
		/Common_Files/contracts/contract_details.cfm,
		/reportwriter/performance_reports/revisionreport.cfm,
		/reportwriter/performance_reports/program_changes.cfm,
		/Common_Files/contracts/payment_history/view_billback_payment_history.cfm
		/components/programs/PaymentHistory/PaymentHistoryManager.cfc
		/Common_Files/contracts/ajax/billback_details.cfm,
		/common_files/csv.cfm,
	   	/CID_Wrapper.cfm">

<CFIF isdefined("url.CPAccess") AND url.CPAccess NEQ "" AND CGI.SCRIPT_NAME NEQ "/Customer_Profile/customer_profile.cfm"
	  AND ListContainsNoCase(Variables.CustomerProfileTrustList, #CGI.SCRIPT_NAME#) NEQ 0>
	<!--- Decrypt --->
	<cf_cryp type="de" string ="#url.CPAccess#" key="#Session.SessionID#">
	<CFSET DeCPAccess = cryp.value>

	<cfset InvalidCustomerProfileSession = 1 />
	<cfif isdefined("session.AccessStructureExternal")>
		<!--- Check if the decrypted value matches with the session value --->
		<cfif DeCPAccess neq "" and DeCPAccess eq session.AccessStructureExternal.External_Customer_Profile_Access_CustNum>
			<CFSET request.AccessStructure = session.AccessStructureExternal />
			<cfset InvalidCustomerProfileSession = 0 />
		</cfif>
	</cfif>
	<cfif InvalidCustomerProfileSession>
		<!--- Rediect to customer_profile.cfm
		If URL.CustNum is invalid, customer_profile will show the message.
		--->
		<cflocation url="/Customer_Profile/customer_profile.cfm?CustNum=#DeCPAccess#">
	</cfif>
</CFIF>


<CFIF isdefined("request.AccessStructure.External_Customer_Profile_Access") AND request.AccessStructure.External_Customer_Profile_Access EQ "1">
	<!--- Don't do extra checks done in below section --->
	<cfscript>
		request.app_general_functions = CreateObject("component","components.general.General_Functions");
		request.key = request.app_general_functions.GenerateKey();
	</cfscript>

<CFELSEIF ListContainsNoCase(Variables.TrustList, #CGI.SCRIPT_NAME#) EQ 0 OR CGI.SCRIPT_NAME EQ "/">

		<!--- If the cookie has expired redirect user to the home page 							*****************-------
		----- Keep this out of the session check below in case user opens app in second browser *****************-------
		----- This will logs them out in that scenario as well            						*****************------->
	<CFIF isdefined("cookie.User_Info") EQ FALSE OR cookie.User_Info EQ "" OR isdefined("cookie.User_Id") EQ FALSE>

	<!--- Dev Note:
	For some reason, "cookie.user_Info" gets deleted after being set. Here we are resetting "cookie.user_Info" from session.AccessStructure.
	--->
	<cfif isdefined("session.AccessStructure") and isdefined("cookie.User_Id") EQ TRUE AND (session.AccessStructure.User_id eq cookie.User_Id)>
		<!--- Serialize packet --->
		<CFWDDX ACTION="CFML2WDDX" INPUT="#session.AccessStructure#" OUTPUT="myPacket">

		<!--- Create cookie with contents of the WDDX packet --->
		<CFCOOKIE NAME="User_Info" VALUE="#myPacket#">
	</cfif>

		<!--- Re-check the contents of the cookie, before logging out. --->
        <CFIF isdefined("cookie.User_Info") EQ FALSE OR cookie.User_Info EQ "" OR isdefined("cookie.User_Id") EQ FALSE>
			<CFLOCATION URL="/logoff.cfm" ADDTOKEN="No">
		</CFIF>
	</CFIF>

	<!--- Put AccessStructure in A session var.  This may reduce WDDX parse errors That some users experience *****************
	-----	make sure the session user_id = the cookie user_id in case user opens second browser and logs in. *****************--->
	<cfif isdefined("session.AccessStructure") and (session.User_id eq cookie.User_Id)>
		<cfset request.AccessStructure = Session.AccessStructure>
	<cfelse>
		<CFIF Not IsWddx(cookie.User_Info)><!--- ISWDDX check for sporadic parse errors --->
		  <CFLOCATION URL="/logoff.cfm" ADDTOKEN="No">
        </CFIF>



		<!--- Deserialize WDDX user info packet that lives in the cookie --->
		<CFWDDX ACTION="WDDX2CFML" INPUT="#cookie.User_Info#" OUTPUT="request.AccessStructure">
		<!--- Write it to the session to avoid this next time...This may reduce WDDX parse errors--->
		<cfset Session.AccessStructure = request.AccessStructure>
		<cfset Session.User_id = request.AccessStructure.User_ID>
	</cfif>


	<CFINCLUDE TEMPLATE = "/session_tracker.cfm">

	<!--- Get the fully qualified name of the server												 --->
	<CFSET HOSTNAME=CGI.HTTP_HOST>

	<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

	<!--- Get the drive letter where the root lives													 --->
	<CFIF CGI.HTTP_HOST EQ "WEB24">
		<CFSET DRIVELETTER="E">
	<CFELSE>
		<cfset temp = listgetat(CGI.PATH_TRANSLATED, 2, "\")>
		<cfset temp = listgetat(temp, 1, "$")>
		<CFSET DRIVELETTER=temp>
	</CFIF>

	<!--- Generate the encryption key--->
	<!--- <cfinvoke component="components.general.General_Functions" method="GenerateKey" returnVariable="key"> --->
	<cfscript>
		request.key = request.app_general_functions.GenerateKey();
	</cfscript>

<CFELSE>
	<!--- If current page is in the list of the trusted files don't do anything						 --->
</CFIF>
</CFSILENT>
</CFIF>
