

<cfset WebservicesManager = CreateObject("component","components.programs.Approval.Webservices_Manager") />

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif isdefined("url.bsa_program_id")>
	<cfif url.bsa_program_id eq "">
		Program Number is not defined.
		<CFABORT>
	<CFELSE>
<cfset getRebateChildren = WebservicesManager.getRebateChildren('',url.bsa_program_id)>
	</cfif>
<cfelse>
<cfset getRebateChildren = WebservicesManager.getRebateChildren(appSettings.getSAPInterfaceBuffer())>
</cfif>
<cfif isdefined("getRebateChildren") and getRebateChildren.recordcount GT 0>

<cfloop query="getRebateChildren">
<cfset errorData = ''/>
<!--- <cftry> --->
	<cfset getRebateXML = WebservicesManager.getRebateXML(Left(getRebateChildren.bsa_program_id, 15),getRebateChildren.program_id)>
	
<cfif getRebateXML.recordcount GT 0>
		
		<cfset RebateXML = getRebateXML.BSA_XML_Structure>
		
		
		<cfset xmlDocument = XmlParse(RebateXML)>
		
	
		<cfset detaillen  = ArrayLen(xmlDocument.Envelope.body.sapSubmitRebate.RebateDetail.XmlChildren) - 1>
	
	<cfset stime = 0.18 * detaillen>
	<cfset ltime = 0.18 * detaillen>
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
	<cfset externalId = '' />
	
	<cfif  getRebateChildren.External_Id eq '$/CA'>
		<cfset externalId = 'DOLL' />
	 <cfelse>
		<cfset externalId = getRebateChildren.External_Id />
	</cfif>
		
		<cfset RebateID = #getRebateChildren.bsa_program_id#> 
	
	<cfset start_date = #Dateformat(Trim(getRebateChildren.PERIOD_START_DATE),"yyyymmdd")#>
	<cfset end_date = #Dateformat(Trim(getRebateChildren.PERIOD_END_DATE),"yyyymmdd")#>
	
	<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.RebateID.XmlText = RebateID>
	<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.ValidFrom.XmlText = start_date>
	<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.ValidTo.XmlText = end_date>
	<cfif NOT StructKeyExists(xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader,"CalculationBasis")>
	   <cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.CalculationBasis = XmlElemNew(xmlDocument, "CalculationBasis")>
	   <cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.CalculationBasis.XmlText = externalId />			
	</cfif>
	
	
	  <!---<cfdump var="#RebateHeader#"> <cfabort> --->
	
	
	<CFQUERY NAME="getprogramerrordetails" datasource="#application.datasource#">
		select * from
		Program_Webservices_Error_Detail
		where BSA_Program_Id = '#RebateID#'
		and deleted = 0
		and Message_Type like '%S%'
	</CFQUERY>
	
	<cfset SAPRebateID = "">
	<cfset UpdateStatus = "">
	<cfif getprogramerrordetails.recordcount EQ 0>
		<cfset UpdateStatus = "I">
		<cfset SAPRebateID = "">
	<cfelse>
		<cfset UpdateStatus = "U">
		<cfset SAPRebateID = #getprogramerrordetails.Pactiv_Program_Id#>
	</cfif>
	 
	<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.UpdateStatus.XmlText = UpdateStatus>
	<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.SAPRebateID.XmlText = SAPRebateID>
		
	<cfset xmlProgramDoc = ToString(xmlDocument)>
	 <!---<cfdump var="#xmlProgramDoc#">
	  <cfif getProgramheader.approved_user EQ "gvegulla@bigredflame.com">
	 <cfdump var="#xmlProgramDoc#"><HR></cfif> --->
	<CFQUERY NAME="getprogramdetails" datasource="#application.datasource#">
		select * from
		Program_WebServices_Detail
		where BSA_Program_Id = '#RebateID#'
		and deleted = 0
	</CFQUERY>
	
	
	<cfif getprogramdetails.recordcount GT 0>
		<CFQUERY NAME="updateprogramwebservicesdetails" datasource="#application.datasource#">
			update Program_WebServices_Detail
			SET 
			BSA_XML_Structure = '#xmlProgramDoc#',
			Approved_User_Id = '#getRebateChildren.approved_by_user_id#',
			Approved_Date = #now()#,
			Program_Id = #getRebateChildren.program_id#,
			Component_Name_ID = #getRebateChildren.Component_Name_ID#,
			Schedule_Sent = 1
			where
			BSA_Program_Id = '#RebateID#'
			and Program_Discount_Type_ID = #getRebateChildren.Program_Discount_Type_ID#
			and deleted = 0
		</CFQUERY>
	<cfelse>
		 <CFQUERY NAME="insertprogramwebservicesdetails" datasource="#application.datasource#">
			insert into Program_WebServices_Detail
			(Program_Id,BSA_Program_Id,Program_Discount_Type_ID,Component_Name_ID,BSA_XML_Structure,Schedule_Sent,Approved_User_Id,Approved_Date)
			values(#getRebateChildren.program_id#,'#RebateID#',#getRebateChildren.Program_Discount_Type_ID#, #getRebateChildren.Component_Name_ID#,'#xmlProgramDoc#',1,'#getRebateChildren.approved_by_user_id#',#now()#)
		</CFQUERY>
	</cfif>
	
	
	<cfset lResolve = 5 * 5000>
	<cfset lConnect = 10 * 5000>
	<cfset lSend = stime * 5000>
	<cfset lReceive = ltime * 5000>
	<!---
	 <cfscript>
	objXMLHTTP = CreateObject("COM", "MSXML2.ServerXMLHTTP"); 
	objXMLHTTP.setTimeouts(lResolve, lConnect, lSend, lReceive);
	objXMLHTTP.open("POST", appSettings.getExternalWebserviceURL(), false); 
	objXMLHTTP.setRequestHeader("Content-Type","text/xml"); 
	objXMLHTTP.setRequestHeader("charset", "utf-8");
	objXMLHTTP.send(xmlProgramDoc); 
	myxml = objXMLHTTP.responseText;
	objXMLHTTP = "";
	</cfscript>
	--->
	<cfhttp method="post" 
	 		url = "#appSettings.getExternalWebserviceURL()#"
			charset = "UTF-8">
		
			<cfhttpparam
					type="xml"
					value="#trim(xmlProgramDoc)#"/>
	 
	</cfhttp>
	<cfset myxml = 	CFHTTP.Filecontent/>
	
	
	<cfif isdefined("myxml") and myxml NEQ "">
	<cfset xmldoc = XmlParse(myxml)>
	
		<cfif StructKeyExists(xmldoc.Envelope.body,"sapSubmitRebateResponse")>
		 
			<cfset component= xmldoc.Envelope.body.sapSubmitRebateResponse.RebateResult[1].item>
			<cfset size = ArrayLen(component)>
			
			<cfif isXmlDoc(xmldoc)>
				<cfset i = 1>
				<cfloop condition = "i LESS THAN OR EQUAL TO #size#">
					<cfoutput>PROCESSED:: #RebateId#  ::  SAP_ID: #component[i].PactivRebateNumber.XmlText#  :: BA_ID: #component[i].BlackSmithRebateNumber.XmlText# :: #component[i].MessageType.XmlText#</cfoutput><br>
					<cfset useLakebaseForinsertwebserviceserrordetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_error_detail")>
<cfif useLakebaseForinsertwebserviceserrordetails>
	<cftry>
		<cfset application.oLakebase.insertRow("program_webservices_error_detail", {
			"bsa_program_id" = "#component[i].BlackSmithRebateNumber.XmlText#",
			"pactiv_program_id" = "#component[i].PactivRebateNumber.XmlText#",
			"message_text" = "#component[i].MessageText.XmlText#",
			"message_type" = "#component[i].MessageType.XmlText#",
			"message_for" = "#component[i].MessageFor.XmlText#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertwebserviceserrordetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertwebserviceserrordetails>
<CFQUERY NAME="insertwebserviceserrordetails" datasource="#application.datasource#">
						insert into Program_Webservices_Error_Detail
						(BSA_Program_Id,Pactiv_Program_Id,Message_Text,Message_Type,Message_For)
						values('#component[i].BlackSmithRebateNumber.XmlText#','#component[i].PactivRebateNumber.XmlText#','#component[i].MessageText.XmlText#','#component[i].MessageType.XmlText#','#component[i].MessageFor.XmlText#')
					</CFQUERY>
</cfif>
					<!--- SEND ERROR --->
					<CFIF component[i].MessageType.XmlText EQ 'E'>				                
					<cfsavecontent variable="errorDataTmp">
						Error in Automated Rebate Children:<br>
					<cfoutput>
						#component[i].BlackSmithRebateNumber.XmlText#<br> 
						#component[i].PactivRebateNumber.XmlText# <br>
						#component[i].MessageText.XmlText# <br>
						#component[i].MessageType.XmlText# <br>
						#component[i].MessageFor.XmlText# <br>
						ACCRUAL: http://pactiv.awayx.com/scheduled/automated_rebate_children.cfm?bsa_Program_Id=#RebateId#   <br>
						APPROVAL: http://pactiv.awayx.com/scheduled/runsapprograms.cfm?cmid=#getRebateChildren.program_id# 
					</cfoutput>
					</cfsavecontent>
					<cfset errorData = errorData & errorDataTmp />
					</CFIF>
					<cfset i = i + 1>
				</cfloop>
			</cfif>
		<cfelse>
			<CFQUERY NAME="insertwebserviceserrordetails1" datasource="#application.datasource#">
				insert into Program_Webservices_Error_Detail
				(BSA_Program_Id,Pactiv_Program_Id,Message_Text,Message_Type,Message_For)
				values('#RebateId#','','No Response From SAP','E','P')
			</CFQUERY>
			<cfsavecontent variable="errorDataTmp">
				Error in Automated Rebate Children:<br>
				<cfoutput>
						#RebateId#<br>
						No Response From SAP (NOT XML)<br>
						E<br>
						P<br>
						ACCRUAL: http://pactiv.awayx.com/scheduled/automated_rebate_children.cfm?bsa_Program_Id=#RebateId#  <br>
						APPROVAL: http://pactiv.awayx.com/scheduled/runsapprograms.cfm?cmid=#getRebateChildren.program_id# 
		        </cfoutput>
			</cfsavecontent>
			<cfset errorData = errorData & errorDataTmp />
		</cfif>
	<cfelse>
		<CFQUERY NAME="insertwebserviceserrordetails2" datasource="#application.datasource#">
			insert into Program_Webservices_Error_Detail
			(BSA_Program_Id,Pactiv_Program_Id,Message_Text,Message_Type,Message_For)
			values('#RebateId#','','No Response From SAP','E','P')
		</CFQUERY>
		<cfsavecontent variable="errorDataTmp">
				Error in Automated Rebate Children:<br>
				<cfoutput>
					#RebateId#
					No Response From SAP (NOT http response)
					E
					P
					ACCRUAL: http://pactiv.awayx.com/scheduled/automated_rebate_children.cfm?bsa_Program_Id=#RebateId#  <br>
					APPROVAL: http://pactiv.awayx.com/scheduled/runsapprograms.cfm?cmid=#getRebateChildren.program_id# 
       			</cfoutput>
		</cfsavecontent>
		<cfset errorData = errorData & errorDataTmp />
	</cfif>
</cfif>
<cfif errorData NEQ ''>
	<cfmail to = "msaunders@bigredflame.com;dkost@bigredflame.com" from = "msaunders@bigredflame.com" subject = "SAP Error :: Pactiv :: Accrual" type="HTML">
		#errorData#
	</cfmail>
	<cfoutput>#errorData#</cfoutput>
</cfif>
 <!--- <cfcatch type="Any">
      <CFOUTPUT> <div align="center"><font size="2" color="red"><B>
	 #cfcatch.message# - #cfcatch.detail# Could not connect to SAP, Please try again.</B></font></div></cfoutput>
	<cfset useLakebaseForinsertwebserviceserrordetails3 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_error_detail")>
<cfif useLakebaseForinsertwebserviceserrordetails3>
	<cftry>
		<cfset application.oLakebase.insertRow("program_webservices_error_detail", {
			"bsa_program_id" = "#RebateId#",
			"pactiv_program_id" = "",
			"message_text" = "#cfcatch.message# - #cfcatch.detail#",
			"message_type" = "E",
			"message_for" = "B"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertwebserviceserrordetails3 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertwebserviceserrordetails3>
<CFQUERY NAME="insertwebserviceserrordetails3" datasource="#application.datasource#">
			insert into Program_Webservices_Error_Detail
(BSA_Program_Id,Pactiv_Program_Id,Message_Text,Message_Type,Message_For)
values('#RebateId#','','#cfcatch.message# - #cfcatch.detail#','E','B')
		</CFQUERY>
</cfif>
   </cfcatch>

</cftry>
 --->

</cfloop>

</cfif>
