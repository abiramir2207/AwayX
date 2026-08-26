<!--- ------------------------------------------------------------------------------ 
     Template: \DEDUCTIONS\settings\3rdPartyUpload_DefaultPayeeShipTo.cfm
      Date:     
      Updated By:   
      Purpose:  
------------------------------------------------------------------------------ --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title></title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style type="text/css" media=screen>
.action { font-size: 8pt; font-weight:bold; margin:10px 0 10px 0; }
.action label { margin:0 10px 0 30px; }
.action select { position:relative; top:2px; }
.dollar { text-align:right; }
.mid { text-align: center; }
.moveup { margin-top:-5px; }
#budget_form { margin:15px; }
#datatable { margin-top:15px; }
#mainfieldset { margin:0px 0; padding:0 1em .5em; border:0 none; border-top:#cccccc 1px solid; }
#mainfieldset legend { margin:0.5em; padding:0 1.5em; background:transparent; color:#003366; font-size:1.1em; font-weight:bold; }
#segments { margin-left:15px; }
div.save { margin-top:10px; }
ul, li { display:inline; }
ul { margin:0; list-style-type:none; }
li { border:solid 1px white; padding:5px; margin:5px; background-color:white; font-weight:normal; }
</style>
</head>
<body>

<script>
function submitForm(command)
{
	var ErrorCount = 0;
	var thisForm	= document.frmBillback_3rdSingleIV;
	if (command == "IMPORT")
	{
		//console.log('radio checked:' + $('.cb:checked').length);
		if ($('.cb:checked').length == 0) {
				alert("Please select a payee.")
				return false;	
		}
		else {
			thisForm.command.value = command;
			document.frmBillback_3rdSingleIV.submit();
			return false;	
		}
	}
	else
	{
		if ((thisForm.Dist_Name.value == "") && (thisForm.ShipTO.value == ""))
		{
			ErrorCount++;
			queueMessage("Please enter at least one search criterion.", document.all.error_Payee);
		}
		else
		{
			clearQueue(document.all.error_Payee);
		}

		if(ErrorCount == 0) {
			thisForm.command.value = command;
			document.frmBillback_3rdSingleIV.submit();
			return false;	
		}		
		else {
			showMessageWindow();
			return false;
		}
	}
}
</script>

<cfoutput>
<CFPARAM NAME="URL.Customers_ID" DEFAULT="">
<CFPARAM NAME="FORM.Customers_ID" DEFAULT="#URL.Customers_ID#">
</cfoutput>
<CFPARAM NAME="FORM.Dist_Name" DEFAULT="">
<CFPARAM NAME="FORM.ShipTO" DEFAULT="">
<CFPARAM NAME="FORM.command" DEFAULT="0">
<CFPARAM NAME="FORM.selected_Dist" DEFAULT="">
<CFPARAM NAME="vars.qDistributor_Customer.recordcount" DEFAULT="0">

<cfif Form.command eq "IMPORT">
	<cfif len(trim(Form.selected_Dist)) GT 0>
		<cfoutput>
		<cfset useLakebaseForsetDeletedBB_III_Upload_Default_Dist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
<cfif useLakebaseForsetDeletedBB_III_Upload_Default_Dist>
<cftry>
<cfset application.oLakebase.updateRows("bb_iii_upload_default_dist",
{ "bsa_foodservice_customers_id" = "eq.#Form.Customers_ID#", "ship_to_level" = "eq.1" },
{ "deleted" = 1 }
)>
<cfcatch type="any">
<cfset useLakebaseForsetDeletedBB_III_Upload_Default_Dist = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForsetDeletedBB_III_Upload_Default_Dist><cfquery name="setDeletedBB_III_Upload_Default_Dist" datasource="#application.datasource#">
			UPDATE	BB_III_Upload_Default_Dist
			SET		Deleted = 1
			WHERE	BSA_Foodservice_Customers_ID = '#Form.Customers_ID#'
			AND		Ship_To_Level = 1
		</cfquery>
</cfif>
		<cfset useLakebaseForInsertBB_III_Upload_Default_Dist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
<cfif useLakebaseForInsertBB_III_Upload_Default_Dist>
<cftry>
<cfset application.oLakebase.insertRow("bb_iii_upload_default_dist", {
"distributor_id" = Form.selected_Dist,
"updated_by" = request.AccessStructure.user_id,
"ship_to_level" = 1,
"bsa_foodservice_customers_id" = Form.Customers_ID
})>
<cfcatch type="any">
<cfset useLakebaseForInsertBB_III_Upload_Default_Dist = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForInsertBB_III_Upload_Default_Dist><cfquery name="InsertBB_III_Upload_Default_Dist" datasource="#application.datasource#">
			INSERT INTO	BB_III_Upload_Default_Dist
				(Distributor_ID, Updated_By, Ship_To_Level, BSA_Foodservice_Customers_ID)
			VALUES
				('#Form.selected_Dist#','#request.AccessStructure.user_id#', 1, '#Form.Customers_ID#') 
		</cfquery>
