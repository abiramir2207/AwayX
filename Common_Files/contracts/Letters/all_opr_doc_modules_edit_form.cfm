<cfsilent>
<!--- 
FILE: 		
FILENAME: all_opr_doc_modules_edit_form.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		08/15/2008 - RBL
EDITED:			08/16/2010 - Milan [Convert to Itext in Java]

FUNCTIONALITY:
- This form allows the authorized user to edit a pre-existing program 'Operator' letter with deletions ONLY...
--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="url.CMID"					type="numeric"	default="0">
<cfparam name="url.LID"						type="numeric"	default="0">
<cfparam name="url.pages" 					type="numeric" 	default="0">
<cfparam name="url.bNoDistributors" 				type="numeric" 	default="0">


</cfsilent>

<cfoutput>

<cfinclude template="doc_modules/inc_all_head_top.cfm">

<!--- The Deal Letters V2 ALWAYS Starts with the original data... --->
<cfinclude template="doc_modules/inc_all_vars.cfm">

<!--- what type of letter are we creating RIGHT NOW --->
<cfset variables.abbreviation = "opr">

<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [begin] --->
<cfinclude template="doc_modules/inc_init_vars.cfm">
<!--- IMPORTANT - This must always follow the above variables - IMPORTANT [end] --->

<!--- alpha order The Magnificent 7 --->
<cfparam name="variables.qProgramBidRequestInitial"		type="query" 	default="#queryNew('Bid_Request')#">
<cfparam name="variables.qProgramClauseInitial"			type="query" 	default="#queryNew('Clause')#">
<cfparam name="variables.qProgramDistributorInitial"	type="query" 	default="#queryNew('Distributor')#">
<cfparam name="variables.qProgramFixedPriceInitial"		type="query" 	default="#queryNew('Fixed_Price')#">
<cfparam name="variables.qProgramLumpSumInitial"		type="query" 	default="#queryNew('Lump_Sum')#">
<cfparam name="variables.qProgramOperatorInitial"		type="query" 	default="#queryNew('Operator')#">
<cfparam name="variables.qProgramRebateInitial"			type="query" 	default="#queryNew('Rebate')#">

<!--- D16774 8/14/08 [begin]
<!--- XXXXXXXXXX Get info for/from XML Doc [begin] XXXXXXXXXX --->
<cfquery name="variables.qGetLetterInfo" datasource="#application.datasource#">
  SELECT 			letter_path
  FROM 				program_letters
  WHERE 			program_letters.program_letters_id = #url.lid#
</cfquery>
--->
<cfset variables.currentLetterPath = trim(application.oLetterManager.getLetterPath(url.lid))>
<!--- D16774 8/14/08 [end] --->

<cfset variables.html_left_characters_to_remove = findNoCase('\data_files',variables.currentLetterPath)>
<cfset variables.html_letter_path_length = len(variables.currentLetterPath)>
<cfset variables.html_relativePath = application.doc_path & '\' & right(variables.currentLetterPath,variables.html_letter_path_length-variables.html_left_characters_to_remove)>
<cfset variables.html_fileName_relativeURL = application.doc_mapping & '/' &  replace(right(variables.currentLetterPath,variables.html_letter_path_length-variables.html_left_characters_to_remove),"\","/","all")>
<!--- ACTION: TO DELETE - TEMPORARILY KEEPING UNTIL TESTED "../../../common_documents" IS NOW application.doc_mapping & '/' & --->
<cfset variables.xml_fileName_relativeURL = lCase(replace(html_fileName_relativeURL,'.htm','.xml'))>

<font size="1" color="Red">[</font> &nbsp;<font size="1" color="Blue"><a  href="##" id="backLink" onClick="javascript:go_back();">back</a></font>&nbsp;<font size="1" color="Red">]</font>
<br /><font></font><br />
<cfinclude template="doc_modules/inc_all_head_bottom_body_top.cfm">

<!--- tech note: 3/12/2008 qGetProgramDetails, qGetTemplateSettings no longer needed? --->
<cf_generate_all_edit_form
		lsContractMainIDs="#List_Of_Contract_Main_IDs#"
		lsDistributorNames="#valueList(variables.qProgramDistributorInitial.Name,', ')#"
  	lsDistributorIDs="#valueList(variables.qProgramDistributorInitial.contract_distributors_id,',')#"
		lsOperatorNames="#valueList(variables.qProgramOperatorInitial.operator_name,', ')#"
		lsOperatorIDs="#valueList(variables.qProgramOperatorInitial.operator_id,',')#"
		oAppSettings="#appsettings#"
    pages="#url.pages#"
		<!---preferred_fontFamily="Century Gothic"--->
		program_id="#url.CMID#"
		program_letter_id="#url.LID#"
    qGetLetterSettings="#getlettersettings#"
    qGetProgramDetails="#getprogramdetails#"	
    qGetTemplateSettings="#gettemplatesettings#"
    qProgramBidRequest="#variables.qProgramBidRequestInitial#"
    qProgramClause="#variables.qProgramClauseInitial#"
    qProgramDistributor="#variables.qProgramDistributorInitial#"
    qProgramFixedPrice="#variables.qProgramFixedPriceInitial#"
    qProgramLumpSum="#variables.qProgramLumpSumInitial#"
    qProgramOperator="#variables.qProgramOperatorInitial#"
    qProgramRebate="#variables.qProgramRebateInitial#"
    relative_path="#opr_path#"
    stPDFBodyInfo="#variables.stPDFBodyInfo#"	
    stPDFEndInfo="#variables.stPDFEndInfo#"
    stPDFHeaderInfo="#variables.stPDFHeaderInfo#"
    stPDFIntroInfo="#variables.stPDFIntroInfo#"
    xml_fileName_relativeURL="#variables.xml_fileName_relativeURL#">

<a href="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" target="new"><img src="images/btn_flash_icon.gif" height="16" width="120" border="0"></a>

<cfinclude template="doc_modules/inc_all_body_bottom.cfm">

</cfoutput>

<script>
function go_back()
{
	//window.location.reload();
	//history.back();
	/* history.back() does not work when flash forms are loaded. */
	<cfoutput>
	window.location.href = 'show_opr_dis_letters.cfm?CID=#url.CMID#&SkipLock=1';
	</cfoutput>
}
</script>