

<CFPARAM NAME="MarginTypeDesc" default="CS">
<CFPARAM name="CannotApproveItemMargin" default="0">
<CFPARAM name="CannotApproveItem" default="0">
<CFPARAM name="CannotApproveGroupMargin" default="0">
<CFPARAM name="CannotApproveSettings" default="0">
<cfparam name="checkgroupvalue" default="">
<cfparam name="checkitemvalue" default="">
<cfparam name="grouptrbgcolor" default = "CCFFCC">
<cfparam name="itemtrbgcolor" default = "f4f4f4">
<cfparam name="form.Margin_Type" default="1">

<cfif isdefined("url.groupid")>
<cfset group_id = #replace(url.groupid, "_", "-", "ALL")#>
<cfelse>
<cfset group_id ="NULL">
</cfif>

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

<CFSTOREDPROC PROCEDURE="GET_ITEM_PROFIT_MARGIN_DISPOSABLE" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(contract_main_id)#" NULL="No">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="cf_sql_idstamp" VARIABLE="group_id" VALUE="#trim(group_id)#" NULL="No">
</CFSTOREDPROC>

<!--- get all the products of the program --->
<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.disposable_program_approval") />

<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(contract_main_id,group_id,request.AccessStructure.profiles_id)>

<!--- create an array for error messages --->

<CFQUERY NAME="getProgramVolume" datasource="#application.datasource#">
	select
	<cfif form.Margin_Type EQ 1 or form.Margin_Type EQ 4>
	Sum(ISNULL(Round(Product_Program_Volume_CS, 0),0)) as totalprogramvolume,
	'CS' as Volume_UOM
	<cfelseif form.Margin_Type EQ 3>
	Sum(ISNULL(Round(Product_Program_Volume_LB, 0),0)) as totalprogramvolume,
	'LB' as Volume_UOM
	</cfif>
	from contract_product_margin
	where contract_main_id  = '#contract_main_id#' and deleted = 0
</CFQUERY>

<!---  get tottal program volume --->
<cfset TotalProgramVolume = getProgramVolume.totalprogramvolume>
<cfset totalprogramvolumeUOM = getProgramVolume.Volume_UOM>


<!--- check growthapproval --->
<FORM ACTION="contract_layered_Approve_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm" >

<TABLE CLASS="Maintable" CELLPADDING="4" CELLSPACING="0" WIDTH="100%">

 <TR>
    <TD ID="header" colspan="100%" STYLE="font-size: 15px; font-weight:bold; color: Navy;border-bottom: 2px solid black;">Products</TD>
	<!--- <TD class="title6"  STYLE="font-size: 12px; font-weight:bold; color: Navy;border-bottom: 2px solid black;" colspan="100%">
		<input type="radio" name="Margin_Type" value="1" <cfif form.margin_type EQ 1>checked</cfif> onClick = "changemarginType();">CASE &nbsp;&nbsp;&nbsp;
		<input type="radio" name="Margin_Type" value="3" <cfif form.margin_type EQ 3>checked</cfif> onClick = "changemarginType();">LB &nbsp;&nbsp;&nbsp;
		<input type="radio" name="Margin_Type" value="4" <cfif form.margin_type EQ 4>checked</cfif> onClick = "changemarginType();">APPLY VOLUME
	</TD> --->
</TR>
<TR>
	 <TD VALIGN="bottom" COLSPAN="100%" >&nbsp;</td>
</TR>
  <TR BGCOLOR="FFCE84" VALIGN="top">
