<!DOCTYPE HTML>
<head>
<style>
.header
{
	font-weight: bold;
	font-size: 12px;
}
#tb0930 input {
	width: 90%;
}
form { margin:0; }
#act0940 a {
	margin:5px;
}
#datagrid td { vertical-align: top; }
td.wrap19 { word-wrap:break-word; }
</style>
<script>
function doSearchNow()
{
	document.DataForm.submit();
	return false;
}
</script>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
</head>

<body>
<cfset URL.PageTitle="Email Log">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>
<cfparam name="Form.DOSEARCH" default="0">
<cfparam name="URL.EmailFrom" default="">
<cfparam name="Form.Email_From" default="#URL.EmailFrom#">
<cfparam name="URL.EmailTo" default="">
<cfparam name="Form.Email_To" default="#URL.EmailTo#">
<cfparam name="URL.EmailSubject" default="">
<cfparam name="Form.Email_Subject" default="#URL.EmailSubject#">
<cfparam name="getEmails.recordcount" default="0">

<cfset mydatetime=now()>
<cfparam name="URL.EmailCreatedAfterDate" default="#DateFormat(now(), 'mm/dd/yyyy')#">
<cfparam name="Form.Email_Created_After_Date" default="#URL.EmailCreatedAfterDate#">
</cfoutput>

<CFPARAM NAME="SortBy" DEFAULT="Message_Log.Created_Date">
<CFPARAM NAME="Form.SortBy" DEFAULT="#SortBy#">
<CFPARAM NAME="URL.Sortorder" DEFAULT="DESC">
<CFPARAM NAME="Form.sortorder" DEFAULT="#URL.Sortorder#">
<CFPARAM NAME="SRCIMG" DEFAULT="/images/sort_desc.gif">
<!--- Dev Note: drachala; D29699: Email Log Updates  START
Added/Changed: Added this code, if user submit form with empty "Email Created After" field we will display emails of previous 7 days--->
<cfif len(Form.Email_Created_After_Date) EQ 0>
	<cfset Form.Email_Created_After_Date = #URL.EmailCreatedAfterDate#>
