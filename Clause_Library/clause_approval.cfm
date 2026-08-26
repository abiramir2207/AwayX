<cfparam name="URL.CID" 	default="">
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">

<!--- 34392 FOB vs DEL validation :: if validation fails this approval process would stop otherwise it would continue with all logic below --->
<!--- Dev Note -Milan (38629). Validation (including validation at the distributor level, which does not exist on "greatest_program_value.cfm")
has been added to the "rates" grid and so we do not need validation here anymore. No need to maintain the logic in 2 places. 
<cfmodule template="\Common_Files\contracts\greatest_program_value.cfm" 	Program_ID = #cryp.value#>
--->

<!------ clause_approval.cfm ----->
<cfoutput>
<!--- Milan;19623/25647 - This file is not being used anymore for "Simple Clause". This file just relocates (check at the end of the file) --->

<!--- Milan;25647 - (Start) This file is not being used anymore for "Simple Clause". It is only being used when "Simple Clause" app setting is OFF --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfif appSettings.getSimpleClause() eq 0>
<!---  Dev Note :10193- Milan; This is to remove "cfoutput" tags around url.cid --->
<cfif FindNoCase("<cfoutput>",URL.CID) neq 0>
	<cfset URL.CID = RemoveChars(URL.CID,1,10)>
	<cfset URL.CID = RemoveChars(Reverse(URL.CID),1,11)>
	<cfset URL.CID = Reverse(URL.CID)>
</cfif>
<CFSET Program_ID = cryp.value>
<cfinclude template="/Clause_Library/Clause_Functions.cfm">

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>



<!------ set defaults ----->
<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
	SELECT    Program_Control_Panel_Options.generic_type,
	Program_Control_Panel_Options.Pullbacks_On,
	Program_Control_Panel_Options.pullback_from_corporate,
	Program_Control_Panel_Options.is_pullback_corporate_deal,
	ProgramControl_Panel_Options_ID
	FROM dbo.Contract_Main INNER JOIN
	dbo.Program_Control_Panel_Options ON 
	dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#Program_ID#'
</CFQUERY>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset qGetProfileTemplates = templateManager.getProfileTemplates(
				profileId = request.AccessStructure.Profiles_ID,
				forbidAccessType = 6,
				templateId = getProgramTemplateInfo.ProgramControl_Panel_Options_ID
				) />

<!--- <CFIF ((getProgramTemplateInfo.generic_type EQ "Distributor Trade/Shelter"
	and getProgramTemplateInfo.pullback_from_corporate EQ 1) OR 
	(getProgramTemplateInfo.generic_type EQ "Operator Direct or HQ Programs" OR 
	getProgramTemplateInfo.generic_type EQ "Operator-Deviated Pricing")) and
	getProgramTemplateInfo.Pullbacks_On EQ 1 and  qGetProfileTemplates.approve eq 1>
	<cfset profitAnalysisPage = "/Common_Files/Contracts/pullbacks/pullback_index.cfm?CID=#URL.CID#&margincheck=1">
<cfelseif getProgramTemplateInfo.is_pullback_corporate_deal EQ 1 and getProgramTemplateInfo.Pullbacks_On EQ 1  and getProgramTemplateInfo.generic_type EQ "Distributor Trade/Shelter" and qGetProfileTemplates.approve eq 1>
	<cfset profitAnalysisPage = "/Common_Files/Contracts/pullbacks/pullback_index.cfm?CID=#URL.CID#&FromDistributor_Prg=1&margincheck=1">
<cfelse> --->
	<cfset profitAnalysisPage = "/Common_Files/Contracts/duplicate_check.cfm?CID=#URL.CID#">
<!--- </CFIF> --->

<cfparam name="form.state" 	default="0">
<cfset qGetDiscountTypes = CreateObject("component","components.programs.Program").getDiscountTypes(Program_ID) />
<cfset clauseProgramManager = CreateObject("component", "components.clause_library.ClauseProgramManager").init() />

<cfif form.state>
	<!------ loop thru removed clauses ----->
		<cfset fieldName = buildFieldName("Removed_Clause", "0", 1, 0)>
		<cfparam name="form.#fieldName#" 	default="">		
		<cfloop list="#Evaluate("form.#fieldName#")#" index="clauseId">		
			<cfset catId = Evaluate("catId_#clauseId#")>
			<cfset clauseProgramManager.insertClause(clauseId, Program_ID, catId, 1, 0, request.AccessStructure.User_ID)>	
		</cfloop>
	<cfloop query="qGetDiscountTypes">
		<cfset fieldName = buildFieldName("Removed_Clause", "0", 2, Discount_Type_ID)>
		<cfparam name="form.#fieldName#" 	default="">
		<cfloop list="#Evaluate("form.#fieldName#")#" index="clauseId">
			<cfset catId = Evaluate("catId_#clauseId#")>
			<cfset clauseProgramManager.insertClause(clauseId, Program_ID, catId, 2, Discount_Type_ID, request.AccessStructure.User_ID)>	
		</cfloop>
	</cfloop>
	
	<!------ loop thru edited clauses ----->
	<cfparam name="form.edited_clause_list" 	default="">
	<cfloop list="#form.edited_clause_list#" index="clauseId">
		<cfif isDefined("edited_clause_#clauseId#")>
			<cfset newClauseId = Evaluate("edited_clause_#clauseId#")>
			<cfif newClauseId NEQ clauseId>
				<cfset clauseProgramManager.updateClause(clauseId, newClauseId, Program_ID)>
			</cfif>
		</cfif>
	</cfloop>
	<cflocation addtoken="No" url="#profitAnalysisPage#">
