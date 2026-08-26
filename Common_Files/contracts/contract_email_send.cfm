
<CFSET PAGE_TITLE="Email Contract">
<CFSET GROUP="contracts">
<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">
<CFPARAM NAME="FORM.ATTACH_PAYMENT_DET" DEFAULT="0">
<CFPARAM NAME="form.Group_Deals" DEFAULT="0">
<CFPARAM NAME="form.EZTemplate" DEFAULT="0">
<cfparam name="form.dup_warn_msg" default="">
<cfparam name="form.resetToWip" default="0" />

<!--- Encrypt the CID the file --->
<cf_cryp	type = "en" string = "#Form.Program_CID#" key = "#request.key#">
<CFSET CID=cryp.value>
 <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif form.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<BR><BR>
<H4 STYLE="Color: Red;">
The following Email has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<cfset useLakebaseForFaxDocuments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_details")>
<cfif useLakebaseForFaxDocuments>
	<cftry>
		<cfif isdefined("FORM.Doc_ID")>
			<cfset Fax_Documents = application.oLakebase.toQuery(
				application.oLakebase.selectRows("document_details", { "select" = "doc_uni_name,doc_title", "doc_id" = "in.(#FORM.Doc_ID#)" })
			)>
		<cfelse>
			<cfset Fax_Documents = application.oLakebase.toQuery([], "Doc_Uni_Name,doc_title")>
		</cfif>
		<cfcatch type="any">
			<cfset useLakebaseForFaxDocuments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForFaxDocuments>
	<CFQUERY NAME="Fax_Documents" DATASOURCE = "#Application.Datasource#">
		SELECT 		Doc_Uni_Name,
					doc_title
		FROM		Document_Details
		WHERE 		1=2 <CFIF isdefined("FORM.Doc_ID")> OR Doc_ID IN (#ListQualify(FORM.Doc_ID, "'", ",")#)</CFIF>
	</CFQUERY>
</cfif>


<CFSAVECONTENT VARIABLE = "coverpage">
Enclosed: please find the following documents#chr(13)#&nbsp;&nbsp;&nbsp;&nbsp;Program Number: #FORM.Program_no#<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents">#chr(13)#&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</CFLOOP></CFIF>
</CFSAVECONTENT>
</CFOUTPUT>

<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>

		<CFOUTPUT>
		<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0">
		<TR>
			<TD VALIGN="top"><B>Date:</B></TD>
			<TD ROWSPAN="100%" BGCOLOR="Orange"></TD>
			<TD>#Form.SenderDate#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>From:</B></TD>
			<TD>#Form.Senderaddress#</TD>
		</TR>
		<cfif isDefined("form.program_name")>
			<TR>
				<TD VALIGN="top"><B>Attachments:</B></TD>
				<TD>Program Number: #FORM.Program_no#
					<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#request.APPLICATIONPATH#\common_files\documents\uploaded_doc\#Doc_Uni_Name#")><br>#Doc_Title#</CFIF></CFLOOP></CFIF>
					<CFIF FORM.Attach_Payment_Det NEQ 0><BR>Payment Addresses</CFIF>
				</TD>
			</TR>
		</cfif>
		<TR>
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
		<!---
		<cfif isDefined("form.program_name")>
			<TR>
				<TD VALIGN="top"><B>Program</B></TD>
				<TD><CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\contracts\contract_documents\#Form.Program_Name#"></TD>
			</TR>
		</cfif>
		--->
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>
		<cfif Not isDefined("form.program_name")>
			<div align="center" STYLE="color: red; font-size: 13px; font-weight: bold;">
				#form.dup_warn_msg#
			</div>
		</cfif>
		</CFOUTPUT>
</CFSAVECONTENT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#<BR></CFOUTPUT>

<cfif isDefined("form.program_name")>
	<CFSET Formula_File_Path = "#Application.Doc_Path#\temp_files\contracts\contract_documents\Formula_#Form.Program_Name#">
	<CFSET Scr_Formula_Path = "\temp_files\contracts\contract_documents\Formula_#Form.Program_Name#">
	<CFSET Program_ID = Form.Program_CID>

	<CFSET Show_Formula_Details = false>
	<CFIF IsDefined("FORM.Formula_Details")>
		<CFIF FORM.Formula_Details EQ "Formula_Details">
			<CFSET Show_Formula_Details = true>
		</CFIF>
	</CFIF>
	<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 0>
	<CFIF Show_Formula_Details>
		<CFINCLUDE template="Formula_Price_Products_Summary_Save.cfm">

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Repalcing Formula file name with program title																 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CF_Naming_Email_Attachments
					Title="Formula_Details_#FORM.Program_no#" 
					Relative_Src_File_Path="#Scr_Formula_Path#"
					Relative_Dest_Dir_Path ="Temp_Files\Formula"
					Return_Variable_Name="Formula_FN" /><!--- FORM.Prog_Title --->

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</CFIF>

	<!------ Handle for lumpsum distributor attachment ----->
	<cfif isDefined("FORM.Lumpsum_Distributor")>
		<CFSET URL.Program_ID = Form.Program_CID>
		<CFSET LumpsumDistributor_Summary_Src_Path = "\common_files\contracts\lumpsum_distributors_display.cfm">

		<CFSAVECONTENT variable="LumpsumDistributor_Summary_Content">
			<CFINCLUDE template="#LumpsumDistributor_Summary_Src_Path#">
		</CFSAVECONTENT>

		<CF_Writing_Email_Attachment
  				Naming_Format="#Application.LumpsumLabel#_#application.returned_customer_setting.distributor_label_plural#_#FORM.Program_no#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#LumpsumDistributor_Summary_Content#"
				addNewLine="No"
				Return_File_Name="LumpsumDistributor_Summary_FileName" /> <!--- FORM.Prog_Title --->
	</cfif>

	<!---HANDLE FOR GROUP DEAL ITEMS--->
	<CFIF form.Group_Deals neq 0>

		<CFSET form.Program_ID = Form.Program_CID>

		<CFSET Group_File_Path = "#Application.Doc_Path#\temp_files\contracts\contract_documents\Group_Items_#Form.Program_Name#">
		<CFSET Group_Summary_Src_Path = "\temp_files\contracts\contract_documents\Group_Items_#Form.Program_Name#">

		<CFSAVECONTENT variable="Group_Summary_Content">
			<CFINCLUDE template="Groups/program_group_display.cfm">
		</CFSAVECONTENT>


		<CFFILE ACTION = "write"
			FILE="#Group_File_Path#"
			OUTPUT="#Group_Summary_Content#">

		<CF_Naming_Email_Attachments
			Title="Group_Item_Summary_#FORM.Program_no#" 
			Relative_Src_File_Path="#Group_Summary_Src_Path#"
			Relative_Dest_Dir_Path ="Temp_Files\Program"
			Return_Variable_Name="rGroupItemSummary" /> <!--- FORM.Prog_Title --->

	</CFIF>

	<!------ Handle for sysco deal sheet attachment ----->
	<cfif isDefined("FORM.Sysco_Deal_Sheet")>
		<CFSET URL.CID = CID />
		<CFSET form.Program_ID = Form.Program_CID>
		<CFSET SyscoDealSheet_Src_Path = "\common_files\contracts\sysco_deal_sheet\sysco_report_get_excel_file.cfm">

		<CFSAVECONTENT variable="SyscoDealSheet_Content">
			<CFINCLUDE template="#SyscoDealSheet_Src_Path#">
		</CFSAVECONTENT>

		<CF_Writing_Email_Attachment
  				Naming_Format="sysco_report_#FORM.Program_no#"
				File_Extension="xls"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#SyscoDealSheet_Content#"
				addNewLine="No"
				Return_File_Name="SyscoDealSheet_Summary_FileName" /> <!--- FORM.Prog_Title --->
	</cfif>

	<!---HANDLE FOR Volume--->
	<CFIF isDefined("form.Program_Volume")>

		<CFSET form.Program_ID = Form.Program_CID>
		<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
		<CFSET Program_Volume.Load_Basic_Information(form.Program_ID, request.AccessStructure.Company_Main_ID)>
		<cfsavecontent variable="volume_content">
			<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
			</STYLE>
			<cfoutput>
			<table BORDER="0" WIDTH="700" CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD COLSPAN="100%" BGCOLOR="">
						<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
						#application.returned_customer_setting.company_name#</DIV>
						<B><FONT SIZE="+1" COLOR="Navy">
							#Program_Volume.Contract_Number#
						</FONT></B>
					</td>
				</tr>
			</table>
			</cfoutput>
			<cfset Program_Volume.fnProgramVolumeResult()>

		</cfsavecontent>
		<CFSET volume_content = REReplaceNoCase(volume_content, "<a[^>]*?>", "", "All")>
		<CFSET volume_content = REReplaceNoCase(volume_content, "</a>", "", "All")>
		<CF_Writing_Email_Attachment
			Naming_Format="Program_Volume_#FORM.Program_no#"			
			Relative_Path="\Temp_Files\Volume\"
			Output_Content="#volume_content#"
			File_Extension="html" 		
			Return_File_Name="rProgramVolumeSummary" /><!--- FORM.Prog_Title	 --->

	</CFIF>

	<!--- Handle for Freight Summary --->
	<CFIF isDefined("form.Freight_Summary")>
		<cfset URL.cid = CID>
		<cfset URL.command = "summary">
		<cfset URL.mode = "view">
		<CFSET Freight_Summary_Src_Path = "\common_Files\contracts\Freight\Index.cfm">

		<CFSAVECONTENT variable="Freight_Summary_Content">
			<STYLE TYPE="text/css">
			 td{font-family:	sans-serif;font-size:10px;}
			 #header{font-size: 12px;}
			.overrideDisplay {color:red;font-size:14px;font-style:normal;font-weight:normal;}
			.topheader td {font-weight:bold;font-size:12px;border:none}
			.zeroValue {color:red;}
			.nonZeroValue {color:black;}
			.overriddenShow {visibility: visible; color:red; font-size:14px; font-style:normal; font-weight:normal;}
			.overriddenHide {visibility: hidden}
			</STYLE>
			<CFINCLUDE template="#Freight_Summary_Src_Path#">
		</CFSAVECONTENT>

			<CF_Writing_Email_Attachment
  			Naming_Format="Freight_Summary_#FORM.Program_no#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#Freight_Summary_Content#"
				addNewLine="No"
				Return_File_Name="Freight_Summary_FileName" /> 
	</CFIF>

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Repalcing Program file name with program title																 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- get install path --->
	<CFSET InstallPath = request.APPLICATIONPATH>
	<!--- END get install path --->

	<CF_Naming_Email_Attachments
					Title="Program_#FORM.Program_no#"
					Relative_Src_File_Path="temp_files\contracts\contract_documents\#Form.Program_Name#"
					Relative_Dest_Dir_Path ="Temp_Files\Program"
					Return_Variable_Name="Program_File_Path" /><!--- FORM.Prog_Title --->

  <cfoutput>
  <!---remove all javascript tags/calls that caused JS errors in opening attachments in IE--->
  <cffile action="read"  file="#Program_File_Path#" variable="attachmentContent">					
  <cffile action="write" file="#Program_File_Path#" output="#AttachmentFormat(attachmentContent)#">					
  </cfoutput>

	<CFSET Record_Count = 0>
	<CFOUTPUT QUERY="Fax_Documents">
	<CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")>
		<CFSET Record_Count = Record_Count + 1>
		<CFSET search = ".">
		<CFSET content = Doc_Uni_Name>
		<CFSET File_Extension = Find(search,content)>
		<CFSET length = len(content)>
		<CFSET right_len = length-File_Extension>
		<CFSET File_Extension = right(content,right_len)>

		<CF_Naming_Email_Attachments
					Title="#Doc_Title#"
					Relative_Src_File_Path="data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#"
					Relative_Dest_Dir_Path ="Temp_Files\Program\Documents"
					Return_Variable_Name="Dis_File_Name"
					File_Extension="#File_Extension#" /> <!--- FORM.Prog_Title --->

		<CFIF Record_Count EQ 1>
			<CFSET Dis_File_Name_String = "#Dis_File_Name#">
		<CFELSE>
			<CFSET Dis_File_Name_String = "#Dis_File_Name_String#;#Dis_File_Name#">
		</CFIF>
	</CFIF>
	</CFOUTPUT>


	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Preparing payable to and Send payment to Address Attachment--->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CFIF FORM.Attach_Payment_Det NEQ 0>
		<CFSET ProgramID = FORM.Program_CID>
		<CFSET DetailsAbout = FORM.Attach_Payment_Det>
		<CFSAVECONTENT VARIABLE="PaymentDetails">
		<CFINCLUDE TEMPLATE="PaymentAddressInfo.cfm">
		</CFSAVECONTENT>

		<CF_Writing_Email_Attachment
			Naming_Format="PaymentAddressesOfProgram_#FORM.Program_no#"				
			Relative_Path="\Temp_Files\PaymentAddress\"
			Output_Content="#PaymentDetails#"
			Return_File_Name="PaymentfName" /> <!--- FORM.Prog_Title --->
	</CFIF>

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send email..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- D35555 auto cc the sender on outbound view program emails START--->
	<cfif appSettings.getIncludeUsersEmailAuto()>
			<cfset cc_address = request.AccessStructure.User_Email>
			<!---<cfset Broker_Address = replace(Broker_Address, request.AccessStructure.User_Email, " ","ALL")>--->
			<cfif  FindNoCase(request.AccessStructure.User_Email,Broker_Address) gt 0>
				<cfset cc_address = " ">
			</cfif>
	<cfelse>
			<cfset cc_address = " ">
	</cfif>	
	
<!--- D35555 auto cc the sender on outbound view program emails END--->
<cfoutput>
	<CF_EMAILWRAPPER TO			=	"#Broker_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
		CC = "#cc_Address#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"
		messagetype="1"
		generatedby="3"
		apparea="1"
		userid="#request.AccessStructure.user_id#">

		<TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		<cfif isDefined("form.program_name")>
			<TR VALIGN="top">
			<TD>
			Attachments:Please find the following documents<br>&nbsp;&nbsp;&nbsp;&nbsp;Program Number: #FORM.Program_no#
			<CFIF fax_Documents.recordcount GT 0><CFLOOP QUERY="fax_Documents"><CFIF FILEEXISTS("#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#Doc_Uni_Name#")><br>&nbsp;&nbsp;&nbsp;&nbsp;#Doc_Title#</CFIF></CFLOOP></CFIF>
			<CFIF FORM.Attach_Payment_Det NEQ 0><br>&nbsp;&nbsp;&nbsp;&nbsp;[#FORM.Program_no#] Payment Addresses</CFIF>
			<CFIF SHOW_FORMULA_PRICING_DETAIL_INFO><br>&nbsp;&nbsp;&nbsp;&nbsp;[#FORM.Program_no#] Formula Pricing Details</CFIF>
			<cfif isDefined("FORM.Lumpsum_Distributor")><br>&nbsp;&nbsp;&nbsp;&nbsp;[#FORM.Program_no#] #Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</CFIF>
			</TD>
			</TR>
		<cfelse>
			<TR>
				<TD>
					<HR>
				</TD>
			</TR>
			<TR VALIGN="top">
			<TD>
				<div align="center" STYLE="color: red; font-size: 13px; font-weight: bold;">
					#form.dup_warn_msg#
				</div>
			</TD>
			</TR>
		</cfif>
		</TABLE>


		<!--- The cfmailparam IS the file being attached --->
		<!--- <cfmailparam file = "#Program_File_Path#"> --->
		<cfif isDefined("form.program_name")>
			<cf_emailwrapperparam file = "#Program_File_Path#" store="yes" />
			<CFIF isdefined("Dis_File_Name_String")>
				<CFLOOP INDEX = "disp_item" LIST = "#Dis_File_Name_String#" DELIMITERS = ";">
					<!--- <CFMAILPARAM FILE = "#disp_item#"> --->
					<CF_EMAILWRAPPERPARAM FILE = "#disp_item#" />
				</CFLOOP>
			</CFIF>

			<CFIF FORM.Attach_Payment_Det NEQ 0>
				<cf_emailwrapperparam file = "#PaymentfName#" store="yes" />
			</CFIF>
			<!--- Formula Details ------>
			<CFIF SHOW_FORMULA_PRICING_DETAIL_INFO>
				<CF_EMAILWRAPPERPARAM FILE = "#Formula_FN#" store="yes" />
			</CFIF>
			<CFIF form.Group_Deals neq 0>
				<cf_emailwrapperparam file = "#rGroupItemSummary#" store="yes" />
			</CFIF>
			<cfif isDefined("FORM.Lumpsum_Distributor")>
				<cf_emailwrapperparam file = "#LumpsumDistributor_Summary_FileName#" store="yes" />
			</cfif>
			<cfif isDefined("FORM.Program_Volume")>
				<cf_emailwrapperparam file = "#rProgramVolumeSummary#" store="yes" />
			</CFIF>
			<cfif isDefined("FORM.Sysco_Deal_Sheet")>
				<cf_emailwrapperparam file = "#SyscoDealSheet_Summary_FileName#" store="yes" />
			</cfif>
			<cfif isDefined("FORM.Freight_Summary")>
				<cf_emailwrapperparam file = "#Freight_Summary_FileName#" store="yes" />
			</cfif>
		</cfif>
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Tim Ford - 06/23/2014: Label D43528 - Duplicate emails being sent. Change location back to contract edit menu. This is to avoid duplicate emails being sent. --->
<cfif isDefined("form.program_name")>
	<script>
		window.location.href='contract_edit_menu.cfm?CID=<cfoutput>#CID#</cfoutput>';
	</script>
</cfif>

<cfif form.EZTemplate EQ 0>
<CF_button
	button_name		=	""
	button_caption	=	"return to contract view"
	button_action	=	"window.location.href='contract_edit_menu.cfm?CID=#CID#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to program view..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">

</cfif>


</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif form.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif form.EZTemplate EQ 0 and form.resetToWip eq 1>
    <script>
	 window.parent.close();
	</script>
	</cfif>

</BODY>
</HTML>

<cffunction name="AttachmentFormat" returntype="string" output="false" hint="Remove javascript tags/calls from a html string.">
  <cfargument name="text" type="string" required="true">
  
  <cfscript>
   // remove script tags and their contents
   var newtext = ReReplaceNoCase (arguments.text, "<script.*?>.*?</script>", "", "all");
   // remove any tag that contains a JavaScript call
   newtext = ReReplaceNoCase (newtext, '<[^>]*="javascript:[^"]*"[^>]*>', '', 'all');
  </cfscript>
  
  <cfreturn newtext>
</cffunction>