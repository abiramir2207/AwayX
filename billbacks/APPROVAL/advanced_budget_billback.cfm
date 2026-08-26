<!---      
	Name:          	advanced_budget_billback.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.       
	Created Date:  	09/19/2011
	Created By:    	Deepa Kunnath
	Description:   	This page is the UI for displaying [budget $ / committed $ / balance / trade spend $] inside the billback  
	Parameters:   	Billback_ID 	
	Usage:         	/billbacks/APPROVAL/advanced_budget_billback.cfm?Billback_ID=812D16A4-364F-4AEB-9CC6-515294EBD0B6
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Billback - Budget Display</title>
</head>

<body>

<cfif IsDefined("URL.Billback_ID") AND URL.Billback_ID NEQ "">

<cfquery name="qGetBillback" datasource="#application.datasource#">

	SELECT	BB_Code, BB_Title, Billback_Status_ID
	FROM	Billback
	WHERE	Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#URL.Billback_ID#">

</cfquery>

<cfset qBudgetsForBillback = CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").getBudgetsForBillback(URL.Billback_ID) />	

<style>
//TABLE..budget TD { border:none; }
.subHeading {background-color: #FFCE84; font-weight:bold; font-size:14px;}
.balanceHeader {border-top:2px solid black;border-right:2px solid black;border-left:2px solid black;border-right:2px solid black;}
#balanceRowPositive {border-left:2px solid black;border-right:2px solid black;}
#balanceRowNegative {border-left:2px solid black;border-right:2px solid black;color:red;}
#balanceLastRowPositive {border-left:2px solid black;border-right:2px solid black;border-left:2px solid black;border-bottom:2px solid black;}
#balanceLastRowNegative {border-left:2px solid black;border-right:2px solid black;border-left:2px solid black;border-bottom:2px solid black;color:red;}
</style>

<br>
<cfset tdStyle="text-align:right;padding-right:3px;font-size:12px;">
<cfoutput>
<table width="100%" class="MainTable" cellspacing="0">
<caption align="left">
<cfoutput>
Billback: [#qGetBillback.BB_Code#] #qGetBillback.BB_Title#
</cfoutput>
</caption> 
<thead>  
<tr valign="top" class="subHeading">  
<td style="font-size:12px;">Program</td>
<td style="font-size:12px;">Budget/<br>Class</td>  
<td style="font-size:12px;">Position/<br>#application.returned_customer_setting.distributor_label_singular#</td>
<td style="#tdStyle#">Budget $</td>  
<td style="#tdStyle#">Committed $</td>  
<td style="#tdStyle#">Actual $</td>
<td style="#tdStyle#" class="balanceHeader">Balance</td>
<td style="#tdStyle#">Overall<br>Constraint

	<CF_SmallHelp
		imgPath="/Images/i.gif"
		imgWidth="12"
		imgHeight="11"
		width="200"
		>
		<table>
		<tr>
		<td style="border:none;">
		<center><b>*** Overall Constraint ***</b></center><br>
		The overall constraint represents a higher level budget value beyond the amount allocated.  
		<br>The value displayed represents the balance of dollars available for additional commitments against that macro budget.  
		<br>In some scenarios, the allocated budget balance may be greater than the balance remaining in the overall budget.  
		<br>In that case, additional commitments may require special approval.
		</td>
		</tr>
		</table>
	</CF_SmallHelp>
	
</td>
<td style="#tdStyle#">Billback<br>Contribution</td>
<cfif qGetBillback.Billback_Status_ID NEQ 5>
<td style="#tdStyle#" class="balanceHeader">Balance<br>After Paid</td>
</cfif>
</tr>  
</thead>  
</cfoutput>
<cfset tdStyle="text-align:right;padding-right:3px;">
<tbody>  
<cfoutput query="qBudgetsForBillback"> 
<tr valign="top"> 
<td>#Contract_Number#<br>#Contract_Title#</td>
<td>#Budget_Desc#<br>#Budget_Class_Desc#</td> 
<td>
	<cfif Allocation_Position_Level eq 4>
	#Shr_Ship_to#<br>#Distributor_Name#
	<cfelse>
	#Position_Label#
	</cfif>
</td>
<td style="#tdStyle#"><cfif Budget_Contribution_Factor_Type_ID eq 3 and Budget_Dollar eq "">N/A<cfelse>#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Budget_Dollar)#</cfif>&nbsp;</td> 
<td style="#tdStyle#"><cfif Budget_Contribution_Factor_Type_ID eq 3 and Committed_Dollar eq "">N/A<cfelse>#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Committed_Dollar)#</cfif>&nbsp;</td> 
<td style="#tdStyle#"><cfif Budget_Contribution_Factor_Type_ID eq 3 and Actual_Dollar eq "">N/A<cfelse>#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Actual_Dollar)#</cfif>&nbsp;</td>
<td style="#tdStyle#"
	<cfif qBudgetsForBillback.currentRow eq qBudgetsForBillback.recordCount>
	<cfif Budget_Balance neq "" and Budget_Balance lt 0>id="balanceLastRowNegative"<cfelse>id="balanceLastRowPositive"</cfif>
	<cfelse> 
	<cfif Budget_Balance neq "" and Budget_Balance lt 0>id="balanceRowNegative"<cfelse>id="balanceRowPositive"</cfif>
	</cfif>
	>#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Budget_Balance)#&nbsp;</td>
<td style="#tdStyle#">&nbsp;</td>
<td style="#tdStyle#">#DollarFormat(Billback_Program_Paid_Amount)#</td>
<cfif qGetBillback.Billback_Status_ID NEQ 5>
<td style="#tdStyle#"
	<cfif qBudgetsForBillback.currentRow eq qBudgetsForBillback.recordCount>
	<cfif Budget_Balance_After_Approval neq "" and Budget_Balance_After_Approval lt 0>id="balanceLastRowNegative"<cfelse>id="balanceLastRowPositive"</cfif>
	<cfelse> 
	<cfif Budget_Balance_After_Approval neq "" and Budget_Balance_After_Approval lt 0>id="balanceRowNegative"<cfelse>id="balanceRowPositive"</cfif>
	</cfif> 
	>#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Budget_Balance_After_Approval)#&nbsp;</td>
</cfif>
</tr> 

</cfoutput>   

<tr>
<td colspan="100%" align="center" style="border:none;">
<br><br><br>
<CF_button
	button_name		=	"close"
	button_caption	=	"Close Window"
	button_action	=	"javascript:window.close();"
	button_type		=	"javascript_link"
	button_width	=	"50"
	button_color	=	"Navy"
	button_tip		=	"Close Window"
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>
</td>
</tr>
</tbody>  
</table>



</cfif>
</body>
</html>