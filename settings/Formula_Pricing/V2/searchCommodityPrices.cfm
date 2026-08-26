<!---------------------------------------------------------------------------------------------------------------------
      Template: \\settings\Formula_Pricing\V2\searchCommodityPrices.cfm
      Date:     2016 Dec
      Author:   Mark Saunders
      Purpose:  

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<!---<cfmodule template="/customTags/layout.cfm" layoutID = "vendorBatching">--->


<link rel="stylesheet" type="text/css" href="/common_files/datatable_Formula.css">
<style>
	div.batched { float: left; }
	div.datagridwrapper { margin:5px 0; }
	.show923 { margin-left: 20px; font-weight: bold; }
  div.export { margin: 0 30px; float:left; }
  div.page {float:right; padding: 0px 50px 0px 0px;}
  .dataTables_paginate{width:225px;padding: 0px 10px 10px 0px;}
 /*float:right;text-align:right; margin-top:2px;}*/
</style>
<cfparam name="form.commDate" default="">
<cfscript>
  oCommodityPrices	= createObject("component","mvc.Models.Admin.Commodity.CommodityPrices");
  appSettings = application.appSettingsGet;
  oFormulaItem    = CreateObject("component", "mvc.Models.Program.FormulaItemLevel");
  qGetSavedFormulas = oFormulaItem.getSavedFormulas();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
<!---<cfoutput>
<cfif cgi.request_method eq "post">
	<!---<cfdump var="#form#" abort=true>--->
	<cfset dataCFC.saveBatchedVendors( form )>
</cfif>
</cfoutput>
--->
<script>
  function uploadFile(){
    var x = document.getElementById("myFile");
    var txt = "";
    if ('files' in x) {
      if (x.files.length == 0) {
        txt = "Select a file to upload.";
      } else {
        for (var i = 0; i < x.files.length; i++) {
         // txt += "<br><strong>" + (i+1) + ". file</strong><br>";
          var file = x.files[i];
          if ('name' in file) {
            txt += "name: " + file.name;
          }
          if ('size' in file) {
            txt += "size: " + file.size + " bytes <br>";
            previewFile();
          }
        }
      }
    } 
    else {
      if (x.value == "") {
        txt += "Select a file to upload.";
      } else {
        txt += "The files property is not supported by your browser!";
        txt  += "<br>The path of the selected file: " + x.value; // If the browser does not support the files property, it will return the path of the selected file instead. 
      }
    }
    document.getElementById("demo").innerHTML = txt;
  }

  function previewFile() {
    var file    = document.querySelector('input[type=file]').files[0];
    var reader  = new FileReader();

    reader.addEventListener("load", function () {
     // document.getElementById("demo").innerHTML = 'File Uploaded!';
      uploadCommodityData(reader.result);
    }, false);

    if (file) {
      reader.readAsDataURL(file);
    }
  }

    function uploadCommodityData(data){
                //Make sure we have rates
               // console.log(data);
                show_loader('Uploading...');
                var stop = 0;
                $.ajax({
                                async: true
                                ,data: {    data:  data,
                                            //Claim_Mechanics: $('#rebate_eligible').val(),
                                            method: "uploadCommodityData" }
                                //,dataType: "json"
                                ,success: function (data) {
                                  //  alert(data);
                                  document.getElementById("demo").innerHTML += '<br>' + data;
                                    //  XXXXXXXXXXXXXX     THIS IS ON THE GPO_PRODUCTS_FORM>CFM INCLUDE FILE     XXXXXXXXXXXXXXXXXXXXXXXX  
                                    $("div.loader").hide();
                                }
                                ,error: function (data) {
                                    //console.log('An error occurred.');
                                    console.log(data);
                                    alert('An error occurred (Uploading Comms).  ' + JSON.stringify(data));
                                }
                                ,type: "post"
                                ,url: "/mvc/Models/Admin/Commodity/CommodityPrices.cfc"
                    });
            }
</script>
<div class="wait" style='margin-top:1px;'>
	Loading commodities, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
</div>

