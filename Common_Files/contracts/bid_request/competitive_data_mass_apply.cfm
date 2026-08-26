<!----
	Name: competitive_data_mass_apply.cfm
	Copyright (c) 2014 Blacksmith Applications, Inc.
	Description:Used to MASS UPDATE competitive data.
	Label:D43580	 :: Competitive Information Page - Updates
---->
<cfparam name="url.contract_main_id" 	default="0">
<cfparam name="url.product_group_id" 	default="0">
<cfparam name="variables.selectedList" 	default="">
<cfparam name="variables.rowIndx" 		default="1">
<cfparam name="variables.existingLen"	default="0">

<cfscript>
	variables.components = {};
	variables.components.competitive = createObject("component", "components.programs.bid_request.CompetitiveDataManager");
	variables.templateSettings = variables.components.competitive.getTemplateSettings(url.contract_main_id);
	variables.allProducts = variables.components.competitive.getProducts(url.contract_main_id);
	variables.competitors = variables.components.competitive.getCompetitors();
	variables.itemsInfo = variables.components.competitive.getProgramCompetitiveProductData(url.contract_main_id);
	variables.defaultUOM = variables.components.competitive.getProgramUOM(url.Contract_Main_ID);
	variables.nClientBidId = variables.components.competitive.getClientBidId();
</cfscript>

