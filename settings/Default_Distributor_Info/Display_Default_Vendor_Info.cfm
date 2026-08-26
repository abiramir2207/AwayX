<!-----------------------------------------------------------------------------
FILE NAME:		Display_Default_Vendor_info.cfm
DESCRIPTION:		???
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	9-Dec-2008	Added check number and
							DD_Reference fields

------------------------------------------------------------------------------>
<!DOCTYPE HTML>
<html>
<head>
	<title>Default Vendor & BB Closing Method Display</title>
<script language="JavaScript" src="/Script/javascript/dom_common.js"></script>
<link rel="stylesheet" type="text/css" href="/common_files/viewmodes.css">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/feedback.css">
<style>
td select, th select {
  width:98%;
}
.vendor_id {
  width:70%;
}
.find {
  cursor: pointer;
}
.vendor_name {
  width:98%;
  background-color: #F5F5F5;
}
div.save {
  float:left;
  margin: 5px 0 0 15px;
}
</style>
</head>
<body>
<cfif cgi.request_method eq "post">
  <cfset saveChanges()>
</cfif>

<cfquery name="variables.bbClosingMethods" datasource="#application.datasource#">
  SELECT  vchBillback_Closing_Method_Desc
         ,iBillback_Closing_Method_ID
    FROM BILLBACK_CLOSING_METHODS
   WHERE Deleted = 0
         AND iBillback_Closing_Method_ID IN (1, 2)
</cfquery>

<cfquery NAME="qryVendorInfo" DATASOURCE = "#Application.Datasource#">
  SELECT    CAST(BSA_Foodservice_Customers_ID AS nvarchar(50)) AS BSA_ID,
      '' AS Legacy_ID,
           Name,
           Shr_ship_to AS Dist_Opr_ID,
           Bsa_foodservice_customers.Default_vendor_id,
           Isnull(Nullif(Bsa_foodservice_customers.Default_billback_closing_method_id, ''), 0) AS Default_billback_closing_method_id,
           Vendor_master.Vendor_name,
           Billback_closing_methods.Vchbillback_closing_method_desc,
           'D' AS Dist_Opr_Type,
           Bsa_foodservice_customers.Default_billback_closing_method_id,
           CAST(BSA_Foodservice_Customers_ID AS VARCHAR(50)) AS UniqueKey
      FROM Bsa_foodservice_customers
           LEFT JOIN Vendor_master
             ON Bsa_foodservice_customers.Default_vendor_id = Vendor_master.Vendor_id AND Vendor_master.Deleted = 0
           LEFT JOIN Billback_closing_methods
             ON Bsa_foodservice_customers.Default_billback_closing_method_id = Billback_closing_methods.Ibillback_closing_method_id
     WHERE
           Bsa_foodservice_customers.Deleted = 0
           AND Bsa_foodservice_customers.Active_code = 'A'
           AND (Default_Vendor_ID != ''  OR Default_Vendor_ID != null OR Isnull(Nullif(Bsa_foodservice_customers.Default_billback_closing_method_id, ''), 0) != 0)

UNION

 select CAST (BSA_Operator_ID AS nvarchar(50)) AS BSA_ID,
           Legacy_ID,
           Operator_Name as Name,
           isnull(nullif(BSA_Operator.Legacy_ID,''), BSA_Operator.BSA_Operator_ID) AS Dist_Opr_ID,
           BSA_Operator.Default_Vendor_ID,
           isnull(nullif(BSA_Operator.Default_Billback_Closing_Method_ID,''),0) AS Default_Billback_Closing_Method_ID,
           Vendor_Master.Vendor_Name,
           Billback_Closing_Methods.vchBillback_Closing_Method_Desc,
           'O' AS Dist_Opr_Type,
           BSA_Operator.Default_Billback_Closing_Method_ID,
           CAST(BSA_Operator_ID AS VARCHAR(50)) AS UniqueKey
      FROM BSA_Operator
      LEFT JOIN Vendor_Master ON BSA_Operator.Default_Vendor_ID = Vendor_Master.Vendor_ID
             AND Vendor_Master.Deleted = 0
      LEFT JOIN Billback_Closing_Methods ON BSA_Operator.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID
     WHERE
      BSA_Operator.Default_Vendor_ID != '' OR BSA_Operator.Default_Vendor_ID != null  OR
       isnull(nullif(BSA_Operator.Default_Billback_Closing_Method_ID,''),0) != 0
 ORDER BY Name
</cfquery>

<cfoutput>
<cfset pagetitle = "Default Vendor & BB Closing Method Display">
</cfoutput>

<cfinclude template="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/settings/settings_title.cfm">
 <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1, 2.5, 1, 1.3, 2.5, 1] )>
