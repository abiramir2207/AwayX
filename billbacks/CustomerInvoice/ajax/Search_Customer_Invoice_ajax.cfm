<!---- 
 	Name: Search_Customer_Invoice_ajax.cfm          
 	Copyright (c) 2016 Blacksmith Applications, Inc.        
 ---->	
 
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

  <cfsilent>
    <cfparam name="url.iDisplayStart"   	default="0">
    <cfparam name="url.iDisplayLength"  default="100">
    <cfparam name="url.sEcho"           		default="10">
	<cfparam name="url.iSortCol_0"			default="">
	<cfparam name="url.sSortDir_0"			default="">
  <cfscript>
      tmp   = structnew();
      reply = structnew();
      tmp.page_size   = val(url.iDisplayLength);
      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>  

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
	<cfparam name="form.up" 											default="0"/>
	<cfparam name="form.pnf" 											default="0"/>
	<cfparam name="form.generic_type" 							default="0"/>
	<cfparam name="form.status" 										default="0"/>
	<cfparam name="form.programs" 									default="0"/>
	<cfparam name="form.payee_filter" 								default="broker"/>
	<cfparam name="form.broker_id" 									default="0"/>
	<cfparam name="form.distributor_name" 						default=""/>
	<cfparam name="form.distributor_bill_to_id" 				default=""/>
	<cfparam name="form.distributor_id" 							default=""/>
	<cfparam name="form.operator_name" 						default=""/>
	<cfparam name="form.billback_number" 						default=""/>
	<cfparam name="form.payable_number" 						default=""/>
	<cfparam name="form.amount_operator" 					default=""/>
	<cfparam name="form.amount" 									default=""/>
	<cfparam name="form.date_operator" 							default=""/>
	<cfparam name="form.bb_date_type" 							default=""/>
	<cfparam name="form.bb_date" 									default=""/>
	<cfparam name="form.start_date_operator" 				default=""/>
	<cfparam name="form.start_date" 								default=""/>
	<cfparam name="form.billback_title" 							default=""/>
	<cfparam name="form.end_date_operator" 					default=""/>
	<cfparam name="form.end_date" 									default=""/>
	<cfparam name="form.bb_aging" 									default=0/>
	<cfparam name="form.contract_number" 					default=""/>
	<cfparam name="form.alreadyselected" 						default=""/>
	<cfparam name="form.pp_user_id" 								default=""/>
	<cfparam name="form.user_position_operator" 			default="="/>
	<cfparam name="form.bb_closing_method" 				default=""/>
	<cfparam name="form.include_eligible_programs" 		default=""/>
	<cfparam name="form.deviated" 									default="0"/>
	<cfparam name="form.referencenum" 							default="" />
	<cfparam name="form.user_position" 							default="" />
	<cfparam name="form.user_position_of" 						default="" />
	<cfparam name="form.program_status" 						default="" />
	<cfparam name="form.matchcentral" 							default="false" />
	<cfparam name="form.source" 										default="" />
	<cfparam name="form.mc_shr_ship_to" 						default="" />
	<cfparam name="form.mc_distributor_name" 				default="" />
	<cfparam name="form.mc_bill_to_name" 					default="" />
	<cfparam name="form.mc_shr_bill_to" 							default="" />
	<cfparam name="form.check_number" 						default="">
	<cfparam name="form.soldtono" 									default="" />
	<cfparam name="form.operatorid" 								default="" />
	<cfparam name="form.vendorid" 									default="" />
	<cfparam name="form.title" 											default=""/>
	<cfparam name="form.showincompletebillbacks" 		default="0"/>
	<cfparam name="form.uploaded_billback" 					default="0"/>
	<cfparam name="form.search_filter_analyst_user_id" 	default="" />
	<cfparam name="url.type_search" 									default=""/>
	<cfparam name="ExcludeLockedBillbacks" 					default="0">	
	<cfparam name="HideAllSplitBB" 									default="false" />
    <cfparam name="form.sort_by" 										default="BBI">
    <cfparam name="form.sort_order" 								default="asc">
	<cfparam name="form.sql_sort_by" 								default="Billback.BB_Code"/>
	
	<cfinclude template="/get_access_profile.cfm">
	<cfinclude template="/billbacks/Billback_Access_Permission.cfm" >
	<cfset businessSegmentsOn = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").isEnabled() />
	<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	<cfset invoiceSearch = 1>

	<cfset start = url.iDisplaystart>
	<cfset end 	= url.iDisplaystart + 100>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>
	<cfset form.startrow = start>
	<cfset form.endrow = end>
	<cfset form.iSortCol_0 = url.iSortCol_0>
	<cfset form.sSortDir_0 = url.sSortDir_0>
	
	<cfscript>
		request.stSearch = structNew();
		// 1 variables
		structAppend(request.stSearch,variables,true);
		// 2 form
		structAppend(request.stSearch,form,true);
		// 3 specific variables var
		structInsert(request.stSearch,'appsettings',variables.appSettings,true);	
		//application.oController.getObject("components.Billback.BillbackSearch").init();
	</cfscript>
 
  <cfset variables.reply.aaData = [] >
    