<!---   check if they can see the base view --->
  <cfif Get_Profile_Settings.Base_View EQ 1>
    	<TD ID="header" VALIGN="top" WIDTH="250"><B>Description</B></TD>

    	 <TD ID="header" valign="top" NOWRAP align="center">
		<B>Annual<BR>
		Vol.<cfoutput>#totalprogramvolumeUOM#</cfoutput></B></TD>

    	<TD ID="header" valign="top"><B>Gross Sales</B></TD>

   		<TD ID="header" valign="top"><B>Cash Dis.</B></TD>

    	<TD ID="header" valign="top" ><B>Allow.</B></TD>
	<CFIF ShowTPA EQ 1>
		 <TD ID="header" valign="top" >
		<B><CFOUTPUT>#Current_Trade_Label#</CFOUTPUT> Adj</B></TD>
      </CFIF>
  		  <TD ID="header" valign="top" ><B>Net Sales</B></TD>
	</cfif>
	<!---   check if they can see the cost --->
	<cfif Get_Profile_Settings.View_Cost EQ 1>
	 	 <TD ID="header" valign="top"><B>Variable<br>Costs</B></TD>
	 	 <TD ID="header" valign="top" >
		<B>Cont.<br>
		Margin$</B></TD>
		 <TD ID="header" valign="top" >
		<B>Cont.<br>
		Margin%</B></TD>
		<TD ID="header" valign="top"><B>Fixed<br>Costs</B></TD>
	 </cfif>
	 <!---   check if they can see the Target_Margins --->
	  <TD ID="header" valign="top" >
		<B>Gross Profit</B></TD>
		  <TD ID="header" valign="top" >
		<B>Gross Profit%</B></TD>
			<!--- margin target --->
   		<TD ID="header" valign="top" COLSPAN="2">
		<B>Target%</B></TD>
		<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND approvaltype EQ 1>
		<TD ID="header" valign="top" ALIGN="right"><input type="checkbox" value="1" name="checkall" ONCLICK="selectAll()"></td>
		<TD ID="header" valign="top" ><B>Approve/ Agree</B></TD>
		<TD ID="header" valign="top">&nbsp;</td> </cfif>
		</TR>
	<cfset count = 0>
	<cfoutput>


	 <cfloop query="getAllProductMargins">

	<!--- add variation to group margin --->
	<cfif trim(getAllProductMargins.Group_ID_Margin) EQ "">
		<cfset getAllProductMargins.Group_ID_Margin = 0>
	</cfif>
	<cfif trim(getAllProductMargins.Group_ID_Margin) NEQ "*" and trim(getAllProductMargins.Group_ID_Margin) NEQ "">
		<cfset groupapprovalmargin = Target_Margin - ((Target_Margin * getAllProductMargins.Group_ID_Margin)/100)>
	<cfelse>
		<cfset groupapprovalmargin = "*">
	</cfif>


	<CFIF getAllProductMargins.Group_ID_Approval EQ 0>
		<CFSET CannotApproveGroupMargin = 1>
			<cfset disablecheckbox = "disabled">
			<cfset temp = ArrayAppend(messageArray, "You cannot approve #Type_Group_Desc#")>
			<cfset grouptrbgcolor = "gray">
			<cfset itemtrbgcolor ="gray">
	</CFIF>

	<CFIF getAllProductMargins.Group_ID_Approval EQ 0>
		<CFSET CannotApproveItemMargin = 1>
	</CFIF>

	<!--- check if the profile has rights to have base view --->
 <cfif Get_Profile_Settings.Base_View EQ 1>
	<!--- <TR BGCOLOR="#IIf(count Mod 2, DE('ffffff'), DE('CCCCFF'))#" VALIGN="top"> --->
<TR BGCOLOR="#itemtrbgcolor#" VALIGN="top">
	<td align="left">
	<cfif form.margin_type EQ 3>
	<span STYLE="cursor:pointer;" onmouseover="initTheTooltip('Net Weight:#trim(numberformat(NET_WEIGHT,'_-___,___,___,___,___.__'))#')" onmouseout="popOut()">#Description# #Item#</span>
