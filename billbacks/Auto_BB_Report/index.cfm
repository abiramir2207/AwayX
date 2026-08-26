<!DOCTYPE HTML>
<html>
<head>
</head>
<body>
<!---
XXXX  This is the maintenance area for Auto Generated Billbacks.
XXXX  Reports go through different statuses: BB_Auto_Report.status 1 = Scheduled to Run report; 2 = Recalc; 3 = RFA; 4= approved
XXXX
XXXX
XXXX
--->
<cfparam name="url.report" default="">

<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/prototype/prototype.js, /script/tTip.js">

<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
<style type="text/css">
.colHead {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	padding-left: 5px;
}
.rowHead {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	color: #000099;
	text-align: left;
	border-bottom-width: thin;
	border-bottom-style: solid;
	border-bottom-color: #990000;
	background-color: #ffce84;
	padding-left: 5px;
}
 td {
	border-top-width: 1px;
	border-right-width: 1px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-top-style: none;
	border-right-style: solid;
	border-bottom-style: solid;
	border-left-style: none;
}
table {
	border-top-width: 1px;
	border-right-width: 1px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-top-style: solid;
	border-right-style: none;
	border-bottom-style: none;
	border-left-style: solid;
}

.NoBorder {
	border-top-style: none;
	border-right-style: none;
	border-bottom-style: none;
	border-left-style: none;
}
.Grayed
	{
		color: 				gray;
		font-family:		Arial;
		font-size :			11px;
	}
</style>

<script>
function start(){
	disabledImageZone = document.createElement('div');
	disabledImageZone.setAttribute('id', 'createLoading');
	disabledImageZone.style.position = "absolute";
	disabledImageZone.style.zIndex = "1000";
	disabledImageZone.style.left = "0px";
	disabledImageZone.style.top = "0px";
	disabledImageZone.style.width = "100%";
	disabledImageZone.style.height = "100%";
	var imageZone = document.createElement('img');
	imageZone.setAttribute('id','imageZone');
	imageZone.setAttribute('src','/images/ajax-loader_red.gif');
	imageZone.style.position = "absolute";
	imageZone.style.top = "170px";
	//imageZone.style.right = "15px";
	imageZone.style.left = "45px";
	disabledImageZone.appendChild(imageZone);
	document.body.appendChild(disabledImageZone);
	disabledImageZone.style.visibility = 'hidden';//visible
	}

function CellOn(CellName)
		{
			eval("CellName.bgColor = '#EAFFEA'")
		}

function CellOff(CellName)
		{
			eval("CellName.bgColor = '#FFFFFF'")
		}
function lockLinks(){
			document.all.frm_BB_Auto_Report.process.value = '1';
			DisableEnableLinks(true);
		}
function unLockLinks(){
			document.all.frm_BB_Auto_Report.process.value = '0';
			DisableEnableLinks(false);
		}

function DisableEnableLinks(xHow){
  objLinks = document.links;
  for (i = 0; i < objLinks.length; i++) {
  		disableEnableAnchor(objLinks[i], xHow);
		}
}

