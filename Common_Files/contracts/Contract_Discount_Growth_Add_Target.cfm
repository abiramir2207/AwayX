<cfif isDefined("url.Program_ID")><cfset Form.Program_ID = url.Program_ID></cfif>
<CFSET PAGE_TITLE= "Select Growth Targets">
<cfparam name="Action" default="Create">
<cfparam name="Child_ID" default="">
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">
<cfparam name="url.EZTemplate" default="0">
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	
	<style>
	#dataStyle
		{
			font-size: 10px;
		}
	
	</style>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
	<!---Format program information for a gazillion different variable names--->
	<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFIF len(URL.CID) EQ 0>
		<CFSET temp = 0>
	<CFELSE>
		<CFSEt temp = cryp.value>
	</CFIF>
	<CFSET CSL_Contract_Main_ID = temp>
	<CFSET CSL_CallingPageCode = "growth"> 
	
	<cfparam name="AddTarget" default=0>
	
	<CFSET URL.Contract_Main_ID = cryp.value>
	<CFSET FORM.Contract_Main_ID = cryp.value>
	<cfset Contract_Main_ID = cryp.value>
	<cfset Program_ID = cryp.value>
	<!---End program/contract information setting--->
	

<!---Initialize all components here--->
<!---initialize app settings object--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
	
<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<!---End initialize all components--->

<!--- Get all the Growth Comparison Period UOM's (Program_Growth_Comparison_Period_UOM is for "Amount" OR "Volume" for growth tiers calculation)--->
<cfinvoke component = "components.programs.Growth.GrowthComponent" 
				method = "getGrowthComparisonPeriodUOM" 
				returnVariable = "AllGrowthComparisonPeriodUOM">
</cfinvoke>
					
<!---Globally available queries--->

<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
	SELECT	*
	FROM	dbo.Contract_Main 
			INNER JOIN
            dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>

<!---End globally available queries--->

<!---Initilized variables--->	
<cfparam name="FORM.Product_Level_1" 	default="">
<cfparam name="FORM.groupLevelProducts" 	default="0">
<CFPARAM NAME="Form.Discount_Growth_Item_Level" DEFAULT="0">
<CFPARAM NAME="Form.Discount_Growth_Group_Level" DEFAULT="0">
<CFPARAM NAME="form.Level_1" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_1" DEFAULT="">
<CFPARAM name="form.navigate" default="0">
<CFPARAM name="form.stopnavigate" default="0">
<CFPARAM name="defaultselected" default="1">
<CFPARAM name="FORM.AddTarget" default="0">
<cfparam name="form.Product_List" default="">
<CFPARAM NAME="form.Dynamic_Static_Groups" DEFAULT="0">

<cfset 	businessSegmentID = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
<cfset	bAllowSelectAllProducts = ProductGroupManager.allowSelectAllProducts(4, FORM.Contract_Main_ID) />
<cfset  bGrowthSelectProductsType = ProductGroupManager.growthSelectProductsType(FORM.Contract_Main_ID, Component_ID) />
<cfif bGrowthSelectProductsType GT 0>
	<cfset bAllowSelectAllProducts = 0 />
</cfif>
<cfset bAllowSelectProducts = 1 />
<cfif bGrowthSelectProductsType GT 1>
	<cfset bAllowSelectProducts = 0 />
</cfif>

<!---End initialized variables--->

<cfoutput>
<!---Body--->
<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getAllowNavigate()>onbeforeunload="verifyNavigate();"</cfif>>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>
<!---set if groups are static or dynamic--->
<cfif isDefined("GetSettings.Dynamic_Static_Groups")>
	<cfset form.Dynamic_Static_Groups = GetSettings.Dynamic_Static_Groups />
</cfif>

<!---Modification: Group Deals--->
<cfset form.Discount_Growth_Item_Level = GetSettings.Discount_Growth_Item_Level />
<cfset form.Discount_Growth_Group_Level = GetSettings.Discount_Growth_Group_Level />

<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0>
	<cfset EzButton_Disable = 1>
<cfelse>
	<cfset EzButton_Disable = 0>
</cfif>

<cfif url.EZTemplate EQ 0>
<BLOCKQUOTE><BLOCKQUOTE>
</cfif>

