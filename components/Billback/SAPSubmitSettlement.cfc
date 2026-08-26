
<cfcomponent hint="Send Settlememt data to the Pactiv webservice sapSubmitSettlement.wsdl" output="yes">

<!--- XXXXXXXXXXXXXXXXX   ProcessPayment  ->  Processor    XXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="ProcessPayment" access="public" returntype="string">
		<cfargument name="Billback_Id"  required="yes"	type="string" />
		<cfargument name="user_id"      required="yes"	type="string" />
		<cfset var sendPaymentRequest = This.Send(arguments.Billback_Id, arguments.user_id) />
		
		<cfreturn sendPaymentRequest />
		
	</cffunction>
	
<!--- XXXXXXXXXXXXXXXXX   Send  -> Call the Webservice    XXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="Send" access="public" returntype="string" output="true">
		<cfargument name="Billback_Id" required="yes" type="string">
		<cfargument name="user_id" type="string" required="yes" />
		<cfset var oWebservicesManager	= CreateObject("component","components.programs.Approval.Webservices_Manager") />
		<cfset var oDetail 				= CreateObject("component","components.Billback.BillbackSummaryManager") />
		<cfset var oWebService 			= createObject("webservice","http://#cgi.http_host#/components/billback/service/sapSubmitSettlement.wsdl") />
		<cfset var getPaymentHeader 	= oWebservicesManager.getPaymentHeader(arguments.Billback_Id)>
		<cfset var BillbackProgramId 	= oDetail.getBillbackProgramId(arguments.Billback_Id) />
		<cfset var getPaymentDetail 	= oDetail.GetProductFamilyPayment(arguments.Billback_Id,BillbackProgramId) />
		<cfset var temp 				= "" />
		<cfset var a_SettlementResult 	= structNew() />
		<cfset var status 				= "S" />
		<cfset var soapreq 				= "" />
		<cfset var soapresp 			= "" />
		<cfset var response 			= "" />	
		
			<cfset a__SettlementHeader							=	StructNew() />
			<cfset a__SettlementHeader.active_Code				= 	getPaymentHeader.active_Code />
			<cfset a__SettlementHeader.approved_By				= 	arguments.user_id />
			<cfset a__SettlementHeader.approved_Date			= 	getPaymentHeader.approved_Date />
			<cfset a__SettlementHeader.created_By				= 	arguments.user_id />
			<cfset a__SettlementHeader.created_Date				= 	getPaymentHeader.created_Date />
			<cfset a__SettlementHeader.credit_Order				= 	getPaymentHeader.credit_Order />
			<cfset a__SettlementHeader.credit_Order_Date		= 	getPaymentHeader.credit_Order_Date />
			<cfset a__SettlementHeader.rebate_ID				= 	getPaymentHeader.rebate_ID />
			<cfset a__SettlementHeader.rebate_Ref_ID			= 	getPaymentHeader.rebate_Ref_ID />
			<cfset a__SettlementHeader.SAP_Accrual				= 	getPaymentHeader.SAP_Accrual />
			<cfset a__SettlementHeader.settlement_Reason_Code	= 	getPaymentHeader.settlement_Reason_Code />
			<cfset a__SettlementHeader.settlement_Total			= 	getPaymentHeader.settlement_Total />
			<cfset a__SettlementHeader.settlement_Withhold_Amt	= 	getPaymentHeader.settlement_Withhold_Amt />
			<cfset a__SettlementHeader.settlement_Withhold_Ref	= 	getPaymentHeader.settlement_Withhold_Ref />
			<cfset a__SettlementHeader.shared_ShipTo			= 	getPaymentHeader.shared_ShipTo />
		
			<cfset a__SettlementDetail=arrayNew(1) />
			<cfloop query="getPaymentDetail">
				<cfset SettlementDetail 					= structNew() />
				<cfset SettlementDetail.active_Code			= " " />
				<cfset SettlementDetail.buy_Group_ID		= getPaymentDetail.Group_Ship_To />
				<cfset SettlementDetail.prod_Group 			= getPaymentDetail.Product_Hierarchy />
				<cfset SettlementDetail.rebate_ID 			= getPaymentHeader.rebate_ID />
				<cfset SettlementDetail.rebate_Ref_ID		= getPaymentHeader.rebate_Ref_ID />
				<cfset SettlementDetail.settlement_Total 	= getPaymentDetail.FamilyRate />
				<cfset SettlementDetail.shared_ShipTo 		= getPaymentDetail.Earned_Ship_To />
				<cfset temp 								= ArrayAppend(a__SettlementDetail, SettlementDetail) />
			</cfloop>
			<!--- send the request.  use try/catch since we do not know if ERP is listening--->
			<cftry>
				<cfset a_SettlementResult = oWebService.sapSubmitSettlement("0",a__SettlementHeader, a__SettlementDetail) />
				<cfcatch type="any">
						<cfset message	= "SUBMIT SETTLEMENT WEBSERVICE ERROR  ::  "&cfcatch.Message&" :: "&cfcatch.detail&" :: "&cfcatch.type&" :: "&cfcatch.ExtendedInfo />
						<cfset status	= "F" />
						<cflog type="information" log="application" text="#message#" />
						
				</cfcatch>	
			</cftry>
				
			<cfset soapreq	= GetSOAPRequest(oWebService) />
			<cfset soapresp	= GetSOAPResponse(oWebService) />
			
			<cfset logRequest	= This.logRequest(soapreq, a__SettlementHeader, arguments.Billback_Id) />
			<cfset response		= This.logResponse(soapresp, a__SettlementHeader, status, arguments.Billback_Id, logRequest) />
					   
		<cfreturn response />
	</cffunction>
	
