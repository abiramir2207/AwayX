<cfcomponent rest="true" restpath="Payment" extends="Service">
	
	<cffunction name="ExportPaymentRequest" access="remote" returntype="any" httpmethod="GET" output="false" restpath="Request">
		<cfargument name="format" required="false" restargsource="query" type="string" default="json"/>
		<cfscript>
			
			var reqData = GetHttpRequestData();
			var a = [];
			var jsonStruct = StructNew();
			var q = getPayments();
			
			var fname = this.log('Export_700_PaymentRequest_#q.ID#',q.xml,'xml','out');
			this.updDataInt(q.ID,fname);
			//this.dmp(now());
			//this.dmp(':::::::::::::::::::::::   END  ::::::::::::::::::::::::');
			return q.xml;
		</cfscript>
	</cffunction>
	<cffunction name="ExportPaymentRequestConfirmation" access="remote" returntype="any" httpmethod="Post" restpath="Response" output="false">
		<cfargument name="xmlData" required="true" restargsource="Form" type="string"/>
		<cfscript>
			var x = '';
			var s = '';
			var aRows = [];
			var aDetails = [];
			var aData = [];
			var stData = StructNew();
			var retData= '';
			var process = false;
			var data = structNew();
			//log it
			var fname = this.log('PaymentRequest_700_Response',arguments.xmlData,'xml','in');
		</cfscript>
		
		<cfquery name="qPaymentResponse710" datasource="#application.datasource#">
			 EXEC  Forge_700_Payment_Response_Log '#fname#'
		</cfquery>
		<!--- nothing to return as per spec/call--->
		<cfreturn qPaymentResponse710.xml>
	</cffunction>
	
	<cffunction name="getPayments" access="private" returntype="query" output="false">
		<cfquery name="qGetPayRequest" datasource="#application.datasource#">
			 EXEC Forge_700_Payment_Request
		</cfquery>
		<cfscript>
			return qGetPayRequest;
		</cfscript>
	</cffunction>

	<cffunction name="getRequestId" access="private" returntype="any" output="false">
		<cfquery name="qGetRequestId" datasource="#application.datasource#">
			select isnull(max(Data_integration_Upload_id),0) as requestID from Data_integration_Upload
			where INTRA_ID = '700'
		</cfquery>
		<cfscript>
			return qGetRequestId.requestID;
		</cfscript>
	</cffunction>
</cfcomponent>