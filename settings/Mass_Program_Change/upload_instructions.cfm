<cfsilent>
<!---  
       Name:          upload_instructions.cfm           
       Copyright:     Copyright (c) 2010 Blacksmith Applications, Inc.       
       Created Date:  12/01/2010
       Created By:    Kal
       Label:		  25195
       Description:   Mass Program Change Upload Utility
--->
</cfsilent>

<!--- css --->
<link rel="stylesheet" type="text/css" href="/common_files/upload_styles.css">

<div class="displayHeader">
	Using the mass change tools
</div>

<div class="Instructions">
	<ul>
		<li>Uploaded files must be an Excel File.  If you are using Excel to create a file for uploading, be sure to remove all comma’s from the worksheet prior to converting to Excel.</li>
		<li>If you are converting to an Excel worksheet, note to remove formula’s and formatting prior to the upload.</li>
		<li>Files should contain column headers as row one.  The application will ignore the first row from the file.</li>
		<li>The date format for date columns must be MM/DD/YYYY.  Months and days with leading zeroes should contain those characters with the year being the full four characters.</li>
		<li>Uploading a price of “zero” will remove an item from a given program.</li>
		<li>Item volume uploaded with a valid price but a volume of zero will default to a volume of “one” per unit of measure.</li>
		<li>There are 10 fields in the upload file, with comments noted below.</li>
	</ul>
</div>


<div class="Instructions">
	Field Comments:
	<ol>
		<li>ROW ID:  The row ID field is used to communicate error rows to the user after the upload validates.  The application will assign a row number based upon the row count in the upload.</li>
		<li>CONTRACT NUMBER:  This the primary contract number from the application without the version extension. For example, program “PRG-1000123-002” would upload as “PRG-1000123” only.</li>
		<li>START DATE:  Formatted as MM/DD/YYYY with an example of January 1, 2011 uploaded as “01/01/2011”.  Validated for format, month integrity and relationship to end date [cannot be after the end date].</li>
		<li>END DATE:  Formatted as MM/DD/YYYY with an example of January 1, 2011 uploaded as “01/01/2011”.  Validated for format, month integrity and relationship to start date [cannot be before the start date].</li>
		<li>COMPONENT ID:  External component ID from the application settings.</li>
		<li>ITEM NUMBER:  The item number field is expected to be an exact match to the character string in the ERP.  Leading zeroes apply to that rule.</li>
		<li>PRICE:  Must be a valid integer rounded to a precision of two for per case rates and no more than four for per pound rates.</li>
		<li>UOM:  Unit of measure expressed as “CS” for per case and “LB” for per pound.</li>
		<li>VOLUME:  Must be a valid integer as a whole number only and is assumed to be cases for the program span.</li>
		<li>CURRENCY:  Valid choice is “USD” for this release.</li>
	</ol>
</div>