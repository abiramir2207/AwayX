	<!--- sectuin for Product --->
	<CFPARAM NAME="FORM.Q_Brand_ID" 					DEFAULT="0">
	<CFPARAM NAME="FORM.Type_Code_Desc_ID" 				DEFAULT="0">
	<CFPARAM NAME="FORM.Brand_ID" 						DEFAULT="0">
	<CFPARAM NAME="FORM.Product_Status" 				DEFAULT="A">
	<CFPARAM NAME="FORM.item_number" 					DEFAULT="">
	<CFPARAM NAME="FORM.upc_number" 					DEFAULT="">
	<CFPARAM NAME="FORM.description_string" 			DEFAULT="">
	<CFPARAM NAME="FORM.product_sort_by" 				DEFAULT="">
	<CFPARAM NAME="FORM.product_sort_Order" 			DEFAULT="ASC1">
	<cfparam name="FORM.Rebate_Type_Search_ID" 			default="0">
	<CFPARAM NAME="FORM.Distributor" 					DEFAULT="0">
	<CFPARAM NAME="FORM.Invoice_Days" 					DEFAULT="">
	<CFPARAM NAME="FORM.Type_Group_Desc_ID" 			DEFAULT="">
	<CFPARAM NAME="FORM.DTPS_Program_ID" 				DEFAULT="">
	<CFPARAM NAME="FORM.Product_Line_Of_Biz" 			DEFAULT="">
	<CFPARAM NAME="SHOW_INVOICE_FILTER" 				DEFAULT="0">
	<CFPARAM NAME="FORM.Type_Code_Desc_Text" 			DEFAULT="">
	<CFPARAM NAME="FORM.Type_Group_Desc_Text" 			DEFAULT="">
	
	<SCRIPT language="JavaScript" src="invoiceCommon.js"></SCRIPT>
	
	<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
		SELECT *
		FROM Type_Group_Desc
		WHERE len(Type_Group_Desc) != 0 AND Deleted = 0
		ORDER BY Type_Group_Desc
	</CFQUERY>
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get type codes																				 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
		SELECT *
		FROM Type_Code_Desc
		WHERE len(Type_Code_Desc) != 0 AND Deleted = 0
		ORDER BY Type_Code_Desc
	</CFQUERY>
	
	<cfoutput>
	
		<INPUT TYPE="Hidden" NAME="Type_Code_Desc_Text" ID="Type_Code_Desc_Text" VALUE="">
		<INPUT TYPE="Hidden" NAME="Type_Group_Desc_Text" ID="Type_Group_Desc_Text" VALUE="">
		
		<DIV ID="filterProduct" STYLE="display:none; visibility:hidden;" <!---ALIGN="center"--->>
			<BR><HR COLOR="Orange" SIZE="1">
			<FIELDSET STYLE="padding:10px; border:5px outset LightGrey; width:400px">
				<LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;">Product Criteria</LEGEND>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="5" STYLE="background-color: ##F5FFFA ;">
					<TR>
						<TD NOWRAP ALIGN="left">
							<B>#application.returned_customer_setting.type_group_label_singular#</B><BR>
							<SELECT NAME="Type_Group_Desc_ID" ONCHANGE="javascript:set_hidden_value(document.MyInvoiceForm.Type_Group_Desc_Text, document.MyInvoiceForm.Type_Group_Desc_ID);">
								<OPTION VALUE="0">**ALL** #application.returned_customer_setting.type_group_label_plural#</OPTION>
								<CFLOOP QUERY="GetTypeGroupDesc"><OPTION VALUE="#Type_Group_Desc_ID#"<cfif FORM.Type_Group_Desc_ID EQ "#trim(Type_Group_Desc_ID)#"> SELECTED</cfif>>#Type_Group_Desc#</OPTION></CFLOOP>
							</SELECT>
						</TD>
						<TD NOWRAP ALIGN="left">
							<B>#application.returned_customer_setting.type_code_label_singular#</B><BR>
							<SELECT NAME="Type_Code_Desc_ID" ONCHANGE="javascript:set_hidden_value(document.MyInvoiceForm.Type_Code_Desc_Text, document.MyInvoiceForm.Type_Code_Desc_ID);">
								<OPTION VALUE="0">**ALL** #application.returned_customer_setting.type_code_label_plural#</OPTION>
								<CFLOOP QUERY="GetTypeCodeDesc"><OPTION VALUE="#Type_Code_Desc_ID#"<cfif FORM.Type_Code_Desc_ID EQ "#trim(Type_Code_Desc_ID)#"> SELECTED</cfif>>#Type_Code_Desc#</OPTION></CFLOOP>
							</SELECT>
						</TD>
						<TD NOWRAP ALIGN="left">
						<B>Item ##</B><BR><input TYPE="Text" NAME="item_number" VALUE="<CFOUTPUT>#FORM.item_number#</CFOUTPUT>" STYLE="WIDTH:180px">
						</TD>
						<TD>
							<BR>&nbsp&nbsp
							<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10">
							<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: reset_Form_Fields(3);">reset</a><FONT COLOR="##FF0000">]</FONT></B>
						</TD>		
					</TR>
			</TABLE>
		</FIELDSET>
		<BR>
	</DIV>
</cfoutput>