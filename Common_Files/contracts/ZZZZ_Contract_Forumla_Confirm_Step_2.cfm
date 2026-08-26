
<CFSET URL.CID = FORM.Program_ID>
<CFSET URL.RID = FORM.Program_Formula_Pricing_Rule_ID>



<CFSET Rule_ID = URL.RID>


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


<CFQUERY datasource="#application.datasource#" NAME="get_Commodity_From_Database">
	SELECT     	s.Symbol_Description, 
				e.Exchange_Detail_Name,
				fp.Point_In_Time, 
				fp.Point_In_Time_UOM, 
	            fp.Sample_Size, 
				fp.Sample_Size_UOM, 
				fp.Weight
	FROM         
				Program_Formula_Pricing_Rule_Comm_Data fp,
	            Commodities_Symbol s,				
	            Commodities_Exchange_Detail e	            
	WHERE
				fp.Symbol = s.Symbol
				AND
				fp.Exchange = e.Exchange_Detail_ID
				AND
				fp.Program_ID = '#Program_ID#'
				AND
				fp.Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
				AND
				fp.Active = 1
				AND
				fp.Deleted = 0
</CFQUERY>

<CFQUERY datasource="#application.datasource#" NAME="selectedCommodities">
	SELECT     	s.Symbol_Description, 
				e.Exchange_Detail_Name
	FROM         
	            Commodities_Symbol s,				
	            Commodities_Exchange_Detail e	            
	WHERE
				1=2
		<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Comms#" STEP="1">
				OR
				(
				s.Symbol = '#evaluate("FORM.COMMODITY_#i#")#'
				AND
				e.Exchange_Detail_ID = '#evaluate("FORM.EXCHANGE_#i#")#'
				)
		</CFLOOP>
</CFQUERY>
<CFSET i = 1>
<CFLOOP QUERY="selectedCommodities">
	<CFSET "Exchange#i#"				= selectedCommodities.Exchange_Detail_Name>
	<CFSET "Symbol#i#"				= selectedCommodities.Symbol_Description>
	<CFSET i = i + 1>
</CFLOOP>

