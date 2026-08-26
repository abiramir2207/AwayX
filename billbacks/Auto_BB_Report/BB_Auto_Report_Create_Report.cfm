<!---------------------------------------------------------------------------------------------------------------------
      File Name:  \billbacks\Auto_BB_Report\BB_Auto_Report_Create_Report.cfm
   Created Date:  ??
         Author:  ??
        Purpose:  Create/Copy Auto Pay

        Remarks:  2016 April: Enhanced auto pay ChrisN 48219
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="url.nav_index" default="">
<cfmodule template="/customTags/layout.cfm" layoutID="autoPay" selectedIndex="#nav_index#">     <!--- 48219 --->
<div style="margin-left:10px">
<SCRIPT SRC="/script/javascript/prototype/prototype.js"></SCRIPT>
<style type="text/css">
.colHead {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;

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
#save {
	margin-right: 15px;
}
</style>

 <!--- Will be defined for edit and copy --->
 <cfparam name="url.Report_ID"	default="">
 <cfparam name="url.Action"		default="create">
 <cfparam name="url.fx"			default="0">
 <cfparam name="url.FlexAppName"	default="AutoPayMain">
 <cfparam name="create_exception" default="0">

 <!--- used as values in form -- we be overwritten for edit and copy --->
 <cfparam name="Report_Title"	default= "">
 <cfparam name="Start_Date"		default="">
 <cfparam name="End_Date"		default="">
 <cfparam name="Program_List"	default="">

 <!--- Just in case params --->
 <cfparam name="SaveText"		default="save">

 <!--- Get data from report pass in, if any --->
 <cfif len(trim(url.Report_ID)) GT 0>
 		<cfset qGetReportInfo =  application.oBBReportGet.getReportInfo(url.Report_ID)>
		<cfset qGetReportPrograms = application.oBBReportGet.getReportPrograms(url.Report_ID)>

		<cfset Report_Title = qGetReportInfo.Report_Title>
		<cfset Start_Date 	= qGetReportInfo.Start_Date>
		<cfset End_Date		= qGetReportInfo.End_Date>
		<cfset Program_List = valuelist(qGetReportPrograms.Program_ID)>

 </cfif>

 <!--- Save button text varies depending on what action you're doing --->
 <cfswitch expression="#action#">
 	<cfcase value="create">
		<cfset SaveText = "save">
		<cfset Form_Action = "/billbacks/auto_bb_report/save_report.cfm">
	</cfcase>
	<cfcase value="edit">
		<cfset SaveText = "save changes">
		<cfset Form_Action = "/billbacks/auto_bb_report/save_changes.cfm">
	</cfcase>
	<cfcase value="copy">
		<cfset SaveText = "save copy">
		<cfset Form_Action = "/billbacks/auto_bb_report/save_report.cfm">
	</cfcase>
	<cfdefaultcase>
		<cfset SaveText = "save">
		<cfset Form_Action = "/billbacks/auto_bb_report/save_report.cfm">
	</cfdefaultcase>
 </cfswitch>


 <cfoutput>
<p>&nbsp</p>
 <form name="frmInsPayPeriod" action="#Form_Action#" method="post" format="html" >

 <input type="hidden" name="Report_ID" value="#url.Report_ID#">
 <input type="hidden" name="create_exception" value="#create_exception#">
 <input type="hidden" name="Save_Action" value="#url.Action#">

