<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\ajax\billback_details.cfm
      Date:     2016 February
      Author:   Milan Mushran
      Purpose:  AJAX processing for loading and searching billbacks
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="form.iDisplayStart"		default="0">
<cfparam name="form.iDisplayLength"	default="100">
<cfparam name="form.sEcho"			default="10">
<cfparam name="form.iSortCol_0"		default="0">
<cfparam name="form.SSORTDIR_0"		default="asc">
<cfparam name="form.contract_number"	default="">
<cfparam name="form.type_code_desc_id"	default="">
<cfparam name="form.payee"			default="">
<cfparam name="form.start_date_operator"	default="">
<cfparam name="form.end_date_operator"		default="">
<cfparam name="form.date_criteria_start"	default="">
<cfparam name="form.date_criteria_end"		default="">
<cfparam name="form.settlement_id"		default="">
<cfparam name="billback_search"	default="">
<cfparam name="form.productID"		default="">
<cfparam name="form.billbackList"		default="">
<cfparam name="form.plannerID"		default="0">

  <cfscript>
    variables.reply = {};

    variables.page_size   = val(form.iDisplayLength);
    if ( variables.page_size eq -1) {
      variables.start_row   = 1;
      variables.end_row     = -1;
    }
    else {
      variables.start_row   = form.iDisplayStart + 1;
      variables.end_row     = form.iDisplayStart + variables.page_size;
    }
    form.sSearch = trim(form.sSearch);

    // parse search string into an array of words
    if ( len(form.sSearch) ) {
      variables.arrayOfWords = reMatch( "[[:word:]]+", form.sSearch );
    }
    else {
      variables.arrayOfWords = [];
    }
    // concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
    variables.listOfWords = arrayToList(variables.arrayOfWords, "%");

    form.iSortCol_0 = val(form.iSortCol_0);
  </cfscript>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfset structItemDetails = PaymentHistoryManager.getpaymentdetails(contract_number=form.contractNumber,contractMainID=form.contractMainID,type_code_desc_id=form.type_code_desc_id,payee=form.payee,
													start_date_operator=form.start_date_operator,end_date_operator=form.end_date_operator,
													date_criteria_start=form.date_criteria_start,date_criteria_end=form.date_criteria_end,
													settlement_id=form.settlement_id,billback_search=billback_search,productID=productID,
													column_sequence_number=form.iSortCol_0,sort_order=form.SSORTDIR_0,
													startRow=variables.start_row,endRow=variables.end_row,selectedMonths=url.selectedMonths,
	   												plannerID=plannerID) />


 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

  <cfoutput>
		  <cfloop query="structItemDetails.queryResults">

			<!---D42826 :: green dollar sign issue :: --->
			<cfif FindNoCase(";",Check_Number)>
				<cfset checkNumberList = "<span onmouseout=popUpTip(event,'Multiple_Checks'); onmouseover=popUpTip(event,'Multiple_Checks');> Multiple <img src='/images/help_small.gif' /></span>">
				<cfset checkNumberList = checkNumberList & "<div id='Multiple_Checks' class='tip'>" & replace(Check_Number,';','<br/>','ALL') & "</div> ">
			<cfelse>
			<cfset checkNumberList = Check_Number>
			</cfif>
			<!---D42826 :: green dollar sign issue :: --->

			<!--- :: check date :: --->
			<cfif check_date NEQ "">
				<cfset CheckDate = dateformat(check_date,"mm/dd/yyyy")>
			<cfelse>
				<cfset CheckDate = '&nbsp;'>
			</cfif>
			<!--- :: check date :: --->
			<!--- :: Actual Check Date/AckDate/ Approved Date :: --->
			<cfif Date_Approved NEQ "">
				<cfset ApprovedDate = dateformat(Date_Approved,"mm/dd/yyyy")>
			<cfelse>
				<cfset ApprovedDate = '&nbsp;'>
			</cfif>
			<cfif Actual_Check_Date NEQ "">
				<cfset ActualCheckDate = dateformat(Actual_Check_Date,"mm/dd/yyyy")>
			<cfelse>
				<cfset ActualCheckDate = '&nbsp;'>
			</cfif>
			<cfif BB_Received_Ack_Date NEQ "">
				<cfset BBReceivedAckDate = dateformat(BB_Received_Ack_Date,"mm/dd/yyyy")>
			<cfelse>
				<cfset BBReceivedAckDate = '&nbsp;'>
			</cfif>			
			<!--- :: Approved date :: --->

			<!--- :: BB Ref AND BB Title ::  --->
			<cfif BB_reference neq "">
				<cfset bbRefANDTitle =  BB_reference & "<br>" & BB_Title>
			<cfelse>
				<cfset bbRefANDTitle =  BB_Title>
			</cfif>
			<!--- :: BB Ref AND BB Title ::  --->

			<cfset variables.dArrayTmp = []>

			<!--- SELECT THE CHECKBOX OF THE SELECTED RECORDS --->
			<cfif form.productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
				<cfif ListFind(form.billbackList,billback_id) neq 0>
					<cfset arrayAppend(variables.dArrayTmp, '<input type="checkbox" id="check_billback" name="check_billback" class="cb" value="#billback_id#" CHECKED ONCLICK="if(!this.checked) document.all.payment_check_all.checked = false;addRemoveBB()">')>
				<cfelse>
					<cfset arrayAppend(variables.dArrayTmp, '<input type="checkbox" id="check_billback" name="check_billback" class="cb" value="#billback_id#" ONCLICK="if(!this.checked) document.all.payment_check_all.checked = false;addRemoveBB()">')>
				</cfif>
			</cfif>
			<cfset arrayAppend(variables.dArrayTmp, bbRefANDTitle)>
		<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
			<cfset arrayAppend(variables.dArrayTmp, '#BB_code#')>
		<cfelse>
			<cfset arrayAppend(variables.dArrayTmp, '<a onclick=window.open("/billbacks/capture/bb_preview.cfm?bbid=#billback_id#","#BB_code#Preview","toolbar=no,width=800,height=600,resizable=no,scrollbars=yes")>#BB_code#</a>')>
		</cfif>
			<cfset arrayAppend(variables.dArrayTmp, payee_name & "<br>" & payee_id)>
			<cfset arrayAppend(variables.dArrayTmp, dateformat(BB_start_date,"mm/dd/yyyy"))>
			<cfset arrayAppend(variables.dArrayTmp, dateformat(BB_End_date,"mm/dd/yyyy"))>
			<cfset arrayAppend(variables.dArrayTmp, dollarFormat(paid_amount) & "<br>" & checkNumberList)>
			<cfset arrayAppend(variables.dArrayTmp, "<font size='1px'>" & ApprovedDate & "<br>" & ActualCheckDate & "<br>" & BBReceivedAckDate & "</font>")>
			<cfset arrayAppend(variables.dArrayTmp, numberformat(volume_lb,'_,') & "<br>" & numberformat(avg_rate_lb,'$(_,.____'))>
			<cfset arrayAppend(variables.dArrayTmp, numberformat(volume_cs,'_,') & "<br>" & numberformat(avg_rate_cs,'$(_,.____'))>

			<cfset arrayAppend(variables.reply.aaData, variables.dArrayTmp)>
		  </cfloop>
  </cfoutput>

	<cfset variables.reply.TotalPoundsInvoiced = structItemDetails.TotalPoundsInvoiced>
	<cfset variables.reply.TotalCasesInvoiced = structItemDetails.TotalCasesInvoiced>

	<cfset variables.reply.iTotalRecords = structItemDetails.recordTotal>
	<cfset variables.reply.iTotalDisplayRecords = structItemDetails.recordTotal>
	<cfset variables.reply.sEcho  = javacast('int', form.sEcho)>
	<cfset variables.sOut = SerializeJSON( variables.reply )>


  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one')>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>

</cfprocessingdirective>