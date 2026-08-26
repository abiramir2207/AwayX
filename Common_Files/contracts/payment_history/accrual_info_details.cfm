<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\accrual_info_details.cfm
      Date:     2016 Febriary
      Author:   Milan Mushran
      Purpose:  Accrual data details viewer
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Accrual detail data viewer</TITLE>

	
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	
	
	<style>
		<cfif plannerId eq 0>
			header {
				background-color: #FFE083;
				height:100px !important;
				margin-bottom:4px;
			}
		<cfelse>
			/* Use Planner color */
			header {
				background-color: #C4DCF1;
				height:100px !important;
				margin-bottom:4px;
			}
		</cfif>

		#hdr1 { 
			display: flex;
			margin-left:10px; 
			padding-top: 5px;
			width: 80%;
		}

		section:not(:last-child) {
			margin-right: 80px;
		}

		#sectionDollars {
			margin-left: 40px;
		}

		/* Progress bar layout */
		#dollarsProgress,
		#daysProgress  {
			margin-bottom: 7px;
			width:150px;
		}

		.val-right {
			float: right;
			padding-right: 30px;
		}

		section:not(:last-child) {
			margin-right: 80px;
		}

		#sectionDollars {
			margin-left: 40px;
		}

		/* Progress bar layout */
		#dollarsProgress,
		#daysProgress  {
			margin-bottom: 7px;
			width:150px;
		}

		.val-right {
			float: right;
			padding-right: 30px;
		}


		table.datagrid { font-size: 1.05em; width: 100%; }
		thead th { text-align:left !important;}		
        table.datagrid td {
            word-break: break-all;
        }
		div.export {float:right;}
		div.otherSearch {float:right;}
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		.drpDownWidth{width:auto}

		table.dataTable thead th{ font-weight: normal; font-family: "Arial";<cfif plannerId neq 0>background-color:#9BC2E6</cfif>}	

	</style>

	<cf_include files="/script/javascript/progress-bar/progress-bar.css, /script/javascript/progress-bar/progress-bar.js">
		
	<style>
		/* NOTE: The progress-bar override styles must be defined AFTER the progress-bar.css, to take priority */
		.dollars {
			background-color: #228b22;
		}
		.days {
			/* background-color: #3498db; */
			background-color: #2079b4;
		}
		.dollars-gone {
			background-color: #CCCCCC
		}
	</style>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>

<script>
	function viewContract(program_id)
	{
	NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id, 'ViewProgram','800','600','Yes', 'Yes');
	}
</script>
</HEAD>

<cfparam name="form.distributorComponentList" default="">
<cfparam name="form.Product_Group_Level_ID" default="0">
<cfparam name="form.plannerId" default="0">
<cfparam name="form.filter_ProductAttribute" default="">
<cfparam name="form.filter_item" default="">
<cfparam name="form.filter_itemDescription" default="">


<cf_cryp type="en" string ="#ContractId#" key="#request.key#">

<cfset EncContractID = cryp.value>
	<cfset Business_Segments_On = 0 />
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfif businessSegManager.isEnabled()>
		<cfset Business_Segments_On = 1 />
	</cfif>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfset appSettings = application.appsettingsGet />
<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset getdateInfo = PaymentHistoryManager.getdateInfo(contractNumber, ContractId, plannerID)>
<cfset getTotalAccruedAndSpentDollars = PaymentHistoryManager.getTotalAccruedAndSpentDollars(contractNumber, ContractId, plannerID)>

<!--- DAYS --->
<cfset TotalDays = getdateInfo.TotalDays>
<cfset DaysElapsed = getdateInfo.DaysElapsed>
<cfset DaysRemaining = getdateInfo.DaysRemaining>
<cfset DaysReminingPercent = getdateInfo.DaysReminingPercent>

<!--- DOLLARS --->
<cfset TotalAccruedDollars =  getTotalAccruedAndSpentDollars.Total_Accrued_Dollars>
<cfset TotalSpentDollars =  getTotalAccruedAndSpentDollars.Total_Spent_Dollars>
<cfset TotalRemainingDollars =  getTotalAccruedAndSpentDollars.Total_Remaining_Dollars>
<cfset TotalRemainingPercent =  getTotalAccruedAndSpentDollars.Total_Remaining_Percent>

