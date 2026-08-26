<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\contracts\ajax\uploadRebate.cfm
      Date:     2014 June
      Author:   Chris Nguyen
      Purpose:  Import rebate

      Parameters:   URL.ProgramID  =  CONTRACT_MAIN.Contract_Main_ID
                    URL.CompID     =  Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
----------------------------------------------------------------------------------------------------------------------->
<cfsetting requesttimeout="600">       <!--- increased timeout setting to 10 min. to allow big file to be processed --->
<cfinvoke
    component="components.billback.billbackuploadutility"
    method="getUploadPath"
    returnVariable="variables.destination">

<cfinvoke
    component="Mvc.Models.Program.Component.ComponentDefManager"
    method="getComponentUomData"
    returnVariable="variables.uomArray">
      <cfinvokeargument name="programID" value="#url.programID#">
      <cfinvokeargument name="type" value="2">
</cfinvoke>

<cfscript>
  // variables.destinationPath = '#application.Doc_Path#\data_files\rebate_upload';
  variables.errorFile  = application.util.io.TempFileName() & ".html";
</cfscript>

<!--- <cfif ( not directoryExists( variables.destinationPath ) )>
  <cfdirectory action="create" directory="#variables.destinationPath#" >
</cfif> --->

<cftry>
    <cffile action="upload" destination="#variables.destination.File_Path#" nameconflict="makeunique" result="variables.upload">
    <cfcatch>
        <cfdump var="#cfcatch#" output="#variables.errorFile#" format="html">
        <cfsetting enablecfoutputonly="false">
        <cfoutput>#serializeJSON({STATUS=500, MESSAGE=variables.errorFile})#</cfoutput>
        <cfabort>
    </cfcatch>
</cftry>