<cfif isdefined('form.submit')>
	
	<cfparam name="form.won" 				default="2" />
	<cfparam name="form.shared_level1" 		default="0" />
	<cfparam name="form.incremental_level1" default="0" />
	<cfparam name="form.specd_level1" 		default="0" />
	<cfparam name="form.incremental" 		default="0" />
	<cfparam name="form.Shared" 			default="0" />
	<cfparam name="form.Specd" 				default="0" />
	
	<!---is delivery type flagged as included--->
	<cfif variables.templateSettings.Delivery_type EQ 0>
		<cfset form.Delivery =  "0">
	</cfif>
	<!---is category flagged as included--->
	<cfif variables.templateSettings.category EQ 0>
		<cfset form.Category =  "0">
	</cfif>
	<!---is package flagged as included--->
	<cfif variables.templateSettings.Package EQ 0>
		<cfset form.Package =  "0">
	</cfif>

	<cfif isdefined('form.Existing_competitor_id')>
		
		<!--- Tim Ford - Label 44526: We need to handle for which checkboxes were selected for existing entries--->
		<!--- Handle Incremental, Shared and Specd for existing first --->
		<!---
		<cfloop index="exIdx" from="1" to="#listlen(form.Existing_competitor_id)#">
			<!--- Incremental --->
			<cfif variables.templateSettings.Incremental>
				<cfparam name="form.Existing_Incremental_#exIdx#" default="0" />
				<cfset form.Existing_Incremental = listappend(form.Existing_Incremental, form["Existing_Incremental_" & exIdx]) />
			</cfif>
			<!--- Shared --->
			<cfif variables.templateSettings.Shared>
				<cfparam name="form.Existing_Shared_#exIdx#" default="0" />
				<cfset form.Existing_Shared = listappend(form.Existing_Shared, form["Existing_Shared_" & exIdx]) />
			</cfif>
			<!--- Specd --->
			<cfif variables.templateSettings.Specd>
				<cfparam name="form.Existing_Specd_#exIdx#" default="0" />
				<cfset form.Existing_Specd = listappend(form.Existing_Specd, form["Existing_Specd_" & exIdx]) />
			</cfif>
			
			<cfset variables.existingLen = variables.existingLen + 1 />
			
		</cfloop>
		--->
		
		<!--- Incremental --->
		<cfif variables.templateSettings.Incremental>
			<cfset form.competitor_Incremental = listappend(form.Existing_Incremental,form.competitor_Incremental)/>
		<cfelse>
			<cfset form.competitor_Incremental = listappend(form.Existing_Incremental,0)/>
		</cfif>
		<!--- Shared --->
		<cfif variables.templateSettings.Shared>
			<cfset form.competitor_Shared = listappend(form.Existing_Shared,form.competitor_Shared)/>
		<cfelse>
			<cfset form.competitor_Shared = listappend(form.Existing_Shared,0)/>
		</cfif>
		<!--- Specd --->
		<cfif variables.templateSettings.Specd>
			<cfset form.competitor_Specd = listappend(form.Existing_Specd,form.competitor_Specd)/>
		<cfelse>
			<cfset form.competitor_Specd = listappend(form.Existing_Specd,0)/>
		</cfif>
		<!---Delivery_type--->
		<cfif variables.templateSettings.Delivery_type>
			<cfset form.competitor_delivery = listappend(form.Existing_competitor_delivery,form.competitor_delivery)/>
		<cfelse>
			<cfset form.competitor_delivery = listappend(form.Existing_competitor_delivery,0)/>
		</cfif>
		
		<!---<cfset form.competitorFields = form.competitorFields + listlen(form.Existing_competitor_id)>--->
		<cfset form.competitor_id = listappend(form.Existing_competitor_id,form.competitor_id)/>
		<cfset form.competitor_rate = listappend(form.Existing_competitor_rate,form.competitor_rate)/>
		<cfset form.competitor_uom = listappend(form.Existing_competitor_uom,form.competitor_uom)/>
		<cfset form.competitor_won = listappend(form.Existing_Won,form.competitor_won)/>
		
	</cfif>

	<cfset form.won_level1				= listGetAt(form.Competitor_Won, 1) />
	<cfset form.Client_Bid_ID_level1 	= listGetAt(form.competitor_id, 1) />
	<cfset form.client_rate_level1		= listGetAt(form.competitor_rate, 1) />
	<cfset form.client_uom_level1		= listGetAt(form.competitor_uom, 1) />
	<cfset form.client_delivery_level1	= listGetAt(form.competitor_delivery, 1) />
	
	<!--- We have to set the loop count to start after the existing form variables. This is to handle for the rows that have been added dynamically.
	<cfif variables.existingLen gte 1>
		<cfset nLoopFrom = variables.existingLen + 1 />
	<cfelse>
		<cfset nLoopFrom = 1 />
	</cfif>
	
	<!--- Handle Incremental, Shared and Specd for competitor --->
	<cfloop index="comIdx" from="1" to="#form.competitorFields#">

		<!--- Incremental --->
		<cfif variables.templateSettings.Incremental>
			<cfparam name="form.competitor_Incremental_#comIdx#" default="0" />
			<cfset form.competitor_Incremental = listappend(form.competitor_Incremental, form["competitor_Incremental_" & comIdx]) />
		</cfif>
		<!--- Shared --->
		<cfif variables.templateSettings.Shared>
			<cfparam name="form.competitor_Shared_#comIdx#" default="0" />
			<cfset form.competitor_Shared = listappend(form.competitor_Shared, form["competitor_Shared_" & comIdx]) />
		</cfif>
		<!--- Specd --->
		<cfif variables.templateSettings.Specd>
			<cfparam name="form.competitor_Specd_#comIdx#" default="0" />
			<cfset form.competitor_Specd = listappend(form.competitor_Specd, form["competitor_Specd_" & comIdx]) />
		</cfif>
		
		<!--- if client competitor data is in the list then set the data for that --->
		<!---<cfif listGetAt(form.competitor_id, comIdx) eq form.Client_Bid_Id>
		<cfset form.client_rate	= listGetAt(form.competitor_rate, comIdx) />
		<cfset form.won 		= listGetAt(form.Competitor_Won, comIdx) />
		
		<cfset form.incremental = listGetAt(form.Competitor_incremental, comIdx) />
		<cfset form.Shared 		= listGetAt(form.Competitor_Shared, comIdx) />
		<cfset form.Specd 		= listGetAt(form.Competitor_Specd, comIdx) />
		</cfif>--->
		
	</cfloop>
	--->
	
	<cfif listLen(form.competitor_Shared)>
		<cfset form.shared_level1			= listGetAt(form.competitor_Shared, 1) />
	</cfif>
	
	<cfif listLen(form.competitor_Incremental)>
		<cfset form.incremental_level1		= listGetAt(form.competitor_Incremental, 1) />
	</cfif>
	
	<cfif listLen(form.competitor_Specd)>
		<cfset form.specd_level1			= listGetAt(form.competitor_Specd, 1) />
	</cfif>
	
	<cfset createObject("component", "components.programs.bid_request.CompetitiveDataManager").saveMassApplyData(form)>
	<CF_CRYP type="en" key="#request.key#" string="#url.contract_main_id#" />
	<CFSET CID = cryp.value />
	<cfoutput>
		<script type="text/javascript">
			window.opener.location="/Common_Files/contracts/bid_request/competitive_data.cfm?CID=#CID#";
			self.close();
		</script>
	</cfoutput>
	