<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1> 
  <table width="800" border="0">
    <tr>
        <td width="400" height="80">
          <FIELDSET STYLE="padding:5px; width: 350px; border: 1px solid Silver;  height: 80px">
            <LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Upload Commodity Data</LEGEND>
            <input type="file" id="myFile" size="50" onchange="uploadFile()">
            <p id="demo">Select a file to upload.</p>
          </FIELDSET>
        </td>

        <td width="400" height="80">
          <FIELDSET STYLE="padding:5px; width: 350px; border: 1px solid Silver; height: 80px">
            <LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Remove Saved Formulas</LEGEND>
            <select name="saved_formula" id="saved_formula" class="border rounded">
              <option value="" selected disabled hidden> -- select a formula to remove -- </option>
              <cfoutput query="qGetSavedFormulas">
                <option value="#Program_Formula_Pricing_Rule_ID#">#Rule_Name#</option>
              </cfoutput>
            </select>
            &nbsp;&nbsp;<CFOUTPUT><a HREF="##" onClick="removeFromSaved(); return false;">#application.util.string.actionLinkFormat("remove from saved")#</a></CFOUTPUT>
          </FIELDSET>
        </td>
    </tr>
  </table>
  <p>
</cfif>

<form name="searchCommodity" method="post">
 <!---  <body onload="myFunction()"> --->

<FIELDSET STYLE="padding:5px; width: 95%; border: 1px solid Silver;">
  <LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Search Commodity Data</LEGEND>
<cfoutput><b>Comm Date:</b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input name="commDate" id="commDate" type="text" class="date" value="#form.commDate#"></cfoutput><br>
<div class="datagridwrapper" style="display:none">
<table id="datagrid" class="datagrid" style='table-layout:fixed' width='100%'>
  <col width="15%">
  <col width="6%">
  <col width="6%">
  <col width="6%">
  <col width="8%">
  <col width="8%">
  <col width="10%">
  <col width="12%">
  <col width="10%">
  <col width="10%">
  <thead>
<!---    <tr>
      <th align="left">Symbol</th>
      <th align="left">Comm_Last</th>
      <th align="left">Comm_High</th>
      <th align="left">Comm_Low</th>
      <th align="left">Comm_Datetime</th>
	  <th align="left">Category_Name</th>
      <th align="left">Sub_Category_Name</th>
      <th align="left">Exchange_Detail_Abrev</th>
      <th align="left">Exchange_Detail_Name</th>
    </tr>--->
	<tr id='filterrow'>
      <th align="left">Symbol</th>
      <th align="left">Comm_Last</th>
      <th align="left">Comm_High</th>
      <th align="left">Comm_Low</th>
      <th align="left">Comm_Wtd_Avg</th>
      <th align="left">Comm_Datetime</th>
	    <th align="left">Category_Name</th>
      <th align="left">Sub_Category_Name</th>
      <th align="left">Exchange_Detail_Abrev</th>
      <th align="left">Exchange_Detail_Name</th>
    </tr>
  </thead>
<tbody>
</tbody>
</table>
</div>

</form>   
</FIELDSET>
<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">
<cf_include files="/script/javascript/table2csv.js, /styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js, /script/javascript/jquery.noty.packaged.min.js,/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"/>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
$(function() {

  
  var mydatagrid = $('#datagrid').dataTable({
      "ajax": {
                  url: "ajaxSearchCommodityPrices.cfm"
                , type: "post"
                , orderCellsTop: true
                , data: function ( d ) {
                                        d.commDate = $('#commDate').val();
                                        d.searchString = $('.dataTables_filter input').val();
                                        d.Symbol = $('#Symbol').val();
                                        d.Sub_Category_Name = $('#Sub_Category_Name').val();
                                        d.Exchange_Detail_Abrev = $('#Exchange_Detail_Abrev').val();
                }
      }
      ,"autoWidth": true
      ,"language": { "search": "Filter All Columns:",
                    paginate: {
                                first:    '&nbsp; << First &nbsp;',
                                previous: '&nbsp; < Previous &nbsp;',
                                next:     '&nbsp; Next > &nbsp;',
                                last:     '&nbsp; Last >> &nbsp;'
                               }
                     }
      ,"lengthMenu": [ [500, 15, 25, 50, 300], [500, 15, 25, 50, 300]]
      ,"processing": true
      ,"serverSide": true
      ,"scrollCollapse": true
      ,pagingType : "full"
      ,"sDom": '<f<"export"><"page"p>l>rti<"page"p>l'
      ,"drawCallback": function(r) {
          r.json.aaExchFilterData.forEach((element) => {
            if(!$('#Exchange_Detail_Abrev').find("option:contains('" + element  + "')").length){
              $('#Exchange_Detail_Abrev').append( '<option value="' + element + '">' + element + '</option>' );
            } 
          });
      }
    }).fnSetFilteringDelay();
 
    $("div.export").html(<cfoutput>"<a id='export'>#application.util.string.actionLinkFormat2('export')#</a>"</cfoutput>);

    $('a#export').click(function() {
      noty( { text: "Exporting..."
              ,layout:'topRight'
              ,type:'information'
              ,killer:true
              ,timeout:3500 });
      window.open( "/Common_Files/exportAll.cfm?" + "type=commodity"
                            + "&friendlyFileName=commodity"
                            + "&commDate="     + $('#commDate').val()
                            + "&searchString=" + $('.dataTables_filter input').val()
                            + "&Symbol="       + $('#Symbol').val()
                            + "&Sub_Category_Name=" + $('#Sub_Category_Name').val()
                            + "&Exchange_Detail_Abrev=" + $('#Exchange_Detail_Abrev').val()
                    ,"searchComms"
                    ,"toolbar=no, scrollbars=no, resizable=no, top=500, left=500, width=1, height=1");
    });

	
	$('div.wait').hide();
	$('div.datagridwrapper').show();
});

