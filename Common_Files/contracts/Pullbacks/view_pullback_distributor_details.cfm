<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<cfparam name="distributorlist" default="">
<cfparam name="productlist" default="">
<cfparam name="FORM.sort_by" 	default="DN">
<cfparam name="form.sql_Sort_By" default="name">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="DN">
		<CFSET form.sql_Sort_By="name">
	</CFCASE>
	<CFCASE value="SH">
		<CFSET form.sql_Sort_By="shr_ship_to">
	</CFCASE>	
</CFSWITCH>

<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<cfset GetDistributors = PullbackManager.GetDistributorlist(CSL_Contract_Main_ID,CSLGetContractInfo.applied_pullbacks,form.sql_Sort_By,FORM.sort_order)>

<cfset distributorlist = valuelist(GetDistributors.BSA_Foodservice_Customers_id)>

 <table width="780" class="maintable" CELLPADDING="0" CELLSPACING="0">
 <tr  bgcolor="C6FFC6">
<TD id="header" style="font-size: 12px;"> <strong><A HREF="##" OnClick="javaScript: setSortHref('DN');"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "DN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <td id="header" style="font-size: 12px;"><A HREF="##" OnClick="javaScript: setSortHref('SH');"><strong>Shipto</strong></A><SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "SH"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN></TD>
 <TD id="header" style="font-size: 12px;"><strong><cfoutput>#appsettings.getPullbackLabel()#</cfoutput></strong></TD>
 <TD id="header" style="font-size: 12px;"><strong><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate</strong></TD>
 </TR>
 <cfif GetDistributors.recordcount GT 0>
 <cfoutput query="GetDistributors" group="BSA_Foodservice_Customers_id">
 <TR height="20">
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdistprograms('#GetDistributors.BSA_Foodservice_Customers_id#');">#name#</A></TD>
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdistprograms('#GetDistributors.BSA_Foodservice_Customers_id#');">#shr_ship_to#</A></TD>
 <td><cfif GetDistributors.pullback_value NEQ 0>Yes<cfelse>No</cfif></td>
<td>#GetDistributors.pullback_value#%</td>
 </TR>
 </cfoutput>
 <cfelse>
 <TR>
 <TD><strong>No <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> found.</strong></TD>
 </TR>
  </cfif>
</TABLE>
<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>" METHOD="post" NAME="DistPrograms" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="D">
<input type="hidden" name="applied_pullbacks" value="<cfoutput>#form.applied_pullbacks#</cfoutput>">
<input type="hidden" name="command" value="view">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
</FORM>
<script>
function getdistprograms(DistId)
{
NewWindow('/common_files/contracts/pullbacks/view_pullback_distributor_program_details.cfm?<cfoutput>contract_main_id=#CSL_Contract_Main_ID#</cfoutput>&distributor_id='+DistId,'pullbackdetails','800','620','Yes', 'No');
}
</script>