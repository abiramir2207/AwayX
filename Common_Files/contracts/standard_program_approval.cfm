 <CFPARAM NAME="MarginTypeDesc" default="CS">
<CFPARAM name="CannotApproveItemMargin" default="0">
<CFPARAM name="CannotApproveItem" default="0">
<CFPARAM name="CannotApproveGroupMargin" default="0">
<CFPARAM name="CannotApproveSettings" default="0">
<cfparam name="checkgroupvalue" default="">
<cfparam name="checkitemvalue" default="">
<cfparam name="grouptrbgcolor" default = "CCFFCC">
<cfparam name="itemtrbgcolor" default = "f4f4f4">
<cfparam name="margin_content" default = "">
<cfparam name="duplicateprogram" default = "0">

<!--- get all the products of the program --->
<cfif appSettings.getShowORHideGroupsInViewMargin()>
	<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(contract_main_id,getSettings.approval_uom,form)>
<cfelse>
	<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(contract_main_id,getSettings.approval_uom)>
</cfif>
<cfset getProgramMargins = ApprovalProgramManager.getProgramMargins(contract_main_id,getSettings.approval_uom)>
<cfif getAllProductMargins.recordcount GT 0>
	<!--- get all the typecode info --->
	<cfset getAllGroupMargins = ApprovalProgramManager.getAllGroupMargins(contract_main_id,request.AccessStructure.Profiles_ID,getSettings.approval_uom)>
</cfif>

<cfif getSettings.approval_uom EQ 1>
	<cfset TotalProgramVolume = getProgramMargins.totalprogramvolume>
	<cfset totalprogramvolumeUOM = "CS">
<cfelse>
	<cfset TotalProgramVolume = getProgramMargins.totalprogramvolume_CS>
	<cfset totalprogramvolumeUOM = "LB">
</cfif>