jQuery(".date").datepicker({
    dateFormat: "mm/dd/yy",
    changeMonth: true,
    changeYear: true,
});
$('#commDate').on( 'change', function () {
	//alert(this.value);
    $('#datagrid').DataTable().draw();
} );

$(document).ready(function() {
    // Setup - add a text input to each footer cell
    $('#datagrid  thead tr#filterrow th').each( function () {
        //var title = $(this).index().text();
		var title = $('#datagrid thead th').eq( $(this).index() ).text();
		if(title == 'Symbol' || title == 'Sub_Category_Name' ){
			$(this).html( title + '<br><input type="text" onclick="stopPropagation(event);" id="' + title  + '"placeholder="Search '+title+'" />' );
		}
		else if (title != 'Exchange_Detail_Abrev'){
			$(this).html( title + '<br> &nbsp;');
		}
        
    } );
 
    // DataTable
    var table = $('#datagrid').DataTable();
    
   
 
    // Apply the search
    table.columns().every( function () {
        var that = this;
        var colText = $(this.header()).text();
            $( 'input', this.header() ).on( 'keyup change', function () {
                if ( that.search() !== this.value ) {
                    that
                        .search( this.value )
                        .draw();
                }
            } );
        var column = this;
        if (colText == 'Exchange_Detail_Abrev') {
              
              var select = $('<select onclick="stopPropagation(event);" id="' + colText  + '"><option value=""></option></select>')
                        .appendTo( $(column.header()))
                        .on( 'change', function () {
                            var val = $.fn.dataTable.util.escapeRegex(
                                $(this).val()
                            );
    
                            column
                                .search( val ? '^'+val+'$' : '', true, false )
                                .draw();
                        } );                 
        }
       
    } );

} );

function removeFromSaved(){
    var formulaId = $('#saved_formula').val();

      $.ajax({
              async: true
              ,data: {  Program_Formula_Pricing_Rule_ID: formulaId,
                        method: 'removeFromSaved' }
              //,dataType: "json"
              ,success: function(data){
                       // console.log(data);
                        $('#saved_formula').find('option').remove();
                        aData = JSON.parse(data);
                        console.log(aData);
                        $('#saved_formula').append('<option value="" selected disabled hidden> -- select a formula to remove -- </option>');
                        aData.forEach(function(item){
                            $('#saved_formula').append('<option value=' + item.program_formula_pricing_rule_id + '>' + item.rule_name + ' :: ' +  item.formula_price + '</option>');
                        });
                        //location.reload();
                    }
                    ,error: function (data) {
                      // console.log(data);
                        alert('An error occurred (createFromSaved).  ' + JSON.stringify(data) );
                    }
              ,type: "post"
              ,url: "/mvc/Models/Program/FormulaItemLevel.cfc"
        });
    }

function stopPropagation(evt) {
		if (evt.stopPropagation !== undefined) {
			evt.stopPropagation();
		} else {
			evt.cancelBubble = true;
		}
	}


</script>

<!---</cfmodule>--->
