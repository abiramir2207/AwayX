<!---
NAME: <costs_section>

DESCRIPTION: Tag used to maintain the costs section

--->
<cfoutput>

<cfparam name="Attributes.totalList" default="">
<cfparam name="Attributes.action" default="" type="any">
<cfparam name="Attributes.name" default="" type="any">
	
<cfscript>

	function fontColor(num)
	{
		if (trim(num) gte 0 or trim(num) eq "")
			return "black";
		else
			return "red";
	}
	
</cfscript>

<!---get active cost/rebate components--->
<cfscript>
	comp = createObject("component","components.programs.rebates.RebateComponent");
	lumpSumObj = createObject("component","components.programs.lump_sum_components.LumpSumComponent");
</cfscript>
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////EDIT, DISPLAY, PRINT, EMAIL, FAX////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
<!--- <cfif CompareNoCase(attributes.action, "create")> --->

	<cfparam name="Attributes.CostType" default="">
	<cfparam name="Attributes.qItemTypes" default="" type="query">
	<cfparam name="Attributes.aItmClass" default="" type="array">
	<cfparam name="Attributes.aGrandCostTot" default="0" type="array">
	
	<cfset aCostTot = arrayNew(2) />
	<cfset aGrandCostTot = arrayNew(1) />

	<!---to maintain state, build query from form fields if form re-submits in edit mode--->
	<cfif isDefined("form.action") and ListFindNoCase("edit,create", form.action)>
		<cfscript>
			qGetCosts = QueryNew("Program_Rebates_Component_Name_Id, Program_Lump_Sum_Name_ID, Name, Cost, Trade_Plan_Cost_Percent_ID, Trade_Plan_Costs_ID");
		</cfscript>
		
		<!---Create counter--->
		<cfset costCount = 0 />
		
		<!---Loop through the form field names to determine how many costs exists--->
		<cfloop index="index" list="#Form.FieldNames#">
		
			<cfparam name="#Attributes.name#PercentDollar_#costCount#" default="" />
			<!---find each cost field--->
			<cfset cost = ListContainsNoCase(index, "#Attributes.name#CostName_") />
			<cfset costId = ListContainsNoCase(index, "#Attributes.name#CostNameId_") />
			<cfif cost or costId>
			
				<cfscript>
				
					QueryAddRow(qGetCosts);
					//if (Attributes.Name eq "incentive")
					if (not CompareNoCase(Attributes.Name,"incentive"))
					{
						QuerySetCell(qGetCosts, "Program_Rebates_Component_Name_Id", Evaluate("#Attributes.name#CostNameId_#costCount#"));
					}
					else if (not CompareNoCase(Attributes.Name,"lumpSum"))
					{
						QuerySetCell(qGetCosts, "Program_Lump_Sum_Name_ID", Evaluate("#Attributes.name#CostNameId_#costCount#"));
					}
					else
					{
						QuerySetCell(qGetCosts, "Name", Evaluate("#Attributes.name#CostName_#costCount#"));
					}
					QuerySetCell(qGetCosts, "Cost", Evaluate("#Attributes.name#Cost_#costCount#"));
					QuerySetCell(qGetCosts, "Trade_Plan_Cost_Percent_ID", Evaluate("#Attributes.name#PercentDollar_#costCount#"));
					QuerySetCell(qGetCosts, "Trade_Plan_Costs_ID", "1");
					
				</cfscript>
			
				<cfset costCount = costCount+1 />
			
			</cfif>
	
		</cfloop>

	<cfelse>

		<!---Query for all costs from database--->
		<cfset useLakebaseForqGetCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("trade_plan_costs")>
<cfif useLakebaseForqGetCosts>
	<cftry>
		<cfset qGetCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("trade_plan_costs", {
				"trade_plan_id" = "eq.#Trade_Plan_ID#",
				"trade_plan_cost_type_id" = "eq.#attributes.CostType#",
				"select" = "name,cost,trade_plan_cost_percent_id,trade_plan_costs_id,program_rebates_component_name_id,program_lump_sum_name_id"
			}), "name,cost,trade_plan_cost_percent_id,trade_plan_costs_id,program_rebates_component_name_id,program_lump_sum_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCosts>
