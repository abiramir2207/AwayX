<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\dataTables2.cfm
      Date:     2015 April
      Author:   Chris Nguyen
      Purpose:  Load the new MODERN DataTables JS from MS CDN for better performance (or from local server when MS
      			CDN is blocked)

      Remark:   Use the other \Common_Files\dataTables.cfm for the CLASSIC DataTables (version 1.8.1)
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="datatables.version"    default="1.10.10">
<cfparam name="datatables.extensions" default="">

<!---------------------------------------------------------------------
	Handling for 2 different ways to call this include file:
	1.  cf_include files = ( when caller variable scope is available )
	2.  cfinclude template =
---------------------------------------------------------------------->
<cfif isDefined("caller.datatables.version")>
	<cfset local.datatables.version = caller.datatables.version>
<cfelse>
	<cfset local.datatables.version = datatables.version>
</cfif>

<cfif isDefined("caller.datatables.extensions")>
	<cfset local.datatables.extensions = caller.datatables.extensions>
<cfelse>
	<cfset local.datatables.extensions = datatables.extensions>
</cfif>


<cfif local.datatables.version eq "1.10.10">
	<cfoutput><cf_include files="/script/javascript/jquery.dataTables-#local.datatables.version#.min.js">
	<script>if (!$.isFunction($.fn.dataTable)) { var s = document.createElement("script"); s.src = "/script/javascript/jquery.dataTables-#local.datatables.version#.min.js"; $("head").append(s); }</script></cfoutput>

