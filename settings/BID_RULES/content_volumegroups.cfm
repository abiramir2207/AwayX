<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<!-- if the variable is defined the user wants action -->
<cfif isdefined("URL.VOLUMEGROUPCOUNT")>
	<cfif URL.VOLUMEGROUPCOUNT GT 10>
		<cfset URL.VOLUMEGROUPCOUNT = 10>
	</cfif>
	
	<!-- init vars assuming user wants to add groups -->
	<cfset incrementvalue = 1>
	<cfset loopFrom = 1>
	<cfset loopTo = URL.VOLUMEGROUPCOUNT>
	
	<!-- If the request is to remove groups, init vars to make it happen -->
	<cfif URL.VOLUMEGROUPCOUNT LT BidRule.VOLUMEGROUPS.INDEX_COUNT>
		<cfset incrementvalue = -1>
		<cfset loopFrom = BidRule.VOLUMEGROUPS.INDEX_COUNT>
		<cfset loopTo = URL.VOLUMEGROUPCOUNT>
	</cfif>
	
	<!-- before destructively manipulating packet, store data supplied by last user form post into packet -->
	<cfloop index="x" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
		<cfif structkeyexists(BidRule.VOLUMEGROUPS, "group_#x#")>
			<cfif isdefined("form.range_start_#x#")>
				<cfset "BidRule.VOLUMEGROUPS.group_#x#.range_start" = evaluate("form.range_start_#x#")>
			</cfif>
			
			<cfif isdefined("form.range_end_#x#")>
				<cfset "BidRule.VOLUMEGROUPS.group_#x#.range_end" = evaluate("form.range_end_#x#")>
			</cfif>			
		</cfif>
	</cfloop>
	
	<!-- destructively manipulating packet (aka: add or remove volume group objects from it) -->
	<cfloop index="x" from="#loopFrom#" to="#loopTo#" step="#incrementvalue#">
		<!-- does the group related to the loop index exist  -->
		<cfif structkeyexists(BidRule.volumegroups, "group_#x#")><cfset isDefGroup = 1><cfelse><cfset isDefGroup = 0></cfif>
		<!-- if increment value is negative, user wants to delete packets -->
		<cfif incrementvalue LT 0>
			<cfif isDefGroup IS 1 AND x NEQ loopTo><!--- delete it --->
				<cfset thisGroupID = evaluate("BidRule.volumegroups.Group_#x#.Bid_Rule_Group_ID")>
				<cfif len(thisGroupID) GT 0>
					<cfset BidRule.volumegroups.deletethesegroups.index_count = BidRule.volumegroups.deletethesegroups.index_count + 1>
					<cfset "BidRule.volumegroups.deletethesegroups.Group_#BidRule.volumegroups.deletethesegroups.index_count#_ID" = thisGroupID>
				</cfif>
				<cfset temp = structdelete(BidRule.VOLUMEGROUPS, "Group_#x#")>
			</cfif>
		<cfelse>			
			<cfif isDefGroup IS 0><!--- init prototype, aka: create new group --->
				<cfset temp = structinsert(BidRule.VOLUMEGROUPS, "Group_#x#", Duplicate(BidRule.VOLUMEGROUPS.ProtoType))>
			</cfif>			
		</cfif>
		<!-- up the loop count -->
		<cfset BidRule.VOLUMEGROUPS.INDEX_COUNT = x>
	</cfloop>
</cfif><!-- end  isdefined("URL.VOLUMEGROUPCOUNT") -->

<cfwddx action="CFML2WDDX" input="#BidRule#" output="BidRule_Serialized" usetimezoneinfo="Yes">
<!--- <cffile action="WRITE" file="#apppath#\WddxPackets\#url.sg#.ddx" output="#BidRule_Serialized#" addnewline="Yes">
--->
<cffile action="WRITE" file="#Application.Doc_Path#\temp_files\WddxPackets\#url.sg#.ddx" output="#BidRule_Serialized#" addnewline="Yes">

<cfparam name="url.volumegroupcount" default="0">

<!--- get uom desc --->
<cfset useLakebaseForgetUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForgetUOM>
	<cftry>
		<cfset getUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "eq.#bidrule.basic.bid_rule_uom#",
				"select" = "unit_of_measure_desc"
			}), "unit_of_measure_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUOM>
<cfquery name="getUOM" datasource="#application.datasource#">
	SELECT Unit_Of_Measure_Desc
	FROM Units_of_Measure
	WHERE Unit_Of_Measure_ID = '#bidrule.basic.bid_rule_uom#'
</cfquery>
</cfif>
<cfset ruleuomdesc = getUOM.Unit_Of_Measure_Desc>

