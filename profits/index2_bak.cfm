<CFSET pagetitle = "step 1 of 4">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of a pricing rule ID (PRID) in the URL --->
<CFPARAM NAME="URL.PRID" DEFAULT="">
<CFPARAM NAME="FORM.aa_comm_number" DEFAULT="0">
<CFPARAM NAME="struct_profit_rule_name.aa_comm_number" DEFAULT="#FORM.aa_comm_number#">
<CFPARAM NAME="aa_rulename" DEFAULT="">
<CFPARAM NAME="FORM.Newly_Selected_Products" DEFAULT="">
<CFPARAM NAME="struct_profit_rule_name.aa_comm_number" DEFAULT="0">


<!--- If the pricing rule ID has been passed get the details for it --->
<CFIF URL.PRID NEQ "">

<!--- Get the rule --->
<cfset useLakebaseForGet_Rule_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pricing_rule")>
<cfif useLakebaseForGet_Rule_Data>
	<cftry>
		<cfset Get_Rule_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pricing_rule", {
				"pricing_rule_id" = "eq.#URL.PRID#",
				"select" = "pricing_rule_id,pricing_rule_name,pricing_rule_date,pricing_rule_author,pricing_rule_final_cost,pricing_rule_data"
			}), "pricing_rule_id,pricing_rule_name,pricing_rule_date,pricing_rule_author,pricing_rule_final_cost,pricing_rule_data"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Rule_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Rule_Data>
<CFQUERY NAME="Get_Rule_Data" datasource="#application.datasource#">
	Select		Pricing_Rule.Pricing_Rule_ID,
				Pricing_Rule.Pricing_Rule_Name,
				Pricing_Rule.Pricing_Rule_Date,
				Pricing_Rule.Pricing_Rule_Author,
				Pricing_Rule.Pricing_Rule_Final_Cost,
				Pricing_Rule.Pricing_Rule_Data
	From		Pricing_Rule
	Where		Pricing_Rule.Pricing_Rule_ID			=	'#URL.PRID#'
</CFQUERY>
</cfif>

<!--- Get the products of the rule --->
<cfset useLakebaseForGet_Rule_Products = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pricing_rule_products")>
<cfif useLakebaseForGet_Rule_Products>
	<cftry>
		<cfset Get_Rule_Products = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pricing_rule_products", {
				"pricing_rule_id" = "eq.#Get_Rule_Data.Pricing_Rule_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Rule_Products = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Rule_Products>
<CFQUERY name="Get_Rule_Products" datasource="#application.datasource#">
	Select		*
	From		Pricing_Rule_Products
	Where		Pricing_Rule_Products.Pricing_Rule_ID = '#Get_Rule_Data.Pricing_Rule_ID#'
</CFQUERY>
</cfif>



<!--- Deserialize the XML packet --->
<CFWDDX ACTION="wddx2cfml" INPUT="#Get_Rule_Data.Pricing_Rule_Data#" OUTPUT="struct_profit_rule_name">
<CFSET aa_rulename=struct_profit_rule_name.aa_rulename>

<CFSET Get_Products = QueryNew("UPC")>

