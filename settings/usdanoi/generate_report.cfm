<cfsilent>
<cfparam name="url.report_filename" default="">
<cfparam name="url.final_destination" default="">
<cfparam name="url.report_number" default="0">
<cfparam name="url.ReportUOM" default="rm">
<cfparam name="url.REPORTBBDETAIL" default="0">
<cfparam name="url.ReportType" default="operator">
<cfparam name="url.thisReportBBDetail" default="1">
<cfparam name="url.state" default="0">
<cfparam name="url.county" default="0">
<cfparam name="url.operator" default="0">
<cfparam name="url.distributor" default="0">
<cfparam name="url.operatorid" default="0">
<cfparam name="url.productid" default="0">
<cfparam name="url.programid" default="0">
<cfparam name="url.distributor_ID" default="0">
<cfparam name="operator_id" default="0">
<cfparam name="url.SummaryExport" default="">
<cfparam name="url.file" default="">
<cfparam name="url.file_printer_friendly" default="">
<cfif url.Operator IS NOT 0>
	<cfset Operator_ID = url.Operator>
</cfif>
<cfif url.Distributor IS NOT 0>
	<cfset Distributor = url.Distributor>
</cfif>
<cfif url.operatorid IS NOT 0>
	<cfset Operator_ID = url.operatorid>
</cfif>

<cfif isdefined("url.selReportType")>
	<cfset url.ReportType = url.selReportType>
</cfif>

<cfif isdefined("url.selReportUOM")>
	<cfset url.thisReportUOM = url.selReportUOM>
	<cfset url.ReportUOM = url.selReportUOM>
</cfif>

<cfif isdefined("url.selReportBBDetail")>
	<cfset url.ReportBBDetail = url.selReportBBDetail>
	<cfset url.thisReportBBDetail = url.selReportBBDetail>
</cfif>
<cfif url.ReportType EQ "export_to_excel" or url.SummaryExport eq "summaryexportexcel">
	<cfset spacer = " ">
	 	<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=NOIReport.xls">
</cfif>

<cfset form.thisReportUOM = url.ReportUOM>
<cfset form.thisReportBBDetail = url.ReportBBDetail>


<!---Get state and county for program with only operator--->
<cfif url.state IS 0 AND url.county IS 0 AND url.operator IS NOT 0>
<cfquery name="GetOperatorMap" datasource="#application.datasource#">
	SELECT	StateFIPS, CountyFIPS
	FROM	Operator_ZipCode_Map
	WHERE 
	BSA_Operator_ID = '#url.Operator#'
</cfquery>

<cfset url.state = GetOperatorMap.StateFIPS>
<cfset url.county = GetOperatorMap.CountyFIPS>

</cfif>
</cfsilent>
<cfif url.ReportType NEQ "export_to_excel" and url.SummaryExport neq "summaryexportexcel">
<cfscript>
	function CalcTime(Seconds) {
		tData1 = 0;
		tData2 = 0;
		CalcTime = 999;
		
		if(Seconds LT 60) {
			if(len(Seconds) EQ 1){
				CalcTime = "00:0" & Seconds;
			}
			else {
				CalcTime = "00:" & Seconds;
			}
			return CalcTime;
		}
		else {
			tData1 = RoundDown(Seconds / 60);
			tData2 = Seconds - tData1 * 60;

	        If(Len(tData1) EQ 1) {
            	tData1 = "0" & tData1;
			}

	        If(Len(tData2) EQ 1){
            	tData2 = "0" & tData2;
			}
			CalcTime = tData1 & ":" & tData2;

		}
	
		return CalcTime;
	}
	
	function RoundDown(Number) {
		tData1 = 0;
		tData1 = Find(",", Number);
		 If(tData1 EQ 0){
		 	 RoundDown = Number;
		 }
		 else {
		 	 RoundDown = Left(Number, tData1 - 1);		 
		 }
	 return RoundDown;
	}
</cfscript>

<!--- 
	ORBITZ inspired wait screen.
	author: eduardo vazquez
 --->
