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
<cfset ContinueApproval = 1>
<cfset ForceContinueLinkForDistributors = 1>
<cfset AnyDistributorsWithPrograms = 0>
<!--- Get all the available distributors from the current program --->
<cfset GetDistributors = PullbackManager.GetDistributorlist(CSL_Contract_Main_ID,CSLGetContractInfo.applied_pullbacks,form.sql_Sort_By,FORM.sort_order)>
<!--- Get all the available prodcuts from the current program and this list is passed as a form variable, if the user clicks save on this page. We loop over this product list to make entries into the pullback_details table. --->
<cfset GetProducts = PullbackManager.GetProductlist(CSL_Contract_Main_ID)>

<cfset distributorlist = valuelist(GetDistributors.BSA_Foodservice_Customers_id)>
<cfset productlist = valuelist(GetProducts.BSA_Foodservice_items_master_id)>

<FORM ACTION="pullbacks_save.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="SavePullbacks" STYLE="DISPLAY:INLINE">
 <table width="780" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center">
 <tr bgcolor="C6FFC6">
 <TD id="header" style="font-size: 12px;" valign="top"> <strong><A HREF="##" OnClick="javaScript: setSortHref('DN');"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "DN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <td id="header" style="font-size: 12px;" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('SH');"><strong>Shipto</strong></A><SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "SH"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN></TD>
 <TD id="header" style="font-size: 12px;" valign="top">&nbsp;</td>
 </TR>
<!---  <cfif CSLGetContractInfo.applied_pullbacks NEQ 1>
 <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> are not applied yet. Click Save to apply <cfoutput>#appsettings.getPullbackLabel()#</cfoutput>.
 </cfif> --->
 <cfif GetDistributors.recordcount GT 0>
 <cfoutput query="GetDistributors" group="BSA_Foodservice_Customers_id">
 
<!---  For a distributor check if any active Dis Corp or Local Deals to pullback from. --->
<cfset checkDisCorpPorgramsCount = PullbackManager.checkDisCorpPorgramsCount(GetDistributors.BSA_Foodservice_Customers_id, CSLGetContractInfo.contract_end_date, CSLGetContractInfo.contract_start_date, CSLGetContractInfo.contract_main_id)>
<cfif checkDisCorpPorgramsCount GT 0>
	<cfset AnyDistributorsWithPrograms = 1>
</cfif>
<cfif checkDisCorpPorgramsCount GT 0 AND pullback_details_customer_id EQ "">
	<!--- if the current customer do programs and pullback has not been applied yet for this customer then do not let user continue --->
	<cfset ForceContinueLinkForDistributors = 0>
</cfif>
<!--- If no programs found, disable pullback(yes or no) option and just give the text box to entera  default value for any future deals that might get created. --->
 <TR style="height: 20px;">
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdistprograms('#GetDistributors.BSA_Foodservice_Customers_id#');">#name#</A>
<cfif checkDisCorpPorgramsCount EQ 0>
<CFMODULE template="/CustomTags/SmallHelp.cfm"
					width = "180"
					height = "50"
					imgPath="/Images/Asterix.gif"
					imgWidth="10"
					imgHeight="10"
					dropdownCheck=0
					>
No active programs found for this #application.returned_customer_setting.distributor_label_singular#.
</CFMODULE>
</cfif></TD>
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdistprograms('#GetDistributors.BSA_Foodservice_Customers_id#');">#shr_ship_to#</A></TD>
 </TR>
 </cfoutput>
 <cfelse>
 <TR>
 <TD><strong>No <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> found.</strong></TD>
 </TR>
  </cfif>
</TABLE>
 <cfif GetDistributors.recordcount GT 0>
<TABLE CELLPADDING="0" CELLSPACING="0" align="center" width="780" >
 <tr>
 <td>&nbsp;</td>
 </tr>
 <tr>
		<!--- <td align="left" width="20">
		<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"submitForm1(document.SavePullbacks);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save <cfoutput>#appsettings.getPullbackLabel()#</cfoutput>"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td> --->
<!--- the same page is used in approval to, the users are forced to go through the pullback rules. If the pullbacks are applied partially(not every distributor has a pullback value), the users are forced to click save. Otherwise we provide both Save and Continue approval buttons. --->
<!--- <cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 0 and 
GetSettings. --->

<td align="left" width="20">
		<CF_button
			button_name		=	""
			button_caption	=	"Continue to program summary"
			button_action	=	"basicInformation();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Continue to program summary"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>

