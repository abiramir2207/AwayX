<!---
       Name:          upload_history_columns.cfm
       Copyright:     Copyright (c) 2019 Blacksmith Applications, Inc.
       Created Date:  15-Nov-2019
       Created By:    Anand Rao
       Label:		  
       Description:  This Page loads the list of Columns used in the AG grid.
--->

<cfscript>
/* header */
 uploadHistory_columns_arr = 
			["UPLOAD_ID"
			,"USER_ID"
			,"TOTAL_HEADER_COUNT"
			,"TOTAL_HEADER_COUNT_FAILED"
			,"TOTAL_HEADER_COUNT_LOADED"
			,"TOTAL_DETAIL_COUNT"
			,"TOTAL_DETAIL_COUNT_FAILED"
			,"TOTAL_DETAIL_COUNT_LOADED"
			,"UPLOAD_DATE"
			,"UPLOAD_STATUS"	
			,"UPLOAD_TYPE_ID"
			,"UPLOAD_TYPE"
			,"DELETED"
			,"DELETED_BY"
			,"DELETED_DATE"
			,"HEADER_FILE_NAME"	
			,"DETAIL_FILE_NAME"
			,"USER_CODE"
			,"UPLOAD_STATUS_LINK"
			,"ACTION_LINK"
			,"REPORT_HEADER_FILENAME"
			,"REPORT_DETAIL_FILENAME"
			,"ROWS_CNT"
			];
</cfscript>