<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<html>
<head>
	<title>Apply <cfoutput>#appsettings.getPullbackLabel()#</cfoutput></title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/format_functions.js, /Script/javascript/dhtml.js"/>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<cfparam name="url.BB_ID" default="">

<cfinclude template="/get_access_profile.cfm">

<cfif url.BB_ID NEQ "">

<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>

<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<!--- Get the already applied pullback amount to compare against the profiles threshold  --->
<cfset qGetPullbackAppliedInfo = PullbackManager.getPullbackAppliedInfo(url.BB_ID) />
<cfset alreadyAppliedPullbackAmount = 0 />
<cfif isNumeric(qGetPullbackAppliedInfo.Pullback_applied_Amount)>
	<cfset alreadyAppliedPullbackAmount = qGetPullbackAppliedInfo.Pullback_applied_Amount />
</cfif>

<!--- Get all the Opr or Local Distributor billbacks that are in the pullback Log table for this BB contract number - that match the distributor and products on this BB --->
<cfset GetBillbackstoApply = PullbackManager.GetBillbackstoApply(url.BB_ID)>

<!--- check if the current BB has products added in growth and get aggregate values for growth --->
<cfset checkifBBhasGrowth = PullbackManager.checkifBBhasGrowth(url.BB_Id,0)>

<!--- If the above query returned any results, added the result set to getbillbackstoapply query  --->
<cfif checkifBBhasGrowth.recordcount GT 0>
<cfloop query="checkifBBhasGrowth">
	<cfset temp = QueryAddRow(GetBillbackstoApply)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_billback_id", checkifBBhasGrowth.pullback_billback_id )>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_from_program_number", checkifBBhasGrowth.pullback_from_program_number)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "BB_title",checkifBBhasGrowth.BB_title)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_reference",checkifBBhasGrowth.bb_reference )>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_code",checkifBBhasGrowth.bb_code )>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_start_date", checkifBBhasGrowth.bb_start_date)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_end_date",checkifBBhasGrowth.bb_end_date )>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "contract_number",checkifBBhasGrowth.contract_number )>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "revision_version", checkifBBhasGrowth.revision_version)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "discount_type_desc", checkifBBhasGrowth.discount_type_desc)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "discount_type_id", checkifBBhasGrowth.discount_type_id)>
	<cfset Temp = QuerySetCell(GetBillbackstoApply, "Product_BB_Volume_LB", checkifBBhasGrowth.Volume_LB)>
</cfloop>
</cfif>

<cfquery name="SortBillbackstoApply" dbtype="query">
select * 
from GetBillbackstoApply
order by bb_end_date desc, pullback_billback_id,discount_type_id
</cfquery>

<FORM ACTION="pullbacksapply_action.cfm" METHOD="post" NAME="ApplyPullbacksAction" STYLE="DISPLAY:INLINE">
<br>
 <table width="100%" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center" border="0">
 <cfoutput>
 <caption align="right" style="font-size:12px;font-weight:bold;">Already applied #appsettings.getPullbackLabelLower()# amount: #DollarFormat(alreadyAppliedPullbackAmount)# </caption>
 </cfoutput>
 <tr  bgcolor="ffcc33">
 <td>&nbsp;</td>
 <TD id="header" valign="top"><input name="pullback_check_all" type="checkbox" onclick="selectall(this);" checked><strong>Billback Id</strong>
</td>
 <TD id="header" valign="top"> <strong>Reference Id</strong>
</td>
 <TD id="header" valign="top"> <strong>Title</strong></td>
 <TD id="header" valign="top"> <strong>Start Date</strong></TD>
 <TD id="header" valign="top"> <strong>End Date</strong></TD>
 </TR>
 <cfif GetBillbackstoApply.recordcount GT 0>
 <cfoutput query="SortBillbackstoApply" group="pullback_billback_id">
<cfset strPullbackBillbackID = replace(pullback_billback_id,'-','_','ALL') />
 <TR bgcolor="C6FFC6">
 <TD>&nbsp;</TD>
 <TD valign="top" style="font-size: 12px;"><span ID="checkAllPullbacks"><input name="pullback_check_all_bb" type="checkbox" onClick="selectall(this,'#strPullbackBillbackID#');" checked></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#BB_Code#</td>
 <TD valign="top" style="font-size: 12px;">#BB_reference#</td>
 <TD valign="top" style="font-size: 12px;">#BB_title#</td>
 <TD valign="top" style="font-size: 12px;">#dateformat(BB_Start_Date,"mm/dd/yyyy")#</TD>
 <TD valign="top" style="font-size: 12px;">#dateformat(BB_End_Date,"mm/dd/yyyy")#</TD>
 </TR>
 <TR>
 <TD colspan="100%" style="border:none;">
 <table width="98%" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center">
 <TR bgcolor="FFE083">
