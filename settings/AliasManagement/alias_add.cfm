
<cfoutput>

	<CF_MessageWindow>

<cfparam name="form.Distributor_Alias" 			default="">
<cfparam name="form.Distributor_List" 			default="">
<cfparam name="form.Product_Alias" 				default="">
<cfparam name="form.ExistingProductList" 		default="">
<cfparam name="form.Product_List" 				default="">
<cfparam name="Alias_ID"					default="">




<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Alias Information</LEGEND>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup>
		
		<tr><td colspan="2" class="SectionHeader">#application.returned_customer_setting.distributor_label_singular# Alias</td></tr>
		
			<!--- Distributor Alias  --->
				<TR>
					<TD ALIGN="right"><B>#application.returned_customer_setting.distributor_label_singular# Alias Text:</B><br>(What people call the #application.returned_customer_setting.distributor_label_singular#)</TD>
					<TD><span id="error_DistributorAlias1"></span><span id="error_DistributorAlias2"></span><INPUT NAME="Distributor_Alias" TYPE="text" VALUE="#form.Distributor_Alias#" SIZE="30" MAXLENGTH="50"></TD>
				</TR>
					<TR>
				<TD ALIGN="right"><B>Search for #lcase(application.returned_customer_setting.distributor_label_singular)#:</B></TD>
				<TD>
				<CF_smallLink 
				title = "search for #lcase(application.returned_customer_setting.distributor_label_singular)#" 
				url = "##"
				parameters = "onClick=""showDistributorSearchWindow();"""
				> 
<INPUT NAME="Distributor_List" TYPE="hidden"  value="#form.Distributor_List#"></TD>
			</TR>	
			<tr><td>&nbsp; </td><Td align="Center">
			<p>&nbsp; </p>
			<CF_smallLink 
	title = "save #lcase(application.returned_customer_setting.distributor_label_singular)# alias" 
	url = "##"
	parameters = "onClick=""confirmCompletion();"""
></TD></tr>

<!--- /Distributor Alias  --->

<tr><td colspan="2"><hr width="90%" color="orange"></td></tr>
	
	<!--- Product Alias  --->
	
				<TR>
					<TD ALIGN="right"><B>Product Alias Text:</B><br>(What people call the product)</TD>
					<TD><span id="error_ProductAlias1"></span><span id="error_ProductAlias2"></span><INPUT NAME="Product_Alias" TYPE="text" VALUE="#form.Product_Alias#" SIZE="30" MAXLENGTH="50"></TD>
				</TR>
					<TR>
				<TD ALIGN="right"><B>Search for product:</B></TD>
				<Td><CF_smallLink 
	title = "search for product" 
	url = "##"
	parameters = "onClick=""showProductSearchWindow();"""
>
	<INPUT NAME="ExistingProductList" TYPE="hidden"  value="#form.ExistingProductList#">
	<INPUT NAME="Product_List" TYPE="hidden"  value="#form.Product_List#">
	<input type="hidden" name="command" value="">
	<input type="hidden" name="display" value="">
	</TD></tr>
		<tr><td>&nbsp; </td><Td align="Center">
			<p>&nbsp; </p>
			<CF_smallLink 
	title = "save product alias" 
	url = "##"
	parameters = "onClick=""confirmCompletion();"""
></TD></tr>

		<!--- /Product Alias  --->
		
	</table>
</FIELDSET>
</cfoutput>