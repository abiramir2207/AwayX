<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Turn on Client and Session variables capabilities (to enable CFTOKEN & CFID only)				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFAPPLICATION NAME="" CLIENTMANAGEMENT="Yes" SESSIONMANAGEMENT="Yes">



<!--- Link to the main style sheet																	 ---><HEAD>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<!--- Custom tag that gets the name of the current template file									 --->
<CF_TemplateName>

<!--- Delimited list of trusted files that we don't want application.cfm acting upon				 --->
<CFSET TrustList="
		/index.cfm,
		/index2.cfm,
		/enter.cfm,
		/enter_administration_login.cfm,
		/getie.cfm,
		/reset_login_status.cfm,
		/session_expired.cfm">


		

                
		
<!--- If current page is not in the list of the trusted files execute application.cfm				 --->
<CFIF ListContainsNoCase(Variables.TrustList, #CGI.SCRIPT_NAME#) EQ 0>


	
	<!--- If the cookie has expired redirect user to the home page									 --->
	<CFIF isdefined("cookie.User_Info") EQ FALSE OR cookie.User_Info EQ "">
	<CFLOCATION URL="/logoff.cfm" ADDTOKEN="No">
	</CFIF>

	<!--- Deserialize WDDX user info packet that lives in the cookie --->
	<CFWDDX ACTION="WDDX2CFML" INPUT="#cookie.User_Info#" OUTPUT="AccessStructure">






	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!-----  Check session against Session_Tracker ------->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET sessionOK=false>
	<CFSET thisSessionID=Session.SessionID>
		
		
	<!--- Retrieve the length of time before expiring --->	
	<cfset useLakebaseForGet_Session_Window = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGet_Session_Window>
	<cftry>
		<cfset Get_Session_Window = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "session_expiration_length"
			}), "session_expiration_length"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Session_Window = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Session_Window>
<CFQUERY NAME="Get_Session_Window" datasource="#application.datasource#">
		Select	Session_Expiration_Length
		From	General_Settings
	</CFQUERY>
</cfif>

	
	<!--- If there is no data in the session expiration field, put 15 minutes in there --->
	<CFIF Get_Session_Window.recordcount EQ 0>
		<CFQUERY NAME="Get_Session_Window" datasource="#application.datasource#">
			Update	General_Settings
			Set		Session_Expiration_Length		=	0.0104166666667,
					Session_Expiration_Changed_By	=	'#accessstrucutre.User_ID#'
		</CFQUERY>
	<CFELSE>
		<CFSET session_time=0.0104166666667><!--- 0.0104166666667 represents 15 minutes --->
	</CFIF>	

	<CFSET session_time=Get_Session_Window.Session_Expiration_Length>
	<cfset useLakebaseForGet_Session_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_tracker")>
<cfif useLakebaseForGet_Session_Status>
	<cftry>
		<cfset Get_Session_Status = application.oLakebase.toQuery(
			application.oLakebase.selectRows("session_tracker", {
				"session_user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "session_id,session_date_time_stamp"
			}), "session_id,session_date_time_stamp"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Session_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Session_Status>
<CFQUERY NAME="Get_Session_Status" datasource="#application.datasource#">
		Select		Session_ID, Session_Date_Time_Stamp
		From		Session_Tracker
		Where		Session_User_ID	= '#request.AccessStructure.User_ID#'
	</CFQUERY>
</cfif>
	
	
	<CFIF Get_Session_Status.recordCount GT 0>
		<CFIF Get_Session_Status.Session_ID EQ thisSessionID>
			<CFSET sessionOK=true>
		</CFIF>
	</CFIF>
	
	
	
	<CFIF NOT sessionOK>
		<!-----<CFLOCATION URL="/try_again.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">------->
		<CFLOCATION URL="/session_expired.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">
	</CFIF>

	<CFSET session_delta=evaluate(now()-Get_Session_Status.Session_Date_Time_Stamp)>

<!--- 
		<CFOUTPUT>#Get_Session_Status.Session_Date_Time_Stamp#</CFOUTPUT><BR>
		<CFOUTPUT>#now()#</CFOUTPUT><BR>
		<CFOUTPUT>#session_delta#</CFOUTPUT>
 --->

		<!--- Test how long since the last activity time stamp --->
		<CFIF session_delta GT session_time>
			<!--- If the session time stamp is greater than session_time, bark... --->
			<CFLOCATION URL="/session_expired.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">
		<CFELSE>
			<!--- Otherwise record the current time --->
			<cfset useLakebaseForUpdate_Session_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_tracker")>
<cfif useLakebaseForUpdate_Session_Status>
	<cftry>
		<cfset application.oLakebase.updateRows("session_tracker",
			{
				"session_user_id" = "eq.#request.AccessStructure.User_ID#"
			},
			{
				"session_date_time_stamp" = "#createodbcdatetime(now())#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Session_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Session_Status>
<CFQUERY NAME="Update_Session_Status" datasource="#application.datasource#">
				UPDATE	Session_Tracker
				SET		Session_Date_Time_Stamp	=	#createodbcdatetime(now())#
				WHERE	Session_User_ID = '#request.AccessStructure.User_ID#'
			</CFQUERY>
</cfif>
		</CFIF>


	
		

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!-----  End Check session against Session_Tracker ------->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	

	
	
	<!--- <CFDUMP VAR="#cookie.User_Info#"> --->
	
	
	<!--- Get the fully qualified name of the server												 --->
	<CFSET HOSTNAME=CGI.HTTP_HOST>
	
	<!--- Get the drive letter where the root lives													 --->
	<CFIF CGI.HTTP_HOST EQ "WEB24">
		<CFSET DRIVELETTER="E">
	<CFELSE>
		<cfset temp = listgetat(CGI.PATH_TRANSLATED, 2, "\")>
		<cfset temp = listgetat(temp, 1, "$")>
		<CFSET DRIVELETTER=temp>
	</CFIF>

	
	<!--- Generate the encryption key																 --->
	<CFSET key=hash(log(((evaluate(Session.CFID&Session.CFToken))^pi())^(1/sqr(2)))*(10000))>

	<!--- Code to center popup windows																 --->
	<SCRIPT LANGUAGE="JavaScript">
	function NewWindow(mypage, myname, w, h, scroll, resize)
	{
		var winl = (screen.width - w) / 2;
		var wint = (screen.height - h) / 2;
		winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize
		win = window.open(mypage, myname, winprops)
		if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
	}
	</SCRIPT>




<CFELSE>
	<!--- If current page is in the list of the trusted files don't do anything						 --->
</CFIF>





