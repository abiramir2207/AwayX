<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Turn on Client and Session variables capabilities (to enable CFTOKEN & CFID only)				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFAPPLICATION NAME="" CLIENTMANAGEMENT="Yes" SESSIONMANAGEMENT="Yes">



<!--- Link to the main style sheet																	 --->
<HEAD>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<!--- Custom tag that gets the name of the current template file									 --->
<CF_TemplateName>

<!--- Delimited list of trusted files that we don't want application.cfm acting upon				 --->
<CFSET TrustList="
		/index.cfm,
		/enter.cfm,
		/logoff.cfm,
		/getie.cfm,
		/reset_login_status.cfm,
		/try_again.cfm">


		

                
		
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
	
	<CFQUERY NAME="Get_Session_Status" datasource="#application.datasource#">
		Select		Session_ID
		From		Session_Tracker
		Where		Session_User_ID	= '#request.AccessStructure.User_ID#'
	</CFQUERY>


	<CFIF Get_Session_Status.recordCount GT 0>
		<!-----<CFIF Get_Session_Status.Session_ID EQ "">
			<CFLOCATION URL="/logoff.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">
		<CFELSEIF Get_Session_Status.Session_ID EQ thisSessionID>			------->
		<CFIF Get_Session_Status.Session_ID EQ thisSessionID>
			<CFSET sessionOK=true>
		</CFIF>
	</CFIF>
	
	<CFIF NOT sessionOK>
		<CFLOCATION URL="/try_again.cfm?id=#request.AccessStructure.User_ID#" ADDTOKEN="No">
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

<!--- 
<!--- 'm trying to come up with a diagnostic interface to javascript --->
<cfif request.AccessStructure.user_id EQ "8F4E2CFD-C6AB-4172-BCFCD050F39EF729">



</cfif>

 --->
