<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<style type="text/css">
.dataTables_filter {display: none; }
select  	{width: 145px; font-size: 11px; }
</style>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />

<cfparam name="ShowDetails" default="0">
<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFPARAM NAME="Form.DOSEARCH" DEFAULT="0">
<cfset ListofWorkRequests = valuelist(qGetCompRebates.Work_Request_ID)>

<CFPARAM NAME="Form.Request_Desc" default="">
<CFPARAM NAME="Form.Request_Type" DEFAULT="0">
<CFPARAM NAME="Form.App_Area" DEFAULT="0">
<CFPARAM NAME="Form.Client_Priority" DEFAULT="0">
<CFPARAM NAME="Form.Created_Since_Date" DEFAULT="">

<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="90%">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">request search</LEGEND>
<table width="880px" CELLPADDING="1" CELLSPACING="0" >
	<TR>
		<TD valign="bottom"><!--- Request --->
			<CF_SmallHelp
					width="250"
					displayShifyX = "-20"
					imgPath="/images/help_small.gif"
					imgWidth="14"
					imgHeight="13"
					dropdownCheck="0"
					>
					<center>Search Request #, Title and Reference #.</center>
			</CF_SmallHelp>
			<span ID="searchItemLabel">Keyword</span>
		</TD>
		<TD valign="bottom"><!--- Request Type --->
			<span ID="searchItemLabel">Type</span>
		</TD>
		<TD valign="bottom"><!--- App area --->
			<span ID="searchItemLabel">Application Area</span>
		</TD>
		<TD valign="bottom"><!--- Priority --->
			<span ID="searchItemLabel">Priority</span>
		</TD>
		<TD valign="bottom"><!--- Item Status --->
			<CF_SmallHelp
				width="350"
				displayShifyX = "-200"
				imgPath="/images/help_small.gif"
				imgWidth="14"
				imgHeight="13"
				dropdownCheck="0"
				>
<font color=blue>Open</font>  Request is being reviewed by BA to ensure enough details have been provided by the client before any work begins.
<br><font color=blue>BA Review</font>  The request is an enhancement.  Before any work begins the following must be done:  specification document, client approval of specification document, client agreement of payment and terms.
<br><font color=blue>Complete</font>  Development work complete.  Note:  the work may not be internally tested or deployed to your environment yet.
<br><font color=blue>Decline</font>  Not a code issue.  Client requires explanation of how the feature works.
<br><font color=blue>DEV</font>  Request reviewed and has all necessary information.  Request is waiting to be assigned to development team.
<br><font color=blue>DEV ASGN</font>  Request is in development. 
<br><font color=blue>Duplicate</font>  This has already been reported and addressed in a prior label.  
<br><font color=blue>Next Service Pk</font>  Request is considered for our next service pack.
			</CF_SmallHelp>
			<span ID="searchItemLabel">Status</span>
		</TD>
		<TD valign="bottom"><!--- Built To --->
			<span ID="searchItemLabel">Built To</span>
		</TD>
		<TD valign="bottom" nowrap><!--- Created Since --->
			<span ID="searchItemLabel">Created Since (mm/dd/yyyy)</span>
		</TD>							
	</TR>
	<TR>
		<TD valign="top"><!--- Request --->
			<CFPARAM NAME="FORM.Request_Desc" DEFAULT="">
			<input type="text" Name="Request_Desc" value="<cfoutput>#form.Request_Desc#</cfoutput>">	
		</TD>
		<TD valign="top"><!--- Request Type --->
			<cfset useLakebaseForGetRequestTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForGetRequestTypes>
	<cftry>
		<cfset GetRequestTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"deleted" = "eq.0",
				"order" = "request_type.asc",
				"select" = "request_type"
			}), "request_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetRequestTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetRequestTypes>
<CFQUERY NAME="GetRequestTypes" datasource="#application.datasource#">
			SELECT DISTINCT Request_Type
			FROM Work_Request
			WHERE Deleted = 0
			ORDER BY Request_Type
			</CFQUERY>
