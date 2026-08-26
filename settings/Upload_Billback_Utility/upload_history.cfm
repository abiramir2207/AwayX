<!---
       Name:          upload_history.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:
--->

<!--- Todo: Get History on when this was updated --->
<cfparam name="FORM.showSearchForm"	default="0" />
<cfparam name="FORM.Upload_Type"	default="0" />
<cfparam name="FORM.Uploaded_User"	default="0" />
<cfparam name="FORM.Uploaded_Date"	default="" />
<cfparam name="FORM.BB_Code"	default="" />
<cfparam name="FORM.BB_Reference"	default="" />
<cfparam name="FORM.Vendor_ID"	default="" />
<cfparam name="FORM.File_Name"	default="" />
<cfparam name="FORM.BB_Upload_Status"	default="0" />
<cfparam name="FORM.lnkClick"	default="0" />
<cfparam name="FORM.payable_list" 	default="">
<cfparam name="FORM.Reference_Number_list" 	default="">
<cfparam name="FORM.match_type" default="">

<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
<cfset stBBLabels = objSettingsService.getBBLabels()>

<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset getUniqueMonthDay = uploadUtility.getUniqueMonthDay() />

<cfset vars = structnew()>
<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnvariable="vars.appSettings">
<!---30227 when app settings “3rd party bb upload”  = Instill and “BB Approve Expected Rate Less Tolerance” = ON turn on audit report--->
<cfset vars.audit_rpt_on = ( vars.appSettings.ThirdPartyBbUpload eq "1" and vars.appSettings.Bb_Approve_Expected_Rate_Less_Tolerance eq "1" )>

<!--- The above query populates the "DATE" dropdown below. Here I am taking the first record from the query which will always show up
	as the selected record whenever this page is loaded and so the resultset will always return the selected record from the
	"DATE" dropdown by default (on the initial page load). I could not use "Body Onload" due to the different "include" files.
--->
<cfif getUniqueMonthDay.Recordcount GT 0>
<cfparam name="Form.UploadMonthYear" default="#CreateDate(getUniqueMonthDay.ComboYear, getUniqueMonthDay.ComboMonth, '01')#">
<cfelse>
<!--- Today's date --->
<cfparam name="Form.UploadMonthYear" default="#now()#">
</cfif>

<cfparam name="Form.SelectedMonthYear" default="#dateFormat(UploadMonthYear,"yyyymmmm")#">
<cfset transactions = uploadUtility.getHistoricUploadLog(datepart("m",Form.UploadMonthYear),datepart("yyyy",Form.UploadMonthYear),FORM) />
<cfset qAllUploadingUsers = uploadUtility.getAllUploadingUsers() />

<br>
<form name="frmGetDate" id="frmGetDate" action="index.cfm?showtab=3" method="post">
<input type="hidden" name="showSearchForm" value="1" />

<cfoutput>
<input type="hidden" name="lnkClick" value="#form.lnkClick#" />
<input type="hidden" name="payable_list" value="#form.payable_list#">
<input type="hidden" name="Reference_Number_list" value="#form.Reference_Number_list#">
<input type="hidden" name="match_type" value="#form.match_type#">


	<table border="0">
		<tr>
			<td>
				<span class="subheading">Historic Upload Data</span>&nbsp;&nbsp;
			</td>
			<td>
				<select name="UploadMonthYear" id="UploadMonthYear"
					onchange="getHistory(this.value,'0')"
					>
					<cfif getUniqueMonthDay.Recordcount eq 0>
						<option value="">None</option>
					</cfif>
					<cfloop query="getUniqueMonthDay">
						<cfset x = CreateDate(getUniqueMonthDay.ComboYear, getUniqueMonthDay.ComboMonth, "01")>
						<option value="#x#" <cfif ComboText eq UploadMonthYear>selected</cfif>> #ComboText#</option>
					</cfloop>
				</select>
				<input type="hidden" name="showTab" value="3">
			</td>
		</tr>
	</table>				
	<br>
	<br>