<table width="650" border="0" cellpadding="3" cellspacing="0">
	<tr>
		<td class="rowHead" colspan="2">
			Enter Auto Pay Report information: <cfif create_exception eq 1><img src="/images/help_small.gif" title="An exception report allows the user to select which distributors and/or invoices from the selected program to include in the auto pay report."/></cfif>
		</td>
	</tr>
	<tr>
		<td class="colHead">
			Title
		</td>
		<td class="colHead">
			<input type="text" name="Report_Title" size="35" maxlength="50" value="#Report_Title#">
		</td>
	</tr>
	<tr>
		<td class="colHead">
			Start Date&nbsp&nbsp
		</td>
		<td class="colHead">
			<cf_easydate FormName="frmInsPayPeriod"
				 			  FieldName="Start_Date"
				 			  Format="mm/dd/yyyy"
				 			  Default="#Start_Date#">
		</td>
		</tr>
	<tr>
		<td class="colHead">
			End Date&nbsp&nbsp&nbsp
		</td>
		<td class="colHead">
			<cf_easydate FormName="frmInsPayPeriod"
				 			  FieldName="End_Date"
				 			  Format="mm/dd/yyyy"
				 			  Default="#End_Date#">
		</td>
	</tr>

	<tr>
		<td class="colHead">
			Select Programs&nbsp&nbsp&nbsp
		</td>
		<td>
			<cfif create_exception eq 1>
			<cfset addProgLink = application.oBBReportGet.getActionLink(reportId	= 0,
					periodId	= 0,
					action		= 'addProgForException')
			/>
			<cfelse>
			<cfset addProgLink = application.oBBReportGet.getActionLink(reportId	= 0,
					periodId	= 0,
					action		= 'addProg')
			/>
			</cfif>
					
					<cfoutput>#addProgLink#</cfoutput>
			<!--- <span onmouseout="popUpTip(event,'tProgramLink');" onmouseover="popUpTip(event,'tProgramLink');">
				<img src="/images/help_small.gif" />
			 </span> --->
			<div id="tProgramLink" class="tip">
				Only Programs with at least one Auto Pay component will be available to import.  A components claim mechanic (payment type) determines whether it is auto pay or not.
			</div>
			<input type="hidden" name="Program_List" value="#Program_List#" id="Program_List">
			<div name="ProgramDisplay" id="ProgramDisplay"></div>
		</td>
	</tr>


	<!--- Needed for program search --->
	<input type="hidden" name="FilterSearchPrograms" value="" />
	<input type="hidden" name="FilterType" value="" />
	<input type="hidden" name="FilterDataList" value="" />
	<input type="hidden" name="fx" value="#url.fx#" />
	<input type="hidden" name="FlexAppName" value="#url.FlexAppName#" />

	<tr><td  class="colHead" colspan="2">
		<!--- <input type="button" name="Save" label="Save" value=" #SaveText# " Onclick="saveData();" > --->
		 
			<div id="saveLink" style="display:block; width:60px; float:left; margin:2px;">
				<a href="##" id="save" onclick="saveData();this.disabled=true;">#application.util.string.actionLinkFormat2("save")#</a>
			</div>
			<div id="saveLinkProcessing" style="display:none; width:100px; float:left; margin:2px;vertical-align:text-top;">
				<font color="grey" style="font-size:12px;vertical-align:text-top;"><img src="/images/loading_red.gif">  processing...</font>
			</div>
			<div style="width:60px; float:left; margin:2px;">
				<a href="##" onclick="location.href='/billbacks/auto_bb_report/bb_auto_report_view.cfm'">#application.util.string.actionLinkFormat2("cancel")#</a>
			</div>
	</td></tr>

</table>
</form>
</cfoutput>

<script>

function trim(sStr)
{
	return sStr.replace(/^\s*/ig, "").replace(/\s*$/ig, "");
}

<!--- Show the programs if there are some already saved--->
		<cfif len(trim(Program_List)) GT 0>
			<cfoutput>
				saveProgramAction("#Program_List#","#Report_ID#");
			</cfoutput>
		</cfif>


function saveProgramAction(Program_List,Report_ID)
{
	if( ! Report_ID > 0 ){
		Report_ID = 0;
	}

	<cfif create_exception eq 1>
	new Ajax.Updater($('ProgramDisplay'), '/Billbacks/Auto_BB_Report/selected_programs.cfm', {parameters: {ProgramList: Program_List, Start_Date: document.frmInsPayPeriod.Start_Date.value, End_Date: document.frmInsPayPeriod.End_Date.value, ReportID: Report_ID, CreateException: 1}});
	<cfelse>
	new Ajax.Updater($('ProgramDisplay'), '/Billbacks/Auto_BB_Report/selected_programs.cfm', {parameters: {ProgramList: Program_List, CreateException: 0}});
	</cfif>
	
	return false;
}

function saveData()
{

	var actionFrm = document.frmInsPayPeriod;


	<!--- Title --->
	if (trim(actionFrm.Report_Title.value) == "")
	{
		alert("Please provide a report title");
		return;
	}

	<!--- Start date --->
	if (trim(actionFrm.Start_Date.value) == "")
	{
		alert("Please enter a valid start date");
		return;
	}

		var Date1 = new Date(actionFrm.Start_Date.value);
		var Date2 = new Date(actionFrm.End_Date.value);
		var Date3 = new Date();
		var date1_ms = Date1.getTime()
		var date2_ms = Date2.getTime()
		var date3_ms = Date3.getTime()


		if(date1_ms<= date2_ms & date2_ms <= date3_ms)
		{

		}
		else
		{
			alert("Start and End Dates must be in the past and start (" + actionFrm.Start_Date.value + ") must be before end (" + actionFrm.End_Date.value + ")." );
			return false;
		}


	<!--- End date --->
	if (trim(actionFrm.End_Date.value) == "" )
		{
			alert("Please enter a valid end date");
			return false;
		}
	<!--- Programs --->
	if (trim(actionFrm.Program_List.value) == "" )
		{
			alert("Please select at least one program for this report");
			return false;
		}
	//set hidden form fields and submit
	document.getElementById('saveLink').style.display='none';
	document.getElementById('saveLinkProcessing').style.display='block';
	
	actionFrm.submit();
	return false;
}


function SearchPrograms(Billback_ID,reportID,singleSearch)
  {
  NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=frmInsPayPeriod&fieldname=Program_List&selectMultiResultOverRide=1&SELECTSINGLESEARCHRESULTONLY="+ singleSearch + "&Start_Date=" + document.frmInsPayPeriod.Start_Date.value + "&End_Date=" + document.frmInsPayPeriod.End_Date.value + "&Billback_ID=" + Billback_ID + "&AutoPayFilter=1&ActiveWithinSpan=1", "programswindow", 1010, 800, "yes", "yes");
  }

  // alert(window.opener.sayHi());
</script>
</div>
</cfmodule>