<cfsilent>
<cfset filename = createuuid()&createuuid()>
<cfset filename = "A"&replace(filename, "-","","ALL")>

<cfquery name="CheckForExistingReportTimeStats" datasource="#application.datasource#">
	SELECT ReportTimeSec 
	FROM usdanoi_reportstats
	WHERE
		<cfif url.state NEQ 0>StateFips = '#url.state#'<CFELSE>StateFips IS NULL</cfif>
		
		<cfif url.county NEQ 0>AND CountyFips = '#url.county#'<Cfelse>AND CountyFips IS NULL</cfif>

		<cfif url.operator NEQ 0>AND Operator_ID = '#url.operator#'<CFELSE>AND Operator_ID IS NULL</cfif>
		AND
		ReportType = '#url.ReportType#'
		AND
		ReportUOM = '#url.ReportUOM#'
		AND
		ReprtSHowBillback = '#url.thisReportBBDetail#'
</cfquery>
</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Please Wait...</title>
	

</head>

<body>

<BR>
<BR>
<BR>
<BR>
<div align="center">
	<span style="color:maroon;font-size:20px;">Please wait while your report is prepared</span>
	<BR><BR>
	<img src="/images/lamb_weston.jpg" title="" width="300" height="62" border="0">
	<BR><BR>
	<span style="color:maroon;font-size:20px;">Please wait while your report is prepared<br><br>
	
	This may take upwards of 30 seconds...Please Be Patient
	
	<cfif CheckForExistingReportTimeStats.recordcount GT 0><cfoutput><br>
	<cfset rt = CalcTime(CheckForExistingReportTimeStats.ReportTimeSec)>
	<br>
	This Report When Last Run Completed in: #rt# (mm:ss)<BR></cfoutput></cfif>
	<FORM NAME="timerForm" onSubmit="0">Time Elapsed:&nbsp;
		<input type="text" name="timerField" size="10" style="border: 0 none; font-size: 20px;" style="color: maroon;"></FORM>
	
	</span>
</div>
<SCRIPT LANGUAGE="JavaScript">
<!-- Beginning of JavaScript --------
/* 
	JavaScript Timer
	Written by Jerry Aman, Optima System, June 1, 1996.
	Part of the PageSpinner distribution.
 
	Portions based upon the JavaScript setTimeout example at:
	http://home.netscape.com/eng/mozilla/Gold/handbook/javascript/

	We will not be held responsible for any unwanted 
	effects due to the usage of this script or any derivative.  
	No warrantees for usability for any specific application are 
	given or implied.

	You are free to use and modify this script,
	if the credits above are given in the source code
*/

var	timerID = null
var	timerRunning = false
var	startDate
var	startSecs

function stopclock()
{
	if(timerRunning)
		clearTimeout(timerID)
		timerRunning = false
}

function startclock()
{
	startDate = new Date()
	startSecs = (startDate.getHours()*60*60) + (startDate.getMinutes()*60) 
						+ startDate.getSeconds()

	stopclock()
	showtime()
}


/*	-------------------------------------------------
	showtime()
	Puts the amount of time that has passed since 
	loading the page into the field named timerField in 
	the form named timeForm 
	-------------------------------------------------	*/

function showtime()
{
	// this doesn't work correctly at midnight...

	var now = new Date()
	var nowSecs = (now.getHours()*60*60) + (now.getMinutes()*60) + now.getSeconds()
	var elapsedSecs = nowSecs - startSecs;

	var hours = Math.floor( elapsedSecs / 3600 )
	elapsedSecs = elapsedSecs - (hours*3600)

	var minutes = 	Math.floor( elapsedSecs / 60 )
	elapsedSecs = elapsedSecs - (minutes*60)

	var seconds = elapsedSecs

	var timeValue = "" + hours
	timeValue  += ((minutes < 10) ? ":0" : ":") + minutes
	timeValue  += ((seconds < 10) ? ":0" : ":") + seconds

		// Update display
	document.timerForm.timerField.value = timeValue 
	timerID = setTimeout("showtime()",1000)
	timerRunning = true
}

