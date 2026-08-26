

<CFSET URL.RID = FORM.Program_Formula_Pricing_Rule_ID>







<cf_cryp type="de" key="#request.key#" string="#URL.RID#">
<CFSET Rule_ID = cryp.value>

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET Program_ID = cryp.value>


<CFSET PAGE_TITLE="">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		function submitForm() {
			if(confirm("Press OK to activate this rule.")){
				document.all.MyForm.submit();
			}
		}
	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF len(URL.CID) EQ 0>
<CFSET temp = 0>
<CFELSE>
<CFSEt temp = cryp.value>
</CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 

<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>

<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfinclude template="minimal_contract_info.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	<!--- TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;} --->
	#header {font-size: 12px;}
</style>


<CFQUERY datasource="#application.datasource#" NAME="existing_Products">
	SELECT		fp.Weekly_Volume, cfim.Item, cfim.UPC, cfim.Description, 
	           	b.Brand_Name, tc.Type_Code_Desc
	FROM		Program_Formula_Pricing_Rule_Products fp,  
				Contract_Products cp,
				BSA_Foodservice_Items_Master cfim,
			   	Brand b,
			   	Type_Code_Desc tc
	WHERE	
				fp.Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
				AND
				fp.Program_ID = '#Program_ID#'
				AND		
				cp.Contract_Products_ID = fp.Contract_Product_ID
				AND		
				fp.Active = 1
				AND		
				fp.Deleted = 0	
				AND
				cp.BSA_Foodservice_Items_Master_ID = cfim.BSA_Foodservice_Items_Master_ID
				AND
				cfim.Brand_ID = b.Brand_ID
				AND
	           	cfim.Type_Code_Desc_ID = tc.Type_Code_Desc_ID
	ORDER BY	description
</CFQUERY>

<CFQUERY NAME="selected_Products" datasource="#application.datasource#">
	SELECT     cfim.BSA_Foodservice_Items_Master_ID, cfim.Item, cfim.UPC, cfim.Description, 
	           b.Brand_Name, tc.Type_Code_Desc
	FROM       
			   BSA_Foodservice_Items_Master cfim,
			   Brand b,
			   Type_Code_Desc tc	           
	WHERE
				cfim.Brand_ID = b.Brand_ID
				AND
	           	cfim.Type_Code_Desc_ID = tc.Type_Code_Desc_ID
				AND
				(
				1=2
				<CFLOOP INDEX="Product_ID" LIST="#FORM.ABS_FINAL_PRODUCT_LIST#">
				 OR cfim.BSA_Foodservice_Items_Master_ID = '#Product_ID#'
				</CFLOOP>
				)
	ORDER BY 	description
</CFQUERY>

