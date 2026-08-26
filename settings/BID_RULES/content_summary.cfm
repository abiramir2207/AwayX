<cfparam name="url.savecomplete" default="0">
<cfset dnpMessage = "<span style=""color: Red; font-weight:bold;"">Data Not Provided</span>">

<cfquery name="getUOMLabel" datasource="#application.datasource#">
	SELECT Unit_Of_Measure_Desc
	FROM Units_Of_Measure
	WHERE Unit_Of_Measure_ID = '#bidrule.basic.Bid_Rule_UOM#'
</cfquery>

<cfif bidrule.basic.Bid_Rule_UOM EQ 0><cfset uomDesc = dnpMessage><cfelse><cfset uomDesc = getUOMLabel.Unit_Of_Measure_Desc></cfif>

<cfset this.table 	= application.returned_customer_setting.approval_criteria_table>
<cfset this.ID 		= application.returned_customer_setting.approval_criteria_table_ID>
<cfif listlen(BidRule.type.Current_Index) GT 0>
	<cfquery name="getTypes" datasource="#application.datasource#">
		SELECT #this.ID# AS ID, #this.table# AS Type_Desc
		FROM #this.table#
		WHERE #this.ID# IN(#listqualify(BidRule.type.Current_Index, "'")#)
		ORDER BY Type_Desc	
	</cfquery>
<cfelse>
	<cfset getTypes = QueryNew("ID")>
</cfif>


<script>
	function verifyData() {
		if(confirm("Press OK to save.")) {
			document.all.MyForm.action="packet_modifier.cfm";
			document.all.MyForm.submit();
		}
	}
</script>

<br><br>
<style type="text/css">
	.labelCellStyle {
		text-align : right;
		font-weight: bold;
		font-size: 14px;
	}
	
	.headingStyle {
		font-size: 15px;
		font-weight: bold;
		color: Navy;
	}
	
	.contentLabel {
		text-align : right;
		font-weight: bold;
		font-size: 13px;
	}
</style>

<cfif url.savecomplete EQ 1>
	<div align="center" style="color: Green; font-weight: bold; font-size: 15px;">
		Bid Rule Saved Succesfully! 
		<BR>
	</div>
</cfif>

<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Bid Rule Summary
</div>
<hr color="Orange" width="75%">
<div align="center">
<cfoutput>
<!--- Basic Infor --->

<cfset const_statusImageSrc_nogo = "/images/no_small.gif">
<cfset const_statusImageSrc_go = "/images/yes_small.gif">

<cfset theValidData = BidRule.Basic.ValidData>
<cfif theValidData EQ 1 AND uomDesc NEQ dnpMessage>
	<cfset thisImgaeSrc = const_statusImageSrc_go>
<cfelse>
	<cfset thisImgaeSrc = const_statusImageSrc_nogo>
