   

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
<cfparam name="Noitems" default="false">


<CFSTOREDPROC PROCEDURE="DISPOSABLE_MARGIN" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(contract_main_id)#" NULL="No">
</CFSTOREDPROC>

<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(contract_main_id,request.AccessStructure.profiles_id)>

<cfif getAllProductMargins.recordcount GT 0>
<cfset Noitems = "false">
<cfset getAllGroupMargins = ApprovalProgramManager.getAllGroupMargins(contract_main_id,request.AccessStructure.Profiles_ID)>

<cfelse>
	<cfset Noitems = "true">
	<CFSTOREDPROC PROCEDURE="INSERT_FAMILY_GROSS_MARGIN_DISPOSABLE" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(contract_main_id)#" NULL="No">
</CFSTOREDPROC>
	<cfset getAllGroupMargins = ApprovalProgramManager.getAllGroupMargins(contract_main_id,request.AccessStructure.profiles_id)>
</cfif>
 
<cfset getProgramMargins  = ApprovalProgramManager.getProgramMargins(contract_main_id)>

<cfset totalprogramvolumeUOM = "CS">


<!--- check growthapproval --->
<TABLE CLASS="Maintable" CELLPADDING="4" CELLSPACING="0" WIDTH="100%" border="0">
 <TR> 
	<TD COLSPAN="100%" align="left" style="color:red;font-size:11px;">
	<!---D50860 :: Release 8.0 - Improvements to the ‘View Margin’ page inside a program START --->
		<cfif isDefined("ProgramIsARevision") AND ProgramIsARevision NEQ 0>
			<div style="float:left;margin-right:80px;">*** NOTE: This Is A Revision Of An Existing Program ***</div>
		</cfif>
		<cfif isDefined("MarginDate")>
			<div style="float:left;">#MarginDate#</div>
		</cfif>
	<!---D50860 :: Release 8.0 - Improvements to the ‘View Margin’ page inside a program END --->
	</TD>
</TR>
<TR> 
	 <TD VALIGN="bottom" COLSPAN="100%" >&nbsp;</td>
</TR>
  <TR BGCOLOR="FFCE84" VALIGN="top"> 
<!---   check if they can see the base view --->
  <cfif Get_Profile_Settings.Base_View EQ 1>
    	<TD ID="header" VALIGN="top" WIDTH="250"><B>Description</B></TD>
		<cfif direct_pricing EQ 1>
		<TD ID="header" valign="top"><B>Stock Price</B></TD>	
		</cfif>
    	 <TD ID="header" valign="top" NOWRAP align="center">
		<B>Annual<BR>
		Vol.<cfoutput>#totalprogramvolumeUOM#</cfoutput></B></TD>
 
    	<TD ID="header" valign="top"><B>Gross Sales</B></TD>
		<cfif direct_pricing EQ 0>
   		<TD ID="header" valign="top"><B>Cash Dis.</B></TD>	
    	<TD ID="header" valign="top" ><B>Allow.</B></TD>
		</cfif>
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
		<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND (approvaltype EQ 1 OR agreetype EQ 1)>
		<TD ID="header" valign="top" ALIGN="right"><input type="checkbox" value="1" name="checkall" ONCLICK="selectAll()"></td>
		<TD ID="header" valign="top" ><B>Approve/ Agree</B></TD>  
		<TD ID="header" valign="top">&nbsp;</td> </cfif>
		</TR>
	<cfset count = 0>

