<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "lump_sums"> 
<CFSET URL.Contract_Main_ID = CSL_Contract_Main_ID>
<CFSET FORM.Contract_Main_ID = CSL_Contract_Main_ID>
<cfparam name="donotallowaddproductsDE" default = "0">
<cfparam name="form.deletedateexclusions" default = "0">

<cfparam name="URL.Program_Lump_Sum_ID" 	default="">
<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager") />

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Select #Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</title>
</head>

<body>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<blockquote>
<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddproductsDE = 1>
</CFIF>
</cfif>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:431px; width:200px; z-index:1; left: 140px; top: 10px;">
</cfif>
<cfinclude template="minimal_contract_info.cfm">
<!------ Content starts here ----->
<form name="frmLumpSumDistributors" action="select_lumpsum_distributors_action.cfm" method="post">

<!------ Get the distributors in the program ----->
<cfset getDistributors  = LumpSumManager.getLumpSumDistributors(CSL_Contract_Main_ID, URL.Program_Lump_Sum_ID)>

<!------ Display the distributors in the program ----->
<TABLE CLASS="Maintable" WIDTH="800" CELLPADDING="3" CELLSPACING="0" BORDER="0">
	<caption align="left" style="font-weight:bold;font-size:14px;">Select #application.returned_customer_setting.distributor_label_plural#</caption>
	<!--- TABLE HEADERS --->
	<TR ID="header" BGCOLOR="##ffce84">
		<TD>&nbsp;</TD>
		<TD align="left" ID="header" WIDTH=""><B>#application.returned_customer_setting.distributor_label_singular# Name / #application.returned_customer_setting.shard_ship_to_label#</B></TD>
		<TD ID="header" WIDTH="20%"><B>Address</B></TD>
	</TR>			
	<CFLOOP QUERY="getDistributors">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD><span ID="chkBoxCol">
			<input TYPE="Checkbox" NAME="Lumpsum_Distributors" value="#BSA_Foodservice_Customers_ID#" <cfif IsSelected>checked</cfif>>
			</span></TD>
			<TD style="cursor:pointer;" onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#Name#<BR>#Shr_Ship_To#&nbsp;</TD>
			<TD style="cursor:pointer;" onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;">#Address_1#<BR>#City#,#State# #ZipCode#&nbsp;</TD>
		</TR>
	</CFLOOP>
</TABLE>
<input type="Hidden" name="Program_Lump_Sum_ID" value="#URL.Program_Lump_Sum_ID#">
<input type="Hidden" name="Program_ID" value="#CSL_Contract_Main_ID#">
<input type="Hidden" name="CID" value="#URL.CID#">
<input TYPE="hidden" NAME="deletedateexclusions" value="0">
<center>
<cf_smallLink
	url="##"
	title="save"
	parameters="STYLE=""cursor:pointer;"" ONCLICK=""javaScript:savelumpdistributors();"""
	>
</center>
</form>
<script>
function savelumpdistributors() {
<cfif donotallowaddproductsDE EQ 1>
if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
	{document.all.deletedateexclusions.value = 1;</cfif>
document.frmLumpSumDistributors.submit();
return false;
	<cfif donotallowaddproductsDE EQ 1>}</cfif>
}
</script>
<!------ Content ends here ----->
<cfif application.programlayout EQ 1>
</div>
</cfif>
</blockquote>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</body>
</html>
</cfoutput>