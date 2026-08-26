<!------ print_fax_email.cfm ----->
<cfoutput>
<cfparam name="url.id" 	default="">
<cfparam name="url.mode" 	default="">
<cfparam name="url.pagePhase" 	default="0">
<cfparam name="form.emailState" 	default="0">

<cfset url.command = "dealSheet" />
<cfset lCommand = "dRequest,dRequestMaterials,dProcurement,dPricing,dPriceInSales" />	

<cfset thisPageUrl = "#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">
<cfset fromFPEmailFaxPage = 1>

<cfif url.mode EQ "print">
	<cfset form.command = ListGetAt(lCommand, url.pagePhase, ",")>
	<cfsavecontent variable="requestContent">
	<cfinclude template="handler.cfm" />
	</cfsavecontent>
	<!------ if print ----->
	#requestContent#
	<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
<cfelse>
	<cfinclude template="/Script/cf/string_functions.cfm">
	
	<cfset reqManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
	<cfset requestObj = reqManager.get(url.id) />
	
	<!------ if email or fax ----->
	<cfif form.emailState>
	<!------ if form submit ----->	
	<!------ send email / fax ----->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// send mail or fax ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

		<!------ show spinner ----->
		<cfinclude template="/includes/call_please_wait.cfm">		
		
		<cfparam name="form.FP_Attachment_ID" 	default="">
		<cfparam name="form.Document_ID" 	default="">
		<cfset qDocuments = CreateObject("component", "components.document.DocumentManager").getDocumentsFromList(form.Document_ID) />
		
		<cfif form.FP_Attachment_ID NEQ "">
			
			<!------ get the cover sheet ----->
			<cfif url.mode EQ "email">
				<!------ email ----->
				<cfset messagetype = 1>
				<cfset recepientAddress = form.recipient_address>
				<cfset fromAddress = request.AccessStructure.User_Email>
				<cfsavecontent variable="cover_sheet">
				<table width="100%">		
				<tr valign="top">
					<td>#form.message_body#</td>
				</tr>
				<tr valign="top">
				<td>
				Attachments:Please find the following documents
				<cfloop list="#form.FP_Attachment_ID#" index="thisAttachment">
					<cfsilent><cfset docDesc = "">
					<cfswitch expression="#Left(thisAttachment, 8)#">
						<cfcase value="FP_Phase">
							<cfif Listlen(thisAttachment, "_") GTE 3>
								<cfset phaseId = ListGetAt(thisAttachment, 3, "_") />
								<cfset docDesc = " - Phase #phaseId#">
							</cfif>
						</cfcase>
						<cfcase value="FP_DealS">
							<cfset docDesc = "Deal Sheet">
						</cfcase>
						<cfcase value="FP_Notes">
							<cfset docDesc = " - Notes">
						</cfcase>
					</cfswitch></cfsilent>
					<br>&nbsp;&nbsp;&nbsp;&nbsp;Futures Pricing: #requestObj.getTitle()# #docDesc#
				</cfloop>
				<cfif qDocuments.recordcount GT 0><cfloop QUERY="qDocuments"><cfif FILEEXISTS("#APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#")><br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</cfif></CFLOOP></cfif>
				</td>
				</tr>
				</table>
				</cfsavecontent>
			<cfelse>
				<!------ fax ----->
				<cfset messagetype = 2>
				<cfset recepientAddress = request.app_general_functions.Get_Fax_Email_Address(Source_Fax_Numbers=form.recipient_address,Name_First=request.AccessStructure.Name_First,Name_Last=request.AccessStructure.Name_Last) />
				<cfset fromAddress = application.CompanyFaxFromEmail>
				
				<cfsavecontent variable="cover_sheet"> 
					<table cellpadding="5" cellspacing="15" border="0"  width="95%">
					<tr>
						<td nowrap align="right" colspan="4">
				  		<b><font face="arial" size="5">#application.returned_customer_setting.company_name#</font></b>  
				  		</td>
				 	</tr>
				 	<tr>
				  		<td colspan="4" style="border-bottom-style: solid; border-bottom-width: 4" valign="top"></td>
				 	</tr>
				 	<tr>
				  		<td style="font:72px;" colspan="4" valign="top"><font face="arial"><b>
				        <br>
				        f a x<br>&nbsp;</b></font>
						</td>
				 	</tr>
				 	<tr>
				  		<td width="75" rowspan="6" valign="top">&nbsp;</td> 
						<td rowspan="6" valign="top">&nbsp;</td>
				  		<td valign="top" style="font:16px;"><b><font size="5" face="arial">date:</font></b></td>
				  		<td width="100%" style="font:16px;" valign="top">
				        <font face="arial">
				        <span style="font-size: 13pt">#form.senderdate# </span></font></td>  
					 </tr>
					 <tr>
					  	<td valign="top" style="font:16px;"><b><font size="5" face="arial">from:</font></b></td>
					  	<td style="font:16px;" width="100%" valign="top">
					        <font face="arial">
					        <span style="font-size: 13pt">#form.senderaddress#</span></font>
						</td>
					 </tr>
					 <tr>
						<td valign="top" style="font:16px;"><b><font size="5" face="arial">subject:</font></b></td>
					  	<td style="font:16px;" width="100%" valign="top">
					        <font face="arial">
					        <span style="font-size: 13pt">#form.sendersubject#</span></font>
						</td>
					 </tr>
					 <tr>
					 	<td valign="top" style="font:16px;"><b><font size="5" face="arial">message:</font></b></td>
					  	<td style="font:16px;" width="100%" valign="top">
					        <font face="arial">
					        <span style="font-size: 13pt">#form.message_body#</span></font>
						</td>
					 </tr>
					 <tr>
					 	<td valign="top" style="font:16px;"><b><font size="5" face="arial">comments:</font></b></td>
					  	<td style="font:16px;" width="100%" valign="top">
					        <font face="arial">
					        <span style="font-size: 13pt">please find the following documents<br>
							<cfloop list="#form.FP_Attachment_ID#" index="thisAttachment">
								<cfsilent><cfset docDesc = "">
								<cfswitch expression="#Left(thisAttachment, 8)#">
									<cfcase value="FP_Phase">
										<cfif Listlen(thisAttachment, "_") GTE 3>
											<cfset phaseId = ListGetAt(thisAttachment, 3, "_") />
											<cfset docDesc = " - Phase #phaseId#">
										</cfif>
									</cfcase>
									<cfcase value="FP_DealS">
										<cfset docDesc = "Deal Sheet">
									</cfcase>
									<cfcase value="FP_Notes">
										<cfset docDesc = " - Notes">
									</cfcase>
								</cfswitch></cfsilent>
								<br>&nbsp;&nbsp;&nbsp;&nbsp;Futures Pricing: #requestObj.getTitle()# #docDesc#
							</cfloop>
							<cfif qDocuments.recordcount GT 0><cfloop QUERY="qDocuments"><cfif FILEEXISTS("#APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#")><br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</cfif></CFLOOP></cfif>
							</span></font>
						</td>
					 </tr>
					 <tr>
						<td valign="top" style="font:16px;">&nbsp;</td>
						<td style="font:16px;" width="100%" valign="top">
					        <br><br><br><br><br><br><br><br><br>&nbsp;
						</td>  
					 </tr>
					</table>				 
					<cfinclude template="/common_files/email_footer.cfm">
				</cfsavecontent>			
			</cfif>
			
			<!------ Send Email ----->
			<CF_EMAILWRAPPER 
					TO = "#recepientAddress#"
	        		FROM = "#fromAddress#"
	        		SUBJECT = "#form.Sendersubject#"
					TYPE = "html" 
					messagetype = "#messagetype#" 
					generatedby="3" 
					apparea="14" 
					userid="#request.AccessStructure.user_id#">
					#cover_sheet#
				<!------ loop thru the different attachment types and attach to email ----->
				<cfloop list="#form.FP_Attachment_ID#" index="thisAttachment">
					<cfset thisFileContent = "" />
					<cfset phaseId = "">
					<cfset docDesc = "">
					<cfswitch expression="#Left(thisAttachment, 8)#">
						<cfcase value="FP_Phase">
							<cfif Listlen(thisAttachment, "_") GTE 3>
								<cfset phaseId = ListGetAt(thisAttachment, 3, "_") />
								<cfset form.command = ListGetAt(lCommand, phaseId, ",")>
								<cfsavecontent variable="thisFileContent">
								<cfinclude template="handler_core.cfm" />
								</cfsavecontent>
								<cfset docDesc = "Phase #phaseId#">
							</cfif>
						</cfcase>
						<cfcase value="FP_DealS">
							<cfset form.command = "dealSheet">							
							<cfsavecontent variable="thisFileContent">
							<cfinclude template="handler_core.cfm" />
							</cfsavecontent>
							<cfset docDesc = "Deal Sheet">
						</cfcase>
						<cfcase value="FP_Notes">
							<cfset form.command = "dNotes">							
							<cfsavecontent variable="thisFileContent">
							<cfinclude template="handler_core.cfm" />
							</cfsavecontent>
							<cfset docDesc = "Notes">
						</cfcase>
					</cfswitch>								
					<!------ save file ----->
					<cfif Len(thisFileContent) GT 0>	
						<cfset thisFileContent = reqManager.stripHTMLTag(thisFileContent, "SCRIPT") />
						<CF_Writing_Email_Attachment
				  				Naming_Format="Futures_Pricing_#requestObj.getTitle()# #docDesc#"
								File_Extension="html"
								Relative_Path="\Temp_Files\Futures_pricing\"
								Output_Content="#thisFileContent#"
								addNewLine="No"
								Return_File_Name="RequestSavedFilePath"> 
						<cf_emailwrapperparam file="#RequestSavedFilePath#" store="yes" />
					</cfif>
				</cfloop>
				<!------ loop thru different documents being attached ----->
				<cfloop query="qDocuments">
					<CFIF FILEEXISTS("#APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#")>
						<cfset File_Extension = ListLast(Doc_Uni_Name, ".") />
						<CF_Naming_Email_Attachments 
							Title="#Doc_Title#" 
							Relative_Src_File_Path="data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#"  
							Relative_Dest_Dir_Path ="Temp_Files\Program\Documents" 
							Return_Variable_Name="RequestDocumentSavedFilePath"
							File_Extension="#File_Extension#">
						<cf_emailwrapperparam file="#RequestDocumentSavedFilePath#" store="yes" />
					</CFIF>
				</cfloop>
			</CF_EMAILWRAPPER>
			
			<!------ Show User ----->
			<H4 STYLE="Color: Red;">
			The following #url.mode# has been sent...<BR><BR>
			</H4>
			<div align="center">
			<CF_button
				button_name		=	""
				button_caption	=	"close"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to close this window..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
			</div>
			<table cellpadding="1" cellspacing="5" border="0">
			<tr>
				<td valign="top"><b>date:</b></td>
				<td rowspan="100%" bgcolor="orange"></td>
				<td>#form.senderdate#</td>
			</tr>
			<tr>
				<td valign="top"><b>from:</b></td>
				<td>#form.senderaddress#</td>
			</tr>
			<tr>
				<td valign="top"><b>message:</b></td>
				<td>#form.message_body#</td>
			</tr>
			<tr>
				<td valign="top"><b>subject:</b></td>
				<td>#form.sendersubject#</td>
			</tr>			
			<tr>
				<td valign="top"></td>
				<td></td>
			</tr>
			</table>
			
		</cfif>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// send mail or fax ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

	<cfelse>
	<!------ Get request Object ----->
	<cfset qGetStatus = CreateObject("component", "components.futures_pricing.StatusManager").getAll() />
	<cfset statusId = requestObj.getStatusId()>
	<cfset documentManager = CreateObject("component", "components.futures_pricing.DocumentManager") />
	<cfset qDocument =  documentManager.getRequestDocuments(url.id) />
	<cfset notesExist =  CreateObject("component", "components.futures_pricing.NoteManager").getNotesExist(url.id) />
	
	<!------ show form ----->
	<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>	
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<script language="JavaScript">

		function confirmCompletion(formObj, faxEmail)
		{
			var ErrorCount = 0;
		
			if(formObj.SenderAddress.value.length == 0)	
			{ 
				ErrorCount++;
				queueMessage("You must enter your email address", document.all.error_SenderAddress);
			}	
			else
			{			
				clearQueue(document.all.error_SenderAddress);
			}
			
			if(formObj.SenderSubject.value.length == 0)
			{			
				ErrorCount++;
				queueMessage("You must enter a subject", document.all.error_SenderSubject);
			}
			else
			{			
				clearQueue(document.all.error_SenderSubject);
			}	
			
			if(faxEmail == "email")
			{
				<!------ email ----->
				var ValidEmail1 = replaceInvalidEmailCharsAndValidate(formObj.recipient_address)
				var sBroker_Address = formObj.recipient_address.value;
				
				if(sBroker_Address.length == 0)
				{
					ErrorCount++;
					queueMessage("You must enter at least one email address", document.all.error_recipient_address);
				}
				else if(ValidEmail1!=true)
				{
					ErrorCount++;
				 	queueMessage("Invalid email Address <font size=2><b>" + ValidEmail1 + "</b></font> ! Please re-enter.", document.all.error_recipient_address);
				}
				else
				{
					clearQueue(document.all.error_recipient_address);
				}
			}
			else
			{
				<!------ fax ----->
				var sBroker_Address = formObj.recipient_address.value;
				
				if(sBroker_Address.length == 0)
				{
					ErrorCount++;
					queueMessage("You must enter at least one fax number", document.all.error_recipient_address);
				}				
				else
				{
					clearQueue(document.all.error_recipient_address);
				}
			}
			
			if(!Any_Object_Checked(formObj.FP_Attachment_ID))
			{			
				ErrorCount++;
				queueMessage("You must select atleast one page to attach", document.all.error_attachments);
			}
			else
			{			
				clearQueue(document.all.error_attachments);
			}
			
		<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) 
			{
				formObj.submit()
				
			}
			else 
			{
				showMessageWindow()
			}	
		}
	</script>
	<CF_MessageWindow>
	<cfset formName = "frmEmailFax">
	<form action="#thisPageUrl#" method="post" name="#formName#">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<span class="title2">message details:</span>
		<hr color="orange">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<table border="0" cellpadding="0" cellspacing="0" >
		<tr>
			<td align="right" width="150"><b>date:&nbsp;&nbsp;</b></td>
			<td><input type="text" name="senderdate" size="30" value="#dateformat(now(), 'mmmmm d, yyyy')#" style="width: 250px;"></td>
			<!--- <td rowspan="100%"><img src="/images/email.gif"></td> --->
		</tr>
		<tr>
			<td align="right"><b>from:&nbsp;&nbsp;</b><span id="error_SenderAddress"></span></td>
			<td><input type="text" name="SenderAddress" size="30" value="#request.AccessStructure.name_first# #request.AccessStructure.name_last# (#request.AccessStructure.user_email#)" style="width: 250px;"></td>
		</tr>
		<tr>
			<td align="right"><b>subject:&nbsp;&nbsp;</b><span id="error_SenderSubject"></span></td>
			<td><input type="text" name="SenderSubject" size="30" value="futures pricing request #requestObj.getTitle()#" style="width:540px;"></td>
		</tr>
		<tr>
			<td align="right" valign="top"><b>message body:&nbsp;&nbsp;</b></td>
			<td ><textarea name="message_body" cols="75" rows="5" style="width:540px;"></textarea></td>
		</tr>
		</table>
		<cfif url.mode EQ "email">
			<!------ email ----->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<span class="title2">recipients' email addresses</span>
			<hr color="orange">
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			
			<table border="0" cellpadding="0" cellspacing="0" >
			<tr>
				<td align="right" width="150" valign="top"><b>recipients:&nbsp;&nbsp;</b><span id="error_recipient_address"></span></td>
				<td><textarea name="recipient_address" cols="75" rows="5" style="width:300px;"  onkeypress="javascript: return Valid_Key_On_Email_Object();"></textarea>
				</td>
				<td align="left">
				<cf_email_address_lookup 
						destination_form_name="#formName#"
						destination_field_name="recipient_address"
						width="200"
						size="5"
						alert="true">
				</td>
			</tr>
			<tr>
				<td></td>
				<td colspan="2">
				<font color="red"><b><i>to add more recipients, add the email addresses separating them with a semi- colon ( ;)</i></b></font>
				</td>
			</tr>
			</table>
		<cfelse>
			<!------ fax ----->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<span class="title2">recipients' fax numbers</span>
			<hr color="orange">
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			
			<table border="0" cellpadding="0" cellspacing="0" >
			<tr>
				<td align="right" width="150" valign="top"><b>recipients:&nbsp;&nbsp;</b><span id="error_recipient_address"></span></td>
				<td>
					<textarea name="recipient_address" cols="75" rows="5" onkeyup="clenseText(this, '0123456789;')" style="width:540px;"></textarea><br>
					<font color="red"><b><i>
			you must preceed the area code with a "1"<br>
			to add more recipients, add the fax numbers separating them with a semi- colon ( ;)<br>
						please make sure that there are no spaces, dashes in the fax number.
					</i></b></font>
				</td>
			</tr>
			</table>

		</cfif>
			<!------ attachments ----->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<span class="title2">attachments</span><span id="error_attachments"></span>
			<hr color="orange">
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			
			<table border="0" cellpadding="0" cellspacing="0" >
			<cfloop query="qGetStatus" endrow="#statusId#">
			<cf_print_email_attachment_section
				desc = "#FP_Status_Desc#"
				id = "FP_Phase_#FP_Status_ID#"
				>			
			</cfloop>
			<cf_print_email_attachment_section
				desc = "Deal Sheet"
				id = "FP_DealSheet"
				>
			<cfif notesExist>
			<cf_print_email_attachment_section
				desc = "Notes"
				id = "FP_Notes"
				>	
			</cfif>
			</table>
			
			<cfif qDocument.recordCount>
			<!------ attached documents ----->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<span class="title2">attached documents</span>
			<hr color="orange">
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<table border="0" cellpadding="2" cellspacing="0" width="80%" align="center">
			<tr bgcolor="##ffce84">
				<td id="header"></td>
				<td id="header"><B>Date / Name</B></td>
				<td id="header"><B>File</B></td>
				<td id="header"><B>Title / Description</B></td>
				<td id="header"><B>Type</B></td>				
			</tr>				
			<cfloop query="qDocument">
				<tr valign="top" bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<td>
					<input type="Checkbox" name="Document_ID" value="#Doc_ID#">
					</td>
					<td>
					#DateFormat(Uploaded_Date, "mm/dd/yyyy")#
					<br>#UploadedByName#
					&nbsp;</td>
					<td title="File Name: #Doc_File_Name#">
					<a href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">#showRestrictedLength(Doc_File_Name, 100)#&nbsp;</a>
					<br>#numberformat(Doc_size_KB,"_.___")# KB
					&nbsp;</td>				
					<td>
					#Doc_Title#
					<br>#showRestrictedLength(Doc_Description, 100)#
					&nbsp;</td>
					<td>#Doc_Type#&nbsp;</td>
				</tr>
			</cfloop>
			</table>
			</cfif>
		<input name="emailState" type="hidden" value="1">
		<TABLE align="center">
			<TR>
				<TD>
					<CF_button
						button_name		=	""
						button_caption	=	"send #url.mode#"
						button_action	=	"confirmCompletion(document.#formName#, '#url.mode#');"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Click here to send #url.mode#..."
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold">
				</TD>
			</TR>
		</TABLE>		
	</form>
	</cfif>
</cfif>
</cfoutput>