<cfoutput>
<script>
	var updateCount = 0;
	var destinationString = "";
	var currentGroupCount = '<cfoutput>#BidRule.volumegroups.index_count#</cfoutput>'

	function updateGroupCount() {
		updateCount = 1;
		a = document.all.VolumegroupCount.value;
		
		if (a == "") {
			alert("Please Enter a Number");
			return false;
		}
		else {
			if(a > 10) {
				alert("No more than 10 groups can be created")
				return false;
			}
		}
		
		<cfset exclusionList = lcase("cftoken,cfid,VOLUMEGROUPCOUNT")>
		<cfset destinationString = "">
		<cfloop index="i" list="#StructKeyList(URL)#" delimiters=",">
			<cfif listfind(exclusionList ,lcase(i)) EQ 0>
				<cfset destinationString = listappend(destinationString, "#i#=#evaluate(i)#", "&")>
			</cfif>
		</cfloop>

		destinationString = "#destinationString#";
		destinationString = "popupWindow_Content.cfm?" + destinationString + "&volumegroupcount=" + a;
		
		if(parseInt(a) < parseInt(currentGroupCount)) {
			document.all.MyForm.action = destinationString;
			document.all.MyForm.submit();
		}
		else {
			verifyRanges();
		}
	}
	
	function verifyRanges() {
		ErrorCount = 0;
		thisCollection = document.all.rangeinput;
		
		previousTextbox 	= "";
		previousErrorSpan 	= "";
		
		if(thisCollection != null){
			for(var x=0; x<thisCollection.length; x++) {
				thisTexbox 		= thisCollection[x].firstChild.nextSibling.nextSibling;
				if(x != 0) {
					lastValue = thisCollection[x-1].firstChild.nextSibling.nextSibling
				}
				thisErrorSpan 	= thisCollection[x].firstChild;
				thisErrorSpan2	= thisCollection[x].firstChild.nextSibling;
			
				if(thisTexbox.value.length == 0) {
					ErrorCount++
					queueMessage("Enter A Volume", thisErrorSpan)
				}
				else {
					clearQueue(thisErrorSpan)
				}
				
				CQ = 0;
				z=x/2;
				z=z+"";
				
				if(x != 0) {
					if(thisTexbox.value.length != 0) thisValue = parseInt(thisTexbox.value);
					else thisValue = -100;
					if(thisTexbox.value.length != 0) lastValue = parseInt(lastValue.value);
					else lastValue = -99;
					if(x != 0) {
						if(lastValue >= thisValue) {
							ErrorCount++
							queueMessage("Enter A Value Greater Than the Previous", thisErrorSpan2)
						}
						else {
							clearQueue(thisErrorSpan2)
						}
					}
				}
			}
		}

		if(ErrorCount==0){
			if(updateCount == 0){
				document.all.MyForm.action = "packet_modifier.cfm";
			}
			else {
				document.all.MyForm.action = destinationString;
			}
			
			document.all.MyForm.submit();
		}
		else {
			showMessageWindow();
		}
	}
</script>
</cfoutput>
<cf_messagewindow>

<br><br>
<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Supply the number of volume groups
</div>
<hr color="Orange" width="75%">
<div align="center">
<form action="" method="post" name="MyForm" id="MyForm">
<table>
	<tr>
		<td align="center" valign="middle"><b>Number for Volume Groups:</b></td>
		<td align="left"><input type="text" name="VolumegroupCount" id="VolumegroupCount" maxlength="2" size="1" value="<cfoutput>#bidrule.volumegroups.index_count#</cfoutput>" ONKEYUP="clenseText(this, '0123456789')"></td>
	</tr>
	<tr>
		<td colspan="100%" align="center">
			<CF_button
			button_name		=	""
			button_caption	=	"update"
			button_action	=	"updateGroupCount()"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
	</tr>
	<tr>
		<td colspan="100%"><hr width="100%" color="navy"></td>
	</tr>
	<tr>
		<td align="center" colspan="100%">
			<table align="center">
				<cfoutput>
					<tr>
						<td colspan="5" align="center"><b>Weekly Volume Ranges</b></td>
					</tr>					

					<tr>
						<td>&nbsp;</td>
						<td><b>Range Start</b></td>
						<td size="20" rowspan="100%">&nbsp;</td>
						<td><b>Range End</b></td>
					</tr>					
				<cfloop index="i" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
					<cfset currentnode = evaluate("BidRule.VolumeGroups.Group_#i#")>
					<tr>
						<td><b>Group #i#</b></td>
						<td><span id="rangeinput"><span id="errorspan"></span>
							<span id="errorspan_two"></span>
								<input name="range_start_#i#" type="text" size="10" ONKEYUP="clenseText(this, '0123456789')"
								
								<cfif i EQ 1> 
									value= "0" disabled
								<cfelse>
									<cfif currentnode.Range_End NEQ "*">
										value="#currentnode.Range_Start#"
									</cfif>
								</cfif>
								>
								
							</span>
						</td>
						<td><span id="rangeinput"><span id="errorspan"></span><span id="errorspan_two"></span>
							<input name="range_end_#i#" type="text" size="10"  ONKEYUP="clenseText(this, '0123456789')"
								<cfif i EQ BidRule.VOLUMEGROUPS.INDEX_COUNT> 
									value= "*" disabled
								<cfelse>
									<cfif currentnode.Range_End NEQ "*">
										value="#currentnode.Range_End#"
									</cfif>
								</cfif>
							>&nbsp;<b>#ruleuomdesc#</b>
							</span>
						</td>
					</tr>
				</cfloop>
				</cfoutput>
			</table>
		</td>
	</tr>
</table>

<cfif BidRule.VOLUMEGROUPS.INDEX_COUNT EQ 0>
	<div align="center" style="font-weight:bold; color: red;">Enter the number of volume groups you require then press "UPDATE"</div>
</cfif>

<input type="Hidden" name="SuppliedDataType" 	value="volumegroups">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="overage">
</form>

</div>
<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"verifyRanges()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>