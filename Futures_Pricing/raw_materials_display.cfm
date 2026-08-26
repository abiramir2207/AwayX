<!------ raw_materials_display.cfm ----->
<cfoutput>
	<!------ Loop thru products ----->
	<cfset requestProductArray = requestObj.getRequestProduct()>
	<cfset productCount = ArrayLen(requestProductArray)>
	<cfloop index="prodIndex" from="1" to="#productCount#">
		<cfset requestProduct = requestProductArray[prodIndex]>
		<cfset currentProductId = requestProduct.getRequestProdId()>
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
		<table cellpadding="2" cellspacing="0" width="90%" border="0" bgcolor="##E8FCFD">
		<tr>
		<td colspan="100%" style="border-top:1px solid navy;">
			<B>#requestProduct.getDesc()#</B>			
		</td>
		</tr>
		<tr>
		<td colspan="100%" style="border-bottom:1px solid navy;">
			Volume = #requestProduct.getVolume()# #request.app_general_functions.getUOMDesc(requestProduct.getUom(), 0)#
			<cfif requestProduct.getUom() EQ 1> 
			(#requestProduct.getlbVolume()# Lbs)			
			</cfif>
		</td>
		</tr>
		<tr>
		<td>
			<B>Processing Plant:</B>
			#requestProduct.getProcessingPlantName()#
		</td>
		
		<td>
			<B>Preservation:</B>
			<cfif isnumeric(requestProduct.getPreservationId())>
				<cfquery name="qGetProductPreservations" dbtype="query">
					SELECT	*
					FROM	qGetDistinctPreservations
					WHERE
							FP_Preservation_ID = #requestProduct.getPreservationId()#
				</cfquery>
				#qGetProductPreservations.Preservation_Desc#
			</cfif>
		</td>
		<td>
			<B>Offset:</B>
			<cfif isNumeric(requestProduct.getProcessingPeriodOffset())>#requestProduct.getProcessingPeriodOffset()# days</cfif>
		</td>
		</tr>
		</table>
		<br>
		<table width="90%" cellpadding="2" cellspacing="0" class="MainTable">
			<colgroup>
				<col span="1" width="5">
				<col span="1" width="">
				<col span="1" width="10%">
				<col span="1" width="10%">
				<col span="1" width="10%">
			</colgroup>
			<thead>
				<tr bgcolor="##FFCE84">
					<td id="header">&nbsp;</td>
					<td id="header"><B>Raw Material</B></td>
					<td id="header"><B>Blend (%)</B></td>
					<td id="header"><B>Yield Loss (%)</B></td>
					<td id="header" align="right"><B>Volume</B></td>
				</tr>
			</thead>
			<!------ Loop thru raw materials ----->
			
			<cfset requestRawMaterialsArray = requestProduct.getRequestRawMaterial()>
			<cfset requestRawMaterialsCount = ArrayLen(requestRawMaterialsArray)>
			
			<cfloop index="rawMatIndex" from="1" to="#requestRawMaterialsCount#">
				<cfset requestRawMaterial = requestRawMaterialsArray[rawMatIndex]>
				<cfset rawMaterial = requestRawMaterial.getRawMaterial()>
					
				<tr>
					<td id="header">&nbsp;</td>
					<td>#rawMaterial.getNumber()# #rawMaterial.getDesc()#</td>
					<td>#requestRawMaterial.getBlend()#</td>
					<td>#requestRawMaterial.getYieldLoss()#</td>
					<td align="right">#requestRawMaterial.getEffectiveVolume()#</td>
				</tr>
				<!------ volume distributon ----->
				<tr>
					<td colspan="100%">
					<cfset maxCols = 8>
					<table cellpadding="2" cellspacing="2" border="0" class="NotMaintable">
						
							<cfset volDistArray = requestRawMaterial.getVolumeDist() />
							<cfset volDistArrayLen = ArrayLen(volDistArray)>
							<cfloop index="volDistIndex" from="1" to="#volDistArrayLen#">
								
								<cfset volDist = volDistArray[volDistIndex]>
								<cfset Start_Date = volDist.getStartDate() />
								<cfset End_Date = volDist.getEndDate() />
								<!------ Find LTO ----->
								<cfset offsetRemovedPeriodStartDate = DateAdd("d", requestProduct.getProcessingPeriodOffset(), volDist.getPeriodStartDate()) />
								<cfset offsetRemovedPeriodEndDate = DateAdd("d", requestProduct.getProcessingPeriodOffset(), volDist.getPeriodEndDate()) />
								
								<cfset rawLTO = false />
								<cfloop query="qGetProductLTPPeriods">
									<cfif reqManager.checkDateOverLap(offsetRemovedPeriodStartDate, offsetRemovedPeriodEndDate, Start_Date, End_Date)>
										<cfset rawLTO = true />
										<cfbreak />
									</cfif>
								</cfloop>
									
								<cfset periodLength = DateDiff("d", Start_Date, End_Date) + 1>
								<cfif volDistIndex mod maxCols EQ 1>
									<cfif volDistIndex GT 1>
									</tr>
									</cfif>
									<tr>
								</cfif>
								<td width="100" style="border:1px solid ##cccccc;" align="center" title="#DateFormat(Start_Date, "mm/dd/yy")# - #DateFormat(End_Date, "mm/dd/yy")# (#periodLength# days)">							
								<div style="background-color:##FFFFCC;">#volDist.getDesc()#<cfif rawLTO> <font color="red" size="-3">LTO</font></cfif></div>
								#volDist.getVolume()#
								</td>
							</cfloop>
						</tr>
					</table>
					</td>
				</tr>				
			</cfloop>
			
		</table>
	</cfloop>	
</cfoutput>