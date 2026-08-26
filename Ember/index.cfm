<cfparam name="sDestination" default="Ember"/>
<!--- get the ember logon account for this user --->
<CFQUERY NAME="qEmberInfo" datasource="#application.datasource#">
	Select		Ember_Info,
				Analytics_SSO_USER_NAME,
				user_code
	From		_users
	Where 		user_id = '#request.AccessStructure.user_id#'
	AND 		deleted = 0
</CFQUERY>

<cfscript>
	if(sDestination == 'Ember'){ //Login to Ember/Insight
		OpenDocument_URL	=	application.appSettingsget.get_Setting('Ember_OpenDocument_URL');
		Logon_URL			=	application.appSettingsget.get_Setting('Ember_Logon_URL');
		User_Info 			= 	qEmberInfo.Ember_Info;
	}
	else{ // Login to Analyrtics
		OpenDocument_URL	=	application.appSettingsget.get_Setting('Analytics_OpenDocument_URL');
		Logon_URL			=	application.appSettingsget.get_Setting('Analytics_Logon_URL');
		User_Info 			= 	qEmberInfo.Analytics_SSO_USER_NAME;
	}
	
</cfscript>

<cftry>
	<!--- Get the logon token fron BO  --->
	<cfhttp result="result" method="GET" url="#Logon_URL##User_Info#" />

	<!--- <cfdump var="#result.filecontent#"> --->
	<cfscript>
		// Some messages
		m = 'Login to Analytics Unsuccessful';
		mCatch = 'Analytics did not respond to request';
		// Parse the XML to find the logonToken
		x = xmlparse(result.filecontent);
		e = IsXmlElem(x.entry.content.attrs.attr);
	</cfscript>
	<br>
	<!--- <cfoutput>http://analytics4.stage.awayx.com/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=AXDIgMnmy9pKn_pSuvCQa50&noDetailsPanel=true&token=#URLEncodedFormat(x.entry.content.attrs.attr.XmlText)#</cfoutput> --->

	<!--- If the logonToken XML element is available, pass it to the open document URL --->
	<cfif e>
		<cflocation url="#OpenDocument_URL##URLEncodedFormat(x.entry.content.attrs.attr.XmlText)#&X_FORGEUser=#qEmberInfo.user_code#" addtoken="no"/>
	<cfelse> <!--- display a message --->
		<cfoutput>#m#</cfoutput>
	</cfif>
	<!--- WE HAD A PROBLEM  ::  display a message--->
	<cfcatch><br>
	<br>
	<br>
	
		<p align="center">
			<b>You do not have access to <cfif sDestination EQ "Ember">Insights<cfelse>Analytics</cfif>.   Please contact the system administrator to discuss how to gain access</b><br>
			<br>
			<CF_smallLink
				title = "close window"
				url = "JavaScript:window.close();"
				parameters = ""
			>
			
		</p>	
		
		
		<!--- <cfoutput>#mCatch#</cfoutput>
		<p>
		Logon:  <cfoutput>#Logon_URL##User_Info#</cfoutput>
		<p>
		Document:  <cfoutput>#OpenDocument_URL##URLEncodedFormat(x.entry.content.attrs.attr.XmlText)#</cfoutput>
		<p>
		<cfoutput>#result.filecontent#</cfoutput>
		<!--- <cfdump var="#result.filecontent#"> --->
		<!--- <cfdump var="#cfcatch#"> ---> --->
	</cfcatch>

</cftry>



