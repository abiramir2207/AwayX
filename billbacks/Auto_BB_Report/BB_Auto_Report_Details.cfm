<!--- BB Auto Report Details:  View or Modify report details
----  called from index.cfm
---- qDetails loads whole report or will run search base on form Value submited
--->
<div style="margin-left:10px">
<cfparam name="FORM.Search_String" default="" />
<cfset qDetails = application.oBBReportGet.getReportDetails(URL.Report, FORM.Search_String, 0)>
<cfset qGetPeriod	= application.oBBReportGet.getReportPeriod(URL.Report) />
<cfset IsAnAutoPayExceptionReport = application.oBBReportGet.getIsAnAutoPayExceptionReport(URL.Report) />
<!---D35392: GM Pullback Log entries --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif  businessSegManager.isEnabled()>
	<cfset Business_Segment_On = 1>
	<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
<cfelse>
	<cfset Business_Segment_On = 0>
	<cfset UserSegmentFiltersAutopayResults = 0>
</cfif>


<!---D35392: GM Pullback Log entries --->
<style type="text/css">
.gray	{background-color: #dfdfe1;} <!---  //EAC6B5 dfdfe1 d1d1d3 --->
.green	{background-color: #C8FBC9;}<!--- //39cc41 --->
.white	{background-color: #FFFFFF;}
.ltgreen	{background-color: #EAFFEA;}
.txt {font-size: 10px;font-weight: normal;}
</style>

		<cfif appSettings.get_Setting('BB_Auto_Pay_enable_BB_Number') eq '1' AND appSettings.get_Setting('BB_Auto_Pay_enable_Ref_Number') eq '1'>
			<cfset BB_Ref_Fields = 'Billback ##<br>Reference ##'>
		<cfelseif appSettings.get_Setting('BB_Auto_Pay_enable_Ref_Number') eq '1'>
			<cfset BB_Ref_Fields = 'Reference ##'>
		<cfelseif appSettings.get_Setting('BB_Auto_Pay_enable_BB_Number') eq '1'>
			<cfset BB_Ref_Fields = 'Billback ##'>
		<cfelse>
			<cfset BB_Ref_Fields = ''>
		</cfif>

<cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css"/>
<form name="frm_BB_Auto_Report_Detail" method="post" action="index.cfm">
<CFOUTPUT>
	<table border="0" cellspacing="0" cellpadding="3"  width="800" style="margin-bottom:20px;" class="datagrid">
		<thead>
		<tr>
			<th width="150" nowrap>
			<cfif application.oBBReportGet.getAutoPayType() EQ 2>
			<!--- Auto Pay Lite --->
				Title
			<cfelse>
			<!--- Full auto pay --->
				Period
			</cfif>
			</th>
			<th  nowrap>
				Report Id
		<cfif (application.appSettingsGet.getUNIPRO_450() IS 1)><img src="/images/Reports-icon.png" border="0" alt="unipro" class="small" title="Export Unipro 450" onclick="generatereport(1,1);" style="cursor:pointer"></cfif>
		<cfif (application.appSettingsGet.getPullbacksOn())><img src="/images/Sales-report-icon.png" border="0" alt="export pullback" class="small" title="Export #application.appSettingsGet.getPullbackLabel()#" onclick="generatereport(1,2);" style="cursor:pointer"></cfif>
		<cfif (application.oBBReportGet.getGrowthCalcExist(qDetails.BB_Auto_Report_id))><img src="/images/report-icon.png" border="0" alt="growth exception" class="small" title="Growth Exceptions" onclick="generatereport(1,3);" style="cursor:pointer"></cfif>
		<!---<IMG BORDER="0" SRC="/images/doc_table_csv.png"  title="Export item level invoice data for this report"  class="small"  style="cursor:pointer">--->
		<a href="##" title="Export item level invoice data for this report" class="small" onclick="NewWindow('/billbacks/Auto_BB_Report/BB_Auto_Report_Export_Universal.cfm?ReportID=#qgetPeriod.BB_Auto_Report_id#&Del=0&Disp=Detail', 'downloadAutoReports', 600, 400, 'yes', 'yes'); return false;" > <!------>
			<IMG BORDER="0" SRC="/images/doc_table_csv.png" class="small">
		</a>
		<!--- Auto Report Exception List --->
		<cfif IsAnAutoPayExceptionReport>
			<img src="/images/excel-icon.png" border="0" alt="Auto pay exception list" class="small" title="Auto pay exception list" onclick="generatereport(1,4);" style="cursor:pointer">
		</cfif>
			</th>
			<th  width="80">Status</th>
			<th  width="80">Programs</th>
			<cfif len(BB_Ref_Fields)>
			<th width="275">#BB_Ref_Fields#</th>
			</cfif>
			<th>Search</th>
		</tr>
		</thead>
		<tr>
			<td class="colHead">
				<cfif application.oBBReportGet.getAutoPayType() EQ 2>
					<!--- Auto Pay Lite --->
					#qgetPeriod.Report_Title#
				<cfelse>
					<!--- Full auto pay --->
					#dateFormat(qgetPeriod.end_date,"mmmm yy")#
				</cfif>
			</td>
			<td align="left">#qgetPeriod.BB_Auto_Report_id#</td>
			<td>#application.oBBReportGet.getReportStatus(status = qgetPeriod.status, pause	= qgetPeriod.Pause_Schedule)#</td>
			<td align="left"><span id="claimCount">#qDetails.recordcount#</span></td>
			<cfif len(BB_Ref_Fields)>
			<td>
				<select name="BB_Ref_Update" id="BB_Ref_Update">
					<option value="1">Billback ##</option>
					<option value="2">Reference ##</option>
				</select>
				<input type="text" name="BB_Ref_Value" value="" style="margin-top:2px;" id="BB_Ref_Value"/>
				<a onclick="updateBB()">#application.util.string.actionLinkFormat2('update')#</a>
			</td>
			</cfif>
			<td  title="Search on Billback Code, Program Number or Payee"><input type="text" name="Search_String" size="25" value="#Form.Search_String#" />&nbsp;&nbsp;<input type="submit" value="Get Details" /></td>
		</tr>
	</table>
		<input type="hidden" name="Disp"  value="Detail" />
		<input type="hidden" name="Report" value="#URL.Report#" />
</CFOUTPUT>

<table border="0" cellspacing="0" cellpadding="1" width="1000" class="datagrid">
	<thead>
	<tr>
		<th>
			Action<span class="txt" style="visibility: hidden;"><input type="checkbox" name="CalcNow" /></span>
			<cfif locked and qDetails.ReportStatus EQ 4 and appSettings.getBBAutoReportAllowReverse() and Get_Profile_Settings.Autopay_Reverse>
			<cfmodule template="/CustomTags/SmallHelp.cfm"
					width = "360"
					displayShifyX = "0"
					displayShifyY = "-30"
					imgPath="/Images/i.gif"
					dropdownCheck = "0"
					imgWidth="12"
					imgHeight="11"
					returnDivId="divNoRoutingMessage"
					>
					<span>
						Selecting the option ''Reverse/Delete'' will create reversing entries if the transaction has already interfaced with the enterprise system[s] and will delete the transaction if it has not already interfaced.
						In either case, the user will need to re-create and re-run any batches that are either reversed or deleted.
					</span>
				</cfmodule>
			</cfif>
		</th>
		<th>
			<input type="checkbox" name="allBBs" value="1" id="checkAll">Billback
			<cfoutput>
				<cfif (application.appSettingsGet.getUNIPRO_450() IS 1)>
					<img src="/images/Reports-icon.png" border="0" alt="unipro" class="small" title="Export Unipro 450 at Billback level" onclick="generatereport(0,1);" style="cursor:pointer">
				</cfif>
				<cfif (application.appSettingsGet.getPullbacksOn())>
					<img src="/images/Sales-report-icon.png" border="0" alt="export pullback" class="small" title="Export #application.appSettingsGet.getPullbackLabel()# at Billback level" onclick="generatereport(0,2);" style="cursor:pointer">
				</cfif>
				<cfif (application.oBBReportGet.getGrowthCalcExist(qDetails.BB_Auto_Report_id))>
					<img src="/images/report-icon.png" border="0" alt="growth exception" class="small" title="Growth Exceptions at Billback level" onclick="generatereport(0,3);" style="cursor:pointer">
				</cfif>
			</cfoutput>
		</th>
		<cfif len(BB_Ref_Fields)>
		<th>
			<cfoutput>#BB_Ref_Fields#</cfoutput>
		</th>
		</cfif>

			<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
				<cfset Payeewidth="65">
			<cfelse>
				<cfset Payeewidth="125">
			</cfif>
		<th width="#Payeewidth#">Payee</th>
		<th>Program</th>
	<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
		<th>Pay Cycle</th>
	</cfif>
		<th>Start Date<br> End Date</th>
		<th>Gross Amount</th>
	<cfif appSettings.getPullbacksOn()>
		<th nowrap><cfoutput>#appsettings.getPullbackLabel()#</cfoutput></th>
	</cfif>
		 <th>Final Pymt </th>
	</tr>
	</thead>
	<cfoutput query="qDetails">
		<cfset id = qDetails.BB_Auto_Program_Pay_Period_ID />
		<cfset BBId = application.oBBReportGet.getBBIds(id).Billback_Id />
		<!--- Handle for re-calc records.  BBID is null, but we can't cast a guid to an int --->
		<cfif BBId EQ "">
			<cfset BBId = "0" />
		</cfif>
		<!---D35392: GM Pullback Log entries --->
		<cfset action = application.oBBReportGet.getBBDetailAction(		reportID						= qDetails.BB_Auto_Report_id,
																															userId							= qDetails.updated_User_id,
																															BBId							= BBId,
																															PayPeriodId				= id,
																															reportStatus 				= qDetails.ReportStatus,
																															Contract_Main_ID 	= qDetails.Contract_Main_ID,
																															PullbacksOn 				= appSettings.getPullbacksOn(),
																															BBApplyPullback		=	Get_Profile_Settings.BB_Apply_Pullback,
																															Autopay_Reverse = Get_Profile_Settings.Autopay_Reverse,
																															BBStatus = qDetails.BBStatus)/>

		<tr id="PayPeriod#id#"<cfif BBId EQ 0>class="gray" <cfelseif (qDetails.CurrentRow MOD 2) EQ 0>class="white"<cfelse>class="ltgreen"</cfif> class="new">

			<td align="left" valign="top" style="padding-left:5px;">
				<span id="spanAction#id#">
					#action#
				</span>
				<img src="/images/loading_red.gif" align="absmiddle" hspace="5" id="spanLoading#id#" style="display:none"/>&nbsp;
			</td>

			<td class="colHead" nowrap>
				<span id="spanBBcode#id#">
					<!--- Moved from out of BBAutoReportGet.cfc because I need to reuse the query --->
					<cfset qBBInfo = application.oBBReportGet.getBBDetail(id) />
					<cfset i = 0 />
						<cfloop query="qBBInfo">
						<cfif qBBInfo.BB_CODE NEQ '' AND qBBInfo.BB_CODE NEQ 'ReCalc'>
							<!--- line break if more than one --->
							<cfif i GT 0> <br></cfif>
							<input type="checkbox" name="billbackIds" value="#qBBInfo.billback_id#" id="billbackIds" class="billbackIds" <cfif (isDefined("qBBInfo.User_Business_segment_ID") AND qBBInfo.User_Business_segment_ID NEQ "")>&nbsp;<cfelse>disabled</cfif>>
							<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
								<cfif (isDefined("qBBInfo.User_Business_segment_ID") AND qBBInfo.User_Business_segment_ID NEQ "")>
									<a href="##" onclick="browse('#JSSTRINGFORMAT(qBBInfo.billback_id)#');return false;" title="#qBBInfo.BB_Title#">#qBBInfo.BB_CODE#</a>
									<a  id="spanAction#qDetails.BB_Auto_Report_id#" title="View the line item details for this billback in the export file" href="/billbacks/auto_bb_report/index.cfm?Report=#qDetails.BB_Auto_Report_id#&disp=ExpView&PP_ID=#id#&BB_ID=#qBBInfo.Billback_ID#&PageTitle=PAYABLES: Auto Pay Export Report #qDetails.BB_Auto_Report_id#">
								<img src="/images/view.gif" align="middle" border="0" />
							</a>
								<cfelse>
									#qBBInfo.BB_CODE#
								</cfif>
							<cfelse>
								<a href="##" onclick="browse('#JSSTRINGFORMAT(qBBInfo.billback_id)#');return false;" title="#qBBInfo.BB_Title#">#qBBInfo.BB_CODE#</a>
								<a  id="spanAction#qDetails.BB_Auto_Report_id#" title="View the line item details for this billback in the export file" href="/billbacks/auto_bb_report/index.cfm?Report=#qDetails.BB_Auto_Report_id#&disp=ExpView&PP_ID=#id#&BB_ID=#qBBInfo.Billback_ID#&PageTitle=PAYABLES: Auto Pay Export Report #qDetails.BB_Auto_Report_id#">
								<img src="/images/view.gif" align="middle" border="0" />
							</a>
							</cfif>
							<!--- D71658 Moved the “apply recapture” and “un-apply recapture” icons from first column to second column in auto pay details page. --->
							<cfif locked and qDetails.ReportStatus LT 4 and BBStatus LT 4 and appSettings.getPullbacksOn() and Get_Profile_Settings.BB_Apply_Pullback>
							&nbsp;<a  href="##" id="ApplyPullback" name="ApplyPullback" title="Apply #appsettings.getPullbackLabel()# for this BB" onclick="pullbacks('#Billback_Id#',0);return false;"><img src="/images/statusImage1.gif" align="middle" border="0" /></a>
							<cfif Pullback_applied_Amount neq 0>
							&nbsp;<a  href="##" id="UnApplyPullback"name="UnApplyPullback" title="Un-apply #appsettings.getPullbackLabel()# #dollarformat(Pullback_Applied_Amount)# for this BB" onclick="pullbacks('#Billback_Id#',1);return false;"><img src="/images/statusImage2.gif" align="middle" border="0" /></a>
							</cfif>
							</cfif>
						<cfelse><!--- Recalc Record --->
							&nbsp;
						</cfif>
						<cfset i = i + 1 />
					</cfloop>
					<cfif BBId NEQ 0></span></cfif>
					&nbsp;
			</td>
			<cfif len(BB_Ref_Fields)>
			<td>
					<!--- Moved from out of BBAutoReportGet.cfc because I need to reuse the query --->
					<cfset qBBInfo = application.oBBReportGet.getBBDetail(id) />
					<cfset i = 0 />
					<cfloop query="qBBInfo">
						<!--- line break if more than one --->
						<cfif i GT 0><hr></cfif>
						#qBBInfo.BB_Reference#
						<cfif len(qBBInfo.referenceNum)>
							/ #qBBInfo.referenceNum#
						</cfif>
						<cfset i = i + 1 />
					</cfloop>
			</td>
			</cfif>

			<td valign="top" nowrap height="10" style="padding-left:5px;">
				<span id="spanPayee#id#">
					<CFIF application.oBBReportGet.getBBIds(qDetails.BB_Auto_Program_Pay_Period_ID).recordcount GT 1>
						<cfloop query ="qBBInfo">
							#left(Name, 15)# (#Ship_To#) <img src="/images/clear.gif" height="20" align="middle" border="0" /> <!--- this image helps line it up with the billback ---><br>
						</cfloop>
					<CFELSE>
						#qDetails.Vendor_Name# <CFIF trim(qDetails.Vendor_ID) NEQ ''>(#trim(qDetails.Vendor_ID)#)</CFIF>
					</CFIF>
				</span>
			</td>
			<td class="colHead" valign="top" style="padding-left:5px;">
				<span id="spanContractNum#id#">
					<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
						<cfif (isDefined("qBBInfo.User_Business_segment_ID") AND qBBInfo.User_Business_segment_ID NEQ "")>
							#application.oBBReportGet.getProgramLink(qDetails.Contract_Number,qDetails.Contract_Main_ID)#
						<cfelse>
							#qDetails.Contract_Number#
						</cfif>
					<cfelse>
						#application.oBBReportGet.getProgramLink(qDetails.Contract_Number,qDetails.Contract_Main_ID)#
					</cfif>
				</span>
			</td>
			<cfif application.oBBReportGet.getAutoPayType() NEQ 2>
			<td valign="top" style="padding-left:5px;">
				<span id="spanPayCycle#id#">
						#qDetails.Payment_Cycle#
				</span>
			</td>
			</cfif>
			<td nowrap valign="top" style="padding-left:5px;">
				#dateformat(qDetails.Payment_Start_Date, 'mmm d yyyy')#&nbsp;
			<br>
				#dateformat(qDetails.Payment_End_Date, 'mmm d yyyy')#&nbsp;
			</td>
			<td valign="top" style="padding-left:5px;" align="right">
				<span id="spanAmount#id#">
					<cfif BBId NEQ 0>
						#dollarformat(qDetails.Gross_Amount)#
					<cfelse><!--- Recalc Record --->
						#application.oBBReportGet.getDiscountName(discountTypeId = qDetails.Discount_Type_Id)#
					</cfif>
				</span>
			</td>
			<cfif appSettings.getPullbacksOn()>
			<td valign="top" style="padding-left:5px;" align="right">
				<span id="spanPullbackAmount#id#">
					<cfif BBId NEQ 0>
						#dollarformat(qDetails.Pullback_Applied_Amount)#
					</cfif>
				</span>
			</td>
			</cfif>
			<td valign="top" style="padding-left:5px;" align="right">
					#dollarformat(qDetails.Net_Amount)#
			</td>
		</tr>
	</cfoutput>
</table>
<input type="hidden" name="process" value="0" />
</form>
<cfinclude template="/common_files/jQuery.cfm">
<script>
	//ajBBReport = new autoPay();
<!--- Detail Page Script xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
	function callDetailResponse(response) {
		response = jQuery.parseJSON(response);
		var theAction	= 'spanAction' + response[1];
		var theLoad		= 'spanLoading' + response[1];
		var theTitle	= 'spanBBcode' + response[1];
		var theAmount	= 'spanAmount' + response[1];
		<cfif appSettings.getPullbacksOn()>
		var theRecaptureAmount		= 'spanPullbackAmount' + response[1];
		</cfif>
		var theRow		= 'PayPeriod' + response[1];
	  // Gray out Row
	  document.getElementById(theRow).className = response[0];
	  //hide loader image
	  document.getElementById(theLoad).style.display = 'none';
	  //update user and date in Title field
	  document.getElementById(theTitle).innerHTML = response[2] + '&nbsp;';
	  //clear The Amount
	  document.getElementById(theAmount).innerHTML = '&nbsp;';
	  <cfif appSettings.getPullbacksOn()>
	  //clear The Amount
	  document.getElementById(theRecaptureAmount).innerHTML = '&nbsp;';
	  </cfif>
	  unLockLinks();
	  }
	function callRecalcResponse(response) {
		response = jQuery.parseJSON(response);
		var theAction	= 'spanAction' + response[1];
		var theLoad		= 'spanLoading' + response[1];
		var theTitle	= 'spanTitle' + response[1];
		var theAmount	= 'spanAmount' + response[1];
		var theRow		= 'PayPeriod' + response[1];
		var theBBcode	= 'spanBBcode' + response[1];
		<cfif appSettings.getPullbacksOn()>
		var theRecaptureAmount		= 'spanPullbackAmount' + response[1];
		</cfif>
	  // Gray out Row
	  document.getElementById(theRow).className = 'green'; //response[0]
	  //hide loader image
	  document.getElementById(theLoad).style.display = 'none';
	  //update user and date in Title field
	  //document.getElementById(theTitle).innerHTML = response[2] + '&nbsp;';
	  //clear The Amount
	  document.getElementById(theAmount).innerHTML = response[4];
	  document.getElementById(theBBcode).innerHTML = 'Re-Calc'; //response[3]
	  //update the actio links
	  document.getElementById(theAction).innerHTML = response[5];
	  <cfif appSettings.getPullbacksOn()>
	  document.getElementById(theRecaptureAmount).innerHTML = response[6];
	  </cfif>
	  //unlock Links
	  unLockLinks();
	  }
	 function callApproveResponse(response) {
	 	response = jQuery.parseJSON(response);
		var theAction	= 'spanAction' + response[1];
		var theLoad		= 'spanLoading' + response[1];
		var theTitle	= 'spanTitle' + response[1];
		var theAmount	= 'spanAmount' + response[1];
		var theRow		= 'PayPeriod' + response[1];
		var theBBcode	= 'spanBBcode' + response[1];
	  // Gray out Row
	  document.getElementById(theRow).className = 'green'; //response[0]
	  //hide loader image
	  document.getElementById(theLoad).style.display = 'none';
	  //update the actio links
	  document.getElementById(theAction).innerHTML = response[5];

	  //unlock Links
	  unLockLinks();
	  }
<!---  function removeBBAction(reportId,userId,BBId,PayPeriodId) {
	  // Calls remote method with string mask as argument
	  var argument = new Array();
	  var theId = 'spanLoading' + PayPeriodId;
	  var theAction = 'spanAction' + PayPeriodId;
	  argument[0]	= reportId;
	  argument[1]	= userId;
	  argument[2]	= BBId;
	  // Show loader elementId = periodid + reportid...reportid is always 0 for create
	   document.getElementById(theId).style.display = '';
	  //Hide the Links
	   document.getElementById(theAction).innerHTML = '';
	  //call ajax.  response goes to JS callReportResponse() in an array
	  ajBBReport.call('removeBBCaller',callDetailResponse,argument);
	  }  --->
 function removeBBAction(reportId,userId,BBId,PayPeriodId) {
	  // Calls remote method with string mask as argument
	  var argument = new Array();
	  var theId = 'spanLoading' + PayPeriodId;
	  var theAction = 'spanAction' + PayPeriodId;
	  var theBBcode = 'spanBBcode' + PayPeriodId;
	  argument[0]	= reportId;
	  argument[1]	= userId;
	  argument[2]	= BBId;
	  argument[3]	= PayPeriodId;
	  if (document.all.frm_BB_Auto_Report_Detail.process.value == '0')
		  {
			lockLinks();
		  // Show loader elementId = periodid + reportid...reportid is always 0 for create
		   document.getElementById(theId).style.display = '';
		  //Hide the Links
		   document.getElementById(theAction).innerHTML = ' ';
		   document.getElementById(theBBcode).innerHTML = ' ';
		  //call ajax.  response goes to JS callReportResponse() in an array
		 // ajBBReport.call('removeBBCaller',callDetailResponse,argument);
		 //ChromeFix :: ajBBReport only supports IE
		jQuery.ajax({
					  url: "/components/Billback/BBAutoReportAjaxCaller.cfc?method=removeBBCaller",
					  //data:argument
					 // type: "post",
					  contentType: "application/json",
					  data: { arg: JSON.stringify(argument) },
					  }).done( function( msg ) {
						    callDetailResponse(msg);
						  }
					);
		  //update claim count
		  document.getElementById('claimCount').innerHTML = document.getElementById('claimCount').innerHTML - 1;
	  	  }
	  else
		  {
			alert("Another Process is currently running.  Please wait until it completes and try again.");
		  }
	  }
 function reverseBBAction(reportId,userId,BBId,PayPeriodId) {
	  // Calls remote method with string mask as argument
	  var argument = new Array();
	  var theId = 'spanLoading' + PayPeriodId;
	  var theAction = 'spanAction' + PayPeriodId;
	  var theBBcode = 'spanBBcode' + PayPeriodId;
	  argument[0]	= reportId;
	  argument[1]	= userId;
	  argument[2]	= BBId;
	  argument[3]	= PayPeriodId;
	  if (document.all.frm_BB_Auto_Report_Detail.process.value == '0')
		  {
			lockLinks();
		  // Show loader elementId = periodid + reportid...reportid is always 0 for create
		   document.getElementById(theId).style.display = '';
		  //Hide the Links
		   document.getElementById(theAction).innerHTML = ' ';
		   document.getElementById(theBBcode).innerHTML = ' ';
		  //call ajax.  response goes to JS callReportResponse() in an array
		//  ajBBReport.call('reverseBBCaller',callDetailResponse,argument);
		//ChromeFix :: ajBBReport only supports IE
		jQuery.ajax({
					  url: "/components/Billback/BBAutoReportAjaxCaller.cfc?method=reverseBBCaller",
					  //data:argument
					 // type: "post",
					  contentType: "application/json",
					  data: { arg: JSON.stringify(argument) },
					  }).done( function( msg ) {
						    callDetailResponse(msg);
						  }
					);
		  //update claim count
		//  document.getElementById('claimCount').innerHTML = document.getElementById('claimCount').innerHTML - 1;
	  	  }
	  else
		  {
			alert("Another Process is currently running.  Please wait until it completes and try again.");
		  }
	  }
 function approvePayPeriodAction(reportId,PayPeriodId,userId) {
	  // Calls remote met;hod with string mask as argument

	  var argument = new Array();
	  var theId = 'spanLoading' + PayPeriodId;
	  var theAction = 'spanAction' + PayPeriodId;
	  var theBBcode = 'spanBBcode' + PayPeriodId;
	  argument[0]	= reportId;
	  argument[1]	= userId;
	  argument[2]	= PayPeriodId;
	  if (document.all.frm_BB_Auto_Report_Detail.process.value == '0')
		  {
			lockLinks();
		  // Show loader elementId = periodid + reportid...reportid is always 0 for create
		   document.getElementById(theId).style.display = '';
		  //Hide the Links
		   document.getElementById(theAction).innerHTML = ' ';
		  //call ajax.  response goes to JS callReportResponse() in an array
		 // ajBBReport.call('approvePayPeriodCaller',callApproveResponse,argument);
		 //ChromeFix :: ajBBReport only supports IE
		jQuery.ajax({
					  url: "/components/Billback/BBAutoReportAjaxCaller.cfc?method=approvePayPeriodCaller",
					  //data:argument
					 // type: "post",
					  contentType: "application/json",
					  data: { arg: JSON.stringify(argument) },
					  }).done( function( msg ) {
						    callApproveResponse(msg);
						  }
					);
		  //update claim count
		//  document.getElementById('claimCount').innerHTML = document.getElementById('claimCount').innerHTML - 1;
	  	  }
	  else
		  {
			alert("Another Process is currently running.  Please wait until it completes and try again.");
		  }
	  }
// D39144 :: Autopay Recapture
function pullbacks(bbackid, type)
				{
					NewWindow('/billbacks/auto_bb_report/apply_unapply_pullbacks.cfm?BB_ID='+bbackid+'&type='+type,'pullbackdetails','870','700','Yes', 'Yes');
				}
//D35392: GM Pullback Log entries
function submitapplypullbackform(bbackid)
				{
					NewWindow('/billbacks/approval/applypullbacks.cfm?BB_ID='+bbackid,'pullbackdetails','870','620','Yes', 'Yes');
				}
function submitunapplypullbackform(bbackid)
				{
					NewWindow('/billbacks/approval/viewappliedpullbacks.cfm?BB_ID='+bbackid,'pullbackdetails','870','620','Yes', 'Yes');
				}
//D35392: GM Pullback Log entries
function lockLinks(){
			document.all.frm_BB_Auto_Report_Detail.process.value = '1';
		}
function unLockLinks(){
			document.all.frm_BB_Auto_Report_Detail.process.value = '0';
		}
 function recalcBBAction(reportId,userId,BBId,PayPeriodId) {
	  // Calls remote method with string mask as argument
	  var argument = new Array();
	  var theId = 'spanLoading' + PayPeriodId;
	  var theAction = 'spanAction' + PayPeriodId;
	  argument[0]	= reportId;
	  argument[1]	= userId;
	  argument[2]	= BBId;
	  argument[3]	= PayPeriodId;
	  argument[4]	= document.all.frm_BB_Auto_Report_Detail.CalcNow.checked;
	  if (document.all.frm_BB_Auto_Report_Detail.process.value == '0')
		  {
			lockLinks();
			  // Show loader elementId = periodid + reportid...reportid is always 0 for create
			document.getElementById(theId).style.display = '';
			  //Hide the Links
			document.getElementById(theAction).innerHTML = '';
			  //call ajax.  response goes to JS callReportResponse() in an array
			//ajBBReport.call('recalcBBCaller',callRecalcResponse,argument);
			jQuery.ajax({
					  url: "/components/Billback/BBAutoReportAjaxCaller.cfc?method=recalcBBCaller",
					  //data:argument
					 // type: "post",
					  contentType: "application/json",
					  data: { arg: JSON.stringify(argument) },
					  }).done( function( msg ) {
						    callRecalcResponse(msg);
						  }
					);
		  }
		else
		  {
			alert("Another Process is currently running.  Please wait until it completes and try again.");
		  }
	  }

function browse(id)
 {
  NewWindow('/billbacks/capture/bb_preview.cfm?BBID='+id,'BB_Preview','800','600','Yes', 'Yes');
 }
function CreatePDF(Report_ID,Contract_Main_ID,BB_Auto_Program_Pay_Period_ID)
{
	NewWindow('/billbacks/Auto_BB_Report/create_pdf_holder.cfm?Report_ID='+Report_ID+'&Contract_Main_ID='+Contract_Main_ID+'&BB_Auto_Program_Pay_Period_ID='+BB_Auto_Program_Pay_Period_ID,'AutoPay','800','600','Yes', 'Yes');
	return false;
}
 function generatereport(level, type){
	 if(level =='0'){
		 var chkBoxArray = [];
		$('#billbackIds:checked').each(function() {
				chkBoxArray.push($(this).val());
			});
		if(chkBoxArray == 0){
			alert('Please select atleast one Billback!');
			return;
		}
	 }
<cfoutput>
	if(type =='1'){
		window.open("/billbacks/auto_bb_report/Unipro_450_Report.cfm?ReportID=#qDetails.BB_Auto_Report_id#&ReportLevel="+level+"&billback_id="+chkBoxArray, "", "width=800,height=500,scrollbars=yes");
	}
		else if(type == '2'){
		window.open("/billbacks/auto_bb_report/BB_Auto_Report_Export_Pullback_Universal.cfm?ReportID=#qDetails.BB_Auto_Report_id#&ReportLevel="+level+"&billback_id="+chkBoxArray, "", "width=800,height=500,scrollbars=yes");
	}
		else if(type == '3'){
		window.open("/billbacks/auto_bb_report/BB_Auto_Report_Growth_Calc_Details.cfm?ReportID=#qDetails.BB_Auto_Report_id#&ReportLevel="+level+"&billback_id="+chkBoxArray, "", "width=800,height=500,scrollbars=yes");
	}
		else if(type == '4'){
		window.open("/billbacks/auto_bb_report/BB_Auto_Exception_Report.cfm?ReportID=#qDetails.BB_Auto_Report_id#", "", "width=800,height=500,scrollbars=yes");
	}
}
</cfoutput>

   //Select and deselect all checkboxes
	$("#checkAll").click(function(){
		$(".billbackIds").prop("checked",$(this).prop("checked"));
	});

	//If one BILLBACK deselect then checkbox 'checkAll' is UnCheck
	//If all BILLBACK select individually then checkbox 'checkAll' is Check
	$(".billbackIds").click(function () {
		$("#checkAll").prop('checked', ($('.billbackIds:checked').length == $('.billbackIds').length) ? true : false);
	});

function updateBB(){
			 var chkBoxArray = [];
			 var error = '';



		$('.billbackIds:checked').each(function() {
				chkBoxArray.push($(this).val());
			});
		if(chkBoxArray == 0){
			error = error.concat('Please select atleast one Billback\n');
		}
		if ($('#BB_Ref_Value').val() == ''){
			error = error.concat('Please enter value for <cfoutput>#replace(BB_Ref_Fields,'<br>',' / ')#</cfoutput>')
		}
		if(error.length){
			alert(error);
		}
		else{ 
					$.ajax({
										  url: "/components/Billback/BBAutoReportAjaxCaller.cfc"
											,type: "post"
											,dataType: 'json'
										  ,data: {
										  	   method: "BBUpdate"
											, arg: JSON.stringify(chkBoxArray)
											, type:$('#BB_Ref_Update').val()
											, value: $('#BB_Ref_Value').val()
										  }
												,	success: function (data){
													location.reload(true);
												}
										  })
		}
}
</script>
</div>