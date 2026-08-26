<!------ raw_materials_create_edit.cfm ----->

<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<cfoutput>
<script language="JavaScript" src="raw_material_create_edit.js"></script>

	<cfset requestSpan = DateDiff("d", requestObj.getStartDate(), requestObj.getEndDate()) + 1 />
	<cfset tmpPeriodType = trim(requestObj.getPeriodType()) />
	<table>
		<tr>
			<td>
				<b>View Periods By:</b>&nbsp;
				<select name="periodType">
					<option value="1" <cfif tmpPeriodType eq 1>selected</cfif>>Calendar</option>
					<option value="2" <cfif tmpPeriodType eq 2>selected</cfif>>Fiscal</option>
				</select>
				&nbsp;&nbsp;
				<CF_smallLink 
					title = "apply" 
					url = "##"
					parameters = "onClick=""JavaScript: return submitForm('#formName#','ceRequestMaterials', #form.page#, #form.bForward#);"""
				>
			</td>			
		</tr>
	</table>
	
	<!------ Loop thru products ----->
	<cfset requestProductArray = requestObj.getRequestProduct()>
	<cfset productCount = ArrayLen(requestProductArray)>
	<!------ <cfloop query="qGetProducts"> ----->
	<cfloop index="prodIndex" from="1" to="#productCount#">
		<cfset requestProduct = requestProductArray[prodIndex]>
		
		<cfset currentProductId = requestProduct.getRequestProdId()>
		<!------ <cfset productIdEscaped = request.app_general_functions.replaceHyphen(currentProductId)> ----->
		<cfset productIdEscaped = currentProductId>
		
		<cfset preservationId = requestProduct.getPreservationId()>
		<cfparam name="form.Mat_Id_#productIdEscaped#" 	default="">
		<cfset offset = requestProduct.getProcessingPeriodOffset()>
		<cfset productVolume = requestProduct.getVolume()>
		
		<!------ get limited time offer periods for this product ----->
		<cfquery name="qGetProductLTPPeriods" dbtype="query">
			SELECT	Start_Date, End_Date, Limited_Time_Offer
			FROM	qGetProductVolDist
			WHERE
					Limited_Time_Offer = 1
					AND
					FP_Product_ID = #currentProductId#
		</cfquery>
		<br>		
		
		<!------ raw materials ----->
		<cfset rawMatIdList = "">
		<cfset requestRawMaterialsArray = requestProduct.getRequestRawMaterial()>
		<cfset requestRawMaterialsCount = ArrayLen(requestRawMaterialsArray)>
		
		<table cellpadding="2" cellspacing="0" width="90%" border="0" bgcolor="##E8FCFD">
		<tr>
		<td colspan="100%" style="border-top:1px solid navy;">
			<B>#trim(requestProduct.getDesc())#</B>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<CF_smallLink 
				title = "select raw materials" 
				url = "##"
				parameters = "onClick=""javascript: return showRawMaterialSearchWindow('#formName#','Mat_Id_#productIdEscaped#');"""
			>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cf_smallLink
				title="distribute blend evenly"
				url="##"
				parameters=" onClick=""JavaScript: return distributeBlend(document.#formName#, '#productIdEscaped#');"""
				>
		</td>
		</tr>
		<tr>
		<td colspan="100%" style="border-bottom:1px solid navy;">
			Volume = #productVolume# #request.app_general_functions.getUOMDesc(requestProduct.getUom(), 0)#
			<cfif requestProduct.getUom() EQ 1> 
			<cfset productVolume = requestProduct.getlbVolume()>
			(#productVolume# Lbs)			
			</cfif>			
		</td>
		</tr>
		<tr>
		<td>
			<B>Processing Plant:</B>
			<input size="50" type="Text" name="processingPlant_#productIdEscaped#" value="#requestProduct.getProcessingPlantName()#"><br>
		</td>
		
		<td>
			<B>Preservation:</B>
			<select name="preservation_#productIdEscaped#">
				<cfloop query="qGetDistinctPreservations">
					<option value="#FP_Preservation_ID#"<cfif preservationId EQ FP_Preservation_ID> selected</cfif>>#Preservation_Desc#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<B>Offset:</B>			
			<cfset firstPeriodStart = "">
			<cfset firstPeriodEnd = "">
			<cfset lastPeriodStart = "">
			<cfset lastPeriodEnd = "">			
			<cfset changeOffsetScriptOn = false>
			<cfif requestRawMaterialsCount>
				<cfset firstRequestRawMaterial = requestRawMaterialsArray[1]>		
				
				<cfset volDistArray = firstRequestRawMaterial.getVolumeDist() />
				<cfset volDistArrayLen = ArrayLen(volDistArray)>
				<cfif volDistArrayLen>
					<cfset firstPeriodStart = volDistArray[1].getPeriodStartDate()>
					<cfset firstPeriodEnd = volDistArray[1].getPeriodEndDate()>
					<cfset lastPeriodStart = volDistArray[volDistArrayLen].getPeriodStartDate()>
					<cfset lastPeriodEnd = volDistArray[volDistArrayLen].getPeriodEndDate()>
					<cfset changeOffsetScriptOn = true>
				</cfif>
			</cfif>
			<input size="3" maxlength="3" type="Text" name="offset_#productIdEscaped#" value="#offset#" onkeypress="javaScript: return Allow_Key_List('0123456789')"<cfif changeOffsetScriptOn> onchange="javaScript: checkOffsetDays(this, '#DateFormat(requestObj.getStartDate(), "mm/dd/yyyy")#', '#DateFormat(requestObj.getEndDate(), "mm/dd/yyyy")#', '#DateFormat(firstPeriodStart, "mm/dd/yyyy")#', '#DateFormat(firstPeriodEnd, "mm/dd/yyyy")#', '#DateFormat(lastPeriodStart, "mm/dd/yyyy")#', '#DateFormat(lastPeriodEnd, "mm/dd/yyyy")#', '#productIdEscaped#');"</cfif>> days<br>
		</td>
		</tr>
		<tr id="vol_dist_period_mismatch_#productIdEscaped#" style="display:none;">
			<td colspan="100%" bgcolor="##ff0000" style="color:##ffffff">
			The volume distribution periods should be refreshed in order to reflect the change in the offset (#DateFormat(firstPeriodStart, "mm/dd/yyyy")# - #DateFormat(lastPeriodEnd, "mm/dd/yyyy")#)
			<cf_smallLink
			title="refresh"
			url="##"
			innerTextColor="##0000FF"
			outerTextColor="##FFFFFF"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','ceRequestMaterials', #form.page#, #form.bForward#);"""
			>
			</td>
		</tr>
		</table>
		<br>
		<input type="Hidden" name="productVolume_#productIdEscaped#" value="#productVolume#">
		<table width="90%" cellpadding="2" cellspacing="0" class="MainTable" border="0">
			<colgroup>
				<col span="1" width="5">
				<col span="1" width="">
				<col span="1" width="10%">
				<col span="1" width="10%">
				<col span="1" width="10%" align="right">
			</colgroup>
			<thead>
				<tr bgcolor="##FFCE84" valign="top">
					<td id="header">&nbsp;</td>
					<td id="header"><B>Raw Material</B>
					<span id="er_span_#productIdEscaped#">&nbsp;</span>
					</td>
					<td id="header"><B>Blend (%)</B>
					<span id="er_sp_Mat_Blend_#productIdEscaped#">&nbsp;</span>
					</td>
					<td id="header"><B>Yield Loss (%)</B></td>
					<td id="header"><B>Volume</B></td>
				</tr>
			</thead>
			<cfif requestRawMaterialsCount EQ 0>
				<tr>
					<td colspan="100%" style="color:##ff0000;" id="header">&nbsp;&nbsp;&nbsp;<B>No raw material sected</B></td>
				</tr>
			<cfelse>			
				<!------ Loop thru raw materials ----->				
				<cfloop index="rawMatIndex" from="1" to="#requestRawMaterialsCount#">
					<cfset requestRawMaterial = requestRawMaterialsArray[rawMatIndex]>
					<cfset rawMaterial = requestRawMaterial.getRawMaterial()>
					<cfset rawMatIdList = ListAppend(rawMatIdList, rawMaterial.getId(), ",") />
					
					<cfset currentRawMaterialId = requestRawMaterial.getRawMaterialId()>
					<cfset currentRequestRawMaterialId = requestRawMaterial.getRequestRawMaterialId()>
					<cfsavecontent variable="jsChangeEffectiveVolume">javaScript: changeEffectiveVolume('#productVolume#', document.all.effectiveVolume_#productIdEscaped#_#currentRawMaterialId#, 'Mat_Blend_#productIdEscaped#_#currentRawMaterialId#', 'Mat_YieldLoss_#productIdEscaped#_#currentRawMaterialId#', '#productIdEscaped#_#currentRawMaterialId#');</cfsavecontent>
					<tr ID="SCISSOR_ITEM_#currentRawMaterialId#">
						<td id="header"><img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" onclick="deleteThisRecord('#currentRawMaterialId#', '#currentRawMaterialId#', document.#formName#.Mat_Id_#productIdEscaped#)" style="cursor: hand;">&nbsp;</td>
						<td id="header"><B>#rawMaterial.getNumber()# #rawMaterial.getDesc()#</B>
						<cf_smallLink
							title="distribute volume evenly"
							url="##"
							parameters=" onClick=""JavaScript: return distributeVolume('#productVolume#', document.#formName#, '#productIdEscaped#', '#currentRawMaterialId#', #requestSpan#);"""
							>
						</td>
						<td><input size="3" maxlength="5" type="Text" name="Mat_Blend_#productIdEscaped#_#currentRawMaterialId#" value="#requestRawMaterial.getBlend()#" onchange="#jsChangeEffectiveVolume#" onkeypress="javaScript: return Allow_Key_List('0123456789.')" onblur="javaScript: makeValidIntFloat(this, 2, 0);">
						<span id="er_sp_Mat_Blend_#productIdEscaped#_#currentRawMaterialId#">&nbsp;</span>
						</td>
						<td>
							<input size="3" maxlength="5" type="Text" name="Mat_YieldLoss_#productIdEscaped#_#currentRawMaterialId#" value="#requestRawMaterial.getYieldLoss()#" onchange="#jsChangeEffectiveVolume#" onkeypress="javaScript: return Allow_Key_List('0123456789.')" onblur="javaScript: makeValidIntFloat(this, 2, 0);">
							<input type="Hidden" name="Request_Raw_Material_ID_#productIdEscaped#_#currentRawMaterialId#" value="#currentRequestRawMaterialId#">
							<span id="er_sp_Mat_YieldLoss_#productIdEscaped#_#currentRawMaterialId#">&nbsp;</span>
						</td>
						<td align="right">
						<cfset effectiveVolume = requestRawMaterial.getEffectiveVolume()>						
						
						<div style="display:inline;" id="effectiveVolume_#productIdEscaped#_#currentRawMaterialId#">#effectiveVolume#</div>
						&nbsp;						
						</td>
					</tr>
					
					<!------ volume distribution ----->
					
					<tr ID="SCISSOR_ITEM_#currentRawMaterialId#">
						<td colspan="100%">
						<cfset maxCols = 8>
						<table cellpadding="2" cellspacing="2" border="0" class="NotMaintable" reqProdId="#productIdEscaped#" rawMatId="#currentRawMaterialId#" id="tab_#productIdEscaped#_#currentRawMaterialId#">
							
								<cfset totalVolDist = 0>
								<cfset volDistArray = requestRawMaterial.getVolumeDist() />
								<!------ <cfset volDistArray = requestRawMaterial.getSourceVolumeDist() /> ----->
								<cfset volDistArrayLen = ArrayLen(volDistArray)>
								<cfloop index="volDistIndex" from="1" to="#volDistArrayLen#">
								
									<cfset volDist = volDistArray[volDistIndex]>
								 	<cfset Start_Date = DateFormat(volDist.getStartDate(), "mm/dd/yyyy") />
									<cfset End_Date = DateFormat(volDist.getEndDate(), "mm/dd/yyyy") />
									<cfset periodLength = DateDiff("d", Start_Date, End_Date) + 1>
									
									<!------ Find LTO ----->
									<cfset offsetRemovedPeriodStartDate = DateAdd("d", offset, volDist.getPeriodStartDate()) />
									<cfset offsetRemovedPeriodEndDate = DateAdd("d", offset, volDist.getPeriodEndDate()) />
									
									<cfset rawLTO = false />
									<cfloop query="qGetProductLTPPeriods">
										<cfif reqManager.checkDateOverLap(offsetRemovedPeriodStartDate, offsetRemovedPeriodEndDate, Start_Date, End_Date)>
											<cfset rawLTO = true />
											<cfbreak />
										</cfif>
									</cfloop>
									
									<cfif isNumeric(volDist.getVolume())>
										<cfset totalVolDist = totalVolDist + volDist.getVolume()>
									</cfif>
									<cfif volDistIndex mod maxCols EQ 1>
										<cfif volDistIndex GT 1>
										</tr>
										</cfif>
										<tr>
									</cfif>
									<td style="border:1px solid ##cccccc;" align="center" title="#DateFormat(Start_Date, "mm/dd/yy")# - #DateFormat(End_Date, "mm/dd/yy")# (#periodLength# days)">							
									<div style="background-color:##FFFFCC;">#volDist.getDesc()#
									<cfif rawLTO> <font color="red" size="-3">LTO</font></cfif></div>
									
									<cfset volDistOrder = volDist.getOrder()>
									<cfset Vol = trim(formatVolume(volDist.getVolume(), false))>
									<input type="text" value="#Vol#" name="periodVolume_#productIdEscaped#_#currentRawMaterialId#_#volDistOrder#" size="8" style="text-align:right;" onchange="javaScript: setVolumeDiff('#productIdEscaped#_#currentRawMaterialId#', document.all.effectiveVolume_#productIdEscaped#_#currentRawMaterialId#.innerText)" onkeypress="javaSCript: return Allow_Key_List('0123456789.');" onblur="javaScript: makeValidIntFloat(this, 2, 0);">
									<input type="hidden" name="periodStartDate_#productIdEscaped#_#currentRawMaterialId#_#volDistOrder#" value="#start_date#" />
									<input type="hidden" name="periodEndDate_#productIdEscaped#_#currentRawMaterialId#_#volDistOrder#" value="#end_date#" />
									</td>
								</cfloop>	
								<td style="color:red;">
								<cfset volDiff = effectiveVolume - totalVolDist>
								<cfset volDiff = trim(formatVolume(volDiff, false))>
								<font size="2" face="Ariel">&##916;</font> = <br>								
								<div id="volumeMismatch_#productIdEscaped#_#currentRawMaterialId#">#volDiff#</div>
								</td>
								<td>
								<span id="er_sp_Total_Vol_Dist_#productIdEscaped#_#currentRawMaterialId#">&nbsp;</span>
								</td>
							</tr>							
						</table>
						<input type="Hidden" name="periodLength_#productIdEscaped#_#currentRawMaterialId#" value="#volDistArrayLen#">
						<!--- <input type="Hidden" name="periodType_#productIdEscaped#_#currentRawMaterialId#" value="#requestRawMaterial.getPeriodType()#"> --->
						</td>
					</tr>
						
				</cfloop>
			</cfif>
		</table>
		<input type="Hidden" name="Mat_Id_#productIdEscaped#" value="#rawMatIdList#">
		<script language="JavaScript">
			prodIdEscapedArray[prodIdEscapedArray.length] = "#productIdEscaped#";
		</script>
	</cfloop>
	<br><br>
<cf_messagewindow>
	<cf_kickbackLink
		id = "#requestObj.getId()#"
		statusId = "#requestObj.getStatusId()#">
	<cf_smallLink
			title="save only"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','sRequestMaterials', #form.page#, #form.bForward#);"""
			>
	<cf_smallLink
			title="save & forward"
			url="##"
			parameters=" onClick=""JavaScript: return submitForm('#formName#','sRequestMaterials', #form.page#, 1);"""
			>
	
</cfoutput>