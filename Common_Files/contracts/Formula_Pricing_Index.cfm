<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<CFSET PAGE_TITLE="Product Formula pricing Entry">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE><BLOCKQUOTE>

<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 100px; top: 10px;"></cfif>
<cfinclude template="minimal_contract_info.cfm">

<BR>
<!--------------------------------------------------------------
Default will be changed to Pre-Active rather than RFA
--------------------------------------------------------------->
<!---------------
<CFSET FORM.On_Release_Contract_Status_Type_IDX = CSLGetContractInfo.On_Release_Contract_Status_Type_IDX>
<FORM ACTION="Formula_Pricing_Program_Release_Action.cfm" METHOD="post" NAME="ReleaseStatusForm" ID="ReleaseStatusForm">
	<TABLE>
		<TR>
			<TD nowrap><span id="error_PricingPeriods"></span>&nbsp;<B>Program Status On Release:</B></TD>
			<CFOUTPUT>
			<TD VALIGN="top">
				<INPUT TYPE="Radio" NAME="On_Release_Contract_Status_Type_IDX" VALUE="2" <CFIF FORM.On_Release_Contract_Status_Type_IDX EQ 2>CHECKED</CFIF>>Ready For Approval (RFA)<INPUT TYPE="Radio" NAME="On_Release_Contract_Status_Type_IDX" VALUE="4" <CFIF FORM.On_Release_Contract_Status_Type_IDX EQ 4>CHECKED</CFIF>>Pre-Active (P-ACT)
			</TD>
			</CFOUTPUT>
			<TD>
				<INPUT TYPE="submit" VALUE="save">
			</TD>
		</TR>		
	</TABLE>
	<CFOUTPUT><INPUT TYPE="hidden" NAME="Program_ID" ID="Program_ID" VALUE="#URL.CID#"></CFOUTPUT>
</FORM>
---------------------->
<CFSCRIPT>
	Layerborder="Yes";
	BorderSize=1;  
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Blue"; 
	TitleFont="Arial";
	TitleSize=9;
	IsClosed="Yes";  
	layerwidth=600;
</CFSCRIPT>

<cfset useLakebaseForgetCurrentPeriods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForgetCurrentPeriods>
	<cftry>
		<cfset getCurrentPeriods = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_periods", {
				"program_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "start_date.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentPeriods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentPeriods>
<CFQUERY NAME="getCurrentPeriods" datasource="#application.datasource#">
	SELECT *
	FROM Program_Formula_Pricing_Periods
	WHERE Program_ID = '#FORM.Contract_Main_ID#'
	AND
		DELETED = 0
	AND 
		ACTIVE = 1
	ORDER BY Start_Date		
</CFQUERY>
</cfif>
   <span style="width=800px"> <B><FONT SIZE="2" COLOR="Navy">1. Pricing Periods</FONT></B>
&nbsp;
<A HREF="Contract_Formula_Pricing_Periods_step_1.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" STYLE="<!--- font-size: 20px --->"><span STYLE="color: red; font-weight: bold;">[</span>Click here to establish new pricing periods<span STYLE="color: red; font-weight: bold;">]</span></A>
<CFIF getCurrentPeriods.recordcount GT 0>
	<FONT COLOR="FF0000"><B>[</B></FONT><a HREF="Contract_Formula_Pricing_Periods_step_2.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>">edit current periods</a><FONT COLOR="FF0000"><B>]</B></FONT></span>
</CFIF>
<HR COLOR="Navy" WIDTH="800" ALIGN="left">

<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Current Pricing Periods"  
	TitleClosed="Click Here to View The Current Pricing Periods"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="No"
	width="#layerwidth#">
		
		
		<CFIF getCurrentPeriods.recordcount EQ 0>
			<div ALIGN="center" STYLE="color: red; font-size:15px;font-weight:bold;">NO PERIODS DEFINED</div>
		<CFELSE>
			<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
				<!--- TABLE HEADERS --->
				<TR BGCOLOR="#FFCE84" VALIGN="bottom">
					<TD ID="header" ALIGN="center"><B>Period</B></TD>
					<TD ID="header"><B>Start Date</B></TD>
					<TD ID="header"><B>End Date</B></TD>
					<TD ID="header"><B>Release Date</B></TD>
				</TR>
				
				<!--- TABLE DATA QUERY --->
				<CFOUTPUT QUERY="getCurrentPeriods">
					<TR <!--- BGCOLOR="#IIf(i Mod 2, DE('ffffff'), DE('C6FFC6'))#" ---> VALIGN="top">
						<TD ALIGN="center">#currentrow#</TD>
						<TD>#dateFormat(Start_Date, 'm/d/yyyy')#</TD>
						<TD>#dateFormat(End_Date, 'm/d/yyyy')#</TD>
						<TD>#dateFormat(Release_Date, 'm/d/yyyy')#</TD>
					</TR>
				</CFOUTPUT>
			</TABLE>		
		</CFIF>

 	
	
</CF_openLayer>


<BR><BR><BR>

<CFIF getCurrentPeriods.recordcount GT 0>
<CFQUERY NAME="getPricingRules" datasource="#application.datasource#">
	SELECT 	Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID, Formula_Pricing_Rule.*
	FROM 	Program_Formula_Pricing_Rule_Mapped
			INNER JOIN Formula_Pricing_Rule
			ON
			Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
			AND
			Formula_Pricing_Rule.Deleted = 0
	WHERE 
		Program_Formula_Pricing_Rule_Mapped.Program_ID = '#FORM.Contract_Main_ID#'
		AND
		Program_Formula_Pricing_Rule_Mapped.Deleted = 0