<td>&nbsp;</td>
<TD valign="top"> <strong>Contract Number<br>#application.returned_customer_setting.Shard_Ship_To_Label#</strong></td>
<TD valign="top"> <strong>Item<br>Description</strong></td>
<TD valign="top"> <strong>Discount<br>Type</strong></td>
<TD valign="top"> <strong>Vol. CS</strong></td>
<TD valign="top"> <strong>#appsettings.getPullbackLabel()#<br> %</strong></td>
<TD valign="top"> <strong>Rate/CS</strong></td>
 <!--- D35392: GM Pullback Log entries --->
		<cfif appSettings.getBudgetsFunctionalityOn()>
		<TD valign="top"> <strong>Budget <br>#appsettings.getPullbackLabel()#</strong></TD>
		</cfif>
 <!--- D35392: GM Pullback Log entries --->
<TD valign="top"> <strong>#appsettings.getPullbackLabel()# <br>Amt.</strong></td>
 </TR>
 <cfoutput>
<!---  If the discount type is either rebate or fixed loop over each product --->
 <cfif discount_type_id NEQ 4>
<cfset uniqueKey = "#pullback_billback_id#_#discount_type_id#_#product_id#_#customer_id#" />
 <TR>
 <TD valign="top"><span ID="checkAllPullbacks#strPullbackBillbackID#"><span ID="checkAllPullbacks"><input type="checkbox" name="pullback_billback_ids" checked value="#uniqueKey#" pullbackAmount="#pullback_amount#"></span></span></TD>
 <TD>#application.oBBReportGet.getProgramLink("#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif>",Contract_Main_ID)#
	<br>#name#<br>(#shr_ship_to#)
</TD>
 <TD width="200" valign="top">#Item#<br>#Description#</TD>
  <TD>#Discount_type_desc#</TD>
<cfif Product_BB_Volume_LB neq "">
	<cfset Product_BB_Volume_CS = Product_BB_Volume_LB / net_weight />
<cfelse>
	<cfset Product_BB_Volume_CS = Product_BB_Volume_LB />
</cfif>
 <TD>#numberformat(Product_BB_Volume_CS,'_,___,___,___,___')#</TD>
 <TD>#pullback_percent#</TD>
<cfif paid_rate neq "">
	<cfset paid_rate_cs = paid_rate * net_weight />
<cfelse>
	<cfset paid_rate_cs = paid_rate />
</cfif>
 <TD>#DollarFormat(paid_rate_cs)#</TD>
 <!--- D35392: GM Pullback Log entries --->
		<cfif appSettings.getBudgetsFunctionalityOn()>
		<TD>#DollarFormat(Budget_Recapture_Amount)#</TD>
		</cfif>
 <!--- D35392: GM Pullback Log entries --->
 <TD>#DollarFormat(pullback_amount)#</TD>
<input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_budget" value="#Budget_Recapture_Amount#">
<input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_amount" value="#pullback_amount#">
<input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_rate" value="#paid_rate#">
<input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_volume" value="#Product_BB_Volume_LB#">
 </TR>
 <cfelse>
<!---  if the discount type is 4 execute the growth procedure twice. once with the invoice volume for the current products in the BB and again with Invoice volume - Pullback log volume for the products added in the BB and store the results in different tables --->
 <cfset PullbackManager.ExecuteGrowthSP(url.BB_ID,pullback_billback_id)> 
<!---  Now get the difference between the total expected amount and pullback volume subtracted expected amount - this gives the pullback amount for the whole growth discount type --->
 <cfset GrowthPullbackAmount = PullbackManager.GrowthPullbackAmount(url.BB_ID,pullback_billback_id)>
 <TR bgcolor="ffff99"><TD>
 <span ID="checkAllPullbacks"><input type="checkbox" name="pullback_billback_growth_ids" checked value="#pullback_billback_id#" pullbackAmount="#GrowthPullbackAmount#"></span></TD>
<input type="hidden" name="growthamount_#replace(pullback_billback_id,'-','_','ALL')#" value="#GrowthPullbackAmount#">
<input type="hidden" name="growthvolume_#replace(pullback_billback_id,'-','_','ALL')#" value="#Product_BB_Volume_LB#">

