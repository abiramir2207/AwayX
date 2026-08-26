<cfparam name="error" default="false">
<cfparam name="nomessagereceived" default="false">
<cfparam name="Error_Program_Id" default="">
<cfparam name="novaliditems" default="false">
<cfparam name="url.delete" default = 1>
<cfparam name="url.cancelOption" 	default="1">

<cfif isdefined("url.program_id") and url.program_id NEQ "">
<cfset WebservicesManager = CreateObject("component","components.programs.Approval.Webservices_Manager") />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif url.delete EQ 1>
<cfset getPrograms = WebservicesManager.getCancelledPrograms(url.program_id)>
<cfelseif url.delete EQ 2>
<cfset getPrograms = WebservicesManager.getPurgedPrograms(url.program_id)>
</cfif>
<!--- <cfif getCancelledPrograms.recordcount GT 0> --->
	<cfloop query="getPrograms">
	
<cfset useLakebaseForgetwebservicedetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_detail")>
<cfif useLakebaseForgetwebservicedetails>
	<cftry>
		<cfset getwebservicedetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_webservices_detail", {
				"bsa_program_id" = "eq.#getPrograms.bsa_program_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetwebservicedetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetwebservicedetails>
<CFQUERY NAME="getwebservicedetails" datasource="#application.datasource#">
 	select * from Program_Webservices_Detail
	where bsa_program_id = '#getPrograms.bsa_program_id#'
 </CFQUERY>
</cfif>
 

 
<cfif getwebservicedetails.BSA_XML_Structure NEQ "">
	<cfset tempxml = getwebservicedetails.BSA_XML_Structure>
	<cfset xmlDoc = XmlParse(tempxml)>
<cfelse>
	<cfinclude template="create_xmlstructure.cfm">
	<cfset useLakebaseForupdatewebservicedetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_detail")>
