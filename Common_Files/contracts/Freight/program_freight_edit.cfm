<!---- program_freight_edit.cfm ---->
<!---- common ------>
<!---  MOVED TO CALLER common_files/contracts/freight/index.cfm
<cfset objFreightBracketSetting = CreateObject("component","components.freight.FreightBracketSetting") />
<cfset objFreightBracketSetting.getFreightSettings()  />
--->
<cfset qFreightBracketSettings = objFreightBracketSetting.getFreightBracketInfo() />
<cfset maxFreightBracket = objFreightBracketSetting.getMaxFreightBracket() />
<cfset freightDate = DateFormat(Now(), "mm/dd/yyyy") />
<cfif DateDiff("d", freightDate, qProgramInfo.Contract_Start_Date) gt 0>
	<cfset freightDate = qProgramInfo.Contract_Start_Date />
</cfif>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>	

<LINK REL="STYLESHEET" TYPE="text/css" HREF="scroll_bars.css">

<!--- Ajax script to call the "Populate Program Distributor Freight" routine asynchronously --->
<script type='text/javascript'>
	_ajaxConfig = {	'_cfscriptLocation':'/components/freight/FreightAjax.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
</script>		
<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
<script language="javascript">
	<cfoutput>
	var globalFreightComponentType = '#qProgramInfo.Freight_Component_Type#';
	var globalFreightDate = '#freightDate#';
	var globalDefaultBracket = '#maxFreightBracket#';
	</cfoutput>
	function fnHideFields(rdoField){
 		var rdoFields=document.getElementsByName(rdoField.name);
		if (rdoFields[1].checked)
		{
			document.getElementById('dataPane').style.display='none'
		}
		else
		{
			document.getElementById('dataPane').style.display='block';
		}
 		 
 		//document.getElementById('depot').style.display=(rads[1].checked||rads[3].checked)?'block':'none';
	}
</script>
<SCRIPT SRC="program_freight_ajax.js"></SCRIPT>

<cfinclude template="program_freight_display_header.cfm" />

<div id="table_container">
<table cellpadding="2" cellspacing="0" border="0" width="100%" class="maintable">
<tr>
	<th id="header" width="50" class="locked_top"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></th>
	<th id="header" class="locked_top" align="left">Weight</th>
	<th id="header" class="locked_top" align="left">Warehouse</th>
<cfif qProgramInfo.Freight_Component_Type eq 1>
	<th id="header" class="locked_top" align="left">bracket</th>
</cfif>
<!--- if freight is at item level hide these columns --->
<cfif NOT objFreightBracketSetting.bFREIGHT_VERSION_ITEM >
		<th id="header" class="locked_top" align="left">IBF/cwt</th>
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<th id="header" class="locked_top" align="left">OBF/cwt</th>
		<th id="header" class="locked_top" align="left">PUA/cwt</th>
	</cfif>
		<th id="header" class="locked_top" align="left">Frt.Adj</th>
</cfif>
</tr>
<cfset Distributor_List = "">
<cfoutput query="qProgramDistributorFreight">
	<cfset Current_Freight_Bracket_Setting_ID = Freight_Bracket_Setting_ID />
	<cfset Current_Distributor_ID = Distributor_ID />
	<cfset InputNameSuffix = Replace(Distributor_ID, "-", "_", "all") />
	<cfset Distributor_List = ListAppend(Distributor_List, InputNameSuffix) />
	<tr bgcolor="#IIf(currentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" valign="top">
		<td>
			#Name#&nbsp;#Shr_Ship_to#<br />#City#&nbsp;#State#&nbsp;#ZipCode#
			<input type="hidden" name="Zip_Code_#InputNameSuffix#" value="#Left(ZipCode, 3)#" />
		</td>
		<td>#Program_Weight#%</td>
		<!----- warehouse ------->
		<td>
			<table cellpadding="0" cellspacing="0">
			<tr valign="top">
				<td style="border:none">
				<span id="Warehouse_details_#InputNameSuffix#">
				#Warehouse_Name#&nbsp;&nbsp;
				<br />#Warehouse_Address_1#<cfif Warehouse_Address_2 neq ""><br />#Warehouse_Address_2#</cfif>
				<br />#Warehouse_City#,#Warehouse_State#&nbsp;#Warehouse_Zip#
				</span>	
				</td>
				<td style="border:none">
				<span id="Overridden_SelectedWarehouse_#InputNameSuffix#"
					<cfif Overridden_Warehouse_Master_ID eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
				>&nbsp;*</span>
				</td>
			</tr>
			</table>
			<input type="hidden" name="SelectedWarehouse_#InputNameSuffix#" ID="SelectedWarehouse_#InputNameSuffix#" value="#WareHouse_Master_ID#" />
			<input type="hidden" name="Default_SelectedWarehouse_#InputNameSuffix#" value="#Default_WareHouse_Master_ID#" />
			<span style="font-size:11px;font-weight:bold;color:FF0000;">[</font></span>
			<a href="##" onclick="OpenWarehousePage('#InputNameSuffix#');return false;"  style="font-size:11px;font-weight:bold;">change</a>
			<span style="font-size:11px;font-weight:bold;color:FF0000;"><font color="FF0000">]</font></span>
		</td>
		<!----- bracket ------->
	<cfif qProgramInfo.Freight_Component_Type eq 1>
		<td>			
			<select name="Freight_Bracket_Setting_ID_#InputNameSuffix#" 
					onchange="SetOverride(this); bracketChanged('#Distributor_ID#');">
			<cfloop query="qFreightBracketSettings">
				<option value="#Freight_Bracket_Setting_ID#" <cfif Current_Freight_Bracket_Setting_ID eq Freight_Bracket_Setting_ID>selected</cfif>>#Freight_Bracket_Label#</option>
			</cfloop>
			</select>
			<input type="hidden" name="Default_Freight_Bracket_Setting_ID_#InputNameSuffix#" value="#Default_Freight_Bracket_Setting_ID#" />
			<sup id="Overridden_Freight_Bracket_Setting_ID_#InputNameSuffix#"
				<cfif Overridden_Freight_Bracket_Setting_ID eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
				>*</sup>
		</td>
	</cfif>
	<!--- if freight is at item level hide these columns --->
	<cfif NOT objFreightBracketSetting.bFREIGHT_VERSION_ITEM>
		<!----- IBF ------->
		<td>
			<input type="text" name="IBF_Rate_#InputNameSuffix#" value="#IBF_Rate#" size="4" 
					OnKeyPress="javaScript: return Allow_Key_List('-.0123456789')"
					onChange="javaScript: FormatInputValue(this)"  
					<cfif IBF_Rate eq 0>class="zeroValue"<cfelse>class="nonZeroValue"</cfif>
					 />
			<input type="hidden" name="Default_IBF_Rate_#InputNameSuffix#" value="#Default_IBF_Rate#" />
			<sup id="Overridden_IBF_Rate_#InputNameSuffix#"
				<cfif Overridden_IBF_Rate eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
				>*</sup>
			<span id="error_IBF_Rate_#qProgramDistributorFreight.currentRow#"></span>			
		</td>
		<cfif qProgramInfo.Freight_Component_Type eq 1>
			<!----- OBF ------->
			<td>
				<input type="text" name="OBF_Rate_#InputNameSuffix#" value="#OBF_Rate#" size="4" 
						OnKeyPress="javaScript: return Allow_Key_List('-.0123456789')"
						onChange="javaScript: FormatInputValue(this)"
						<cfif OBF_Rate eq 0>class="zeroValue"<cfelse>class="nonZeroValue"</cfif>
						 />
				<input type="hidden" name="Default_OBF_Rate_#InputNameSuffix#" value="#Default_OBF_Rate#" />
				<sup id="Overridden_OBF_Rate_#InputNameSuffix#"
					<cfif Overridden_OBF_Rate eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
					>*</sup>
				<span id="error_OBF_Rate_#qProgramDistributorFreight.currentRow#"></span>
			</td>
			<!----- PUA ------->
			<td>
				<input type="text" name="Pickup_Allowance_#InputNameSuffix#" value="#Pickup_Allowance#" size="4" 
						OnKeyPress="javaScript: return Allow_Key_List('-.0123456789')"
						onChange="javaScript: FormatInputValue(this)"  
						<cfif Pickup_Allowance eq 0>class="zeroValue"<cfelse>class="nonZeroValue"</cfif>
						 />
				<input type="hidden" name="Default_Pickup_Allowance_#InputNameSuffix#" value="#Default_Pickup_Allowance#" />
				<sup id="Overridden_Pickup_Allowance_#InputNameSuffix#"
					<cfif Overridden_Pickup_Allowance eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
					>*</sup>
				<span id="error_Pickup_Allowance_#qProgramDistributorFreight.currentRow#"></span>
				<span id="error_Total_Pickup_Allowance_#qProgramDistributorFreight.currentRow#"></span>
			</td>
		</cfif> <!------- Freight_Component_Type  ------->
			<!----- Frt. Adj ------->
			<td>
				<input type="text" name="Freight_Adjustment_#InputNameSuffix#" value="#Freight_Adjustment#" size="4" 
						OnKeyPress="javaScript: return Allow_Key_List('-.0123456789')"
						onChange="javaScript: FormatInputValue(this)"  
						<cfif Freight_Adjustment eq 0>class="zeroValue"<cfelse>class="nonZeroValue"</cfif>
						 />
				<input type="hidden" name="Default_Freight_Adjustment_#InputNameSuffix#" value="0" />
				<sup id="Overridden_Freight_Adjustment_#InputNameSuffix#"
					<cfif Freight_Adjustment >class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
					>*</sup>
				<span id="error_Freight_Adjustment_#qProgramDistributorFreight.currentRow#"></span>
				<span id="error_Total_Freight_Adjustment_#qProgramDistributorFreight.currentRow#"></span>
			</td>
		
	<cfelse><!------- bFREIGHT_VERSION_ITEM ------->
		<!--- make the form vars hidden --->
		<input type="hidden" name="OBF_Rate_#InputNameSuffix#" value="#OBF_Rate#" />
		<input type="hidden" name="Default_OBF_Rate_#InputNameSuffix#" value="#Default_OBF_Rate#" />
		<input type="hidden" name="Pickup_Allowance_#InputNameSuffix#" value="#Pickup_Allowance#" />
		<input type="hidden" name="Default_Pickup_Allowance_#InputNameSuffix#" value="#Default_Pickup_Allowance#" />
		<input type="hidden" name="Freight_Adjustment_#InputNameSuffix#" value="#Freight_Adjustment#" />
		<input type="hidden" name="Default_Freight_Adjustment_#InputNameSuffix#" value="0" />
		<input type="hidden" name="IBF_Rate_#InputNameSuffix#" value="#IBF_Rate#"/>
		<input type="hidden" name="Default_IBF_Rate_#InputNameSuffix#" value="#Default_IBF_Rate#" />
		
	</cfif> <!------- bFREIGHT_VERSION_ITEM ------->
	</tr>
</cfoutput>
</table>
</div>
<p>

<div>
<cfset notes_Max_Length = 4000>
		<CF_SCALABLETEXTAREA 
			NAME="Freight_Notes" 
			ID="Freight_Notes"
			COLS="57" 
			ROWS="5" 
			onPaste="javaScript: return textareaChecklength(#notes_Max_Length#, this);"
			onkeyPress="javaScript: return textareaChecklength(#notes_Max_Length#, this);"
			incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">" 
			decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">"><CFOUTPUT>#qProgramInfo.Freight_Notes#</CFOUTPUT></CF_SCALABLETEXTAREA>	
</div>


<cfoutput>
<input type="hidden" name="Distributor_List" value="#Distributor_List#">
<input type="hidden" name="ContractStartDate" value="#DateFormat(qProgramInfo.Contract_Start_Date,'mm/dd/yyyy')#" />
<input type="hidden" name="ContractEndDate" value="#DateFormat(qProgramInfo.Contract_End_Date,'mm/dd/yyyy')#" />
</cfoutput>
</script>
<cfinclude template="program_freight_buttons.cfm" />
