<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<script>
		function dist(){
			NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=distributor_form", "distributorwindow", 800, 600, "yes", "yes")
		}
		
		function prod(){
			NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=distributor_form", "productwindow", 800, 600, "yes", "yes")
		}		
	</script>
</head>

<body>

<a href="#" onclick="dist()">select <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></a>
<br>
<a href="#" onclick="prod()">select product</a>

<cfoutput>
<form action="index_1.cfm" method="post" name="distributor_form" id="distributor_form">
	<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="<cfif isDefined("Form.Distributor_List")>#Form.Distributor_List#</cfif>">
	<INPUT TYPE="Hidden" NAME="Product_List" VALUE="">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="<cfif isDefined("Form.Product_List")>#Form.Product_List#</cfif>">
</FORM>
</cfoutput>


<cfif isDefined("Form.Distributor_List")>
<CFIF len(trim(Form.Distributor_List)) GT 0>
	<cfquery name="GetDist" datasource="#application.datasource#">
		SELECT Ship_To, Name
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID = '#Form.Distributor_List#' 
	</cfquery>
	<h2>Distributor:</h2>
	<CFDUMP var="#GetDist#">
</CFIF>
</cfif>
<BR><BR>
<cfif isDefined("Form.Product_List")>
<CFIF len(trim(Form.Product_List)) GT 0>
	<cfquery name="GetProd" datasource="#application.datasource#">
		SELECT Item, UPC, Description
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID = '#Form.Product_List#' 
	</cfquery>
	<h2>Product:</h2>
	<CFDUMP var="#GetProd#">
</cfif>
</cfif>

<BR>
<input type="Button" value="compile data" onclick="document.all.distributor_form.action = 'index_2.cfm'; document.all.distributor_form.submit();">
</body>
</html>