<FORM METHOD="post" NAME="DataForm" id="DataForm">
  <cfif cgi.request_method eq "post">
    <div class="success" style="height:15px;">
      <p>Your changes have been saved succesfully.</p>
    </div>
 </cfif>

 <table width="100%" border="0" cellpadding="1" cellspacing="0" class="datagrid" id="VendorDisplayTable" style='table-layout:fixed'>
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
	<!---- HEAD ----->
  <thead>
  <tr>
		<th class="columnfilter">Type<br><select><option></option><option>Distributor</option><option>Operator</option></select></th>
		<th>Name</th>
 		<th>ID</th>
		<th>Vendor ID<br><input type="text" name="vendor_id_mass" class="vendor_id"> <img class='find' src="/images/searchtool.gif" width="16" height="16"/><br><cfoutput><a id='mass_apply_1' href='##'>#application.util.string.actionLinkFormat('mass apply')#</a></cfoutput></th>
		<th>Vendor Name<br><input type="text" name="vendor_name_mass" class="vendor_name" disabled><br>&nbsp;</th>
		<th>BB Closing Method<br><select id="closing_method_id_mass">
        <option></option>
        <cfoutput query="variables.bbClosingMethods">
          <option value="#variables.bbClosingMethods.iBillback_Closing_Method_ID#">#variables.bbClosingMethods.vchBillback_Closing_Method_Desc#</option>
        </cfoutput>
      </select><br><cfoutput><a id='mass_apply_2' href='##'>#application.util.string.actionLinkFormat('mass apply')#</a></cfoutput></th>
  </tr>
	</thead>
	<tbody>
  <cfsetting enablecfoutputonly=true>
	<cfloop query="qryVendorInfo">
		<cfoutput><tr></cfoutput>
		 	<cfoutput><td><input type="hidden" name="row_#qryVendorInfo.currentRow#" class="row_id" changed="0" value="#qryVendorInfo.UniqueKey#"></cfoutput>
				<cfif qryVendorInfo.Dist_Opr_Type EQ "D">
					<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>
				<cfelseif qryVendorInfo.Dist_Opr_Type EQ "O">
					<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>
				</cfif>
			<cfoutput></td></cfoutput>
		 	<cfoutput><td>#qryVendorInfo.Name#</td></cfoutput>
		 	<cfoutput><td>#qryVendorInfo.Dist_Opr_ID#</td></cfoutput>
		 	<cfoutput><td><input type="text" name="vendor_id_#qryVendorInfo.currentRow#" class="vendor_id" value="#qryVendorInfo.Default_Vendor_ID#"><!--- <input type="button" value="Search"> ---> <img class='find' src="/images/searchtool.gif" width="16" height="16"/></td></cfoutput>
		 	<cfoutput><td><input name="vendor_name_#qryVendorInfo.currentRow#" class="vendor_name" value="#qryVendorInfo.Vendor_Name#" disabled></td></cfoutput>
		 	<cfoutput><td><select name="closing_method_id_#qryVendorInfo.currentRow#" class="closing_method"> <option></option> <cfloop query="variables.bbClosingMethods"> <option value="#variables.bbClosingMethods.iBillback_Closing_Method_ID#" #(qryVendorInfo.Default_billback_closing_method_id eq variables.bbClosingMethods.iBillback_Closing_Method_ID ? "selected=selected" : "")#>#variables.bbClosingMethods.vchBillback_Closing_Method_Desc#</option> </cfloop> </select></td></cfoutput>
		<cfoutput></tr></cfoutput>
	 </cfloop>
  <cfsetting enablecfoutputonly=false>
	</tbody>
</table>
</FORM>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="saveChanges" output="false">
  <!--- <cfdump var="#form#" abort="false"> --->
  <cfoutput>
  <cfloop collection="#form#" item="local.element">
    <!--- locate the element with a prefix of "row_", it contains the record ID --->
    <cfif left(local.element, 4) eq "row_">
      <!--- extract the information from the related elements --->
      <cfscript>
        local.record_id = form[ local.element ];

        local.row_number = listLast( local.element, '_');
        local.vendor_id = form[ "vendor_id_" & local.row_number ];
        local.closing_method_id = form[ "closing_method_id_" & local.row_number ];
      </cfscript>

      <!--- #local.record_id# | #local.row_number# | #local.vendor_id# | #local.closing_method_id#<br> --->

      <cfquery name="local.save" datasource="#application.datasource#">
          <cfif application.util.string.isGUID(local.record_id)>
            UPDATE Bsa_foodservice_customers
               SET  Default_vendor_id = '#local.vendor_id#'
                    <cfif local.closing_method_id eq ''>
                      ,Default_billback_closing_method_id = NULL
                    <cfelse>
                      ,Default_billback_closing_method_id = #local.closing_method_id#
                    </cfif>
             WHERE BSA_Foodservice_Customers_ID = '#local.record_id#'
          <cfelse>
            UPDATE BSA_Operator
               SET  Default_vendor_id = '#local.vendor_id#'
                    <cfif local.closing_method_id eq ''>
                      ,Default_billback_closing_method_id = NULL
                    <cfelse>
                      ,Default_billback_closing_method_id = #local.closing_method_id#
                    </cfif>
             WHERE BSA_Operator_ID = '#local.record_id#'
          </cfif>
      </cfquery>
    </cfif>
  </cfloop>
  </cfoutput>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfscript>
  dt.tableId = "VendorDisplayTable";
  dt.trHover = "off";
  dt.sDom    = 'f<"save">ptip';
  dt.tableHeight = ( cgi.request_method eq "post" ? 0.67 : 0.73 );
  dt.aoColumns = [  '"bSearchable":false, "bSortable":false'
                   ,'"bSearchable":true, "bSortable":true'
		               ,'"bSearchable":true, "bSortable":true'
                   ,'"bSearchable":true, "bSortable":false'
		               ,'"bSearchable":true, "bSortable":true'
      						 ,'"bSearchable":false, "bSortable":false'
                 ];
