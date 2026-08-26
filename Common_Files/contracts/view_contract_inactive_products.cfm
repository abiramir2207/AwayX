<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfparam name="url.ContractID" default="">
<cfif url.ContractID NEQ "">

<!---
From 6.1 onwards the routine will be doing the copy and we will not be using teh wddx way
Info will be stored in below tables
Program_Copy_Removed_Product 
--->
<CFSET The_File_Location = Application.Doc_Path & "\Data_Files\Created\Program_Inactive_Products\#url.ContractID#.xml">
 <cfif FileExists(The_File_Location)>
<CFFILE ACTION="READ" FILE="#The_File_Location#" VARIABLE="Packet_Data">
	<CFWDDX ACTION="WDDX2CFML" INPUT="#Packet_Data#" OUTPUT="Products_Packet">

	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Inactive Records Removed</B></TD>
		</TR>
	</TABLE>
	<CFSET ThisStructureLevel = Products_Packet.Products>
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" width="350" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
		<CFIF ThisStructureLevel.recordcount GT 0>
		<cfoutput>
		<tr><td BGCOLOR ="FFE083" colspan="100%"><strong>Products Removed</strong></td></tr>
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.item_label#</B></TD>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.upc_label#</B></TD><cfelse><TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;</td></cfif></cfif>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Description</B></TD>
		</TR></cfoutput>
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
			<CFSET item = evaluate("ThisStructureLevel.Item_#LoopCount#")>
			<CFSET upc = evaluate("ThisStructureLevel.upc_#LoopCount#")>
			<CFSET description = evaluate("ThisStructureLevel.description_#LoopCount#")>
			<CFSET isgroup = evaluate("ThisStructureLevel.is_group_#LoopCount#")>
			<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfif isgroup eq 1>
			Group
			<cfelse>
			#item#
			</cfif>
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfif isgroup eq 1>
			Group
			<cfelse>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#upc#<cfelse>&nbsp;</cfif></cfif>
			</cfif>
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#description#
			</td>
			</tr></cfoutput>
		</CFLOOP>
		<cfelse>
<TR>
			<TD colspan="100%" STYLE="border-bottom: 1px ##93BEE2 solid;"><B>No Products Removed</B></TD>
</TR>
		</CFIF>
<tr><td colspan="100%"><hr color="Navy"></td></tr>
		<CFSET ThisStructureLevel = Products_Packet.Distributors>
		<CFIF ThisStructureLevel.recordcount GT 0>
		<cfoutput>
		<tr><td BGCOLOR ="FFE083" colspan="100%" >
<strong>#application.returned_customer_setting.distributor_label_plural# Removed</strong></td></tr>
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Name</B></TD>
		</TR></cfoutput>
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
			<CFSET ship_to = evaluate("ThisStructureLevel.shr_ship_to_#LoopCount#")>
			<CFSET description = evaluate("ThisStructureLevel.name_#LoopCount#")>
			<cfparam name="ThisStructureLevel.is_group_#LoopCount#" default="0">
			<CFSET isgroup = evaluate("ThisStructureLevel.is_group_#LoopCount#")>
			<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfif isgroup eq 1>
			Group
			<cfelse>
			#ship_to#
			</cfif>
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#description#
			</td>
			</tr></cfoutput>
		</CFLOOP>
		<cfelse>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;" colspan="100%"><B>No <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> Removed</B></TD>
</TR>
		</CFIF>		
<tr><td colspan="100%"><hr color="Navy"></td></tr>
		<CFSET ThisStructureLevel = Products_Packet.Operators>
		<CFIF ThisStructureLevel.recordcount GT 0>
		<cfoutput>
		<tr><td BGCOLOR ="FFE083" colspan="100%"><strong>#application.returned_customer_setting.operator_label_plural# Removed</strong></td></tr>
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Operator Id</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Legacy Id</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Name</B></TD>
		</TR></cfoutput>
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
			<CFSET opr_id = evaluate("ThisStructureLevel.BSA_Operator_id_#LoopCount#")>
			<CFSET legacy_id = evaluate("ThisStructureLevel.legacy_id_#LoopCount#")>
			<CFSET description = evaluate("ThisStructureLevel.operator_name_#LoopCount#")>
			<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			#opr_id#
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			#legacy_id#
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#description#
			</td>
			</tr></cfoutput>
		</CFLOOP>
		<cfelse>
