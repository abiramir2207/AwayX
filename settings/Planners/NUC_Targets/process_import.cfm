<!----------------------------------------------------------------------------------------------------------------------------------
	Template: \settings\Planners\NUC_Targets\process_import.cfm
	  Author: Chris Nguyen
		Date: 2016 December
	 Purpose: Process the import NUC Targets from Excel XLSX file
----------------------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
  <cfsavecontent variable="head_content">
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<cfinclude template="/common_files/jQuery.cfm">

	<cfset jQueryUI.widgets = "tooltip">
	<cfinclude template="/common_files/jQueryUI.cfm">
	<cf_include files="/common_files/datatable.css, /common_files/datatableIcon.css">
	<style>
	  div.header {
		height: 27px;
		margin:0 0 10px 0;
		background-image:
		  linear-gradient(
			to right,
			 #010281, #A7CAF2
		  );
		color: white;
		font-size: 14px;
		font-weight: bold;
		letter-spacing: 0.75px;
		padding:8px 0 0 8px;
	  }
	  #abc { text-align:center; }
	  #abc > .error { font-weight: bold; font-size:13px; color: red; }
	  .exclamation { position:relative; top:5px; height=15; width=15; margin-right:5px; }
	  .datagrid thead tr th { text-align: center; vertical-align: top; }
	  .datagrid tbody tr td { overflow: hidden; }
	  div.file { color: #818152; font-size: 14px; font-weight: bold; letter-spacing:0.25px; text-align: center; margin-bottom: 8px; }
	  div#result { color: #818152; font-size: 12px; font-weight: bold; letter-spacing:0.25px; text-align: center; }
	  .center { text-align: center; }
	  .numeric { text-align: right; }
	</style>
  </cfsavecontent>
  <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
  <cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
	<div class="header">
		NUC TARGETS - IMPORT
	</div>

	<cfset read_failure = false>
	<cftry>
		<!--- column names & column order are important:  do not change them --->
		<cfset excel_columns_list = "group_number,group_desc,promoted_nuc,promoted_nuc_uom,blended_nuc,blended_nuc_uom,case_count,target_margin,group_guid">
		<cfspreadsheet action="read"
						src              = "#url.f#"
						query            = "qExcelEntries"
						headerrow        = "1"
						excludeHeaderRow = "true"
						columnnames      = "#excel_columns_list#">
	<cfcatch type="any">
		<cfset read_failure = true>
		<cfset qExcelEntries = queryNew( excel_columns_list )>
	</cfcatch>
	</cftry>

	<!--- <cfdump var="#qExcelEntries#"> --->
	<cfoutput>
	<div class="file">#getFileFromPath(url.f)#</div>

	<cfset total_errors = 0>	
	<!--- fail the whole file when number of columns is not right or file has no data --->
	<cfif read_failure or listLen(qExcelEntries.columnList) neq listLen(excel_columns_list) or qExcelEntries.recordCount eq 0>
		<div id="abc">
			<img src="/images/Exclamation_Triangle.gif" alt="" class="exclamation"><span class="error">Sorry, something wasn't right in the selected Excel file. Please check the file and try again.</span><br><br>
			<a href="/Manufacturers/home.cfm">#application.util.string.linkFormat('return to home page')#</a>
		</div>
	<cfelse>
		<!--- data table grid --->
		<cfset column_sizes = application.util.array.dtColumnSizeInPercent( [  1,    <!--- row --->
																			   2.5,  <!--- group # --->
																			   5,    <!--- group desc --->
																			   2,    <!--- promoted nuc --->
																			   2,    <!--- promoted nuc uom --->
																			   2,    <!--- blended nuc --->
																			   2,    <!--- blended nuc uom --->
																			   2,    <!--- case count --->
																			   2,    <!--- target margin --->
																			   5     <!--- status --->] )>
		<table class="datagrid" style="table-layout:fixed;">
			<cfloop array="#column_sizes#" index="column_percentage">
				<cfoutput><col width="#column_percentage#%"></cfoutput>
			</cfloop>
			<thead>
			<tr>
				<th><br>ROW ##</th>
			 	<cfset listCnt = 0>
				<cfloop list="#excel_columns_list#" index="thisColumn">
					<cfif thisColumn neq "group_guid">
						<cfset listCnt++>
					 	<th>#chr(listCnt + 64)# <br> <!---display Excel column headings: A, B, C, ... --->
					 		#uCase( replace(thisColumn,'_',' ','all') )#
					 	</th>
					</cfif>
				</cfloop>
				<th class="added"><br>PROBLEMS</th>
			</tr>
			</thead>
			<tbody>
			<cfset total_errors = 0>
			<cfloop query="qExcelEntries">
				<cfset row_errors = []>
				<cfif qExcelEntries.group_guid eq "">
					<cfset arrayAppend(row_errors, "missing guid")>
				<cfelseif application.util.string.isGUID(qExcelEntries.group_guid) eq false>
					<cfset arrayAppend(row_errors, "invalid guid")>
				</cfif>

				<!-------------------->
				<!--- PROMOTED NUC --->
				<!-------------------->
				<cfif qExcelEntries.promoted_nuc neq "">
					<cfif qExcelEntries.promoted_nuc_uom eq "">
						<cfset arrayAppend(row_errors, "missing uom in D")>
					<cfelseif trim(qExcelEntries.promoted_nuc_uom) neq "CS"
							and trim(qExcelEntries.promoted_nuc_uom) neq "LB"
							and trim(qExcelEntries.promoted_nuc_uom) neq "EA" 
							and trim(qExcelEntries.promoted_nuc_uom) neq "UN" >
						<cfset arrayAppend(row_errors, "invalid uom in D")>
					<cfelseif isNumeric(qExcelEntries.promoted_nuc) eq false>
						<cfset arrayAppend(row_errors, "invalid number in C")>
					</cfif>
				</cfif> <!--- qExcelEntries.promoted_nuc neq ""> --->

				<!------------------->
				<!--- BLENDED NUC --->
				<!------------------->
				<cfif qExcelEntries.blended_nuc neq "">
					<cfif qExcelEntries.blended_nuc_uom eq "">
						<cfset arrayAppend(row_errors, "missing uom in F")>
					<cfelseif trim(qExcelEntries.blended_nuc_uom) neq "CS"
							and trim(qExcelEntries.blended_nuc_uom) neq "LB"
							and trim(qExcelEntries.blended_nuc_uom) neq "EA" 
							and trim(qExcelEntries.blended_nuc_uom) neq "UN">
						<cfset arrayAppend(row_errors, "invalid uom in F")>
					<cfelseif isNumeric(qExcelEntries.blended_nuc) eq false>
						<cfset arrayAppend(row_errors, "invalid number in E")>
					</cfif>
				</cfif> <!--- qExcelEntries.blended_nuc neq ""> --->

				<!------------------>
				<!--- CASE COUNT --->
				<!------------------>
				<cfif qExcelEntries.case_count neq "">
					<cfif isNumeric(qExcelEntries.case_count) eq false>
						<cfset arrayAppend(row_errors, "invalid number in G")>
					</cfif>
				</cfif> <!--- qExcelEntries.case_count neq ""> --->

				<!--------------------->
				<!--- TARGET MARGIN --->
				<!--------------------->
				<cfif qExcelEntries.target_margin neq "">
					<cfif isNumeric(qExcelEntries.target_margin) eq false>
						<cfset arrayAppend(row_errors, "invalid number in H")>
					</cfif>
				</cfif> <!--- qExcelEntries.target_margin neq ""> --->

				<cfif arrayLen(row_errors) gt 0>
					<cfset total_errors++>
					<tr>
						<td class="center">#qExcelEntries.currentrow#</td>
						<td>#qExcelEntries.group_number#</td>
						<td>#qExcelEntries.group_desc#</td>
						<td class="numeric">#qExcelEntries.promoted_nuc#</td>
						<td class="center">#qExcelEntries.promoted_nuc_uom#</td>
						<td class="numeric">#qExcelEntries.blended_nuc#</td>
						<td class="center">#qExcelEntries.blended_nuc_uom#</td>
						<td class="numeric">#qExcelEntries.case_count#</td>
						<td class="numeric">#qExcelEntries.target_margin#</td>
						<td>#arrayToList(row_errors, ", ")#</td>
					</tr>
				</cfif>

				<cfif qExcelEntries.currentRow eq qExcelEntries.recordCount>
				</cfif>
			</cfloop>
			</tbody>
		</table>

		<hr class="two">
		<div id="result">
			<cfif total_errors gt 0>
				#total_errors# row#(total_errors gt 1 ? 's' : '')# have problems. Please make corrections in your Excel file and try again.<br>
			<cfelse>
				<!--- save entries in Excel file to the database --->
				<cfloop query="qExcelEntries">
					<cfif trim(qExcelEntries.promoted_nuc_uom) eq "CS">
						<cfset variables.promoted_nuc_uom = 1>
					<cfelseif trim(qExcelEntries.promoted_nuc_uom) eq "LB">
						<cfset variables.promoted_nuc_uom = 2>
					<cfelseif trim(qExcelEntries.promoted_nuc_uom) eq "EA" OR trim(qExcelEntries.promoted_nuc_uom) eq "UN" >
						<cfset variables.promoted_nuc_uom = 5>
					<cfelse>
						<cfset variables.promoted_nuc_uom = 0>
					</cfif>
					<cfif trim(qExcelEntries.blended_nuc_uom) eq "CS">
						<cfset variables.blended_nuc_uom = 1>
					<cfelseif trim(qExcelEntries.blended_nuc_uom) eq "LB">
						<cfset variables.blended_nuc_uom = 2>
					<cfelseif trim(qExcelEntries.blended_nuc_uom) eq "EA" OR trim(qExcelEntries.blended_nuc_uom) eq "UN" >
						<cfset variables.blended_nuc_uom = 5>
					<cfelse>
						<cfset variables.blended_nuc_uom = 0>
					</cfif>

					<cfquery result="qUpdate" datasource="#application.datasource#">
                        /* this set is needed to get the correct record count back */
                        SET NOCOUNT OFF

						UPDATE NUC_Targets
							SET
								Promoted_NUC		 = #val(qExcelEntries.promoted_nuc)#,
								<cfif variables.promoted_nuc_uom gt 0>
									Promoted_NUC_UOM = #variables.promoted_nuc_uom#,
								</cfif>
								Blended_NUC			= #val(qExcelEntries.blended_nuc)#,
								<cfif variables.blended_nuc_uom gt 0>
									Blended_NUC_UOM = #variables.blended_nuc_uom#,
								</cfif>
								Case_Count          = #val(qExcelEntries.case_count)#,
								Target_Margin       = #val(qExcelEntries.target_margin)#,
								Updated_Date		= GetDate(),
								Updated_By			= '#request.accessStructure.User_Id#'
							WHERE
								Product_Group_ID = '#trim(qExcelEntries.group_guid)#' AND
								Deleted = 0
					</cfquery>

                    <!--- the update was not successful --->
                    <cfif qUpdate.recordCount eq 0>
                        <!--- look for retail product group setting (i.e. Qbrand) & save it into a request variable for subsequent references --->
                        <cfif structKeyExists(request, "qTarget_product") eq false>
                            <cfquery datasource="#application.datasource#" name="request.qTarget_product">
                                SELECT s.Value                                                     AS Product_Group_Level_Id
                                       , Ltrim( Rtrim( pga.Product_Group_Attribute_Table ) )           AS Product_Group_Attribute_Table
                                       , Ltrim( Rtrim( pga.Product_Group_Attribute_Master_Id_Field ) ) AS Product_Group_Attribute_Master_Id_Field
                                       , Ltrim( Rtrim( pga.Product_Group_Attribute_Name_Field ) )      AS Product_Group_Attribute_Name_Field
                                       , Ltrim( Rtrim( pga.Product_Group_Attribute_Number_Field ) )    AS Product_Group_Attribute_Number_Field
                                FROM _SETTINGS s
                                    LEFT JOIN PRODUCT_GROUP_ATTRIBUTE pga
                                            ON pga.Product_Group_Level_Id = CASE
                                                                                WHEN Isnull( s.Value, '' ) = '' THEN 11
                                                                                ELSE s.Value
                                                                            END
                                WHERE s.Input_Name = 'Retail_Target_Product_Group' 
                            </cfquery>
                        </cfif>

                        <!--- retail product group setting (i.e. Qbrand) exists --->
                        <cfif request.qTarget_product.recordCount>
                            <!--- create NUC_Targets --->
                            <cfoutput>
                                <cfquery datasource="#application.datasource#">
                                    INSERT INTO NUC_Targets
                                        ( Product_Group_ID
                                        , Created_By
                                        , Created_Date
                                        , Promoted_NUC
                                        , Promoted_NUC_UOM
                                        , Blended_NUC
                                        , Blended_NUC_UOM
                                        , Case_Count
                                        , Target_Margin )

                                    SELECT '#trim(qExcelEntries.group_guid)#'
                                            , '#request.accessStructure.User_Id#'
                                            , GETDATE()
                                            , #val(qExcelEntries.promoted_nuc)#
                                            , <cfif variables.promoted_nuc_uom gt 0> #variables.promoted_nuc_uom# <cfelse> NULL </cfif>
                                            , #val(qExcelEntries.blended_nuc)#
                                            , <cfif variables.blended_nuc_uom gt 0> #variables.blended_nuc_uom# <cfelse> NULL </cfif>
                                            , #val(qExcelEntries.case_count)#
                                            , #val(qExcelEntries.target_margin)#
                                      FROM #request.qTarget_product.Product_Group_Attribute_Table#
                                     WHERE #request.qTarget_product.Product_Group_Attribute_Master_ID_Field# = '#trim(qExcelEntries.group_guid)#'
                                </cfquery>
                            </cfoutput>
                        </cfif>
                    </cfif>     <!--- <cfif qUpdate.recordCount eq 0> --->
				</cfloop>
				#qExcelEntries.recordCount# rows in the above Excel file have been loaded successfully.<br>
			</cfif>
			<a href="/Manufacturers/home.cfm" style="font-weight:normal;font-size:11px;">#application.util.string.linkFormat('return to home page')#</a>
		</div>
	</cfif>
	</cfoutput>

	<cfinclude template="/common_files/dataTables2.cfm">

  	<script>
		<cfif total_errors eq 0>
			jQuery('table.datagrid').hide();
		<cfelse>
			jQuery('table.datagrid').DataTable({
	                               "aaSorting": []
							      ,"aoColumns": [
							                       {"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                      ,{"bSortable":false, "bSearchable":false}
							                    ]
	                              ,"bAutoWidth": false
	                              ,"bPaginate": false
	                              ,"bSortClasses": false
	                              ,"bScrollCollapse": true
	                              ,"bFilter": false
								  ,"language": {"emptyTable": <cfoutput>"<b>No problems in Excel import.</b>"</cfoutput>}
	                              ,"sDom": 't'
	                              ,"scrollY": Math.floor(jQuery(window).height()) - 190
	                            });
			jQuery('tbody').on('hover', 'tr', function() { jQuery(this).toggleClass("over"); });
		</cfif>
	</script>

	<cfinclude template="/common_files/focus.cfm">
</body>
</html>