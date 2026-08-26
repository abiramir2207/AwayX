<cf_cryp type="de" string="#URL.CID#" key="#request.key#">

<CFSET FORM.Program_ID = cryp.value>

<CFQUERY NAME="GetTypeGroups" datasource="#application.datasource#" >
	SELECT DISTINCT BSA_Foodservice_Items_Master.Type_Group_Desc_ID,Type_Group_Desc.Type_Group_Desc
	FROM BSA_Foodservice_Items_Master, Type_Group_Desc
	WHERE Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
	ORDER BY BSA_Foodservice_Items_Master.Type_Group_Desc_ID
</CFQUERY>


<CFQUERY NAME="GetQBrands" datasource="#application.datasource#" >
	SELECT DISTINCT BSA_Foodservice_Items_Master.Type_Group_Desc_ID, BSA_Foodservice_Items_Master.Q_Brand_Desc_ID, Q_Brand_Desc.Q_Brand_Desc
	FROM BSA_Foodservice_Items_Master, Q_Brand_Desc
	WHERE Q_Brand_Desc.Q_Brand_Desc_id = BSA_Foodservice_Items_Master.Q_Brand_Desc_ID
	ORDER BY BSA_Foodservice_Items_Master.Type_Group_Desc_ID, BSA_Foodservice_Items_Master.Q_Brand_Desc_ID
</CFQUERY>

<CFQUERY NAME="GetTypeCodes" datasource="#application.datasource#" >
	SELECT DISTINCT BSA_Foodservice_Items_Master.Type_Group_Desc_ID, BSA_Foodservice_Items_Master.Q_Brand_Desc_ID,BSA_Foodservice_Items_Master.Type_Code_Desc_ID, Type_Code_Desc.Type_Code_Desc
	FROM BSA_Foodservice_Items_Master, Type_Code_Desc
	WHERE Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
	ORDER BY BSA_Foodservice_Items_Master.Type_Group_Desc_ID, BSA_Foodservice_Items_Master.Q_Brand_Desc_ID,BSA_Foodservice_Items_Master.Type_Code_Desc_ID
</CFQUERY>


<CFQUERY NAME="GetBrands" datasource="#application.datasource#" >
	SELECT DISTINCT BSA_Foodservice_Items_Master.Type_Group_Desc_ID, BSA_Foodservice_Items_Master.Q_Brand_Desc_ID, BSA_Foodservice_Items_Master.Type_Code_Desc_ID, BSA_Foodservice_Items_Master.Brand_ID, Brand.Brand
	FROM BSA_Foodservice_Items_Master, Brand
	WHERE Brand.Brand_ID = BSA_Foodservice_Items_Master.Brand_ID
	ORDER BY BSA_Foodservice_Items_Master.Type_Group_Desc_ID, BSA_Foodservice_Items_Master.Q_Brand_Desc_ID,BSA_Foodservice_Items_Master.Type_Code_Desc_ID,BSA_Foodservice_Items_Master.Brand_ID
</CFQUERY>



