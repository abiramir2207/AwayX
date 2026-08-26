<cfif isDefined("url.Program_ID")><cfset Form.Program_ID = url.Program_ID></cfif>
<CFSET PAGE_TITLE= "Select Items for Growth Volume">
<cfparam name="Action" default="Create">
<cfparam name="Child_ID" default="">
<cfparam name="ExistingProductList" default="">
<CFPARAM NAME="Form.Discount_Growth_Item_Level" DEFAULT="0">
<CFPARAM NAME="Form.Discount_Growth_Group_Level" DEFAULT="0">
<CFPARAM NAME="form.Level_1" DEFAULT="">
<CFPARAM NAME="form.GroupLevel_1" DEFAULT="">
<CFPARAM NAME="form.Dynamic_Static_Groups" DEFAULT="0">

<cfset Component_ID = url.CompID>


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

<cfset DataManager = CreateObject("component", "components.products.Group.DataManager") />
<!---End initialize all components--->

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
<cfparam name="form.Product_List" default="">

<!---If this is an edit, find items already there--->

<cfif action IS "Edit" and len(trim(form.Product_List)) LT 1>

	<cfquery name="GetPreviousItems" datasource="#application.datasource#">
		SELECT 	Contract_Products.BSA_Foodservice_Items_Master_ID,
				Contract_Products.Is_Group,
				Contract_Products.Product_Group_Level_ID
		FROM 	Contract_Products
				INNER JOIN Program_Growth_Component_Product_Data ON 
				Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
				AND Program_Growth_Component_Product_Data.Deleted = 0
				AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#Component_ID#'
	</cfquery>
	<cfset form.Product_List =  ValueList(GetPreviousItems.BSA_Foodservice_Items_Master_ID, ",")>
	<Cfset ExistingProductList = form.Product_List>
	<!---TSF: Modification Label 6676 --->
	<cfloop query="GetPreviousItems">
		<cfif isDefined("Is_Group") and Is_Group eq 1>
			<cfset form.Level_1 = ListAppend(form.Level_1, BSA_Foodservice_Items_Master_ID) />
			<cfif not ListFindNoCase(Form.GroupLevel_1, Product_Group_Level_ID)>
				<cfset Form.GroupLevel_1 = ListAppend(Form.GroupLevel_1, Product_Group_Level_ID) />
			</cfif>
		</cfif>
	</cfloop>
</cfif>

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
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<!---set if groups are static or dynamic--->
<cfif isDefined("GetSettings.Dynamic_Static_Groups")>
	<cfset form.Dynamic_Static_Groups = GetSettings.Dynamic_Static_Groups />
</cfif>

<!---Modification: Group Deals--->
<cfset form.Discount_Growth_Item_Level = GetSettings.Discount_Growth_Item_Level />
<cfset form.Discount_Growth_Group_Level = GetSettings.Discount_Growth_Group_Level />

<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<BLOCKQUOTE><BLOCKQUOTE>