<fieldset style="padding:8px; width: 98%; border: 1px solid Blue;">
				<legend><span style="font: bold 14px sans-serif; color: Red;">Upload History Search</span>
				<span style="font-weight:bold;color:red;">[</span><a href="##" id="UploadHistorySearch" style="font: bold 11px sans-serif;margin:2px;color:blue;font-weight:bold;" <cfif form.showSearchForm EQ 0>data-text-swap="show"<cfelse>data-text-swap="hide"</cfif>><cfif form.showSearchForm EQ 0>hide<cfelse>show</cfif></a><span style="font-weight:bold;color:red;">]</span>
				</legend>	
	<div name="UploadHistorySearchForm" id="UploadHistorySearchForm" border="1" style="border:0px solid ##666600;width:1000px; border-radius:5px; padding-top:10px;padding-right:5px;padding-bottom:10px;padding-left:5px;" >
		<table border = "0">  
			<tr>
				<td align="right">
					<nobr>&nbsp;&nbsp;<b>Uploaded By:</b></nobr>
				</td>
				<td>
					&nbsp;<select name="Uploaded_User" id="Uploaded_User" size="1" style="width:180px">
						<option value="0">Select User</option>
							<cfloop query="qAllUploadingUsers">
								<option value="#User_ID#" <cfif FORM.Uploaded_User EQ User_ID>selected</cfif>>#Name_First# #Name_Last#</option>
							</cfloop>
					</select>					
				</td>
				<td align="right">&nbsp;&nbsp;<b>Type:</b></td> 
				<td>
					<nobr>&nbsp;<select name="Upload_Type" id="Upload_Type" size="1" style="width:110px">
							<option value="0">Select a Type</option>
							<option value="2" <cfif FORM.Upload_Type EQ "2">selected</cfif>>Application</option>
							<option value="3" <cfif FORM.Upload_Type EQ "3">selected</cfif>>3rd Party</option>
						  </select>	</nobr>
				</td>
				
				
				<td align="right"> 
					<nobr>&nbsp;&nbsp;<b>#stBBLabels.Reference_Number#<!--- BB Reference --->:</b></nobr>
				</td>
				<td > 
					&nbsp;<input type="text" name="BB_Reference" style="width:90px" <cfif FORM.BB_Reference NEQ ''>value="#FORM.BB_Reference#"</cfif>><br>
				</td>
				<td align="right"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>#stBBLabels.Vendor#<!--- Vendor--->:</nobr></b> 
				</td>
				<td>
					&nbsp;<input type="text" name="Vendor_ID" style="width:120px" <cfif FORM.Vendor_ID NEQ ''>value="#FORM.Vendor_ID#"</cfif>>
				</td>
				
				<td></td>
			</tr>
			
			<tr>
			<td colspan="5">&nbsp;
			</td>
			<td>
				&nbsp;<FONT COLOR="Red">[</FONT><a href="##" onclick="popupCreatelist('Reference_Number')" title="create list of Reference numbers"> <b>create list</b> </a><FONT COLOR="Red">]</FONT><br><br>
			</td>
			</tr>
			
			<tr>
				<td align="right"> 
					<nobr>&nbsp;&nbsp;<b>File Name:</b> </nobr>
				</td>
				<td>
					<nobr>&nbsp;<input type="text" name="File_Name" style="width:180px" <cfif FORM.File_Name NEQ ''>value="#FORM.File_Name#"</cfif></nobr></td>
				
				<td align="right">
					<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Upload Date:</b></nobr>
				</td>
				<td>
					&nbsp;<input type="text" name="Uploaded_Date" style="width:100px"  class="date" <cfif FORM.Uploaded_Date NEQ ''>value="#FORM.Uploaded_Date#"</cfif>>
				</td>
				<td align="right">
					<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Payable ##:</b> </nobr>
				</td>
				<td>
					<nobr>&nbsp;<input type="text" name="BB_Code" style="width:100px" <cfif FORM.BB_Code NEQ ''>value="#FORM.BB_Code#"</cfif>></nobr>
				</td>
				<td align="right"> 
					<nobr>&nbsp;<b>Status:</b></nobr>
				</td>
				<td>
 					<nobr>
					&nbsp;
					<select name="BB_Upload_Status" id="BB_Upload_Status" size="1" style="width:150px">
							<option value="0">Select an Upload Status</option>
							<option value="Alias needs to be fixed" <cfif FORM.BB_Upload_Status EQ "Alias needs to be fixed">selected</cfif>>Alias needs to be fixed</option>
							<option value="Atleast One Source is Invalid" <cfif FORM.BB_Upload_Status EQ "Atleast One Source is Invalid">selected</cfif>> Atleast One Source is Invalid</option>
							<option value="Creation Complete" <cfif FORM.BB_Upload_Status EQ "Creation Complete">selected</cfif>>Creation Complete</option>
							<option value="Check for file FORMAT" <cfif FORM.BB_Upload_Status EQ "Check for file FORMAT">selected</cfif>>Check for file FORMAT</option>
							<option value="Validation Completed" <cfif FORM.BB_Upload_Status EQ "Validation Completed">selected</cfif>>Validation Completed</option>
							<option value="Validation Failed" <cfif FORM.BB_Upload_Status EQ "Validation Failed">selected</cfif>>Validation Failed</option>
						  </select>
				</nobr>
				</td>
				<td><nobr>&nbsp;<FONT COLOR="Red">[&nbsp;</FONT><a href="##" onclick="getHistory(this.value,'1')" title="Search the Upload history "> <b>Search</b> </a><FONT COLOR="Red">&nbsp;]</FONT></nobr></td>
				<td><nobr>&nbsp;<FONT COLOR="Red">[&nbsp;</FONT><a href="##" onclick="fnReset();" title="Search the Upload history "> <b>Reset</b> </a><FONT COLOR="Red">&nbsp;]</FONT></nobr></td>
				
			</tr>
			<tr>
				<td colspan="5">&nbsp;</td>
				<td>
					&nbsp;<FONT COLOR="Red">[</FONT><a href="##" onclick="popupCreatelist('BB_Code')" title="create list of Payable ##s"> <b>create list</b> </a><FONT COLOR="Red">]</FONT><br><br>
				</td>
				<td>&nbsp;</td>
			</tr>
		</table>
	</div>