<cfif Business_Segments_On eq 1 and plannerId eq 0>
	<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(contractId) />
	<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
</cfif>

<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />

<cfset getDeductionAccountExist = PaymentHistoryManager.getDeductionAccountExist(contractNumber, ContractId, plannerId)>
<cfset getPaymentAccountExist = PaymentHistoryManager.getPaymentAccountExist(contractNumber, ContractId, plannerId)>
<cfset getGLAccountExist = PaymentHistoryManager.getGLAccountExist(contractNumber, ContractId, plannerId)>
<cfset qAllProductAttributes = ProductGroupAttributeManager.getProductGroupAttributes(active=1,includePG=0)>
<cfset qGetProductAttribute = PaymentHistoryManager.getProductGroupLevelForAccrual()>
<cfset form.Product_Group_Level_ID = qGetProductAttribute.Product_Group_Level_ID>

<BODY>
<cfoutput>
<header>		
	<div id="hdr1">	
		<cfif plannerId eq 0>
		<section style="margin-top: 4px;">

			<a href='##' onClick="viewContract('#EncContractID#')">#getcontractInfo.Contract_Number#</a>
			&nbsp;&nbsp;#getcontractInfo.contract_title#<br/>
			<b>Template:</b>&nbsp;&nbsp;#getcontractInfo.created_type#<br/>
			<b>RSP:</b>&nbsp;&nbsp;#getcontractInfo.RSP#<br/>
			<b>Delivery Period</b>:&nbsp;&nbsp;#Dateformat(getdateInfo.start_date,"mm/dd/yyyy")# - #Dateformat(getdateInfo.end_date,"mm/dd/yyyy")#<br/>
			<b>Approved Date:</b>&nbsp;&nbsp;#getcontractInfo.Approval_Date#<br/>
			<cfif Business_Segments_On eq 1 and plannerId eq 0>
			<b>Segment:</b>&nbsp;&nbsp;#qGetThisBusSegment.Business_Unit_Desc#<br/>
			</cfif>
			<cfif appSettings.getReleaseSettlement()>
				<cfif getcontractInfo.Released eq 1>
				<b>Released Date:</b>&nbsp;&nbsp;#getcontractInfo.ReleasedBy#<br/>
				<b>Released By:</b>&nbsp;&nbsp;#getcontractInfo.Released_Date#
				</cfif>
			</cfif>		
		</section>
		</cfif>
		<section id="sectionDollars">
			<div style="line-height:1.6em; text-align:center">Dollars Remaining:</div>
			<div id="dollarsProgress"></div>	<!--- Progress bar --->

			<!--- Values set via ids --->
			<div>Accrued:
				<span id="Accrued_Amt" class="val-right"></span>
			</div>
			<div>Spent:
				<span id="Spent_Amt" class="val-right"></span>
			</div>
			<div>Remaining:
				<span id="Remaining_Amt" class="val-right"></span>
			</div>
		</section>

		<section id="sectionDays">
			<div style="line-height:1.6em; text-align:center">Days Remaining:</div>
			<div id="daysProgress" style="width:150px;"></div>	<!--- Progress bar --->

			<!--- Values set via ids --->
			<div>Total Days:
				<span id="Days_Num" class="val-right"></span>
			</div>
			<div>Elapsed:
				<span span id="Days_Elapsed_Num" class="val-right"></span>
			</div>
			<div>Remaining:
				<span id="Days_Remaining_Num" class="val-right"></span>
			</div>
		</section>	
	</div>
</header>

<cfset missingColumns = 0 />
<cfset sortCol = 6 /> <!--- Default sort by Accrual $--->
<cfif plannerId neq 0>
	<cfset sortCol = sortCol + 1 />
</cfif>
<cfif getDeductionAccountExist eq 0>
	<cfset missingColumns = missingColumns + 1 />
	<cfset sortCol = sortCol + 1 />
</cfif>
<cfif getPaymentAccountExist eq 0>
	<cfset missingColumns = missingColumns + 1 />
	<cfset sortCol = sortCol + 1 />
</cfif>
<cfif getGLAccountExist eq 0>
	<cfset missingColumns = missingColumns + 1 />
	<cfset sortCol = sortCol + 1 />
