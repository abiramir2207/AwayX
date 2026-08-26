<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->
<!---   Need to add user/company_main constriction to data    --->
<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Code used to measure the time required to run a block of code --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET begin=gettickcount()>
<!--- <DIV STYLE="background-color: Yellow; font-weight: bold;"><B>Start: <CFOUTPUT>#begin#</CFOUTPUT></B></DIV> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET PAGE_TITLE="Create New Contract - 4 of 6">
<CFSET GROUP="HQ #Application.RebateLabel#s">

<CFPARAM NAME="URL.HQR_ID" DEFAULT="">
<CFPARAM NAME="URL.RO" DEFAULT="0">

<CFPARAM name="FORM.button_caption"					default="continue">

<CFIF len(trim(URL.HQR_ID)) GT 0 AND URL.RO EQ 1>
		<CF_CRYP type="de" string="#URL.HQR_ID#" key="#request.key#">
		<cfquery name="CheckForExistingDistributors" datasource="#application.datasource#">
			SELECT 	Distributor_IDs
			FROM HQ_Rebate
			WHERE HQ_Rebate_ID = '#cryp.value#'			
		</cfquery>		
		
		<cfquery name="getTheseLambRequirements" datasource="#application.datasource#">
			SELECT DISTINCT *
			FROM lamb_requirements
			WHERE HQ_Rebate_ID = #cryp.value#
		</cfquery>
		
		<cfset HQRC_ID = #ValueList(getTheseLambRequirements.HQ_Rebate_ID)#>
		
	<CFSET FORM.button_caption = "save">

	<CFIF listfind(CheckForExistingDistributors.Distributor_IDs, 0, ",") EQ 0>
		<CFSET FORM.FinalItemList = valuelist(CheckForExistingDistributors.Distributor_IDs)>	
	</CFIF>

	<CFSET FORM.HQR_ID = cryp.value>
</CFIF>

<cfquery name="getContractTypes" datasource="#application.datasource#">
	Select DISTINCT Created_Type 
	From Program_Control_Panel_Options 
	Where Generic_Type = 'Operator-Deviated Pricing'
</cfquery>

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<body background="/images/background_gray_lines.gif"
      bgcolor="#FFFFFF"
      text="#000000"
      link="#0000FF"
      vlink="#0000FF"
      alink="#FF0000"
      leftmargin="0"
      topmargin="0">

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

<CFIF len(URL.HQR_ID) EQ 0>
	<CFSET temp = 0>
<CFELSE>
	<CFSEt temp = cryp.value>
</CFIF>

<CFSET HQRSL_HQ_Rebate_ID = temp>
<CFSET HQRSL_CallingPageCode = "lw"> 
<CFINCLUDE TEMPLATE="hq_rebate_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>
<CFSET helpfilenumber=5>
<cfinclude template="minimal_hq_rebate_info.cfm">