</cfif>
		</cfoutput>
		<script>
  			var openerFormObj = opener.BBIIIPUpload;
			openerFormObj.jumpTodefaultPayee.value = "1";
			openerFormObj.submit();
			window.close();		
		</script>
	<!---<cflocation url="3rdPartyUpload_SearchShipTo.cfm">--->
	</cfif>
</cfif>

<div align="right">
	<B><FONT COLOR="#FF0000" STYLE="font-size:11px;">[ </FONT><A HREF="3rdPartyUpload_SearchShipTo.cfm"><FONT STYLE="font-size:11px;">BACK</FONT></a><FONT COLOR="#FF0000" STYLE="font-size:11px;"> ]</FONT></B>
</div>

<cfset useLakebaseForgetCustomerName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForgetCustomerName>
<cftry>
<cfset getCustomerName = application.oLakebase.toQuery(
application.oLakebase.selectRows("bsa_foodservice_customers", {
"select" = "name",
"bsa_foodservice_customers_id" = "eq.#Form.Customers_ID#"
}),
"name"
)>
<cfcatch type="any">
<cfset useLakebaseForgetCustomerName = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForgetCustomerName><cfquery name="getCustomerName" datasource="#application.datasource#">
	SELECT 	Name
	FROM	BSA_Foodservice_Customers 
	WHERE	BSA_Foodservice_Customers_ID = '#Form.Customers_ID#'
</cfquery>
</cfif>

<form name="frmBillback_3rdSingleIV" method="post" action="3rdPartyUpload_DefaultPayeeShipTo.cfm">
<cfoutput><CF_MessageWindow></cfoutput>
<FIELDSET STYLE="padding: 10px; width: 98%; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput> #getCustomerName.Name#</cfoutput> :: Select Default Payee # </LEGEND>
	<table width="98%" border="0" cellpadding="0" cellspacing="0" style="border:thin">
		<TR bgcolor="#F8F8F8">
			<TD width="4%" STYLE="font-size:11px;" nowrap><span id="error_Payee"></span>&nbsp;</TD>
			<TD width="25%" STYLE="font-size:11px;" nowrap><strong>Payee: </strong><input type="text" Name="Dist_Name" value="<cfoutput>#form.Dist_Name#</cfoutput>" onChange="submitForm('SEARCH')";>	</TD>
			<TD width="25%" STYLE="font-size:11px;" nowrap><strong>Ship To: </strong><input type="text" Name="ShipTO" value="<cfoutput>#form.ShipTO#</cfoutput>"></TD>
			<TD  width="10%" ALIGN="left" STYLE="font-size:11px;" nowrap>
				<B><FONT COLOR="#FF0000">[ </FONT><a HREF="#" ONCLICK="javascript: return submitForm('SEARCH');">search payee</a><FONT COLOR="#FF0000"> ]</FONT></B>
			</TD>
			<TD width="36%">&nbsp;</TD>
		</TR>
	</table>
	<INPUT TYPE="Hidden" NAME="command" VALUE="0">
	<INPUT TYPE="Hidden" NAME="Customers_ID" VALUE="<cfoutput>#Form.Customers_ID#</cfoutput>">
</FIELDSET>

<!--- --------------------------------------------------------------------------- --->
<cfif Form.command eq "0">
	<cfquery name="vars.qDistributor_Customer" datasource="#application.datasource#">
		SELECT	Ship_To,BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,Name,*
		FROM	BSA_Foodservice_Customers
				LEFT JOIN BB_III_Upload_Default_Dist on BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = BB_III_Upload_Default_Dist.Distributor_ID
		WHERE 	BSA_Foodservice_Customers.deleted = 0 
		AND		BB_III_Upload_Default_Dist.deleted = 0
		AND 	BB_III_Upload_Default_Dist.Distributor_ID = '#Form.Customers_ID#'  
	</cfquery>
<cfelse>
	<cfquery name="vars.qDistributor_Customer" datasource="#application.datasource#">
		SELECT	Ship_To,BSA_Foodservice_Customers_ID,Name
		FROM 	BSA_Foodservice_Customers
		WHERE	Deleted = 0
		AND		Ship_To <> 'Group'
		<cfif len(trim(FORM.Dist_Name)) gt 0 AND len(trim(FORM.ShipTO)) gt 0>
			and (name like '%#FORM.Dist_Name#%' and Ship_to like '%#FORM.ShipTO#%')
		<cfelseif len(trim(FORM.Dist_Name)) gt 0>
			and name like '%#FORM.Dist_Name#%'
		<cfelseif len(trim(FORM.ShipTO)) gt 0>
			and Ship_to like '%#FORM.ShipTO#%'
		</cfif>
	</cfquery>
</cfif>