</cfif>

	
<table id="datagridAccrual" class="datagrid" style="table-layout:fixed;">
  <cfif plannerId neq 0>
	<col width="10%">  <!--- Program --->
  </cfif>
  <col width="#Evaluate("10+(#missingColumns#*1)")#%">  <!--- Product --->
  <col width="#Evaluate("18+(#missingColumns#*2)")#%">  <!--- Product Desc --->
 <cfif getDeductionAccountExist eq 1>
  <col width="10%">  <!--- Deduction Account --->
 </cfif>
 <cfif getPaymentAccountExist eq 1>
  <col width="10%">  <!--- Payment Account --->
 </cfif>
 <cfif getGLAccountExist eq 1>
  <col width="8%">  <!--- GL Account --->
 </cfif>
  <col width="8%">  <!--- Component ID --->
  <col width="12%">  <!--- Component --->
  <col width="4%"> 
  <col width="7%">  
  <col width="4%"> 
  <thead>
  <tr>
	<cfif plannerId neq 0>
		<th>Program</th>
	</cfif>
	<th>#application.returned_customer_setting.item_label#</th>
	<th>#application.returned_customer_setting.item_label# Desc</th>
	<cfif getDeductionAccountExist eq 1>
	<th>Ded Acct</th>
	</cfif>
	<cfif getPaymentAccountExist eq 1>
	<th>Pymt Acct</th>
	</cfif>
	<cfif getGLAccountExist eq 1>
	<th>GL Acct</th>
	</cfif>
	<th>Comp ID</th>
	<th>Component</th>
	<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Accrual $&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Rate&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Rate UOM</th>
  </tr>
  <!--- column filters --->
  <tr id="filter">
	<cfif plannerId neq 0>
		<th class="csvExclude">
			<select name="filter_ContractNumber" class="drpDownWidth"></select>
		</th>
	</cfif>
	<th>
		<select name="filter_item" class="drpDownWidth"></select>
	</th>
	<th>
		<select name="filter_itemDescription" class="drpDownWidth"></select>
	</th>
	<cfif getDeductionAccountExist eq 1>
	<th class="csvExclude">
		<select name="filter_deductionAccount" class="drpDownWidth">
		</select>
	</th>
	</cfif>
	<cfif getPaymentAccountExist eq 1>
	<th class="csvExclude">
		<select name="filter_paymentAccount" class="drpDownWidth"></select>
	</th>
	</cfif>
	<cfif getGLAccountExist eq 1>
	<th class="csvExclude">
		<select name="filter_GL_Account" class="drpDownWidth"></select>
	</th>
	</cfif>
	<th class="csvExclude">
		<select name="filter_externalID" class="drpDownWidth"></select>
	</th>
	<th class="csvExclude">
		<select name="filter_componentName" class="drpDownWidth"></select>
	</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th class="csvExclude right">
		<select name="filter_rateUOM" class="drpDownWidth"></select>
	</th>
  </tr>
  </thead>
  <tbody>
  </tbody>
  <tfoot>
    <tr>
		 <cfif plannerId neq 0>
            <th>&nbsp;</th>
        </cfif>
        <th>&nbsp;</th>
        <th>&nbsp;</th>
        <cfif getDeductionAccountExist eq 1>
            <th>&nbsp;</th>
        </cfif>
        <cfif getPaymentAccountExist eq 1>
            <th>&nbsp;</th>
        </cfif>
        <cfif getGLAccountExist eq 1>
            <th>&nbsp;</th>
        </cfif>
        <th>&nbsp;</th>
        <th>&nbsp;</th>
        <th id="totalCases">&nbsp;</th>
        <th id="totalAmount">&nbsp;</th>
        <th id="totalRate">&nbsp;</th>
		<th>&nbsp;</th>
    </tr>
  </tfoot>
</table>
</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in 
"jquery.dataTables-api.js" below and so we need to define it here. 
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 60;
	var mydatagrid = '';
</script>

<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<script>
var jTable = $(".datagrid");
var firstTime = 1;
mydatagrid = jTable.dataTable({
	aaSorting: [ [<cfoutput>#sortCol#</cfoutput>, 'desc'] ]
	,"aoColumns": [
				<cfif plannerId neq 0>
				{ "bSortable": true},
				</cfif>
				,{ "bSortable": true } 
				,{ "bSortable": true }
				<cfif getDeductionAccountExist eq 1>
				,{ "bSortable": false} 
				</cfif>
				<cfif getPaymentAccountExist eq 1>
				,{ "bSortable": false} 
				</cfif>
				<cfif getGLAccountExist eq 1>
				,{ "bSortable": false} 
				</cfif>
				,{ "bSortable": false}
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" } 
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" } 
				,{ "bSortable": true, "sClass" : "right","sType":"dollar" } 
				,{ "bSortable": false, "sClass" : "right"} 
				]
	,"bAutoWidth": false
	,"bProcessing": true
	,"bServerSide": true
	,"bSortClasses": false
	,"bScrollCollapse": true	/* true to put the footer of the grid just below the records, when there are a few records only */
	,"iDisplayLength": 100
	/* Keep the The "sort" option is at the top, next to column header. (When we have column filters, the sort options can sometimes 
	go to the line, where we have filters) */
	,"bSortCellsTop": true
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sAjaxSource": "/Common_Files/contracts/ajax/accrual_info_details_data.cfm"
	,"sDom": 'fp<"export"><"otherSearch"><"prodAttribute">tir'
	,"sServerMethod": "POST"
	<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
	IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
	THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
	--->
	<cfif plannerId eq 0>
	,"sScrollY" : Math.floor(jQuery(window).height()) - 240
	<cfelse>
	,"sScrollY" : Math.floor(jQuery(window).height()) - 400
	</cfif>
	,"fnServerParams": function ( aoData ) {	
		 <cfoutput>
		aoData.push( { "name": "contractNumber", "value": '#contractNumber#' } );
		aoData.push( { "name": "contractId", "value": '#contractId#' } );
		aoData.push( { "name": "distributorComponentList", "value": '#form.distributorComponentList#' } );
		<!--- Dev Note (76039)-When data gets loaded for the first time, get the value from the settings panel.--->
		if(firstTime){
			aoData.push( { "name": "Product_Group_Level_ID", "value": '#form.Product_Group_Level_ID#' } );
		}
		else{
			aoData.push( { "name": "Product_Group_Level_ID", "value": $('select[name=Product_Group_Level_ID]').val() } );
		}
		if(firstTime){
			aoData.push( { "name": "filter_ProductAttribute", "value": '#form.filter_ProductAttribute#' } );
		}
		else{
			aoData.push( { "name": "filter_ProductAttribute", "value": $('select[name=filter_ProductAttribute]').val() } );
		}
		aoData.push( { "name": "plannerId", "value": '#plannerId#' } );
		
		if(firstTime){
			aoData.push( { "name": "filter_item", "value": '#form.filter_item#' } );
		}
		else{
			aoData.push( { "name": "filter_item", "value": $('select[name=filter_item]').val() } );
		}
		if(firstTime){
			aoData.push( { "name": "filter_itemDescription", "value": '#form.filter_itemDescription#' } );
		}
		else{
			aoData.push( { "name": "filter_itemDescription", "value": $('select[name=filter_itemDescription]').val() } );
		}
		firstTime = 0;
		 </cfoutput>
		}
	/* THIS TECHNIQUE OF TOTALLING IS USED WHEN WE THE DATA CALL IS AN AJAX CALL */
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
									$tfoot.find('#totalCases').text(numeral(json.TOTALCASESINVOICED).format( "0,0" ) );
									$tfoot.find('#totalAmount').text(numeral(json.TOTALAMOUNT).format( "($0,0.00)" ) );
									$tfoot.find('#totalRate').text(numeral(json.TOTALRATE).format( "($0,0.00)" ) );
									
									/* POPULATE THE FILTER DROPDOWNS */
									/* UOM */
									var selectedRateUOM = $('select[name=filter_rateUOM]').val();
								
									$('select[name=filter_rateUOM]').empty();
									$('select[name=filter_rateUOM]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLUOM.length; i++) {														
											$('select[name=filter_rateUOM]').append('<option value="'+json.ALLUOM[i]+'">'+json.ALLUOM[i]+'</option>');
									}

									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_rateUOM]').val(selectedRateUOM);
									
									/* Deduction Acct */
									<cfif getDeductionAccountExist eq 1>
									var selectedDeductionAccount = $('select[name=filter_deductionAccount]').val();

									$('select[name=filter_deductionAccount]').empty();
									$('select[name=filter_deductionAccount]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLDEDUCTIONACCOUNT.length; i++) {
											$('select[name=filter_deductionAccount]').append('<option value="'+json.ALLDEDUCTIONACCOUNT[i]+'">'+json.ALLDEDUCTIONACCOUNT[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_deductionAccount]').val(selectedDeductionAccount);
									</cfif>
									
									/* Payment Acct */
									<cfif getPaymentAccountExist eq 1>
									var selectedPaymentAccount = $('select[name=filter_paymentAccount]').val();

									$('select[name=filter_paymentAccount]').empty();
									$('select[name=filter_paymentAccount]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLPAYMENTACCOUNT.length; i++) {
											$('select[name=filter_paymentAccount]').append('<option value="'+json.ALLPAYMENTACCOUNT[i]+'">'+json.ALLPAYMENTACCOUNT[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_paymentAccount]').val(selectedPaymentAccount);
									</cfif>
									
									/* GL Account */
									<cfif getGLAccountExist eq 1>
									var selectedGLAccount = $('select[name=filter_GL_Account]').val();

									$('select[name=filter_GL_Account]').empty();
									$('select[name=filter_GL_Account]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLGLACCOUNT.length; i++) {
											$('select[name=filter_GL_Account]').append('<option value="'+json.ALLGLACCOUNT[i]+'">'+json.ALLGLACCOUNT[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_GL_Account]').val(selectedGLAccount);
									</cfif>
									
									/* External ID */
									var selectedExternalID = $('select[name=filter_externalID]').val();	
									
									$('select[name=filter_externalID]').empty();
									$('select[name=filter_externalID]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLEXTERNALID.length; i++) {
											$('select[name=filter_externalID]').append('<option value="'+json.ALLEXTERNALID[i]+'">'+json.ALLEXTERNALID[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_externalID]').val(selectedExternalID);
									
									/* Component Name */
									var selectedComponentName = $('select[name=filter_componentName]').val();
									
									$('select[name=filter_componentName]').empty();
									$('select[name=filter_componentName]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLCOMPONENTNAME.length; i++) {
											$('select[name=filter_componentName]').append('<option value="'+json.ALLCOMPONENTNAME[i]+'">'+json.ALLCOMPONENTNAME[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_componentName]').val(selectedComponentName);
									
									
									/* Product Attribute(selected) */
									var selectedProductAttribute = $('select[name=filter_ProductAttribute]').val();

									$('select[name=filter_ProductAttribute]').empty();
									$('select[name=filter_ProductAttribute]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLPRODUCTATTRIBUTES.length; i++) {
											$('select[name=filter_ProductAttribute]').append('<option value="'+json.ALLPRODUCTATTRIBUTES[i]+'">'+json.ALLPRODUCTATTRIBUTES[i]+'</option>');
									}
								
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_ProductAttribute]').val(selectedProductAttribute);

									/* Product Attribute header should get the appropriate header name, e.g. size, category etc. */
									$("#selectedProdAttribute").html($('select[name=Product_Group_Level_ID] option:selected').text());
									
	
									/* Contract Number */
									<cfif plannerId neq 0>
										var selectedContractNumber = $('select[name=filter_ContractNumber]').val();

										$('select[name=filter_ContractNumber]').empty();
										$('select[name=filter_ContractNumber]').append('<option value="">All</option>');
										for(var i = 0; i <json.ALLCONTRACTNUMBER.length; i++) {
												$('select[name=filter_ContractNumber]').append('<option value="'+json.ALLCONTRACTNUMBER[i]+'">'+json.ALLCONTRACTNUMBER[i]+'</option>');
										}
										/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
										$('select[name=filter_ContractNumber]').val(selectedContractNumber);
									</cfif>

									/* Item */
									var selectedItem = $('select[name=filter_item]').val();

									$('select[name=filter_item]').empty();
									$('select[name=filter_item]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLITEM.length; i++) {
											$('select[name=filter_item]').append('<option value="'+json.ALLITEM[i]+'">'+json.ALLITEM[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_item]').val(selectedItem);

									/* Item Description */
									var selectedItemDescription = $('select[name=filter_itemDescription]').val();

									$('select[name=filter_itemDescription]').empty();
									$('select[name=filter_itemDescription]').append('<option value="">All</option>');
									for(var i = 0; i <json.ALLITEMDESCRIPTIOM.length; i++) {
											$('select[name=filter_itemDescription]').append('<option value="'+json.ALLITEMDESCRIPTIOM[i]+'">'+json.ALLITEMDESCRIPTIOM[i]+'</option>');
									}
									/* The filter option (if filtered) should be selected. The dropdown should not show "ALL". */
									$('select[name=filter_itemDescription]').val(selectedItemDescription);

							fnCallback(json); }
		 } );
		}
	}).fnSetFilteringDelay(); 

	$(window).resize(function(){
		jTable.fnAdjustColumnSizing();
  	});

	
	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that 
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	//$('.dataTables_scrollBody').css('min-height', '69px');
	//$('.dataTables_scrollBody').css('min-height', $('.dataTables_scrollBody').css('height'));
	//$('.dataTables_scrollBody').css('min-height', ($('.dataTables_scrollBody').height()));
	$('.dataTables_scrollBody').css('min-height', '30px');

	
	/*
	var rows= $("#datagridAccrual tbody tr");
	console.log(rows);
	*/
	
/* set up column filter */
$("#filter th").each( function ( i ) {
    $('select', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });

	$('input', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });
});

/* Normally the "exportAll" function passes data through the URL, but below function passes data through the form instead of the URL, 
as the data passed to the URL may sometimes exceed the limit. */
exportAll = function() {
	frmExportAll.selectedProductAttribute.value = $('select[name=Product_Group_Level_ID] option:selected').val();
	frmExportAll.selectedProductAttributeText.value = $('select[name=Product_Group_Level_ID] option:selected').text();
	frmExportAll.submit();
}
<cfoutput>
$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a> &nbsp;");
$('div.otherSearch').html("<a href='javascript:show_loader();frmDetailSearchCriteria.submit();'>#application.util.string.actionLinkFormat2('view by program')#</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
$('div.prodAttribute').html("&nbsp;&nbsp;<select name='Product_Group_Level_ID' onChange='mydatagrid.fnFilterClear();mydatagrid.fnReloadAjax();'><cfloop query='qAllProductAttributes'><option value='#qAllProductAttributes.Product_Group_Level_ID#' #(form.Product_Group_Level_ID eq qAllProductAttributes.Product_Group_Level_ID ? 'selected' : '')#>#qAllProductAttributes.Group_Level_Desc#</option></cfloop></select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<select name='filter_ProductAttribute' onChange='mydatagrid.fnFilterClear();mydatagrid.fnReloadAjax();'></select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='javascript:void(0)' onClick=resetData();>#application.util.string.actionLinkFormat2('reset')#</a>");
</cfoutput>


/* HEADER CODE (START) */
var TotalDays = <cfoutput>#TotalDays#</cfoutput>
var DaysElapsed = <cfoutput>#DaysElapsed#</cfoutput>
var DaysRemaining = <cfoutput>#DaysRemaining#</cfoutput>
var TotalAccruedDollars =  <cfoutput>#TotalAccruedDollars#</cfoutput>
var TotalSpentDollars =  <cfoutput>#TotalSpentDollars#</cfoutput>
var TotalRemainingDollars =  <cfoutput>#TotalRemainingDollars#</cfoutput>
var TotalRemainingPercent =  <cfoutput>#TotalRemainingPercent#</cfoutput>
var DaysReminingPercent = <cfoutput>#DaysReminingPercent#</cfoutput>

if(DaysRemaining < 0){
	DaysRemaining = 0;
}

$('#Accrued_Amt').text( numeral(TotalAccruedDollars).format( "($0,0.00)" ) );
$('#Spent_Amt').text( numeral(TotalSpentDollars).format( "($0,0.00)" ) );
$('#Remaining_Amt').text( numeral(TotalRemainingDollars).format( "($0,0.00)" ) );

$('#Days_Num').text( numeral(TotalDays).format( "(0,0)" ) );
$('#Days_Elapsed_Num').text( numeral(DaysElapsed).format( "(0,0)" ) );
$('#Days_Remaining_Num').text( numeral(DaysRemaining).format( "(0,0)" ) );



var total_remaining_percent = numeral(TotalRemainingPercent).format('0.00');
	total_remaining_percent_text = total_remaining_percent + '%'
	/* If "total_remaining_percent" is a negative number, then the progress bar should show 100% color, but the text should should display 0% */
	if(total_remaining_percent < 0){
		total_remaining_percent = Math.abs(total_remaining_percent);
		total_remaining_percent_text = '(' + numeral(total_remaining_percent) + '%)';
		$('#Remaining_Amt').addClass("neg");
	}

var days_remaining_percent = DaysReminingPercent;
	days_remaining_percent_text = days_remaining_percent + '%'
	/* If "days_remaining_percent" is a negative number, then the progress bar should show 100% color, but the text should should display 0% */
	if(days_remaining_percent < 0){
		days_remaining_percent = 100;
		days_remaining_percent_text = '0%';
	}


var paramsDollars = {id: "dollarsProgress", barStyle: "dollars", bIndicate: true};
var paramsDays = {id: "daysProgress", barStyle: "days", bIndicate: true};
var dollarsProgress, daysProgress;

jQuery(document).ready(function($) {

	// If no remaining dollars, show progress in red
	if(TotalRemainingDollars < 0) {
		paramsDollars.barStyle = "dollars-gone";
	}
	// Setup progress bars
	dollarsProgress = progressBar(paramsDollars);
	daysProgress = progressBar(paramsDays);

	// Set percentage value to show
	dollarsProgress.set(total_remaining_percent, total_remaining_percent_text);
	daysProgress.set(days_remaining_percent, days_remaining_percent_text);

	//$('.dataTables_scrollBody').css('min-height', $('.dataTables_scrollBody').height);
	$('#datagridAccrual_filter').attr('title', 'Keyword search on any of the fields: <cfoutput>#application.returned_customer_setting.item_label#, #application.returned_customer_setting.item_label# Desc</cfoutput>');

});
/* HEADER CODE (END) */

function resetData()
{
	$('select[name=Product_Group_Level_ID]').val(8);
	$('select[name=filter_ProductAttribute]').val('');
	$('select').val('');
	mydatagrid.fnFilterClear();mydatagrid.fnReloadAjax();
}

</script>

<cfoutput>
<!---Param mode to handle for posting back to planner_accruals.cfm --->
<cfparam name="form.mode" default="">
<cfparam name="form.accrualDisplay" default="">

<form name="frmExportAll" action="/Common_Files/exportAll.cfm" method="post" target="export_frame">
	<input type="hidden" name="type" value="getProgramAccrualDistributorItemData">
	<input type="hidden" name="contract_number" value="#ContractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<input type="hidden" name="distributorComponentList" value="#form.distributorComponentList#">
	<input type="hidden" name="selectedProductAttribute" value="">
	<input type="hidden" name="selectedProductAttributeText" value="">
	<input type="hidden" name="friendlyFileName" value="#urlEncodedFormat('AccrualByDistributorItems_#contractNumber#_')#">	
	<input type="hidden" name="plannerId" value="#form.plannerId#">
</form>

<!---Param frmDetailSearchCriteria action--->
<cfparam name="frmDetailSearchCriteria" default="/Common_Files/contracts/payment_history/program_accrual.cfm">

<!---If we're viewing within planner then set frmAccrualProductsAction action to planner_accruals.cfm--->
<cfif plannerId neq 0>
	<cfset frmDetailSearchCriteria = "/Planners/Create/planner_accruals.cfm" />
	<cfset form.accrualDisplay = "/Common_Files/contracts/payment_history/program_accrual.cfm" />
</cfif>

<!--- These form values are exclusively used to pass values the from values to a popup page.
These form values (filters) are needed.
--->
<form name="frmDetailSearchCriteria" action="#frmDetailSearchCriteria#" method="post">
	<input type="hidden" name="contractNumber" value="#ContractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<input type="hidden" name="distributorComponentList" value="#form.distributorComponentList#">
	<input type="hidden" name="plannerId" value="#form.plannerId#">
	<input type="hidden" name="mode" value="#form.mode#">
	<input type="hidden" name="accrualDisplay" value="#form.accrualDisplay#">
</form>
</cfoutput>

<iframe name="export_frame" style="opacity:0;height:0px"></iframe>
</BODY>
</HTML>