<TR>
			<TD colspan="100%" STYLE="border-bottom: 1px ##93BEE2 solid;"><B>No <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> Removed</B></TD>
</TR>
		</CFIF>		
</table>
<cfelse>
	<CFQUERY NAME="qGetContractProductsRemoved" datasource="#application.datasource#">
		SELECT	*
		FROM	Program_Copy_Removed_Product
		WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.ContractID#"> 
	</CFQUERY>
	<CFQUERY NAME="qGetContractDistributorsRemoved" datasource="#application.datasource#">
		SELECT	*
		FROM	Program_Copy_Removed_Distributor
		WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.ContractID#"> 
	</CFQUERY>
	<CFQUERY NAME="qGetContractOperatorsRemoved" datasource="#application.datasource#">
		SELECT	*
		FROM	Program_Copy_Removed_Operator
		WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.ContractID#"> 
	</CFQUERY>

	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Inactive Records Removed</B></TD>
		</TR>
	</TABLE>
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" width="350" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
		<!--- **************** Products Removed *************************** --->
		<CFIF qGetContractProductsRemoved.recordcount GT 0>
		<cfoutput>
		<tr><td BGCOLOR ="FFE083" colspan="100%"><strong>Products Removed</strong></td></tr>
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.item_label#</B></TD>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.upc_label#</B></TD><cfelse><TD STYLE="border-bottom: 1px ##93BEE2 solid;">&nbsp;</td></cfif></cfif>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Description</B></TD>
		</TR>
		</cfoutput>
		<CFLOOP query="qGetContractProductsRemoved">
			<CFSET item = qGetContractProductsRemoved.item />
			<CFSET upc = qGetContractProductsRemoved.upc />
			<CFSET description = qGetContractProductsRemoved.description />
			<CFSET isgroup = qGetContractProductsRemoved.is_group />
			<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfif isgroup eq 1>
			Group
			<cfelse>
			#item#
			</cfif>
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfif isgroup eq 1>
			Group
			<cfelse>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#upc#<cfelse>&nbsp;</cfif></cfif>
			</cfif>
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#description#
			</td>
			</tr></cfoutput>
		</CFLOOP>
		<cfelse>
			<TR>
			<TD colspan="100%" STYLE="border-bottom: 1px ##93BEE2 solid;"><B>No Products Removed</B></TD>
			</TR>
		</CFIF>
		<!--- **************** Distributors Removed *************************** --->
		<tr><td colspan="100%"><hr color="Navy"></td></tr>
		<CFIF qGetContractDistributorsRemoved.recordcount GT 0>
		<cfoutput>
		<tr><td BGCOLOR ="FFE083" colspan="100%">
		<strong>#application.returned_customer_setting.distributor_label_plural# Removed</strong>
		</td></tr>
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;" colspan="2"><B>Name</B></TD>
		</TR></cfoutput>
		<CFLOOP query="qGetContractDistributorsRemoved">
			<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfif is_group eq 1>
			Group
			<cfelse>
			#shr_ship_to#
			</cfif>
			</td>
			<TD colspan="2" STYLE="border-bottom: 1px ##93BEE2 solid;">#name#
			</td>
			</tr></cfoutput>
		</CFLOOP>
		<cfelse>
			<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;" colspan="100%"><B>No <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> Removed</B></TD>
			</TR>
		</CFIF>
		<!--- **************** Operators Removed *************************** --->
		<tr><td colspan="100%"><hr color="Navy"></td></tr>
		<CFIF qGetContractOperatorsRemoved.recordcount GT 0>
		<cfoutput>
		<tr><td BGCOLOR ="FFE083" colspan="100%"><strong>#application.returned_customer_setting.operator_label_plural# Removed</strong></td></tr>
		<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Operator Id</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Legacy Id</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Name</B></TD>
		</TR></cfoutput>
		<CFLOOP query="qGetContractOperatorsRemoved">
			<cfoutput><TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			#bsa_operator_id#
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
			#legacy_id#&nbsp;
			</td>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">#operator_name#
			</td>
			</tr></cfoutput>
		</CFLOOP>
		<cfelse>
<TR>
			<TD colspan="100%" STYLE="border-bottom: 1px ##93BEE2 solid;"><B>No <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> Removed</B></TD>
</TR>
		</CFIF>
		</TABLE>
 </cfif> 
</cfif>

</body>
</html>