<cfoutput>
<Table>
	<TR>
		<TD COLSPAN="2">
			<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
				<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Step 1 - Edit Confirmation</LEGEND>
				<BR>
				<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
					<TR>
						<TD WIDTH="50%" VALIGN="TOP">
							<TABLE WIDTH="100%" CELLPADDING="2" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
							<CAPTION><b>Current Settings</b></CAPTION>
								<TR>									
									<TD>
									<b>Products</b>
									<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
									<TR BGCOLOR="FFCE84">
										<TD ID="header">&nbsp;</TD>
										<TD ID="header">#application.returned_customer_setting.item_label#</TD>
										<TD ID="header">#application.returned_customer_setting.upc_label#</TD>
										<TD ID="header">Description</TD>
										<TD ID="header">Type Code</TD>
										<TD ID="header">Brand</TD>
										<TD ID="header">Weekly Volume</TD>
									</TR>								
									<CFIF existing_Products.recordcount GT 0>
										<CFLOOP QUERY="existing_Products">
											<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="TOP">
												<TD ID="header">&nbsp;</TD>
												<TD>#Item#&nbsp;</TD>
												<TD>#UPC#&nbsp;</TD>
												<TD>#Description#&nbsp;</TD>
												<TD>#Type_Code_Desc#&nbsp;</TD>
												<TD>#Brand_Name#&nbsp;</TD>
												<TD>#Weekly_Volume#&nbsp;</TD>
											</TR>
										</CFLOOP>
									</CFIF>
									</TABLE>
									</TD>
								</TR>
							</TABLE>
						</TD>
						<TD BGCOLOR="000080" ROWSPAN="100%" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
						<TD WIDTH="50%" VALIGN="TOP">
							<FORM ACTION="Contract_Formula_Rule_Step_3_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
								<INPUT TYPE="hidden" NAME="UPDATE" ID="UPDATE" VALUE="1">
								
								<INPUT TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
							 	<INPUT TYPE="Hidden" NAME="Abs_Final_Product_List" VALUE="#Form.Abs_Final_Product_List#">
								<INPUT TYPE="Hidden" NAME="Program_Formula_Pricing_Rule_ID" VALUE="#URL.RID#">		
								<INPUT TYPE="Hidden" NAME="Formula_Price_Rebate_Type" VALUE="#Form.Formula_Price_Rebate_Type#">
							<TABLE WIDTH="100%" CELLPADDING="2" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
							<CAPTION><b>Edited To</b></CAPTION>								
								<TR>
									<TD>
									<b>Products</b>
									<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
									<TR BGCOLOR="FFCE84">
										<TD ID="header">&nbsp;</TD>
										<TD ID="header">Item</TD>
										<TD ID="header">UPC</TD>
										<TD ID="header">Description</TD>
										<TD ID="header">Type Code</TD>
										<TD ID="header">Brand</TD>
										<TD ID="header">Weekly Volume</TD>
									</TR>								
									<CFIF selected_Products.recordcount GT 0>
										<CFLOOP QUERY="selected_Products">
											<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="TOP">
												<TD ID="header">&nbsp;</TD>
												<TD>#Item#&nbsp;</TD>
												<TD>#UPC#&nbsp;</TD>
												<TD>#Description#&nbsp;</TD>
												<TD>#Type_Code_Desc#&nbsp;</TD>
												<TD>#Brand_Name#&nbsp;</TD>
												<TD>
												<CFSET ThisProductIDFormattedForHTMLFormElementName = Replace(BSA_Foodservice_Items_Master_ID,"-","_", "ALL")>
												<CFSET thisWeeklyVolume=Evaluate("Form.WEEKLYVOLUME_#ThisProductIDFormattedForHTMLFormElementName#")>
												#thisWeeklyVolume#&nbsp;
												<input TYPE="hidden" NAME="WEEKLYVOLUME_#ThisProductIDFormattedForHTMLFormElementName#" size="8" VALUE="#thisWeeklyVolume#">
												</TD>
											</TR>
										</CFLOOP>
									</CFIF>
									</TABLE>
									</TD>
								</TR>
							</TABLE>
							</FORM>
						</TD>
					</TR>
				</TABLE>				
			</cfoutput>
			</FIELDSET>		
			<BR><BR>
		</TD>
	</TR>
	<TR>
		<TD ALIGN="right">
			<CF_button
				button_name		=	""
				button_caption	=	"cancel"
				button_action	=	"document.all.STEP_3_EDIT.submit();"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	"cancel"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>			
		</TD>
		<TD ALIGN="left">
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"document.all.MyForm.submit();"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	"save"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>			
		</TD>
	</TR>
</TABLE>

<CFOUTPUT>
<!------
	<FORM ACTION="Contract_Formula_Rule_Step_1.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_1_EDIT" ID="STEP_1_EDIT">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>
	
	<FORM ACTION="Contract_Formula_Rule_Step_2.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_2_EDIT" ID="STEP_2_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<CF_Cryp type="en" key="#request.key#" string="#URL.RID#">
		<INPUT TYPE="Hidden" NAME="RULE_ID" VALUE="#cryp.value#">
	</FORM>
	---->
	<FORM ACTION="Contract_Formula_Rule_Step_3.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_3_EDIT" ID="STEP_3_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>
	
</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