<cfif (TotalProgramVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*">
 	<cfset CannotApproveSettings = 1>
	<cfset temp = ArrayAppend(messageArray, "You cannot approve since the volume of the program exceeds your approval limits.")>
</cfif>
<cfif (TotalProgramVolume LT minvolume_CS) and TRIM(minvolume_CS) NEQ "*">
 	<cfset CannotApproveSettings = 1>
	<cfset temp = ArrayAppend(messageArray, "You cannot approve since the volume is below your minimum required volume threshold.")>
</cfif>
<cfif getSettings.approval_program_margin EQ 1>
	<cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
 		<cfset CannotApproveSettings = 1>
		<cfset temp = ArrayAppend(messageArray, "The operating margin of the program is less than the minimum approval limits.")>
	</cfif>
</cfif>
<cfset program_spend = Val(getProgramMargins.TotalProgramVolume) *  Val(getProgramMargins.TOTAL_Allowance)>

<cfset getlumpsumwithoutprods = ApprovalProgramManager.getlumpsumwithoutprods(contract_main_id)>
<cfset getlumpsumwithprods = ApprovalProgramManager.getlumpsumwithprods(contract_main_id)>
<cfif getlumpsumwithoutprods.recordcount GT 0>
	<cfset lumpsumamount = getlumpsumwithoutprods.lumpsumamount>
<cfelse>
	<cfset lumpsumamount = 0>
</cfif>
<cfset program_spend = program_spend + lumpsumamount>
<cfset program_spend = program_spend + getlumpsumwithprods.lumpsumamount>
<cfif getSettings.approval_program_spend EQ 1>
<cfif (program_spend GT Get_Profile_Settings.Max_Program_Spend) and TRIM(Get_Profile_Settings.Max_Program_Spend) NEQ "*">
 		<cfset CannotApproveSettings = 1>
		<cfset temp = ArrayAppend(messageArray, "The trade spend $ of the program is greater than the program spending cap ($#numberformat(Get_Profile_Settings.Max_Program_Spend,'_-___,___,___,___,___.__')#).")>
	</cfif>
</cfif>

<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	
	#Summary {border-top:double solid #93BEE2;border-bottom:double solid #93BEE2; font-size : 12px; color: black; font-weight : bold;}
	#header {font-size: 10px; color: black;}
</style>
<!--- This variable adds the number of columns in the row --->
<cfset ColumnNumbers = 0>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<TABLE CLASS="Maintable" CELLPADDING="4" CELLSPACING="0" WIDTH="100%" border="0">
<TR> 
	<TD align="left" style="color:red;font-size:11px;">
	<!---D50860 :: Release 8.0 - Improvements to the ‘View Margin’ page inside a program START --->
		<cfif isDefined("ProgramIsARevision") AND ProgramIsARevision NEQ 0>
			<div style="float:left;margin-right:80px;">*** NOTE: This Is A Revision Of An Existing Program ***</div>
		</cfif>
		<cfif isDefined("MarginDate")>
			<div style="float:left;">#MarginDate#</div>
		</cfif>
	<!---D50860 :: Release 8.0 - Improvements to the ‘View Margin’ page inside a program END --->
	</TD>
	<TD class="title6" align="right"  STYLE="font-size: 12px; font-weight:bold; color: Navy;border-bottom: 2px solid black;" colspan="7">
		Unit Of Measure: <cfif getSettings.approval_uom EQ 1>CASES<cfelse>POUNDS</cfif>
	</TD>
</TR>
  <TR BGCOLOR="FFCE84" VALIGN="top"> 
<!---   check if they can see the base view --->
  <cfif Get_Profile_Settings.Base_View EQ 1>
    	<TD ID="header" VALIGN="top" WIDTH="250"><B>Description</B></TD>

    	 <TD ID="header" valign="top" NOWRAP align="center">
		<B>Program
		Vol. <BR><cfoutput>#totalprogramvolumeUOM#</cfoutput></B></TD>
 
    	<TD ID="header" valign="top"><B>Base <br> Sales<br>&nbsp;&nbsp;&nbsp;+</B></TD>
			<!--- We have 3 columns above. If you add more columns, please change the value below 3 to the number of columns.
						This rule applies to all the cells in this row --->
		<cfset ColumnNumbers = ColumnNumbers + 3> 
		<cfif appsettings.getlocalcostvariables() and direct_pricing EQ 0>
   		<TD ID="header" valign="top"><B>Local<br> Costs<br>&nbsp;&nbsp;&nbsp; - </B></TD>
			<cfset ColumnNumbers = ColumnNumbers + 1>
		</cfif>
			
		<cfif direct_pricing EQ 0>
    	<TD ID="header" valign="bottom" ><B>Allow.<br>&nbsp;&nbsp;&nbsp; - </B></TD>
			<cfset ColumnNumbers = ColumnNumbers + 1>
		</cfif>
	</cfif >
	<CFIF ShowTPA EQ 1 and Get_Profile_Settings.View_TPA EQ 1>
		 <TD ID="header" valign="top" >
		<B><CFOUTPUT>#Current_Trade_Label#</CFOUTPUT><br> Adj<br>&nbsp;&nbsp;&nbsp; - </B></TD>
		<cfset ColumnNumbers = ColumnNumbers + 1>
     </CFIF>
	  <cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
	 	<TD ID="header" valign="top" >
		<B><cfoutput>#appsettings.getPullbackLabel()#</cfoutput><br> Amt<br>&nbsp;&nbsp;&nbsp;+</B></TD>
		<cfset ColumnNumbers = ColumnNumbers + 1>
	 </cfif> 
	 <cfif Get_Profile_Settings.View_Net_Sales EQ 1>
  		  <TD ID="header" valign="top" ><B>Net Sales</B></TD>
				<cfset ColumnNumbers = ColumnNumbers + 1>
	</cfif>
	<!---   check if they can see the cost --->
	<cfif Get_Profile_Settings.View_Cost EQ 1 and appsettings.getcustomerbasedcosts()>
	 	 <TD ID="header" valign="bottom"><B>Cost<br>&nbsp;&nbsp;&nbsp; -</B></TD>
		 <cfset ColumnNumbers = ColumnNumbers + 1>
	</cfif>
	<!---   check if they can see the Operating_Income --->
	<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
	 	 <TD ID="header" valign="top" >
		<B>Opr.<br>
		Income$</B></TD>
		<cfset ColumnNumbers = ColumnNumbers + 1>
	 </cfif>
	 <!---   check if they can see the Target_Margins --->
	<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
		  <TD ID="header" valign="top" >
		<B>Opr. Margin%</B></TD>
			<!--- margin target --->
   		<TD ID="header" valign="bottom" COLSPAN="2">
		<B>Target%<br>&nbsp;</B></TD>
		<cfset ColumnNumbers = ColumnNumbers + 3>
		</cfif>		
		<TD ID="header" valign="top" COLSPAN="2" align="left">
		<B>Trade <br>Spend$</B></TD>
		<cfset ColumnNumbers = ColumnNumbers + 2>
		
		<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND (approvaltype EQ 1 OR agreetype EQ 1)>
		<TD ID="header" valign="top" ALIGN="right" style="display:visible"><input type="checkbox" value="1" name="checkall" ONCLICK="selectAll('a')"></td>
		<TD ID="header" valign="top" style="display:visible"><B>Approve/ Agree</B></TD>  
		<TD ID="header" valign="top" style="display:visible">&nbsp;</td> </cfif>
		</TR>

	<cfset count = 0>	
	<cfset OuterLoopcount = 1>

<CFQUERY NAME="getProductMarginCount" DBTYPE="query">
	SELECT COUNT(*) As ProductMarginCount
	FROM getAllProductMargins
	GROUP BY group_id
</CFQUERY>

<cfset ProductMarginCount = getProductMarginCount.Recordcount>

<CFOUTPUT query="getAllProductMargins" group="group_id">
	<cfset useLakebaseForgetGroupvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallgroupmargins")>
<cfif useLakebaseForgetGroupvalues>
	<cftry>
		<cfset getGroupvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallgroupmargins", {
				"type_code_desc_id" = "eq.#getAllProductMargins.group_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupvalues>
<CFQUERY name="getGroupvalues" dbtype="query">
	select * from getAllGroupMargins
	where Type_Code_Desc_Id = '#getAllProductMargins.group_id#'
	</CFQUERY>
</cfif>

	<!--- add variation to group margin --->
	<cfif trim(getGroupvalues.Group_ID_Margin) EQ "">
		<cfset getGroupvalues.Group_ID_Margin = 0>
	</cfif>
	<cfif trim(getGroupvalues.Group_ID_Margin) NEQ "*" and trim(getGroupvalues.Group_ID_Margin) NEQ "">
		<cfset groupapprovalmargin = getGroupvalues.Target_Margin - ((getGroupvalues.Target_Margin * getGroupvalues.Group_ID_Margin)/100)>
	<cfelse>
		<cfset groupapprovalmargin = "*">
	</cfif>
	
	<cfif trim(Spend_Dollar_CS) EQ "">
		<cfset Spend_Dollar_CS = 0>
	</cfif>
	<cfif trim(Spend_Dollar_CS) NEQ "*" and trim(Spend_Dollar_CS) NEQ "">
		<cfset itemapprovalspend = Spend_Dollar_CS>
		<cfset itemspenddollar = Spend_Dollar_CS * (getAllProductMargins.Product_Program_Volume)>
	<cfelse>
		<cfset itemapprovalspend = "*">
	</cfif>
	
	<!--- check if group margin is within limits --->
	<CFIF getGroupvalues.Group_ID_Approval EQ 0>
		<CFSET CannotApproveGroupMargin = 1>
		<CFSET CannotApproveItemMargin = 1>
		<cfset disablecheckbox = "disabled">
		<cfset temp = ArrayAppend(messageArray, "You cannot approve #getGroupvalues.Type_Code_Desc#")>
		<cfset grouptrbgcolor = "gray">
		<cfset itemtrbgcolor ="gray">
		<!----<cfset form.RestrictedList = listAppend(form.RestrictedList,BSA_Foodservice_Items_Master_Id ) >--->
	</CFIF>
	<cfoutput>	

	<!--- check if the profile has rights to have base view --->
 <cfif Get_Profile_Settings.Base_View EQ 1>
	<!--- <TR BGCOLOR="#IIf(count Mod 2, DE('ffffff'), DE('CCCCFF'))#" VALIGN="top"> --->
<TR BGCOLOR="#itemtrbgcolor#" VALIGN="top">
	<td align="left">#Description# #Item#</td>
	<td align="center">
	 #trim(numberformat(Round(Product_Program_Volume),'_-___,___,___,___,___'))#
	</td>
	<td>
		<A STYLE="cursor:pointer;" href="javascript:showCalculation('#replace(Product_Id, "-", "_", "ALL")#','B','')">
<cfif Base_Sales EQ 0>
<cfif groupapprovalmargin NEQ "*" and getSettings.approval_margin_item EQ 1>
	<CFSET CannotApproveGroupMargin = 1>
	<CFSET CannotApproveItemMargin = 1>
	<cfset temp = ArrayAppend(messageArray, "*** INSUFFICIENT PURCHASE ACTIVITY TO CALCULATE *** #Item#")>
<cfelseif itemapprovalspend NEQ "*" and getSettings.approval_spend_item EQ 1>
	<CFSET CannotApproveGroupMargin = 1>
	<CFSET CannotApproveItemMargin = 1>
	<cfset temp = ArrayAppend(messageArray, "*** INSUFFICIENT PURCHASE ACTIVITY TO CALCULATE *** #Item#")>
</cfif>
*IDC
<cfelse>
$#trim(numberformat(Base_Sales,'_-___,___,___,___,___.__'))#
</cfif></A>
	</td>
	<cfif appsettings.getlocalcostvariables() and direct_pricing EQ 0>
	<td>
		 <A STYLE="cursor:pointer;" href="javascript:showLocalCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','L','')">$#trim(numberformat(Cash_discount,'_-___,___,___,___,___.__'))#</A>
	 </td>
	 </cfif>
	<cfif direct_pricing EQ 0>
	<td>
	<A STYLE="cursor:pointer;" href="javascript:showCalculation('#replace(Product_Id, "-", "_", "ALL")#','A','')">
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
	</cfif>
</CFIF>
	<CFIF ShowTPA EQ 1 and Get_Profile_Settings.View_TPA EQ 1>
	<td>
		<A STYLE="cursor:pointer;" href="javascript:showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#')">
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
	<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
	<td>
	<A STYLE="cursor:pointer;" href="javascript:showPullbackCalculation('#replace(Product_Id, "-", "_", "ALL")#')">
		<cfif Pullbackamount LT 0>
			<span STYLE="color: red;">
			<cfset Pullbackamount_Neg = (Val(Pullbackamount)) * (-1)>
			[$#trim(numberformat(Pullbackamount_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(Pullbackamount,'_-___,___,___,___,___.__'))#
		</cfif>
	</A>
	</td>
	</cfif>
 <cfif Get_Profile_Settings.View_Net_Sales EQ 1>
	<td>
		<A STYLE="cursor:pointer;" href="javascript:showCalculation('#replace(Product_Id, "-", "_", "ALL")#','N','')">
		<cfif Net_Sales LT 0>
		<span STYLE="color: red;">
			<cfset Net_Sales_Neg = (Net_Sales) * (-1)>
			[$#trim(numberformat(Net_Sales_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>	
			$#trim(numberformat(Net_Sales,'_-___,___,___,___,___.__'))#
		</CFIF>
		</A>
	</td>
</cfif>
<cfif Get_Profile_Settings.View_Cost EQ 1 and appsettings.getcustomerbasedcosts() eq 1>
	<td>
		<A STYLE="cursor:pointer;" href="javascript:showCalculation('#replace(Product_Id, "-", "_", "ALL")#','CB','')">
		$#trim(numberformat(Cost,'_-___,___,___,___,___.__'))#</A>
	</td>

</cfif>
<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
	<td>
		<cfif Operating_Income LT 0>
		<span STYLE="color: red;">
			<cfset Operating_Income_Neg = (Operating_Income) * (-1)>
			[$#trim(numberformat(Operating_Income_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Operating_Income,'_-___,___,___,___,___.__'))#
		</cfif>
		</td>
</cfif>
<!--- check if the user profile has rights to view margins --->
<cfif getSettings.approval_margin_item EQ 1>
	<CFIF OperatingMargin_percent LT groupapprovalmargin AND groupapprovalmargin NEQ "*">
		<CFSET CannotApproveItemMargin = 1>
		<CFSET CannotApproveGroupMargin = 1>
		<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
	</CFIF> 
</cfif>
<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
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
	<!--- add item variation to the item --->
	
	<TD BGCOLOR="#itemtrbgcolor#" align="right">
		<CFIF CannotApproveItemMargin EQ 1>
			<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
		<cfelse>
			&nbsp;
		</cfif> 
	</TD>

	<TD align="left">
		<cfif marginTagetEnabled and appSettings.getuploadmargintargets_on()>
			<A STYLE="cursor:pointer;" href="javascript:showCalculation('#replace(Product_Id, "-", "_", "ALL")#','T','P')">
			<cfif groupapprovalmargin LT 0 and groupapprovalmargin NEQ "*">
			<span STYLE="color: red;">
			<cfset groupapprovalmargin1 = (groupapprovalmargin) * (-1)>
			[#trim(numberformat(groupapprovalmargin1,'_-___,___,___,___,___._'))#%]
			<cfelse>
				<cfif groupapprovalmargin eq "*">
					*%
				<cfelse>
					#trim(numberformat(groupapprovalmargin,'_-___,___,___,___,___._'))#%
				</cfif>
			
			</cfif>
			</A>
		</cfif>&nbsp;
	</TD>
	</cfif>
	
		
	<cfif getSettings.approval_spend_item EQ 1>
	<CFIF Item_Allowance GT itemapprovalspend AND itemapprovalspend NEQ "*">
		<CFSET CannotApproveItemMargin = 1>
		<CFSET CannotApproveGroupMargin = 1>
	
			<cfset temp = ArrayAppend(messageArray, "Trade spend for #Description# #Item# is greater than the spending cap ($#numberformat(itemspenddollar,'_-___,___,___,___,___.__')#).")>
	</CFIF> 
	</cfif>

	<TD align="left" COLSPAN="2">
	<cfset tradespend = Item_Allowance * Round(Product_Program_Volume)>
	 <cfif tradespend LT 0>
		<span STYLE="color: red;">
		<cfset tradespend1 = (tradespend) * (-1)>
		[$#trim(numberformat(tradespend1,'_-___,___,___,___,___.__'))#]</span>
	<cfelse>
		$#trim(numberformat(tradespend,'_-___,___,___,___,___.__'))#
	</cfif> 
	</TD>

<cfif CannotApproveGroupMargin EQ 1 >
	<cfset form.RestrictedList = listAppend(form.RestrictedList,BSA_Foodservice_Items_Master_Id ) >
</cfif>

<!--- check if the program is RFA only then display the check boxes --->
<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND (approvaltype EQ 1 OR agreetype EQ 1)>
<!--- get all the previous approved items  --->
	<cfquery name="getitemapprovedvalues" datasource="#application.datasource#">
			select isnull(approve,0) as item_approve,Name_Last,Name_First
			from Program_Type_Code_Approval_Info
			LEFT JOIN  _Users
			ON _Users.user_id = Program_Type_Code_Approval_Info.User_Id
			and _Users.deleted = 0
			where program_id = #contract_main_id#
			and product_id = '#BSA_Foodservice_Items_Master_Id#'
			and isnull(approve,0) = 1
			and Program_Type_Code_Approval_Info.deleted = 0
	</cfquery>
	<cfquery name="getitemagreedcount" datasource="#application.datasource#">
			select count(agree) as agreecount
			from Program_Type_Code_Approval_Info
			where program_id = #contract_main_id#
			and product_id = '#BSA_Foodservice_Items_Master_Id#'
			and  isnull(agree,0) = 1
			and	 Program_Type_Code_Approval_Info.deleted = 0
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
		<cfset showagreepopup = 1>
		
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
		<cfset button_label = "Agree">
	</cfif>
	
	<CFIF CannotApproveItemMargin EQ 1>
		<cfset form.AgreeList = ListAppend(form.AgreeList, BSA_Foodservice_Items_Master_Id) >
	<cfelse>
		<cfset form.ApproveList = ListAppend(form.ApproveList, BSA_Foodservice_Items_Master_Id)>
	</cfif>
	
	<td BGCOLOR="#itemtrbgcolor#" ALIGN="right" valign="top" style="display:visible">
	<span ID="checkAllProducts"><input type="checkbox" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox#></span></td>
	<td BGCOLOR="#itemtrbgcolor#" ALIGN="left" class="Title6" valign="top" style="display:visible">
		<span class="title5">#itemlabel#</span></td>
	<td BGCOLOR="#itemtrbgcolor#" style="display:visible">
		<IMG SRC="/images/Layered_Approval/#imagesrc#"
		<cfif imagesrc EQ 'Gaya_i11.gif'>
onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
		<cfelseif imagesrc EQ 'Gaya_i18.gif'>
		 onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
		 href="javascript:showCalculation('#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#','AG','P')"
		</cfif> STYLE="cursor:pointer;"></td>
</cfif>
	 </TR>

		<cfset count = count + 1>
		<cfset checkitemvalue = "">
		<cfset itemlabel ="">
		<cfset CannotApproveItemMargin = 0>
	</cfoutput>
	<TR bgcolor="#grouptrbgcolor#">
	<CFLOOP query="getGroupvalues">
	<cfif Get_Profile_Settings.Base_View EQ 1>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">#Type_Code_Desc#</TD>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="center">
	#trim(numberformat(Round(Group_Product_Program_Volume),'_-___,___,___,___,___'))#
	</TD>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
	<cfif Group_Base_Sales EQ 0>
	*IDC
<cfelse>
	$#trim(numberformat(Group_Base_Sales,'_-___,___,___,___,___.__'))#
</cfif>
		
	</TD>
	<cfif appsettings.getlocalcostvariables() and direct_pricing EQ 0>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		$#trim(numberformat(Group_Cash_discount,'_-___,___,___,___,___.__'))#
	</TD>
	</cfif>
	<cfif direct_pricing EQ 0>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		<cfif Group_Item_Allowance LT 0>
		<span STYLE="color: red;">
		<cfset Group_Item_Allowance_Neg = (Group_Item_Allowance) * (-1)>
		[$#trim(numberformat(Group_Item_Allowance_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
		$#trim(numberformat(Group_Item_Allowance,'_-___,___,___,___,___.__'))#
		</cfif>
	</TD>
	</cfif>
	</cfif>
	<CFIF ShowTPA EQ 1 and Get_Profile_Settings.View_TPA EQ 1>
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		<cfif Group_TPA LT 0>
		<span STYLE="color: red;">
			<cfset Group_TPA_Neg = (Group_TPA) * (-1)>
			[$#trim(numberformat(Group_TPA_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(Group_TPA,'_-___,___,___,___,___.__'))#
		</cfif>
	</td>
	</CFIF>
	<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
		<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		<cfif Group_Pullbackamount LT 0>
		<span STYLE="color: red;">
			<cfset Group_Pullbackamount_Neg = (Group_Pullbackamount) * (-1)>
			[$#trim(numberformat(Group_Pullbackamount_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(Group_Pullbackamount,'_-___,___,___,___,___.__'))#
		</cfif>
	</td>
	</cfif>
<cfif Get_Profile_Settings.View_Net_Sales EQ 1>
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		<cfif Group_Net_Sales LT 0>
		<span STYLE="color: red;">
			<cfset Group_Net_Sales_Neg = (Group_Net_Sales) * (-1)>
			[$#trim(numberformat(Group_Net_Sales_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>	
			$#trim(numberformat(Group_Net_Sales,'_-___,___,___,___,___.__'))#
		</CFIF>
	</td>
	</cfif>
<cfif Get_Profile_Settings.View_Cost EQ 1>
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		$#trim(numberformat(Group_Cost,'_-___,___,___,___,___.__'))#
	</td>
</cfif>
<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		<cfif Group_Operating_Income LT 0>
		<span STYLE="color: red;">
		<cfset Group_Operating_Income_Neg = (Group_Operating_Income) * (-1)>
		[$#trim(numberformat(Group_Operating_Income_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
		$#trim(numberformat(Group_Operating_Income,'_-___,___,___,___,___.__'))#
		</cfif>
	</td>
</cfif>
<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
	<cfif Group_OperatingMargin_percent LT 0>
		<span STYLE="color: red;">
		<cfset Group_OperatingMarginpercent = (Group_OperatingMargin_percent) * (-1)>
	[#trim(numberformat(Round(Group_OperatingMarginpercent),'_-___,___,___,___,___._'))#%]</SPAN>
		<!--- <CFELSEIF  Total_OperatingMargin_percent eq 0>
			<span STYLE="color: red;">*IDC</SPAN> --->
		<cfelse>
	#trim(numberformat(Round(Group_OperatingMargin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</TD>
	
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right">&nbsp;
			
	</TD>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="left">
	<A STYLE="cursor:pointer;" href="javascript:showCalculation('#replace(Type_code_desc_id, "-", "_", "ALL")#','T','G')">
		
		<cfif groupapprovalmargin LT 0 and groupapprovalmargin NEQ "*">
		<span STYLE="color: red;">
		<cfset Group_groupapprovalmargin = (groupapprovalmargin) * (-1)>
		[#trim(numberformat(Group_groupapprovalmargin,'_-___,___,___,___,___._'))#%]
		<cfelse>
			<cfif groupapprovalmargin EQ "*">
				*%
			<cfelse>
				#trim(numberformat(groupapprovalmargin,'_-___,___,___,___,___._'))#%
			</cfif>
		</cfif></A>
	</TD>
	
</cfif>
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" ALIGN="right">&nbsp;
	</td>
		
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" ALIGN="left">&nbsp;</td>
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
	<cfset groupcolspan = 0>
	<cfif getSettings.approval_spend_item EQ 1>
		<cfset groupcolspan= groupcolspan + 2>
	</cfif>
	<cfif getSettings.approval_margin_item EQ 1>
		<cfset groupcolspan= groupcolspan + 2>
	</cfif>
	<td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" ALIGN="left" colspan="#groupcolspan#" style="display:visible">&nbsp;</td>
	</cfif>
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" style="display:visible" colspan="2">&nbsp;</TD>
</cfif>
<cfset checkgroupvalue = "">
<cfset grouplabel = "">
</CFLOOP>
	</TR>
<TR>
	<td colspan="100%" style="border-bottom: 0px solid blue;">&nbsp;</td>
</TR>
<cfset CannotApproveGroupMargin = 0>
<cfset disablecheckbox = "">
<cfset grouptrbgcolor = "CCFFCC">
<cfset itemtrbgcolor = "f4f4f4">

<cfset LastPercent = 0>

<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
<cfset PercentDone = Int(Ceiling((OuterLoopcount/ProductMarginCount) * 100)/10)>

<!--- Show the Image based on product count --->
<cfif LastPercent neq PercentDone>
	<cfset Block = "Block" & PercentDone>
	<script>
	if(document.#Block#){
		<cfloop from="1" to="#PercentDone#" index="i">
			<cfset Block = "Block" & i>
			document.#Block#.src = '/images/red_block.gif';
		</cfloop>
	}
	//Show the progress in percent
 if(document.getElementById('ShowPercentProgress')){
 <cfset PercentDone = PercentDone&'0'>
	document.getElementById('ShowPercentProgress').innerHTML = '#PercentDone#%';
 }
	</script>		
	<cfflush>
	<cfset LastPercent = PercentDone>
</cfif>
<cfset OuterLoopcount = OuterLoopcount + 1>
</CFOUTPUT>
	<cfoutput>
<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND (approvaltype EQ 1 OR agreetype EQ 1)>
<TR BGCOLOR="FFCE84" VALIGN="top"> 
		<TD ID="header" VALIGN="top" colspan="#ColumnNumbers#">&nbsp;</TD>
		<TD ID="header" VALIGN="top" ALIGN="right" style="display:visible"><input type="checkbox" value="1" name="checkall_1" ONCLICK="selectAll('b')"></TD>
		<TD ID="header" valign="top" style="display:visible;font-size:8px;"><B>Approve/ Agree</B></TD>  
		<TD ID="header" valign="top" style="display:visible">&nbsp;</td>
</TR>
</cfif>
<cfset colCount = 0 />
<!------ Program Summary start ----->
<TR>
<TD VALIGN="top" ID="Summary" nowrap><cfset colCount = colCount + 1 />
<cfif lumpsumamount GT 0>Lump Sum Amount<br><br></cfif>
Program Summary</TD>
 <cfif Get_Profile_Settings.Base_View EQ 1>
<CFSET data = makeNumeric(getProgramMargins.TotalProgramVolume)>					
						<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ #data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))></CFIF>
<TD valign="bottom" ID="Summary" nowrap align="center"><cfset colCount = colCount + 1 />
<cfif ((TotalProgramVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*") OR ((TotalProgramVolume LT MinVolume_CS) and TRIM(MinVolume_CS) NEQ "*")>
<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('Volume not within your approval limits.')" onmouseout="popOut()" align="absmiddle">
</cfif>
#data#</TD>

<CFSET data = makeNumeric(getProgramMargins.Total_BaseSales)>						
						<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
<cfif appsettings.getlocalcostvariables() and direct_pricing EQ 0>
<CFSET data = makeNumeric(getProgramMargins.Total_Cash_Discount)>						
						<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>
<cfif direct_pricing EQ 0>
<cfparam name="addExtra" default="0">
<cfif TotalProgramVolume neq "" and TotalProgramVolume neq 0>
	<cfset addExtra = makenumeric(getlumpsumwithprods.lumpsumamount/TotalProgramVolume) >
</cfif>
<CFSET data = makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra >						
						<CFIF data LT 0>
						<cfset data = data * (-1)>
						<CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>

<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>
</cfif>
<CFIF ShowTPA EQ 1 and Get_Profile_Settings.View_TPA EQ 1>
<CFSET data = makeNumeric(getProgramMargins.Total_TPA)>						
						<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>
<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
<CFSET data = makeNumeric(getProgramMargins.Total_pullbackamount)>						
						<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="top" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>
 <cfif Get_Profile_Settings.View_Net_Sales EQ 1>
<CFSET data = makeNumeric(getProgramMargins.TOTAL_NetSales)>						
						<CFIF data LT 0>
						<cfset data = data * (-1)>
						<CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>
<cfif Get_Profile_Settings.View_Cost EQ 1>
<CFSET data = makeNumeric(getProgramMargins.Total_Cost)>						
						<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>
<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
<CFSET data = makeNumeric(getProgramMargins.Total_OprIncome)>						
						<CFIF data LT 0>
						<cfset data = data * (-1)>
						<CFSET data = (trim(numberformat(data,"___,___,___,___,___,___-__.__")))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
<cfset data = "$#data#">
</CFIF>
<TD valign="bottom" ID="Summary">#data#</TD><cfset colCount = colCount + 1 />
</cfif>

<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
<CFSET data = makeNumeric(getProgramMargins.Total_OprMargin)>						
						<CFIF data LT 0>
						<cfset data = data * (-1)>
						<CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ #data#% ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))>
<cfset data = "<b>#data#%</b>"></CFIF>
<TD valign="bottom" nowrap ID="Summary"><cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')" onmouseout="popOut()" align="absmiddle">
</cfif>#data#</TD><cfset colCount = colCount + 1 />
<td ID="Summary" colspan="2">&nbsp;</td><cfset colCount = colCount + 1 />
</cfif>
<TD valign="top" nowrap ID="Summary" colspan="2" <cfif lumpsumamount GT 0>align="right"</cfif>>
<cfset colCount = colCount + 1 />
<cfif lumpsumamount GT 0>
$#trim(numberformat(lumpsumamount,"___,___,___,___,___,___-__.__"))#<br><br>
</cfif>
<cfif (program_spend GT Get_Profile_Settings.Max_Program_Spend) and TRIM(Get_Profile_Settings.Max_Program_Spend) NEQ "*">
<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('Spending Cap not within your approval limits.')" onmouseout="popOut()" align="absmiddle">
</cfif>#trim(dollarformat(program_spend))#</TD>

<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
<TD colspan="100%"  ID="Summary" style="display:visible">&nbsp;</TD><cfset colCount = colCount + 1 />
</cfif>
</TR>
<!--- <cfif lumpsumamount GT 0>
<TR>
<TD VALIGN="top" ID="Summary" nowrap style="border-top: none;">Lumpsum Amount</TD>
<TD valign="top" ID="Summary" nowrap colspan="100%" style="border-top: none;" align="right">$#trim(numberformat(lumpsumamount,"___,___,___,___,___,___-__.__"))#</TD>
</TR>
</cfif> --->
<!------ Program Summary end ----->
<cfset tempABS_BaseSales =  makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(getProgramMargins.TotalProgramVolume)>

<!--- New Summary --->
	<TR>
	<TD VALIGN="top" nowrap><cfset colCount = colCount + 1 />
	<cfif lumpsumamount GT 0>Lump Sum Amount<br><br></cfif>
	<strong>Program Summary<br />(absolute $)</strong></TD>
	 <cfif Get_Profile_Settings.Base_View EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.TotalProgramVolume)>					
							<CFIF data LT 0>&nbsp;<CFSET data = "<SPAN STYLE=""color: red;""><b>[ #data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))></CFIF>
	<TD valign="bottom"  nowrap align="center"><cfset colCount = colCount + 1 />
	<cfif ((TotalProgramVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*") OR ((TotalProgramVolume LT MinVolume_CS) and TRIM(MinVolume_CS) NEQ "*")>
	<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('Volume not within your approval limits.')" onmouseout="popOut()" align="absmiddle">
	</cfif>
	&nbsp;</TD>
	
	<CFSET data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(getProgramMargins.TotalProgramVolume)>
	<CFSET tempABS_BaseSales = data />								
							<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	<cfif appsettings.getlocalcostvariables() and direct_pricing EQ 0>
	<CFSET data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(getProgramMargins.TotalProgramVolume) >						
							<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	<cfif direct_pricing EQ 0>
	<cfparam name="addExtra" default="0">
	<cfif TotalProgramVolume neq "" and TotalProgramVolume neq 0>
		<cfset addExtra = makenumeric(getlumpsumwithprods.lumpsumamount/TotalProgramVolume) >
	</cfif>
	<CFSET data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(getProgramMargins.TotalProgramVolume)  >						
							<CFIF data LT 0>
							<cfset data = data * (-1)>
							<CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	</cfif>
	<CFIF ShowTPA EQ 1 and Get_Profile_Settings.View_TPA EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(getProgramMargins.TotalProgramVolume) >						
							<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(getProgramMargins.TotalProgramVolume)  >						
							<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	 <cfif Get_Profile_Settings.View_Net_Sales EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(getProgramMargins.TotalProgramVolume) >						
							<CFIF data LT 0>
							<cfset data = data * (-1)>
							<CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	<cfif Get_Profile_Settings.View_Cost EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(getProgramMargins.TotalProgramVolume) >						
							<CFIF data LT 0><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(getProgramMargins.TotalProgramVolume) >						
							<CFIF data LT 0>
							<cfset data = data * (-1)>
							<CFSET data = (trim(numberformat(data,"___,___,___,___,___,___-__.__")))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $#data# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__.__"))>
	<cfset data = "$#data#">
	</CFIF>
	<TD valign="bottom" >#data#</TD><cfset colCount = colCount + 1 />
	</cfif>
	
	<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
	<CFSET data = makeNumeric(getProgramMargins.Total_OprMargin) * makeNumeric(getProgramMargins.TotalProgramVolume) >						
							<CFIF data LT 0>
							<cfset data = data * (-1)>
							<CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ #data#% ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))>
	<cfset data = "<b>#data#%</b>"></CFIF>
	<TD valign="bottom" nowrap ><cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
	<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')" onmouseout="popOut()" align="absmiddle">
	</cfif>&nbsp;</TD><cfset colCount = colCount + 1 />
	<td colspan="2">&nbsp;</td><cfset colCount = colCount + 1 />
	</cfif>
	<TD valign="bottom" nowrap colspan="2" <cfif lumpsumamount GT 0>align="right"</cfif>>
	<cfset colCount = colCount + 1 />
	<cfif lumpsumamount GT 0>
	$#trim(numberformat(lumpsumamount,"___,___,___,___,___,___-__.__"))#<br><br>
	</cfif>
	<cfif (program_spend GT Get_Profile_Settings.Max_Program_Spend) and TRIM(Get_Profile_Settings.Max_Program_Spend) NEQ "*">
	<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('Spending Cap not within your approval limits.')" onmouseout="popOut()" align="absmiddle">
	</cfif>#trim(dollarformat(program_spend))#</TD>
	
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
	<TD colspan="100%" style="display:visible">&nbsp;</TD><cfset colCount = colCount + 1 />
	</cfif>
	</TR>
	<cfif appSettings.getFreight_Calculator_On()>
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<tr><td colspan="100%" align="right" style="font-size:12px;font-weight:bold;">Freight Estimate&nbsp;&nbsp; <input type="text" id="marginFreightCalc" name="marginFreightCalc" onBlur="javascript:calcFreight();" size="3" width="25px"> % <span id="marginFreightCalcTarget" style="margin-left:25px;">&nbsp;&nbsp;&nbsp;&nbsp;</span></td></tr>
		</cfif>
	</cfif>
<!--- End New Summary --->
</cfoutput>

<!------ display the pullback checkbox ----->
<cfif bPullbackAvailable>
<!------ 
Different possible scenario
- pullback already approved
- pullback not approved and user do not have approval right for this template
- pullback not approved and user do have approval right for this template
----->

<cfset pullbackBgColor = "gray" />
<cfset pullbackCheckDisabled = " disabled" />
<cfset pullbackCheckChecked = "" />
<cfif bUserCanApprovePullbackForThisPgm>
	<cfset pullbackBgColor = "ffdead" />
	<cfset pullbackCheckDisabled = "" />
</cfif>
<cfif bPullbackApproved>
	<cfset pullbackCheckChecked = " checked" />
	<cfset pullbackCheckDisabled = " disabled" />
</cfif>

<!------ If pullback not yet approved and needs approval ----->
<cfif bPullbackAvailable AND NOT bPullbackApproved>		
	<cfif bUserCanApprovePullbackForThisPgm EQ 1>
		<cfif button_label EQ "Approve">
			<cfset bApprovingPullbackApprovesProgram = 1 /><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->	
		</cfif>	
	</cfif>
</cfif>

<TR>
	<td colspan="100%">&nbsp;</td>
</TR>
<cfoutput>
<TR>
	<TD bgcolor="#pullbackBgColor#" id="header"><b>Approve #appSettings.getPullbackLabel()#</b></TD>
	<TD bgcolor="#pullbackBgColor#" colspan="#colCount#">&nbsp;</TD>
	<TD bgcolor="#pullbackBgColor#"><input type="checkbox" name="Approve_Pullback" value="1" #pullbackCheckDisabled# #pullbackCheckChecked# <cfif bApprovingPullbackApprovesProgram>onPropertyChange="javaScript:changeApproveLabel(this.checked);"</cfif>></TD>
	<TD bgcolor="#pullbackBgColor#"><span class="title6">Approve</span></TD>
	<TD bgcolor="#pullbackBgColor#">
	<CFIF bPullbackApproved>
		<IMG SRC="/images/Layered_Approval/Gaya_i11.gif" onmouseover="initTheTooltip('#sPullbackApprovedMessage#')" onmouseout="popOut()" />
	<CFELSE>
		<IMG SRC="/images/Layered_Approval/Gaya_i12.gif" />
	</CFIF>
	</TD>
</TR>
</cfoutput>
</cfif>

</TABLE>

<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 and button_label EQ "approve">
<cfinclude template="/common_files/general_labels.cfm">
<cfsavecontent variable = "save_margin_content">
	<cfoutput>
<SPAN CLASS="Title4">
[#getProgramInfo.Contract_Number#] : #getProgramInfo.Contract_Title#
<BR>
#general_labels[ delivery_period ]#: #DateFormat(getProgramInfo.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(getProgramInfo.Contract_End_Date, "mm/dd/yyyy")#
#margin_content#
</SPAN></cfoutput>
</cfsavecontent>

<CFSET save_margin_content = REReplaceNoCase(save_margin_content, "<a[^>]*?>", "", "All")>
<CFSET save_margin_content = REReplaceNoCase(save_margin_content, "</a>", "", "All")>
<CFSET save_margin_content = REReplaceNoCase(save_margin_content, "display:visible", "display:none", "All")>

<cflock timeout="10" type="exclusive">
				<cffile action="write" file="#Application.Doc_Path#\Data_Files\Margins\#contract_main_id#_Margin.htm" output="#save_margin_content#">
			</cflock>
</cfif>
	<cfif form.RestrictedList neq "" and ( form.AgreeList neq "" or form.ApproveList neq "" ) >
		<cfloop list="#form.RestrictedList#" index="restrictedItem">
			<cfif form.AgreeList neq "" and ListFind(form.AgreeList, restrictedItem) gt 0 >
				<cfset form.AgreeList = ListDeleteAt(form.AgreeList, ListFind(form.AgreeList, restrictedItem)) >
			</cfif>
			<cfif form.ApproveList neq "" and ListFind(form.ApproveList, restrictedItem) gt 0 >
				<cfset form.ApproveList = ListDeleteAt(form.ApproveList, ListFind(form.ApproveList, restrictedItem)) >
			</cfif>
		</cfloop>
	</cfif>
	<input type="hidden" name="programid" value="<cfoutput>#url.CID#</cfoutput>">
	<input type="hidden" name="ProgramIsARevision" value="<cfoutput>#getProgramInfo.Is_A_Revision#</cfoutput>">
	<input type="hidden" name="AllowRetroRevision" value="<cfoutput>#getSettings.ALLOW_RETRO_REVISION#</cfoutput>">
	<input type="hidden" name="MaxDuration" value="<cfoutput>#getSettings.max_duration#</cfoutput>">
	<input type="hidden" name="Allow_Retro_Revision_Span" value="<cfoutput>#getSettings.Allow_Retro_Revision_Span#</cfoutput>">
	<input type="hidden" name="Business_considerations" value="">
	<input type="hidden" name="AgreeList" value="<cfoutput>#form.AgreeList#</cfoutput>">
	<input type="hidden" name="ApproveList" value="<cfoutput>#form.ApproveList#</cfoutput>">
	<input type="hidden" name="RestrictedList" value="<cfoutput>#form.RestrictedList#</cfoutput>">
	<input type="hidden" name="preAgreeList" value="<cfoutput>#form.preAgreeList#</cfoutput>">
	<input type="hidden" name="preApproveList" value="<cfoutput>#form.preApproveList#</cfoutput>">
	<input type="hidden" name="preRestrictedList" value="<cfoutput>#form.preRestrictedList#</cfoutput>">
	<!--- Dev Note: KAL; 8891 --->
	<input type="hidden" name="userName" value="">
	<input type="hidden" name="evalAction" value="">
	<input type="hidden" name="notes" value="N/A">
	<input type="hidden" name="mode" value="">
	<input type="hidden" name="Contract_Number" value="">
	<input type="hidden" name="NoteType" value="2">
	<input type="hidden" name="reject" value="0">	
</form>

<script>
function submitMarginForm()
{
	document.MyForm.action = "layered_approval_include.cfm?groupCheckStatusChange=1&CID=<cfoutput>#URL.CID#</cfoutput>"
	MyForm.submit();
}
</script>

<!--- Freight Calc Js --->
	<script type="text/javascript">
	function calcFreight(){
		var totalBaseSales = <cfoutput>#tempABS_BaseSales#</cfoutput>;
		var percentage = parseInt(document.all.marginFreightCalc.value);
		if(isNaN(percentage))
		{
			document.all.marginFreightCalcTarget.innerText =  0;
			document.all.marginFreightCalc.value = 0;
		}
		else
		{
			if (percentage > 1000 || percentage < 0)
			{
				document.all.marginFreightCalc.value = 0;
			}
			else
			{
				document.all.marginFreightCalcTarget.innerText =  "$" + FormatTextWithCommas(parseInt((percentage * .01) * totalBaseSales));
			}
		}
	}
	
	//function to add commas to a given string -  TODO: Put this in a .js file where it can be accessed everywhere
	function FormatTextWithCommas(oText) {
		var nf = new NumberFormat();
		nf.setNumber(oText);
		nf.setCommas(true);
		nf.setCurrency(false);
		nf.setPlaces(0);
		return nf.toFormatted()
	}
	</script>
	
	<script language="JavaScript" type="text/javascript" src="/script/javascript/string_functions.js"></script>
<!--- End Freight Calc Js --->