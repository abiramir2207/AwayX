 <!-----------------------------------------------------------------------------

FILE NAME:		deleteTableRows.cfm
DESCRIPTION:	Delete the rows when the window closes.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	25-Feb-2015	 Delete the rows
							 

------------------------------------------------------------------------------> 
 
<cfset UploadID = URL.Upload_ID />
 <br>
 <br>
 <strong>Clearing cache.... </strong>
<!--- <cfquery name="delDataFromTable" datasource="#application.datasource#">
	DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
</cfquery> --->
<script>
window.close();
</script>