</cfif>
<!------ check whether clause needs approval ----->
<cfset qGetClauseRequireApproval = clauseProgramManager.getClauseRequireApproval(Program_ID, ValueList(qGetDiscountTypes.Product_Type_ID))>

<cfif qGetClauseRequireApproval.recordCount GT 0>	
	<cfset userCanApprove = clauseProgramManager.getClauseProgramApproveAccess(request.AccessStructure.Profiles_ID)>

	<cfset tableBorderColor = "##FFF7E5">
	
	<cfset clauseChangeTypeName = "The following required clauses were removed from the program. Select the clause you wish to include in the program,The following clauses were edited in the program&##44; which version do you want to include in the program.">
	<cfset currChangeType = 0>
	<cfset formName = "frmClauseApproval">
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<script language="JavaScript">
	function expandNextRow(aThisObj)
	{
		var thisObj = getParentObject(aThisObj, "tr");
		var nextSib = thisObj.nextSibling;
		if(nextSib)
		{
			if(nextSib.style.display == "")
			{
				nextSib.style.display = "none";
			}
			else
			{
				nextSib.style.display = "";
			}
		}
		return false;
	}
	function submitForm(thisForm, sCommand)
	{
		thisForm.submit();
		return false;
	}	
	</script>
	
	<cfset useLakebaseForqGetDistinctChangeType1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetclauserequireapproval")>
<cfif useLakebaseForqGetDistinctChangeType1>
	<cftry>
		<cfset qGetDistinctChangeType1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetclauserequireapproval", {
				"clause_change_type" = "eq.1",
				"order" = "clause_category_name.asc",
				"select" = "clause_library_id,clause_category_id,clause_category_name,clause_id,category_name,clause_library_body,clause_body,clause_change_type"
			}), "clause_library_id,clause_category_id,clause_category_name,clause_id,category_name,clause_library_body,clause_body,clause_change_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistinctChangeType1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistinctChangeType1>
<cfquery name="qGetDistinctChangeType1" dbtype="query">
		SELECT	DISTINCT Clause_Library_ID, Clause_Category_ID, Clause_Category_Name, Clause_ID, Category_Name,
				Clause_Library_Body, Clause_Body, Clause_Change_Type
		FROM	qGetClauseRequireApproval
		WHERE
				Clause_Change_Type = 1
		ORDER BY Clause_Category_Name
	</cfquery>
</cfif>
	<cfset useLakebaseForqGetDistinctChangeType2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetclauserequireapproval")>
<cfif useLakebaseForqGetDistinctChangeType2>
	<cftry>
		<cfset qGetDistinctChangeType2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetclauserequireapproval", {
				"clause_change_type" = "eq.2",
				"order" = "clause_category_name.asc",
				"select" = "clause_library_id,clause_category_id,clause_category_name,clause_id,category_name,clause_library_body,clause_body,clause_change_type"
			}), "clause_library_id,clause_category_id,clause_category_name,clause_id,category_name,clause_library_body,clause_body,clause_change_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistinctChangeType2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistinctChangeType2>
<cfquery name="qGetDistinctChangeType2" dbtype="query">
		SELECT	DISTINCT Clause_Library_ID, Clause_Category_ID, Clause_Category_Name, Clause_ID, Category_Name,
				Clause_Library_Body, Clause_Body, Clause_Change_Type
		FROM	qGetClauseRequireApproval
		WHERE
				Clause_Change_Type = 2
		ORDER BY Clause_Category_Name
	</cfquery>
