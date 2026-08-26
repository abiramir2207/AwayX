<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Planning_Groups\exportByGroups.cfm
      Date:     2015 March
      Author:   Chris Nguyen
      Purpose:  Export members in selected planning groups to an Excel file

      Required Elements in posting FORM:
      1. form.pg_type = 'product' | 'distributor' | 'operator'
      2. form.checkBoxName = checkbox input name ( 'chkPGProductCatID' | 'chkPGCustomerCatID' | 'chkPGOperatorCatID' )
      2. form[ form.checkBoxName ] = comma-delimited list of planning group category IDs
----------------------------------------------------------------------------------------------------------------------->
<cfsilent>
    <cfset variables.webServerPath = "#application.doc_path#\data_files\created\settings\planning_groups\">

	<cfscript>
		variables.isDebugging = IsDebugMode();
		variables.excelFile   = createUUID() & ".xlsx";    // create a unique file name
		
		server_drives = [ "C:", "D:", "E:", "F:" ];
		/* eliminate drive letter from path */
		for (i = 1; i <= arrayLen(server_drives); i++){
			variables.webServerPath = replaceNoCase(variables.webServerPath, server_drives[i], "");
		};
		
		variables.dbServerPath = "\\" 	& application.webServerName 
										& variables.webServerPath 
										& variables.excelFile;     // path + file name for db server to write to
	</cfscript>

	<!---create new folder to store Excel files --->
	<cfif not DirectoryExists(variables.webServerPath)>
		<cfdirectory directory = "#variables.webServerPath#" action = "create">
	</cfif>

    <cfquery name="variables.getData" datasource="#application.datasource#">
        IF Object_Id( 'tempdb..##tmp_PG_type') IS NOT NULL
            DROP TABLE ##tmp_PG_type

        CREATE TABLE ##tmp_PG_type (PG_Type VARCHAR( 20 ), PG_Category_Id UNIQUEIDENTIFIER)

        <!--- place all selected planning group IDs in a temp table to share with the stored procedure --->
        <cfoutput>
        <cfloop list="#form[ form.checkBoxName ]#" index="variables.singleCatID">
            INSERT INTO ##tmp_PG_type VALUES ('#form.pg_type18#', '#variables.singleCatID#')
        </cfloop>
        </cfoutput>

        <cfif variables.isDebugging>
            SELECT * FROM ##tmp_PG_type
        </cfif>
        <cfoutput>EXEC USP_EXTRACT_PG_MEMBERS_LIST  @excel_result_file_name='#variables.excelFile#',  @excel_result_full_path='#variables.dbServerPath#'</cfoutput>
    </cfquery>

    <!--- TODO: change 1 to 0 before checking the code in --->
    <cfif 0>
        <cfset variables.excelFile = "48055.xlsx">
    </cfif>
</cfsilent>

<!--- result came back successfully --->
<cfif fileExists( variables.webServerPath & variables.excelFile )>
    <!--- replace backslashes which cause problems in window.open --->
    <cfset variables.webServerPath = replace( variables.webServerPath, '\', '/', 'all' )>
    <script>
        <cfoutput>window.open('/common_files/openContent.cfm?type=xls&fileName=#variables.excelFile#' + '&webServerPath=#variables.webServerPath#', 'openContent', 'height=50,width=10,top=0,left=0');</cfoutput>
        // window.close();    // close window with gathering info message
    </script>
<cfelse>
    <!--- <!doctype html>
    <html>
    <head>
    <title>Export Members</title>
    </head>
    <body>
        <cfif variables.isDebugging>
            <cfdump var="#form#" label="FORM">
            <cfdump var="#variables.getData#" label="TMP_PG_MEMBER">
        </cfif>
        <!--- problems occurred inform users and bail out --->
        <cfinclude template="/common_files/jQuery.cfm">

        <script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
        <script>
            noty( {  text:"We are sorry for the inconvenience.<br>But we are unable to execute<br>this action at this time."
                    ,type:'error'
                    ,buttons: [  { text:'close', onClick:function($noty) {  $noty.close(); window.close(); } } ]
                    ,layout:'center' });
        </script>
    </body>
    </html> --->
    <cfif variables.isDebugging>
        <cfdump var="#form#" label="FORM">
        <cfdump var="#variables.getData#" label="TMP_PG_MEMBER">
    </cfif>
    <script>
        alert("We are sorry for the inconvenience. But we are unable\n to execute this action at this time.");
    </script>
<!---
        <!--- problems occurred inform users and bail out --->
        <cfinclude template="/common_files/jQuery.cfm">

        <script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
        <script>
            noty( {  text:"We are sorry for the inconvenience.<br>But we are unable to execute<br>this action at this time."
                    ,type:'error'
                    ,buttons: [  { text:'close', onClick:function($noty) {  $noty.close(); } } ]
                    ,layout:'bottom' });
        </script>
 --->
</cfif>