<cfquery name="qGetCosts" datasource="#application.datasource#">
			SELECT 	Name,
					Cost,
					Trade_Plan_Cost_Percent_ID,
					Trade_Plan_Costs_ID,
					Program_Rebates_Component_Name_ID,
					Program_Lump_Sum_Name_ID
			FROM 	Trade_Plan_Costs
			WHERE	Trade_Plan_ID = '#Trade_Plan_ID#'
			AND		Trade_Plan_Cost_Type_ID = '#attributes.CostType#'
		</cfquery>
</cfif>
		
	</cfif>
	
	<cfset costGrndTotl = 0/>
	<cfset count = 0/>
	
	<!---////////////////////////////////////////////SECTION IF COST HAS RECORD COUNT///////////////////////////////////////////////--->
	
	<cfloop query="qGetCosts">

		<!---if the cost type is incentive then let's get the name based on the id--->
		<cfif not CompareNoCase(Attributes.name, "incentive")>
			<cfscript>
				qGetActiveComps = comp.getActive(Program_Rebates_Component_Name_ID);
				qGetCompName = comp.getComp(Program_Rebates_Component_Name_ID);
			</cfscript>
		<!---if the cost type is lump sum then let's get the name based on the id--->
		<cfelseif not CompareNoCase(Attributes.name, "lumpSum")>
			<cfscript>
				qGetActiveLumpSumNames = lumpSumObj.getActive(Program_Lump_Sum_Name_ID);
				qGetLumpSumName = lumpSumObj.getLumpSumName(Program_Lump_Sum_Name_ID);
			</cfscript>
		</cfif>
	
		<tr id="calcRow" section="#Attributes.name#">
			<td nowrap>
				<cfif ListFindNoCase("print,display,email,fax", Attributes.action)>
					<b>
					<cfif Attributes.name eq "incentive">
						#qGetCompName.Program_Rebates_Component_Name#
					<cfelseif Attributes.name eq "lumpSum">
						#qGetLumpSumName.Program_Lump_Sum_Name#
					<cfelse>
						#Name#
					</cfif></b>:&nbsp;&nbsp;#Cost#&nbsp;&nbsp;<cfif Trade_Plan_Cost_Percent_ID eq 1>Percent<cfelse>Dollar(s)</cfif>
				<cfelse>
					
					<!---if the cost type is incentive then display drop down--->
					<cfif not CompareNoCase(Attributes.name, "incentive")>
						<select name="#Attributes.name#CostNameId_#count#">
							<option value="0">Select cost...</option>
						<cfloop query="qGetActiveComps">
							<option value="#Program_Rebates_Component_Name_ID#" <cfif qGetCompName.Program_Rebates_Component_Name_ID eq Program_Rebates_Component_Name_ID>selected</cfif>>#Program_Rebates_Component_Name#</option>
						</cfloop>
						</select>
					<!---if the cost type is lump sum then display drop down--->
					<cfelseif not CompareNoCase(Attributes.name, "lumpSum")>
						<select name="#Attributes.name#CostNameId_#count#">
							<option value="0">Select cost...</option>
						<cfloop query="qGetActiveLumpSumNames">
							<option value="#Program_Lump_Sum_Name_ID#" <cfif qGetLumpSumName.Program_Lump_Sum_Name_ID eq Program_Lump_Sum_Name_ID>selected</cfif>>#Program_Lump_Sum_Name#</option>
						</cfloop>
						</select>
					<cfelse>
						<input size="30" type="text" name="#Attributes.name#CostName_#count#" value="#Name#" />
					</cfif>
					<input size="2" maxlength="15" type="text" name="#Attributes.name#Cost_#count#" value="#Cost#" onKeyUp="clenseText(this, '0123456789.');" />
					
					<cfif CompareNoCase(Attributes.name, "lumpSum")>
						<select name="#Attributes.name#PercentDollar_#count#">
							<option value="1" <cfif Trade_Plan_Cost_Percent_ID eq 1>selected</cfif>>%</option>
							<option value="2" <cfif Trade_Plan_Cost_Percent_ID eq 2>selected</cfif>>$</option>
						</select>
					</cfif>
					
					<input type="button" name="addIncCost" value="+" onClick="addFilterRows(this)" />
					<input type="button" name="deleteIncCost" value="-" onClick="deleteFilterRows(this)"/>
				</cfif>
			</td>
				
			<cfset trdePlnCstId = qGetCosts.Trade_Plan_Costs_ID />
			<cfset costPcntDoll = Trade_Plan_Cost_Percent_ID />
			<cfset costValCalc = Cost />
			<cfset x = 0 />
			<cfset cstTotl = 0 />
			<cfset isChecked = 0 />	
		
			<cfloop query="Attributes.qItemTypes">
		
				<!--- <cfif Attributes.name neq "lumpSum"> --->
				<cfif CompareNoCase(Attributes.name, "lumpSum")>
			
					<!---to maintain state, get check bit from form scope if form re-submits in edit mode--->
					<!--- <cfif isDefined("form.action") and form.action eq "edit"> --->
					<cfif isDefined("form.action") and ListFindNoCase("edit,create", form.action)>
			
						<cfif isDefined("form.#Attributes.name#CostCalc#x#_#count#")>
							<cfset isChecked = 1 />
						<cfelseif x gt ListLen(Form.ItemTotal)-1>
							<cfset isChecked = 1 />
						<cfelse>
							<cfset isChecked = 0 />
						</cfif>
			
					<cfelse>
		
						<cfset useLakebaseForqGetCheckBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("trade_plan_item_cost")>
