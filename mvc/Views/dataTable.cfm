<!---
 Template: \mvc\Views\dataTable.cfm
 Date:     1.10.2011
 Author:   Mark Saunders
 Purpose:  generic ui page for displaying data in JQUERY DataTable plugin

 Requires (from calling page):

 	cfcAttrsPath = 'mvc.Views.dataTable.zipTable';

	The cfcAttrsPath .cfc nreeds a getAttrs method.
	getAttrs() method neds to return a struct with configuration info
	SEE: /mvc/Views/dataTable/dataTable.cfc -> getAttrs() for details of latest config options
 --->
  <cfscript>
 	//if the path has no dots, use default path
 	variables.arrSearchField = ArrayNew(1);
 	variables.arrSort = ArrayNew(1);
 	variables.arrVisible = ArrayNew(1);
 	variables.arrColumns = ArrayNew(1);

 	if(listlen(cfcAttrsPath,'.') == 1){
		cfcAttrsPath = 'mvc.Views.dataTable.' & cfcAttrsPath;
	}
	attrs = createObject('component',cfcAttrsPath).getAttrs();
	//clean up dot notation in arrays used in DB
	for (i=1;i LTE ArrayLen(attrs.arrColumns);i=i+1) {
		arrColumns[i] = ListLast(attrs.arrColumns[i],'.');
	}

	for (i=1;i LTE ArrayLen(attrs.arrSearchField);i=i+1) {
		arrSearchField[i] = ListLast(attrs.arrSearchField[i],'.');
	}

	for (i=1;i LTE ArrayLen(attrs.arrSort);i=i+1) {
		arrSort[i] = ListLast(attrs.arrSort[i],'.');
	}

	for (i=1;i LTE ArrayLen(attrs.arrVisible);i=i+1) {
		arrVisible[i] = ListLast(attrs.arrVisible[i],'.');
	}