</CFQUERY>

<span style="width=800px"><B><FONT SIZE="2" COLOR="Navy">2. Pricing Rules</FONT></B>
&nbsp;
<CFIF getCurrentPeriods.recordcount EQ 0>
	<A onclick="alert('Please Define The Rule Periods Before Creating A Rule')"><span STYLE="color: red; fon-weight: bold; cursor: hand;">[</span>Click here to add a rule<span STYLE="color: red; fon-weight: bold;">]</span></A>
<CFELSE>
	<!------<A HREF="Contract_Formula_Rule_Step_1.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" STYLE="<!--- font-size: 20px --->"><span STYLE="color: red; font-weight: bold;">[</span>Click here to add a rule<span STYLE="color: red; font-weight: bold;">]</span></A>----->
	<span style="width=120px"><A HREF="Contract_Formula_Add_Rule.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" STYLE="<!--- font-size: 20px --->"><span STYLE="color: red; font-weight: bold;">[</span>Click here to add a rule<span STYLE="color: red; font-weight: bold;">]</span></A>	</span>
</CFIF></span>
<HR COLOR="Navy" WIDTH="800" ALIGN="left">
		<CFIF getPricingRules.recordcount EQ 0>
			<table WIDTH="800">
				<TR>
					<TD><div ALIGN="center" STYLE="color: red; font-size:15px;font-weight:bold;">NO RULE DEFINED</div></TD>
				</TR>
			</table>
			
		<CFELSE>
			<cfif appSettings.getPaymentCycleAtDiscountType()>
			<TABLE WIDTH="600" CELLPADDING="3" CELLSPACING="0">
				<tr>
				<B>Payment Cycle</B>:
				<cf_payment_cycle_selection
					Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
					Program_ID = "#FORM.Contract_Main_ID#"
					discount_Type_ID = "5"
					Selected_Payment_Cycle_ID = ""
					Action = "display"
					>
				</tr>
			</TABLE>
			</cfif>
			<TABLE CLASS="Maintable" WIDTH="600" CELLPADDING="3" CELLSPACING="0">
				<!--- TABLE HEADERS --->
				<TR BGCOLOR="#FFCE84" VALIGN="bottom">
					<TD ID="header"><B>Rule Name</B></TD>
					<TD>&nbsp;</TD>
				</TR>
				
				<!--- TABLE DATA QUERY --->
				<CFOUTPUT QUERY="getPricingRules">
					<CF_Cryp type="en" key="#request.key#" string="#getPricingRules.Program_Formula_Pricing_Rule_Mapped_ID#">
					<TR <!--- BGCOLOR="#IIf(i Mod 2, DE('ffffff'), DE('C6FFC6'))#" ---> VALIGN="top">
						<TD ALIGN="left">#Rule_Name#</TD>
						<TD><!--- <A STYLE="cursor:hand;" ONCLICK="showRuleSummary('#cryp.value#')"><span STYLE="color: red; fon-weight: bold;">[</span>summary<span STYLE="color: red; font-weight: bold;">]</span> ---></A>&nbsp;&nbsp;<A ONCLICK="editRule('#cryp.value#')" STYLE="cursor:hand;"><span STYLE="color: red; fon-weight: bold;">[</span>edit<span STYLE="color: red; font-weight: bold;">]</span></A>&nbsp;&nbsp;<A STYLE="cursor:hand;" ONCLICK="deleteRule('#cryp.value#')"><span STYLE="color: red; fon-weight: bold;">[</span>delete<span STYLE="color: red; font-weight: bold;">]</span></A></TD>
					</TR>
				</CFOUTPUT>
			</TABLE>		
		</CFIF>
</CFIF>
<script>
	function showRuleSummary(Rule_ID){
		document.all.Rule_ID.value = Rule_ID;
		document.all.rule_summary.submit();
	}
	function editRule(Rule_ID){
		document.all.Rule_ID.value = Rule_ID;
		document.all.Edit.value = 1;
		document.all.rule_summary.submit();
	}

	function deleteRule(Rule_ID){
		if(confirm("Are you sure you want to delete this rule?")){
			document.all.Delete_Rule_ID.value = Rule_ID;
			document.all.DeleteRule.submit();
		}
	}	
</script>
<cfif application.programlayout EQ 1></div></cfif>
<CFOUTPUT>
	<FORM ACTION="Formula_Pricing_Index_Rule_Summary.cfm" METHOD="post" NAME="rule_summary" ID="rule_summary">
		<INPUT  TYPE="Hidden" NAME="Rule_ID" VALUE="">
		<INPUT  TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
		<INPUT  TYPE="Hidden" NAME="Edit" VALUE="0">
	</FORM>

	<FORM ACTION="Formula_Pricing_Index_Rule_Deleted_Action.cfm" METHOD="post" NAME="DeleteRule" ID="DeleteRule">
		<INPUT  TYPE="Hidden" NAME="Delete_Rule_ID" VALUE="">
		<INPUT  TYPE="Hidden" NAME="CID" VALUE="#URL.CID#">
	</FORM>

</CFOUTPUT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