<cfif useLakebaseForqGetCheckBit>
	<cftry>
		<cfset qGetCheckBit = application.oLakebase.toQuery(
			application.oLakebase.selectRows("trade_plan_item_cost", {
				"type_group_desc_id" = "eq.#Type_Group_Desc_ID#",
				"trade_plan_costs_id" = "eq.#trdePlnCstId#",
				"select" = "check_bit"
			}), "check_bit"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCheckBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCheckBit>
<cfquery name="qGetCheckBit" datasource="#application.datasource#">
							SELECT	Check_Bit
							FROM	Trade_Plan_Item_Cost
							WHERE	Type_Group_Desc_ID = '#Type_Group_Desc_ID#'
							AND		Trade_Plan_Costs_ID = '#trdePlnCstId#'
						</cfquery>
</cfif>
		
						<cfset isChecked = qGetCheckBit.Check_Bit />
			
					</cfif>

					<cfset tmpVal = Attributes.aItmClass[x+1][costPcntDoll] />
					
					<!---if the value wasn't checked then set to 0--->
					<cfif not isChecked>
						<cfset costVal = 0 />
					<cfelse>
						<cfif trim(costValCalc) eq "">
							<cfset costVal = 0 />
						<cfelse>
							<cfif costPcntDoll eq 1>
								<cfset costVal = tmpVal * (costValCalc / 100) />
							<cfelse>
								<cfset costVal = tmpVal * costValCalc />
							</cfif>
						</cfif>					
					</cfif>

					<cfset aCostTot[x+1][count+1]=costVal>
					
					<td ALIGN="right" NOWRAP>
						<div style="display:inline;" id="#Attributes.name#CostClassDiv#x#_#count#"><font color="#fontColor(costVal)#">#LSNumberFormat(costVal, "(_$,_.__)")#</font></div>
						<input type="hidden" name="#Attributes.name#CostClass#x#_#count#">
						<!--- <cfif Attributes.action eq "edit"> --->
						<cfif ListFindNoCase("edit,create",Attributes.action)>
							<input name="#Attributes.name#CostCalc#x#_#count#" type="checkbox" <cfif isChecked>checked</cfif> />
						</cfif> 
					</td>
					
					<cfset cstTotl = cstTotl + costVal />
					
					<cfset x =  x+1 />
			
				<cfelse>
					
					<!--- <cfif trim(costValCalc) eq ""> --->
					<cfif not CompareNoCase(trim(costValCalc), "")>
						<cfset costVal = 0 />
					<cfelse>
						<cfset cstTotl = costValCalc />
					</cfif>
					
					<td ALIGN="right" NOWRAP>&nbsp;</td>
					
				</cfif>
			
			</cfloop>

			<td ALIGN="right">
				<div id="#Attributes.name#CostTotalDiv_#count#"><font color="#fontColor(cstTotl)#">#LSNumberFormat(cstTotl, "(_$,_.__)")#</font></div>
				<input type="hidden" name="#Attributes.name#CostTotal_#count#" />
			</td>
		</tr>
		
		<cfset costGrndTotl = costGrndTotl + cstTotl/>		
		<cfset count = count+1 />		
				
	</cfloop>		
	
	<!---////////////////////////////////////////////SECTION WITHOUT RECORD COUNT///////////////////////////////////////////////--->
	
	<cfif not qGetCosts.RecordCount>
		
		<!---if the cost type is incentive then let's get the name based on the id--->
		<cfif not CompareNoCase(Attributes.name, "incentive")>
			<cfscript>
				qGetActiveComps = comp.getActive();
			</cfscript>
		<!---if the cost type is lump sum then let's get the name based on the id--->
		<cfelseif not CompareNoCase(Attributes.name, "lumpSum")>
			<cfscript>
				qGetActiveLumpSumNames = lumpSumObj.getActive();
			</cfscript>
		</cfif>
		
		<tr id="calcRow" section="#Attributes.name#">
			<td nowrap>
				<cfif ListFindNoCase("print,display,email,fax", Attributes.action)>
					<b>N/A</b>
				<cfelse>
					
					<!---if the cost type is incentive then display drop down--->
					<!--- <cfif Attributes.name eq "incentive"> --->
					<cfif not CompareNoCase(Attributes.name, "incentive")>
						<select name="#Attributes.name#CostNameId_0">
							<option value="0">Select cost...</option>
						<cfloop query="qGetActiveComps">
							<option value="#Program_Rebates_Component_Name_ID#">#Program_Rebates_Component_Name#</option>
						</cfloop>
						</select>
					<cfelseif not CompareNoCase(Attributes.name, "lumpSum")>
						<select name="#Attributes.name#CostNameId_0">
							<option value="0">Select cost...</option>
						<cfloop query="qGetActiveLumpSumNames">
							<option value="#Program_Lump_Sum_Name_ID#">#Program_Lump_Sum_Name#</option>
						</cfloop>
						</select>
					<cfelse>
						<input size="30" type="text" name="#Attributes.name#CostName_0" value="" />
					</cfif>
					
					<input size="2" maxlength="15" type="text" name="#Attributes.name#Cost_0" value="" onKeyUp="clenseText(this, '0123456789.');" />
					
					<!--- <cfif Attributes.name neq "lumpSum"> --->
					<cfif CompareNoCase(Attributes.name, "lumpSum")>
						<select name="#Attributes.name#PercentDollar_0">
							<option value="1">%</option>
							<option value="2">$</option>
						</select>
					</cfif>
					
					<input type="button" name="addIncCost" value="+" onClick="addFilterRows(this)" />
					<input type="button" name="deleteIncCost" value="-" onClick="deleteFilterRows(this)"/>
					
				</cfif>
				
			</td>

			<cfset x = 0 />
			<cfset cstTotl = 0 />
			<cfset isChecked = 0 />	
		
			<cfloop query="Attributes.qItemTypes">
		
				<cfif CompareNoCase(Attributes.name, "lumpSum")>
			
					<!---to maintain state, get check bit from form scope if form re-submits in edit mode--->
					<cfif isDefined("form.action") and ListFindNoCase("edit,create",form.action)>
			
						<cfif isDefined("form.#Attributes.name#CostCalc#x#_0")>
							<cfset isChecked = 1 />
						<cfelseif x gt ListLen(Form.ItemTotal)-1>
							<cfset isChecked = 1 />
						<cfelse>
							<cfset isChecked = 0 />
						</cfif>
						
					</cfif>
					
					<td ALIGN="right" NOWRAP>
						<div style="display:inline;" id="#Attributes.name#CostClassDiv#x#_0">#LSNumberFormat(0.00, "(_$,_.__)")#</div>
						<input type="hidden" name="#Attributes.name#CostClass#x#_0">
						<!--- <cfif Attributes.action eq "edit"> --->
						<cfif ListFindNoCase("edit,create",Attributes.action)>
							<input name="#Attributes.name#CostCalc#x#_0" type="checkbox" <cfif isChecked>checked</cfif> />
						</cfif> 
					</td>
					
					<cfset x =  x+1 />
			
				<cfelse>
				
					<td ALIGN="right" NOWRAP>&nbsp;</td>
					
				</cfif>
			
			</cfloop>

			<td ALIGN="right">
				<div id="#Attributes.name#CostTotalDiv_0">#LSNumberFormat(0.00, "(_$,_.__)")#</div>
				<input type="hidden" name="#Attributes.name#CostTotal_0" />
			</td>
		</tr>		
		
		<cfset costGrndTotl = costGrndTotl + cstTotl/>
		
	</cfif>
	<!---////////////////////////////////////////////TOTAL///////////////////////////////////////////////--->	
			
	<tr class="thinTop" id="totRow">
		<td>Total</td>
		<cfloop index="x" list="#Attributes.totalList#">
		
			<!--- <cfif Attributes.name neq "lumpSum"> --->
			<cfif CompareNoCase(Attributes.name, "lumpSum")>
			
				<cfparam name="Attributes.aGrandCostTot[x+1]" default=0/>
				<cfset classCstTotl = 0 />
			
				<cfloop query="qGetCosts">
					<cfset classCstTotl = classCstTotl + aCostTot[x+1][CurrentRow] />
				</cfloop>

				<cfset Attributes.aGrandCostTot[x+1] = Attributes.aGrandCostTot[x+1] + classCstTotl />
			
				<td ALIGN="right">
					<div style="display:inline;" id="#Attributes.name#CostClassTotalDiv#x#"><font color="#fontColor(classCstTotl)#">#LSNumberFormat(classCstTotl, "(_$,_.__)")#</font></div>
					<input type="hidden" name="#Attributes.name#CostClassTotal#x#" />
					<cfif ListFindNoCase("edit,create",Attributes.action)>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>
				</td>
			<cfelse>
			
				<td ALIGN="right">&nbsp;</td>
				
			</cfif>
			
		</cfloop>
	
		<td align="right" valign="top">
			<div style="display:inline;" id="#Attributes.name#CostTotalDiv"><font color="#fontColor(costGrndTotl)#">#LSNumberFormat(costGrndTotl, "(_$,_.__)")#</font></div>
			<input type="hidden" name="#Attributes.name#CostTotal" />
		</td>
	</tr>

	<!---return caller variables--->
	<cfset "Caller.#Attributes.rReturnGrndTotlArray#" = Attributes.aGrandCostTot>
	<cfset "Caller.#Attributes.rCostGrndTotl#" = costGrndTotl>
	
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////////////CREATE////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<!---
<cfelse>
	
	<!---cost row--->
	<tr id="calcRow" section="#Attributes.name#">
		<td nowrap>
			<!---if the cost type is incentive then display drop down--->
			<cfif not CompareNoCase(Attributes.name, "incentive")>
				<select name="#Attributes.name#CostNameId_0">
					<option value="0">Select cost...</option>
				<cfloop query="qGetActiveComps">
					<option value="#Program_Rebates_Component_Name_ID#">#Program_Rebates_Component_Name#</option>
				</cfloop>
				</select>
			<cfelse>
				<input size="30" type="text" name="#Attributes.name#CostName_0" />
			</cfif>
			<input size="4" maxlength="15" type="text" name="#Attributes.name#Cost_0" onKeyUp="clenseText(this, '0123456789.');" />
			<!--- <cfif Attributes.name neq "lumpSum"> --->
			<cfif CompareNoCase(Attributes.name, "lumpSum")>
			<select name="#Attributes.name#PercentDollar_0">
				<option value="1">%</option>
				<option value="2">$</option>
			</select>
			</cfif>
			<input type="button" name="addIncCost" value="+" onClick="addFilterRows(this)" />
			<input type="button" name="deleteIncCost" value="-" onClick="deleteFilterRows(this)"/>
		</td>
		
		
		<cfloop index="x" list="#attributes.totalList#">
		<td align="right" NOWRAP>
		<cfif CompareNoCase(Attributes.name, "lumpSum")>
			<div style="display:inline;" id="#Attributes.name#CostClassDiv#x#_0"></div>
			<input type="hidden" name="#Attributes.name#CostClass#x#_0" />
			<input name="#Attributes.name#CostCalc#x#_0" type="checkbox" checked />
		</cfif>
		</td>
		</cfloop>
		
		<td align="right">
			<div id="#Attributes.name#CostTotalDiv_0"></div>
			<input type="hidden" name="#Attributes.name#CostTotal_0" />
		</td>
	</tr>
	
	<!---total row for cost type--->
	<tr class="thinTop" id="totRow">
		<td>Total</td>
		<cfloop index="x" list="#attributes.totalList#">
		<td align="right">
		<cfif CompareNoCase(Attributes.name, "lumpSum")>
			<div style="display:inline;" id="#Attributes.name#CostClassTotalDiv#x#"></div>
			<input type="hidden" name="#Attributes.name#CostClassTotal#x#" />
			<cfif action neq "print">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>
		<cfelse>
			&nbsp;
		</cfif>
		</td>
		</cfloop>
		<td align="right" valign="top">
			<div id="#Attributes.name#CostTotalDiv"></div>
			<input type="hidden" name="#Attributes.name#CostTotal" />
		</td>
	</tr>
		
</cfif>
 --->
</cfoutput>