</cfif>
<!--- End Dev Note: drachala; D29669: Email Log Updates  --->
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="90%">
<LEGEND STYLE="font: bold 14px sans-serif; color: Blue;">Email Log</LEGEND>
	<FORM ACTION="Email_Log_Display.cfm" METHOD="post" NAME="DataForm" ID="DataForm">
	<table width="100%" CELLPADDING="1" CELLSPACING="0" border="0" style="table-layout:fixed" id="tb0930">
		<col width="19%">
		<col width="19%">
		<col width="20%">
		<col width="12%">
		<col width="30%">
		<TR>
			<TD>Email From:<br>
				<input type="text" Name="Email_From" value="<cfoutput>#Form.Email_From#</cfoutput>">
			</TD>
			<TD>Email To:<br>
				<input type="text" Name="Email_To" value="<cfoutput>#Form.Email_To#</cfoutput>">
			</TD>
			<TD>Email Subject:<br>
				<input type="text" Name="Email_Subject" value="<cfoutput>#Form.Email_Subject#</cfoutput>">
			</TD>
			<TD>Created After:<CF_SmallHelp
					width="320"
					displayShifyX = "-120"
					displayShifyY = "-75"
					imgPath="/images/help_small.gif"
					imgWidth="14"
					imgHeight="13"
					dropdownCheck="0">
				<center style="text-align:justify">
				By default, emails from today's date will display on the page.
				To search for emails from prior days, type a date (e.g. <cfoutput>#DateFormat(now(), 'mm/dd/yyyy')#</cfoutput>) into the Email Created Date field and then click [search emails].
				</center>
					</CF_SmallHelp><br>
				<input type="text" Name="Email_Created_After_Date" value="<cfoutput>#Form.Email_Created_After_Date#</cfoutput>">
			</TD>
			<TD VALIGN="bottom" id="act0940">
				<cfoutput>
				<a HREF="##" ONCLICK="javascript: return doSearchNow();">#application.util.string.actionLinkFormat( "search" )#</a>
				<a HREF="/settings/Email_Log_Display.cfm">#application.util.string.actionLinkFormat( "reset" )#</a>
				<a HREF="javascript:xls('#Form.Email_Created_After_Date#');">#application.util.string.actionLinkFormat( "create XL file" )#</a>
				</cfoutput>
			</TD>
		</TR>
	</table>
	<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	<INPUT TYPE="Hidden" NAME="sortorder" VALUE="DESC">
	</FORM>
</FIELDSET>

<cfif sortorder eq "desc">
	<cfset sortorder="asc">
	<cfset SRCIMG = "/images/sort_desc.gif">
<cfelse>
	<cfset sortorder="desc">
	<cfset SRCIMG = "/images/sort_asc.gif">
</cfif>

<cfquery name="getEmails" datasource="#application.datasource#">
    SELECT Message_Log.Created_Date
 	        ,Message_Log.Message_From
 	        ,convert(varchar(8000),Message_To) as Message_To
 	        ,Message_Log.Message_Subject
 	        ,Sent_Date
 	    FROM MESSAGE_LOG
	   WHERE Message_Log.deleted = 0
	     and Message_Log.Message_From like '%@%'
	     and Message_Log.Message_To like '%@%'
	     and Message_Log.Message_To not like '%>;%'
					<cfif Form.Email_From NEQ "">
						and	Message_Log.Message_From like '%#trim(Form.Email_From)#%'
					</cfif>
					<cfif Form.Email_To NEQ "">
						and	Message_Log.Message_To like '%#trim(Form.Email_To)#%'
					</cfif>
					<cfif Form.Email_Subject NEQ "">
						and	Message_Log.Message_Subject like '%#trim(Form.Email_Subject)#%'
					</cfif>
					<cfif Form.Email_Created_After_Date NEQ "">
					and	Message_Log.Created_Date >  '#Form.Email_Created_After_Date#'
					</cfif>
 		ORDER BY #Form.SortBy# #Form.sortorder#
</cfquery>

<cfif getEmails.recordcount GTE 2000>
	<br><center><FONT STYLE="font-size:11px;" ><B>Your query returned more than 2000 records. Please narrow your search.</B></FONT></center>
<cfelse>
<div id="dt0915">
<TABLE class="datagrid" id="datagrid" style="table-layout:fixed">
<col width="22%">
<col width="22%">
<col width="34%">
<col width="9%">
<col width="13%">
<THEAD>
	<TR>
	<cfoutput>
		<TH STYLE="font-size:11px;">From</TH>
		<TH  STYLE="font-size:11px;">To</TH>
		<TH  STYLE="font-size:11px;">Subject</TH>
		<TH STYLE="font-size:11px;" >Created</TH>
		<TH>Sort Created Date</TH><!--- D29699: Email Log Updates --->
		<TH  STYLE="font-size:11px;">Sent Date</TH>
		<TH>Sort Send Date</TH><!--- D29699: Email Log Updates  --->
	</cfoutput>
	</TR>
</THEAD>
<TBODY>
	<cfoutput query = "getEmails">
	<TR>
		<TD>#replace(Message_From,"BlacksmithApplicationsNotificationService", "BlacksmithApplications<br>NotificationService")#</TD>
		<TD class="wrap19">#replace( replace(Message_To,";", ";<br>","ALL"), ",", ",<br>", "all" )#</TD>
		<TD>#Message_Subject#</TD>
		<TD>#DateFormat(Created_Date, 'MM/DD/YYYY')#</TD>
		<td>#DateFormat(Created_Date, 'YYYYMMDD')#</td><!--- D29699: Email Log Updates  --->
		<TD>#DateFormat(Sent_Date, 'MM/DD/YYYY')#  #TimeFormat(Sent_Date, "HH:mm:ss")#</TD>
		<td>#DateFormat(Sent_Date, 'YYYYMMDD')#</td><!---D29699: Email Log Updates  --->
	</TR>
	</cfoutput>
</TBODY>
</TABLE>
</div>   <!--- id="dt0915"> --->


<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
$(function() {
	var grid = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": true
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'Rlrtip'
    ,"sScrollY": $(window).height()*60/100         <!--- datagrid height --->
    ,"aaSorting": [[ 4, "desc" ]] <!--- sort on group name column --->
		,"iDisplayLength": 100
		,"aLengthMenu": [ [100, 250, 500], [100, 250, 500] ]
		,"aoColumnDefs": [ { "aTargets":[3], "iDataSort":4 }, { "aTargets":[4], "bVisible":false }, { "aTargets":[5], "iDataSort":6 }, { "aTargets":[6], "bVisible":false } ]
  }).fnSetFilteringDelay();

	<!--- hovering background color switching --->
	$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
	$('input[name=Email_Created_After_Date]').datepicker();
});
</script>
</cfif>
<script>
function xls(fdate){
	window.open( "email_xls_download.cfm?fdate="+fdate);
}
</script>
</body>
</html>