// -- End of JavaScript code -------------- -->
	startclock();
</SCRIPT>

<cfflush>
<cfsilent>
<!--- Report Time Measurement --->
<CFSET begin=gettickcount()>

<cfif
	url.programid NEQ "0" 
	AND
	url.programid NEQ ""
	AND
	len(trim(url.programid)) NEQ "0"
	AND
	url.operator NEQ "0" 
	AND
	url.operator NEQ ""
	AND
	len(trim(url.operator)) NEQ "0">
	<cfquery name="getLatestAgreement" datasource="#application.datasource#">
	SELECT    top 1 dbo._Users.Name_First, dbo._Users.Name_Last, dbo.USDA_Agreement.DateTimeStamp, User_Agrees, Notes
	FROM         dbo.USDA_Agreement INNER JOIN
	                      dbo._Users ON dbo.USDA_Agreement.User_ID = dbo._Users.User_ID
		WHERE 
		--dbo.USDA_Agreement.User_ID = '#request.AccessStructure.user_id#'
		--AND
			dbo.USDA_Agreement.Operator = '#url.operator#'
		AND
			Program_ID = '#url.programid#'
			
			ORDER BY dbo.USDA_Agreement.DateTimeStamp desc
	
	</cfquery>
<cfelse>
	<cfquery name="getLatestAgreement" datasource="#application.datasource#">
	SELECT    top 1 dbo._Users.Name_First, dbo._Users.Name_Last, dbo.USDA_Agreement.DateTimeStamp, User_Agrees, Notes
	FROM         dbo.USDA_Agreement INNER JOIN
	                      dbo._Users ON dbo.USDA_Agreement.User_ID = dbo._Users.User_ID
		WHERE USDA_Agreement.Operator_ID = '#Operator_ID#'
		ORDER BY dbo.USDA_Agreement.DateTimeStamp desc
	</cfquery>
</cfif>
</cfsilent>

<!--- Dev Note: KAL; 8425 --->
<cfset USDANOIPath = "" />
<cfif isdefined("Application.Doc_Mapping")>
	<cfset USDANOIPath = Application.Doc_Mapping />
</cfif>	 

<cfset url.file = "#USDANOIPath#\Temp_Files\Program\#filename#.tmp">
<cfset url.file_printer_friendly = "#USDANOIPath#\Temp_Files\Program\#filename#_printer_friendly.tmp">
</cfif>
<cfif url.ReportType NEQ "export_to_excel" and url.SummaryExport neq "summaryexportexcel">
 <cfsavecontent variable = "reportresults"> 
<cfinclude template="program_search.cfm">

<IFRAME name="popupHelper" style="DISPLAY: none; LEFT: 0px; POSITION: absolute; TOP: 0px" src="javascript:false;" frameBorder="0" scrolling="no"></IFRAME>

<div id="agreementForm" style="border: 1px solid Blue; position: absolute; visibility: hidden;">
<table bgcolor="White" width="100%" height="100%" cellpadding="5">
<tr>
	<td valign="top">
<span style="font-size: 15px;">
<b>Verification of Indirect Sales Discount</b><BR><BR>
Federal regulations require Lamb Weston to verify that your school is receiving the appropriate discounts.<BR>
Please confirm that your school is receiving the appropriate discounts by using the information from this 
report and your purchase records.
<UL>
	<li>If your school is receiving the proper discounts as shown on this report, select the “I Agree” button.</li>
	<li>If there is an error with the discount you are receiving, please select the “I Do Not Agree” button
and utilize the notes field to communicate the errors you believe are present. This selection will send 
notification to Lamb Weston for corrective action.</li>
	<li>Please note that failure to select either choice will be considered a confirmation that you are receiving