<CFIF GetSettings.Discount_Lump_Sums EQ 1>
	<cfif GetSettings.Discount_Lump_Sums_Item_Mandated EQ 0>
		<cfset ContinueApproval = 1>
	</cfif>
	<CFIF LumpStatus.Recordcount GT 0 and  GetSettings.Discount_Lump_Sums_Item_Mandated EQ 1>
		<cfset ContinueApproval = 0>
	</CFIF>
</CFIF>

<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
	<CFIF FixedPricesStatus.Recordcount GT 0>
		<cfset ContinueApproval = 0>
	</CFIF>
</CFIF>

<CFIF GetSettings.Discount_Rebates EQ 1>
	<CFIF RebateStatus.Recordcount GT 0>
		<cfset ContinueApproval = 0>
	</CFIF>
</CFIF>

<CFIF GetSettings.Discount_Growth EQ 1>
	<CFIF GrowthStatus.Recordcount GT 0>
		<cfset ContinueApproval = 0>
	</CFIF>
</CFIF>

<!--- 
Either all the distributors do not have any programs or no products added (checkifproductsadded EQ 0 OR AnyDistributorsWithPrograms EQ 0)
ForceContinueLinkForDistributors will be 1 if either all distributors do not have programs or those distributprs who have programs will have pullbacks already applied
--->
<CFIF ForceContinueLinkForDistributors EQ 1 AND (checkifproductsadded EQ 0 OR AnyDistributorsWithPrograms EQ 0)>
		<cfset ContinueApproval = 1>
</CFIF>

 <cfif (checkifproductsadded EQ 0 and checkifdistributorsadded EQ 0 and url.margincheck EQ 1 and checkifproductsremoved EQ 0 and checkifdistributorsremoved EQ 0) OR (ContinueApproval EQ 1 and url.margincheck EQ 1)>
 	<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Continue Approval"
			button_action	=	"continueapproval(document.SavePullbacks);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Continue Approval"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
	</td>
 </cfif>
 <cfif form.command EQ "edit" and url.margincheck EQ 0>
  	<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Back"
			button_action	=	"gobacktoview();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Go Back"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
	</td>
 </cfif>
 </tr>
</table>
</cfif>
<input type="hidden" name="pagetype" value="D">
<input type="hidden" name="contract_main_id" value="<cfoutput>#CSL_Contract_Main_ID#</cfoutput>">
<input type="hidden" name="distributorlist" value="<cfoutput>#distributorlist#</cfoutput>">
<input type="hidden" name="productlist" value="<cfoutput>#productlist#</cfoutput>">
<input type="hidden" name="contract_end_date" value="<cfoutput>#CSLGetContractInfo.contract_end_date#</cfoutput>">
<input type="hidden" name="contract_start_date" value="<cfoutput>#CSLGetContractInfo.contract_start_date#</cfoutput>">
<input type="hidden" name="pullback_template_type" value="<cfoutput>#getsettings.pullback_template_type#</cfoutput>">
</FORM>

<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="DistPrograms" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="P">
<input type="hidden" name="distributorId" value="">
<input type="hidden" name="applied_pullbacks" value="<cfoutput>#form.applied_pullbacks#</cfoutput>">
<input type="hidden" name="command" value="edit">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
</FORM>
<script>
 function submitForm1(thisForm)
	{
			<cfif listlen(productlist) GT 0>
			thisForm.submit();
			return false;
			<cfelse>
			alert("Please select products for the discount types before you save");
			</cfif>
	}
	
function getdistprograms(DistId)
{
document.DistPrograms.sort_by.value = 'CN';
document.DistPrograms.sort_Order.value = 'DESC';
document.DistPrograms.distributorId.value = DistId;
document.DistPrograms.submit();
}
function submitdistdetails(distid)
{
	
	NewWindow('view_pullback_distributor_program_details.cfm?contract_main_id=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>&display=1&distributor_id='+distid,'pullbackdetails','870','620','Yes', 'No');
}
function basicInformation()
{
location.href ='/Common_Files/contracts/contract_edit_menu.cfm?CID=<cfoutput>#URL.CID#</cfoutput>';
}
function continueapproval()
{
location.href = '/Common_Files/Contracts/duplicate_check.cfm?CID=<cfoutput>#URL.CID#</cfoutput>';
}
function gobacktoview()
{
location.href = 'pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>';
}
</script>