-	<cfif url.searchClick AND (len(url.iSortCol_0) EQ 0 AND len(url.sSortDir_0) EQ 0) AND end EQ 100>
		<cfinvoke
			component="components.Billback.BillbackSearch"
			method="searchBillbacks"
			argumentcollection="#request.stSearch#"
			returnvariable="variables.qBillbackSearchResults">
	<cfelse>
		<cfinvoke
			component="components.Billback.BillbackSearch"
			method="finalBillbacklist"
			argumentcollection="#request.stSearch#"
			returnvariable="variables.qBillbackSearchResults">				
	</cfif>

    <cfset reply.iTotalDisplayRecords    = #variables.qBillbackSearchResults.record_count#>
    <cfset reply.iTotalRecords = #variables.qBillbackSearchResults.record_count#>

    <!--- Generate JSON from Query --->
    <cfset tmp.dArray = ArrayNew(1) >
    <cfloop query="variables.qBillbackSearchResults">	  	  
		 <cfscript>
	       dArrayTmp = [];
	       arrayAppend(dArrayTmp, '<a href="##" onclick="listofbb(''#variables.qBillbackSearchResults.BB_Reference#'', #variables.qBillbackSearchResults.Upload_ID# )" style="cursor:pointer;">#variables.qBillbackSearchResults.BB_Reference#</a>' );
	       arrayAppend(dArrayTmp, dateformat(variables.qBillbackSearchResults.BB_Start_Date,'mm/dd/yyyy'));
	       arrayAppend(dArrayTmp, dateformat(variables.qBillbackSearchResults.BB_End_Date,'mm/dd/yyyy'));
	       arrayAppend(dArrayTmp, variables.qBillbackSearchResults.Total_Claims);
	       arrayAppend(dArrayTmp, variables.qBillbackSearchResults.Payee_Name);
	       arrayAppend(dArrayTmp, dollarformat(variables.qBillbackSearchResults.Claimed));
	       arrayAppend(dArrayTmp, dollarformat(variables.qBillbackSearchResults.Expected));
	       arrayAppend(dArrayTmp, dollarformat(variables.qBillbackSearchResults.Paid));
	       arrayAppend(dArrayTmp, dollarformat(variables.qBillbackSearchResults.Deviated));      
	       arrayAppend(variables.reply.aaData, dArrayTmp);
	    </cfscript>
	    <cfset ArrayAppend(tmp.dArray, dArrayTmp) >
    </cfloop>

    <cfset reply.aaData = tmp.dArray>
    <cfset reply.sEcho  = javacast('int', url.sEcho)>
    <cfset tmp.sOut = SerializeJSON( reply )>
    <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
    <cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData')>
  </cfsilent>

  <!---send JSON data back to client--->
  <cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective> 