<!--- XXXXXXXXXXXXXXXXX   logRequest  ->  Handle the Request    XXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="logRequest" access="public" returntype="numeric">
		<cfargument name="soapRequest"	required="yes"	type="xml" />
		<cfargument name="header"		required="yes"	type="struct" />
		<cfargument name="Billback_ID"	required="no"	type="string" />
		
			<cftransaction isolation="repeatable_read">
				<cfquery name="qInsertRequest" datasource="#application.datasource#">
					Insert into Settlement_WebService_Request
							(
							Billback_ID,
							Rebate_ID,
							Rebate_Ref_ID,
							Settlement_Total,
							Approved_User_ID,
							XML_Data
							)
					Values (
							'#arguments.Billback_id#',
							'#arguments.header.rebate_ID#',
							'#arguments.header.rebate_Ref_ID#',
							'#arguments.header.Settlement_Total#',
							'#arguments.header.Approved_by#',
							'#arguments.soapRequest#'
							)
				</cfquery>
				<cfquery name="qGetRequestID" datasource="#application.datasource#">
				 		Select Max(Settlement_WebService_Request_ID) as Settlement_WebService_Request_ID
						FROM Settlement_WebService_Request
						WHERE Rebate_ID = <cfqueryparam value="#arguments.header.rebate_ID#" cfsqltype="cf_sql_varchar" />
				</cfquery>
			</cftransaction>
			
		<cfreturn qGetRequestID.Settlement_WebService_Request_ID />		
			
	</cffunction>
	
