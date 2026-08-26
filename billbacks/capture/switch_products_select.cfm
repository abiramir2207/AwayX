<!---
Name: 			switch_products_select.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	11/09/2009
Created By:		Tim Ford    
Description:	This file is responsible for selecting the products to switch in Billbacks.  
--->
<cfparam name="url.FromBBProgProdForm" 				default="">
<cfparam name="url.PayeeID" 						default="">
<cfparam name="DiscountList" 						default="">
<cfparam name="url.Business_Segment_ID" 			default="0">
<cfparam name="form.Business_Segment_ID" 			default="#url.Business_Segment_ID#">
<cfparam name="url.businessSegmentsOn" 				default="0">
<cfparam name="form.businessSegmentsOn" 			default="#url.businessSegmentsOn#">
<cfparam name="url.ExistingProductList_Field_Name"	default="ExistingProductList">
<cfparam name="form.submitForm"						default="0">


<!--- We need the following:
	- 	Billback_ID
	-	Billback_Program_ID
	-	Product_ID (BSA_Foodservice_Items_Master_ID)
--->


<cfif isdefined("url.FormName")>
<cfoutput>
	<cfparam name="url.PID" default="">
	<form action="switch_products_select.cfm" method="post" name="MyForm" id="MyForm">
		<input name="ParentFormname" 		type="hidden" 	value="#url.FormName#">
		<input name="ExistingProductList" 	type="hidden" 	value="">
		<input name="FromBBProgProdForm"	type="hidden" 	value="#url.FromBBProgProdForm#">
		<input name="PayeeID"				type="hidden"	value="#url.PayeeID#">
		<input name="DiscountList"			type="hidden"	value="#DiscountList#">
		<input name="Program_ID" 			type="hidden" 	value="#url.PID#">
		<input name="BBID" 					type="hidden" 	value="#url.BBID#">
		<input name="Billback_Program_ID"	type="hidden" 	value="#url.Billback_Program_ID#">
		<input name="Product_ID" 			type="hidden" 	value="#url.Product_ID#">
		<input name="Billback_Product_ID" 	type="hidden" 	value="#url.Billback_Product_ID#">
	</form>
	
	<script>
		if(window.opener.document.all.#url.FormName# != null)
		{
			this.document.all.ExistingProductList.value = opener.document.all.#url.FormName#.#url.ExistingProductList_Field_Name#.value;
			document.all.MyForm.submit();
		}
		else
		{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!");
			window.close();
		}
	</script>
	<cfabort>
</cfoutput>
</cfif>

<cfif form.submitForm eq 1>
	<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->
	<CFPARAM NAME="In_Progress_Check_BBID" default="">
	<CFPARAM NAME="PageName_InProgress" default="">
	<CFPARAM NAME="Progress_Type" default="0">
	
	<CFSET In_Progress_Check_BBID = FORM.BBID>
	<CFSET PageName_InProgress = "Swtich Products">
	<CFSET Progress_Type = 1>	
	<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">
	
	<cfset objBillbackSwitch = createObject("component", "components.Billback.BillbackSwitchProducts") />
	<cfset objBillbackSwitch.saveSwitchProducts(form.BBID, form.Billback_Program_ID, form.Program_ID, form.Product_ID, form.productIdToSwitch, request.AccessStructure.user_id, form.Billback_Product_ID) />
	
	<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->
	<CFPARAM NAME="In_Progress_Check_BBID" default="">
	<CFPARAM NAME="PageName_InProgress" default="">
	<CFPARAM NAME="Progress_Type" default="0">
	
	<CFSET In_Progress_Check_BBID = FORM.BBID>
	<CFSET PageName_InProgress = "Swtich Products">
	<CFSET Progress_Type = 2>	
	<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">
	
	<script>
		window.close();
		window.opener.location.reload();
	</script>
</cfif>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabled()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset form.Business_Segment_Id = businessSegManager.getSegmentIdByProgram(Form.Program_ID) />
</cfif>
<cfoutput>
<cfset Billback_Contract_Main_ID = Form.Program_ID>
<cfquery name="getParentIDs" datasource="#application.datasource#">
	SELECT	*
	FROM	udf_program_revision_detail(#Form.Program_ID#)
	ORDER By Contract_Main_ID
</cfquery>
</cfoutput>
<cfset getParentIDs_List = valuelist(getParentIDs.contract_main_id)>
<!------ keep the original one program id, because next statement may set it with alist pf programs ids ----->
<cfset OriginalProgram_ID = form.Program_ID>

<cfset Calling_Page = "Highlight">

<!--- include the eligible product queries --->
<cfinclude template="inc_eligible_products.cfm">

<cfset PAGE_TITLE= "Switch Product Select">
<cfoutput>
<!--- PRODUCT LIST MAINTAINENCE --->
<cfparam name="form.selectedProductId" default="">
<cfparam name="form.AlreadySelectedItems" default="">
<cfparam name="form.LoadExistingProductList" default="1">
<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.FromBBProgProdForm" 		default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>#PAGE_TITLE#</title>
	<link rel="STYLESHEET" type="text/css" href="/common_files/main_style.css">

	<script>
		function saveSwitchProducts()
		{
			var objSwitchProd = document.all.SearchForm.productIdRadio;
			var radioLen = objSwitchProd.length;
			if(radioLen)
			{
				for (i=0; i<radioLen; i++)
				{
					if(objSwitchProd[i].checked)
					{
						document.all.SearchForm.productIdToSwitch.value = objSwitchProd[i].value;
						document.all.SearchForm.submitForm.value = 1;
						document.all.SearchForm.submit();
						return;
					}
				}
			}
			else if(objSwitchProd.checked)
			{
				document.all.SearchForm.productIdToSwitch.value = objSwitchProd.value;
				document.all.SearchForm.submitForm.value = 1;
				document.all.SearchForm.submit();
				return;
			}
			alert('Please select a product to switch.');
			return;

		}
	</script>
	
</head>

<body background="" bgcolor="White" text="Black" link="Blue" vlink="Blue" alink="Red" leftmargin="5" topmargin="5">

<form action="switch_products_select.cfm" method="post" name="SearchForm" id="SearchForm">

<input type="Hidden" name="FromBBProgProdForm" value="#form.FromBBProgProdForm#">

<cfset billbackObj = CreateObject("component", "components.Billback.BillbackSummaryManager") >
<cfif len(trim(form.payeeID))>
	<cfset qGetDistributor = billbackObj.getdistributorInfo(form.payeeID) />
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset stStruct = Form>
<cfset stStruct.appSettings = appSettings>
<cfset stStruct.ignoreMasterDeleted = 1>

<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset searchProducts = productManager.search(stStruct)>

<!---TODO: Tim Ford - Get query out of view page. --->
<cfquery name="gGetProgramInfo" datasource="#application.datasource#">
	SELECT	Contract_Number,
			Contract_Title,
			Contract_Start_Date,
			Contract_End_Date
	FROM	Contract_Main
	WHERE	Contract_Main_ID = '#form.Program_ID#'
</cfquery>

<cfquery name="qGetProductsToSwitch" dbtype="query">
	SELECT	*
	FROM	searchProducts
	WHERE	BSA_Foodservice_Items_Master_ID != '#form.Product_ID#'
</cfquery>

<!------ reset the progran id to the original one program id, because now it may be a list of program iss ----->
<cfset form.Program_ID = OriginalProgram_ID>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid ##93BEE2 1px; font-size : 10px;}
	##header {font-size: 12px; font-weight: bold;}
</style>
<table class="Maintable" border="0" width="99%" align="center" bgcolor="ffffff" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="100%">
			<B>
				<FONT SIZE="2" COLOR="Navy">
					#gGetProgramInfo.Contract_Number#
					#gGetProgramInfo.Contract_Title# - #dateformat(gGetProgramInfo.Contract_Start_Date, 'mm/dd/yyyy')# to #dateformat(gGetProgramInfo.Contract_End_Date, 'mm/dd/yyyy')#
				</FONT>
			</B>
			<HR COLOR="Navy">
		</td>
	</tr>
</table>
<!------------------------------ Get all list - exclude list -------------------------------------->
<table class="Maintable" width="100%" cellpadding="1" cellspacing="0">
	<cfif isDefined("qGetDistributor")>
	<tr bgcolor="8B0000">
		<td nowrap valign="top" style="font-size:9px; color:white;" colspan="100%">
			<strong>#qGetDistributor.ship_to# :: #qGetDistributor.name#</strong>
		</td>
	</tr>
	</cfif>
	<tr bgcolor="FFCE84">
		<td id="header" width="1">&nbsp;
			
		</td>
		<td id="header" align="left">
			#application.returned_customer_setting.item_label#
		</td>
		<td id="header" align="left">
			Description
		</td>
	</tr>
	<cfloop query="qGetProductsToSwitch">
		<!--- This query in inc_eligible_products.cfm --->
		<cfquery name="IsProductEligible" dbtype="Query">
			SELECT 	DISTINCT Product_ID
			FROM 	AllEligibleProducts
			WHERE 	Product_ID = '#BSA_Foodservice_Items_Master_ID#'
		</cfquery>
		<cfif IsProductEligible.Recordcount GT 0>
			<cfset ProductIsEligible = 1>
		<cfelse>
			<cfset ProductIsEligible = 0>
		</cfif>
		
		<cfset tmpname = replace(BSA_Foodservice_Items_Master_ID,"-","_","all")>	
		<cfset tmpItm = BSA_Foodservice_Items_Master_ID>
		<tr <cfif ProductIsEligible IS 1>bgcolor="#ValidDiscountBGColor#"<cfelse>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</cfif>>
			<td>
				<input type="radio" name="productIdRadio" value="#BSA_Foodservice_Items_Master_ID#">
			</td>
			<td>
				#Item#&nbsp;
			</td>
			<td>
				#Description#&nbsp;
			</td>
		</tr>
	</cfloop>
</table>

<br><br>
<div align="Center">
<cfif qGetProductsToSwitch.recordcount GT 0>
	<cf_smalllink 
		title = "switch product" 
		url = "##"
		parameters = "onClick=""javascript: saveSwitchProducts();"""
	>
</cfif> 
<cf_smalllink 
	title = "cancel" 
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
>
</div>

	<input name="ParentFormname"		type="hidden"	value="#form.ParentFormname#">
	<input name="ExistingProductList"	type="Hidden"	value="#form.ExistingProductList#">
	<input name="PayeeID" 				type="Hidden"	value="#Form.PayeeID#">
	<input name="DiscountList"			type="Hidden"	value="#DiscountList#">
	<input name="Business_Segment_ID"	type="hidden"	value="#form.Business_Segment_ID#">
	<input name="businessSegmentsOn" 	type="hidden"	value="#form.businessSegmentsOn#">
	<input name="Program_ID"			type="hidden"	value="#form.Program_ID#">
	<input name="BBID" 					type="Hidden"	value="#form.BBID#">
	<input name="Billback_Program_ID"	type="hidden" 	value="#form.Billback_Program_ID#">
	<input name="Product_ID" 			type="hidden" 	value="#form.Product_ID#">
	<input name="Billback_Product_ID" 	type="hidden" 	value="#form.Billback_Product_ID#">
	<input name="submitForm" 			type="hidden" 	value="#form.submitForm#">
	<input name="productIdToSwitch" 	type="hidden" 	value="">
		
</form>
</body>
</html>
</cfoutput>