</cfif>
<table width="70%" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td><BR>
			
			
			<div align="left" class="headingStyle"><img src="#thisImgaeSrc#" alt="" border="0">&nbsp;Basic Information</div>
			<hr width="100%" align="left" color="navy">
			<table>
				<tr>
					<td class="contentLabel" nowrap>Rule Name:</td>
					<td rowspan="100%"></td>
					<td><cfif len(trim(bidrule.basic.bid_rule_name)) EQ 0>#dnpMessage#<cfelse>#bidrule.basic.bid_rule_name#</cfif></td>
				</tr>
				<tr>
					<td class="contentLabel" valign="top">Description:</td>
					<td><cfif len(trim(bidrule.basic.bid_rule_desc)) EQ 0>#dnpMessage#<cfelse>#bidrule.basic.bid_rule_desc#</cfif></td>
				</tr>
				<tr>
					<td class="contentLabel" nowrap>Unit of Measure:</td>
					<td><cfif bidrule.basic.Bid_Rule_UOM EQ 0>#dnpMessage#<cfelse>#getUOMLabel.Unit_Of_Measure_Desc#</cfif></td>
				</tr>
			</table><BR><BR>
			

			<cfset theValidData = BidRule.Type.ValidData>
			<cfif theValidData EQ 1>
				<cfset thisImgaeSrc = const_statusImageSrc_go>
			<cfelse>
				<cfset thisImgaeSrc = const_statusImageSrc_nogo>
			</cfif>
			<div align="left" class="headingStyle"><img src="#thisImgaeSrc#" alt="" border="0">&nbsp;Type Codes</div>
			<hr width="100%" align="left" color="navy">
			<table width="100%" border="0" cellspacing="0" cellpadding="3" align="center">
				<cfset columnCount = 0>
				<cfset NumberOfColumns = 2>
				<cfset currentRowCount = 1>
				<TR>
				<cfif listlen(BidRule.type.Current_Index) EQ 0><td colspan="100%" align="center">#dnpMessage#</td></cfif>
				<cfloop query="getTypes">
					<CFIF currentRowCount mod 2><cfset BGCOLOR="white"><CFELSE><cfset BGCOLOR="ccffcc"></CFIF>
					<cfif columnCount EQ NumberOfColumns><TR></cfif>
						<td BGCOLOR="#BGCOLOR#" nowrap>#getTypes.Type_Desc#</td>
					<cfset columnCount = columnCount + 1>
					<cfif columnCount EQ NumberOfColumns></TR><cfset columnCount = 0><cfset currentRowCount = currentRowCount + 1></cfif>
				</cfloop>
				
				<cfif columnCount NEQ 0>
					<cfloop index="x" from="#columnCount#" to="#NumberOfColumns-1#" step="1">
						<td BGCOLOR="#BGCOLOR#">&nbsp;</td>
					</cfloop>
				</cfif>
			</table><BR><BR>
		
						
			<cfset theValidData = 1>
			<cfif theValidData EQ 1>
				<cfset thisImgaeSrc = const_statusImageSrc_go>
			<cfelse>
				<cfset thisImgaeSrc = const_statusImageSrc_nogo>
			</cfif>
			<div align="left" class="headingStyle"><img src="#thisImgaeSrc#" alt="" border="0">&nbsp;Modifiers</div>
			<hr width="100%" align="left" color="navy">
			<!-- compound -->
			<table width="100%" border="0" cellspacing="0" cellpadding="3" align="center">
				<tr><td colspan="100%" STYLE="border-bottom:1px solid orange;" nowrap><b>Compounded</b></td></tr>
				
				<TR ID="header" BGCOLOR="##ffce84">
					<td><b>Description</b></td>
					<td><b>Amount</b></td>
				</tr>
		
			<cfset validDataCount = 0>
			<cfloop index="x" from="1" to="#BidRule.Modifiers.Index_Count#" step="1">
				<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#x#")>
				<cfif currentnode.ValidData EQ 1 AND currentnode.iscompound EQ 1>
				<TR <CFIF x mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<td>#currentnode.modifier_desc#</td>
					<td>
					#currentnode.modifier_amount#&nbsp;
					<cfif currentnode.modifier_amount GT 1><cfset plural = 1><cfelse><cfset plural = 0></cfif>
					<cfif currentnode.modifier_uom EQ 1 AND plural EQ 0>Case</cfif>
					<cfif currentnode.modifier_uom EQ 1 AND plural EQ 1>Cases</cfif>
					<cfif currentnode.modifier_uom EQ 2 AND plural EQ 0>Pound</cfif>
					<cfif currentnode.modifier_uom EQ 2 AND plural EQ 1>Pounds</cfif>
					<cfif currentnode.modifier_uom EQ 3 AND plural EQ 0>%</cfif>
					<cfif currentnode.modifier_uom EQ 3 AND plural EQ 1>%</cfif>
					
					<cfset validDataCount = validDataCount + 1>
					</td>
				</TR>
				</cfif>
			</cfloop>
			<cfif validDataCount EQ 0><td colspan="100%" align="center">#dnpMessage#</td></cfif>
			</table><BR>
			
			<!-- independent -->
			<table width="100%" border="0" cellspacing="0" cellpadding="3" align="center">
				<tr><td colspan="100%" STYLE="border-bottom:1px solid orange;" nowrap><b>Independent</b></td></tr>
				
				<TR ID="header" BGCOLOR="##ffce84">
					<td><b>Description</b></td>
					<td><b>Amount</b></td>
				</tr>
		
			<cfset validDataCount = 0>
			<cfloop index="x" from="1" to="#BidRule.Modifiers.Index_Count#" step="1">
				<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#x#")>
				<cfif currentnode.ValidData EQ 1 AND currentnode.isindependent EQ 1>
				<TR <CFIF x mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<td>#currentnode.modifier_desc#</td>
					<td>
					#currentnode.modifier_amount#&nbsp;
					<cfif currentnode.modifier_amount GT 1><cfset plural = 1><cfelse><cfset plural = 0></cfif>
					<cfif currentnode.modifier_uom EQ 1 AND plural EQ 0>Case</cfif>
					<cfif currentnode.modifier_uom EQ 1 AND plural EQ 1>Cases</cfif>
					<cfif currentnode.modifier_uom EQ 2 AND plural EQ 0>Pound</cfif>
					<cfif currentnode.modifier_uom EQ 2 AND plural EQ 1>Pounds</cfif>
					<cfif currentnode.modifier_uom EQ 3 AND plural EQ 0>%</cfif>
					<cfif currentnode.modifier_uom EQ 3 AND plural EQ 1>%</cfif>
					
					<cfset validDataCount = validDataCount + 1>
					</td>
				</TR>
				</cfif>
			</cfloop>
			<cfif validDataCount EQ 0><td colspan="100%" align="center">#dnpMessage#</td></cfif>
			</table><BR><BR>			
			

			<cfset theValidData = BidRule.volumegroups.ValidData>
			<cfif theValidData EQ 1 AND uomDesc NEQ dnpMessage>
				<cfset thisImgaeSrc = const_statusImageSrc_go>
			<cfelse>
				<cfset thisImgaeSrc = const_statusImageSrc_nogo>
			</cfif>
			<div align="left" class="headingStyle"><img src="#thisImgaeSrc#" alt="" border="0">&nbsp;Volume Groups</div>
			<hr width="100%" align="left" color="navy">
			<table cellspacing="0" cellpadding="3" align="center">
				<TR ID="header" BGCOLOR="##ffce84">
					<td>&nbsp;</td>
					<td><b>Range Start</b></td>
					<td>&nbsp;</td>
					<td><b>Range End</b></td>
				</tr>					
				<cfloop index="i" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
					<cfset currentnode = evaluate("BidRule.VolumeGroups.Group_#i#")>
					<tr <CFIF i mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
						<td><b>Group #i#</b></td>
						<td align="center"><cfif i EQ 1>0<cfelse>#currentnode.Range_Start#</cfif></td>
						<td align="center">-</td>
						<td align="center"><cfif i EQ BidRule.VOLUMEGROUPS.INDEX_COUNT>*<cfelse><cfif currentnode.Range_End NEQ "*">#currentnode.Range_End#</cfif></cfif>&nbsp;&nbsp;<cfif bidrule.basic.Bid_Rule_UOM EQ 0>#dnpMessage#<cfelse>#getUOMLabel.Unit_Of_Measure_Desc#</cfif></td>
					</tr>
				</cfloop>
				<cfif BidRule.VOLUMEGROUPS.INDEX_COUNT EQ 0>
					<tr>
						<Td align="center" colspan="100%">#dnpMessage#</TD>
					</tr>
				</cfif>
			</table><BR><BR>


			<cfset theValidData = BidRule.type.Overage.ValidData>
			<cfif theValidData EQ 1 AND uomDesc NEQ dnpMessage>
				<cfset thisImgaeSrc = const_statusImageSrc_go>
			<cfelse>
				<cfset thisImgaeSrc = const_statusImageSrc_nogo>
			</cfif>
			<div align="left" class="headingStyle"><img src="#thisImgaeSrc#" alt="" border="0">&nbsp;Overage</div>
			<hr width="100%" align="left" color="navy">			
			<table width="400px" border="0" cellspacing="0" cellpadding="3" align="center">
				<cfset thisCounter = 1>
				<cfloop condition="thisCounter NEQ 0">
					<cfif not isdefined("BidRule.Type.Type_#thisCounter#")>
						<cfset thisCounter = 0>
						<cfbreak>
					</cfif>
					<cfset currentnode_type = evaluate("BidRule.Type.Type_#thisCounter#")>
					<cfif currentnode_type.action NEQ 3>
						<CFIF thisCounter mod 2><cfset bgcolor = "##ffce84"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
						<tr BGCOLOR="<cfoutput>#bgcolor#</cfoutput>">
							<td colspan="100%" style="border: 1 solid Black;"><b style="color: Navy; font-size: 14px;"><cfoutput>#currentnode_type.description#</cfoutput></b></td>
						</tr>
						
						<cfloop index="n" from="1" to="#BidRule.Volumegroups.Index_Count#" step="1">
						<CFIF n mod 2><cfset bgcolor = "white"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
						<cfset currentnode = evaluate("BidRule.Volumegroups.Group_#n#")>
						<cfoutput>
						<tr bgcolor="white">
							<td BGCOLOR="whitesmoke" width="50px" style="border-left: 1 solid Black;">&nbsp;</td>
							<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; border-left: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"	><cfif n EQ 1>0<cfelse>#currentnode.Range_Start#</cfif></td>
							<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>" 						>to</td>
							<td BGCOLOR="#bgcolor#" <cfif uomDesc NEQ dnpMessage>width="1px"</cfif> style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"	nowrap 					><cfif n EQ BidRule.Volumegroups.Index_Count>*<cfelse>#currentnode.Range_End#</cfif></td>
							<td BGCOLOR="#bgcolor#" nowrap style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>">&nbsp;&nbsp;#uomDesc#&nbsp;:</td>
							<td BGCOLOR="#bgcolor#"	style="<cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>" nowrap													><cfset dataValue = evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#")><cfif len(dataValue) EQ 0>#dnpMessage#<cfelse>#dataValue# &nbsp;<cfswitch EXPRESSION="#evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#_uom")#"><cfcase VALUE="1">$</cfcase><cfcase VALUE="2">%</cfcase></cfswitch></cfif></td>
							<td BGCOLOR="#bgcolor#" style="border-right: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"								><img src="/images/fill.gif" width="150" height="1px"></td>
						</tr>
						</cfoutput>
						</cfloop>
						<tr>
							<td colspan="100%" height="15px;" style="border-top: 1 solid Black;">&nbsp;</td>
						</tr>
					</cfif>
				<cfset thisCounter = thisCounter + 1>
				</CFLOOP>
			</table>
			
