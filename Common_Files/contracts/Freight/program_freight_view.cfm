<LINK REL="STYLESHEET" TYPE="text/css" HREF="scroll_bars.css">
<cfinclude template="program_freight_display_header.cfm" />
<div id="table_container">
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="ffce84" class="maintable">
	<tr>
		<td id="header" width="30%" class="locked_top"><b><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></b></td>
		<td id="header" class="locked_top"><b>Weight</b></td>
		<td id="header" class="locked_top"><b>Warehouse</b></td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td id="header" class="locked_top"><b>Bracket</b></td>
	</cfif>
		<td id="header" class="locked_top"><b>IBF/cwt</b></td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td id="header" class="locked_top"><b>OBF/cwt</b></td>
		<td id="header" class="locked_top"><b>PUA/cwt</b></td>
	</cfif>
		<td id="header" class="locked_top"><b>Frt.Adj</b></td>
	</tr>
	<cfset zeroFreight = 0 />
	<cfoutput query="qProgramDistributorFreight">
	<cfset totalFreight = IBF_Rate />
	<tr bgcolor="#IIf(currentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<td valign="top">#Name#&nbsp;#Shr_Ship_to#<br />#City#&nbsp;#State#&nbsp;#ZipCode#</td>
		<td valign="top">#Program_Weight#%</td>
		<td valign="top">
			#Warehouse_Name#&nbsp;&nbsp;
			<span <cfif Overridden_Warehouse_Master_ID eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>>*</span>
			<br />#Warehouse_Address_1#<cfif Warehouse_Address_2 neq ""><br />#Warehouse_Address_2#</cfif>
			<br />#Warehouse_City#,#Warehouse_State#&nbsp;#Warehouse_Zip#
		</td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td valign="top">#Freight_Bracket_Label#
		<sup 
			<cfif Overridden_Freight_Bracket_Setting_ID eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
			>*</sup>
		</td>
	</cfif>
		<td valign="top" <cfif IBF_Rate eq 0>class="zeroValue"</cfif>>#IBF_Rate#
		<sup 
			<cfif Overridden_IBF_Rate eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
			>*</sup>
		</td>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<cfset totalFreight = totalFreight + OBF_Rate />
		<td valign="top" <cfif OBF_Rate eq 0>class="zeroValue"</cfif>>#OBF_Rate#
		<sup 
			<cfif Overridden_OBF_Rate eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
			>*</sup>
		</td>
		<td valign="top" <cfif Pickup_Allowance eq 0>class="zeroValue"</cfif>>#Pickup_Allowance#
		<sup 
			<cfif Overridden_Pickup_Allowance eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
			>*</sup>
		</td>
	</cfif>
		<td valign="top" <cfif Freight_Adjustment eq 0>class="zeroValue"</cfif>>#Freight_Adjustment#
		<sup 
			<cfif Freight_Adjustment>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
			>*</sup>
		</td>
	
	</tr>
	<cfif totalFreight EQ 0>
		<cfset zeroFreight = 1 />
	</cfif>
	</cfoutput>
</table>
</div>
<br>
<cfinclude template="program_freight_buttons.cfm" />