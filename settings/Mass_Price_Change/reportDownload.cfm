<cfsilent>
<!---  
       Name:          index.cfm           
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.       
       Created Date:  06/10/2013
       Created By:    Kal
       Label:		  34605
       Description:   Mass Price Change Utility
--->
</cfsilent>

<!--- get the path to the report file --->
<cfset fileName = "Mass_Price_Change_Report_" & DateFormat(now(),"yyyy_mm_dd") & ".xlsx" />
<cfset fileNamePath = application.Doc_Path & "\Temp_Files\Report\" & fileName />


<!--- download the file --->
<cfheader name="Content-Disposition" value="attachment" >
<cfcontent type="application/vnd.ms-excel" file="#fileNamePath#">

