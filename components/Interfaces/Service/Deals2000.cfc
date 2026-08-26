<cfcomponent rest="true" restpath="Deals" extends="Service">
	<!--- 2000 INTERFACE --->
	<cffunction name="ExportDeals" access="remote" returntype="any" httpmethod="GET" output="false" restpath="Request">
		<cfargument name="format" required="false" restargsource="query" type="string" default="json"/>

		<cfscript>
			//return 'SERVICE OFFLINE FOR MAINTENANCE'; // Turn It OFF!
			var reqData = GetHttpRequestData();
			var a = [];
			var q = '';
			var fname = '';
			var sError = '';
			try {
				q = getDeals();
				fname = this.log('Export_2000_Deals_#q.ID#',q.xml,'xml','out');
				this.updDataInt(q.ID,fname);
			} catch (any e) {
				sError = 'REST 2000 ERROR::  #e.Message# :: #e.Detail#';
				//sError = '2000 error :: in catch';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				//dmpError(sError);
				this.updateActivityLog(sError,'2000');
				throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}

			return q.xml;
		</cfscript>
	</cffunction>
	
	<!--- 2100 INTERFACE --->
	<cffunction name="ImportDealsResponse" access="remote" returntype="Any" httpmethod="post" restpath="Response">
		<cfargument name="xmlData" required="true" restargsource="Form" type="string"/>
		<cfscript>
			var x = '';
			var s = '';
			var a = [];
			var process = false;
			var data = structNew();
			//this.dmp(xmlData);
			
			try{
				var fName = this.log('Upload_2000_DealsResponse',arguments.xmlData,'xml','in');
				var q = putDeals(fName);
			} catch (any e) {
				sError = 'REST 2100 Response ERROR::  #e.Message# :: #e.Detail#';
				//sError = '2000 error :: in catch';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				//dmpError(sError);
				this.updateActivityLog(sError,'2100');
				throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}
			//this.dmp(aData);
			return q.xml;
		</cfscript>
	</cffunction>
	<cffunction name="dmpError" >
		<cfargument name="x" type="any" required="true" default="">
		<cfdump var='#x#' output='c:\dumpError.log'>   
	</cffunction>
	
	<cffunction name="getDeals" access="private" returntype="query" output="false">
		<cfquery name="qGetDeals" datasource="#application.datasource#">
				exec Forge_ERP_Promotions_Extract
		</cfquery>
		<cfscript>
			return qGetDeals;
		</cfscript>
	</cffunction>

	<cffunction name="putDeals" access="private" returntype="query" output="false">
		<cfargument name="fName" required="true" type="string"/>
		<cfquery name="qUploadDealResponse" datasource="#application.datasource#">
				EXEC Forge_ERP_Promotions_Extract_LOG '#arguments.fName#'
		</cfquery>
		<cfscript>
			return qUploadDealResponse;
		</cfscript>
	</cffunction>

	<cffunction name="getRequestId" access="private" returntype="any" output="false">
		<cfquery name="qGetRequestId" datasource="#application.datasource#">
			select isnull(max(Data_integration_Upload_id),0) as requestID from Data_integration_Upload
			where INTRA_ID = '2000'
		</cfquery>
		<cfscript>
			return qGetRequestId.requestID;
		</cfscript>
	</cffunction>

</cfcomponent>