<!------------------------------------------------>
<!--- introduced version 1.10.19 on 2019 Feb 6 --->
<!------------------------------------------------>
<cfelseif local.datatables.version eq "1.10.19">

	<cfset source_root = "/script/javascript/datatables">

	<!--- load compact version for production site --->
	<cfset min_file = ( application.util.io.isProduction() ? ".min" : "" )>

	<cfoutput><cf_include files="#source_root#/datatables-1.10.19/js/jquery.dataTables#min_file#.js, #source_root#/datatables-1.10.19/css/jquery.dataTables#min_file#.css"></cfoutput>

	<!--- load extensions --->
	<cfscript>
		css_extensions = [];
		js_extensions  = [];
		all_extensions = listToArray(local.datatables.extensions);

		// gather all needed extensions :: both css and js
		for (counter = 1; counter lte arrayLen(all_extensions); counter++ ) {
	
			switch (trim(all_extensions[counter])) {
				case "autofill":
					arrayAppend(css_extensions, source_root & "/autofill-2.3.2/css/autoFill.dataTables.css");
					arrayAppend(js_extensions,  source_root & "/autofill-2.3.2/js/dataTables.autoFill#min_file#.js");
					break;
				case "buttons": 
					arrayAppend(css_extensions, source_root & "/buttons-1.6.1/css/buttons.datatables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/buttons-1.6.1/js/datatables.buttons#min_file#.js");
					arrayAppend(js_extensions,  source_root & "/buttons-1.6.1/js/buttons.colvis#min_file#.js");
					arrayAppend(js_extensions,  source_root & "/buttons-1.6.1/js/buttons.html5#min_file#.js");
                    arrayAppend(js_extensions,  source_root & "/buttons-1.6.1/js/buttons.print#min_file#.js");

                    // export to excel needs this jszip extension
					arrayAppend(js_extensions,  source_root & "/jszip-2.5.0/jszip#min_file#.js");
					break;
				case "colreorder":
					arrayAppend(css_extensions, source_root & "/colreorder-1.5.0/css/colReorder.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/colreorder-1.5.0/js/dataTables.colReorder#min_file#.js");
                    break;
                case "editor":
					arrayAppend(css_extensions, source_root & "/editor-1.8.1/css/editor.datatables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/editor-1.8.1/js/datatables.editor#min_file#.js");
                    break;
				case "fixedcolumns":
					arrayAppend(css_extensions, source_root & "/fixedcolumns-3.2.5/css/fixedColumns.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/fixedcolumns-3.2.5/js/dataTables.fixedColumns#min_file#.js");
					break;
				case "fixedheader":
					arrayAppend(css_extensions, source_root & "/fixedheader-3.1.4/css/fixedHeader.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/fixedheader-3.1.4/js/dataTables.fixedHeader#min_file#.js");
					break;
				case "keytable":
					arrayAppend(css_extensions, source_root & "/keytable-2.5.0/css/keyTable.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/keytable-2.5.0/js/dataTables.keyTable#min_file#.js");
					break;
				case "jsZip":
					arrayAppend(js_extensions,  source_root & "/jszip-2.5.0/jszip#min_file#.js");
					break;
				case "responsive":
					arrayAppend(css_extensions, source_root & "/responsive-2.2.2/css/responsive.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/responsive-2.2.2/js/dataTables.responsive#min_file#.js");
					break;
				case "rowgroup":
					arrayAppend(css_extensions, source_root & "/rowgroup-1.1.0/css/rowGroup.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/rowgroup-1.1.0/js/dataTables.rowGroup#min_file#.js");
					break;
				case "rowreorder":
					arrayAppend(css_extensions, source_root & "/rowreorder-1.2.4/css/rowReorder.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/rowreorder-1.2.4/js/dataTables.rowReorder#min_file#.js");
					break;
				case "pdfmake":
					arrayAppend(js_extensions,  source_root & "/pdfmake-0.1.36/pdfmake#min_file#.js");
					arrayAppend(js_extensions,  source_root & "/pdfmake-0.1.36/vfs_fonts.js");
					break;
				case "scroller":
					arrayAppend(css_extensions, source_root & "/scroller-1.5.0/css/scroller.dataTables#min_file#.css");
					arrayAppend(js_extensions,  source_root & "/scroller-1.5.0/js/dataTables.scroller#min_file#.js");
					break;
				case "select":
					arrayAppend(css_extensions, source_root & "/select-1.2.6/css/select.dataTables.css");
					arrayAppend(js_extensions,  source_root & "/select-1.2.6/js/dataTables.select.js");
					break;
			};
		};
	</cfscript>

	<!--------------------------------------------------------------------------------------->
	<!--- pull extension resources from CDN if applicable otherwise from local web server --->
	<!--------------------------------------------------------------------------------------->
	<cfif arrayLen(css_extensions)>
		<cfoutput><cf_include files="#arrayToList(css_extensions)#"></cfoutput>
	</cfif>

	<cfif arrayLen(js_extensions)>
		<cfoutput><cf_include files="#arrayToList(js_extensions)#"></cfoutput>
	</cfif>					


	<!------------------------------------------------------>
	<!--- override default css styles go in this section --->
	<!------------------------------------------------------>
	<cfsavecontent variable="custom_styles">
        <style>
            table.dataTable {
                border-collapse: collapse;
            }

			table.dataTable thead th, table.dataTable thead td, table.dataTable tfoot td { 
                padding: 6px 10px;	
                font-size: 12px;
			}

			table.dataTable.display tbody tr.odd {
				background-color: #F5F6FA;
			}

			table.dataTable.hover tbody tr:hover, table.dataTable.display tbody tr:hover {
				background-color: #E6F0FF;
			}

			table.dataTable.display tbody tr.selected
			,table.dataTable tbody > tr.selected, table.dataTable tbody > tr > .selected  {
				background-color: #BFD9FF;
			}

			table.dataTable tbody td {
				padding: 5px 10px;
			}

			/* Dense rows  - if wanted, include class "dense" on the table */
			table.dataTable.dense tbody td {
				padding: 2px 10px;
			}

			table.dataTable thead {
				background-color:#FFCE84;
			}
			
			table.dataTable th {
				text-align:left !important;
				color: rgba(0,0,0,0.9);
			}
			
			table.dataTable td {
				color:rgba(0,0,0,0.8);
			}
			
			table.dataTable.display tbody tr.selected,
			table.dataTable.display tbody > tr.odd.selected,
			table.dataTable.display tbody > tr.selected:hover {
				background-color: #BFD9FF;
			}
			/* center the checkmark in the box */
			table.dataTable tr.selected td.select-checkbox:after, table.dataTable tr.selected th.select-checkbox:after {
				margin-top:-7px;
				margin-left: -5px;
            }
        </style>		
        
        <script>
            function draw_callback() {
                /* replace default button class with ours, shorthen margin */
                $("button.dt-button")
                        .removeClass("dt-button")
                        .addClass("button")
                        .css("margin", "0 2px");
            }
        </script>
	</cfsavecontent>

    <cfoutput>#application.util.string.compress( custom_styles )#</cfoutput>
        
<cfelse>
    <cfoutput><script>if (!$.isFunction($.fn.dataTable)) { var s = document.createElement("script"); s.src = "/script/javascript/jquery.dataTables-#datatables.version#.min.js"; $("head").append(s); }</script></cfoutput>    
</cfif>

<cfif left(local.datatables.version,4) eq "1.10">
    <script>
        // default grid properties
        $.extend( true, $.fn.dataTable.defaults, {
            "language": {
                          "loadingRecords": "<img src='/images/prettyPhoto/default/loader.gif'> <span style='display:inline-block;position:relative;top:-5px;padding-left:7px;'>Please wait while we are processing your request...</span>"
                        }
        } );
    </script>
</cfif>

<script>
    if (!Math.trunc) {
        Math.trunc = function (v) {
            return v < 0 ? Math.ceil(v) : Math.floor(v);
        };
    }
    
    // convert pixels into vh value
    function pixelToVH(value) {
        return Math.trunc((100 * value) / window.innerHeight);
    }    
</script>
<cfsetting enableCFoutputOnly = "no">
