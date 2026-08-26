<!---
  * ==================================================================================================== 
  *    @File: \billbacks\gm\ajax\upload_history
  *  @Author: Tim FOrd
  *    @Date: 8/17/2020
  * 
  * @Remarks: Billback Upload History - upload and history tab Ajax backend (under home tab)
  *
  * ==================================================================================================== 
--->
<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">

		<cfscript>
			param form.dateRangeStartValueKeyword = now();
			param form.dateRangeEndValueKeyword   = now();
		</cfscript>

<cfinvoke   component = "mvc.Models.Billback.BillbackUploadDAO"
            method    = "getUploadHistory"
            argStart  = "#form.dateRangeStartValueKeyword#"
            argEnd    = "#form.dateRangeEndValueKeyword#"
            returnvariable = "qRows">

<!--- ~~~~~~~~~~~~~ hidden columns are placed in the leading positions ~~~~~~~~~~~~~~ --->
<cfoutput>{ "COUNT":#(isDefined("qRows.NumberofRecords") ? -999 : qRows.recordCount)#
            ,"ROWS":#application.util.query.toDtJSON(qRows, 
                                                    arrayToList([
                                                        <!--- 0 --->  "upload_id"
                                                        <!--- 1 --->  ,"user_id"
                                                        <!--- 2 --->  ,"total_header_count"
                                                        <!--- 3 --->  ,"total_header_count_failed"
                                                        <!--- 4 --->  ,"total_header_count_loaded"
                                                        <!--- 5 --->  ,"total_detail_count"
                                                        <!--- 6 --->  ,"total_detail_count_failed"
                                                        <!--- 7 --->  ,"total_detail_count_loaded"
                                                        <!--- 8 --->  ,"upload_date"                                                       
                                                        <!--- 9 --->  ,"upload_status"
                                                        <!--- 10 ---> ,"deleted"
                                                        <!--- 11 ---> ,"header_file_name"
                                                        <!--- 12 ---> ,"detail_file_name"
                                                        <!--- 13 ---> ,"deleted_by"
                                                        <!--- 14 ---> ,"deleted_date"
                                                        <!--- 15 ---> ,"upload_type"
                                                        <!--- 16 ---> ,"VendorSearchField"
                                                        <!--- 17 ---> ,"Name_First"
                                                        <!--- 18 ---> ,"Name_Last"
                                                         <!---19 ---> ,"BBTitleSearchField"
                                                        <!--- 20 ---> ,"BBCodeSearchField"
                                                    ])
)#}</cfoutput>


















