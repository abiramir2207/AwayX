<CFSET FORM.Program_ID = URL.Program_ID>

<cfquery name="getSavedCategories" datasource="#application.datasource#">
SELECT     dbo.Type_Group_Desc.Type_Group_Desc, dbo.Q_Brand_Desc.Q_Brand_Desc, dbo.Brand.Brand, dbo.Type_Code_Desc.Type_Code_Desc, 
                      dbo.Program_Product_Categories.Program_ID, dbo.Program_Product_Categories.TypeGroup_desc_ID, 
                      dbo.Program_Product_Categories.Qbrand_desc_ID, dbo.Program_Product_Categories.TypeCode_desc_ID, dbo.Program_Product_Categories.Brand_ID,
                       dbo.Program_Product_Categories.Program_Product_Category_ID
FROM         dbo.Program_Product_Categories INNER JOIN
                      dbo.Type_Group_Desc ON dbo.Program_Product_Categories.TypeGroup_desc_ID = dbo.Type_Group_Desc.Type_Group_Desc_ID INNER JOIN
                      dbo.Q_Brand_Desc ON dbo.Program_Product_Categories.Qbrand_desc_ID = dbo.Q_Brand_Desc.Q_Brand_Desc_ID INNER JOIN
                      dbo.Brand ON dbo.Program_Product_Categories.Brand_ID = dbo.Brand.Brand_ID INNER JOIN
                      dbo.Type_Code_Desc ON dbo.Program_Product_Categories.TypeCode_desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
	WHERE isContract = 1 AND Program_ID = #FORM.Program_ID# and Deleted = 0
	Order By dbo.Type_Group_Desc.Type_Group_Desc, dbo.Q_Brand_Desc.Q_Brand_Desc, dbo.Type_Code_Desc.Type_Code_Desc, dbo.Brand.Brand
</cfquery>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>

	<script>
		var AlreadySelectedCategoryCombinations = new Array();
		AlreadySelectedCategoryCombinations[0]=""
		<CFOUTPUT query="getSavedCategories">
			AlreadySelectedCategoryCombinations[#getSavedCategories.currentrow#] = "#getSavedCategories.TypeGroup_Desc_ID#_#getSavedCategories.Qbrand_desc_ID#_#getSavedCategories.TypeCode_desc_ID#_#getSavedCategories.Brand_ID#"
		</CFOUTPUT>
	
	
		function verifyDelete(Cat_ID) {
			if(confirm("Are You Sure You Want To Delete This")){
				document.all.Program_Product_Category_ID.value = Cat_ID;
				document.all.DeleteCategory.submit();
			}
		}
	</script>
	
	

</head>

<body leftmargin="0" topmargin="0"> 
<table width="100%" align="center" CELLPADDING="2" CELLSPACING="0" BORDER="0" class="maintable">
	<TR bgcolor="dddddd">
		<TD>Type Group</TD>
		<TD>QBrand</TD>
		<TD>Type Code</TD>
		<TD>Brand</TD>
<!--- 		<TD>Volume</TD> --->
		<TD>&nbsp;</TD>
	</TR>
	<CFOUTPUT query="getSavedCategories">
	<TR>
		<TD>#getSavedCategories.Type_Group_Desc# - #getSavedCategories.TypeGroup_Desc_ID#</TD>
		<TD>#getSavedCategories.Q_Brand_Desc# - #getSavedCategories.QBrand_Desc_ID#</TD>
		<TD>#getSavedCategories.Type_Code_Desc# - #getSavedCategories.TypeCode_Desc_ID#</TD>
		<TD>#getSavedCategories.Brand# - #getSavedCategories.Brand_ID#</TD>
<!--- 		<TD><input type="text"></TD> --->
		<TD width="16"><img src="/images/delete.gif" title="Delete This Category Combination" border="0" style="cursor: pointer;" onclick="verifyDelete(#getSavedCategories.Program_Product_Category_ID#)" alt="Click Here To Delete"></TD>

	</TR>
	</CFOUTPUT>
	<cfif getSavedCategories.recordcount EQ 0>
	<TR>
		<TD colspan="100%" align="center"><span style="color: black; font-size: 20px;">No Categories On Record</span></TD>
	</TR>
	</cfif>
</table>

<form action="select_product_cats_iframe_list_action.cfm" method="post" name="SaveCategory" id="SaveCategory">
	<input type="hidden" name="Category_String">
	<input type="hidden" name="Program_ID" value="<cfoutput>#FORM.Program_ID#</cfoutput>">
</form>

<form action="select_product_cats_iframe_list_delete.cfm" method="post" name="DeleteCategory" id="DeleteCategory">
	<input type="hidden" name="Program_Product_Category_ID">
	<input type="hidden" name="Program_ID" value="<cfoutput>#FORM.Program_ID#</cfoutput>">
</form>

</body>
</html>
