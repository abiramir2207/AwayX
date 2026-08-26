<cfif ( row_count EQ 0 )  or ( zone_flag EQ 1 ) >
	<cfif srNotCSV> 
		<TR><TD colspan="100%" style="border:1px solid white;">&nbsp;</TD></TR>
	<cfelse>
		<cfoutput>,</cfoutput>
		<cfoutput>#chr(13)##chr(10)#</cfoutput>
	</cfif>
	<cfif srNotCSV> 	
		<TR  class="td_zone_bgcolor" bordercolor="#FFFFFF">
			<TD NOWRAP colspan="<cfoutput>#(ArrayLen(timespanArray) - 1) * 8 #</cfoutput>">
				<cfoutput>#zone_name#</cfoutput>
			</TD>
		</TR>
	<cfelse>
		<cfoutput>#zone_name#</cfoutput> 
		<cfoutput>#chr(13)##chr(10)#</cfoutput> 
	</cfif>
	<cfif srNotCSV> 
		<TR class="td_region_bgcolor" bordercolor="#FFFFFF">
			<TD NOWRAP bgcolor="#FFFFFF">&nbsp;</TD>
			<TD NOWRAP colspan="<cfoutput>#(ArrayLen(timespanArray) - 1) * 8 #</cfoutput>"><cfoutput>#region_name#</cfoutput></TD>
		</TR>
	<cfelse>
		<cfoutput> ,#region_name#</cfoutput> 
		<cfoutput>#chr(13)##chr(10)#</cfoutput> 
	</cfif>
<cfelseif region_flag EQ 1 >
	<cfif srNotCSV> 
		<TR class="td_region_bgcolor" bordercolor="#FFFFFF">
			<TD NOWRAP bgcolor="#FFFFFF">&nbsp;</TD>
			<TD NOWRAP colspan="<cfoutput>#(ArrayLen(timespanArray) - 1) * 8 #</cfoutput>"><cfoutput>#region_name#</cfoutput></TD>
		</TR>
	<cfelse>
		<cfoutput> ,#region_name#</cfoutput> 
		<cfoutput>#chr(13)##chr(10)#</cfoutput> 
	</cfif>
