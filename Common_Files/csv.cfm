<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\csv.cfm
      Date:     Nov 5 2012
      Author:   Chris Nguyen
      Purpose:  Export csv text to csv file
      
      Required parameters:
      		1. form.csv_text:  CSV string delimited by commas

      Optional parameters:
      		1. form.csv_file_name:  CSV output file name
      		
----------------------------------------------------------------------------------------------------------------------->

<cfparam name="form.csv_file_name" default="export.csv">

<cfoutput>
<cfheader name="Content-disposition" value="attachment;filename=#form.csv_file_name#">
<cfcontent type="text/csv">#replace(form.csv_text,'&amp;','&','ALL')#
</cfoutput>