</cfscript>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-type" content="text/html; charset=utf-8">
		<title>DataTable</title>
		<cfset jQuery.version = "1.7.2" />
		<cfset jQueryUI.version = "1.8.23" />
		<cfinclude template="/common_files/jQuery.cfm">
		<script type="text/javascript" src="/Script/javascript/jquery.dataTables-1.9.3.min.js"></script>
		<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
		<script type="text/javascript" src="/Script/javascript/variable.debugger.js"></script>
		<cfset i = 1 />
		<cfset iSortCol = 2 />
		<cfif LEN(attrs.sRowDetailsHtml) GT 0>
			<cfset iSortCol = 3 />
		</cfif>
		<style type="text/css" media="screen">
			@import "/common_files/demo_table_jui.css";
			@import "/common_files/jquery.custom.css";

			/* simple css-based tooltip */
			.tooltip {
					    display:none;
					    background-color:#ffa;
					    border:1px solid #cc9;
					    padding:3px;
					    font-size:12px;
						max-width:325px;
					    -moz-box-shadow: 2px 2px 11px #666;
					    -webkit-box-shadow: 2px 2px 11px #666;
			}
		</style>
		<script>
		<cfoutput>
		var arrSelected =  [];
		//1 year back
		var dateFilter = new Date();
		dateFilter.setUTCFullYear(dateFilter.getFullYear()-1,dateFilter.getMonth());
		var theDate = (dateFilter.getMonth()+1) + '/' + dateFilter.getDate() + '/' + dateFilter.getFullYear();


		$(document).ready(function() {

		 var $dtPicker =  $('<input type="text" id="dtPicker" title="Filter on the start date of the pay period">');
		 $dtPicker.val(theDate);

		 $.ajaxSetup ({
			    // Disable caching of AJAX responses
			    cache: false
			});

			/*
			 * Initialise DataTables, with no sorting on the 'details' column --------------
			 */
			var oTable = $('##datagrid').dataTable( {
			      "bServerSide": true
			    , "bProcessing": true
				, "sScrollY": "435px"
				, "bScrollAutoCss":"true"
				, "bScrollCollapse": true
				, "bJQueryUI": true
				//,"bScrollInfinite": true
				, "bDeferRender": true
			    , "iDisplayLength": #attrs.iDisplayLength#
				, "aLengthMenu": [[15, 30, 50, 100, -1], [15, 30, 50, 100, "All"]]
				, "bSortClasses": false
				, "fnRowCallback": fnInsertDetailsIcon
				, "fnDrawCallback": function( oSettings ) {
					$('.dataTables_scrollBody').css('min-height', '100px');
                  }
			    , "sDom": '<"H"frl>t<"F"pi>'
			    , "oLanguage": {"sSearch": "Filter All:"}
				, "bPaginate" : true
				, "sPaginationType": "#attrs.sPaginationType#"
				, "bLengthChange" : true
				, "aaSorting": [[ #iSortCol#, "desc" ]] //first two cols are id and detail icon
			    , "aoColumns": [
													{ "bVisible": false ,"mDataProp": "dataTableId", "bSearchable": false, "bSortable": false, "sWidth": "75px"}, /* ID column */
													//<!---- If we need to display an  expandRowIcon ---->
												<cfif LEN(attrs.sRowDetailsHtml) GT 0>
													{  "bVisible": false ,"sTitle": "", "bSearchable": false, "bSortable": false,"mDataProp": "Detail", "sClass": "moreInfo", "sWidth": "25px"},
												</cfif>
												<cfloop array="#variables.arrColumns#" index="colName">
												<cfif colName NEQ variables.arrColumns[1]>,</cfif>
													{"mDataProp": "#variables.arrColumns[i]#",
													"sTitle": "#attrs.arrColumnDesc[i]#",
													"bSearchable": <cfif ArrayFind(variables.arrSearchField, colName)>true<cfelse>false</cfif>,
													"bSortable": <cfif ArrayFind(variables.arrSort, colName)>true<cfelse>false</cfif>,
													"bVisible": <cfif ArrayFind(variables.arrVisible, colName)>true<cfelse>false</cfif>
												<cfif attrs.arrColumnDesc[i] EQ "Title">
													,"sWidth": "200px"
												<cfelseif attrs.arrColumnDesc[i] EQ "">
													,"sWidth": "125px"
												<cfelseif attrs.arrColumnDesc[i] EQ "ID" OR attrs.arrColumnDesc[i] EQ "Prg's" OR attrs.arrColumnDesc[i] EQ "BB's">
													,"sWidth": "50px"
												<cfelse>
													,"sWidth": "75px"
												</cfif>
													<cfif colName EQ "BB_Amount">, "sClass": "right"</cfif>}
													<cfset i++ />
												</cfloop>
				                 ]
				//CALL SERVER FOR DATA
				,"fnServerData": function ( sSource, aoData, fnCallback ) {
			            /* Add arguments for server call, and send as 'POST' */
						aoData.push( { "name": "method", "value": "getData" } );
						aoData.push( { "name": "cfcAttrsPath", "value": "#cfcAttrsPath#" } );
						aoData.push( { "name": "dateFilter", "value": $dtPicker.val() } );
						//$.debug(dateFilter.toLocaleString());
			            $.ajax( {
			                "dataType": 'json'
			                ,"type": "POST"
			                ,"url": "/mvc/Views/dataTable/dataTable.cfc"
			                ,"data": aoData
			                ,"success": [function(data, textStatus, jqXHR){
																			$("##dvModal").dialog('close');
																			fnCallback(data);
																		  }
										]
							,"error": function(jqXHR, exception){
														           fnAjaxError(jqXHR, exception)
														        }
			            } );
			      }
				 ,"fnInitComplete": function(oSettings, json) {

					  //set the title of th eFilter input box
					$('div.dataTables_filter input').attr('title','Filter on Report Id, Report Title, User, Program Number, Billback Number and Amount');

					//ADD DATE FILTER
				      $('.dataTables_filter').append('&nbsp;&nbsp;&nbsp;Date Filter: ');   //('&nbsp;&nbsp;&nbsp;Date Filter: ');
					  $('.dataTables_filter').append($dtPicker);
					  //$("##dtPicker").appendTo('.dataTables_filter');
					  $("##dtPicker").datepicker();
					  $("##dtPicker").datepicker("option","changeYear",true);
					  $("##dtPicker").datepicker("option","changeMonth",true);
					  $("##dtPicker").datepicker( "option", "maxDate", "+1m" );
					  $("##dtPicker").datepicker( "option", "minDate", "-36m" );

					//set tooltips
					$('div.dataTables_filter input').tooltip({
										effect: 'fade',
										relative: true,
										position: 'center left',
										offset: [40,447],
										delay: 300
									});
				   }
				//,"fnFooterCallback": function( nFoot, aasData, iStart, iEnd, aiDisplay ) {
				//	fnInsertSelectFilters(nFoot, aasData, iStart, iEnd, aiDisplay )
		       // }
			} );
			$.fn.dataTableInstance = [];
		  	$.fn.dataTableInstance.push( $('##datagrid').dataTable() );
			//new FixedHeader( oTable );

			//fire filter when data cganges
			$dtPicker.datepicker({
			   onSelect: function(dateText, inst) {
			   											//alert('select!!!!');
														oTable.fnFilter( $('.dataTables_filter input').val() );
												}
			});


			/*
			 * ADD ROW HIGHLIGHTING  --------------
			 */
			$('##datagrid').delegate('td','mouseover mouseleave', function(e) {

			    if (e.type == 'mouseover' &&   !$(this).parent().hasClass('row_selected') ) {
			      $(this).parent().addClass("hover");
			     // $("colgroup").eq($(this).index()).addClass("hover");
			    }
			    else {
			      $(this).parent().removeClass("hover");
			     // $("colgroup").eq($(this).index()).removeClass("hover");
			    }
			});
			/*
			 * ADD ROW SELECTING (highlighting)  Could be extended to keep track or call db --------------
			 */
				//TAKE 2
				$('##datagrid').on('click','td',function () {
					//Do not toggle selection if the user clicked "More Info Icon"
					//$.debug(this.parent);
					if($(this).parent().hasClass('rowData') && !$(this).hasClass('moreInfo')){
						// Get the position of the current data from the node
					    var aPos = oTable.fnGetPosition( this );
					    // Get the data array for this row
					    var aData = oTable.fnGetData( aPos[0] );
						var iId = aData['dataTableId'];

						<cfif attrs.bSingleSelect>
							$(oTable.fnSettings().aoData).each(function (){
					            $(this.nTr).removeClass('row_selected');
					        });
							//if not already selected
							if ( jQuery.inArray(iId, arrSelected) == -1 )
							{
								arrSelected = [];
								arrSelected[0] = iId;
								$(this).parent().addClass('row_selected');
								$(this).parent().toggleClass('hover');
							}
							else{//it is selected so we need to deselect (removeClass(row_selected) already happened
								arrSelected = [];
								$(this).parent().toggleClass('hover');
							}
						<cfelse>
							if ( jQuery.inArray(iId, arrSelected) == -1 )
							{
								arrSelected[arrSelected.length++] = iId;
							}
							else
							{
								arrSelected = jQuery.grep(arrSelected, function(value) {
									return value != iId;
								} );
							}
							//for the odd rows, turn off the alternating color
							if(!$(this).parent().hasClass('even')){
								$(this).parent().toggleClass('odd');
							}
							$(this).parent().toggleClass('row_selected');
							$(this).parent().toggleClass('hover');
						</cfif>
					}
				} );

			/* Add event listener for opening and closing details
			 * Note that the indicator for showing which row is open is not controlled by DataTables,
			 * rather it is done here  --------------
			 */
			<cfif LEN(attrs.sRowDetailsHtml) GT 0>
				$('##datagrid tbody td img').live('click', function () {
					var nTr = this.parentNode.parentNode;
					if(nTr){

						if ( this.src.match('details_close') )
						{
							/* This row is already open - close it */
							this.src = "/Images/details_open.png";
							oTable.fnClose( nTr );
						}
						else if(this.src.match('details_open'))
						{
							/* Open this row */
							this.src = "/Images/details_close.png";
							//TODO: PARAMETERIZE THIS COL NUM
							var sData = oTable.fnGetData( nTr,3 );

							var aoData = [];
							aoData.push( { "name": "method", "value": "getRow" } );
							aoData.push( { "name": "cfcAttrsPath", "value": "#cfcAttrsPath#" } );
							aoData.push( { "name": "id", "value": sData } );
							$.ajax({
							         dataType: 'json',
							         url: '/mvc/Views/dataTable/dataTable.cfc',
									 data: aoData,
							         success: function(data, status, xhr) {
							            // TODO: we'll modify this next to create and display
										oTable.fnOpen( nTr, fnFormatDetails(oTable, nTr, data['links']), 'details' );
									    oTable.fnUpdate( data['count'],nTr, 14,0,0 );
										oTable.fnUpdate( data['amount'],nTr, 15,0,0 );
										oTable.fnUpdate( data['status'],nTr, 16,0,0 );
							         },
							         error: function(xhr, status, err) { },
							         complete: function(xhr, status) { }
							      });

							//oTable.fnOpen( nTr, fnFormatDetails(oTable, nTr), 'details' );

							//var sData = oTable.fnGetData( nTr,5 );
	    				    //	alert( 'The cell clicked on had the value of '+sData );
							//$.debug(nTr);
						}
					}
				} );
			</cfif>

			/*
			 * ADD A SELECT MENU for each TH element in the table footer --------------
			 */
		   /* Add a select menu for each TH element in the table footer
			$("tfoot th").each( function ( i ) {
				this.innerHTML = fnCreateSelect( oTable.fnGetColumnData(i) );
				$('select', this).change( function () {
					oTable.fnFilter( $(this).val(), i );
				} );
			} );
			*/

		} );//END DOCUMENT READY

		/*
		 * Formating function for row details --------------
		 */
		function fnFormatDetails ( oTable, nTr,data )
		{
			var sData = oTable.fnGetData( nTr );
			var sOut = data;//'#attrs.sRowDetailsHtml#';

			return sOut;
		}


		/*
		 * AFTER DATA RETURNS INSERT "PLUS" ICON in First COL of each Row --------------
		 */
		function fnInsertDetailsIcon (nRow, aData, iDisplayIndex)
		{
			/* Insert a 'details' icon to the table */

			  this.src = "/Images/details_close.png";
							//TODO: PARAMETERIZE THIS COL NUM
							var oTable = $.fn.dataTableInstance[0];
							var sData = oTable.fnGetData( nRow,3 );

							var aoData = [];
							aoData.push( { "name": "method", "value": "getRow" } );
							aoData.push( { "name": "cfcAttrsPath", "value": "#cfcAttrsPath#" } );
							aoData.push( { "name": "id", "value": sData } );
							$.ajax({
							         dataType: 'json',
							         url: '/mvc/Views/dataTable/autoPayTable.cfc',
									 data: aoData,
							         success: function(data, status, xhr) {
							            // TODO: we'll modify this next to create and display
							              $('td:eq(7)', nRow).html( data['links'] );
							           },
							         error: function(xhr, status, err) { },
							         complete: function(xhr, status) { }
							      });

			  <!---<cfif LEN(attrs.sRowDetailsHtml) GT 0>
			   $('td:eq(0)', nRow).html( '<img src="/Images/details_open.png">' );
			   //$('td:eq(0)', nRow).class = 'detailsIcon';
			  </cfif>--->

			  if ( $.inArray(aData['dataTableId'], arrSelected) != -1 )
				{
					$(nRow).removeClass('odd');
					$(nRow).addClass('row_selected');
				}

			$(nRow).addClass('rowData');
		/* else{
			 	$("tr:odd").addClass("odd");
				} */

			  return nRow;

		}

		/*
		 * AFTER DATA RETURNS INSERT Select boxes for filtering --------------
		 */
		function fnInsertSelectFilters (nFoot, aasData, iStart, iEnd, aiDisplay )
		{
			//nFoot.getElementsByTagName('th')[0].innerHTML = "Starting index is "+iStart;
			var oTable = $.fn.dataTableInstance[0];
			var nCells = nFoot.getElementsByTagName('th');
			$("tfoot th").each( function ( i ) {
				var tmp = this.id;
				//alert(tmp);
				//debug(oTable.fnSettings().aoPreSearchCols[i]);
				this.innerHTML = fnCreateSelect( oTable.fnGetColumnData(tmp) );    <!---//"#attrs.arrColumns[i]#"--->
				$('select', this).change( function () {
					oTable.fnFilter( $(this).val(), i );
				} );
			} );

		}

		/*
		 * GET the rows which are currently selected --------------
		 */
		function fnGetSelected( oTableLocal )
		{
		    var aReturn = new Array();
		    var aTrs = oTableLocal.fnGetNodes();

		    for ( var i=0 ; i<aTrs.length ; i++ )
		    {
		        if ( $(aTrs[i]).hasClass('row_selected') )
		        {
		            aReturn.push( aTrs[i] );
		        }
		    }
		    return aReturn;
		}
		/*
		 * HANDLE ERRORS FROM AJAX CALLs  --------------
		 */
		function fnAjaxError(jqXHR, exception){
			if (jqXHR.status === 0) {
				alert('Not connect.\n Verify Network.');
			}
			else
				if (jqXHR.status == 404) {
					alert('Data Source not found. [404]');
				}
				else
					if (jqXHR.status == 500) {
						alert('Internal Server Error [500].');
					}
					else
						if (exception === 'parsererror') {
							alert('Requested JSON parse failed.');
						}
						else
							if (exception === 'timeout') {
								alert('Time out error.');
							}
							else
								if (exception === 'abort') {
									alert('Ajax request aborted.');
								}
								else {
									alert('Uncaught Error.\n' + jqXHR.responseText);
								}
		}

		(function($) {
		/*
		 * Function: fnGetColumnData
		 * Purpose:  Return an array of table values from a particular column.
		 * Returns:  array string: 1d data array
		 * Inputs:   object:oSettings - dataTable settings object. This is always the last argument past to the function
		 *           int:iColumn - the id of the column to extract the data from
		 *           bool:bUnique - optional - if set to false duplicated values are not filtered out
		 *           bool:bFiltered - optional - if set to false all the table data is used (not only the filtered)
		 *           bool:bIgnoreEmpty - optional - if set to false empty values are not filtered from the result array
		 * Author:   Benedikt Forchhammer <b.forchhammer /AT\ mind2.de>
		 */
		$.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
		    // check that we have a column id
		    if ( typeof iColumn == "undefined" ) return new Array();

		    // by default we only wany unique data
		    if ( typeof bUnique == "undefined" ) bUnique = true;

		    // by default we do want to only look at filtered data
		    if ( typeof bFiltered == "undefined" ) bFiltered = true;

		    // by default we do not wany to include empty values
		    if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;

		    // list of rows which we're going to loop through
		    var aiRows;

		    // use only filtered rows
		    if (bFiltered == true) aiRows = oSettings.aiDisplay;
		    // use all rows
		    else aiRows = oSettings.aiDisplayMaster; // all row numbers

		    // set up data array
		    var asResultData = new Array();

		    for (var i=0,c=aiRows.length; i<c; i++) {
		        iRow = aiRows[i];
		        var aData = this.fnGetData(iRow);
		        var sValue = aData[iColumn];

		        // ignore empty values?
		        if (sValue && bIgnoreEmpty == true && sValue.length == 0) continue;

		        // ignore unique values?
		        else if (bUnique == true && jQuery.inArray(sValue, asResultData) > -1) continue;

		        // else push the value onto the result data array
		        else asResultData.push(sValue);
		    }

		    return asResultData;
		}}(jQuery));


		function fnCreateSelect( aData )
		{
		    var r='<select><option value=""></option>', i, iLen=aData.length;
		    for ( i=0 ; i<iLen ; i++ )
		    {
		        r += '<option value="'+aData[i]+'">'+aData[i]+'</option>';
		    }
		    return r+'</select>';
		}

		</cfoutput>
		</script>
 	</head>
 <body>
<!---<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">--->
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td>
			<table class="display" id="datagrid" cellspacing="0">
				<thead>
					<th></th>
					<cfif LEN(attrs.sRowDetailsHtml) GT 0>
						<th></th>
					</cfif>
					<cfloop array="#variables.arrColumns#" index="x">
						<th></th>
					</cfloop>
				</thead>
				<tbody>
				</tbody>
				<tfoot>
					  <tr>
					  	<th id="dataTableId"></th>
					    <cfif LEN(attrs.sRowDetailsHtml) GT 0>
							<th id="detail"></th>
						</cfif>
						<cfloop array="#variables.arrColumns#" index="y">
							<cfoutput><th id="#y#"></th></cfoutput>
						</cfloop>
				  	 </tr>
				</tfoot>
			</table>

        </td>
    </tr>
</table>


</body>
</html>