String.prototype.getFuncBody = function(){
  var str=this.toString();
  str=str.replace(/[^{]+{/,"");
  str=str.substring(0,str.length-1);
  str = str.replace(/\n/gi,"");
  if(!str.match(/\(.*\)/gi))str += ")";
  return str;
}

function copyReport(reportId)
{
	document.location = "/billbacks/Auto_BB_Report/index.cfm?action=copy&disp=CreatePeriod&Report_ID=" + reportId;
}

function editReport(reportId)
{
	document.location = "/billbacks/Auto_BB_Report/index.cfm?action=edit&disp=CreatePeriod&Report_ID=" + reportId;
}


 function runReport(Report)
 {
 	lockLinks();
	disabledImageZone.style.visibility = 'visible';
	window.location.href = '/billbacks/auto_bb_report/index.cfm?del=0&runall=1&Report=' + Report;
 }
</script>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm" />
<cfparam name="URL.disp" default="view" />
<cfparam name="URL.Action" default="" />
<cfparam name="URL.runAll" default="0" />
<cfparam name="URL.Lck" default="-1" />
<cfparam name="URL.Del" default="0" />
<cfparam name="URL.PageTitle" default="PAYABLES: Auto Pay Report Maintenance" />
<!--- For Detail View Form Submits --->
<cfparam name="FORM.Search_String" default="" />
<!--- For Detail View Form Submits --->
<!--- For View Form Submits --->
<cfparam name="FORM.action" default="" />
<cfparam name="FORM.reportId" default="" />
<cfparam name="FORM.userId" default="" />
<cfparam name="approveResult" default="" />
<cfparam name="deleteResult" default="" />
<!--- For View Form Submits --->

<cfif isdefined("Form.Disp")><cfset URL.Disp = Form.Disp /></cfif>
<cfif isdefined("Form.Report")><cfset URL.Report = Form.Report /></cfif>

<!--- Initialize Main Objects --->

<!--- <cfif NOT structKeyExists(application,"oBBReportGet")>

<!--- BJF: If you are developing and make a change to a .cfc you need to comment out the cfif structkeyexists in order to see your changes --->
<!--- <cfif NOT structKeyExists(application,"oBBReportGet")>  --->

	<cfset application.oBBReportAjaxCaller = CreateObject("component","components.Billback.BBAutoReportAjaxCaller").init() />
	<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
	<cfset application.oBBReportUpdate = CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
	<cfset application.oBBReportPeriod = CreateObject("component","components.Billback.BB_Auto_Report_Period") />
	<cfset application.oBBReportPeriodGateway = CreateObject("component","components.Billback.BB_Auto_Report_PeriodGateway") />

</cfif> --->
<!---<cfif NOT structKeyExists(application,"oBBReportGet")>--->

<!---
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportAjaxCaller",name="BBReportAjaxCaller",bReload= 1).init() />
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportGet",name="BBReportGet",bReload= 1).init() />
	<cfset application.oController.getObject(path="components.Billback.BB_Auto_Report_Period",name="BBReportPeriod",bReload= 1) />
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportUpdate",name="BBReportUpdate",bReload= 1).init() />

 --->

	<!--- <cfset application.oController.getObject("component","components.Billback.BB_Auto_Report_PeriodGateway") /> --->
<!---</cfif>--->

<!--- Initialize AJAX objects --->
<cfmodule template="/CustomTags/wddxAjax/wddxAjax.cfm" ajaxComponent="components.Billback.BBAutoReportAjaxCaller" className="autoPay" >

<!--- START
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Process Form Submits
	* frmInsPayPeriod is the Form for creating new pay periods
	* Only for Manually Configured Auto Pay app setting
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
START --->

<!--- save is now moved to the save_report.cfm page --->
<cfif Form.action EQ "approve">
	<cfscript>
		argArray = arrayNew(1);
		argArray[1] = form.reportID;
		argArray[2] = form.userId;
		approveResult = application.oBBReportAjaxCaller.approveReportCaller(argArray);
	</cfscript>
<cfelseif Form.action EQ "deleteReport">
	<cfscript>
		argArray = arrayNew(1);
		argArray[1] = form.reportID;
		argArray[2] = form.periodId;
		argArray[3] = form.userId;
		deleteResult = application.oBBReportAjaxCaller.deleteReportCaller(argArray);
	</cfscript>
</cfif>

<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
END Process Form Submits END
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->

<!--- Set some variables used to get available report actions --->
<cfset currPeriod	= application.oBBReportGet.getCurrentPeriod() />

<!--- Lock/Unlock the report --->
<cfif URL.Lck EQ 1><!--- lockit and return status--->
	<cfset Locked = application.oBBReportUpdate.lockReport(request.accessStructure.User_Id,1) />
<cfelseif URL.Lck EQ 0><!--- Unlockit --->
	<cfset Locked = application.oBBReportUpdate.lockReport(request.accessStructure.User_Id,0) />
<cfelse><!---  get lock status --->
	<cfset Locked = application.oBBReportGet.getReportLock(request.accessStructure.User_Id) />
</cfif>

<!--- Do I have the report locked? --->
<cfset variables.lockedByMe = application.oBBReportGet.getReportLockByMe(request.accessStructure.User_Id) />
<cfset reportProcessing 	= application.oBBReportGet.getReportProcessingFlag() />

<!--- <cfset createReportAction = "" />
<cfif qGetOpenPeriod.recordcount GT 0>
	<cfset createReportAction = application.oBBReportGet.getAction(reportID = qGetOpenPeriod.BB_Auto_Report_id,
											periodId	= qGetOpenPeriod.bb_auto_report_period_id,
											status		= qGetOpenPeriod.status,
											endDate		= qGetOpenPeriod.end_date,
											currPeriod	= currPeriod,
											pause		= qGetOpenPeriod.Pause_Schedule) />
</cfif> --->

<!--- This is the main Auto Process.  IN dev we let the user trigger the process from the app --->
<cfif URL.runAll EQ 1>
	<cfif len(trim(Report)) GT 0> <!--- Run 1 report --->
			<cfset runNow = application.oBBReportUpdate.runBBAutoCreate(reportID	= Report) />

	<cfelse> <!--- Run all reports --->
			 <cfset runNow = application.oBBReportUpdate.runBBAutoCreate() />
	 </cfif>
</cfif>
<!---<body onload="start();">--->
<!--- <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"> --->



<FORM name="frm_BB_Auto_Report" action="/billbacks/auto_bb_report/index.cfm" method="post" >
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<input type="hidden" name="process" value="<cfoutput>#reportProcessing#</cfoutput>" />
<input type="hidden" name="Program_List" value="" />
<input type="hidden" name="FilterSearchPrograms" value="" />
<input type="hidden" name="FilterType" value="" />
<input type="hidden" name="FilterDataList" value="" />
<input type="hidden" name="curentReport" value="0" />
<input type="hidden" name="action" value="" />
</FORM>
<cfif reportProcessing EQ 0>
	<cfswitch expression="#URL.Disp#">
		<cfcase value="view">
		</cfcase>
		<cfcase value="detail">
			<cfinclude template="BB_Auto_Report_Details.cfm" />
		</cfcase>
		<cfcase value="ExpView">
			<cfinclude template="BB_Auto_Report_Export_Viewer.cfm" />
		</cfcase>
		<cfcase value="CreatePeriod">
			<cfinclude template="BB_Auto_Report_Create_Report.cfm" />
		</cfcase>
		<!---D35392: GM Pullback Log entries --->
		<cfcase value="ApplyDeviations">
			<cfinclude template="/ReportWriter/apply_deviations.cfm" />
		</cfcase>
	</cfswitch>
<cfelse>
	<cfswitch expression="#URL.Disp#">
		<cfcase value="detail">
			<cfinclude template="BB_Auto_Report_Details.cfm" />
		</cfcase>
		<cfdefaultcase>
			<cfset tmp = application.oBBReportUpdate.populatePeriods()>
			<cfinclude template="BB_Auto_Report_View.cfm" />
		</cfdefaultcase>
	</cfswitch>
</cfif>

<script>
start();
</script>
<cfinclude template="/common_files/focus.cfm">   <!--- 48219 --->
</body>
</html>