<TD>#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></TD>
<TD width="200"><A HREF="##" onClick="javaScript: submitfordetails('#pullback_billback_id#','#url.BB_ID#','#GrowthPullbackAmount#','#Product_BB_Volume_LB#');" TITLE="View #appsettings.getPullbackLabel()# Details">View Details</A></TD>
<TD>Growth</TD>
<TD>#numberformat(Product_BB_Volume_LB,'_,___,___,___,___')#</TD>
<TD>&nbsp;</TD>
<TD>&nbsp;</TD>
<TD>#dollarformat(GrowthPullbackAmount)#</TD>
</TR>
 </cfif>
 </cfoutput>
 </TABLE>
 </TD>
 </TR>
 </cfoutput>
 <TR>
<input type="hidden" name="Dis_BB_Id" value="<cfoutput>#url.BB_ID#</cfoutput>">

<cfelse>
<TR><TD colspan="100%">No Billbacks available to apply.</TD></TR>
</TABLE>
</form>
</cfif>
<cfif GetBillbackstoApply.recordcount GT 0>
 <table align="center">
 <tr>
 <td>&nbsp;</td>
 </tr>
 <tr align="left">
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"apply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
			button_action	=	"ApplyPullbacks();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"close"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Close Window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
</tr>
</table>
</cfif>
<cfelse>
 <TR>
 <TD><strong>Invalid Billback Number</strong></TD>
 </TR>
</cfif>
<script>
function ApplyPullbacks()
{
	var obj = window.checkAllPullbacks;
	var pullbackselected = false;
	var totalAmountSelected = 0, currentAmount;
	var bCanApprovePullbackAmount = 0;
	<cfoutput>
	var maxApplyPullbackAmount = "#Get_Profile_Settings.BB_Apply_Pullback_Amount#";
	totalAmountSelected = #alreadyAppliedPullbackAmount#;	
	</cfoutput>	
	if(obj != null)
	{
		if(obj.length)
		{
			for(var x=0; x<obj.length;x++)
			{
				box = getFirstChild(obj[x])
				if(box.checked)
				{
					pullbackselected = true;
					currentAmount = parseFloat(box.pullbackAmount);
					if(isNaN(currentAmount)) currentAmount = 0;
					totalAmountSelected = totalAmountSelected + currentAmount;
				}
			}
		}
		else
		{
			box = getFirstChild(obj)
			if(box.checked)
			{
				pullbackselected = true;
				currentAmount = parseFloat(box.pullbackAmount);
				if(isNaN(currentAmount)) currentAmount = 0;
				totalAmountSelected = totalAmountSelected + currentAmount;
			}
		}
	}
	
	if(maxApplyPullbackAmount == "*")
	{
		bCanApprovePullbackAmount = 1;
	}
	else
	{
		maxApplyPullbackAmount = parseFloat(maxApplyPullbackAmount);
		if(isNaN(maxApplyPullbackAmount)) maxApplyPullbackAmount = 0;
		if(totalAmountSelected <= maxApplyPullbackAmount) bCanApprovePullbackAmount = 1;
	}
	
	if (pullbackselected == false)
	{ 
		alert("Please select atleast one pullback to apply"); 
	}
	else
	{
		if(bCanApprovePullbackAmount)
		{
			document.all.ApplyPullbacksAction.submit();
		}
		else
		{
			<cfoutput>
			alert("You do not have authority to apply a #appsettings.getPullbackLabelLower()# amount of $" + formatWithComma(formatToDecimalPlaces(totalAmountSelected, 2, 0), "3", 0)); 
			</cfoutput>
		}
	}
}
function selectall(headercheckbox)
{
	var obj, bblevel;
	if(arguments[1])
	{
		obj = eval("window.checkAllPullbacks" + arguments[1]);
		bblevel = 1;												
	}
	else
	{
		obj = window.checkAllPullbacks;
		bblevel = 0;
	} 
	 
	if(obj != null)
	{
		if(obj.length)
		{
			for(var x=0; x<obj.length;x++)
			{
				box = getFirstChild(obj[x]);
				if(bblevel) box = getFirstChild(box);
				
				if(box.disabled == false)
				{
					box.checked = headercheckbox.checked;
				}
				else
				{
					box.disabled = true;
				}
			}
		}
		else
		{
			box = getFirstChild(obj);
			if(bblevel) box = box.firstChild;
			box.checked = headercheckbox.checked;
		}
	}
}
</script>
<script>
function submitfordetails(opr_BB_id,dis_BB_id,growth_pullback_amount,growth_pullback_volume)
{
NewWindow('/billbacks/approval/viewdetailsonpullbacks.cfm?dis_BB_id='+dis_BB_id+'&opr_BB_Id='+opr_BB_id+'&Growthpullbackamount='+growth_pullback_amount+'&growthpullbackvolume='+growth_pullback_volume,'pullbackviewdetails','800','620','Yes', 'No');
}
</script>