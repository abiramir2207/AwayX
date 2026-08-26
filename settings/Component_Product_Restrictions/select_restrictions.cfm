<html>
<head>
	<title>Component Product Restrictions</title>

<style>
.Datatable
{
	font-size: 10px;
	border-bottom:solid #cccccc 1px; 
	border-left:solid #cccccc 1px; 
	border-right:solid #cccccc 1px; 
	border-top:solid #cccccc 1px; 
}

.Datacell
{
	border-bottom:solid #cccccc 1px; 
	border-right:solid #cccccc 1px;
	border-left:solid #cccccc 1px;
}

body,td
	{
		font: 11px Arial;
	}
A
	{
		color: blue;
		text-decoration: none;	
	}
A:HOVER
	{
		color: red;
		text-decoration: underline;	
	}
</style>
<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
</head>

<cfif isDefined("form.blnSubmit")>
<cfquery name="GetFieldForProducts" datasource="#application.datasource#">
SELECT Product_Group_Attribute_ID_Field
FROM Product_Group_Attribute
WHERE Product_Group_Level_ID IN 
(	
	SELECT Component_Product_Restriction_Criteria
	FROM General_Settings
)
</cfquery>

<!--- Delete prior selections --->
<cfset useLakebaseForDeleteFromComponentProductRestriction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_product_restriction")>
<cfif useLakebaseForDeleteFromComponentProductRestriction>
	<cftry>
		<cfset application.oLakebase.deleteRows("component_product_restriction", {
			"discount_type_id" = "eq.#form.Discount_Type_ID#",
			"component_id" = "eq.#form.Component_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteFromComponentProductRestriction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteFromComponentProductRestriction>
<cfquery name="DeleteFromComponentProductRestriction" datasource="#application.datasource#">
DELETE FROM Component_Product_Restriction
WHERE Discount_Type_ID = '#form.Discount_Type_ID#'
AND Component_ID = '#form.Component_ID#'
</cfquery>
</cfif>
<!--- Delete from mapping table --->
<cfset useLakebaseForDeleteFromComponentProductsRestricted = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_products_restricted")>
<cfif useLakebaseForDeleteFromComponentProductsRestricted>
	<cftry>
		<cfset application.oLakebase.deleteRows("component_products_restricted", {
			"discount_type_id" = "eq.#form.Discount_Type_ID#",
			"component_id" = "eq.#form.Component_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteFromComponentProductsRestricted = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteFromComponentProductsRestricted>
<cfquery name="DeleteFromComponentProductsRestricted" datasource="#application.datasource#">
DELETE FROM Component_Products_Restricted
WHERE Discount_Type_ID = '#form.Discount_Type_ID#'
AND Component_ID = '#form.Component_ID#'
</cfquery>
</cfif>

<cfif isDefined("form.CriteriaID")>
<cfloop list="#CriteriaID#" index="Criteria_ID">
<!--- Insert new selections --->
	<cfset useLakebaseForInsertIntoMainTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_product_restriction")>
<cfif useLakebaseForInsertIntoMainTable>
	<cftry>
		<cfset application.oLakebase.insertRow("component_product_restriction", {
			"discount_type_id" = "#form.Discount_Type_ID#",
			"component_id" = "#form.Component_ID#",
			"criteria_restriction_id" = "#Criteria_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoMainTable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoMainTable>
<cfquery name="InsertIntoMainTable" datasource="#application.datasource#">
	INSERT INTO Component_Product_Restriction
	(Discount_Type_ID, Component_ID, Criteria_Restriction_ID)
	VALUES
	('#form.Discount_Type_ID#', '#form.Component_ID#', '#Criteria_ID#')
	</cfquery>
</cfif>
	
<!--- Insert into mapping table --->
	<cfquery name="InsertIntoMappingTable" datasource="#application.datasource#">
	INSERT INTO Component_Products_Restricted
	(Discount_Type_ID, Component_ID, Product_ID)
	SELECT '#form.Discount_Type_ID#' AS Discount_Type_ID,
			'#form.Component_ID#' AS Component_ID,
			BSA_Foodservice_Items_Master_ID
	FROM BSA_Foodservice_Items_Master
	WHERE #evaluate("GetFieldForProducts.Product_Group_Attribute_ID_Field")# = '#Criteria_ID#'
	AND BSA_Foodservice_Items_Master.Deleted = 0
	AND BSA_Foodservice_Items_Master.Active_Code = 'A'
	</cfquery>
</cfloop>
</cfif>
<Script>
window.close();
</SCRIPT>
<cfabort>
</cfif>

<body>
<cfoutput>
<cfset useLakebaseForRestrictedProductCriteria = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForRestrictedProductCriteria>
	<cftry>
		<cfset RestrictedProductCriteria = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "component_product_restriction_criteria"
			}), "component_product_restriction_criteria"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForRestrictedProductCriteria = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForRestrictedProductCriteria>
<cfquery name="RestrictedProductCriteria" datasource="#application.datasource#">
SELECT Component_Product_Restriction_Criteria FROM General_Settings
</cfquery>
</cfif>
<!--- Dev Note 12188 BSD: Added query to display component name --->
<cfquery name="getComponentName" datasource="#application.datasource#">
Select Program_Rebates_Component_Name
From Program_Rebates_Component_Name
Where Program_Rebates_Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.component_id#" />
</cfquery>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!---get product group types--->
<cfset qGetProductGroupTypes = CreateObject("component","components.products.Group.DataManager").getProductGroupsData() />
<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
<cfset qGetProductGroupAttributes = ProductGroupAttributeManager.getProductGroupAttributes(active=1) />
<cfscript>

function isNextRow(maxCols, currCols)
{
	if(currCols LTE 1)
	{
		//WriteOutput(currCols & " " & maxCols & " " & "<br>");
		return 0;
	}
	else
	{
		//WriteOutput(currCols & " " & maxCols & " " & (not(currCols) mod maxCols) & "<br>");
		return (not(currCols) mod maxCols);
	}
}

</cfscript>
<cfset maxColsPerRow = 3>

			<cfquery name="GetCriteriaDetails" dbtype="query">
				SELECT	*
				FROM	qGetProductGroupAttributes
				 WHERE	Product_Group_Level_ID = #RestrictedProductCriteria.Component_Product_Restriction_Criteria#
			</cfquery>
			
			<cfset useLakebaseForExistingSelections = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("component_product_restriction")>
<cfif useLakebaseForExistingSelections>
	<cftry>
		<cfset ExistingSelections = application.oLakebase.toQuery(
			application.oLakebase.selectRows("component_product_restriction", {
				"component_id" = "eq.#url.Component_ID#",
				"discount_type_id" = "eq.#url.Discount_Type_ID#",
				"select" = "criteria_restriction_id"
			}), "criteria_restriction_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForExistingSelections = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForExistingSelections>
<cfquery name="ExistingSelections" datasource="#application.datasource#">
			SELECT Criteria_Restriction_ID
			FROM Component_Product_Restriction
			WHERE Component_ID = '#url.Component_ID#'
			AND Discount_Type_ID = '#url.Discount_Type_ID#'
			</cfquery>
</cfif>
			
			<Cfset ExistingSelectionList = valuelist(ExistingSelections.Criteria_Restriction_ID)>
			
			<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
			<cfset qGroupTypeInfo = ProductGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = GetCriteriaDetails.Product_Group_Level_Type) />
			
			
			<cfset currentColCount = 0>
			<form name="SelectRestrictions" method="post" action="select_restrictions.cfm">
			<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="Blue";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";  
	WIDTH="500px";
</CFSCRIPT>
			<cfset TitleColspan = maxColsPerRow -1>
			<div align="Center"><strong>Component Name - #getComponentName.Program_Rebates_Component_Name#</strong></div>
			<div align="Center"><font color="red"><strong>Restrictions do not apply to group selections</strong></font></div>
			<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
				<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="99%" CLASS="MainTable">
		<TR BGCOLOR="##ffce84">
			<TD ID="Header" colspan="#maxColsPerRow#">
			<INPUT TYPE="checkbox" NAME="AllItems" VALUE="" onClick="javaScript: CHSelectAll('CriteriaID', this.checked);">			
			<B>#qGroupTypeInfo.Label#s to restrict from this component</B></TD>
		</TR>
			
			<Tr>
				<cfset GetGroupValues = ProductGroupAttributeManager.getProductGroupValues(
							productGroupType 	= qGroupTypeInfo, 
							groupList 			= "", 
							restrictOnGroupList = 0,
							businessSegmentId 	= 0,
							cachedwithin		= 30) />

			<cfloop query="GetGroupValues">
			
				<TD>
				<input type="checkbox" name="CriteriaID" value="#Group_ID#" <cfif listcontains(ExistingSelectionList, Group_ID) IS NOT 0>checked</cfif>>#Group_Name# 
				</TD>
				<cfset currentColCount = currentColCount + 1 />
				<cfif isNextRow(maxColsPerRow, currentColCount)>
				</TR>
				<TR  BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
				<cfset currentColCount = 0 />
				</cfif>
			
			</cfloop>
			</table>
			</fieldset>
			<input type="hidden" name="Component_ID" value="#url.Component_ID#">
			<input type="hidden" name="Discount_Type_ID" value="#url.Discount_Type_ID#">
			<input type="hidden" name="blnSubmit" value="1">
			</form>
			
			<div align="Center">
			<CF_button
			button_name		=	""
			button_caption	=	"Save component restrictions"
			button_action	=	"SelectRestrictions.submit();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save component restrictions"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			></div>
			
			</cfoutput>

</body>
</html>