</cfif>

<cfif url.contract_main_id EQ 0>
	Something went wrong, please try again.
<cfelse>

	<style>
		  ::-ms-clear {
        	display: none;
    		}
			
		  #program {
		    background-color: #FFCE84;
		    height: 26px;
		    border-top:1px solid black;
		    border-bottom:1px solid black;
		    width: 100%;
			margin-bottom:10px;
			font-weight:bold;
		  }
		  #programTable {
		    margin-top:3px;
			width: 100%;
		  }
		  #programTable td {
		    font-size: 12px;
			padding: 0 15px;
			width: 50%;
		  }
		  #programTable td.right {
		  	text-align:right;
		  }
		  
		  .topRow{
		  	background-color: #eeffee;
		  }
	</style>

	<cfif url.product_group_id NEQ 0 AND url.product_group_id NEQ 'Null'>
		<cfset variables.clientinfo = variables.components.competitive.getClientWonInfo(url.contract_main_id, url.product_group_id)>
		<cfset getExistingCompetitor = variables.components.competitive.getExistingCompetitor(url.contract_main_id, url.product_group_id)>
 	</cfif>

	<!---Check Template Settings for Optional columns--->
	<cfset OptionalColumns = "Won">

    <!---is delivery type flagged as included--->
    <cfif variables.templateSettings.Delivery_type>
      <cfset OptionalColumns =  ListAppend(OptionalColumns,"Delivery")>
    </cfif>
    <!---is category flagged as included--->
    <cfif variables.templateSettings.category>
       <cfset variables.qCategories = variables.components.competitive.getCategories()>
      <cfset OptionalColumns =  ListAppend(OptionalColumns, "Category")>
    </cfif>
    <!---is package flagged as included--->
    <cfif variables.templateSettings.Package>
       <cfset variables.qPackages = variables.components.competitive.getPackages()>
      <cfset OptionalColumns =  ListAppend(OptionalColumns, "Package")>
    </cfif>

    <!---is incremental flagged as included--->
    <cfif variables.templateSettings.Incremental>
      <cfset OptionalColumns = ListAppend(OptionalColumns, "Incremental")>
	</cfif>
    <!---is shared flagged as included--->
    <cfif variables.templateSettings.Shared>
      <cfset OptionalColumns =  ListAppend(OptionalColumns, "Shared")>
	</cfif>
    <!---is specd flagged as included--->
    <cfif variables.templateSettings.Specd>
      <cfset OptionalColumns =  ListAppend(OptionalColumns, "Specd")>
	</cfif>

	<!--- gather a list of distinct type codes --->
	<cfquery name="variables.qTypeCodes" dbtype="query">
		SELECT DISTINCT Group_Desc, Product_Group_ID
		FROM variables.itemsInfo
		WHERE Product_Group_ID != ''
		AND Product_Group_ID is not null
		ORDER BY group_desc
	</cfquery>
 	<!---Gather program number and title --->
	<cfquery name="variables.contractInfo" datasource="#application.datasource#">
		SELECT Program_Control_Panel_Options.Created_Type as CreatedType, Contract_Main.Contract_Number
		FROM Contract_Main
		INNER JOIN Program_Control_Panel_Options
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		WHERE Contract_Main_ID = #url.contract_main_id#
		AND Program_Control_Panel_Options.deleted = 0
	</cfquery>

	<cfif url.product_group_id NEQ 0 AND url.product_group_id NEQ 'Null'>

		<!--- get selected type codes --->
		<cfquery name="variables.qGetSelectedTypeCodes" dbtype="query">
			SELECT DISTINCT Group_Desc
			FROM variables.qTypeCodes
			WHERE Product_Group_ID != ''
			AND Product_Group_ID is not null
			and Product_Group_ID IN (#ListQualify(url.product_group_id, "'")#)
			ORDER BY group_desc
		</cfquery>
		
		<cfset variables.selectedList = ListAppend(variables.selectedList, ValueList(variables.qGetSelectedTypeCodes.Group_Desc)) />
		
 	</cfif>
	
	<cfoutput>
	<!--- Header --->
	<div id="program">
		<table id="programTable">
			<tr>
				<td><B>Competitive Data Mass Update</B></td>
				<td class="right">Program Number: <B>#variables.contractInfo.Contract_Number#</B></td>
			</tr>
		</table>
	</div>
	
	<form name="massupdate" action="competitive_data_mass_apply.cfm?contract_main_id=#url.contract_main_id#" method="post" id="massupdate">
		
		<!--- Product type drop down --->
		<cfif len(variables.allProducts.Product_Group_ID) OR variables.allProducts.Product_Group_ID EQ 'NULL'>
			<b>Product Group : </b>
		<cfelse>
			<b>#application.returned_customer_setting.Item_Label# #application.returned_customer_setting.type_code_label_singular# :</b>
		</cfif>
		<select name="productKind" id="productKind" multiple="multiple" style="width:250px;" title="#variables.selectedList#">
			<cfloop query="variables.qTypeCodes">
				<cfif ListFind(url.product_group_id, product_group_id,',')>
					<cfset selected = 'selected'>
				<cfelse>
					<cfset selected = ''>
				</cfif>
			<option value="#product_group_id#" #selected#>#group_desc#</option>
			</cfloop>
		</select>
	
		<div style="margin-bottom:5px;width:100%;text-align:center;border:solid;border-width:2px;border-color:FFFFFF;margin-top:5px;">
			<!---
			<b>If any of these fields (e.g. competitor, rate, uom<cfif variables.templateSettings.Delivery_type>, delivery</cfif>) are blank, the row will not save.</b>
			--->
		</div>
		<!---Competitor Info --->
		<table width="100%" border="0" cellspacing="0" cellpadding="2">
			<tr id="program">
				<td>Won</td>
				<td>Competitor</td>
				<td>Rate</td>
				<td>UOM</td>
				<cfif variables.templateSettings.Delivery_type>
				<td>Delivery</td>
				</cfif>
				<!--- Tim Ford - Label 44526: All Bid data will pertain to the client so we will be storing it in the Program_Product_Bid_Info table and Competitor data will get stored in the Program_Competitive_Data table--->
				<cfif variables.templateSettings.Incremental>
				<td>Incr</td>
				</cfif>
				<cfif variables.templateSettings.Shared>
				<td>Shared</td>
				</cfif>
				<cfif variables.templateSettings.Specd>
				<td>Spec'd</td>
				</cfif>
				<td>&nbsp;</td>
			</tr>
		<!--- THIS SECTION WILL DISPLAY IF THERE ARE ANY EXITING COMPETITOR INFORMATION START --->
		<cfif url.product_group_id NEQ 0 AND url.product_group_id NEQ 'Null' AND getExistingCompetitor.recordcount>
		
			<cfset existingCompCount = 1 />
			
			<cfloop query="getExistingCompetitor">
			
				<tr class="data" style="padding-top:5px;" id="entryRows">
					<td>
					<select name="Existing_Won" id="existingWon">
						<option value="1" <cfif getExistingCompetitor.Won EQ 1>selected</cfif>>won</option>
						<option value="0" <cfif getExistingCompetitor.Won EQ 0>selected</cfif>>lost</option>
						<option value="2" <cfif getExistingCompetitor.Won EQ 2>selected</cfif>>pending</option>
					</select>
					</td>
					<td width="300px">
						<select name="Existing_competitor_id" style="width:98%;" id="existingCompetitorId">
							<option value="0">select a competitor</option>
							<cfloop query="variables.competitors">
								<cfset ExistingCompetitorSelected = "">
								<cfif variables.competitors.Program_Bid_Won_By_Id EQ getExistingCompetitor.program_bid_won_by_id>
									<cfset ExistingCompetitorSelected="selected">
								</cfif>
							<option value="#variables.competitors.Program_Bid_Won_By_Id#" #ExistingCompetitorSelected#>
								#variables.competitors.Program_Bid_Won_By_Description#
							</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="Existing_competitor_rate" value="#getExistingCompetitor.won_price#" style="width:98%;">
					</td>
					<td width="100px">
						<select name="Existing_competitor_uom" class="uom" style="width:98%;">
							<option>select a uom</option>
							<option value="1"<cfif getExistingCompetitor.won_uom EQ 1>	Selected </cfif>>CS</option>
							<option value="2"<cfif getExistingCompetitor.won_uom EQ 2>	Selected </cfif>>LB</option>
						</select>
					</td>
					<cfif variables.templateSettings.Delivery_type>
					<td>
						<select name="Existing_competitor_delivery" style="width:98%;">
							<option value="">Select Delivery</option>
							<option value="1"<cfif getExistingCompetitor.won_delivery_type EQ 1>	Selected </cfif>>FOB</option>
							<option value="2"<cfif getExistingCompetitor.won_delivery_type EQ 2>	Selected </cfif>>DEL</option>
						</select>
					</td>
					</cfif>
					
					<!---Incremental--->
					<cfif variables.templateSettings.Incremental>
					<td>
						<select name="Existing_Incremental">
							<option value="0" <cfif getExistingCompetitor.Incremental EQ 0>selected</cfif>>No</option>
							<option value="1" <cfif getExistingCompetitor.Incremental EQ 1>selected</cfif>>Yes</option>
						</select>
						<!---
						<input name="Existing_Incremental_chbx_#existingCompCount#" class="chbx" type="checkbox" <cfif getExistingCompetitor.Incremental EQ 1>checked</cfif> />
						<input name="Existing_Incremental_#existingCompCount#" type="hidden" value="<cfif getExistingCompetitor.Incremental EQ 1>1<cfelse>0</cfif>">
						--->
					</td>
					</cfif>
					<!---Shared--->
					<cfif variables.templateSettings.Shared>
					<td>
						<select name="Existing_Shared">
							<option value="0" <cfif getExistingCompetitor.Shared EQ 0>selected</cfif>>No</option>
							<option value="1" <cfif getExistingCompetitor.Shared EQ 1>selected</cfif>>Yes</option>
						</select>
						<!---
						<input name="Existing_Shared_#existingCompCount#" type="checkbox" <cfif getExistingCompetitor.Shared EQ 1>checked</cfif> value="1">
						<input name="Existing_Shared_#existingCompCount#" type="hidden" value="<cfif getExistingCompetitor.Shared EQ 1>1<cfelse>0</cfif>">
						--->
					</td>
					</cfif>
					<!---Specd--->
					<cfif variables.templateSettings.Specd>
					<td>
						<select name="Existing_Specd">
							<option value="0" <cfif getExistingCompetitor.Specd EQ 0>selected</cfif>>No</option>
							<option value="1" <cfif getExistingCompetitor.Specd EQ 1>selected</cfif>>Yes</option>
						</select>
						<!---
						<input name="Existing_Specd_#existingCompCount#" type="checkbox" <cfif getExistingCompetitor.Specd EQ 1>checked</cfif> value="1">
						<input name="Existing_Specd_#existingCompCount#" type="hidden" value="<cfif getExistingCompetitor.Specd EQ 1>1<cfelse>0</cfif>">
						--->
					</td>
					</cfif>
					<td width="40px">
						<!---
						<cfif existingCompCount gt 1>
							<img class="data_remove" src="/images/scissor_blue.gif" border="0" />
						</cfif>
						--->
						<img class="data_remove" src="/images/scissor_blue.gif" border="0" />
					</td>
				</tr>
				<cfset existingCompCount = existingCompCount + 1 />
				<cfset variables.rowIndx = variables.rowIndx + 1 />
				
			</cfloop>
			
		</cfif>
		<!--- THIS SECTION WILL DISPLAY IF THERE ARE ANY EXITING COMPETITOR INFORMATION END --->
		<!--- THIS SECTION WILL DISPLAY DEFAULT CLONE ROW START --->
		<tr class="clone" style="padding-top:5px;" id="entryRows">
			<td>
			<select name="competitor_won" id="competitorWon">
				<option value="1">won</option>
				<option value="0">lost</option>
				<option value="2" selected>pending</option>
			</select>
			</td>
			<td width="300px">
				<select name="competitor_id" style="width:98%;" id="competitorId">
					<option value="0">select a competitor</option>
					<cfloop query="variables.competitors">
					<option value="#variables.competitors.Program_Bid_Won_By_Id#">
					#variables.competitors.Program_Bid_Won_By_Description#
					</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="text" name="competitor_rate" value="0" style="width:98%;" />
			</td>
			<td width="100px">
				<select name="competitor_uom" class="uom" style="width:98%;">
					<option value="0">select a uom</option>
					<option value="1" <cfif variables.defaultUOM eq 1>selected</cfif>>CS</option>
					<option value="2" <cfif variables.defaultUOM eq 2>selected</cfif>>LB</option>
				</select>
			</td>
			<cfif variables.templateSettings.Delivery_type>
			<td>
				<select name="competitor_delivery" style="width:98%;">
					<option value="0">Select Delivery</option>
					<option value="1">FOB</option>
					<option value="2">DEL</option>
				</select>
			</td>
			<cfelse>
				<input type="hidden" name="competitor_delivery" value="0" />
			</cfif>
			<!---Incremental--->
			<cfif variables.templateSettings.Incremental>
			<td>
				<select name="competitor_Incremental">
					<option value="0">No</option>
					<option value="1">Yes</option>
				</select>
				<!---
				<input name="competitor_Incremental_#variables.rowIndx#" type="hidden" value="0" />
				--->
			</td>
			<cfelse>
				<input name="competitor_Incremental" type="hidden" value="0" />
			</cfif>
			<!---Shared--->
			<cfif variables.templateSettings.Shared>
			<td>
				<select name="competitor_Shared">
					<option value="0">No</option>
					<option value="1">Yes</option>
				</select>
				<!---
				<input name="competitor_Shared_#variables.rowIndx#" type="hidden" value="0" />
				--->
			</td>
			<cfelse>
				<input name="competitor_Shared" type="hidden" value="0" />
			</cfif>
			<!---Specd--->
			<cfif variables.templateSettings.Specd>
			<td>
				<select name="competitor_Specd">
					<option value="0">No</option>
					<option value="1">Yes</option>
				</select>
				<!---
				<input name="competitor_Specd_#variables.rowIndx#" type="hidden" value="0" />
				--->
			</td>
			<cfelse>
				<input name="competitor_Specd" type="hidden" value="0" />
			</cfif>
			<td width="40px">
				<img class="clone_add" src="/images/plus4.gif" border="0">
				<img class="clone_remove" src="/images/scissor_blue.gif" border="0" style="display:none;">
			</td>
		</tr>
	</table>
	<!--- THIS SECTION WILL DISPLAY DEFAULT CLONE ROW END --->
	<br>
	<input type="hidden" name="contract_main_id" value="#url.contract_main_id#">
	<input name="competitorFields" type="hidden" id="competitorFields" value="#variables.rowIndx#">
	<input name="Existing_Incremental" type="hidden" value="">
	<input name="competitor_Incremental" type="hidden" value="">
	<input name="Existing_Shared" type="hidden" value="">
	<input name="competitor_Shared" type="hidden" value="">
	<input name="Existing_Specd" type="hidden" value="">
	<input name="competitor_Specd" type="hidden" value="">
	<input name="Existing_competitor_delivery" type="hidden" value="">
	<input name="Client_Bid_ID" type="hidden" value="#variables.nClientBidId#">
	<input type="submit" name="submit" value="Mass Apply" onclick="validate();return false;">
	</form>
	</cfoutput>

<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js?2014-06-06"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>

<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />

<script type="text/javascript">
var regex = /^(.*)(\d)+$/i;
var cindex = 1;

<cfif isDefined("getExistingCompetitor") and getExistingCompetitor.recordcount>
	$( "tr.data").first().addClass( "topRow" );
<cfelse>
	$( "tr.clone").first().addClass( "topRow" );
</cfif>

$("img.clone_add").live('click', function() {
    var $tr    = $(this).closest('.clone');
    var $clone = $tr.clone();
	var competitorFields = parseInt($( "#competitorFields" ).val()) + 1;
	$('#competitorFields').val(competitorFields);

	//alert($tr.html());
    cindex++;
    $clone.find(':text').val('');
	$clone.find("input[name='competitor_rate']").val("0");
	$clone.find("select[name='competitor_won']").val("2");
	$clone.find("select[name='competitor_uom']").val("<cfoutput>#variables.defaultUOM#</cfoutput>");
	//Incremental
	$clone.find("select[name='competitor_Incremental']").val("0");
	//Shared
	$clone.find("select[name='competitor_Shared']").val("0");
	//Specd
	$clone.find("select[name='competitor_Specd']").val("0");
    $clone.attr('id', 'entryRows' ); //update row id if required
    //update ids of elements in row
    $clone.find("*").each(function() {
            var id = this.id || "";
            var match = id.match(regex) || [];
            if (match.length == 3) {
                this.id = match[1] + (cindex);
				
            }	
    });
	/*
	//Incremental
	$clone.find("input[name*='competitor_Incremental_']").attr('name',  'competitor_Incremental_' + cindex);
	//Shared
	$clone.find("input[name*='competitor_Shared_']").attr('name',  'competitor_Shared_' + cindex);
	//Specd
	$clone.find("input[name*='competitor_Specd_']").attr('name',  'competitor_Specd_' + cindex);
	$clone.find("input[type='checkbox']").prop('checked', false);
	*/
	$clone.find(".clone_add").show();
	$clone.find(".clone_remove").hide();
	$clone.removeClass("topRow");
	
	$tr.find(".clone_add").hide();
	$tr.find(".clone_remove").show();
	
    $tr.after($clone);
	
});
$("img.clone_remove").live('click', function() {
		$(this).closest(".clone").remove();
		var competitorFields = parseInt($( "#competitorFields" ).val()) - 1;
		$('#competitorFields').val(competitorFields);
		$( "tr#entryRows").first().addClass( "topRow" );
});
$('select#productKind').change(function() {
    window.location = "competitive_data_mass_apply.cfm?contract_main_id=<cfoutput>#url.contract_main_id#</cfoutput>&Product_Group_ID=" + $(this).val();
});
$("img.data_remove").live('click', function() {
		$(this).closest(".data").remove();
		var competitorFields = parseInt($( "#competitorFields" ).val()) - 1;
		//we cant leave competitorFields equal to 0 so check first
		if (competitorFields > 0){
			$('#competitorFields').val(competitorFields);
		}
		$( "tr#entryRows").first().addClass( "topRow" );
});
/*
$("#Won").change(function() {
 if ($( this ).val() == 1) {
 	$(".ClientWonData").show();
 }
 else{
  	$(".ClientWonData").hide();
 }
 });
 */
 /*
$('table').on('click', 'tr input.chbx', function(e) {
	var $hiddenInput = $(e.target).next('input');
	var bIsChecked = $(e.target).prop('checked');
	
	if (bIsChecked){
		$hiddenInput.val(1);
	}
	else{
		$hiddenInput.val(0);
	}
});
*/
 $("#productKind").multiselect();

 function validate(){
 	var error = 0;
	var errormessage ='';

	if($("select#productKind").val() == null) {
	  	error++;
		errormessage = 'Please select a <cfoutput>#application.returned_customer_setting.Item_Label# #application.returned_customer_setting.type_code_label_singular#</cfoutput>.'
	  }

	if($("select#competitorWon").val() == "2" && $("select#competitorFields").val() == "1") {
	  	error++
		errormessage = errormessage.concat('Please select an option for Won')
	  }
	  
	  if(($("select#competitorWon").val() != "2" && $("select#competitorId").val() == "0") || ($("select#existingWon").val() != "2" && $("select#existingCompetitorId").val() == "")) {
	  	error++
		errormessage = errormessage.concat('Please select an option for Competitor')
	  }
	  
	  var errormessage = errormessage.replace('.','\n')
		if (error) {
			alert(errormessage)
		}
		else{
			$("#massupdate").submit();
		}
 }
 
</script>

</cfif>