</fieldset><br>
</cfoutput>	
</form>
<br>


<!--- Todo: Create Custom Tag for loading graphic. --->

<div id="loading" width="700px">
		<!--- <img align="center" src="/Images/Animation/images/progress.gif"> --->
<!--- script language="javascript">		
	show_loader( "LOADING, PLEASE WAIT...", 1000 );
</script --->
</div>


<!--- Todo: Create Custom Tag for Basic YUI Table --->



<script language="javascript" type="text/javascript">
	function viewdetails(id)
	{
		// window.location.href = 'index.cfm?show_tab=6&tab_title=Upload Detail&upload_id=' + id;
		window.open('upload_detail2.cfm?show_tab=6&tab_title=Upload Detail&upload_id=' + id ,null,"height=600,width=1000,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
	}

	function viewbillbacks(id,cnt,uploadTypeID)
	{
		if (cnt < 4000)
// 			window.location.href = 'index.cfm?show_tab=6&upload_id=' + id + '&tab_title=billbacks&upload_type_id=' + uploadTypeID;
window.open('generated_billbacks.cfm?show_tab=6&upload_id=' + id + '&tab_title=billbacks&upload_type_id=' + uploadTypeID ,null,"height=600,width=1000,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
		else
			window.open('billback_listing_printerfriendly.cfm?printable=1&upload_id=' + id + '&upload_type_id=' + uploadTypeID,null,"height=480,width=800,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=yes,location=no");

		return false;
	}
	
	function fnReset()
	{
	frmGetDate.Upload_Type.selectedIndex = 0;
	frmGetDate.Uploaded_User.selectedIndex = 0;
	frmGetDate.Uploaded_Date.value = '';
	frmGetDate.BB_Code.value = '';
	frmGetDate.BB_Reference.value = '';
	frmGetDate.Vendor_ID.value = '';
	frmGetDate.File_Name.value = '';
	frmGetDate.BB_Upload_Status.selectedIndex=0;
	frmGetDate.payable_list.value = '';
	frmGetDate.Reference_Number_list.value = '';	
	frmGetDate.match_type.value = '';
	
//		frmGetDate.Uploaded_User.options[frmGetDate.Uploaded_User.selectedIndex].value = '0';
		
	}
	
	function getHistory(d,clicked)
	{
		if (clicked == '1')
		{
			frmGetDate.lnkClick.value = '1';
			if (frmGetDate.Upload_Type.options[frmGetDate.Upload_Type.selectedIndex].value == '0' && 
				frmGetDate.Uploaded_User.options[frmGetDate.Uploaded_User.selectedIndex].value == '0' &&
				frmGetDate.Uploaded_Date.value == '' &&
				frmGetDate.BB_Code.value == '' &&
				frmGetDate.BB_Reference.value == '' &&
				frmGetDate.Vendor_ID.value == '' &&
				frmGetDate.File_Name.value == '' &&
				frmGetDate.BB_Upload_Status.options[frmGetDate.BB_Upload_Status.selectedIndex].value == '0')
				{	
					alert('Pick/Enter a criteria to search');
					return;   
				 }
		}
		else
		{
			frmGetDate.lnkClick.value = '0';
		}
		frmGetDate.submit();
		show_loader( "LOADING, PLEASE WAIT...", 1000 );
	}

	function viewHeader(fileName)
	{
		window.open("auditreport.cfm?fileName=" + fileName,"Header_Report", "height=480,width=800,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
	}

	function viewDetail(fileName)
	{
		window.open("auditreport.cfm?fileName=" + fileName,"Detail_Report", "height=480,width=800,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
	}
	
	function popupCreatelist(option)
	{
		frmGetDate.lnkClick.value = '1';
		if(option=='BB_Code')
		{
			frmGetDate.Reference_Number_list.value='';
			window.open('/common_files/createList2.cfm?parent=BB_Code', 'bb_search_create_list', "height=520,width=450,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
		}
		else if(option=='Reference_Number')
		{
			frmGetDate.payable_list.value='';
			window.open('/common_files/createList2.cfm?parent=Reference_Number', 'bb_search_create_list', "height=520,width=450,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
		}
	}
</script>

<div id="markup" style="display:none;">
		<table border="1" style="border-collapse:collapse" id="accounts">
		<thead>
		<tr>
			<td>ID</td>
			<td>Type</td>
			<td>Uploaded By</td>
			<td>Total Header Count</td>
			<td>Total Header Count Failed</td>
			<td>Total Header Count Success</td>
			<td>Total Detail Count</td>
			<td>Total Detail Count Failed</td>
			<td>Total Detail Count Success</td>
			<td>Files</td>
			<td>Date</td>
			<td>Status</td>
		</tr>
		</thead>
		<tbody>
		<cfoutput query="transactions">
			<cfset hdrFileName = "" />
			<cfset dtlFileName = "" />
			
			
		<tr style="border-bottom:1px solid silver;">
			<td>#Upload_ID#</td>
			<td>#Upload_Type#</td>
			<td>#user_code#</td>
			<td>#Total_Header_Count#</td>
			<td>#Total_Header_Count_Failed#</td>
			<td>#Total_Header_Count_loaded#</td>
			<td>#Total_Detail_Count#</td>
			<td>#Total_Detail_Count_Failed#</td>
			<td>#Total_Detail_Count_loaded#</td>
			<td><span title="#dateformat(upload_date,'mm/dd/yyyy')# #timeformat(upload_date,'hh:mm tt')#">#header_file_name#<cfif len(header_file_name) NEQ 0>, </cfif>#detail_file_name#</span></td>
			<td>#dateformat(upload_date,'mm/dd/yyyy')#</td>
			<td><a href="##" title="#upload_status#: click to view upload errors" onclick="viewdetails(#upload_id#);return false;">#upload_status#</a></td>
			<cfif (findnocase(upload_status,'creation complete') OR findnocase(upload_status,'Creation Complete - Partial'))>
				<td><a href="##" title="click to view associated billbacks"  onclick="return viewbillbacks(#upload_id#,#total_header_count#,#Upload_Type_ID#)">(view)</a></td>
			<cfelse>
				<td>&nbsp;</td>
			</cfif>
			<!---30227 added view header/detail audit report--->
			<cfif vars.audit_rpt_on>
				<cfquery name="getReportFileNames" datasource="#application.datasource#">
					SELECT 
						(SELECT TOP 1 Report_fileName FROM Billback_Upload_III_PH_Log WHERE  Upload_ID = #Upload_ID# AND Report_fileName IS NOT NULL) AS Header_Filename,
						(SELECT TOP 1 Report_fileName from Billback_Upload_III_PD_Log WHERE  Upload_ID = #Upload_ID# AND Report_fileName IS NOT NULL) AS Detail_Filename
				</cfquery>
				<cfif (isDefined("getReportFileNames.Header_Filename") AND isDefined("getReportFileNames.Detail_Filename"))>
					<cfset hdrFileName = getReportFileNames.Header_Filename />
					<cfset dtlFileName = getReportFileNames.Detail_Filename />
				</cfif>
				<!---audit report generated on the next day of the upload date--->
				<cfset vars.audit_rpt_date = dateformat(upload_date + 1, "mmddyyyy")>
				<!--- 48341 some functions in JQUERY conflicted with YAHOO   
				<td><a class="vhdr" href="##" id="#vars.audit_rpt_date#">view header</a><br/><a class="vdtl" href="##" id="#vars.audit_rpt_date#">view detail</a></td>
				--->
				<td>
					<a href="##" title="click to view header"  onclick="return viewHeader('#hdrFileName#')">view header</a><br/>
					<a href="##" title="click to view detail"  onclick="return viewDetail('#dtlFileName#')">view detail</a>
				</td>
			</cfif>     
			</tr></cfoutput>
		</tbody>
		</table>
</div>
<cfset jQueryUI.version = "1.8.23">
<cf_include files="/styles/css-loader.css">
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" language="JavaScript">
	YAHOO.example.enhanceFromMarkup = function() {

     var markup = YAHOO.util.Dom.get("markup");

	this.myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("accounts"));
	this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
	this.myDataSource.responseSchema = {
		fields: [
		{key:"rid", parser: YAHOO.util.DataSource.parseNumber},
	        {key:"uploadtype"},
	        {key:"uploadedby"},
	        {key:"totalheadercount", parser: YAHOO.util.DataSource.parseNumber},
	        {key:"totalheadercountfailed", parser: YAHOO.util.DataSource.parseNumber},
		{key:"totalheadercountsuccess", parser: YAHOO.util.DataSource.parseNumber} ,
		{key:"totaldetailcount", parser: YAHOO.util.DataSource.parseNumber} ,
		{key:"totaldetailcountfail", parser: YAHOO.util.DataSource.parseNumber} ,
		{key:"totaldetailcountsuccess", parser: YAHOO.util.DataSource.parseNumber} ,
		{key:"files"},
		{key:"date"} ,
		{key:"status"},
		{key:"thide"}
    <cfif vars.audit_rpt_on>,{key:"auditrpt"}</cfif>   <!---30227--->
		]
	}

	this.columnHeaders = [
	        {key:"rid",label:"ID",type:"number",sortable:true},
	        {key:"uploadtype",label:"Type",sortable:true},
	        {key:"uploadedby",label:"Uploaded By",sortable:true},
	        {key:"totalheadercount",label:"Total Header Count",type:"number",sortable:true},
	        {key:"totalheadercountfailed",label:"Total Header Count Failed",type:"number",sortable:true},
		{key:"totalheadercountsuccess",label:"Total Header Count Success",type:"number",sortable:true} ,
		{key:"totaldetailcount",label:"Total Detail Count",type:"number",sortable:true} ,
		{key:"totaldetailcountfail",label:"Total Detail Count Failed",type:"number",sortable:true} ,
		{key:"totaldetailcountsuccess",label:"Total Detail Count Success",type:"number",sortable:true} ,
		{key:"files",label:"Files",sortable:false},
		{key:"date",label:"Date",type:"date",sortable:true} ,
		{key:"status",label:"Status",type:"text",sortable:true},
		{key:"thide",label:"Action",sortable:false}
    <cfif vars.audit_rpt_on>,{key:"auditrpt",label:"Audit Report",sortable:false}</cfif>    <!---30227--->
    ];

	     // this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);
	   	 var oConfigs = {
		                         paginated:true,
		                         paginator: {
								 containers         : ['paging'], 
								 pageLinks: 25,
		                         rowsPerPage: 500,
		                         dropdownOptions: [500,1000],
								 template           : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink} {RowsPerPageDropdown}" 
		                         }
	                };



	     this.dataTable = new YAHOO.widget.DataTable(markup,this.columnHeaders,this.myDataSource,oConfigs);


	 document.all.loading.style.display = "none";
	 document.all.markup.style.display = "";
 	};

	YAHOO.util.Event.onAvailable("markup",YAHOO.example.enhanceFromMarkup,YAHOO.example.enhanceFromMarkup,true);
	
	$( "#UploadHistorySearch" ).click(function() {
  $( "#UploadHistorySearchForm" ).toggle();
  var el = $(this);
  if (el.text() == el.data("text-swap")) {
    el.text(el.data("text-original"));
  } else {
    el.data("text-original", el.text());
    el.text(el.data("text-swap"));
  }
});

 
$('input[name=Uploaded_Date]').datepicker();
 
</script>


 

<!--- 48341 rmoved below code as some functions in JQUERY conflicted with YAHOO   
<cfinclude template="/common_files/jQuery.cfm">

<script>
$('a.vhdr').click(function(e){
	e.preventDefault;
	NewWindow('/settings/upload_billback_utility/auditreport.cfm?' + 'fileprefix=Audit_Report_Header_' + $(this).prop('id'), 'auditreportheader', '900', '620', 'Yes', 'Yes' );
});
$('a.vdtl').click(function(e){
	e.preventDefault;
	NewWindow('/settings/upload_billback_utility/auditreport.cfm?' + 'fileprefix=Audit_Report_Detail_' + $(this).prop('id'), 'auditreportdetail', '900', '620', 'Yes', 'Yes' );
});
</script>
--->