<CFQUERY datasource="#application.datasource#" NAME="existing_Overage">
	SELECT	
			Description,
			Amount,
			UOM
	FROM	Program_Formula_Pricing_Rule_Overage
	WHERE
			Program_ID		=	'#Program_ID#'
			AND
			Program_Formula_Pricing_Rule_ID	=	'#URL.RID#'
			AND
			Active			=	1
			AND
			Deleted			=	0
	ORDER BY	Overage_Index
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
									<TD WIDTH="80%">
									<B>Number of Commodities</B>: 
									#get_Commodity_From_Database.recordCount#
									</TD>
								</TR>
								<TR>
									<TD>
									<B>Commodities</B><br>
									<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
									<TR BGCOLOR="FFCE84" VALIGN="bottom">
										<TD ID="header"><B>Exchange</B></TD>
										<TD ID="header"><B>Commodity</B></TD>
										<TD ID="header"><B>Sample Size</B></TD>
										<TD ID="header"><B>Lag</B></TD>
										<TD ID="header"><B>Weight</B></TD>
									</TR>
									<CFSET i=1>
									<CFLOOP QUERY="get_Commodity_From_Database">
										<TR VALIGN="TOP">
											<TD>#get_Commodity_From_Database.Exchange_Detail_Name#</TD>
											<TD>#get_Commodity_From_Database.Symbol_Description#</TD>
											<TD>#get_Commodity_From_Database.Point_In_Time# #get_Commodity_From_Database.Point_In_Time_UOM#</TD>
											<TD>#get_Commodity_From_Database.Sample_Size# #get_Commodity_From_Database.Sample_Size_UOM#</TD>
											<TD>#get_Commodity_From_Database.Weight#%</TD>
										</TR>
										<CFSET i= i + 1>
									</CFLOOP>
									</TABLE>
									<BR>									
									</TD>
								</TR>
								<TR>									
									<TD>
									<B>Overage Components</B><br>						
									<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
									<CFLOOP QUERY="existing_Overage">
										<TR>
											<TD>#existing_Overage.Amount# #existing_Overage.UOM#</TD>
											<TD>#existing_Overage.Description#</TD>													
										</TR>
									</CFLOOP>
									</TABLE>
									</TD>
								</TR>
							</TABLE>
						</TD>
						<TD BGCOLOR="000080" ROWSPAN="100%" WIDTH="1"><IMG SRC="/images/fill.gif" ALT="" WIDTH="2" HEIGHT="1" BORDER="0"></TD>
						<TD WIDTH="50%" VALIGN="TOP">
							<FORM ACTION="Contract_Formula_Rule_Step_2_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
								<INPUT TYPE="hidden" NAME="UPDATE" ID="UPDATE" VALUE="1">
								<INPUT TYPE="hidden" NAME="Program_Formula_Pricing_Rule_ID" ID="Program_Formula_Pricing_Rule_ID" VALUE="#FORM.Program_Formula_Pricing_Rule_ID#">
								<INPUT TYPE="hidden" NAME="PROGRAM_ID" ID="PROGRAM_ID" VALUE="#URL.CID#">
							<TABLE WIDTH="100%" CELLPADDING="2" CELLSPACING="0" STYLE="font-size : 10px;" BORDER="0">
							<CAPTION><b>Edited To</b></CAPTION>
								<TR>
									<TD WIDTH="80%">
									<B>Number of Commodities</B>: #FORM.Number_Of_Comms#
									<INPUT TYPE="HIDDEN" ID="Number_Of_Comms" NAME="Number_Of_Comms" VALUE="#FORM.Number_Of_Comms#">
									</TD>
								</TR>
								<TR>
									<TD>
									<B>Commodities</B><br>
									<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
									<TR BGCOLOR="FFCE84" VALIGN="bottom">
										<TD ID="header"><B>Exchange</B></TD>
										<TD ID="header"><B>Commodity</B></TD>
										<TD ID="header"><B>Sample Size</B></TD>
										<TD ID="header"><B>Lag</B></TD>
										<TD ID="header"><B>Weight</B></TD>
									</TR>
									<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Comms#" STEP="1">
										<CFSET thisExchange				= evaluate("FORM.EXCHANGE_#i#")>
										<CFSET thisSymbol				= evaluate("FORM.COMMODITY_#i#")>
										<CFSET thisPointInTIme			= evaluate("FORM.POINT_IN_TIME_#i#")>
										<CFSET thisPointInTImeUOM		= evaluate("FORM.TIME_UOM_POINT_IN_TIME_#i#")>
										<CFSET thisSampleSize			= evaluate("FORM.SAMPLE_SIZE_#i#")>
										<CFSET thisSampleSizeUOM		= evaluate("FORM.TIME_UOM_SAMPLE_SIZE_#i#")>
										<CFSET thisWeight				= evaluate("FORM.Comm_weight_#i#")>
										<INPUT TYPE="HIDDEN" ID="EXCHANGE_#i#" NAME="EXCHANGE_#i#" VALUE="#thisExchange#">
										<INPUT TYPE="HIDDEN" ID="COMMODITY_#i#" NAME="COMMODITY_#i#" VALUE="#thisSymbol#">
										<INPUT TYPE="HIDDEN" ID="POINT_IN_TIME_#i#" NAME="POINT_IN_TIME_#i#" VALUE="#thisPointInTIme#">
										<INPUT TYPE="HIDDEN" ID="TIME_UOM_POINT_IN_TIME_#i#" NAME="TIME_UOM_POINT_IN_TIME_#i#" VALUE="#thisPointInTImeUOM#">
										<INPUT TYPE="HIDDEN" ID="SAMPLE_SIZE_#i#" NAME="SAMPLE_SIZE_#i#" VALUE="#thisSampleSize#">
										<INPUT TYPE="HIDDEN" ID="TIME_UOM_SAMPLE_SIZE_#i#" NAME="TIME_UOM_SAMPLE_SIZE_#i#" VALUE="#thisSampleSizeUOM#">
										<INPUT TYPE="HIDDEN" ID="Comm_weight_#i#" NAME="Comm_weight_#i#" VALUE="#thisWeight#">
										<CFIF IsDefined("Exchange#i#")>
											<CFSET thisExchange				= evaluate("Exchange#i#")>
										</CFIF>
										<CFIF IsDefined("Symbol#i#")>
											<CFSET thisSymbol				= evaluate("Symbol#i#")>
										</CFIF>
										<TR VALIGN="TOP">
											<TD>#thisExchange#</TD>
											<TD>#thisSymbol#</TD>
											<TD>#thisPointInTIme# #thisPointInTImeUOM#</TD>
											<TD>#thisSampleSize# #thisSampleSizeUOM#</TD>
											<TD>#thisWeight#%</TD>
										</TR>
									</CFLOOP>
									</TABLE>
									<BR>
									</TD>
								</TR>
								<TR>									
									<TD>							
									<B>Overage Components</B><br>
									<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
									<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
										<CFIF Isdefined("FORM.independent_amount_uom#i#_1")>
											<CFSET thisDescription = evaluate("FORM.INDEPENDENT_DESC_CALC#i#_1")>
											<CFSET thisAmount = evaluate("FORM.independent_amount_calc#i#_1")>
											<CFSET thisUOM = evaluate("FORM.independent_amount_uom#i#_1")>
											<CFIF len(trim(thisDescription)) GT 0 AND len(trim(thisAmount)) GT 0>
												<INPUT TYPE="HIDDEN" ID="INDEPENDENT_DESC_CALC#i#_1" NAME="INDEPENDENT_DESC_CALC#i#_1" VALUE="#thisDescription#">
												<INPUT TYPE="HIDDEN" ID="independent_amount_calc#i#_1" NAME="independent_amount_calc#i#_1" VALUE="#thisAmount#">
												<INPUT TYPE="HIDDEN" ID="independent_amount_uom#i#_1" NAME="independent_amount_uom#i#_1" VALUE="#thisUOM#">
												<TR>
													<TD>#thisAmount# #thisUOM#</TD>
													<TD>#thisDescription#</TD>													
												</TR>
											</CFIF>
										</CFIF>
									</CFLOOP>
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
				button_action	=	"document.all.STEP_2_EDIT.submit();"
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
	----->
	<FORM ACTION="Contract_Formula_Rule_Step_2.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_2_EDIT" ID="STEP_2_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<CF_Cryp type="en" key="#request.key#" string="#URL.RID#">
		<INPUT TYPE="Hidden" NAME="RULE_ID" VALUE="#cryp.value#">
	</FORM>
	<!----
	<FORM ACTION="Contract_Formula_Rule_Step_3.cfm?CID=#URL.CID#" METHOD="post" NAME="STEP_3_EDIT" ID="STEP_3_EDIT">
		<INPUT TYPE="Hidden" NAME="Update" VALUE="1">
		<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
	</FORM>
	---->
</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