the proper discount.</li>
</UL>
</span>
<form action="agree_save.cfm" method="post" name="confirmationForm" id="confirmationForm">
<input type="hidden" name="IAgreeOperator" value="<cfoutput>#IAgreeOperator#</cfoutput>">
		<table cellspacing="0" cellpadding="1px" align="center" bgcolor="blue"><tr><td>
			<table cellspacing="0" cellpadding="10" align="center" bgcolor="WhiteSmoke">
				<tr>
					<td nowrap colspan="1"><div align="center" style="font-size: 15px; font-weight: bold; vertical-align: middle;"><input type="Radio" name="I_Agree" value="1">I Agree
					&nbsp;&nbsp;
					<input type="Radio" name="I_Agree" value="0">I Do Not Agree</div>
					<hr color="#0000FF" style="height: 1px;">
					Notes:<BR><textarea name="Notes" cols="65" rows="4"></textarea>
					<Br>
					<input type="Button" value="OK" onclick="document.all.confirmationForm.submit();">&nbsp;<input type="Button" value="Cancel" onclick="hideAgreementForm();"></td>
					
				</tr>

			</table>
		</td></tr></table>
		
	</td>
</tr>
</table>
			<cfoutput>
			<input type="hidden" name="Operator_ID" value="#Operator_ID#">
			<input type="Hidden" name="agree_state" value="#url.state#">
			<input type="Hidden" name="agree_county" value="#url.county#">
			<input type="Hidden" name="agree_operator" value="#url.operator#">
			<input type="Hidden" name="file" value="#url.file#">
			<input type="Hidden" name="report_number" value="#url.report_number#">
			<input type="Hidden" name="final_destination" value="/settings/usdanoi/show_report.cfm">
			<cfif isdefined("url.programid")>
				<cfif url.programid NEQ 0>
					<input type="Hidden" name="programid" value="#url.programid#">
				</cfif>
			</cfif>
			</cfoutput>
</form>

</DIV>

<script>
	function changeReportUOM() {
		document.all.frmChangeReportUOM.ReportUOM.value = document.all.selReportUOM.value;
		document.all.frmChangeReportUOM.ReportBBDetail.value = document.all.selReportBBDetail.value;
		document.all.frmChangeReportUOM.ReportType.value = document.all.selReportType.value;
		//document.all.frmChangeReportUOM.submit();
	}
	
	function showAgreementForm() {
		
		var DivRef = document.getElementById('agreementForm');
		var IfrRef = document.getElementById('popupHelper');

		
		screenParts = 8;
		tempLeft = 	(parseInt(screen.width)/screenParts);
		tempWidth = (parseInt(screen.width)/screenParts) * (screenParts-2);
		
		screenParts = 10;
		tempHeight = (parseInt(screen.height-150)/screenParts) * (screenParts-3);
		tempTop = 20
		
		
		DivRef.style.left = tempLeft;
		DivRef.style.width = tempWidth;
		DivRef.style.height = tempHeight;
		DivRef.style.top = tempTop;
		DivRef.style.visibility ='visible';

		IfrRef.style.left = tempLeft;
		IfrRef.style.width = tempWidth;
		IfrRef.style.height = tempHeight;
		IfrRef.style.top = tempTop;
		IfrRef.style.display ='block';		
		DivRef.style.zIndex = DivRef.style.zIndex + 1;
		}
		
		function hideAgreementForm() {
			var DivRef = document.getElementById('agreementForm');
			var IfrRef = document.getElementById('popupHelper');
			IfrRef.style.display ='none';
			DivRef.style.visibility ='hidden';
			document.all.I_Agree_ChkBx.checked = false;
		}
</script>