<cfwddx action="CFML2JS" input="#GetTypeGroups#" output="MyDynamicJSCode4GetTypeGroups" toplevelvariable="GetTypeGroups">
<cfwddx action="CFML2JS" input="#GetQBrands#" output="MyDynamicJSCode4GetQBrands" toplevelvariable="GetQBrands">
<cfwddx action="CFML2JS" input="#GetTypeCodes#" output="MyDynamicJSCode4GetTypeCodes" toplevelvariable="GetTypeCodes">
<cfwddx action="CFML2JS" input="#GetBrands#" output="MyDynamicJSCode4GetBrands" toplevelvariable="GetBrands">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Select Product Categories</title>
	<script src="/qforms/lib/qforms.js"></script>
	<script src="/wddx.js"></script>
	
	<cfoutput>
	<SCRIPT LANGUAGE="JavaScript">
	
	// wddx variable holding getColumns query data
	#MyDynamicJSCode4GetTypeGroups#
	#MyDynamicJSCode4GetQBrands#
	#MyDynamicJSCode4GetTypeCodes#
	#MyDynamicJSCode4GetBrands#
	
		
	<!--//
	// set the path to the qForms directory
	qFormAPI.setLibraryPath("/qforms/lib/");
	// this loads all the default libraries
	qFormAPI.include("*");

	// this is the default struct to use for the blank options to prefix
	// when populating a select box
	stcBlank = new Object();
	stcBlank[" "] = "Select One...";
	
	
	// create a structure to store all the product information in
	productCats = new Object();
	
	/* Get row count */
	nGetTypeGroupsRows = GetTypeGroups.getRowCount();		// Level 1
	nGetQBrandsRows = GetQBrands.getRowCount();				// Level 2
	nGetTypeCodesRows = GetTypeCodes.getRowCount();			// Level 3
	nGetBrandsRows = GetBrands.getRowCount();				// Level 4

// Loop through query data and build table/column arrays

var TypGroupLevel_TypeGroup_ID 	= 0;
var QBrandLevel_TypeGroup_ID	= 0;
var QBrandLevel_QBrand_ID		= 0;
var QBrandLevel_QBrand_Desc		= 0;
var TypeCodeLevel_TypeGroup_ID	= 0;
var TypeCodeLevel_QBrand_ID		= 0;
var TypeCodeLevel_TypeCode_ID	= 0;
var TypeCodeLevel_TypeCode_Desc	= 0;
var BrandLevel_TypeGroup_ID		= 0;
var BrandLevel_QBrand_ID		= 0;
var BrandLevel_TypeCode_ID		= 0;
var BrandLevel_Brand_ID			= 0;
var BrandLevel_Brand_Desc		= 0;