</cfscript>

<cfinclude template="\common_files\datatable\viewDataTable.cfm">

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<script type="text/javascript" src="/script/javascript/jquery.util.js"></script>
<script>
isVendor = function( vendor_id ) {
  var dataIsValid = 1;
    $.ajax({ url: "/components/programs/Vendor/vendor.cfc"
            ,type: "post"
            ,data: { method: "isVendorMaster"
                    ,vendor_id: vendor_id }
            ,dataType: "json"
                          ,async: false
                          ,timeout:60000
            ,error: function(jqXHR, textStatus, errorThrown) { alert( 'System is busy, please try again later.' ); dataIsValid = 0; }
            ,success: function(json) { if ( json.ERRORS.length ) {
                                         alert( json.ERRORS.join('\n') );
                                         dataIsValid = 0;
                                       }
                                     }
          });
  return dataIsValid;
};

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

$('table.datagrid').on('click', 'th img.find', function(e) {
  var windowcmd = "/GL_code/Vendor_Management/vendor_master_search.cfm?"
                    + "Formname=DataForm"
                    + "&FieldName=vendor_id_mass"
                    + "&DescFieldName=vendor_name_mass"
                    + "&ReloadForm=0";
  NewWindow(windowcmd, "Vensearchwindow", 800, 600, "yes", "yes");
})

$('table.datagrid').on('click', 'td img.find', function(e) {
  var $tr = $(e.target).closest('tr');
  // highlight the row to track the location after returning from popup search
  $tr.addClass('over').find("input.row_id").attr("changed", "1");
  var windowcmd = "/GL_code/Vendor_Management/vendor_master_search.cfm?"
                    + "Formname=DataForm"
                    + "&FieldName=" + $tr.find('input.vendor_id').attr("name")
                    + "&DescFieldName=" + $tr.find('.vendor_name').attr("name")
                    + "&ReloadForm=0";
  NewWindow(windowcmd, "Vensearchwindow", 800, 600, "yes", "yes");
})

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
$('tbody').on('change', 'input, select', function(e) {
  var $tr = $(e.target).closest('tr');
  $tr.addClass('over');
  $tr.find("input.row_id").attr("changed", "1");
})

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
$('#mass_apply_1').click(function() {
  var mass_value = $('input[name=vendor_id_mass]').val()
     ,dataIsValid = 1
  if (mass_value !== '') {
    dataIsValid = isVendor( mass_value );
    if (! dataIsValid) {
      $('input[name=vendor_id_mass]').focus();
    }
  }
  if (dataIsValid) {
    $('tbody .vendor_id').val( mass_value );
    $('tbody .vendor_name').val( $('input[name=vendor_name_mass]').val() );
    $('tbody .row_id').attr("changed", "1");
  }
});

$('#mass_apply_2').click(function() {
  $('.closing_method').val( $('#closing_method_id_mass').val() );
  $('tbody .row_id').attr("changed", "1");
});

$('div.save').html( <cfoutput>"<a id='save27' href='##'>#application.util.string.actionLinkFormat('save')#</a>"</cfoutput> );

$('#save27').click(function() {
  $('div.success, div.dataTables_filter, table.datagrid, div.dataTables_info, div.dataTables_paginate').hide();
  $(this).html("<div>Saving changes, please wait for a moment..</div>'");

  // clear filter to get back all rows first
  $('.dataTables_filter  input').val('');

  $('tbody tr').each(function() {
     var $row_id = $(this).find('.row_id[changed=0]');
     if ( $row_id.length ) {
       // disable this row - thus not including it in the form post
       $row_id.attr("disabled", "true");
     }
  });

  $('form[name=DataForm]').submit();
});

$(function() {
  // wait for 2.5 sec. and then hide save success message
  setTimeout(function() { $("div.success").hide('slow'); }, 500);
});
</script>
</body>
</html>