</cfif>
			<CFPARAM NAME="FORM.Request_Type" DEFAULT="0">
			<SELECT NAME="Request_Type" >
				<OPTION VALUE="0">**ALL** Request Types</OPTION>
				<CFOUTPUT QUERY="GetRequestTypes">
						<OPTION VALUE="#trim(GetRequestTypes.Request_Type)#"#IIF(trim(FORM.Request_Type) EQ GetRequestTypes.Request_Type, DE(" SELECTED"), DE(""))#>#trim(GetRequestTypes.Request_Type)#</OPTION>
				</CFOUTPUT>
			</SELECT>	
		</TD>
		<TD valign="top"><!--- App area --->
			<cfset useLakebaseForGetAppAreas = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForGetAppAreas>
	<cftry>
		<cfset GetAppAreas = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"deleted" = "eq.0",
				"order" = "app_area.asc",
				"select" = "app_area"
			}), "app_area"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAppAreas = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAppAreas>
<CFQUERY NAME="GetAppAreas" datasource="#application.datasource#">
			SELECT DISTINCT App_Area
			FROM Work_Request
			WHERE Deleted = 0
			ORDER BY App_Area
			</CFQUERY>
</cfif>
			<CFPARAM NAME="FORM.App_Area" DEFAULT="0">
			<SELECT NAME="App_Area" >
				<OPTION VALUE="0">**ALL** Application Areas</OPTION>
				<CFOUTPUT QUERY="GetAppAreas">
				<OPTION VALUE="#trim(GetAppAreas.App_Area)#"#IIF(trim(FORM.App_Area) EQ trim(GetAppAreas.App_Area), DE(" SELECTED"), DE(""))#>#trim(GetAppAreas.App_Area)#</OPTION>
				</CFOUTPUT>
			</SELECT>		
		</TD>
		<TD valign="top"><!--- Priority --->
			<cfset useLakebaseForGetPriorities = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForGetPriorities>
	<cftry>
		<cfset GetPriorities = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"deleted" = "eq.0",
				"order" = "client_priority.asc",
				"select" = "client_priority"
			}), "client_priority"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPriorities = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPriorities>
<CFQUERY NAME="GetPriorities" datasource="#application.datasource#">
			SELECT DISTINCT Client_Priority
			FROM Work_Request
			WHERE Deleted = 0
			ORDER BY Client_Priority
			</CFQUERY>
</cfif>
			<CFPARAM NAME="FORM.Client_Priority" DEFAULT="0">
			<SELECT NAME="Client_Priority" >
				<OPTION VALUE="0">**ALL** Priorities</OPTION>
				<CFOUTPUT QUERY="GetPriorities">
				<OPTION VALUE="#trim(GetPriorities.Client_Priority)#"#IIF(trim(FORM.Client_Priority) EQ trim(GetPriorities.Client_Priority), DE(" SELECTED"), DE(""))#>#trim(GetPriorities.Client_Priority)#</OPTION>
				</CFOUTPUT>
			</SELECT>	
		</TD>
		<TD valign="top" ><!--- Item Status --->
			<cfset useLakebaseForGeItemStatuses = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("work_request")>