<cfif useLakebaseForupdatewebservicedetails>
	<cftry>
		<cfset application.oLakebase.updateRows("program_webservices_detail",
			{
				"bsa_program_id" = "eq.#getPrograms.bsa_program_id#"
			},
			{
				"bsa_xml_structure" = "#tempxml#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatewebservicedetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatewebservicedetails>
<CFQUERY NAME="updatewebservicedetails" datasource="#application.datasource#">
 	update Program_Webservices_Detail
	set BSA_XML_Structure = #tempxml#
	where bsa_program_id = '#getPrograms.bsa_program_id#'
 </CFQUERY>
</cfif>
</cfif>
	
<cfif url.delete EQ 1>
	<cfset xmldoc.Envelope.body.sapSubmitRebate.RebateHeader.ValidTo.XmlText = #dateformat(now(),"yyyymmdd")#>
<cfelseif url.delete EQ 2>
	<cfset xmldoc.Envelope.body.sapSubmitRebate.RebateHeader.UpdateStatus.XmlText = "D">
</cfif>
	<cfset xmldoc.Envelope.body.sapSubmitRebate.RebateHeader.SAPRebateID.XmlText = getPrograms.Pactiv_Program_Id>


<cfset detaillen  = ArrayLen(xmldoc.Envelope.body.sapSubmitRebate.RebateDetail.XmlChildren) - 1>

<cfset stime = 0.1 * detaillen>
<cfset ltime = 0.1 * detaillen>
<cfif stime LT 20>
	<cfset stime = 20>
<cfelse>
	<cfset stime = stime>
</cfif>

<cfif ltime LT 20>
	<cfset ltime = 20>
<cfelse>
	<cfset ltime = ltime>
</cfif>

<!--- 	<cfset arrlen  = ArrayLen(xmldoc.Envelope.body.sapSubmitRebate.RebateDetail.XmlChildren) - 1>
	<cfloop index="i" from="0" to="#arrlen#">	 
		<cfset xmlElem1 = evaluate("xmldoc.Envelope.body.sapSubmitRebate.RebateDetail.item#i#.DeletionIndicator")>
		<cfset xmlElem2 = evaluate("xmldoc.Envelope.body.sapSubmitRebate.RebateDetail.item#i#.SAPRebateID")>
		<cfset xmlElem1.XmlText = "X">
		<cfset xmlElem2.XmlText = getCancelledPrograms.Pactiv_Program_Id>
	</cfloop> --->
	
<cfset lResolve = 5 * 5000>
<cfset lConnect = 10 * 5000>
<cfset lSend = stime * 5000>
<cfset lReceive = ltime * 5000>

<cfset xmlCancelDoc = ToString(xmlDoc)>
<div align="center"><font size="2" color="red">
Sent Rebate <cfoutput>#getPrograms.bsa_program_id#</cfoutput> to SAP
</font></div>
<br>
<!---
 <cfscript>
objXMLHTTP = CreateObject("COM", "MSXML2.ServerXMLHTTP"); 
objXMLHTTP.setTimeouts(lResolve, lConnect, lSend, lReceive);
objXMLHTTP.open("POST", appSettings.getExternalWebserviceURL(), false); 
objXMLHTTP.setRequestHeader("Content-Type","text/xml"); 
objXMLHTTP.setRequestHeader("charset", "utf-8");
objXMLHTTP.send(xmlCancelDoc); 
xmlResponse = objXMLHTTP.responseText;
objXMLHTTP = "";
</cfscript>
--->
<cfhttp method="post" 
 	url = "#appSettings.getExternalWebserviceURL()#"
	charset = "UTF-8">
	
	<cfhttpparam
	type="xml"
	value="#trim(xmlCancelDoc)#"/>
 
</cfhttp>
<cfset xmlResponse = 	CFHTTP.Filecontent/>

<cfif isdefined("xmlResponse") and xmlResponse NEQ "">
	<cfset xmlResponseDoc = XmlParse(xmlResponse)>
	<cfif isXmlDoc(xmlResponseDoc)>
		<cfif StructKeyExists(xmlResponseDoc.Envelope.body,"sapSubmitRebateResponse")>
			<cfset component= xmlResponseDoc.Envelope.body.sapSubmitRebateResponse.RebateResult.XmlChildren>
			<cfset size = ArrayLen(component)>
	
			<cfset i = 1>
				<cfloop condition = "i LESS THAN OR EQUAL TO #size#">
			 <CFQUERY NAME="insertwebserviceserrordetails" datasource="#application.datasource#">
				insert into Program_Webservices_Error_Detail
	(BSA_Program_Id,Pactiv_Program_Id,Message_Text,Message_Type,Message_For,SAP_Deletion)
	values('#component[i].BlackSmithRebateNumber.XmlText#','#component[i].PactivRebateNumber.XmlText#','#component[i].MessageText.XmlText#','#component[i].MessageType.XmlText#','#component[i].MessageFor.XmlText#',1)
			</CFQUERY>

<cfoutput><cfif component[i].MessageType.XmlText EQ "E">
<div align="center"><font size="2" color="red">
#component[i].PactivRebateNumber.XmlText#-#component[i].MessageText.XmlText#-<cfif Trim(component[i].MessageFor.XmlText) EQ "P">
Message for Pactiv<cfelse>Message for Blacksmith
</cfif></cfoutput>
</font></div>
	<cfset error = "true">
	<cfset Error_Program_Id = component[i].BlackSmithRebateNumber.XmlText>
<cfelse>
	<div align="center"><font size="2" color="red">
<cfoutput>Received #component[i].BlackSmithRebateNumber.XmlText# - #component[i].PactivRebateNumber.XmlText#-#component[i].MessageText.XmlText#</cfoutput>
</font>
<HR>
<CFQUERY NAME="updatewebservicedetails" datasource="#application.datasource#">
 	update Program_Webservices_Detail
	set SAP_Deleted_Status = 1
	where bsa_program_id = '#component[i].BlackSmithRebateNumber.XmlText#'
 </CFQUERY>
</cfif>
				<cfset i = i + 1>
				</cfloop>
		</cfif>
	</cfif>
<cfelse>
	<cfset nomessagereceived = "true">
</cfif>
<cfif error EQ "true" OR nomessagereceived EQ "true">
	<cfbreak>
</cfif>
	</cfloop>
	
	<cfif error EQ "false" AND nomessagereceived EQ "false">
		<cfset program = CreateObject("component", "components.programs.program") />
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfif url.delete EQ 1><!------ Cancel program ----->
			<cfset program.cancelProgram(
							programId = url.program_id, 
							userId = url.User_ID,
							cancelallprogramversions = appsettings.getcancelallprogramversions(),
							Date_Exclusions_ON = 0,
							IS_Date_Exclusions_child = 0,
							cancelOption = url.cancel_option) /><!------ in theory the arguments Date_Exclusions_ON, IS_Date_Exclusions_child should be set, but blacksmith no longer supports the feature date exclusion and also no one uses this feature, especially this client who uses the send cancelled program to SAP ----->
		<cfelseif url.delete EQ 2><!------ purge program ----->
			<cfset program.purgeProgram(url.program_id, url.User_ID) />
			
			<cfset useLakebaseForPurgeFutureContracts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_period_dates")>
<cfif useLakebaseForPurgeFutureContracts>
	<cftry>
		<cfset application.oLakebase.updateRows("program_period_dates",
			{
				"program_id" = "eq.#url.program_id#"
			},
			{
				"sap_deleted_status" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPurgeFutureContracts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPurgeFutureContracts>
<CFQUERY NAME="PurgeFutureContracts" datasource="#application.datasource#">
					UPDATE program_period_dates
					Set SAP_Deleted_Status = 1
					WHERE program_Id = #url.program_id#
			</CFQUERY>
</cfif>
		</cfif>
		<cfset useLakebaseForCancelContract = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForCancelContract>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#url.program_id#"
			},
			{
				"sent_to_external_client" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCancelContract = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCancelContract>
<CFQUERY NAME="CancelContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0
			WHERE Contract_Main_Id = #url.program_id#
		</CFQUERY>
</cfif>
<CFQUERY NAME="PurgeFutureContracts" datasource="#application.datasource#">
		UPDATE program_period_dates
		Set SAP_Deleted_Status = 1
		WHERE program_Id = #url.program_id#
</CFQUERY>
<!------ Get application settings ----->
<cfif url.delete EQ 1>
<cfset appSettings = genSettingsManager.get()>
<cfsilent>
<cfif appSettings.getCancelProgramEmail()>
	<cfset send_Cancel_Email_Now = 1>
	<cfset send_Email_Program_ID = url.program_id>
	<cfinclude template="\anything_automated\email\cancelled_programs_emailer.cfm">
</cfif>
</cfsilent>
</cfif>
	<cfelseif nomessagereceived EQ "true">
	<div align="center"><font size="2" color="red"><B>No Response from SAP</B></font></div>
	<CFQUERY NAME="CancelContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #url.program_id#
		</CFQUERY>
	<cfelseif error EQ 'true'>
	<div align="center"><font size="2" color="red">Program is not Cancelled.</font></div>
		<CFQUERY NAME="CancelContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #url.program_id#
		</CFQUERY>
	</cfif>
<!--- <cfelse>
	<div align="center"><font size="2" color="red">No valid programs found to send for deletion.<br>Program is not Cancelled.</font></div>
	<CFQUERY NAME="CancelContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #url.program_id#
		</CFQUERY>
</cfif> --->
<cfelse>
<div align="center"><font size="2" color="red">Invalid Program Number</font></div>
	<CFQUERY NAME="CancelContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #url.program_id#
		</CFQUERY>
</cfif>