<FORM ACTION="select_lamb_weston_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<CFQUERY NAME="GetDistInfo" datasource="#application.datasource#">
	SELECT *
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID IN(<CFIF len(FORM.FinalItemList) EQ 0 OR FORM.FinalItemList EQ "ALL">0<CFELSE>#FORM.FinalItemList#</CFIF>)
</CFQUERY>

<CF_CRYP type="de" string="#URL.HQR_ID#" key="#request.key#" return="gcpvCryp">
<cfset b = #FORM.FINALITEMLIST#>
	<FIELDSET STYLE="padding:8px; width: 95%; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></LEGEND>
			<CFIF GetDistInfo.recordcount GT 0>
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
					<TR><cfoutput query="GetDistInfo">
						
							<TD NOWRAP BGCOLOR="eeeeee" valign="top">#GetDistInfo.BSA_Foodservice_Customers_ID#: #GetDistInfo.Name#<br>
									<cfquery name="ExistingTradeProgramsForTheseDistributors" datasource="#application.datasource#">
										SELECT 	
											HQ_Rebate.HQ_Rebate_Title,
											HQ_Rebate.Distributor_IDs, 
											HQ_Rebate.ProgramType,
											HQ_Rebate.HQ_Rebate_ID
										FROM HQ_Rebate, Program_Control_Panel_Options
										WHERE Program_Control_Panel_Options.Created_Type = HQ_Rebate.ProgramType 
										AND HQ_Rebate_Start_Date < getDate()
										AND HQ_Rebate_End_Date > getDate()
										AND HQ_Rebate.Deleted = 0
										AND (HQ_Rebate.Distributor_IDs LIKE '#GetDistInfo.BSA_Foodservice_Customers_ID#%' 
										OR HQ_Rebate.Distributor_IDs LIKE '%#GetDistInfo.BSA_Foodservice_Customers_ID#'
										OR HQ_Rebate.Distributor_IDs LIKE '%#GetDistInfo.BSA_Foodservice_Customers_ID#%'
										OR HQ_Rebate.Distributor_IDs LIKE '#GetDistInfo.BSA_Foodservice_Customers_ID#')
										AND HQ_Rebate.HQ_Rebate_ID <> #HQRSL_HQ_Rebate_ID#
										UNION
										SELECT 	
											Contract_Main.Contract_Title,
											Contract_Main.Distributor_IDs, 
											Contract_Main.Created_Type,
											Contract_Main.Contract_Main_ID
										FROM Contract_Main, Program_Control_Panel_Options
										WHERE Program_Control_Panel_Options.Created_Type = Contract_Main.Created_Type
										AND Contract_Start_Date < getDate()
										AND Contract_End_Date > getDate()
										AND Contract_Main.Deleted = 0
										AND (Contract_Main.Distributor_IDs LIKE '#GetDistInfo.BSA_Foodservice_Customers_ID#%' 
										OR Contract_Main.Distributor_IDs LIKE '%#GetDistInfo.BSA_Foodservice_Customers_ID#'
										OR Contract_Main.Distributor_IDs LIKE '%#GetDistInfo.BSA_Foodservice_Customers_ID#%'
										OR Contract_Main.Distributor_IDs LIKE '#GetDistInfo.BSA_Foodservice_Customers_ID#')
									</cfquery> 
									<cfif #ExistingTradeProgramsForTheseDistributors.RecordCount# neq 0>
									&nbsp;&nbsp;&nbsp;<strong><em>Include These Programs?</em></strong><br>
									</cfif>
										<cfset c = #GetDistInfo.BSA_Foodservice_Customers_ID#>
									<cfloop query="ExistingTradeProgramsForTheseDistributors">
									<cfif HQRC_ID neq ''>
				&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox"
									       name="Incl_Program_#c#_#HQ_Rebate_ID#"
									       id="Incl_Program_#c#_#HQ_Rebate_ID#"
									       value="Incl_Program_#HQ_Rebate_ID#"
										    <cfif #ListContains(ValueList(getTheseLambRequirements.Assoc_Program_ID), HQ_Rebate_ID, ",")# 
											   AND #ListContains(ValueList(getTheseLambRequirements.Assoc_Dist_ID), c, ",")#>
											   	checked
											</cfif>
										>
									<cfelse>
				&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox"
									       name="Incl_Program_#c#_#HQ_Rebate_ID#"
									       id="Incl_Program_#c#_#HQ_Rebate_ID#"
									       value="Incl_Program_#HQ_Rebate_ID#">
									</cfif>
											   <strong>#ExistingTradeProgramsForTheseDistributors.HQ_Rebate_ID#</strong> 
											   -<em>#ExistingTradeProgramsForTheseDistributors.HQ_Rebate_Title#</em>
											   <em>#ExistingTradeProgramsForTheseDistributors.ProgramType#</em><br>
										
										<cfif #ExistingTradeProgramsForTheseDistributors.RecordCount# gt 0> 
											<cfset a = #ExistingTradeProgramsForTheseDistributors.HQ_Rebate_ID#>
										<cfelse>
											<cfset a = 0>
										</cfif>
										
										<CF_List_Compare 
											List1 = #ValueList(ExistingTradeProgramsForTheseDistributors.ProgramType, ",")# 
											List2 = #ValueList(getContractTypes.Created_Type, ",")#>	
										<!--- 1; #ValueList(ExistingTradeProgramsForTheseDistributors.ProgramType, ",")#<br><br>
										2; #ValueList(getContractTypes.Created_Type, ",")#<br> --->
										<cfif ListFindNoCase(#LC_Common#, '#ExistingTradeProgramsForTheseDistributors.ProgramType#', ",")>
											<cfinclude template="/common_files/contracts/contract_products_rebate_entry_lw.cfm">
										<cfelse>
											<cfinclude template="created_components_view_insert_lw.cfm">
										</cfif>
									</cfloop>
							</TD>
		 				<CFIF GetDistInfo.currentrow mod 1><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
					</TR>
					 <tr>	<td></td></tr> 
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ "ALL">ALL <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput><CFELSE>NONE</CFIF>
			</CFIF>
			<BR>
	</FIELDSET>
<cfoutput>
<input type="hidden" name="HQR_ID" id="HQR_ID" value="#URL.HQR_ID#">
<input type="hidden" name="updates" id="updates" value="">
</cfoutput>

<BR>

<table>
	<tr>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	" save "
				button_action	=	"javascript: MyForm.submit();"
				button_type		=	"link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
</FORM>
</BLOCKQUOTE></BLOCKQUOTE>

</body>
</html>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">

<cfoutput>	
	<script>
		function computeAdjDiff(discRate, origRate, adj) 
		{	
			var adjRate = origRate - discRate;
			adj.value = adjRate;
		}
	</script>
</cfoutput>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This calculates and displays the total time spent in this block of code --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET end=gettickcount()>
<!--- <DIV STYLE="background-color: Yellow; font-weight: bold;"><B>End: <CFOUTPUT>#end#</CFOUTPUT></B></DIV> --->
<cfset x = (#end# - #begin#)/1000>
<DIV STYLE="background-color: Yellow; font-weight: bold;"><B>Time to Run: <CFOUTPUT>#x# seconds</CFOUTPUT></B></DIV>