<cfif useLakebaseForGeItemStatuses>
	<cftry>
		<cfset GeItemStatuses = application.oLakebase.toQuery(
			application.oLakebase.selectRows("work_request", {
				"deleted" = "eq.0",
				"item_status" = "not.is.null",
				"order" = "item_status.asc",
				"select" = "item_status"
			}), "item_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGeItemStatuses = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGeItemStatuses>
<CFQUERY NAME="GeItemStatuses" datasource="#application.datasource#">
			SELECT DISTINCT Item_Status
			FROM Work_Request
			WHERE Deleted = 0
			and Item_Status is not NULL
			ORDER BY Item_Status
			</CFQUERY>
</cfif>
			<CFPARAM NAME="FORM.Item_Status" DEFAULT="0">
			<cfoutput><CFPARAM NAME="Item_status_selected" DEFAULT= #form.Item_status#></cfoutput>

			<SELECT NAME="Item_Status" class="filter" multiple="multiple" style="width: 160px;">
				<CFOUTPUT QUERY="GeItemStatuses">
					<cfif Item_status_selected NEQ 0>
						<cfset Item_status_selected ="">
						<cfloop index = "lElement" list = "#FORM.Item_Status#">
							<cfif lElement EQ GeItemStatuses.Item_Status>
								<cfset Item_status_selected ="selected">
							</cfif>
						</cfloop>
					</cfif>
						<OPTION VALUE="#trim(GeItemStatuses.Item_Status)#" #Item_status_selected#>#trim(GeItemStatuses.Item_Status)#</OPTION>
				</CFOUTPUT>
			</SELECT>	
		</TD>
		<TD valign="top" ><!--- Built To --->
			<CFPARAM NAME="FORM.Built_To" DEFAULT="0">
			<CFPARAM NAME="built_to_selected_1" DEFAULT="">
			<CFPARAM NAME="built_to_selected_2" DEFAULT="">
			<CFPARAM NAME="built_to_selected_3" DEFAULT="">
			<CFPARAM NAME="built_to_selected_4" DEFAULT="">
			<cfoutput><CFPARAM NAME="built_to_selected" DEFAULT= #form.Built_To#>
			<SELECT NAME="Built_To"  class="filter" multiple="multiple"  style="width: 185px;" >

				<cfif built_to_selected NEQ 0>
					<cfset built_to_selected ="">
					<cfloop index = "BuiltID" list = "#FORM.Built_To#">
						<cfif BuiltID EQ 1><cfset built_to_selected_1 ="selected"></cfif>
						<cfif BuiltID EQ 2><cfset built_to_selected_2 ="selected"></cfif>
						<cfif BuiltID EQ 3><cfset built_to_selected_3 ="selected"></cfif>
						<cfif BuiltID EQ 4><cfset built_to_selected_4 ="selected"></cfif>
					</cfloop>
				</cfif>
				<OPTION VALUE="1"  #built_to_selected_1#> Built To Production </OPTION>
				<OPTION VALUE="2"  #built_to_selected_2#> Built To Stage</OPTION>
				<OPTION VALUE="3"  #built_to_selected_3#> Not Built To Production</OPTION>
				<OPTION VALUE="4"  #built_to_selected_4#> Not Built To Stage</OPTION>
			</SELECT>
			</cfoutput>	
		</TD>		
		<TD valign="top" style="width:150px"><!--- Created Since --->
			<CF_EASYDATE 
				FORMNAME="DataForm" 
				FIELDNAME="Created_Since_Date" FORMAT="mm/dd/yyyy" 
				DEFAULT="#Form.Created_Since_Date#"  
			>
		</TD>
							
	</TR>
	<TR>
		<TD ALIGN="right" NOWRAP colspan="100%">
		<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
		<!--- &nbsp;&nbsp; --->
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search requests</a><FONT COLOR="#FF0000">]</FONT></B>
		<!---<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return reset_Form_Fields();">reset</a><FONT COLOR="#FF0000">]</FONT></B>--->
		<B><FONT COLOR="#FF0000">[</FONT><a href="/Settings/Work_Request/index.cfm" target="mainwindow">reset</a><FONT COLOR="#FF0000">]</FONT></B>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<CF_smallLink 
			title = "export results to XL" 
			url = "##"
			parameters = "onClick=""javascript: return ExportToXL();"""

		>
		</TD>
	</TR>
</table>		
	<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="<CFOUTPUT>#startrow#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="<CFOUTPUT>#frompage#</CFOUTPUT>">
	<br>


<!--- -------------------------Datatable----------------------------------------- --->
<cfif qGetCompRebates.recordcount GTE 1000>
	<br><center><FONT STYLE="font-size:11px;" ><B>Your query returned more than 1000 records. Please narrow your search.</B></FONT></center>