<cfif noitems eq "false">
<!---  WHEN ITEMS ARE FOUND --->
<cfoutput query="getAllProductMargins" group="group_id">
	<CFQUERY name="getAllGroupvalues" dbtype="query">
	select * from getAllGroupMargins
	where group_id = '#getAllProductMargins.group_id#'
	</CFQUERY>
	<!--- add variation to group margin --->
	<cfif trim(getAllGroupvalues.Group_ID_Margin) EQ "">
		<cfset getAllGroupvalues.Group_ID_Margin = 0>
	</cfif>
	<cfif trim(getAllGroupvalues.Group_ID_Margin) NEQ "*" and trim(getAllGroupvalues.Group_ID_Margin) NEQ "">
		<cfset groupapprovalmargin = Target_Margin - ((Target_Margin * getAllGroupvalues.Group_ID_Margin)/100)>
	<cfelse>
		<cfset groupapprovalmargin = "*">
	</cfif>
	
	<!--- check if group margin is within limits --->
	<CFIF getAllGroupvalues.Total_OperatingMargin_percent LT groupapprovalmargin  AND Trim(getAllGroupvalues.Group_ID_Margin) NEQ "*">
		<CFSET CannotApproveGroupMargin = 1>
		<cfset CannotApproveItemMargin = 1>
		<CFIF getAllGroupvalues.Group_ID_Approval EQ 1>
			<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #getAllGroupvalues.group_name#.")>
		</CFIF>
	</CFIF>
	
	<CFIF getAllGroupvalues.Group_ID_Approval EQ 0>
		<CFSET CannotApproveGroupMargin = 1>
			<cfset disablecheckbox = "disabled">
			<cfset temp = ArrayAppend(messageArray, "You cannot approve #getAllGroupvalues.group_name#")>
			<cfset grouptrbgcolor = "gray">
			<cfset itemtrbgcolor ="gray">
	</CFIF>
	 
	<cfoutput>	
	<CFIF getAllGroupvalues.Group_ID_Approval EQ 0>
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
	<cfif direct_pricing EQ 1>
	<td>
		$#trim(numberformat(stock_price,'_-___,___,___,___,___.__'))#
	</td>
	</cfif>
	<td align="center">
	 #trim(numberformat(Round(Product_Program_Volume),'_-___,___,___,___,___'))#
	</td>
	<td>
		$#trim(numberformat(Base_Sales,'_-___,___,___,___,___.__'))#
	</td>
	<cfif direct_pricing EQ 0>
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
	</td></cfif>
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
		<cfif groupapprovalmargin LT 0 and groupapprovalmargin NEQ "*">
		<span STYLE="color: red;">
		<cfset approvalmargin1 = (groupapprovalmargin) * (-1)>
		[#trim(numberformat(approvalmargin1,'_-___,___,___,___,___._'))#%]
		<cfelse>
			<cfif groupapprovalmargin eq "*">
				#trim(numberformat(Target_Margin,'_-___,___,___,___,___._'))#%
			<cfelse>
				#trim(numberformat(groupapprovalmargin,'_-___,___,___,___,___._'))#%
			</cfif>
		
		</cfif>
	</A>
	</TD>

<!--- check if the program is RFA only then display the check boxes --->
<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2  AND (approvaltype EQ 1 OR agreetype EQ 1)>
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

</cfoutput>
<!--- <CFQUERY name="getAllGroupValues" dbtype="query">
	select * from getAllGroupMargins
	where group_id = '#group_id#'
</CFQUERY> --->
<TR bgcolor="#grouptrbgcolor#">
	<CFLOOP query="getAllGroupValues">
<cfif Get_Profile_Settings.Base_View EQ 1>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">#group_name#</TD>
	<cfif direct_pricing EQ 1>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">&nbsp;</TD>
	</cfif>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="center">
	#trim(numberformat(Round(Total_Product_Program_Volume),'_-___,___,___,___,___'))#
	</TD>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		$#trim(numberformat(Total_Base_Sales,'_-___,___,___,___,___.__'))#
	</TD>
	<cfif direct_pricing EQ 0>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		$#trim(numberformat(Total_Cash_discount,'_-___,___,___,___,___.__'))#
	</TD>
	<td>
	 <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','A')"> 
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
	<CFIF ShowTPA EQ 1>
	<td>
		<!--- <A STYLE="cursor:pointer;"
ONCLICK="showTradeCalculation('#replace(Group_Id, "-", "_", "ALL")#')"> --->
		<cfif Total_TPA LT 0>
		<span STYLE="color: red;">
			<cfset TPA_Neg = (Total_TPA) * (-1)>
			[$#trim(numberformat(TPA_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(Total_TPA,'_-___,___,___,___,___.__'))#
		</cfif>
		<!--- </A> --->
	</td>
	</CFIF>
	<td>
		 <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','N')">
		<cfif Total_Net_Sales LT 0>
		<span STYLE="color: red;">
			<cfset Net_Sales_Neg = (Total_Net_Sales) * (-1)>
			[$#trim(numberformat(Net_Sales_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>	
			$#trim(numberformat(Total_Net_Sales,'_-___,___,___,___,___.__'))#
		</CFIF>
		 </A> 
	</td>
</CFIF>
<cfif Get_Profile_Settings.View_Cost EQ 1>
	<td>
		<!---  <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','C1','')"> --->
		$#trim(numberformat(Total_Cost1,'_-___,___,___,___,___.__'))#<!--- </A> --->
	</td>

	<td> <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','CM','')"> 
		<cfif Total_Contribution_Margin LT 0>
		<span STYLE="color: red;">
			<cfset Contribution_Margin_Neg = (Total_Contribution_Margin) * (-1)>
			[$#trim(numberformat(Contribution_Margin_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Total_Contribution_Margin,'_-___,___,___,___,___.__'))#
		</cfif></A>
		</td>
	<td>
		<cfif Total_Contribution_Margin_percent LT 0>
		<span STYLE="color: red;">
		<cfset ContributionMarginpercent = (Total_Contribution_Margin_percent) * (-1)>
	[#trim(numberformat(Round(ContributionMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif Total_Contribution_Margin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(Total_Contribution_Margin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</td>
	<td>
		<!---  <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','C2','')"> --->
		$#trim(numberformat(Total_Cost2,'_-___,___,___,___,___.__'))# <!--- </A> --->
	</td>
</cfif>
<td><A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','GP','')"> 
		<cfif Total_Operating_Income LT 0>
		<span STYLE="color: red;">
			<cfset Operating_Income_Neg = (Total_Operating_Income) * (-1)>
			[$#trim(numberformat(Operating_Income_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Total_Operating_Income,'_-___,___,___,___,___.__'))#
		</cfif> </A>
		</td>
	<td>
		<cfif Total_OperatingMargin_percent LT 0>
		<span STYLE="color: red;">
		<cfset OperatingMarginpercent = (Total_OperatingMargin_percent) * (-1)>
	[#trim(numberformat(Round(OperatingMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif Total_OperatingMargin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(Total_OperatingMargin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</td>
	<cfset approvalmargin = groupapprovalmargin>
	
	 <CFIF Total_OperatingMargin_percent LT approvalmargin AND approvalmargin NEQ "*">
		<CFSET CannotApproveItemMargin = 1>
		<CFSET CannotApproveGroupMargin = 1>
			<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Group_name# #Group_legacy#.")>
	</CFIF> 
	
	<TD align="right">
		<CFIF CannotApproveItemMargin EQ 1>
		<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
		<cfelse>
		&nbsp;
		</cfif> 
	</TD>
	<TD align="left">
		<A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','T')">
		<cfif approvalmargin LT 0 and approvalmargin NEQ "*">
		<span STYLE="color: red;">
		<cfset approvalmargin1 = (approvalmargin) * (-1)>
		[#trim(numberformat(approvalmargin1,'_-___,___,___,___,___._'))#%]
		<cfelse>
			<cfif approvalmargin eq "*">
				#trim(numberformat(Target_Margin,'_-___,___,___,___,___._'))#%
			<cfelse>
				#trim(numberformat(approvalmargin,'_-___,___,___,___,___._'))#%
			</cfif>
		
		</cfif>
	</A> 
	</TD>
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2  AND (approvaltype EQ 1 OR agreetype EQ 1)>
<!--- <cfquery name="getgroupapprovalrights" dbtype="query">
select Group_ID_Approval
from getAllGroupMargins
where Type_Group_Desc_Id = '#getAllProductMargins.Type_Group_Desc_Id#'
</cfquery> --->
<!--- check if the operating margin is LT the caluclated margin - if variation is * then let them approve anything--->
	
	
<!--- get all the previous approved items  --->
	<cfquery name="getitemapprovedvalues" datasource="#application.datasource#">
			select isnull(approve,0) as item_approve,Name_Last,Name_First
			from Program_Type_Code_Approval_Info
			LEFT JOIN  _Users
			ON _Users.user_id = Program_Type_Code_Approval_Info.User_Id
			and _Users.deleted = 0
			where Type_Code_Desc_ID = '#group_id#'
			and program_id = #contract_main_id#
			and Program_Type_Code_Approval_Info.deleted = 0
			and isnull(approve,0) = 1
	</cfquery>
	<cfquery name="getitemagreedcount" datasource="#application.datasource#">
			select count(agree) as agreecount
			from Program_Type_Code_Approval_Info
			where Type_Code_Desc_ID = '#group_id#'
			and program_id = #contract_main_id#
			and Program_Type_Code_Approval_Info.deleted = 0
			and isnull(agree,0) = 1
		</cfquery>
	

	
	<!--- if the approve settings like growth and upfront funds are not allowed to be approved and if the item margin is not within limits --->
<!--- display the label either approve or label after checking all the above conditions --->
	<cfif (CannotApproveSettings EQ 0 and CannotApproveItemMargin EQ 0) OR (getitemapprovedvalues.recordcount GT 0 and getitemapprovedvalues.item_approve EQ 1)>
		<cfset feildname = "GroupApprove_#replace(group_id, "-", "_", "ALL")#">
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
		<cfset feildname = "GroupAgree_#replace(group_id, "-", "_", "ALL")#">
		<cfquery name="getitemvalues" datasource="#application.datasource#">
			select isnull(agree,0) as item_agree
			from Program_Type_Code_Approval_Info
			where Type_Code_Desc_ID = '#group_id#'
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
	
	<td ALIGN="right" valign="top">
	<span ID="checkAllProducts"><input type="checkbox" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox#></span></td>
	<td ALIGN="left" class="Title6" valign="top">
		<span class="title5">#itemlabel#</span></td>
	<td>
		<IMG SRC="/images/Layered_Approval/#imagesrc#"
		<cfif imagesrc EQ 'Gaya_i11.gif'>
onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
		<cfelseif imagesrc EQ 'Gaya_i18.gif'>
		 onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
		 onclick="showGroupCalculation('#replace(group_Id, "-", "_", "ALL")#','AG')"
		</cfif> STYLE="cursor:pointer;"></td>
</cfif>
</cfloop>
</TR>
<TR>
	<td colspan="100%" style="border-bottom: 0px solid blue;">&nbsp;</td>
</TR>
<cfset CannotApproveGroupMargin = 0>
<cfset disablecheckbox = "">
<cfset grouptrbgcolor = "CCFFCC">
<cfset itemtrbgcolor = "f4f4f4">
</cfoutput>

<cfelse>
<!--- WHEN NO ITEMS ARE FOUND --->
<CFOUTPUT query="getAllGroupMargins">
	<CFIF getAllGroupMargins.Group_ID_Approval EQ 0 OR getAllGroupMargins.Group_ID_Margin NEQ "*">
		<CFSET CannotApproveGroupMargin = 1>
			<!--- <cfset disablecheckbox = "disabled"> --->
			<cfset temp = ArrayAppend(messageArray, "You cannot approve #getAllGroupMargins.group_name#")>
			<cfset grouptrbgcolor = "gray">
			<cfset itemtrbgcolor ="gray">
	</CFIF>
	
	<cfset groupapprovalmargin = getAllGroupMargins.Group_ID_Margin>

	<TR bgcolor="#grouptrbgcolor#">
<cfif Get_Profile_Settings.Base_View EQ 1>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">#group_name# - #group_legacy#</TD>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="center">
	#trim(numberformat(Round(Total_Product_Program_Volume),'_-___,___,___,___,___'))#
	</TD>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		$#trim(numberformat(Total_Base_Sales,'_-___,___,___,___,___.__'))#
	</TD>
	<cfif direct_pricing EQ 0>
	<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#">
		$#trim(numberformat(Total_Cash_discount,'_-___,___,___,___,___.__'))#
	</TD>
	<td>
		<cfif Item_Allowance LT 0>
		<span STYLE="color: red;">
			<cfset Item_Allowance_Neg = (Item_Allowance) * (-1)>
			[$#trim(numberformat(Item_Allowance_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Item_Allowance,'_-___,___,___,___,___.__'))#
		</cfif>
	</td>
	</cfif>
	<CFIF ShowTPA EQ 1>
	<td>
		<!--- <A STYLE="cursor:pointer;"
ONCLICK="showTradeCalculation('#replace(Group_Id, "-", "_", "ALL")#')"> --->
		<cfif Total_TPA LT 0>
		<span STYLE="color: red;">
			<cfset TPA_Neg = (Total_TPA) * (-1)>
			[$#trim(numberformat(TPA_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(Total_TPA,'_-___,___,___,___,___.__'))#
		</cfif>
		<!--- </A> --->
	</td>
	</CFIF>
	<td>
		<cfif Total_Net_Sales LT 0>
		<span STYLE="color: red;">
			<cfset Net_Sales_Neg = (Total_Net_Sales) * (-1)>
			[$#trim(numberformat(Net_Sales_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>	
			$#trim(numberformat(Total_Net_Sales,'_-___,___,___,___,___.__'))#
		</CFIF>
	</td>
</CFIF>
<cfif Get_Profile_Settings.View_Cost EQ 1>
	<td>
		<!---  <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','C1','')"> --->
		$#trim(numberformat(Total_Cost1,'_-___,___,___,___,___.__'))#<!--- </A> --->
	</td>

	<td>
		<cfif Total_Contribution_Margin LT 0>
		<span STYLE="color: red;">
			<cfset Contribution_Margin_Neg = (Total_Contribution_Margin) * (-1)>
			[$#trim(numberformat(Contribution_Margin_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Total_Contribution_Margin,'_-___,___,___,___,___.__'))#
		</cfif>
		</td>
	<td>
		<cfif Total_Contribution_Margin_percent LT 0>
		<span STYLE="color: red;">
		<cfset ContributionMarginpercent = (Total_Contribution_Margin_percent) * (-1)>
	[#trim(numberformat(Round(ContributionMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif Total_Contribution_Margin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(Total_Contribution_Margin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</td>
	<td>
		<!---  <A STYLE="cursor:pointer;"
ONCLICK="showGroupCalculation('#replace(Group_Id, "-", "_", "ALL")#','C2','')"> --->
		$#trim(numberformat(Total_Cost2,'_-___,___,___,___,___.__'))# <!--- </A> --->
	</td>
</cfif>
<td> 
		<cfif Total_Operating_Income LT 0>
		<span STYLE="color: red;">
			<cfset Operating_Income_Neg = (Total_Operating_Income) * (-1)>
			[$#trim(numberformat(Operating_Income_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(Total_Operating_Income,'_-___,___,___,___,___.__'))#
		</cfif> 
		</td>
	<td>
		<cfif Total_OperatingMargin_percent LT 0>
		<span STYLE="color: red;">
		<cfset OperatingMarginpercent = (Total_OperatingMargin_percent) * (-1)>
	[#trim(numberformat(Round(OperatingMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif Total_OperatingMargin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(Total_OperatingMargin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
	</td>
	<cfset approvalmargin = groupapprovalmargin>
	
	 <CFIF Total_OperatingMargin_percent LT approvalmargin AND approvalmargin NEQ "*">
		<CFSET CannotApproveItemMargin = 1>
		<CFSET CannotApproveGroupMargin = 1>
			<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Group_name# #Group_legacy#.")>
	</CFIF> 
	
	<TD align="right">
		<CFIF CannotApproveItemMargin EQ 1>
		<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
		<cfelse>
		&nbsp;
		</cfif> 
	</TD>
	<TD align="left">
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
	</TD>
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2  AND (approvaltype EQ 1 OR agreetype EQ 1)>
<!--- <cfquery name="getgroupapprovalrights" dbtype="query">
select Group_ID_Approval
from getAllGroupMargins
where Type_Group_Desc_Id = '#getAllProductMargins.Type_Group_Desc_Id#'
</cfquery> --->
<!--- check if the operating margin is LT the caluclated margin - if variation is * then let them approve anything--->
	
	
<!--- get all the previous approved items  --->
	<cfquery name="getitemapprovedvalues" datasource="#application.datasource#">
			select isnull(approve,0) as item_approve,Name_Last,Name_First
			from Program_Type_Code_Approval_Info
			LEFT JOIN  _Users
			ON _Users.user_id = Program_Type_Code_Approval_Info.User_Id
			and _Users.deleted = 0
			where Type_Code_Desc_ID = '#group_id#'
			and program_id = #contract_main_id#
			and Program_Type_Code_Approval_Info.deleted = 0
			and isnull(approve,0) = 1
	</cfquery>
	<cfquery name="getitemagreedcount" datasource="#application.datasource#">
			select count(agree) as agreecount
			from Program_Type_Code_Approval_Info
			where Type_Code_Desc_ID = '#group_id#'
			and program_id = #contract_main_id#
			and Program_Type_Code_Approval_Info.deleted = 0
			and isnull(agree,0) = 1
		</cfquery>
	

	
	<!--- if the approve settings like growth and upfront funds are not allowed to be approved and if the item margin is not within limits --->
<!--- display the label either approve or label after checking all the above conditions --->
	<cfif (CannotApproveSettings EQ 0 and CannotApproveItemMargin EQ 0) OR (getitemapprovedvalues.recordcount GT 0 and getitemapprovedvalues.item_approve EQ 1)>
		<cfset feildname = "GroupApprove_#replace(group_id, "-", "_", "ALL")#">
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
		<cfset feildname = "GroupAgree_#replace(group_id, "-", "_", "ALL")#">
		<cfquery name="getitemvalues" datasource="#application.datasource#">
			select isnull(agree,0) as item_agree
			from Program_Type_Code_Approval_Info
			where Type_Code_Desc_ID = '#group_id#'
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
	
	<td ALIGN="right" valign="top">
	<span ID="checkAllProducts"><input type="checkbox" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox#></span></td>
	<td ALIGN="left" class="Title6" valign="top">
		<span class="title5">#itemlabel#</span></td>
	<td>
		<IMG SRC="/images/Layered_Approval/#imagesrc#"
		<cfif imagesrc EQ 'Gaya_i11.gif'>
onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
		<cfelseif imagesrc EQ 'Gaya_i18.gif'>
		 onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
		 onclick="showGroupCalculation('#replace(group_Id, "-", "_", "ALL")#','AG')"
		</cfif> STYLE="cursor:pointer;"></td>
</cfif>
</TR>
</cfoutput>
</cfif>

<cfset colCount = 0 />
<cfoutput>
<cfif getProgramMargins.recordcount GT 0>
<!------ Program Summary start ----->
<TR>
<TD VALIGN="top" ID="Summary" nowrap>Program Summary</TD><cfset colCount = colCount + 1 />
 <cfif Get_Profile_Settings.Base_View EQ 1>
 	<cfif direct_pricing EQ 1>
	  <TD ID="Summary" valign="top" NOWRAP align="center">&nbsp;</TD><cfset colCount = colCount + 1 />
	</cfif>
  <TD ID="Summary" valign="top" NOWRAP align="center">
	#trim(numberformat(Round(getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___'))#
  </TD><cfset colCount = colCount + 1 />
 <TD ID="Summary" valign="top">$#trim(numberformat(getProgramMargins.Total_BaseSales,'_-___,___,___,___,___.__'))#</TD><cfset colCount = colCount + 1 />
		
	<cfif direct_pricing EQ 0>	
  <TD ID="Summary" valign="top"><B>$#trim(numberformat(getProgramMargins.Total_Cash_discount,'_-___,___,___,___,___.__'))#</B></TD><cfset colCount = colCount + 1 />

			
   <TD ID="Summary" valign="top" ><B><cfif getProgramMargins.TOTAL_Allowance LT 0><cfset colCount = colCount + 1 />
		<span STYLE="color: red;">
			<cfset Tot_Item_Allowance_Neg = (getProgramMargins.TOTAL_Allowance) * (-1)>
			[$#trim(numberformat(Tot_Item_Allowance_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(getProgramMargins.TOTAL_Allowance,'_-___,___,___,___,___.__'))#
		</cfif></B></TD>
	</cfif>
   <CFIF ShowTPA EQ 1>
    <TD ID="Summary" valign="top" ><cfset colCount = colCount + 1 />
	<cfif getProgramMargins.Total_TPA LT 0>
		<span STYLE="color: red;">
			<cfset Total_TPA_Neg = (getProgramMargins.Total_TPA) * (-1)>
			[$#trim(numberformat(Total_TPA_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>
			$#trim(numberformat(getProgramMargins.Total_TPA,'_-___,___,___,___,___.__'))#
		</cfif>
	</TD>
	</CFIF>
	<TD ID="Summary" valign="top" ><cfset colCount = colCount + 1 />
	<cfif getProgramMargins.Total_NetSales LT 0>
		<span STYLE="color: red;">
			<cfset Total_NetSales_Neg = (getProgramMargins.Total_NetSales) * (-1)>
			[$#trim(numberformat(Total_NetSales_Neg,'_-___,___,___,___,___.__'))#]
		<cfelse>	
			$#trim(numberformat(getProgramMargins.Total_NetSales,'_-___,___,___,___,___.__'))#
		</CFIF></TD>
 </cfif>
 <cfif Get_Profile_Settings.View_Cost EQ 1>
 <TD ID="Summary" valign="top">$#trim(numberformat(getProgramMargins.Total_Cost1,'_-___,___,___,___,___.__'))#</TD><cfset colCount = colCount + 1 />
  <TD ID="Summary" valign="top" ><cfif getProgramMargins.Total_ContributionMargin LT 0><cfset colCount = colCount + 1 />
		<span STYLE="color: red;">
			<cfset Total_ContributionMargin_Neg = (getProgramMargins.Total_ContributionMargin) * (-1)>
			[$#trim(numberformat(Total_ContributionMargin_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(getProgramMargins.Total_ContributionMargin,'_-___,___,___,___,___.__'))#
		</cfif></TD>
 <TD ID="Summary" valign="top" ><cfset colCount = colCount + 1 />
 <cfif getProgramMargins.Total_Contribution_Margin_percent LT 0>
		<span STYLE="color: red;">
		<cfset Toatl_ContributionMarginpercent = (getProgramMargins.Total_Contribution_Margin_percent) * (-1)>
	[#trim(numberformat(Round(Toatl_ContributionMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif getProgramMargins.Total_Contribution_Margin_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(getProgramMargins.Total_Contribution_Margin_percent),'_-___,___,___,___,___._'))#%
		</cfif>
		</TD>
<TD ID="Summary" valign="top">$#trim(numberformat(getProgramMargins.Total_Cost2,'_-___,___,___,___,___.__'))#</TD><cfset colCount = colCount + 1 />
 </cfif>
 <TD ID="Summary" valign="top" ><cfif getProgramMargins.Total_Operating_Income LT 0>
		<span STYLE="color: red;">
			<cfset Total_Operating_Income_Neg = (getProgramMargins.Total_Operating_Income) * (-1)>
			[$#trim(numberformat(Operating_Income_Neg,'_-___,___,___,___,___.__'))#]
		</span>
		<cfelse>
			$#trim(numberformat(getProgramMargins.Total_Operating_Income,'_-___,___,___,___,___.__'))#
		</cfif></TD><cfset colCount = colCount + 1 />
 <TD ID="Summary" valign="top" ><cfset colCount = colCount + 1 />
 		<cfif getProgramMargins.Total_Operating_percent LT 0>
		<span STYLE="color: red;">
		<cfset Total_OperatingMarginpercent = (getProgramMargins.Total_Operating_percent) * (-1)>
	[#trim(numberformat(Round(Total_OperatingMarginpercent),'_-___,___,___,___,___._'))#%]
	</SPAN>
		<cfELSEif getProgramMargins.Total_Operating_percent LT 0>
			<span STYLE="color: red;">*IDC</SPAN>
		<cfelse>
		#trim(numberformat(Round(getProgramMargins.Total_Operating_percent),'_-___,___,___,___,___._'))#%
		</cfif></TD>
			<!--- margin target --->
  <TD ID="Summary" valign="top" COLSPAN="5">&nbsp;</TD>	<cfset colCount = colCount + 2 />
</tr>
</cfif>

<!------ Program Summary end ----->
<cfif getProgramMargins.recordcount GT 0>
<!--- New Summary --->
	<TR>
	<TD VALIGN="top" nowrap></TD><cfset colCount = colCount + 1 />
	 <cfif Get_Profile_Settings.Base_View EQ 1>
	 	<cfif direct_pricing EQ 1>
		  <TD valign="top" NOWRAP align="center">&nbsp;</TD><cfset colCount = colCount + 1 />
		</cfif>
	  <TD valign="top" NOWRAP align="center">
		#trim(numberformat(Round(getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___'))#
	  </TD><cfset colCount = colCount + 1 />
	 <TD valign="top">$#trim(numberformat((getProgramMargins.Total_BaseSales  * getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#</TD><cfset colCount = colCount + 1 />
		<CFSET tempABS_BaseSales = getProgramMargins.Total_BaseSales  * getProgramMargins.Total_Product_Program_Volume />	
			
		<cfif direct_pricing EQ 0>	
	  <TD valign="top"><B>$#trim(numberformat((getProgramMargins.Total_Cash_discount  * getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#</B></TD><cfset colCount = colCount + 1 />
	
				
	   <TD valign="top" ><B><cfif getProgramMargins.TOTAL_Allowance LT 0><cfset colCount = colCount + 1 />
			<span STYLE="color: red;">
				<cfset Tot_Item_Allowance_Neg = ((getProgramMargins.TOTAL_Allowance) * (-1)) * getProgramMargins.Total_Product_Program_Volume>
				[$#trim(numberformat(Tot_Item_Allowance_Neg,'_-___,___,___,___,___.__'))#]
			</span>
			<cfelse>
				$#trim(numberformat((getProgramMargins.TOTAL_Allowance * getProgramMargins.Total_Product_Program_Volume) ,'_-___,___,___,___,___.__'))#
			</cfif></B></TD>
		</cfif>
	   <CFIF ShowTPA EQ 1>
	    <TD valign="top" ><cfset colCount = colCount + 1 />
		<cfif getProgramMargins.Total_TPA LT 0>
			<span STYLE="color: red;">
				<cfset Total_TPA_Neg = ((getProgramMargins.Total_TPA) * (-1)) * getProgramMargins.Total_Product_Program_Volume>
				[$#trim(numberformat(Total_TPA_Neg,'_-___,___,___,___,___.__'))#]
			<cfelse>
				$#trim(numberformat((getProgramMargins.Total_TPA * getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#
			</cfif>
		</TD>
		</CFIF>
		<TD valign="top" ><cfset colCount = colCount + 1 />
		<cfif getProgramMargins.Total_NetSales LT 0>
			<span STYLE="color: red;">
				<cfset Total_NetSales_Neg = ((getProgramMargins.Total_NetSales) * (-1)) * getProgramMargins.Total_Product_Program_Volume>
				[$#trim(numberformat(Total_NetSales_Neg,'_-___,___,___,___,___.__'))#]
			<cfelse>	
				$#trim(numberformat((getProgramMargins.Total_NetSales* getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#
			</CFIF></TD>
	 </cfif>
	 <cfif Get_Profile_Settings.View_Cost EQ 1>
	 <TD valign="top">$#trim(numberformat((getProgramMargins.Total_Cost1 * getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#</TD><cfset colCount = colCount + 1 />
	  <TD valign="top" ><cfif getProgramMargins.Total_ContributionMargin LT 0><cfset colCount = colCount + 1 />
			<span STYLE="color: red;">
				<cfset Total_ContributionMargin_Neg = (getProgramMargins.Total_ContributionMargin) * (-1)>
				&nbsp;
			</span>
			<cfelse>
				&nbsp;
			</cfif></TD>
	 <TD valign="top" ><cfset colCount = colCount + 1 />
	 <cfif getProgramMargins.Total_Contribution_Margin_percent LT 0>
			<span STYLE="color: red;">
			<cfset Toatl_ContributionMarginpercent = (getProgramMargins.Total_Contribution_Margin_percent) * (-1)>
		&nbsp;
		</SPAN>
			<cfELSEif getProgramMargins.Total_Contribution_Margin_percent LT 0>
				<span STYLE="color: red;">*IDC</SPAN>
			<cfelse>
			&nbsp;
			</cfif>
			</TD>
	<TD valign="top">&nbsp;</TD><cfset colCount = colCount + 1 />
	 </cfif>
	 <TD valign="top" ><cfif getProgramMargins.Total_Operating_Income LT 0>
			<span STYLE="color: red;">
				<cfset Total_Operating_Income_Neg = (getProgramMargins.Total_Operating_Income) * (-1)>
				[$#trim(numberformat((Operating_Income_Neg * getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#]
			</span>
			<cfelse>
				$#trim(numberformat((getProgramMargins.Total_Operating_Income * getProgramMargins.Total_Product_Program_Volume),'_-___,___,___,___,___.__'))#
			</cfif></TD><cfset colCount = colCount + 1 />
	 <TD valign="top" ><cfset colCount = colCount + 1 />
	 		<cfif getProgramMargins.Total_Operating_percent LT 0>
			<span STYLE="color: red;">
			<cfset Total_OperatingMarginpercent = (getProgramMargins.Total_Operating_percent) * (-1)>
		&nbsp;
		</SPAN>
			<cfELSEif getProgramMargins.Total_Operating_percent LT 0>
				<span STYLE="color: red;">*IDC</SPAN>
			<cfelse>
			&nbsp;
			</cfif></TD>
				<!--- margin target --->
	  <TD valign="top" COLSPAN="5">&nbsp;</TD>	<cfset colCount = colCount + 2 />
	</tr>

	
			<cfif appSettings.getFreight_Calculator_On()>
				<tr><td colspan="18" align="right" style="font-size:12px;font-weight:bold;">Freight Estimate&nbsp;&nbsp; <input type="text" id="marginFreightCalc" name="marginFreightCalc" onBlur="javascript:calcFreight();" size="3" width="25px"> % <span id="marginFreightCalcTarget" style="margin-left:25px;">&nbsp;&nbsp;&nbsp;&nbsp;</span></td></tr>
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

	<input type="hidden" name="programid" value="<cfoutput>#url.CID#</cfoutput>">
	<input type="hidden" name="ProgramIsARevision" value="<cfoutput>#getProgramInfo.Is_A_Revision#</cfoutput>">
	<input type="hidden" name="AllowRetroRevision" value="<cfoutput>#getSettings.ALLOW_RETRO_REVISION#</cfoutput>">
	<input type="hidden" name="MaxDuration" value="<cfoutput>#getSettings.max_duration#</cfoutput>">
	<input type="hidden" name="Allow_Retro_Revision_Span" value="<cfoutput>#getSettings.Allow_Retro_Revision_Span#</cfoutput>">
	<!--- <input type="hidden" name="groupapproval" value="0"> --->

</TABLE>
</form>
<script>
function changemarginType()
{
	document.MyForm.action = "layered_approval_include.cfm?CID=<cfoutput>#URL.CID#</cfoutput>"
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