<cfif application.programlayout EQ 1>
	<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 65px; top: 0px;"> </cfif> 
	  <cfinclude template="minimal_contract_info.cfm">
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
		  <Cfset ProductList = Form.Product_List>
		</cfif>
	  </cfif>
	  <!---Include navigation--->
	  <cfif appSettings.getGrowthExpansion1()>
		<!---Gets component information needed for this growth--->
		<cfset useLakebaseForGetComponentInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
		<cfif useLakebaseForGetComponentInformation>
			<cftry>
				<cfset GetComponentInformation = application.oLakebase.toQuery(
					application.oLakebase.selectRows("program_growth_components", {
						"program_growth_component_id" = "eq.#Component_ID#",
						"select" = "rate_type,program_growth_component_type_id,program_growth_component_id"
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
			SELECT Rate_Type, Program_Growth_Component_Type_ID, Program_Growth_Component_ID
			FROM Program_Growth_Components WHERE Program_Growth_Component_ID = '#Component_ID#'
			</cfquery>
		</cfif>
		<cfset Component_Type 	= GetComponentInformation.Program_Growth_Component_Type_ID>
		<cfset Rate_Type 		= GetComponentInformation.Rate_Type>
		<cfset Component_ID 	= URL.COMPID>
		<cfinclude template="/common_files/contracts/contract_discount_growth_navigation.cfm">
	  </cfif>
	  <form name="AddItems" action="Contract_Discount_Growth_Add_Volume_Items.cfm?CID=#url.CID#&Component_ID=#Component_ID#&Action=#Action#&CompID=#Component_ID#" method="post">
		<INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
		<input name="Component_ID" type="hidden" value="#Component_ID#">
		<table WIDTH="800" BORDER="0" CELLSPACING="0" CELLPADDING="2" style="maintable">
		  <tr> 
			<td colspan="100%" align="Center"><font color="navy" size="+1"> 
			  <p></p>
			  Items for Volume</font></td>
		  </tr>
		  <cfparam name="ProductList" default="">
		  <!---No previous targets--->
		  <cfparam name="Form.groupLevelProducts" 	default="0">
		  <cfparam name="Form.Product_Level_1" 	default="">
		  <INPUT TYPE="Hidden" NAME="Product_Level_1" VALUE="#Form.Product_Level_1#">
		  <input type="Hidden" name="groupLevelProducts" value="#Form.groupLevelProducts#" />
		  <input type="hidden" name="Level_1" value="#form.Level_1#">
		  <input type="hidden" name="GroupLevel_1" value="#form.GroupLevel_1#">
		  <input type="hidden" NAME="AddTarget" 			value="1">
		  <INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#ExistingProductList#">
		  <INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Product_List#">
		  <INPUT TYPE="Hidden" NAME="Dynamic_Static_Groups" 		VALUE="#form.Dynamic_Static_Groups#">
		  <INPUT TYPE="Hidden" NAME="navigate" VALUE="#FORM.navigate#">
<INPUT TYPE="Hidden" NAME="stopnavigate" VALUE="0">
		  <cfparam name="FORM.Component_Name" default= "">
		  <cfparam name="FORM.Target_Amount" default="">
		  <cfparam name="FORM.Target_UOM" default="">
		  <tr> 
			<td><p>&nbsp; </p></td>
		  </tr>
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
							button_action	=	"javascript: NewWindow('/common_files/contracts/product_Select_V1.cfm?SelectSingleSearchResultOnly=0&FieldName=Product_List&FormName=AddItems&ExistingProductList=#ExistingProductList#&Discountype=4','name','800','600','Yes', 'Yes');return false;"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						> </td>
			</cfif>
			<cfif bAllowSelectAllProducts>
			  <td> <CF_button
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
				> </td>
			</cfif>
			<cfif len(trim(Form.Product_List)) GT 0>
			  <td> <CF_button
					button_name		=	""
					button_caption	=	"save and continue"
					button_action	=	"javascript: SaveAndContinue();"
					button_type		=	"javascript_link"
					button_width	=	"150"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				> </td>
			</cfif>
		  </tr>
		</table>
	  </form><cfif application.programlayout EQ 1>
	  </div>
	</cfif>

</BLOCKQUOTE></BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


</BODY>
</HTML>


<!----All javascript--->

<script>
function SaveAndContinue()
{ 	
	document.AddItems.action = "Contract_Discount_Growth_Add_Volume_Items_Action.cfm?CID=#url.CID#&Component_ID=#Component_ID#&Contract_Main_ID=#Contract_Main_ID#";
	document.all.navigate.value = 0;
	AddItems.submit();
}

function showGroupSearchWindow() 
	{	
	
		//do validation first
		var prodList = document.AddItems.Product_List.value;
		var level1List = document.AddItems.Level_1.value;
				
		//if we have a product list but nothing in level 1 then we can't allow adding groups
		if(prodList != "" && level1List == "")
		{
			alert("Groups cannot be added when products exist.");
			return;
		}
		
		NewWindow("Groups/index.cfm?formName=AddItems&programId=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>&Discountype=4", "productwindow", 800, 600, "yes", "yes");
	}
		
function verifyNavigate() {
			if (document.all.navigate.value == 1 && document.all.stopnavigate.value == 0) {
				{
					event.returnValue="Your changes will not be saved if you click OK";
			}
		}	
		}
</script>
</cfoutput>