<cfelse>
<div id="datatable">
<table id="DistributorFamily" class="datagrid" name="wr" width="100%">
	<thead>
		<tr>
			<TH>Req #</TH>
			<TH>Title</TH>
			<TH>Application<br> Area</TH>
			<TH>Type</TH>		
			<TH>Status</TH>
			<TH>Reference #<br>Priority</TH>		
			<TH nowrap>Created By<br>Created Date</TH>		
			<TH>Built to Prd<br>Built to Stg</TH>
			<th>Documents</th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
		</tr>
	</thead>
	
	<tbody>
	<cfsetting enablecfoutputonly="true">
	<cfloop query="qGetCompRebates">
		<cfoutput><tr></cfoutput>
		<cfoutput><td><cfif #len(BA_Ticket_Number)# EQ 0>
			<CF_SmallHelp
				showImage = 0
				showText = "PND"
				showTextColor = "blue"
				width="250"
				displayShifyX = "-10"
				dropdownCheck="0"
				>
				Request ## is pending. Blacksmith is in the process of assigning a request ## to your record. Please wait 2-3 minutes, then refresh your page or come back later to check the request ##.
			</CF_SmallHelp>
			<cfelse>#BA_Ticket_Number#</cfif></td></cfoutput>
		<cfoutput><td>#left(trim(Work_Title), 50)#<Cfif len(trim(Work_Title)) GT 50>...</CFIF></td></cfoutput>
		<cfoutput><td>#App_Area#</td></cfoutput>
		<cfoutput><td nowrap>#Request_Type#</td></cfoutput>
		<cfoutput><td nowrap>#Item_Status#</td></cfoutput>
		<cfoutput><td>#Client_Reference_Number#<br>#Client_Priority#</td></cfoutput>
		<cfoutput><td nowrap>#Name_First# #Name_Last#<br>#DateFormat(Created_Date, 'MM/DD/YYYY')#</td></cfoutput>
		<cfoutput><td><cfif len(builtOnProd) GT 0>Yes:  #DateFormat(builtOnProd, "mm/dd/yyyy")# <cfelse> NO</cfif><br>
                      <cfif len(builtOnStage) GT 0>Yes:  #DateFormat(builtOnStage, "mm/dd/yyyy")#<cfelse> NO</cfif></td></cfoutput>
		<cfoutput><cfsilent>
		<cfquery name="DocumentsAssociated" datasource="#application.datasource#">
			SELECT count(Work_Request_Document_ID) AS DocCount FROM Work_Request_Document
			WHERE Work_Request_ID = '#Work_Request_ID#'
			AND Work_Request_Document.Deleted = 0
		</cfquery>
		</cfsilent>
		<td nowrap style="width:100px;">	
		<CF_smallLink 
			title = "documents" 
			url = "##"
			parameters = "onClick=""javascript: return documentWindow('#Work_Request_ID#');"""
		>
		<cfif DocumentsAssociated.DocCount GT 0><A href="##" onClick="javascript: return documentWindow('#Work_Request_ID#');"><img src="/images/doc.gif" border="0" title="#DocumentsAssociated.DocCount# document<cfif DocumentsAssociated.DocCount GT 1>s</cfif> associated"></A></cfif>&nbsp;</td></cfoutput>
		<cfoutput><td nowrap><a href="" onClick="JavaScript: return deleteComp('#Work_Request_ID#');"><img src="/images/no_small.gif" TITLE="Delete Work Request" BORDER="0"></a></td></cfoutput>
		<cfoutput><td style="display: none;">#Release_Notes#</td></cfoutput>
		<cfoutput><td style="display: none;">#NotesSpace#</td></cfoutput>
		<cfoutput><td style="display: none;">
		<CF_smallLink 
			title = "edit" 
			url = "##"
			parameters = "onClick=""javascript: return NotesPopup('#Work_Request_ID#','#Form.DOSEARCH#');"""
		></td></cfoutput>
		<cfoutput><td style="display: none;">Updated by:</strong><cfif FindNoCase("bigredflame.com", #User_email#)> Blacksmith <cfelse>#UpdatedBy#</cfif> &nbsp;&nbsp; #dateformat(Updated_On, 'mm/dd/yyyy')# #timeformat(Updated_On, 'h:s tt')#<br>URL of the environment: #URLEnvironment#;  Prog ID, BB ID, DD ID, Interface Name: #ProgBBDDIDs#;  User Name / Password / Position / Profile related to issue: #UserInfo#;  Error Event Number: #ErrorEvent#;  What is the issue?  1. What is current behavior? #CurrentBehavior#; 2. What is the expected behavior?#ExpectedBehavior#</td></cfoutput>
		<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
</tbody>
</table>
</div>   <!---datatable--->
</cfif>

<!--- ------------------------------------------------------------------------------ --->
<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js"></script>
<script type="text/javascript" src="/Script/javascript/multiselect.minWidth50.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">

var oTable;
function fnFormatDetails ( oTable, nTr )
{
	var aData = oTable.fnGetData( nTr );
	var sOut = '<table bgcolor="white"  class="datagrid" width="100%">';
	sOut += '<tr><td>'+aData[14]+'&nbsp;</td></tr>';
	sOut += '<tr bgcolor="#dddddd"><td>Notes: '+aData[13]+'</td></tr>';
	sOut += '<tr bgcolor="white"><td>'+aData[12]+'&nbsp;</td></tr>';
	sOut += '<tr bgcolor="#dddddd"><td>Release Notes:</td></tr>';
	sOut += '<tr><td>'+aData[11]+'&nbsp;</td></tr>';
	sOut += '</table>';
	return sOut;
}

<!---adjust main fieldset width when user's resolution is too low--->
$('#mainfieldset').css('width', ($(window).width() <= 700) ? "600px" : "98%");

var column_sizes = ["2%", "20%","12%","16%","10%","10%","10%","10%","5%","0%","0%"];

$(document).ready(function() {
	var nCloneTh = document.createElement( 'th' );
	var nCloneTd = document.createElement( 'td' );
	nCloneTh.innerHTML = 'Details';
	nCloneTd.innerHTML = '<img src="/images/plus4.gif"> show details';
	nCloneTd.className = "center";
	
	$('#DistributorFamily thead tr').each( function () {
		this.insertBefore( nCloneTh, getChildNodes(this)[9] );
	} );
	
	$('#DistributorFamily tbody tr').each( function () {
		this.insertBefore(  nCloneTd.cloneNode( true ), getChildNodes(this)[9] );
	} );
	
	var oTable = $('#DistributorFamily').dataTable( {
		"aoColumnDefs": [
			{ "bSortable": false, "aTargets": [ 8 ] }
			,{ "bSortable": false, "aTargets": [ 9 ] }
			,{ "bSortable": false, "aTargets": [ 10 ] }
			,{ "bVisible": false, "aTargets": [ 11 ] }
			,{ "bVisible": false, "aTargets": [ 12 ] }
			,{ "bVisible": false, "aTargets": [ 13 ] }
			,{ "bVisible": false, "aTargets": [ 14 ] }
		],
		"aaSorting": [[0, 'desc']]
	});

	$('#DistributorFamily tbody td:nth-child(10) img').live('click', function () {
		var nTr = this.parentNode.parentNode;
		if ( this.src.match('minus4') )
		{
			this.src = "/images/plus4.gif";
			$('td:eq(9)', nTr).html('<img src="/images/plus4.gif"/> show details' ); 
			oTable.fnClose( nTr );
		}
		else
		{
			this.src = "/images/minus4.gif";
			$('td:eq(9)', nTr).html('<img src="/images/minus4.gif" /> hide details' ); 
			oTable.fnOpen( nTr, fnFormatDetails(oTable, nTr), 'details' );
		}
	} );
} );

/* multiple select handling */
$("select.filter").each( function() {
	var $this = $(this), selected_list = 1,  select_name = $this.attr('name');  
	selected_list = 1;    
	$this.multiselect({ selectedList:selected_list
		,checkAllText:"", uncheckAllText:""
		,checkAll:function()   { $(this).trigger('change'); }  
		,uncheckAll:function() { $(this).trigger('change'); }  
	});
});	
//$("select.filter").multiselectfilter();     /* enable find inside dropdowns with many options */
</script>