<cfparam name="url.programid" default="">
<cfoutput>
<form action="generate_report.cfm" method="get" name="frmChangeReportUOM">
	<input type="Hidden" name="state" value="#url.state#">
	<input type="Hidden" name="county" value="#url.county#">
	<input type="Hidden" name="operator" value="#url.operator#">
	<input type="Hidden" name="distributor" value="#url.distributor#">
	<input type="Hidden" name="report_filename" value="#url.report_filename#">
	<input type="Hidden" name="final_destination" value="#url.final_destination#">
	<input type="Hidden" name="report_number" value="#url.report_number#">
	<input type="Hidden" name="ReportUOM" value="#form.thisReportUOM#">
	<input type="Hidden" name="ReportBBDetail" value="#url.thisReportBBDetail#">
	<input type="Hidden" name="ReportType" value="#url.ReportType#">
	<input type="Hidden" name="programid" value="#url.programid#">
	<input type="Hidden" name="Distributor_ID" value="#url.Distributor_ID#">
	<input type="Hidden" name="AllOperators" value="#AllOperators#">
	<input type="hidden" name="SummaryExport" value="">
</form>

<script>
	function monthlyItemDetailSubmit(productID) {
		document.all.monthlyItemDetail.productID.value = productID;
		document.all.monthlyItemDetail.submit();
	}
</script>

</cfoutput>
 </cfsavecontent> 
 <cfelse>
 <cfinclude template="program_search.cfm">
</cfif>
<!--- <cfabort> --->
<cfif url.ReportType NEQ "export_to_excel" and url.SummaryExport neq "summaryexportexcel">
<cffile action="WRITE" file="#APPPATH#\#url.file#" output="#reportresults#" addnewline="Yes">

<BR>
<div align="center" style="color: Maroon; font-size: 18px;">Thank You</div>
<cfflush>

<cfsilent>
<CFSET end=gettickcount()>
<CFSET TotalTimeSeconds = (end-begin)/1000>

<cfif CheckForExistingReportTimeStats.recordcount EQ 0>
	<cfquery name="saveStats" datasource="#application.datasource#">
		INSERT INTO usdanoi_ReportStats
		(
		ReportTimeSec,
		ReprtSHowBillback,
		ReportUOM,
		ReportType
		<cfif url.state NEQ 0>, StateFips</cfif>
		<cfif url.county NEQ 0>, CountyFips</cfif>
		<cfif url.operator NEQ 0>, Operator_ID</cfif>
		)

		VALUES

		(
		'#TotalTimeSeconds#',
		'#url.thisReportBBDetail#',
		'#url.ReportUOM#',
		'#url.ReportType#'
		<cfif url.state NEQ 0>, '#url.State#'</cfif>
		<cfif url.county NEQ 0>, '#url.county#'</cfif>
		<cfif url.operator NEQ 0>, '#url.Operator#'</cfif>
		
		)
	</cfquery>
<cfelse>
	<cfquery name="updateStats" datasource="#application.datasource#">
		UPDATE usdanoi_ReportStats
			set 
			ReportTimeSec 		= '#TotalTimeSeconds#',
			ReprtSHowBillback	= '#url.thisReportBBDetail#',
			ReportUOM			= '#url.ReportUOM#',
			ReportType			= '#url.ReportType#'
			<cfif url.state NEQ 0>, StateFips = '#url.State#'</cfif>
			<cfif url.county NEQ 0>, CountyFips = '#url.county#'</cfif>
			<cfif url.operator NEQ 0>, Operator_ID = '#url.Operator#'</cfif>
		WHERE
			ReprtSHowBillback	= '#url.thisReportBBDetail#'
			AND
			ReportUOM			= '#url.ReportUOM#'
			AND
			ReportType			= '#url.ReportType#'
			<cfif url.state NEQ 0>AND StateFips = '#url.State#'<cfelse>AND StateFips IS NULL</cfif>
			<cfif url.county NEQ 0>AND CountyFips = '#url.county#'<CFELSE>AND CountyFips IS NULL</cfif>
			<cfif url.operator NEQ 0>AND Operator_ID = '#url.Operator#'<cfelse>AND Operator_ID IS NULL</cfif>
	</cfquery>
</cfif>
</cfsilent>

<cfoutput>
<script>
	window.location.href = '#url.final_destination#?File=#replace(url.file,"\", "/", "ALL")#';
</script>
</cfoutput>
</cfif>
</body>
</html>
<cfflush>