<CFIF vars.qDistributor_Customer.recordcount GTE 3000>
	<br><center><FONT STYLE="font-size:11px;" ><B>Your query returned more than 3000 records. Please narrow your search.</B></FONT></center>
<CFELSE>
<cfset useLakebaseForqSelected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
<cfif useLakebaseForqSelected>
<cftry>
<cfset vars.qSelected = application.oLakebase.toQuery(
application.oLakebase.selectRows("bb_iii_upload_default_dist", {
"select" = "distributor_id,bsa_foodservice_customers_id",
"bsa_foodservice_customers_id" = "eq.#Form.Customers_ID#",
"deleted" = "eq.0",
"ship_to_level" = "eq.1"
}),
"distributor_id,bsa_foodservice_customers_id"
)>
<cfcatch type="any">
<cfset useLakebaseForqSelected = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForqSelected><cfquery name="vars.qSelected" datasource="#application.datasource#">
	SELECT	Distributor_ID, BSA_Foodservice_Customers_ID
	FROM 	BB_III_Upload_Default_Dist
	WHERE 	BSA_Foodservice_Customers_ID = '#Form.Customers_ID#' 
	AND 	Deleted = 0
	AND		Ship_To_Level = 1 
</cfquery>
</cfif>

<cfset vars.selected_list = ValueList(vars.qSelected.Distributor_ID)>
<!--- --------------------------------------------------------------------------- --->

<br>
<cfif vars.qDistributor_Customer.recordcount GT 0>
	<div align="right">
		<B><FONT COLOR="#FF0000" STYLE="font-size:11px;">[ </FONT><a HREF="#" ONCLICK="javascript: return submitForm('IMPORT');"><FONT STYLE="font-size:11px;">Import Payee</FONT></a><FONT COLOR="#FF0000" STYLE="font-size:11px;"> ]</FONT></B>
	</div>

	<div id="datatable">
	<table id="DistributorCustomer" class="datagrid">
		<thead>
			<tr>
				<th class="mid"></th>
				<th>Payee Name</th>
				<th>Ship To #</th>
			</tr>
		</thead>
		<tbody>
		
		<cfsetting enablecfoutputonly="true">
		<cfloop query="vars.qDistributor_Customer">
			<cfoutput><tr></cfoutput>
			<cfoutput><td class="mid"><input name="selected_Dist"  type="radio" class="cb" value=#vars.qDistributor_Customer.BSA_Foodservice_Customers_ID# <cfif vars.qSelected.BSA_Foodservice_Customers_ID  eq vars.qDistributor_Customer.BSA_Foodservice_Customers_ID>checked=checked</cfif>></td></cfoutput>
			<cfoutput><td>#vars.qDistributor_Customer.Name#</td></cfoutput>
			<cfoutput><td>#vars.qDistributor_Customer.Ship_to#</td></cfoutput>
			<cfoutput></tr></cfoutput>
		</cfloop>
		<cfsetting enablecfoutputonly="false">
		</tbody>
	</table>
	</div>   <!---datatable--->
	
	<div align="right">
		<B><FONT COLOR="#FF0000" STYLE="font-size:11px;">[ </FONT><a HREF="#" ONCLICK="javascript: return submitForm('IMPORT');"><FONT STYLE="font-size:11px;">Import Payee</FONT></a><FONT COLOR="#FF0000" STYLE="font-size:11px;"> ]</FONT></B>
	</div>
<cfelse>
	<cfif Form.command neq "0">
		<center><FONT STYLE="font-size:11px;">There are no payees that match the above criteria</FONT></center>
	</cfif>
</cfif>
</form>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
var budget_form = "budget_form";
<!---adjust main fieldset width when user's resolution is too low--->
$('#mainfieldset').css('width', ($(window).width() <= 700) ? "600px" : "98%");

  var column_sizes = ["4%", "48%", "48%"];

var grid = $('#DistributorCustomer').dataTable({
	"oLanguage": { "sSearch": "<b>Filter records:</b>" },
	"bAutoWidth": true
	,"bPaginate": false
	 ,"bSortClasses": false
	 ,"bScrollCollapse": true
	 ,"sDom": 'fti'
	,"sScrollXInner": "100%"
	<!---,"sScrollY": "100%"--->
	 ,"aaSorting": [[ 1, "asc" ]] <!---default sorting on code column--->
	 ,"aoColumns": [
		{"sWidth": column_sizes[0], "bSortable":true, "bSearchable":false, "sSortDataType":"dom-checkbox" },
		{"sWidth": column_sizes[1]}
		 ,{"sWidth": column_sizes[2]}

                  ]
}).fnSetFilteringDelay();

$('table#DistributorCustomer tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
<!---events for toggle all checkbox------------------------------------------------------------------------------------>
var $checkboxes = $('.cb');               <!---the other checkboxes--->
$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 $checkboxes.prop('checked', ( this.checked ) ? true : false );
 e.stopPropagation();
});

</script>
</CFIF>
</body>
</html>