<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 65px; top: 0px;"> </cfif> 
	  <!----Get current targets--->
	  <cfquery name="GetTargets" datasource="#application.datasource#">
	  SELECT Program_Growth_Components.Program_Growth_Component_ID AS Child_ID, 
	  Program_Growth_Components.Component_Name, 
	  Program_Growth_Components.Component_Description, 
	  Program_Growth_Component_Tiers.Range_End,
	  Program_Growth_Components.Component_UOM, 
	  Program_Growth_Component_Tiers.Growth_Amount,
	  Program_Growth_Components.Program_Growth_Comparison_Period_UOM_ID,
	  Program_Growth_Components_Name_ID
	  FROM Program_Growth_Components 
	  INNER JOIN Program_Growth_Component_Tiers ON Program_Growth_Component_Tiers.Program_Growth_Component_ID 
	  = Program_Growth_Components.Program_Growth_Component_ID AND Program_Growth_Component_Tiers.Deleted 
	  = 0 WHERE Program_Growth_Components.Deleted = 0 AND Program_Growth_Components.IsParent 
	  = 0 AND Program_Growth_Components.Parent_ID = '#Component_ID#' 
	  </cfquery>
	  <cfparam name="Products_Are_There" default="0">
	  <cfif len(trim(Form.Product_List)) GT 0>
		<cfquery name="GetProductsForTarget" datasource="#application.datasource#">
		SELECT BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, 
		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID FROM BSA_Foodservice_Items_Master 
		WHERE BSA_Foodservice_Items_Master_ID IN(#listqualify(Form.Product_List, 
		"'")#) 
		</cfquery>
		<cfif GetProductsForTarget.Recordcount>
		  <cfset Products_Are_There = 1>
		  <cfset ProductList = Form.Product_List>
		</cfif>
	  </cfif>
	  <!---Include navigation--->
	  <cfif appSettings.getGrowthExpansion1()>
		<!--- Gets component information needed for this growth--->
		<cfset useLakebaseForGetComponentInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
		<cfif useLakebaseForGetComponentInformation>
			<cftry>
				<cfset GetComponentInformation = application.oLakebase.toQuery(
					application.oLakebase.selectRows("program_growth_components", {
						"program_growth_component_id" = "eq.#Component_ID#",
						"select" = "rate_type,program_growth_component_type_id,program_growth_component_id,program_growth_comparison_period_uom_id"
					})
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetComponentInformation = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetComponentInformation>
			<cfquery name="GetComponentInformation" datasource="#application.datasource#">
			SELECT Rate_Type, Program_Growth_Component_Type_ID, Program_Growth_Component_ID, Program_Growth_Comparison_Period_UOM_ID
			FROM Program_Growth_Components WHERE Program_Growth_Component_ID = '#Component_ID#'
			</cfquery>
		</cfif>
		<cfset Component_Type 	= GetComponentInformation.Program_Growth_Component_Type_ID>
		<cfset Rate_Type 		= GetComponentInformation.Rate_Type>
		<cfinclude template="/common_files/contracts/contract_discount_growth_navigation.cfm">
	  </cfif>
	  <form name="AddTargets" action="Contract_Discount_Growth_Add_Target.cfm?CID=#url.CID#&Component_ID=#Component_ID#&Action=#Action#&Child_ID=#Child_ID#&EZTemplate=#url.EZTemplate#" method="post">
		<INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
		<input name="Component_ID" type="hidden" value="#Component_ID#">
		<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
		<input name="DTPS_Program_ID" type="hidden" value="#FORM.Contract_Main_ID#">
		<SCRIPT SRC="/script/javascript/string_functions.js"></script>
		<table WIDTH="800" BORDER="0" CELLSPACING="0" CELLPADDING="2" style="maintable">
		  <tr>
			<td colspan="100%" align="Center"><font color="navy" size="+1">
			  <p></p>
			  Growth Targets</font></td>
		  </tr>
		  <cfparam name="ProductList" default="">
		  <!---No previous targets--->
		  <cfif Action IS "Edit">
			<cfquery name="GetPriorValues" datasource="#application.datasource#">
			SELECT Program_Growth_Component_Tiers.Range_End, Program_Growth_Components.Component_Name, 
			Program_Growth_Components.Component_UOM, Program_Growth_Components.Sample_Period, 
			Program_Growth_Components.Comparison_Type, Program_Growth_Component_Tiers.Growth_Amount,
			Program_Growth_Components.Program_Growth_Comparison_Period_UOM_ID
			FROM Program_Growth_Components INNER JOIN Program_Growth_Component_Tiers 
			ON Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID 
			WHERE Program_Growth_Components.Program_Growth_Component_ID = '#Child_ID#' 
			</cfquery>
			<cfif len(trim(ProductList)) IS 0>
				<cfquery name="GetProductsForTarget" datasource="#application.datasource#">
					SELECT 	BSA_Foodservice_Items_Master.Item, 
							BSA_Foodservice_Items_Master.Description, 
			  				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
							Contract_Products.Is_Group,
							Contract_Products.Product_Group_Level_ID
					FROM 	BSA_Foodservice_Items_Master 
							INNER JOIN Contract_Products ON 
							Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
			  				AND Contract_Products.Deleted = 0 
							INNER JOIN Program_Growth_Component_Product_Data ON 
							Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID 
							AND Program_Growth_Component_Product_Data.Deleted = 0 
							AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#Child_ID#' 
					WHERE 	BSA_Foodservice_Items_Master.Deleted = 0 
			  </cfquery>
			  <cfparam name="ExistingProductList" default="">
			  <cfif GetProductsForTarget.Recordcount GT 0>
				<cfset Products_Are_There = 1>
				<cfset ExistingProductList = ListAppend(ExistingProductList, ValueList(GetProductsForTarget.BSA_Foodservice_Items_Master_ID, ","), ",")>
			  </cfif>
			</cfif>
			<input type="hidden" NAME="AddTarget" 			value="1">
			<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#ExistingProductList#">
			<cfif len(Trim(Form.Product_List)) LT 1>
			  <INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#ExistingProductList#">
			  <cfelse>
			  <INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Product_List#">
			</cfif>
			<cfparam name="FORM.Component_Name" 			default= "#GetPriorValues.Component_Name#">
			<cfparam name="FORM.Target_Amount" 				default="#GetPriorValues.Range_End#">
			<cfparam name="FORM.Target_UOM" 				default="#GetPriorValues.Component_UOM#">
			<cfparam name="Sample_Period" 					default="#GetPriorValues.Sample_Period#">
			<cfparam name="Comparison_Type" 				default="#GetPriorValues.Comparison_Type#">
			<cfparam name="FORM.Target_Bonus" 				default="#GetPriorValues.Growth_Amount#">
			<cfparam name="FORM.Program_Growth_Comparison_Period_UOM" default="#GetPriorValues.Program_Growth_Comparison_Period_UOM_ID#">
			<cfelse>
			<input type="hidden" NAME="AddTarget" 			value="1">
			<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="">
			<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Product_List#">
			<cfparam name="FORM.Component_Name" 			default= "">
			<cfparam name="FORM.Target_Amount" 				default="">
			<cfparam name="FORM.Target_UOM" 				default="">
			<cfparam name="FORM.Target_Bonus" 				default="">
			<CFPARAM NAME="Comparison_Type"					DEFAULT="">
			<CFPARAM NAME="Sample_Period" 					DEFAULT="">
			<cfparam name="FORM.Program_Growth_Comparison_Period_UOM" default="1">
		  </cfif>
		  <tr> 
			<td bgcolor="orange"><font style="bold" size="2"><strong>Target Name</strong></font></td>
			<td bgcolor="orange"><font style="bold" size="2"><strong>Target</strong></font></td>
			<td bgcolor="orange"><font style="bold" size="2"><strong>Unit of Measure</strong></font></td>
			<td bgcolor="orange"><font style="bold" size="2"><strong>Completion <cfoutput>#Application.BonusLabel#</cfoutput></strong></font></td>
			<td bgcolor="orange">&nbsp; </td>
		  </tr>
		  <tr> 
			<td><span id="error_Component_Name"></span> <input type="text" size="30" maxlength="50" name="Component_Name" value="#FORM.Component_Name#"> 
			</td>
			<cfset allowList = "0123456789" />
			<cfset allowListUOM3 = "0123456789" />
			<cfset maxDecimalLen = 0 />
			<cfset maxDecimalLenUOM3 = 0 />
			<cfif appSettings.getGrowthDecimal4PercentTier()>
			  <cfset allowListUOM3 = "0123456789." />
			  <cfset maxDecimalLenUOM3 = 2 />
			</cfif>
			<cfset currentAllowList = allowList />
			<cfset currentMaxDecimalLen = maxDecimalLen />
			<cfif defaultselected EQ 3>
			  <cfset currentAllowList = allowListUOM3 />
			  <cfset currentMaxDecimalLen = maxDecimalLenUOM3 />
			</cfif>
			<td><span id="error_Target_Amount"></span>
			 <input type="text" size="6" maxlength="10" name="Target_Amount"  onkeyup="clenseText(this, this.allowCharsList)" onblur="formatTextboxDecimalPlaces(this, this.maxDecimalLen);" value="#FORM.Target_Amount#" allowCharsList="#currentAllowList#" maxDecimalLen="#currentMaxDecimalLen#" <cfif EzButton_Disable EQ 1>disabled</cfif>> 
	<cfif EzButton_Disable EQ 1>
		<input type="hidden" name="Target_Amount" value="#FORM.Target_Amount#">
	</cfif>
			</td>
			<td> 
			<cf_uom_dropdown
			company_main_id			=	""
			default_option_on		=	""
			setDefaultSelected 		=	"#defaultselected#"
			default_option_text		=	""
			default_option_value	=	"0"
			dropdown_name			=	"Target_UOM"
			option_text_abbreviated	=	""
			plural_uom_display		=	""
			product_type_id			=	""
			program_template_id		=	"#GetAllContractInfo.ProgramType_ID#"
			selected_uom_id			=	"#FORM.Target_UOM#"
			text_before_tag_close	=	"onChange=""showPercent(this)"""
			uom_id_exclusion_list	=	""
			uom_id_inclusion_list	=	"#ListOfAvailUOM#"
			disabled				=  	"#EzButton_Disable#"
		> 
		<cfif EzButton_Disable EQ 1>
		<input type="hidden" name="Target_UOM" value="#FORM.Target_UOM#">
		</cfif>
		</td>
		<td>
		<input type="text" size="6" maxlength="10" name="Target_Bonus"  onkeyup="clenseText(this, '0123456789')" value="#FORM.Target_Bonus#" <cfif EzButton_Disable EQ 1>disabled</cfif>>
		<cfif EzButton_Disable EQ 1>
		<input type="hidden" name="Target_Bonus" value="#FORM.Target_Bonus#">
		</cfif>
		</td>
		  </tr>
		  <!---Only show this if component_uom IS 3 (percent) (Program_Growth_Comparison_Period_UOM is for "Amount" OR "Volume" for growth tiers calculation)--->
		  <TR  ID="TR_Percent_UOM" <cfif FORM.Target_UOM NEQ 3>style="display: none"</cfif>> 
			<td colspan="2" align="right">&nbsp;</td>
			<TD> <B>Comparison Period UOM:</B><br> &nbsp; 
				 <cfset SelectedGrowthComparisonPeriodUOM = GetTargets.Program_Growth_Comparison_Period_UOM_ID>
				<cfloop query="AllGrowthComparisonPeriodUOM">
					<input type="radio" name="Program_Growth_Comparison_Period_UOM" value="#AllGrowthComparisonPeriodUOM.Program_Growth_Comparison_Period_UOM_ID#" <cfif SelectedGrowthComparisonPeriodUOM neq "" AND AllGrowthComparisonPeriodUOM.Program_Growth_Comparison_Period_UOM_ID neq SelectedGrowthComparisonPeriodUOM>Disabled="Disabled"</cfif><cfif AllGrowthComparisonPeriodUOM.Program_Growth_Comparison_Period_UOM_ID is FORM.Program_Growth_Comparison_Period_UOM>checked</cfif>> #Program_Growth_Comparison_Period_UOM#
				</cfloop>
			</TD>
		  </tr>

		  <TR  ID="TR_Percent" <cfif FORM.Target_UOM NEQ 3>style="display: none"</cfif>> 
			<td colspan="2" align="right">&nbsp; <span ID="error_Comparison_Type"></span> 
			  <span ID="error_Sample_Period"></span> </td>
			<TD > <B>Comparison Period:</B><br> &nbsp; <input type="radio" name="Comparison_Type" value="1" <cfif Comparison_Type IS 1>checked</cfif>>
			  Same period, prior year <Br>
			  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <strong>OR</strong><Br> &nbsp; 
			  <input type="radio" name="Comparison_Type" value="2" <cfif Comparison_Type IS 2>checked</cfif>> 
			  <input type="text" size="5" maxlength="5" name="Sample_Period" value="<cfoutput>#Sample_Period#</cfoutput>" onkeyup="clenseText(this, '0123456789')";>
			  Days before program start date </TD>
		  </tr>
		  <tr>
			<Td colspan="100%"><hr color="navy"></tr>
		  <cfif Products_Are_There IS 1>
			<tr> 
			  <td colspan="100%"> <table cellspacing="3" cellpadding="3" WIDTH="100%">
				  <CFLOOP QUERY="GetProductsForTarget">
					<TD CLASS="dataStyle" NOWRAP WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2" > 
					  <span> <FONT SIZE="1"> #trim(GetProductsForTarget.Description)# 
					  <BR>
					  #GetProductsForTarget.Item# </FONT> </span> </TD>
					<CFIF GetProductsForTarget.CURRENTROW MOD 3>
					  <CFELSE></TR>
					  <TR>
					</CFIF>
					<!---TSF: Modification Label 6676 --->
					<cfif isDefined("Is_Group") and Is_Group eq 1>
						<cfset form.Level_1 = ListAppend(form.Level_1, BSA_Foodservice_Items_Master_ID) />
						<cfif not ListFindNoCase(Form.GroupLevel_1, Product_Group_Level_ID)>
							<cfset Form.GroupLevel_1 = ListAppend(Form.GroupLevel_1, Product_Group_Level_ID) />
						</cfif>
					</cfif>
				  </CFLOOP>
				</table></td>
			</tr>
		  </cfif>
		  <tr> 
			<!----add groups links if it's on--->
			<cfif form.Discount_Growth_Group_Level>
			  <td> <CF_button
							button_name		=	""
							button_caption	=	"select groups"
							button_action	=	"javascript: showGroupSearchWindow();"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						> </td>
			</cfif>
			<cfif form.Discount_Growth_Item_Level>
			  <td> <CF_button
							button_name		=	""
							button_caption	=	"select products"
							button_action	=	"javascript:NewWindow('/Flex/search/ItemSearchFx.cfm?SelectSingleSearchResultOnly=0&FieldName=Product_List&FormName=AddTargets&DiscountType=4&EZTemplate=#url.EZTemplate#&isparent=0&component_id=#gettargets.Program_Growth_Components_Name_ID#','name','1024','715','Yes', 'Yes');return false;" 
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						> </td>
			</cfif>
			<!--- 	<cfif bAllowSelectAllProducts>
		
			<td>
				<CF_button
					button_name		=	""
					button_caption	=	"add all products"
					button_action	=	"javascript: addGroupsLevelProducts(1, \'#businessSegmentID#\');"
					button_type		=	"link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</td>
		
		</cfif> --->
			<cfif Action IS "Edit">
			  <td><CF_button
					button_name		=	""
					button_caption	=	"save changes"
					button_action	=	"javascript: confirmCompletion(1);"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				> <cfelse> 
			  <cfif len(trim(Form.Product_List)) GT 0>
				<td><CF_button
					button_name		=	""
					button_caption	=	"save and add target"
					button_action	=	"javascript: confirmCompletion(2);"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				> </td>
				<td> <CF_button
					button_name		=	""
					button_caption	=	"save and continue"
					button_action	=	"javascript: confirmCompletion(3);"
					button_type		=	"link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				> </td>
			  </cfif></td>
			</cfif>
		  </tr>
		</table>
		<!---Modification: Group Deals--->
		<input type="Hidden" name="Discount_Growth_Item_Level" value="#Form.Discount_Growth_Item_Level#" />
		<input type="Hidden" name="Discount_Growth_Group_Level" value="#Form.Discount_Growth_Group_Level#" />
		<input type="Hidden" name="Level_1" value="#trim(Form.Level_1)#" />
		<!---clear groups if levels are empty--->
		<cfif not Len(trim(form.Level_1))>
		  <cfset Form.GroupLevel_1 eq "" />
		</cfif>
		<input type="hidden" name="GroupLevel_1" value="#Form.GroupLevel_1#" />
		<input type="hidden" name="Allow_Multi_Levels" value="0" />
		<input type="hidden" name="Dynamic_Static_Groups" value="#form.Dynamic_Static_Groups#" />
		<input type="hidden" name="deletedateexclusions" value="0">
		<input type="hidden" name="EZTemplate" value="#url.EZTemplate#"
	  </form>
	<cfif application.programlayout EQ 1 and url.EZTemplate EQ 0>
	</div>
	</cfif>

<cfif url.EZTemplate EQ 0>
</BLOCKQUOTE></BLOCKQUOTE>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


</BODY>
</HTML>


<!----All javascript--->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CF_MessageWindow>
<script>

var ErrorCount = 0;
function confirmCompletion(NextPage)
{ 	
	var ErrorCount = 0;
	
<!--- Component Name --->
		if(document.AddTargets.Component_Name.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("You must enter a component name", document.all.error_Component_Name);
		}	
		else
		{ 
			clearQueue(document.AddTargets.error_Component_Name);
		}	
		
		<!--- Component Name --->
		<cfif EzButton_Disable EQ 0>
		if(document.AddTargets.Target_Amount.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("You must enter a target amount", document.all.error_Target_Amount);
		}	
		else
		{ 
			clearQueue(document.AddTargets.error_Target_Amount);
		}	
		</cfif>
		 if(document.AddTargets.Target_UOM.value == 3 && !(document.AddTargets.Comparison_Type[0].checked || document.AddTargets.Comparison_Type[1].checked)){
				ErrorCount++;
				queueMessage("If your target is pecent based, you must select comparison period.", document.all.error_Comparison_Type)
			}
			else{
				clearQueue(document.all.error_Comparison_Type)
			}	
			
			if (document.AddTargets.Comparison_Type[1].checked && trim(document.AddTargets.Sample_Period.value).length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter the number of days the comparison sample should be.", document.all.error_Sample_Period)
			}
			else{
				clearQueue(document.all.error_Sample_Period)
			}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->

	if(ErrorCount == 0) 
	{	
	
	<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{document.all.deletedateexclusions.value = 1;</cfif>
		if (NextPage == 1)
		{	document.AddTargets.action = "Contract_Discount_Growth_Add_Target_Action.cfm?CID=#url.CID#&Component_ID=#Component_ID#&Action=Edit&Child_ID=#Child_ID#";
			document.AddTargets.AddTarget.value = 0;
			AddTargets.submit();
			
		}
		else if (NextPage == 2)
		{
			document.AddTargets.action = "Contract_Discount_Growth_Add_Target_Action.cfm?CID=#url.CID#&Component_ID=#Component_ID#";
			AddTargets.submit();		
		}
		else
		{
			document.AddTargets.action = "Contract_Discount_Growth_Add_Target_Action.cfm?CID=#url.CID#&Component_ID=#Component_ID#";
			document.AddTargets.AddTarget.value = 0;
			AddTargets.submit();
		}
	<cfif donotallowaddproductsDE EQ 1>
	}
	</cfif>
	}
	else 
	{ 
		showMessageWindow()
	}	
}

<cfoutput>
function showPercent(thisObj)
{
	var bDisplay = "none";
	var oTargetAmount = document.all.Target_Amount;
	if(thisObj.value == 3)
	{
		bDisplay = "";
		oTargetAmount.allowCharsList = "#allowListUOM3#";
		oTargetAmount.maxDecimalLen = #maxDecimalLenUOM3#;				
	}
	else
	{
		oTargetAmount.allowCharsList = "#allowList#";
		oTargetAmount.maxDecimalLen = #maxDecimalLen#;
		formatTextboxDecimalPlaces(oTargetAmount, oTargetAmount.maxDecimalLen);
	}
	document.all.TR_Percent.style.display = bDisplay;
	document.all.TR_Percent_UOM.style.display = bDisplay;
}
</cfoutput>
function showGroupSearchWindow() 
		{			
			//do validation first
			var prodList = document.AddTargets.Product_List.value;

			var level1List = document.AddTargets.Level_1.value;

			//if we have a product list but nothing in level 1 then we can't allow adding groups
			if(prodList != "" && level1List == "")
			{
				alert("Groups cannot be added when products exist.");
				return;
			}
			
			NewWindow("Groups/index.cfm?formName=AddTargets&programId=#FORM.Contract_Main_ID#&Discountype=4&EZTemplate=#url.EZTemplate#&isparent=0&component_id=#gettargets.Program_Growth_Components_Name_ID#", "productwindow", 800, 600, "yes", "yes");
		}
		
		function addGroupsLevelProducts(groupLevel, groupId)
		{
			if(window.confirm('Do you want to add all the products?')) 
			{
				if(groupLevel != 0)
				{
					var groupIdListObj = eval("document.all.Product_Level_" + groupLevel);
					groupIdListObj.value = groupId;
					document.AddTargets.submit();
				}
			}
		}
		
</script>
</cfoutput>