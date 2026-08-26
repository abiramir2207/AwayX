<cf_cryp type="de" string="#URL.CID#" key="#request.key#">

<CFSET FORM.Program_ID = cryp.value>

<cfquery name="getSavedCategories" datasource="#application.datasource#">
SELECT	
		dbo.Type_Group_Desc.Type_Group_Desc,
		dbo.Q_Brand_Desc.Q_Brand_Desc,
		dbo.Brand.Brand,
		dbo.Type_Code_Desc.Type_Code_Desc,
		dbo.Program_Product_Categories.Program_ID,
		dbo.Program_Product_Categories.TypeGroup_desc_ID,
		dbo.Program_Product_Categories.Qbrand_desc_ID,
		dbo.Program_Product_Categories.TypeCode_desc_ID,
		dbo.Program_Product_Categories.Brand_ID,
		dbo.Program_Product_Categories.Program_Product_Category_ID
FROM    
		dbo.Program_Product_Categories INNER JOIN dbo.Type_Group_Desc ON
		dbo.Program_Product_Categories.TypeGroup_desc_ID = dbo.Type_Group_Desc.Type_Group_Desc_ID INNER JOIN dbo.Q_Brand_Desc ON
		dbo.Program_Product_Categories.Qbrand_desc_ID = dbo.Q_Brand_Desc.Q_Brand_Desc_ID INNER JOIN dbo.Brand ON dbo.Program_Product_Categories.Brand_ID = 		dbo.Brand.Brand_ID INNER JOIN dbo.Type_Code_Desc ON
		dbo.Program_Product_Categories.TypeCode_desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
WHERE 
		isContract = 1 
		AND 
		Program_ID = #FORM.Program_ID# 
		AND
		Deleted = 0
ORDER BY dbo.Type_Group_Desc.Type_Group_Desc, dbo.Q_Brand_Desc.Q_Brand_Desc, dbo.Type_Code_Desc.Type_Code_Desc, dbo.Brand.Brand		
</cfquery>

<cfset useLakebaseForGETUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForGETUOM>
	<cftry>
		<cfset GETUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGETUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGETUOM>
	<CFQUERY NAME="GETUOM" datasource="#application.datasource#">
		SELECT *
		FROM Units_of_Measure
	</CFQUERY>
</cfif>

<cfquery name="getProgramInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID = '#FORM.Program_ID#'
</cfquery>

<!--- count all the products in the categories --->
<CFSET TotalProductCount = 0>
<CFLOOP query="getSavedCategories">
	<cfquery name="getAllCategoryProducts" datasource="#application.datasource#">
		SELECT count(UPC) AS TheCount
		FROM BSA_Foodservice_Items_Master
		WHERE Type_Group_Desc_ID = '#TypeGroup_desc_ID#' AND Q_Brand_Desc_ID = '#Qbrand_desc_ID#' AND Type_Code_Desc_ID = '#TypeCode_desc_ID#' AND Brand_ID = '#Brand_ID#'
	</cfquery>
	<CFSET TotalProductCount = TotalProductCount + getAllCategoryProducts.TheCount>
</CFLOOP>

<CFIF TotalProductCount EQ 0><CFSET TotalProductCount = 1></CFIF>
<CFSET ContractVolume = trim(getProgramInfo.Contract_Quantity)>
<CFSET VolumePerProduct = ContractVolume/TotalProductCount>

