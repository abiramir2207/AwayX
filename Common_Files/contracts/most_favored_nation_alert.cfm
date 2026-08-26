<!---
	Name:          	most_favored_nation_alert.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	07/22/2014
	Created By:    	Tim Ford
	Description:   	Page to display for MFN Display
	Usage:
--->

<title>Most Favored Nation Display</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<body>
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<cfset nProgramRebateSums 	= 0 />
<cfset nProgramFixedSums 	= 0 />
<cfset nMFNRebateSums 		= 0 />
<cfset nMFNFixedSums 		= 0 />
<cfset useCommonUOM			= 1 />
<cfset useCommonUOMDesc		= "/CS" />

<!--- If top 1 row is in LB we will use LB, actually either CS or LB should work --->
<cfif qMFNConflicts.Current_Program_UOM_ID eq 2>
	<cfset useCommonUOM			= 2 />
	<cfset useCommonUOMDesc		= "/LB" />
</cfif>
<cfquery name="qGetRebateSums" dbtype="query">
	select 	<cfif useCommonUOM eq 1>
			sum(Current_Program_CS) as Rebate_Sum, sum(MFN_Price_CS) as MFN_Rebate_Sum 
			<cfelse>
			sum(Current_Program_LB) as Rebate_Sum, sum(MFN_Price_LB) as MFN_Rebate_Sum 
			</cfif>
	from qMFNConflicts where Component_Type = 2
</cfquery>

<cfquery name="qGetFixedSums" dbtype="query">
	select 	<cfif useCommonUOM eq 1>
			sum(Current_Program_CS) as Fixed_Sum, sum(MFN_Price_CS) as MFN_Fixed_Sum
			<cfelse>
			sum(Current_Program_LB) as Fixed_Sum, sum(MFN_Price_LB) as MFN_Fixed_Sum
			</cfif> 
	from qMFNConflicts where Component_Type = 1
</cfquery>

<cfif isNumeric(qGetRebateSums.Rebate_Sum)>
	<cfset nProgramRebateSums = qGetRebateSums.Rebate_Sum />
</cfif>
<cfif isNumeric(qGetRebateSums.MFN_Rebate_Sum)>
	<cfset nMFNRebateSums = qGetRebateSums.MFN_Rebate_Sum />
</cfif>
<cfif isNumeric(qGetFixedSums.Fixed_Sum)>
	<cfset nProgramFixedSums = qGetFixedSums.Fixed_Sum />
</cfif>
<cfif isNumeric(qGetFixedSums.MFN_Fixed_Sum)>
	<cfset nMFNFixedSums = qGetFixedSums.MFN_Fixed_Sum />
</cfif>
<b>Program conflicts with MFN program<b>
<br>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="50%" CLASS="datagrid" id="compList">
	<thead>
	<tr>
		<th>Current Program Number</th>
		<th>Item</th>
		<th>Current Program Rebate</th>
		<th>Current Program Fixed Price</th>
		<th>Current Program Total Discount</th>
		<th>MFN Program Number</th>
		<th>MFN Program Rebate</th>
		<th>MFN Program Fixed Price</th>
		<th>MFN Program Total Discount</th>
		<th>Variance</th>
	</tr>
	</thead>
	<tbody>
		<cfoutput query="qMFNConflicts">
		<cfset nProgramSum = nProgramFixedSums - nProgramRebateSums />
		<cfset nMFNProgramSum = nMFNFixedSums - nMFNRebateSums />
		
		<cfset useMFNPrice = 0 />
		<cfif Current_Program_UOM_ID eq 1> <!--- cs --->
			<cfset useMFNPrice = MFN_Price_CS />
		<cfelse> <!--- lb --->
			<cfset useMFNPrice = MFN_Price_LB />
		</cfif>
			
		<cfif Component_Type eq 2>
			<cfset variance = useMFNPrice - Current_Program_Price />
		<cfelse>
			<cfset variance = Current_Program_Price - useMFNPrice />
		</cfif>
		<TR>
			<td>#Current_Program_Number#</td>
			<td>#item#</td>
			<td><cfif Component_Type eq 2>#DollarFormat(Current_Program_Price)##Current_Program_UOM#</cfif></td>
			<td><cfif Component_Type eq 1>#DollarFormat(Current_Program_Price)##Current_Program_UOM#</cfif></td>
			<td>#DollarFormat(nProgramSum)##useCommonUOMDesc#</td>
			<td>#MFN_Program_Number#</td>
			<td><cfif Component_Type eq 2>#DollarFormat(useMFNPrice)##Current_Program_UOM#</cfif></td>
			<td><cfif Component_Type eq 1>#DollarFormat(useMFNPrice)##Current_Program_UOM#</cfif></td>
			<td>#DollarFormat(nMFNProgramSum)##useCommonUOMDesc#</td>
			<td>#DollarFormat(variance)##Current_Program_UOM#</td>
		</TR>
		</cfoutput>
	</tbody>
</table>

<table align="center">
	<tr>
		<td>
			<CF_button
				button_name		=	"continue"
				button_caption	=	"continue"
				button_action	=	"contract_approve_broker_action.cfm?CID=#FORM.ApproveContract#&mfnComplete=1"
				button_type		=	"link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"continue with the application"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
		<td>
			<CF_button
				button_name		=	"cancel"
				button_caption	=	"cancel"
				button_action	=	"contract_edit_menu.cfm?CID=#FORM.ApproveContract#"
				button_type		=	"link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"continue with the application"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
</table>



</body>