</cfif>
<cfif srNotCSV> 
	<TR class="td_customer_bgcolor" bordercolor="#FFFFFF">
		<TD NOWRAP></TD>
		<TD NOWRAP></TD>
		<TD NOWRAP><cfoutput>#customer_ship_to_struct[trim(customer_name)]#</cfoutput></TD>
		<!--- 1: period	3: quarter	5: year--->
		<CFLOOP INDEX="idx" FROM="1" TO="#ArrayLen(timespanArray)-2#" STEP="2">
			<!---pounds--->
			<cfloop index="idx1" FROM="#idx#" TO="#idx+1#" STEP="1">
				<CFSET vstruct = Evaluate("#timespanArray[idx1]#_Struct")>
				 <!--- Distributor --->
				<TD NOWRAP align="right">
					<cfif StructKeyExists(vstruct, "#zone_name#") and StructKeyExists(vstruct[#zone_name#], "#region_name#") and StructKeyExists(vstruct[#zone_name#][#region_name#], "#customer_name#")>
						<cfset "curr#timespanArray[idx1]#Vol" = vstruct[#zone_name#][#region_name#][#customer_name#][#invoice_report_title#] >
						<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >#NumberFormat(vstruct[zone_name][region_name][customer_name][invoice_report_title], '_,___,___,___,___')#<cfelse>#DollarFormat(vstruct[zone_name][region_name][customer_name][invoice_report_title])#</cfif></cfoutput>
					<cfelse> 
						<cfset "curr#timespanArray[idx1]#Vol" = 0 >
						0
					</cfif> 
				</TD>
			</cfloop>
			<cfset actualVal = evaluate("curr" & timespanArray[idx] & "Vol")>
			<cfset historyVal = evaluate("curr" & timespanArray[idx+1] & "Vol" )>
			<!--- add on to region sum --->
			<cfset regionLumpSum[timespanArray[Idx]][invoice_report_title] = regionLumpSum[timespanArray[Idx]][invoice_report_title] + actualVal >
			<cfset regionLumpSum[timespanArray[Idx+1]][invoice_report_title] = regionLumpSum[timespanArray[Idx+1]][invoice_report_title] + historyVal >
			<cfset zoneLumpSum[timespanArray[Idx]][invoice_report_title] = zoneLumpSum[timespanArray[Idx]][invoice_report_title] + actualVal >
			<cfset zoneLumpSum[timespanArray[Idx+1]][invoice_report_title] = zoneLumpSum[timespanArray[Idx+1]][invoice_report_title] + historyVal >
			<TD NOWRAP style="<cfif actualVal LT historyVal>color:#CC0000</cfif>" align="right">
				<CFIF (actualVal - historyVal) NEQ 0 >
					<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >#NumberFormat(actualVal - historyVal, '_,___,___,___,___')#<cfelse>#DollarFormat(actualVal - historyVal)#</cfif></cfoutput>
				<CFELSE>
					0
				</CFIF> 
			</TD>
			<TD NOWRAP style="<cfif actualVal LT historyVal and historyVal NEQ 0>color:#CC0000</cfif>" align="right">
				<cfif historyVal NEQ 0>
					<cfoutput>#NumberFormat((actualVal - historyVal) / historyVal * 100,  '_,___,___,___,___.__')#%</cfoutput>
				<cfelse>
					N/A
				</cfif>
			</TD>
		</CFLOOP>
	</TR>
<cfelse>
	<cfoutput> , ,"#customer_name#",</cfoutput>
	<CFLOOP INDEX="idx" FROM="1" TO="#ArrayLen(timespanArray)-2#" STEP="2">
		<!---pounds--->
		<cfloop index="idx1" FROM="#idx#" TO="#idx+1#" STEP="1">
			<CFSET vstruct = Evaluate("#timespanArray[idx1]#_Struct")>
			 <!--- Distributor --->
			<cfif StructKeyExists(vstruct, "#zone_name#") and StructKeyExists(vstruct[#zone_name#], "#region_name#") and StructKeyExists(vstruct[#zone_name#][#region_name#], "#customer_name#")>
				<cfset "curr#timespanArray[idx1]#Vol" = vstruct[#zone_name#][#region_name#][#customer_name#][#invoice_report_title#] >
				<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >"#NumberFormat(vstruct[zone_name][region_name][customer_name][invoice_report_title], '_,___,___,___,___')#",<cfelse>"#LSCurrencyFormat(vstruct[zone_name][region_name][customer_name][invoice_report_title],'local')#",</cfif></cfoutput>
			<cfelse> 
				<cfset "curr#timespanArray[idx1]#Vol" = 0 >
				<cfoutput>0,</cfoutput>
			</cfif> 
		</cfloop>
		<cfset actualVal = evaluate("curr" & timespanArray[idx] & "Vol")>
		<cfset historyVal = evaluate("curr" & timespanArray[idx+1] & "Vol" )>
		<!--- add on to region sum --->
		<cfset regionLumpSum[timespanArray[Idx]][invoice_report_title] = regionLumpSum[timespanArray[Idx]][invoice_report_title] + actualVal >
		<cfset regionLumpSum[timespanArray[Idx+1]][invoice_report_title] = regionLumpSum[timespanArray[Idx+1]][invoice_report_title] + historyVal >
		<cfset zoneLumpSum[timespanArray[Idx]][invoice_report_title] = zoneLumpSum[timespanArray[Idx]][invoice_report_title] + actualVal >
		<cfset zoneLumpSum[timespanArray[Idx+1]][invoice_report_title] = zoneLumpSum[timespanArray[Idx+1]][invoice_report_title] + historyVal >
		<CFIF (actualVal - historyVal) NEQ 0 >
			<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >"#NumberFormat(actualVal - historyVal, '_,___,___,___,___')#",<cfelse>"#DollarFormat(actualVal - historyVal)#",</cfif></cfoutput>
		<CFELSE>
			<cfoutput>0,</cfoutput>
		</CFIF> 
		<cfif historyVal NEQ 0>
			<cfoutput>"#NumberFormat((actualVal - historyVal) / historyVal * 100,  '_,___,___,___,___.__')#"%,</cfoutput>
		<cfelse>
			<cfoutput>N/A,</cfoutput>
		</cfif>
	</CFLOOP>
	<cfoutput>#chr(13)##chr(10)#</cfoutput>
</cfif> 
<cfset row_count = row_count + 1 >