//Type Group
for(var GetTypeGroupsRow = 0; GetTypeGroupsRow < nGetTypeGroupsRows; ++GetTypeGroupsRow) {

	TypeGroupLevel_TypeGroup_ID = GetTypeGroups.getField(GetTypeGroupsRow, 'Type_Group_Desc_ID');

	productCats[TypeGroupLevel_TypeGroup_ID] = new Object();

	//QBRAND
	for (var GetQBrandsRow = 0; GetQBrandsRow < nGetQBrandsRows; ++GetQBrandsRow) {

		QBrandLevel_TypeGroup_ID	=	GetQBrands.getField(GetQBrandsRow, 'Type_Group_Desc_ID');
		QBrandLevel_QBrand_ID		=	GetQBrands.getField(GetQBrandsRow, 'Q_Brand_Desc_ID');
		QBrandLevel_QBrand_Desc		=	GetQBrands.getField(GetQBrandsRow, 'Q_Brand_Desc');
		
		if (QBrandLevel_TypeGroup_ID == TypeGroupLevel_TypeGroup_ID) {
			productCats[TypeGroupLevel_TypeGroup_ID][QBrandLevel_QBrand_ID] = QBrandLevel_QBrand_Desc;
			productCats[TypeGroupLevel_TypeGroup_ID + ',' + QBrandLevel_QBrand_ID] = new Object();
	
			//Type Code
			for (var GetTypeCodesRow = 0; GetTypeCodesRow < nGetTypeCodesRows; ++GetTypeCodesRow) {
				
				TypeCodeLevel_TypeGroup_ID		=	GetTypeCodes.getField(GetTypeCodesRow, 'Type_Group_Desc_ID');
				TypeCodeLevel_QBrand_ID			=	GetTypeCodes.getField(GetTypeCodesRow, 'Q_Brand_Desc_ID');
				TypeCodeLevel_TypeCode_ID		=	GetTypeCodes.getField(GetTypeCodesRow, 'Type_Code_Desc_ID');			
				TypeCodeLevel_TypeCode_Desc		=	GetTypeCodes.getField(GetTypeCodesRow, 'Type_Code_Desc');		
				
				if (TypeCodeLevel_TypeGroup_ID == TypeGroupLevel_TypeGroup_ID && TypeCodeLevel_QBrand_ID == QBrandLevel_QBrand_ID) {
					productCats[TypeGroupLevel_TypeGroup_ID + ',' + QBrandLevel_QBrand_ID][TypeCodeLevel_TypeCode_ID] = TypeCodeLevel_TypeCode_Desc
					productCats[TypeGroupLevel_TypeGroup_ID + ',' + QBrandLevel_QBrand_ID + ',' + TypeCodeLevel_TypeCode_ID] = new Object();
					
					// Brand 
					for (var GetBrandsRow = 0; GetBrandsRow < nGetBrandsRows; ++GetBrandsRow) {
						
						BrandLevel_TypeGroup_ID		=	GetBrands.getField(GetBrandsRow, 'Type_Group_Desc_ID');
						BrandLevel_QBrand_ID		=	GetBrands.getField(GetBrandsRow, 'Q_Brand_Desc_ID');
						BrandLevel_TypeCode_ID		=	GetBrands.getField(GetBrandsRow, 'Type_Code_Desc_ID');			
						BrandLevel_Brand_ID			=	GetBrands.getField(GetBrandsRow, 'Brand_ID');			
						BrandLevel_Brand_Desc		=	GetBrands.getField(GetBrandsRow, 'Brand');		
						
						if (BrandLevel_TypeGroup_ID == TypeGroupLevel_TypeGroup_ID && BrandLevel_QBrand_ID == QBrandLevel_QBrand_ID && BrandLevel_TypeCode_ID == TypeCodeLevel_TypeCode_ID) {
							productCats[TypeGroupLevel_TypeGroup_ID + ',' + QBrandLevel_QBrand_ID + ',' + TypeCodeLevel_TypeCode_ID][BrandLevel_Brand_ID] = BrandLevel_Brand_Desc						

						}// Brand IF 
					}// Brand FOR 
				}// Type Code IF 
			}// Type Code FOR 
		}// QBRAND IF 
	}// QBRAND FOR 
}// Type Group FOR 

	
	function init(){
		// initialize the qForm object
		objForm = new qForm("MyForm");
		// make these fields required
		//objForm.required("typegroup_desc,Qbrand_desc,typecode_desc,brand");
	}
	
	// this example shows how you could pre-populate the form
	function setDefault(){
		objForm.Table.setValue("typegroup_desc");
	}
	//-->


		var GlobalProgram_ID = #FORM.Program_ID#
		function buildURLIDString(){
			string = ""
			string = document.all.typegroup_desc[document.all.typegroup_desc.selectedIndex].value + "_"
			string = string + document.all.Qbrand_desc[document.all.Qbrand_desc.selectedIndex].value + "_"
			string = string + document.all.typecode_desc[document.all.typecode_desc.selectedIndex].value + "_"
			string = string + document.all.brand[document.all.brand.selectedIndex].value
			return string		
		}
		
		function verifyData(){
			if(document.all.typegroup_desc.selectedIndex == 0) { 
				alert("You Must Select A Type Group Desciption") 
				return false
			}
			
			if(document.all.Qbrand_desc.selectedIndex == 0)	{ 
				alert("You Must Select A QBrand Desciption") 
				return false;
			}
			
			if(document.all.typecode_desc.selectedIndex == 0) {
				alert("You Must Select A Type Code Desciption") 
				return false;
			}
			
			if(document.all.brand.selectedIndex == 0) {
				alert("You Must Select A Brand Desciption") 
				return false;
			}
			
			return true;
		}
		
		function sendDataToServer(){
			if(verifyData()){
				if(window.document.category_list_window.document.all.SaveCategory != null){
					stringToSend = buildURLIDString()
					
					for(var x=1; x<window.document.category_list_window.AlreadySelectedCategoryCombinations.length; x++){
						existingString = window.document.category_list_window.AlreadySelectedCategoryCombinations[x]
						
						if(stringToSend == existingString) {
							alert("that combination already existis")
							return false;
						}
					}
					
					window.document.category_list_window.document.all.SaveCategory.Category_String.value = stringToSend
					window.document.category_list_window.document.all.SaveCategory.Program_ID.value = GlobalProgram_ID
					
					window.document.category_list_window.document.all.SaveCategory.submit()
					return true;
				}
				else{
					alert("Press Add Again After Letting The Window Load")
				}
				
			}
		}
	</script>
