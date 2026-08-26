<!--- 
FILE: 		common_files/contracts/contract_documents_menu.cfm
FILEname:   contract_documents_menu.cfm							
CREATED:  	??/??/???? - ???
EDITED:   	10/29/2008 - Brad Lee MMCP/ACI [D17386]

FUNCTIONALITY: 
--->

<!------ Contract_Documents_Menu.cfm ----->
<cfoutput>
<cfparam name="FORM.Contract_Main_ID" default="0" />
<CFSET TR_BORDER_WIDTH = 1>
<CFSET TD_FORE_COLOR = "C1DAA1">
<CFSET TD_BORDER_COLOR = "##6E6E6E">
<CFSET FONT_COLOR_SELECTED = "000000">
<CFSET FONT_COLOR_NOT_SELECTED = "000000">

<style>
	.headerspacer
  	{
   		border-bottom		: solid #TR_BORDER_WIDTH#px #TD_BORDER_COLOR#;
  	}
	.headernotselected
  	{
   		background-color 	: dddddd;
   		border-bottom		: solid #TR_BORDER_WIDTH#px #TD_BORDER_COLOR#;
   		cursor				: pointer;	
  	}
  	.headerselected
  	{
   		border-left			: solid #TR_BORDER_WIDTH#px #TD_BORDER_COLOR#;
   		border-top			: solid #TR_BORDER_WIDTH#px #TD_BORDER_COLOR#;
   		border-right		: solid #TR_BORDER_WIDTH#px #TD_BORDER_COLOR#;
   		background-color 	: #TD_FORE_COLOR#;
   		cursor				: pointer;	
   		/*TEXT-TRANSFORM		: uppercase;*/
  	}
	A.tablink_back1, A:Hover.tablink_back1
	{
		color: 				#FONT_COLOR_SELECTED#;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	A:visited.tablink_back1
	{
		color: 				#FONT_COLOR_SELECTED#;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	A.tablink_fore1, A:Hover.tablink_fore1
	{
		color: 				#FONT_COLOR_NOT_SELECTED#;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	A:visited.tablink_fore1
	{
		color: 				#FONT_COLOR_NOT_SELECTED#;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}	
</style>

<cfset page_titles = "">
<cfset page_urls = "">
<cfset page_names = "">
<cfset record_exist = "">

<!---Tim Ford - Label 15244: Allow attachments regardless of program status--->
<!---if the Attachment_Count query doesn't exist then run it--->
<cfif not isDefined("Attachment_Count")>
	<cfset useLakebaseForAttachmentCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
	<cfif useLakebaseForAttachmentCount>
		<cftry>
			<cfset Attachment_Count = application.oLakebase.toQuery(
				application.oLakebase.selectRows("contract_attachments", { "program_id" = "eq.#FORM.Contract_Main_ID#", "deleted" = "eq.false" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForAttachmentCount = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForAttachmentCount>
		<cfset useLakebaseForAttachment_Count = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForAttachment_Count>
	<cftry>
		<cfset Attachment_Count = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_attachments", {
				"program_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAttachment_Count = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAttachment_Count>
<CFQUERY NAME="Attachment_Count" DATASOURCE="#application.datasource#">
			SELECT 	*
			FROM	Contract_Attachments
			WHERE	Program_ID = '#FORM.Contract_Main_ID#'
			AND		Deleted=0
		</CFQUERY>
</cfif>
	</cfif>
</cfif>

<cfset page_titles = listappend(page_titles, "attachments", ",")>
<cfset page_urls = listappend(page_urls, "/Common_Files/Contracts/contract_attachments.cfm?CID=#EncryptedCID#", ",")>
<cfset page_names = listappend(page_names, "at", ",")>
<cfset record_exist = listappend(record_exist, Attachment_Count.recordCount, ",")>

<cfif CanEditProgram and NOT GETCONTRACTINFO.generic_type eq "LSAutoPay">
	<cfset page_titles = listappend(page_titles, "clauses", ",")>
	<cfset page_urls = listappend(page_urls, "/Clause_Library/index.cfm?command=dClauseProgram&programId=#form.contract_main_id#&programTypeId=#CSLGETCONTRACTINFO.PROGRAMTYPE_ID#", ",")>
	<cfset page_names = listappend(page_names, "clause", ",")>
	<cfset record_exist = listappend(record_exist, qProgramClause.recordCount, ",")>

<cfelseif appsettings.getlettersavailable() EQ 1 and NOT GETCONTRACTINFO.generic_type eq "LSAutoPay">

	<cfset page_titles = listappend(page_titles, "letters", ",")>
	<cfset page_urls = listappend(page_urls, "/Common_Files/Contracts/contract_letters.cfm?CID=#EncryptedCID#", ",")>
	<cfset page_names = listappend(page_names, "letters", ",")>
	<cfset record_exist = listappend(record_exist, 1, ",")>

</cfif>

<!--- 17386 [begin] --->
<cfparam name="variables.authorRSPID" type="string" default="">
<!--- 17386 [end] --->

<table cellpadding="1" cellspacing="0" border="0" width="<cfif request.accessStructure.User_ID EQ variables.authorRSPID>830<cfelse>800</cfif>">
<tr>
	<td class="headerspacer">&nbsp;</td>
	<cfset tabCounter = 1>
	<cfloop list="#page_titles#" index="thismenuitem">
		<cfset thisTabUrl = ListGetAt(page_urls, tabCounter, ",")>
		<cfset thisTabName = ListGetAt(page_names, tabCounter, ",")>
		<cfset thisRecordexist = ListGetAt(record_exist, tabCounter, ",")>
		<cfif CSL_CallingPageCode eq thisTabName>
			<cfset class_name= "headerselected">
			<cfset text_class_name= "tablink_fore1">
		<cfelse>
			<cfset class_name= "headernotselected">
			<cfset text_class_name= "tablink_back1">
		</cfif>
		<cfif thisRecordexist GT 0>
			<cfset img_src = "\images\yes_small.gif">
		<cfelse>
			<cfset img_src = "\images\no_small.gif">		
		</cfif>
		<td width="100" class="#class_name#" align="center" nowrap><a class="#text_class_name#" href="#thisTabUrl#"><img src="#img_src#" border="0">&nbsp;#thismenuitem#</a></td>
		<td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"></td>
		<cfset tabCounter = tabCounter + 1>
	</cfloop>
	
	<td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1"></td>
</tr>
</table>
</cfoutput>