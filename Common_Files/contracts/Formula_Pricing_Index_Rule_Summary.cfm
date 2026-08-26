<cfparam name="FORM.CID" 	default="">
<cfparam name="FORM.Rule_ID" 	default="">
<cfparam name="URL.CID" 	default="#FORM.CID#">
<cfparam name="URL.RID" 	default="#FORM.Rule_ID#">
<cfparam name="Form.EDIT" 	default=1>

<cf_cryp type="de" key="#request.key#" string="#URL.RID#">
<CFSET Rule_ID = cryp.value>

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET Program_ID = cryp.value>

<CFQUERY NAME="getRuleInfo" datasource="#application.datasource#">
	SELECT 	Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID, Formula_Pricing_Rule.*
	FROM 	Program_Formula_Pricing_Rule_Mapped
			INNER JOIN Formula_Pricing_Rule
			ON
			Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
			AND
			Formula_Pricing_Rule.Deleted = 0
	WHERE 
		Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = '#Rule_ID#'
		AND
		Program_Formula_Pricing_Rule_Mapped.Deleted = 0
</CFQUERY>

<CFSET Formula_ID = getRuleInfo.Formula_Pricing_Rule_ID>

<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
SELECT     *, dbo.Units_of_Measure.Unit_Of_Measure_Desc
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Main_ID = #Program_ID#
</CFQUERY>


<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
	SELECT		Units_of_Measure.Abbreviation, Units_of_Measure.Unit_Of_Measure_ID, dbo.Program_Formula_Pricing_Rule_Products.Product_Overage, 
				<!------dbo.Program_Formula_Pricing_Rule_Products.Weekly_Volume,----->
				dbo.Type_Code_Desc.Type_Code_Desc, dbo.Brand.Brand, dbo.BSA_Foodservice_Items_Master.Item, 
				dbo.BSA_Foodservice_Items_Master.UPC, dbo.BSA_Foodservice_Items_Master.Description, dbo.Brand.Brand_Name, dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
				dbo.Program_Formula_Pricing_Rule_Products.Program_ID, dbo.Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID
	FROM		dbo.BSA_Foodservice_Items_Master 
				INNER JOIN dbo.Type_Code_Desc 
				ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID 
				INNER JOIN dbo.Brand 
				ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID 
				INNER JOIN dbo.Contract_Products 
				ON dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Contract_Products.BSA_Foodservice_Items_Master_ID 
				INNER JOIN dbo.Program_Formula_Pricing_Rule_Products 
				ON dbo.Contract_Products.Contract_Products_ID = dbo.Program_Formula_Pricing_Rule_Products.Contract_Product_ID
				INNER JOIN Units_of_Measure
				ON Units_of_Measure.Unit_Of_Measure_ID = Program_Formula_Pricing_Rule_Products.Unit_Of_Measure_ID				
	WHERE		(dbo.Program_Formula_Pricing_Rule_Products.Active = 1) AND (dbo.Program_Formula_Pricing_Rule_Products.Deleted = 0) AND (dbo.Contract_Products.Deleted = 0) AND 
				(dbo.Program_Formula_Pricing_Rule_Products.Program_ID = '#Program_ID#') AND 
				(dbo.Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID = '#Rule_ID#')
	ORDER BY dbo.BSA_Foodservice_Items_Master.Item
</CFQUERY>

<CFSET PAGE_TITLE="Formula Pricing Rule Summary">
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
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 566px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<BLOCKQUOTE><BLOCKQUOTE>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 0px;"></cfif>
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