</cfoutput>

</head>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="init();">

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
<CFSET CSL_CallingPageCode = "pr"> 


<CFINCLUDE TEMPLATE="contract_status_legend.cfm">




<BLOCKQUOTE><BLOCKQUOTE>
<CFSET FORM.CONTRACT_MAIN_ID = temp>
<CFSET helpfilenumber=5>
<cfinclude template="minimal_contract_info.cfm">
	<FORM ACTION="select_products.cfm" METHOD="post" NAME="MyForm">
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">product search</LEGEND>
		<TABLE WIDTH="100%">
			<TR>
				<TD NOWRAP>
					<B>Type Group</B><BR>
					<!--- <CFPARAM NAME="FORM.typegroup_desc" DEFAULT="0"> --->
					<SELECT NAME="typegroup_desc" onChange="objForm.Qbrand_desc.populate(productCats[objForm.typegroup_desc.getValue()], null, null, stcBlank);" style="width: 150px;">
						<OPTION value="">Select One...</OPTION>
						<CFOUTPUT query="GetTypeGroups">
							<OPTION value="#GetTypeGroups.Type_Group_Desc_ID#">#GetTypeGroups.Type_Group_Desc#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>QBrand</B><BR>
					<!--- <CFPARAM NAME="FORM.Qbrand_desc" DEFAULT="0"> --->
					<SELECT NAME="Qbrand_desc" onChange="objForm.typecode_desc.populate(productCats[objForm.typegroup_desc.getValue() + ',' + objForm.Qbrand_desc.getValue()], null, null, stcBlank);" style="width: 150px;">
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>Type Code</B><BR>
					<!--- <CFPARAM NAME="FORM.typecode_desc" DEFAULT="0"> --->
					<SELECT NAME="typecode_desc" onChange="objForm.brand.populate(productCats[objForm.typegroup_desc.getValue() + ',' + objForm.Qbrand_desc.getValue() + ',' + objForm.typecode_desc.getValue()], null, null, stcBlank);" style="width: 150px;">
					</SELECT>
				</TD>
				<TD NOWRAP>
					<B>Brand</B><BR>
					<!--- <CFPARAM NAME="FORM.brand" DEFAULT="0"> --->
					<SELECT NAME="brand" style="width: 150px;">
					</SELECT>
				</TD>
				<TD valign="bottom">
					<input type="button" value="ADD" onclick="sendDataToServer()">
				</TD>
			</TR>
		</TABLE>
		
	</FIELDSET>
<br>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">chosen categories</LEGEND>
					<iframe src="select_product_cats_iframe_list.cfm?Program_ID=<cfoutput>#FORM.Program_ID#</cfoutput>" name="category_list_window" id="category_list_window" width="100%" marginwidth="0" marginheight="0" frameborder="0"></iframe>
	</FIELDSET>	

	</BLOCKQUOTE></BLOCKQUOTE>
<center>
	<script>
		function ask(){
			alert("Do I Allow Category Rate Entry Here Or Under The Rates Tab?")
		}
	</script>
	
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"contract_product_cats_rebate_entry.cfm?CID=#URL.CID#"
		button_type		=	"link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</center>
<!--- <script>
	<cfinclude template="/common_files/scripts/formInputLocationEmphasizer.js">
</script> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</body>
</html>
