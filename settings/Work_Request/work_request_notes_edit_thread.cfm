
			<cfset Punchlist_URL = "http://tools.awayx.com/components/webservices/Work_Requests.cfc?wsdl">
	
			<!--- should we replace with a periodically exeucted function like clear cache instead of executing every single time? --->
			<cfset createObject("java", "coldfusion.server.ServiceFactory").XmlRpcService.refreshWebService("#Punchlist_URL#")>
	
			<cfinvoke
			webservice="#Punchlist_URL#"
			method="UpdateNote"
			timeout = "300">
				<cfinvokeargument name="Notes" value="#Notes#">
	           		<cfinvokeargument name="Notes_UpdatedBy" value="#Notes_UpdatedBy#"> <!--- int --->
	           		 <cfinvokeargument name="BA_Ticket_Number" value="#BA_Ticket_Number#"> <!--- text --->
				<cfinvokeargument name="User_Email" value="#User_Email#">
				
			</cfinvoke>


		