<!--- 			<cfset theValidData = BidRule.exceptions.ValidData>
			<cfif theValidData EQ 1 AND uomDesc NEQ dnpMessage>
				<cfset thisImgaeSrc = const_statusImageSrc_go>
			<cfelse>
				<cfset thisImgaeSrc = const_statusImageSrc_nogo>
			</cfif> --->
			<cfset thisImgaeSrc = const_statusImageSrc_go> <!--- this isnt required data --->
			<div align="left" class="headingStyle"><img src="#thisImgaeSrc#" alt="" border="0">&nbsp;Exception Overage</div>
			<hr width="100%" align="left" color="navy">
			<table width="400px" border="0" cellspacing="0" cellpadding="3" align="center">
				<cfset thisCounter = 1>
				<cfloop condition="thisCounter NEQ 0">
					<cfif not isdefined("BidRule.Exceptions.Groups.Group_#thisCounter#")>
						<cfset thisCounter = 0>
						<cfbreak>
					</cfif>
					<cfset currentnode_type = evaluate("BidRule.Exceptions.Groups.Group_#thisCounter#")>
					<cfif currentnode_type.action NEQ 3>
						<CFIF thisCounter mod 2><cfset bgcolor = "##ffce84"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
						<tr BGCOLOR="<cfoutput>#bgcolor#</cfoutput>">
							<td colspan="100%" style="border: 1 solid Black;"><b style="color: Navy; font-size: 14px;"><cfoutput>#currentnode_type.name#</cfoutput></b></td>
						</tr>
						
						<cfloop index="n" from="1" to="#BidRule.Volumegroups.Index_Count#" step="1">
						<CFIF n mod 2><cfset bgcolor = "white"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
						<cfset currentnode = evaluate("BidRule.Volumegroups.Group_#n#")>
						<cfoutput>
						<tr bgcolor="white">
							<td BGCOLOR="whitesmoke" width="50px" style="border-left: 1 solid Black;">&nbsp;</td>
							<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; border-left: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"	><cfif n EQ 1>0<cfelse>#currentnode.Range_Start#</cfif></td>
							<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>" 						>to</td>
							<td BGCOLOR="#bgcolor#" <cfif uomDesc NEQ dnpMessage>width="1px"</cfif> style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"	nowrap 					><cfif n EQ BidRule.Volumegroups.Index_Count>*<cfelse>#currentnode.Range_End#</cfif></td>
							<td BGCOLOR="#bgcolor#" nowrap style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>">&nbsp;&nbsp;#uomDesc#&nbsp;:</td>
							<td BGCOLOR="#bgcolor#"	style="<cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>" nowrap													><cfset dataValue = evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#")><cfif len(dataValue) EQ 0>#dnpMessage#<cfelse>#dataValue# &nbsp;<cfswitch EXPRESSION="#evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#_uom")#"><cfcase VALUE="1">$</cfcase><cfcase VALUE="2">%</cfcase></cfswitch></cfif></td>
							<td BGCOLOR="#bgcolor#" style="border-right: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"								><img src="/images/fill.gif" width="150" height="1px"></td>
						</tr>
						</cfoutput>
						</cfloop>
						<tr>
							<td colspan="100%" height="15px;" style="border-top: 1 solid Black;">&nbsp;</td>
						</tr>
					</cfif>
				<cfset thisCounter = thisCounter + 1>
				</CFLOOP>
				<cfif BidRule.Exceptions.Index_Count EQ 0>
					<div align="center" style="color: red; font-weight: bold;">Data Not Provided</div>
				</cfif>
			</table>				
			
		</td>
	</tr>
</table>





<form action="" method="post" name="MyForm" id="MyForm">
<input type="Hidden" name="SuppliedDataType" 	value="commitdata">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="savecomplete">
</form>
</cfoutput>
</div>
<hr color="Orange" width="75%">
<div align="center">
<cfif url.savecomplete EQ 0>
	<cfif 
		BidRule.Basic.ValidData EQ 1
		AND
		BidRule.Type.ValidData EQ 1
		AND
		BidRule.volumegroups.ValidData EQ 1
		AND
		BidRule.type.Overage.ValidData EQ 1>
	
		<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"verifyData()"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	<cfelse>
		<br><span style="color: red; font-weight:bold; font-size: 13px;">Please make sure all required information is provided before saving.</span>
	</cfif>
<cfelse>
		<CF_button
			button_name		=	""
			button_caption	=	"save complete - click here to close this window"
			button_action	=	"window.close()"
			button_type		=	"javascript_link"
			button_width	=	"300"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
</cfif>


</div>