</cfif>
	<style>
		.topBorder TD
		{
			border-top: 1px solid ##93BEE2;
		}
	</style>
	<form action="clause_approval.cfm?CID=#URL.CID#" method="post" name="#formName#">
		<cfif qGetDistinctChangeType1.recordCount>
		<table cellpadding="2" cellspacing="0" border="0" width="100%" class="MainTable">
			<cfset discCount = qGetDiscountTypes.recordCount + 1>			
			<colgroup>
				<col span="1" width=""></col>
				<col span="#discCount#" width="100"></col>
			<colgroup>		
			<caption align="left" STYLE="color: navy; font-size: 13px; font-weight: bold;">#ListGetAt(clauseChangeTypeName, 1, ",")#</caption>		
			<tr bgcolor="##FFCE84">
				<td id="header"><B>Clause</B></td>
				<td align="center" id="header"><B>General</B></td>
				<cfloop query="qGetDiscountTypes">
				<td align="center" id="header"><B>#Discount_Type_Desc#</B></td>
				</cfloop>
			</tr>
			<cfloop query="qGetDistinctChangeType1">
			<tr>
				<td>
				<A HREF="index.cfm?id=#Clause_Library_ID#&command=dClause" onClick="NewWindow(this.href,'Clause_Display','625','450','Yes', 'Yes');return false;">#Clause_Category_Name#</A>
				<input type="Hidden" name="catId_#Clause_Library_ID#" value="#Clause_Category_ID#">
				</td>
				<cfset clauseId = Clause_Library_ID>
				<cf_clause_approval_section
						clauseType = "1"
						clauseId = "#clauseId#">
				<cfloop query="qGetDiscountTypes">
					<cf_clause_approval_section
							clauseType = "2"
							clauseId = "#clauseId#"
							discountTypeId = "#Discount_Type_ID#">					
				</cfloop>
			</tr>
			</cfloop>
		</table>
		</cfif>
		<br>
		<cfset Edited_Clause_List = "">
		<cfif qGetDistinctChangeType2.recordCount>
		<table cellpadding="2" cellspacing="0" border="0" width="100%">
			<caption align="left" STYLE="color: navy; font-size: 13px; font-weight: bold;">#ListGetAt(clauseChangeTypeName, 2, ",")#</caption>		
			<tr bgcolor="##FFCE84">
				<td colspan="2" id="header" align="center"><B>From</B></td>
				<td id="header" align="center">&nbsp;</td>
				<td colspan="2" id="header" align="center"><B>To</B></td>
			</tr>			
			<cfloop query="qGetDistinctChangeType2">
			<cfset Edited_Clause_List = ListAppend(Edited_Clause_List, Clause_ID, ",")>
			<tr class="topBorder">
				<td bgcolor="#tableBorderColor#"><input type="radio" value="#Clause_Library_ID#" name="Edited_Clause_#Clause_ID#"></td>
				<td bgcolor="#tableBorderColor#" width="45%"><A HREF="index.cfm?id=#Clause_Library_ID#&command=dClause" onClick="NewWindow(this.href,'Clause_Display','625','450','Yes', 'Yes');return false;">#Clause_Category_Name#</A></td>
				<td width="10%" ALIGN="center" title="click here to toggle details">
				<a STYLE="font-family:'Courier New'font-weight:bold;text-decoration:none;font-size:14px;" href="##" onClick="javaScript: return expandNextRow(this);"> <B>----&gt;</B> </a></td>
				<td bgcolor="#tableBorderColor#"><input checked type="radio" value="#Clause_ID#" name="Edited_Clause_#Clause_ID#"></td>
				<td bgcolor="#tableBorderColor#" width="45%"><A HREF="index.cfm?id=#Clause_ID#&command=dClause" onClick="NewWindow(this.href,'Clause_Display','625','450','Yes', 'Yes');return false;">#Category_Name#</A></td>
			</tr>
			<tr>
				<td colspan="2">#Clause_Library_Body#</td>
				<td style="border:none;">&nbsp;</td>
				<td colspan="2">#Clause_Body#</td>
			</tr>
			</cfloop>
		</table>
		</cfif>
		<input type="Hidden" name="Edited_Clause_List" value="#Edited_Clause_List#">
		<input type="Hidden" name="state" value="1">		
	</form>	
	<CFIF userCanApprove EQ 0>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: red; font-size: 13px; font-weight: bold;"><IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"> You are not authorized to approve the above clause changes.</DIV>
	<CFELSE>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: green; font-size: 13px; font-weight: bold;"> You are authorized to approve the above changes.</DIV>		
	</CFIF>
	<table align="center">
		<tr>
		<td>
		<CF_button
			button_name		=	""
			button_caption	=	"Close"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Close"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
		</td>
		<CFIF userCanApprove>
		<td>
		<CF_button
			button_name		=	""
			button_caption	=	"Approve"
			button_action	=	"submitForm(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Approve"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
		</td>
		</CFIF>
		</tr>
	</table>
	<br>
<cfelse>
	<cflocation addtoken="No" url="#profitAnalysisPage#">
</cfif>
</cfif>
<!--- Milan;25647 - (End) This file is not being used anymore for "Simple Clause". It is only being used when "Simple Clause" app setting is OFF --->

<!--- Milan;19623- This file is not being used anymore for "Simple Clause". This file just relocates. --->
<cfif appSettings.getSimpleClause() eq 1>
	<cfset profitAnalysisPage = "/Common_Files/Contracts/duplicate_check.cfm?CID=#URL.CID#">
	<cflocation addtoken="No" url="#profitAnalysisPage#">
</cfif>
</cfoutput>