<CFIF listlen(FORM.Newly_Selected_Products) GT 0>
	<CFSET FORM.Newly_Selected_Products=#valuelist(Get_Rule_Products.Pricing_Rule_Products_Item_ID)#>
	<!--- Retrieve the product details used in this rule --->
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
		SELECT		BSA_Foodservice_Items_Master_ID,
					Description,
					UPC
		FROM		dbo.BSA_Foodservice_Items_Master
		WHERE     	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN(#replace(listqualify(FORM.Newly_Selected_Products, "'"), '"', "'")#)
		ORDER BY 	description
	</CFQUERY>
</CFIF>

</CFIF>

<!--- <CF_templatename><CFOUTPUT>#TemplateName#</CFOUTPUT> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values for the HR lines --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET color="Orange">
<CFSET size=1>
<FORM ACTION="index3.cfm" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javascript:return  validateAndSubmitIndex2(this);">
	<span id="error_RuleName"></span>&nbsp;<SPAN CLASS="title2">Rule Name</SPAN>
	<HR SIZE="<CFOUTPUT>#size#</CFOUTPUT>" COLOR="<CFOUTPUT>#color#</CFOUTPUT>">
	Please create the rule name: <FONT COLOR="#FF0000" SIZE="-2"><I><B>(must give the rule a name)</B></I></FONT><BR>
	<INPUT TYPE="text" NAME="aa_rulename" VALUE="<CFOUTPUT>#aa_rulename#</CFOUTPUT>" STYLE="width:400px;">
	
	<BR><BR>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get the list of products																		 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<SCRIPT>
		function showProductSearchWindow() {
			document.all.SaveProgramProducts.rule_name.value = document.MyForm.aa_rulename.value
			NewWindow("product_Selector.cfm?Formname=SaveProgramProducts", "productwindow", 800, 600, "yes", "yes")
		}
</SCRIPT>

 	<CFSET Get_Products = QueryNew("BSA_Foodservice_Items_Master_ID")>
	<CFSET Get_Rule_Products = QueryNew("Pricing_Rule_Products_Item_ID")>
	
	<CFIF listlen(FORM.Newly_Selected_Products) GT 0>
		<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
			SELECT		BSA_Foodservice_Items_Master_ID,
						Description,
						UPC
			FROM		dbo.BSA_Foodservice_Items_Master
			WHERE     	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN(#replace(listqualify(FORM.Newly_Selected_Products, "'"), '"', "'")#)
			ORDER BY 	description
		</CFQUERY>
	</CFIF>
	
	<span id="error_PRODUCT_LIST"></span>&nbsp;<SPAN CLASS="title2">Product Selector</SPAN>
	<HR SIZE="<CFOUTPUT>#size#</CFOUTPUT>" COLOR="<CFOUTPUT>#color#</CFOUTPUT>">


		<B>
		<FONT COLOR="#FF0000">[</FONT>
		<a href="javascript: showProductSearchWindow();">click here to select products</a>
		<FONT COLOR="#FF0000">]</FONT>
		</B>

		<BR>
		<BR>


	These are your selected products... <FONT COLOR="#FF0000" SIZE="-2"><I><B>(you must select at least one)</B></I></FONT><BR>
	<SELECT NAME="View_PRODUCT_LIST" SIZE="11" MULTIPLE STYLE="width:400px;">
		<CFOUTPUT QUERY="Get_Products"><OPTION VALUE="#BSA_Foodservice_Items_Master_ID#">#UPC# - #Description#</OPTION></CFOUTPUT>
	</SELECT>

	<BR><BR>

	
	<SPAN CLASS="title2">Number of Commodities</SPAN>
	<HR SIZE="<CFOUTPUT>#size#</CFOUTPUT>" COLOR="<CFOUTPUT>#color#</CFOUTPUT>">
	
	<CFIF struct_profit_rule_name.aa_comm_number GT 0>
		<B>There are <CFOUTPUT>#struct_profit_rule_name.aa_comm_number#</CFOUTPUT> commodities in this pricing rule</B>
		<INPUT NAME="AA_COMM_NUMBER" TYPE="hidden" VALUE="<CFOUTPUT>#struct_profit_rule_name.aa_comm_number#</CFOUTPUT>">	
		<CFELSE>
		How many commodities make up this pricing rule:<BR>
		<SELECT NAME="aa_comm_number" STYLE="width:400px;">
			<CFLOOP INDEX="i" FROM="1" TO="4">
				<CFOUTPUT><OPTION VALUE="#i#">There are #i# commodities in this pricing rule</OPTION></CFOUTPUT>
			</CFLOOP>
		</SELECT>
	</CFIF>

	<!--- <INPUT NAME="AA_PRODUCT_LIST" TYPE="hidden" VALUE="<CFOUTPUT>#valuelist(Get_Rule_Products.Pricing_Rule_Products_Item_ID)#</CFOUTPUT>"> --->
	<INPUT NAME="AA_PRODUCT_LIST" TYPE="hidden" VALUE="<CFOUTPUT>#valuelist(Get_Products.BSA_Foodservice_Items_Master_ID)#</CFOUTPUT>">


	<INPUT NAME="PRID" TYPE="hidden" VALUE="<CFOUTPUT>#URL.PRID#</CFOUTPUT>">


<BR>
<BR>

<CF_BUTTON
BUTTON_NAME		=	""
BUTTON_CAPTION	=	"goto step 2"
BUTTON_ACTION	=	"javascript:validateAndSubmitIndex2(document.all.MyForm);"
BUTTON_TYPE		=	"link"
BUTTON_WIDTH	=	"100"
BUTTON_COLOR	=	"Navy"
BUTTON_TIP		=	""
FONT_COLOR		=	"White"
FONT_SIZE		=	"12"
FONT_WEIGHT		=	"bold">				

<!-------------------- Added By Deepa ----------------------------------------->

<SCRIPT LANGUAGE="JavaScript" SRC="commodityScripts.js"></SCRIPT>
<CF_MessageWindow>

<!-----
Added onSubmit="javascript: return validateAndSubmitIndex2(this);"
in form tag

Edited 
"javascript:document.all.MyForm.submit();"
to
"javascript:validateAndSubmitIndex2(document.all.MyForm);"

Added <span id="error_RuleName"></span>&nbsp;
Added <span id="error_PRODUCT_LIST"></span>&nbsp;
------->
<!-------------------- End Added By Deepa ----------------------------------------->
	
</FORM>

<FORM ACTION="save_products.cfm" METHOD="post" NAME="SaveProgramProducts" ID="SaveProgramProducts">
	<INPUT TYPE="Hidden" NAME="rule_name" VALUE="">	
	<INPUT TYPE="Hidden" NAME="PRID" VALUE="<CFOUTPUT>#URL.PRID#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="aa_comm_number" VALUE="<CFOUTPUT>#struct_profit_rule_name.aa_comm_number#</CFOUTPUT>">	
	<INPUT TYPE="Hidden" NAME="Product_List" VALUE="<CFOUTPUT>#Form.Newly_Selected_Products#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="<CFOUTPUT>#Form.Newly_Selected_Products#</CFOUTPUT>">
</FORM>

