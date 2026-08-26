<!---------------------------------------------------------------------------------------------------------------------
	  Template: \CustomTags\include.cfm
	  Date:     2015 November
	  Author:   Chris Nguyen
	  Purpose:  Include JavaScript/CSS file with version number based on file modification timestamp
				to avoid browser caching issues

	  Parameter:  attributes.files = (new) required :: use this instead of file_to_include
				  attributes.file_to_include = (old) required, relative path file names with extensions
					(e.g. '/common_files/datatable.css' or
						  '/program_wizard/component_select_templates_grid_js.js' or
						  '/Common_Files/Delete_Functions.js,/script/javascript/string_functions.js'
						  )

	  Documentation: http://kb.awayx.com/index.php?/article/AA-00416/9/CSS-JS-Versioning.html
---------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<cfscript>
	if (thisTag.executionMode is "start") {
		// array of js files on forge cdn
		js_on_forge_cdn  = [
								"ag-grid-enterprise",
                                "dataTables",
                                "dayjs",
								"dhtmlxmessage",
								"dhtmlxwindows",
								"dhtmlxscheduler",
								"dropzone",
								"jquery-1.7.2",
								"jquery-1.10.2",
								"jquery-1.12.4",
                                "jquery.cfjs",
                                "jquery-ui-1.12.1.custom",
								"noty",
								"jquery.numeric",
                                // "multiple-select",
                                "multiselect",
								"numeral",
								"vue-js",
								// these are datatables extensions
								"jszip-2.5.0",
								"autofill-2.3.2",
								"autonumeric",
								"buttons-1.5.4",
								"buttons-1.6.1",
								"colreorder-1.5.0",
								"fixedcolumns-3.2.5",
								"fixedheader-3.1.4",
								"keytable-2.5.0",
								"pdfmake-0.1.36",
								"responsive-2.2.2",
								"rowgroup-1.1.0",
								"rowreorder-1.2.4",
								"scroller-1.5.0",
								"select-1.2.6"
							];

		// array of css files on forge cdn
		css_on_forge_cdn = [
                                "ag-grid.css",
                                "ba-ag-theme-balham",
								"css-loader",
								"dhtmlxmessage",
								"dhtmlxwindows",
								"dhtmlxscheduler",
								"dropzone",
								"noty",
                                "multiple-select",
                                "multiselect",
								"tailwind",
                                "jquery.datatables",
                                "jquery-ui-1.12.1.custom",
                                "all.css",    // font awesome
								// these are datatables extensions
								"jszip-2.5.0",
								"autofill-2.3.2",
                                "buttons-1.5.4",
                                "buttons-1.6.1",
								"colreorder-1.5.0",
								"fixedcolumns-3.2.5",
								"fixedheader-3.1.4",
								"keytable-2.5.0",
								"pdfmake-0.1.36",
								"responsive-2.2.2",
								"rowgroup-1.1.0",
								"rowreorder-1.2.4",
								"scroller-1.5.0",
								"select-1.2.6"
                            ];

		// Azure CDN requires lower case
		variables.files  = lcase(trim( structKeyExists(attributes, "files") ? attributes.files : attributes.file_to_include ));

		// create an array to save included files
		if (structKeyExists(request, "included_files") is false) {
			request.included_files = [];
		}

        //
        // validate CDN on first include on current page
        //
        if ( request.included_files.len() eq 0 ) {
            udf_component = createObject("component", "components.udf");

            // missing/invalid cdn variables found, validate CDN to create them
            if ( isDefined("application.cdn_retest_minutes") eq false or isNumeric(application.cdn_retest_minutes) eq false
                or isDefined("application.cdn_available") eq false
                or isDefined("application.cdn_tested_date") eq false or isDate(application.cdn_tested_date) eq false) {
                udf_component.validate_CDN();
            }

            //  periodically validate CDN based on setting & tracking information
            else if ( val(application.cdn_retest_minutes) gt 0
                        and dateDiff('n', application.cdn_tested_date, now()) gt application.cdn_retest_minutes ) {
                    udf_component.validate_CDN();
            }
        }

		// parse the list of files to include & include it
		for (variables.single_file in variables.files) {
			variables.single_file    = trim(variables.single_file);
			variables.file_extension = listLast(variables.single_file, ".");

			// carry out the include action when file has not been previously included
			if (arrayFindNoCase(request.included_files, variables.single_file) eq 0) {

				variables.forge_cdn = '';
				// save the included file into a request variable
				arrayAppend(request.included_files, variables.single_file);

				switch (variables.file_extension) {
					// JavaScript
					case "js":
						// is this file available on FORGE CDN?
						for (variables.cdn_file in js_on_forge_cdn) {
							if (variables.single_file contains variables.cdn_file) {
								if (isDefined("application.cdn_available") and application.cdn_available) {
                                    variables.forge_cdn = application.forge_cdn;
                                }
								break;
							}
						}
						variables.charset = (variables.single_file contains "jquery.mark.")
												? 'charset="UTF-8"'
												: '';

						writeOutput('<script src="#variables.forge_cdn##variables.single_file#?v=#application.util.dateTime.fileVersion( variables.single_file )#" #variables.charset#></script>');
						break;

					// CSS
					case "css":
						// is this file available on FORGE CDN?
						for (variables.cdn_file in css_on_forge_cdn) {
							if (variables.single_file contains variables.cdn_file) {
								if (isDefined("application.cdn_available") and application.cdn_available) {
                                    variables.forge_cdn = application.forge_cdn;
                                }
								break;
							}
						}

						writeOutput('<link rel="stylesheet" type="text/css" href="#variables.forge_cdn##variables.single_file#?v=#application.util.dateTime.fileVersion( variables.single_file )#">');
						break;

					// CFM
					case "cfm":
						include "#variables.single_file#";
						break;
				}
			}
		}
	}
</cfscript>
</cfoutput>

