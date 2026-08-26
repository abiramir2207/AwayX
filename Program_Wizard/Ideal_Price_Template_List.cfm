<!---
  * ====================================================================================================
  *  @File: Ideal_Price_Template_List.cfm
  *  @Author: Dinesh Rachala
  *  @Date: April 2022
  * ====================================================================================================
--->
<cfset PAGETITLE = "PROGRAM TEMPLATES">
<cfset jQuery.version ="1.12.4">
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/settings/settings_title.cfm">

<cfset 	AllTemplates = CreateObject("component", "components.programs.template.TemplateManager").getAll(IgnoreRetail=1, IgnoreDistibutorTemplates=1)>
<cfinclude template="/Script/cf/ListCompare.cfm">
<cfparam name="form.Selected" default="0">

<cfset useLakebaseForCheckTemplateList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ideal_price_template_list")>
<cfif useLakebaseForCheckTemplateList>
	<cftry>
		<cfset CheckTemplateList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ideal_price_template_list", {
				"first_parent_id" = "eq.#url.First_Parent_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckTemplateList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckTemplateList>
<cfquery name="CheckTemplateList" datasource="#application.datasource#">
	SELECT *
	FROM Ideal_Price_Template_List
	WHERE First_Parent_ID = #url.First_Parent_ID#
	AND Deleted = 0
</cfquery>
</cfif>
<cfset selectedTemplate = valueList(CheckTemplateList.Include_First_Parent_ID)>

<cfif form.Selected>
	<!--- BELOW VARAIBLE CONTAINS LIST OF REMOVED TEMPLATES --->
	<cfset removedTemplates = listCompare(selectedTemplate, form.first_Parent_ID)>
	<cfloop list="#removedTemplates#" delimiters="," index="iFirstParentID">
		<cfquery name="UpdData" datasource="#application.datasource#">
			UPDATE Ideal_Price_Template_List
			SET Deleted =1, Deleted_Date = getdate(), Deleted_By = '#request.AccessStructure.User_ID#'
			WHERE First_Parent_ID = #url.First_Parent_ID#
			AND Include_First_Parent_ID = #iFirstParentID#
			</cfquery>
	</cfloop>

		<!--- BELOW VARAIBLE CONTAINS LIST OF NEWLY ADDED TEMPLATES --->
		<cfset addedTemplates = listCompare(form.first_Parent_ID, selectedTemplate)>
		<cfloop list="#addedTemplates#" delimiters="," index="iFirstParentID">

			<cfquery name="CheckTemplateExist" datasource="#application.datasource#">
				SELECT *
				FROM Ideal_Price_Template_List
				WHERE First_Parent_ID = #url.First_Parent_ID#
				AND Include_First_Parent_ID = #iFirstParentID#
				AND Deleted = 1
			</cfquery>
			<cfif CheckTemplateExist.recordCount>
				<cfquery name="UpdOldRecord" datasource="#application.datasource#">
					UPDATE Ideal_Price_Template_List
					SET Deleted =0, Updated_Date = getdate(), Updated_By = '#request.AccessStructure.User_ID#'
					WHERE First_Parent_ID = #url.First_Parent_ID#
					AND Include_First_Parent_ID = #iFirstParentID#
					</cfquery>
			<cfelse>
					<cfquery name="InsData" datasource="#application.datasource#">
						INSERT INTO Ideal_Price_Template_List(First_Parent_ID, Include_First_Parent_ID, Created_By, Created_Date)
						VALUES (#url.First_Parent_ID#, #iFirstParentID#, '#request.AccessStructure.User_ID#' , getdate())
					</cfquery>
			</cfif>
		</cfloop>
	<script>
		window.close();
	</script>
</cfif>
<form name="TemplateList" action="Ideal_Price_Template_List.cfm?First_Parent_ID=<cfoutput>#url.First_Parent_ID#</cfoutput>" method="POST" id="TemplateList">
	<table border="0" width="100%">
		<tr>
			<td colspan="3" align="right">
				<input type="checkbox" name="selectAll" value="1" id="selectAll">Check/UnCheck All &nbsp;
				<a onclick="javascript:resetForm();" STYLE="cursor: pointer;" >
					<cfoutput>#application.util.string.actionLinkFormat("Reset")#</cfoutput>
				</a>
				<a onclick="javascript:submitForm();" STYLE="cursor: pointer;" >
					<cfoutput>#application.util.string.actionLinkFormat("Save")#</cfoutput>
				</a>
			</td>
		</tr>
		<tr>
		<cfoutput query="AllTemplates">
			<td width="33%"><input type="checkbox" name="first_Parent_ID" class="first_Parent_ID" value="#first_Parent_ID#" <cfif listfind(selectedTemplate, first_Parent_ID)>CHECKED</cfif>>#CREATED_TYPE#</td>
			<cfif AllTemplates.currentRow MOD 3 IS 0></tr></cfif>
		</cfoutput>
	</table>
	<input type="hidden" name="Selected" value="0" id="Selected">
</form>
<script>
	function submitForm() {
		$('#Selected').val('1');
		$( "form" ).submit();
	}
	function resetForm() {
		//$("#TemplateList").trigger("reset");
		$(".first_Parent_ID, #selectAll").prop('checked', false);
	}
	$("#selectAll").click(function () {
    $(".first_Parent_ID").prop('checked', $(this).prop('checked'));
});
</script>