<cfoutput>
<Table>
	<TR>
		<TD>
			<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
				<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Rule Summary</LEGEND>
				<BR>
				<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
					<TR>
						<TD COLSPAN="100%"><FONT SIZE="2" COLOR="Navy"><B>Rule Name</B></FONT>&nbsp;<CFIF FORM.EDIT EQ 1> - <A STYLE="cursor:hand;" ONCLICK="document.all.STEP_1_EDIT.submit();"><FONT COLOR="FF0000" STYLE="font-weight:bold;font-size:15px;">[</FONT>click here to edit<FONT COLOR="FF0000" STYLE="font-weight:bold;font-size:15px;">]</FONT>&nbsp;</A><BR></CFIF><HR COLOR="Navy"></TD>
					</TR>
					<TR>
						<TD COLSPAN="100%" STYLE="cursor:hand;">
						<CFSET show_Title = getRuleInfo.Rule_Name>
						<CFSCRIPT>
							Border="Yes";
							BorderSize=1;  
							BorderColor="Silver";
							Image="/images/plus3.gif";
							ImageOpen="/images/minus3.gif";
							TitleColor="Navy"; 
							TitleFont="Arial";
							TitleSize=10;
							IsClosed="Yes";  
							WIDTH="95%";
						</CFSCRIPT>
						<CF_openLayer
							Border="#Border#"
							BorderSize="#BorderSize#"  
							BorderColor="#BorderColor#"  
							Image="#Image#"
							ImageOpen="#ImageOpen#"
							Title="#show_Title#"  
							TitleClosed="#show_Title#"
							TitleTooltip="Click here to toggle the view"  
							TitleColor="#TitleColor#"  
							TitleFont="#TitleFont#"
							TitleSize="#TitleSize#"
							IsClosed="#IsClosed#"
							Width="#width#">
							<CFSET URL.Formula_ID = getRuleInfo.Formula_Pricing_Rule_ID>
							<CFSET SHOW_RULE_TITLE = false>
							<CFINCLUDE TEMPLATE="/Settings/Formula_Pricing/Formula_Display.cfm">
						</CF_openLayer>
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="100%">
							<BR>
							<FONT SIZE="2" COLOR="Navy"><B>Products</B></FONT>&nbsp;<CFIF FORM.EDIT EQ 1> - <A STYLE="cursor:hand;" ONCLICK="document.all.STEP_3_EDIT.submit();"><FONT COLOR="FF0000" STYLE="font-weight:bold;font-size:15px;">[</FONT>click here to edit<FONT COLOR="FF0000" STYLE="font-weight:bold;font-size:15px;">]</FONT>&nbsp;</A><BR></CFIF>
							<HR COLOR="Navy">
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="100%">
							<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
								<TR BGCOLOR="FFCE84">
									<TD ID="header">&nbsp;</TD>
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD ID="header"><B>#application.returned_customer_setting.upc_label#</B></TD></cfif></cfif>
									<TD ID="header"><B>#application.returned_customer_setting.item_label#</B></TD>
									<TD ID="header"><B>Description</B></TD>
									<TD ID="header"><B>Type Code</B></TD>
									<TD ID="header"><B>Brand</B></TD>
									<!------<TD ID="header"><B>Volume</B></TD>----->
									<TD ID="header"><B>Overage</B></TD>
									<TD ID="header"><B>UOM</B></TD>
								</TR>
								<CFIF Get_Products.recordcount GT 0>
									<CFLOOP QUERY="Get_Products">
										<CFSEt ThisProductsID = Get_Products.BSA_Foodservice_Items_Master_ID>
										<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#ThisProductsID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
											<TD ID="header">&nbsp;</TD>
											<TD>#Item#&nbsp;</TD>
											<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD>#UPC#&nbsp;</TD></cfif></cfif>
											<TD>#Description#&nbsp;</TD>
											<TD>#Type_Code_Desc#&nbsp;</TD>
											<TD>#Brand_Name#&nbsp;</TD>
											<!------<TD>#Weekly_Volume#&nbsp;#GetAllContractInfo.Unit_Of_Measure_Desc#</TD>----->
											<TD ALIGN="CENTER"><CFIF Unit_Of_Measure_ID EQ 2>$</CFIF>#numberformat(Get_Products.Product_Overage, '__.___')#</TD>
											<TD>#Get_Products.Abbreviation#</TD>
										</TR>
									</CFLOOP>
								</CFIF>
							</TABLE>							
						</TD>
					</TR>
				</TABLE>
			</cfoutput>
			</FIELDSET>		
		</TD>
	</TR>
	<TR>
		<TD ALIGN="center">
			<CF_button
				button_name		=	""
				button_caption	=	"return"
				button_action	=	"document.location.href='Formula_Pricing_Index.cfm?CID=#URL.CID#'"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	"click here to activate this rule"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>			
		</TD>
	</TR>
</TABLE>

<CFOUTPUT>
	<!------<FORM ACTION="Contract_Formula_Rule_Step_4_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>

	<FORM ACTION="Contract_Formula_Rule_Step_1.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_1_EDIT" ID="STEP_1_EDIT">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>
	
	<FORM ACTION="Contract_Formula_Rule_Step_2.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_2_EDIT" ID="STEP_2_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<INPUT TYPE="Hidden" NAME="RULE_ID" VALUE="#URL.RID#">
	</FORM>
	<FORM ACTION="Contract_Formula_Rule_Step_3.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_3_EDIT" ID="STEP_3_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>----->
	
	<FORM ACTION="Contract_Formula_Add_Rule.cfm" METHOD="post" NAME="STEP_1_EDIT" ID="STEP_1_EDIT">
		<INPUT TYPE="Hidden" NAME="Rule_ID" VALUE="#Rule_ID#">
		<INPUT TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
	</FORM>
	
	<FORM ACTION="Contract_Formula_Add_Products.cfm" METHOD="post" NAME="STEP_3_EDIT" ID="STEP_3_EDIT">
		<INPUT TYPE="Hidden" NAME="Rule_ID" VALUE="#Rule_ID#">
		<INPUT TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
	</FORM>
</CFOUTPUT>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