<!--- XXXXXXXXXXXXXXXXX   logResponse  ->  Handle the Response    XXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="logResponse" access="public" returntype="string">
	
		<cfargument name="soapResponse" required="yes"	type="xml" />
		<cfargument name="header"       required="yes"	type="struct" />
		<cfargument name="status"       required="yes"	type="string" />
		<cfargument name="Billback_ID" 	required="no"	type="string" />
		<cfargument name="RequestID"    required="no"	type="string" />
		<cfset var xmlstruct	= "" />
		<cfset var respMessage	= "" />
		<cfset var result		= "" />
	
		<CFSWITCH expression="#status#">
			<!--- Transmit SUCCESS -> now read the ERP data--->
			<CFCASE value="S"> 
				<!--- test data --->
				<!--- <cfset soapResponse = xmlParse("D:\Inetpub\wwwroot\Pactiv_Staging\AwayX\components\Billback\Service\sapSettlementResponse.xml")> --->
				<cfif StructKeyExists(soapResponse.Envelope.Body,"sapSubmitSettlementResponse")>
					<cfset result	= soapResponse.Envelope.Body.sapSubmitSettlementResponse.SettlementResult[1].item />
					<cfset total	= ArrayLen(result) />
					
					<cfloop from="1" to="#total#" index="i" step="1">
						<cfquery name="qInsertWSResponse" datasource="#Application.Datasource#">
							Insert into Settlement_WebService_Response (
										Settlement_webservice_Request_ID,
										Message_text,
										Message_Type,
										Message_For,
										Rebate_ID,
										Rebate_Ref_ID,
										SAPCreditMemoRequestNumber,
										SAPAccrualAmountAtSettlement
										)
								Values (
										'#arguments.RequestID#',
										'#result[i].Messagetext.XmlText#',
										'#result[i].MessageType.XmlText#',
										'#result[i].MessageFor.XmlText#',
										'#result[i].Rebate_ID.XmlText#',
										'#result[i].Rebate_Ref_ID.XmlText#',
										'#result[i].SAPCreditMemoRequestNumber.XmlText#',
										'#result[i].SAPCreditMemoRequestNumber.XmlText#'
										)
						</cfquery>
						<cfset respMessage = respMessage&"<br>"&result[i].Messagetext.XmlText />
						<cfif result[i].MessageType.XmlText eq "E"> <!--- ERP Response.  Status E = Error --->
							<cfset status = "F" />
						</cfif>
					</cfloop>
					
					<cfif status eq "S"> <!--- Success --->
						<cfset respMessage		= " Succesful<br>Rebate: "&arguments.header.rebate_ID&"<br> Settlement Total: "&arguments.header.Settlement_Total&"<br>Message:<br>"&respMessage/>
						<cfset approveRequest	= This.ApproveRequest(arguments.Billback_id, arguments.header.Approved_by) />
					<cfelse> <!--- Error from ERP --->
						<cfset respMessage		= " Failed<br>Rebate: "&arguments.header.rebate_ID&"<br> Settlement Total: "&arguments.header.Settlement_Total&"<br>Message:<br>"&respMessage/>
						<cfset failRequest		= This.FailRequest(arguments.Billback_id, arguments.header.Approved_by) />
					</cfif>
					
				</cfif>
			</CFCASE>
			<!--- Transmit FAILED log the message.  Most likeley a connection to web service failure--->
			<CFCASE value="F"> 
				<cfset respMessage	= " FAILED<br>Rebate:  "&arguments.header.rebate_ID />
				<cfset failRequest	= This.FailRequest(arguments.Billback_id, arguments.header.Approved_by) />
				<cfset soapResponse	= xmlParse(soapResponse)>
				<cfif StructKeyExists(soapResponse,"Envelope")>
					<cfif StructKeyExists(soapResponse.Envelope.Body,"Fault")>
						<cfif StructKeyExists(soapResponse.Envelope.Body.Fault,"faultstring")>
							<cfset respMessage = respMessage&"<br>Message:  "&soapResponse.Envelope.Body.Fault.faultstring.XmlText>
						</cfif>
					</cfif>
				</cfif>
				<cfquery name="qInsertWSResponse" datasource="#Application.Datasource#">
					Insert into Settlement_WebService_Response 
								(
								Settlement_webservice_Request_ID,
								Message_text,
								Message_Type,
								Message_For,
								Rebate_ID,
								Rebate_Ref_ID
								)
						Values (
								'#arguments.RequestID#',
								'#left(respMessage,100)#',
								'E',
								'B',
								'#arguments.header.Rebate_ID#',
								'#arguments.header.Rebate_Ref_ID#'
								)
				</cfquery>
				<cffile action		= "write" 
						nameconflict="overwrite" 
						file		= "#application.appsettingsget.DOCUMENTPATH#\temp_files\SettlemntResponseXML\#arguments.header.rebate_ID#_sapSubmitsettlementResponse.xml" 
						output		= "#soapResponse#">
			
			</CFCASE>
		</CFSWITCH>
		
		<cfreturn respMessage />
		
	</cffunction>
	
<!--- XXXXXXXXXXXXXXXXX   ApproveRequest  -> update the tables    XXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="ApproveRequest" access="public" returntype="void">
		<cfargument name="Billback_Id"	required="yes"	type="string" />
		<cfargument name="user_id"      required="yes"	type="string" />
	
		<CFQUERY NAME="ApprovePayReq" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_Settlement
			SET		Pay_Req_Approved	= 1,
					Approved_By			=	<cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR" />,
					Approved_On 		=  getdate(),
					Sent_ERP			= 1
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.Billback_id#" cfsqltype="CF_SQL_VARCHAR" />		
		</CFQUERY>
		<CFQUERY NAME="ApproveThis" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback
			SET 	BB_Payment_Request_Approved			= 1,
					BB_Payment_Request_Approved_Date	= getdate(),
					BB_Payment_Request_Approved_By		= '#arguments.header.Approved_by#'		
			WHERE	Billback_ID = <cfqueryparam value="#arguments.Billback_id#" cfsqltype="CF_SQL_VARCHAR" />
		</CFQUERY>
		
	</cffunction>
	
<!--- XXXXXXXXXXXXXXXXX   Failed Request     XXXXXXXXXXXXXXXXXXXXX --->
	<cffunction name="FailRequest" access="public" returntype="void">
		<cfargument name="Billback_Id"  required="yes"	type="string" />
		<cfargument name="user_id"      required="yes"	type="string" />
		
		<CFQUERY NAME="FailedPayReq" DATASOURCE="#Application.Datasource#">
			UPDATE 	BB_Settlement
			SET		Created_Updated_User_ID	=	<cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR" />,
					Sent_ERP				= 1	
			WHERE 	Billback_ID = <cfqueryparam value="#arguments.Billback_id#" cfsqltype="CF_SQL_VARCHAR" />		
		</CFQUERY>
		
	</cffunction>
	
</cfcomponent>


