<cfquery name="getProgramUOM" dbtype="query">
	SELECT *
	FROM GETUOM
	WHERE Unit_Of_Measure_ID = '#getProgramInfo.Contract_Quantity_UOM_IDX#'
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Category Rates</title>
		<!-- *************** DHTML Outline (begin) ***************** -->

		<STYLE TYPE='text/css'>
		<!--
		/*Define elements with children with the class='outlineParentItem', and all elements without children with class='outlineItem'*/
		li.oItem { color: #000000; cursor: text; } ;
		li.oParent { color: #0000FF; cursor: pointer; } ;
		ul ul { display: none; } ;
		// -->
		</STYLE>

		<SCRIPT language="JavaScript" src="/Common_Files/scripts/numberValidation.js"></SCRIPT>
		<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>	
		<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
		<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>
		
		<SCRIPT LANGUAGE='Javascript'>
		<!--
			// Returns the closest parent tag with tagName containing
			// the src tag. If no such tag is found - null is returned.
			function checkParent( src, tagName ) {
				while ( src != null ) {
					if (src.tagName == tagName) 
						return src;
					src = src.parentElement;
				}
				return null;
			}
		
			
			// Returns the first tag with tagName contained by
			// the src tag. If no such tag is found - null is returned.
			function checkContent( src, tagName ) {
				var pos = src.sourceIndex ;
				while ( src.contains( document.all[++pos] ) )
					if ( document.all[pos].tagName == tagName )
						return document.all[pos] ;
				return null ;
			}
		
		      
			// Handle onClick event in the outline box
			function outlineAction() {     
				var src = event.srcElement ;
				var item = checkParent( src, "LI" ) ;
		
				if ( parent != null ) {
					var content = checkContent( item, "UL" ) ;
		
					if ( content != null )
						if ( content.style.display == "" )
							content.style.display = "block" ;
						else
							content.style.display = "" ;
				}
				event.cancelBubble = true;
			}
		    
		// -->
		
		function CalcAllVolumes() {
			var aSpans = document.body.getElementsByTagName("SPAN");

			for(var s=0; s<aSpans.length; s++){
				if(aSpans[s].isCatTotal != null){
					aSpans[s].innerText = 0
				}
			}
			
			for(var x=0; x<document.all.MyForm.elements.length; x++) {
				 currentElement = document.all.MyForm.elements[x]
				if(window.currentElement.isProduct != null) {
					if(currentElement.value.length != 0){

						VolumeTotalArea = eval(currentElement.VolumeTotalID)
						VolumeTotalArea.innerText = parseFloat(VolumeTotalArea.innerText) + parseFloat(currentElement.value)
					}
				}
			}
		}
		

		function initPage(){
			findselectboxes();
			CalcAllVolumes();
		}
		
		
		function CA(SpanIDWithElements) {
			//getAttributesWindow('',SpanIDWithElements.all)
			//alert(SpanIDWithElements.all.length)
			for(var z=0; z<SpanIDWithElements.all.length;z++){
				thisElement = SpanIDWithElements.all[z]
				
				if(thisElement.nodeName == "INPUT" && thisElement.type == "checkbox"){
					thisElement.checked = event.srcElement.checked
				}

			}
		}


		function ApplyAmountToSelectedBoxes() {
			if(document.all.Discount_Amount.value.length > 0){
				for(var x = 0; x<document.all.MyForm.elements.length; x++) {
					if(document.all.MyForm.elements[x].type == "checkbox")	{
						if(document.all.MyForm.elements[x].name.indexOf("_allbox") == -1) {
							if(document.all.MyForm.elements[x].checked) {
								eval("document.all." + document.all.MyForm.elements[x].name.substring(0, document.all.MyForm.elements[x].name.length-6) + '.value =' + document.all.Discount_Amount.value)
							}
						}
					}
				}
			}
		}
		
<cfoutput>		
		function verifyForm() {
			var ErrorCount = 0;
			var VolumeTotal = 0;
			for(var x=0; x<document.all.MyForm.elements.length; x++){
				var theElement = document.all.MyForm.elements[x]
				//Volume Error Checking
				if(theElement.isVolumeEntry != null){
					if(theElement.value.length == 0) {
						ErrorCount++;
						queueMessage("Enter A Volume", eval(theElement.ErrorIndicatorSpan))
					}
					else {
						clearQueue(eval(theElement.ErrorIndicatorSpan))
						temp = Math.round(theElement.value*1000)/1000
						VolumeTotal = VolumeTotal + temp
					}
				}
				
				//Rate Error Checking
				if(theElement.isRateEntry != null){
					if(theElement.value.length == 0) {
						ErrorCount++;
						queueMessage("Enter A Rate", eval(theElement.ErrorIndicatorSpan))
					}
					else {
						clearQueue(eval(theElement.ErrorIndicatorSpan))
					}
				}				
			}
			
			if(ErrorCount == 0){
				if(VolumeTotal != #getProgramInfo.Contract_Quantity#) {
					if(confirm("The Program Volume Calculated From This Page Is " + VolumeTotal + " #getProgramUOM.Unit_Of_Measure_Desc# While The Volume Entered From The Basic Information Page Is #getProgramInfo.Contract_Quantity# #getProgramUOM.Unit_Of_Measure_Desc#. Press OK to Changed The Previously Entered Volume To The Calculated Volume Or Cancel To Adjust The Local Volumes.")){
						document.all.newProgramGlobalVolume.value = VolumeTotal
						document.MyForm.submit()
					}
					else{
						document.all.newProgramGlobalVolume.value = ""
					}
				}
				
				if(VolumeTotal == #getProgramInfo.Contract_Quantity#) document.MyForm.submit()
				
			}
			else {
				showMessageWindow()
			}
			
		}
</cfoutput>
</SCRIPT>		



</head>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="initPage();">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFSET temp = cryp.value>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "ra"> 


<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>
<CFSET FORM.CONTRACT_MAIN_ID = temp>
<CFSET helpfilenumber=5>
<cfinclude template="minimal_contract_info.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Table options																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET tableborder=0>
<CFSET bgcolor="Silver">
<CFSET tablewidth="350">
<CFSET cellpadding=3>
<CFSET cellspacing=0>
<cfset layerwidth = "550">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Open layer Options																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSCRIPT>
	Layerborder="Yes";
	BorderSize=1;  
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=9;
	IsClosed="Yes";  
	Width=550;
</CFSCRIPT>

	<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
		<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">To apply the same rate to more than one product:</LEGEND>
		<FONT SIZE="2">
		<OL>
			<LI>Enter here the rate that you would like to apply: <INPUT TYPE="Text" NAME="Discount_Amount" SIZE="3" ONKEYUP="nextBox(this, 'NONE')"></LI>
			<LI>In the table below, select the products that you would like this amount to be applied to</LI>
			<LI>Click <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;">apply</A><FONT COLOR="Red"><B> ]</B></FONT> to make the rates of the selected products match what you entered above.</LI>
			<LI>Can repeat this process as many times as you need by simply selecting or un-selecting the products in question.</LI>
		</OL>
		</FONT>
	</FIELDSET>

	<FORM ACTION="contract_product_cats_rebate_entry_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>" METHOD="post" NAME="MyForm">
	<FIELDSET STYLE="padding:8px; width: 100%; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Selected Product Categories</LEGEND>
		<br>
		<CFLOOP query="getSavedCategories">
		<CF_openLayer
			border="#layerborder#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="#UCASE(getSavedCategories.Type_Group_Desc)#  >  #UCASE(getSavedCategories.Q_Brand_Desc)#  >  #UCASE(getSavedCategories.Type_Code_Desc)#  >  #UCASE(getSavedCategories.Brand)#"  
			TitleClosed="#UCASE(getSavedCategories.Type_Group_Desc)#  >  #UCASE(getSavedCategories.Q_Brand_Desc)#  >  #UCASE(getSavedCategories.Type_Code_Desc)#  >  #UCASE(getSavedCategories.Brand)#"  
			TitleTooltip="Click here to toggle the view..."  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="0"
			width="100%">
	
		<cfquery name="getAllCategoryProducts" datasource="#application.datasource#">
			SELECT *
			FROM BSA_Foodservice_Items_Master
			WHERE Type_Group_Desc_ID = '#TypeGroup_desc_ID#' AND Q_Brand_Desc_ID = '#Qbrand_desc_ID#' AND Type_Code_Desc_ID = '#TypeCode_desc_ID#' AND Brand_ID = '#Brand_ID#'
		</cfquery>
				<br>
				<TABLE>
					<TR>
						<CFSET VolumeName = "CATEGORY_#getAllCategoryProducts.Type_Group_Desc_ID#_#getAllCategoryProducts.Q_Brand_Desc_ID#_#getAllCategoryProducts.Type_Code_Desc_ID#_#getAllCategoryProducts.Brand_ID#">
						<TD align="left" colspan="100%"><span style="font-size: 13px; font-weight: bold;">Category Volume Total</span>&nbsp;<cfoutput><SPAN id="#VolumeName#_VOLUME" isCatTotal="1" style="font-size: 13px; font-weight: bold;">0</SPAN><span style="font-size: 13px; font-weight: bold;">&nbsp;#getProgramUOM.Unit_Of_Measure_Desc#</span></cfoutput></TD>
					</TR>
				</TABLE>

				<TABLE border="0" cellspacing="0" cellpadding="3" CLASS="Maintable" WIDTH="100%">
					<TR ID="header" BGCOLOR="#ffce84">
						<cfoutput><TD width="1" align="right"><input name="#VolumeName#_allbox" type="Checkbox" onclick="CA(document.all.lgroup_#VolumeName#)"></TD></cfoutput>
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left">UPC Code</TD></cfif></cfif>
						<TD align="left">Item #</TD>
						<TD align="left">Description</TD>
						<TD align="left">Type Code Description</TD>
						<TD align="left">Brand</TD>
						<TD align="left">Volume</TD>
						<TD align="left">Rate</TD>
					</TR>
						
		<CFIF getAllCategoryProducts.Recordcount GT 0>
			<SPAN id="lgroup_<cfoutput>#VolumeName#</cfoutput>">
			<cfloop query="getAllCategoryProducts">
					<CFOUTPUT>
						<CFSET ProductName = "CATEGORY_#getAllCategoryProducts.Type_Group_Desc_ID#_#getAllCategoryProducts.Q_Brand_Desc_ID#_#getAllCategoryProducts.Type_Code_Desc_ID#_#getAllCategoryProducts.Brand_ID#_PRODUCT_#getAllCategoryProducts.BSA_Foodservice_Items_Master_ID#_#Replace(getAllCategoryProducts.UPC, "-", "_", "ALL")#">
						<cf_cryp type="en" string="#trim(getAllCategoryProducts.UPC)#" key="#request.key#">
						<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> ONMOUSEOVER="menuID=6;URLstring='';an_ID='#cryp.value#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
							<TD width="1" align="right"><input name="#ProductName#_RATEASSIGN" type="Checkbox" onclick="if(this.checked==false){document.all.#VolumeName#_allbox.checked = false}"></TD>
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#getAllCategoryProducts.UPC#</TD></cfif></cfif>
							<TD NOWRAP>#getAllCategoryProducts.ITEM#</TD>
							<TD nowrap>#getAllCategoryProducts.Description#</TD>
							<TD nowrap>#getAllCategoryProducts.Type_Code_Desc#</TD>
							<TD NOWRAP>#getAllCategoryProducts.Brand#</TD>

							<cfquery name="getThisProductInfo" datasource="#application.datasource#">
								SELECT *
								FROM Program_Product_Category_Product_Rates_Volumes
								WHERE
									Program_ID 								= 	'#FORM.Program_ID#'
									AND
									BSA_Foodservice_Items_Master_ID		= 	'#getAllCategoryProducts.BSA_Foodservice_Items_Master_ID#'
									AND 
									Deleted 								= 	0								
							</cfquery>
							
							<CFIF getThisProductInfo.recordcount EQ 0>
								<CFSET thisProdRate 		= 0>
								<CFSET thisProdRateUOM 		= getProgramUOM.Unit_Of_Measure_ID>								
								<CFSET thisProdVolume 		= 0>
							<cfelse>
								<CFSET thisProdRate 		= getThisProductInfo.Rate>
								<CFSET thisProdRateUOM 		= getThisProductInfo.Rate_UOM>		
								<CFSET thisProdVolume 		= getThisProductInfo.Volume>						
							</CFIF>

							<TD nowrap><span id="volumeError_#ProductName#"></span>&nbsp;<input name="#ProductName#_VOLUME" type="Text" size="9" onKeyUp="nextBox(this, 'NONE');CalcAllVolumes();" value="#VolumePerProduct#" isProduct="1" isVolumeEntry="1" VolumeTotalID="#VolumeName#_VOLUME" value="#thisProdVolume#"  ErrorIndicatorSpan="document.all.volumeError_#ProductName#">&nbsp;#getProgramUOM.Unit_Of_Measure_Desc#</TD>
							<TD align="right" nowrap><span id="rateError_#ProductName#"></span>&nbsp;<input name="#ProductName#_RATE" type="Text" size="9"onKeyUp="nextBox(this, 'NONE');" value="#thisProdRate#" isRateEntry="1" ErrorIndicatorSpan="document.all.rateError_#ProductName#">
								<SELECT NAME="#ProductName#_RATE_UOM">
									<CFLOOP QUERY="GETUOM">
										<OPTION VALUE="#GETUOM.Unit_Of_Measure_ID#" <CFIF GETUOM.Unit_Of_Measure_ID EQ thisProdRateUOM>SELECTED</CFIF>>#left(GETUOM.Unit_of_Measure_Desc, (len(GETUOM.Unit_of_Measure_Desc)-1))#</OPTION>
									</CFLOOP>					
								</SELECT>							
							</TD>
						</TR>
							
					</CFOUTPUT>
								
			</CFLOOP>
			</SPAN>	
			</TABLE>
			<br>
		</CFIF>
		</CF_openLayer>				
	<br><br>
		</CFLOOP>

<!-- *************** DHTML Outline (end) ***************** -->
	
	</FIELDSET>
	

<center>
<br>
<cfoutput>
	<INPUT type="Hidden" name="Program_ID" 				value="#URL.CID#">
	<INPUT type="Hidden" name="Program_Volume_UOM" 		value="#getProgramInfo.Contract_Quantity_UOM_IDX#">
	<INPUT type="Hidden" name="newProgramGlobalVolume" 	value="">
	
</cfoutput>
</FORM>
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"Javascript: verifyForm()"
		button_type		=	"link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</center>	
	
</BLOCKQUOTE></BLOCKQUOTE>
<CF_MessageWindow>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</body>
</html>
