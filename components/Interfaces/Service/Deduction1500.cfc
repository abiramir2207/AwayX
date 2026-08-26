<cfcomponent rest="true" restpath="Deductions" extends="Service">
	<cffunction name="UploadDeduction" access="remote" returntype="Any" httpmethod="post" restpath="Open" hint="1500 Upload POST from ERP">
		<cfargument name="xmlData" required="true" restargsource="Form" type="string"/>
		<cfscript>
			var s = '';
			var a = [];
			var aData = [];
			var process = false;
			var data = structNew();
			var structData = structNew();
			var retData = '';
			var txnId = RandRange(999,999999);
			//log it
			try{
				var fname = this.log('Upload_1500_Deduction',arguments.xmlData,'xml','in');
				var q = putDeds(fName);
				this.updDataInt(q.ID,fname);
				//log it
				s = this.log('Upload_1500_Deduction_Response',q.xml,'xml','out');
			} catch (any e) {
				sError = 'REST 1500 Upload ERROR::  #e.Message# :: #e.Detail#';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				//dmpError(sError);
				this.updateActivityLog(sError,'1500');
				throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}
			
			return q.xml;
		</cfscript>
	</cffunction>

	<cffunction name="putDeds" access="private" returntype="query" output="false">
		<cfargument name="fName" required="true" type="string"/>

		<cfquery name="qUploadDed" datasource="#application.datasource#">
				EXEC UPLOAD_DEDUCTION '#fName#'
		</cfquery>

		<cfscript>
			return qUploadDed;
		</cfscript>
	</cffunction>

	<cffunction name="ExportDeduction" access="remote" returntype="any" httpmethod="GET" restpath="Approved" output="false" hint="Interface 1510 Export Closed Deductions">
		<cfscript>
			try {
				var q = getDeds();
				var retData = q.xml;
				var fname = this.log('Export_1510_Deduction_#q.ID#',retData,'xml','out');
				this.updDataInt(q.ID,fname);
			} catch (any e) {
				sError = 'REST 1510 Export ERROR::  #e.Message# :: #e.Detail#';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				//dmpError(sError);
				this.updateActivityLog(sError,'1510');
				throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}
		</cfscript>
		<cfreturn retData>
	</cffunction>

	<cffunction name="getDeds" access="private" returntype="query" output="false">
		<cfquery name="qgetDeds" datasource="#application.datasource#">
				EXEC Log_1510_Credit_request
		</cfquery>
		<cfscript>
			return qgetDeds;
		</cfscript>
	</cffunction>

	<cffunction name="ExportDeductionResponse" access="remote" returntype="any" httpmethod="POST" restpath="ApprovedResponse" output="true"
		hint="Interface 1510 Response POST row level Ack from ERP for data Sent to ERP in 1510">
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
			try{
				var fname =	this.log('ExportDeductionResponse', arguments.xmlData, 'xml', 'in');
				var q = putDedsResponse(fName);
			} catch (any e) {
				sError = 'REST 1510 Response (ACK) ERROR::  #e.Message# :: #e.Detail#';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				//NO updateActivityLog.  SAME Intra ID as the GET 1510 which is the key on the Log_WebServices_Activity
				throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}
		</cfscript>
		<!--- nothing to return as per spec/call--->
		<cfreturn q.xml>
	</cffunction>

	<cffunction name="putDedsResponse" access="private" returntype="query" output="false">
		<cfargument name="fName" required="true" type="string"/>

		<cfquery name="qEXEC_SP" datasource="#application.datasource#">
			 EXEC  Log_1510_Final_Update '#fname#'
		</cfquery>

		<cfscript>
			return qEXEC_SP;
		</cfscript>
	</cffunction>
	
	<cffunction name="getResponseResult1510" access="private" returntype="any" output="false">
		<cfquery name="qGetResponseResult1510" datasource="#application.datasource#">
			declare @x xml 

			SET @x = (SELECT 
					(select top 1
					Data_Integration_Upload_Id as [id],
					GetDate()AS [Date],
					(select count(Deduction_Id) from CF_1510_Credit_Response) AS [RECORDS]
						FROM	Data_Integration_Upload where INTRA_ID = '1510' order by Data_Integration_Upload_Id DESC
				FOR XML PATH ('TRANSACTION'), type),
				(select
							INDICATOR,	
							DEDUCTION_ID,
							BILLBACK_CREDIT_ID
						FROM	CF_1510_Credit_Response
				FOR XML PATH ('row'),type, ROOT('DATA'))
				 FOR XML PATH ('Interface_1510_Response'));
			
			SELECT @x as [xml]
		</cfquery>
		<cfscript>
			return qGetResponseResult1510.xml;
		</cfscript>
	</cffunction>
	
	<cffunction name="getDedRequestId" access="private" returntype="any" output="false">
		<cfquery name="qGetRequestId" datasource="#application.datasource#">
			select isnull(max(Data_integration_Upload_id),84) as requestID from Data_integration_Upload
			where INTRA_ID = '1510'
		</cfquery>
		<cfscript>
			return qGetRequestId.requestID;
		</cfscript>
	</cffunction>

</cfcomponent>