<!--- Read the .csv file content into memory --->
<cfset variables.csv = fileRead( variables.upload.serverDirectory & "\" & variables.upload.serverFile )/>

<!--- <cffile action="copy" destination="#variables.destination.File_Path#\#variables.upload.serverFile#" source="#variables.csv#"> --->

<cfscript>
  variables.delimiter = ",";
  variables.textqualifier = """";
  variables.csvFile = variables.upload.serverDirectory & "\" & variables.upload.serverFile;

  variables.escapedDelimiter = regExSafe( variables.delimiter );
  variables.escapedTextqualifier = regExSafe( variables.textqualifier );

  variables.uomList = '';

  // construct a list of valid UOMs for this program
  for (variables.arrayCounter = 1; variables.arrayCounter lte arrayLen(variables.uomArray); variables.arrayCounter++ ) {
    variables.uomList = listAppend(variables.uomList, variables.uomArray[variables.arrayCounter].abbreviation);
  }

  function regExSafe( str ) {
    param name="variables.regexSafeTranslations" default="#{}#";

    if ( not structKeyExists(variables.regexSafeTranslations, arguments.str) )
      structInsert(variables.regexSafeTranslations, arguments.str, rereplace(arguments.str, "(?=[\[\]\\^$.|?*+()])", "\", "all"), true);

    return variables.regexSafeTranslations[arguments.str];
  }
</cfscript>

<!--- <cfloop array="#variables.uomArray#" index="variables.uom">
  <cfset varialistAppend(variables.uomList, variables.uom.abbreviation)>
  <cfdump var="#variables.uom.abbreviation#" format="text" showUDfs="false" top="10" hide="junks" output="d:\coldfusion\myDebugLog.txt">
</cfloop> --->

  <!--- <cfmail to="cnguyen@bigredflame.com" from="bugs@bigredflame.com.com" subject="#CGI.HTTP_HOST#'s debug information #application.util.datetime.dateTimeFormat(now())#" type="html">

    <cfdump var="#variables.uomArray#" format="html" showUDfs="false" top="10" hide="junks">    <!--- use text for smaller email size --->

  </cfmail> --->

<!--- Now, let's define the pattern for parsing the CSV data. --->
<cfsavecontent variable="variables.regEx"><cfoutput>\G(?:#variables.escapedTextqualifier#([^#variables.escapedTextqualifier#]*+(?>#variables.escapedTextqualifier##variables.escapedTextqualifier#[^#variables.escapedTextqualifier#]*+)*)#variables.escapedTextqualifier#|([^#variables.escapedTextqualifier##variables.escapedDelimiter#\r\n]*+))(#variables.escapedDelimiter#|\r\n?|\n|$)</cfoutput></cfsavecontent>

<cfscript>
  variables.errorCount = 0;
  variables.lineCount  = 0;

  // <!--- Create a compiled Java regular expression pattern object for the experssion that will be parsing the CSV. --->
  variables.pattern = createObject("java", "java.util.regex.Pattern").compile(javaCast("string", variables.regEx));
</cfscript>


<!---   V A L I D A T E   F I L E   C O N T E N T   -------------------------------------------------------------------------->

<!--- read .csv file one line at a time to avoid memory issue --->
<cfloop file="#variables.csvFile#" index="variables.csvLine">

  <cfscript>
    variables.lineCount++;
    variables.csvArray = [];
    //  Now, get the pattern matcher for our target text (the CSV data). This will allows us to iterate over all the tokens in the CSV data for individual evaluation.
    variables.matcher = variables.pattern.matcher(javaCast("string", variables.csvLine));
  </cfscript>

  <cfloop condition="variables.matcher.find()">
      <cfscript>
        // Next, try to get the qualified field value. If the field was not qualified, this value will be null.
        variables.fieldValue = variables.matcher.group(javaCast("int", 1));
        // Check to see if the value exists in the local scope. If it doesn't exist, then we want the non-qualified field. If it does exist, then we want to replace any escaped, embedded quotes.
        if ( structKeyExists(variables, "fieldValue") ) {
          // The qualified field was found. Replace escpaed quotes (two double quotes in a row) with an unescaped double quote.
          variables.fieldValue = replace(variables.fieldValue, "#variables.textqualifier##variables.textqualifier#", variables.textqualifier, "all");
        }
        else {
          // No qualified field value was found; as such, let's use the non-qualified field value.
          variables.fieldValue = variables.matcher.group(javaCast("int", 2));
        }
        arrayAppend(variables.csvArray, variables.fieldValue);

        // Get the delimiter. We know that the delimiter will always be matched, but in the case that it matched the end of the CSV string, it will not have a length.
        variables.delimiter = variables.matcher.group(javaCast("int", 3));

        // Check to see if we found a delimiter that is not the field delimiter (end-of-file delimiter will not have a length). If this is the case, then our delimiter is the line delimiter. Add a new data array to the CSV data collection.
        if ( (len(variables.delimiter) && (variables.delimiter neq ",")) ) {
          break;
        }
        else if ( !len(variables.delimiter) ) {
          // If our delimiter has no length, it means that we reached the end of the CSV data. Let's explicitly break out of the loop otherwise we'll get an extra empty space.
          break;
        }
      </cfscript>
  </cfloop>     <!--- <cfloop condition="variables.matcher.find()"> --->

  <!--- this statement displays the parsed columns with | delimiters on the screen - change the value from 1 to 0 to turn the debugging display off --->
  <cfif 0>
    <cfscript>
      for (variables.arrayCounter=1; variables.arrayCounter <= arrayLen(variables.csvArray); variables.arrayCounter++) { writeOutput(variables.csvArray[variables.arrayCounter] & " | "); }
    </cfscript>
    <br>
  </cfif>

  <!--- ---------------------------------------------------------- --->
  <!--- PLACE YOUR LOGIC TO PROCESS A LINE FROM THE .CSV FILE HERE --->
  <!--- ---------------------------------------------------------- --->
  <cfif variables.lineCount gt 1>    <!--- skip heading --->

    <cfset variables.local.errors = []>
    <cfif arrayLen(variables.csvArray) lt 5>
      <cfset arrayAppend(variables.local.errors, "missing column(s)")>
    <cfelse>
      <cfscript>
        variables.local.rate = trim( variables.csvArray[ 3 ] );
        variables.local.uom  = trim( variables.csvArray[ 4 ] );
        variables.local.Bsa_FoodService_Items_Master_Id = trim( variables.csvArray[ 5 ] );
      </cfscript>

      <!--- rate validation | we allow DEL to indicate a product deletion request --->
      <cfif len(variables.local.rate) and variables.local.rate neq "DEL" and not isNumeric( variables.local.rate )>
        <cfset arrayAppend(variables.local.errors, "rate is invalid")>
      </cfif>

      <!--- uom validation --->
      <cfif len(variables.local.rate) and variables.local.rate neq "DEL" and len(variables.local.uom) eq 0>
        <cfset arrayAppend(variables.local.errors, "uom is missing")>
      </cfif>
      <cfif len(variables.local.uom) and listFindNoCase(variables.uomList, left(variables.local.uom, 2)) eq 0>
        <cfset arrayAppend(variables.local.errors, "uom is not appropriate for program")>
      </cfif>

      <!--- guid validation --->
      <cfif not isValid("guid", variables.local.Bsa_FoodService_Items_Master_Id)>
        <cfset arrayAppend(variables.local.errors, "internal row id is invalid")>
      <cfelse>
        <cfquery name="variables.qItem" datasource="#application.datasource#">
          SELECT 1 FROM BSA_Foodservice_Items_Master WHERE BSA_Foodservice_Items_Master_ID = '#variables.local.Bsa_FoodService_Items_Master_Id#'
        </cfquery>
        <cfif variables.qItem.recordCount eq 0>
          <cfset arrayAppend(variables.local.errors, "internal row id is incorrect")>
        </cfif>
      </cfif>
    </cfif>

    <cfset variables.lineStatus = arrayToList(variables.local.errors, ", ")>

    <cfif len(variables.lineStatus)>
      <cfset variables.errorCount++>
      <cfif variables.errorCount eq 1>
        <cffile action="write" file="#variables.errorFile#"
                output="
                <img height=32 width=32 src='/images/knob/KnobAttention.png' style='float:left;'>
                <p style='float:left;margin:5px'>Please correct the following errors in your <b>#variables.upload.attemptedServerFile#</b> rebate upload file and try again.</p>
                <table class='datagrid' style='width:100%' border='0' cellpadding='0' cellspacing='0'>
                  <thead>
                    <tr>
                      <th align='center'>Row</th>
                      <th>Message</th>
                    </tr>
                  </thead>
                <tbody>">
      </cfif>
      <cffile action="append" file="#variables.errorFile#"
        output="<tr>
                  <td align='center'>#variables.lineCount#</td>
                  <td>#variables.lineStatus#</td>
                </tr>">
    </cfif>    <!--- <cfif len(variables.lineStatus)> --->
  </cfif>      <!--- <cfif variables.lineCount gt 1> --->
</cfloop>      <!--- <cfloop file="d:\temp\foo132k.csv" index="variables.csvLine"> --->


<cfif variables.errorCount gt 0>
  <cffile action="append" file="#variables.errorFile#" output="</tbody></table>">

  <cfsetting enablecfoutputonly="false">
  <cfoutput>#serializeJSON({STATUS=500, MESSAGE=variables.errorFile})#</cfoutput>
  <cfabort>
</cfif>


<!---   U P D A T E    D A T A B A S E    ------------------------------------------------------------------------------------>

<cfstoredproc procedure="Upload_Rebate_Rates" datasource="#application.datasource#" result="variables.result">
  <cfprocparam type="in" cfsqltype="cf_sql_integer" dbVarName="@Program_ID" value="#url.programid#" null="no">
  <cfprocparam type="in" cfsqltype="cf_sql_integer" dbVarName="@Component_Name_Id" value="#url.compid#" null="no">

  <cfprocparam type="in" cfsqltype="cf_sql_varchar" dbVarName="@Path" value="#variables.upload.serverDirectory#" null="no">
  <cfprocparam type="in" cfsqltype="cf_sql_varchar" dbVarName="@Filename" value="#variables.upload.serverFile#" null="no">
</cfstoredproc>


<cfsetting enablecfoutputonly="false">
<cfoutput>#serializeJSON({STATUS=200, MESSAGE="Done"})#</cfoutput>
<cfabort>