<cfelse>
	#Description# #Item#
	</cfif>
	</td>
	<td align="center">
	 #trim(numberformat(Round(Product_Program_Volume),'_-___,___,___,___,___'))#
	</td>
	<td>
		$#trim(numberformat(Base_Sales,'_-___,___,___,___,___.__'))#
	</td>
	<td>
		$#trim(numberformat(Cash_discount,'_-___,___,___,___,___.__'))#
	</td>
	<td>
	<A STYLE="cursor:pointer;"
ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','A','')">
		<cfif Item_Allowance LT 0>
		<span STYLE="color: red;">
			<cfset Item_Allowance_Neg = (Item_Allowance) * (-1)>
			[$#trim(numberformat(Item_Allowance_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Item_Allowance,'_-___,___,___,___,___.__'))#
		</cfif>
	</A>
	</td>
	<CFIF ShowTPA EQ 1>
	<td>
		<A STYLE="cursor:pointer;"
ONCLICK="showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#')">
		<cfif TPA LT 0>
		<span STYLE="color: red;">
			<cfset TPA_Neg = (TPA) * (-1)>
			[$#trim(numberformat(TPA_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(TPA,'_-___,___,___,___,___.__'))#
		</cfif>
		</A>
	</td>
	</CFIF>
	<td>
		<A STYLE="cursor:pointer;"
ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','N','')">
		<cfif Net_Sales LT 0>
		<span STYLE="color: red;">
			<cfset Net_Sales_Neg = (Net_Sales) * (-1)>
			[$#trim(numberformat(Net_Sales_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(Net_Sales,'_-___,___,___,___,___.__'))#
		</CFIF>
		</A>
	</td>
</CFIF>
<cfif Get_Profile_Settings.View_Cost EQ 1>
	<td>
		<A STYLE="cursor:pointer;"
ONCLICK="showCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','C1','')">
		$#trim(numberformat(Cost1,'_-___,___,___,___,___.__'))#</A>
	</td>

	<td><A STYLE="cursor:pointer;"
ONCLICK="showCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','CM','')">
		<cfif Contribution_Margin LT 0>
		<span STYLE="color: red;">
			<cfset Contribution_Margin_Neg = (Contribution_Margin) * (-1)>
			[$#trim(numberformat(Contribution_Margin_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Contribution_Margin,'_-___,___,___,___,___.__'))#
		</cfif></A>
		</td>
	<td>
		<cfif Contribution_Margin_percent LT 0>
		<span STYLE="color: red;">
		<cfset ContributionMarginpercent = (Contribution_Margin_percent) * (-1)>
	[#trim(numberformat(Round(ContributionMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif Contribution_Margin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(Contribution_Margin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</td>
	<td>
		<A STYLE="cursor:pointer;"
ONCLICK="showCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','C2','')">
		$#trim(numberformat(Cost2,'_-___,___,___,___,___.__'))#</A>
	</td>
</cfif>
<td><A STYLE="cursor:pointer;"
ONCLICK="showCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','GP','')">
		<cfif Operating_Income LT 0>
		<span STYLE="color: red;">
			<cfset Operating_Income_Neg = (Operating_Income) * (-1)>
			[$#trim(numberformat(Operating_Income_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Operating_Income,'_-___,___,___,___,___.__'))#
		</cfif></A>
		</td>
	<td>
		<cfif OperatingMargin_percent LT 0>
		<span STYLE="color: red;">
		<cfset OperatingMarginpercent = (OperatingMargin_percent) * (-1)>
	[#trim(numberformat(Round(OperatingMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif OperatingMargin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(OperatingMargin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</td>

	<cfset approvalmargin = groupapprovalmargin>

	 <CFIF OperatingMargin_percent LT approvalmargin AND approvalmargin NEQ "*">
		<CFSET CannotApproveItemMargin = 1>
		<CFSET CannotApproveGroupMargin = 1>
			<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
	</CFIF>

	<TD BGCOLOR="#itemtrbgcolor#" align="right">
		<CFIF CannotApproveItemMargin EQ 1>
		<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
		<cfelse>
		&nbsp;
		</cfif>
	</TD>
	<TD align="left">
		<A STYLE="cursor:pointer;"
ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','T','P')">
		<cfif approvalmargin LT 0 and approvalmargin NEQ "*">
		<span STYLE="color: red;">
		<cfset approvalmargin1 = (approvalmargin) * (-1)>
		[#trim(numberformat(approvalmargin1,'_-___,___,___,___,___._'))#%]
		<cfelse>
			<cfif approvalmargin eq "*">
				#approvalmargin#%
			<cfelse>
				#trim(numberformat(approvalmargin,'_-___,___,___,___,___._'))#%
			</cfif>

		</cfif>
	</A>
	</TD>

<!--- check if the program is RFA only then display the check boxes --->
<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND approvaltype eq 1>
<!--- get all the previous approved items  --->
	<cfquery name="getitemapprovedvalues" datasource="#application.datasource#">
			select isnull(approve,0) as item_approve,Name_Last,Name_First
			from Program_Type_Code_Approval_Info
			LEFT JOIN  _Users
			ON _Users.user_id = Program_Type_Code_Approval_Info.User_Id
			and _Users.deleted = 0
			where product_id = '#BSA_Foodservice_Items_Master_Id#'
			and program_id = #contract_main_id#
			and Program_Type_Code_Approval_Info.deleted = 0
			and isnull(approve,0) = 1
	</cfquery>
	<cfquery name="getitemagreedcount" datasource="#application.datasource#">
			select count(agree) as agreecount
			from Program_Type_Code_Approval_Info
			where product_id = '#BSA_Foodservice_Items_Master_Id#'
			and program_id = #contract_main_id#
			and Program_Type_Code_Approval_Info.deleted = 0
			and isnull(agree,0) = 1
		</cfquery>



	<!--- if the approve settings like growth and upfront funds are not allowed to be approved and if the item margin is not within limits --->
<!--- display the label either approve or label after checking all the above conditions --->
	<cfif (CannotApproveSettings EQ 0 and CannotApproveItemMargin EQ 0) OR (getitemapprovedvalues.recordcount GT 0 and getitemapprovedvalues.item_approve EQ 1)>
		<cfset feildname = "ProductApprove_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#">
		<cfset itemlabel = "Approve">
		<cfif getitemagreedcount.agreecount GT 0>
			<cfset imagesrc = "Gaya_i18.gif">
			<cfset title = "Click here to view the list of users who agreed">
		<cfelse>
			<cfset imagesrc = "Gaya_i12.gif">
			<cfset title = "">
		</cfif>
		 <cfif getitemapprovedvalues.item_approve EQ 1>
		 	<cfset itemlabel = "Approved">
			<cfset checkitemvalue = "checked disabled">
			<cfset imagesrc = "Gaya_i11.gif">
			<cfset title = "">
			<cfset approveditemuser = #getitemapprovedvalues.Name_First# & ' ' & #getitemapprovedvalues.Name_Last#>
		</cfif>

	<cfelseif (getitemapprovedvalues.item_approve EQ 0 OR getitemapprovedvalues.recordcount eq 0) and (CannotApproveSettings EQ 1 OR CannotApproveItemMargin EQ 1)>
		<cfset cannotapprove = 1>
		<cfset feildname = "ProductAgree_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#">
		<cfquery name="getitemvalues" datasource="#application.datasource#">
			select isnull(agree,0) as item_agree
			from Program_Type_Code_Approval_Info
			where product_id = '#BSA_Foodservice_Items_Master_Id#'
			and user_id = '#request.AccessStructure.User_ID#'
			and program_id = #contract_main_id#
			and deleted = 0
</cfquery>
		<cfset itemlabel = "Agree">
		<cfset imagesrc = "Gaya_i12.gif">
		 <cfif getitemvalues.item_agree EQ 1 and getitemvalues.recordcount GT 0>
		 	<cfset itemlabel = "Agreed">
			<cfset checkitemvalue = "checked disabled">
			<cfset title = "Click here to view the list of users who agreed">
			<cfset imagesrc = "Gaya_i18.gif">
		</cfif>
	</cfif>

	<td BGCOLOR="#itemtrbgcolor#" ALIGN="right" valign="top">
	<span ID="checkAllProducts"><input type="checkbox" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox#></span></td>
	<td BGCOLOR="#itemtrbgcolor#" ALIGN="left" class="Title6" valign="top">
		<span class="title5">#itemlabel#</span></td>
	<td BGCOLOR="#itemtrbgcolor#">
		<IMG SRC="/images/Layered_Approval/#imagesrc#"
		<cfif imagesrc EQ 'Gaya_i11.gif'>
onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
		<cfelseif imagesrc EQ 'Gaya_i18.gif'>
		 onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
		 onclick="showCalculation('#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#','AG','P')"
		</cfif> STYLE="cursor:pointer;"></td>
</cfif>
	 </TR>

		<cfset count = count + 1>
		<cfset checkitemvalue = "">
		<cfset itemlabel ="">
		<cfset CannotApproveItemMargin = 0>
<TR>
	<td colspan="100%" style="border-bottom: 0px solid blue;">&nbsp;</td>
</TR>
<cfset CannotApproveGroupMargin = 0>
<cfset disablecheckbox = "">
<cfset grouptrbgcolor = "CCFFCC">
<cfset itemtrbgcolor = "f4f4f4">
</CFloop>
</cfoutput>
	<input type="hidden" name="programid" value="<cfoutput>#url.CID#</cfoutput>">
	<input type="hidden" name="ProgramIsARevision" value="<cfoutput>#getProgramInfo.Is_A_Revision#</cfoutput>">
	<input type="hidden" name="AllowRetroRevision" value="<cfoutput>#getSettings.ALLOW_RETRO_REVISION#</cfoutput>">
	<input type="hidden" name="MaxDuration" value="<cfoutput>#getSettings.max_duration#</cfoutput>">
	<input type="hidden" name="Allow_Retro_Revision_Span" value="<cfoutput>#getSettings.Allow_Retro_Revision_Span#</cfoutput>">
	<input type="hidden" name="groupapproval" value="0">

</TABLE>
</form>

<script>
function changemarginType()
{
	document.MyForm.action = "layered_approval_include.cfm?CID=<cfoutput>#URL.CID#</cfoutput>"
	MyForm.submit();
}
</script>



