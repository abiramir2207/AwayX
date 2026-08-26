<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/template_settings.cfm
CREATED: 	1/18/2012 - Milan

FUNCTIONALITY:
	-This calls some of the template settings which are used to decide hide/show of data. It is also used to
	decide where in the pdf letter should that information be shown, since we are dealing with (x,y) properties
	of Itext.
--->
</cfsilent>

<cfset bPriceBrackets = 0>
<cfset bOpenDate = 0>
<cfset bDateNeeded = 0>
<cfset bExpectedDate = 0>
<cfset bEstValueVolume = 0>

<cfset bPriceProtectionDate = 0>

<!--- If it is an "operator" letter, get the template setting to display/not display certain pieces of info --->
<cfif thisTag.abbreviation eq "opr">
   <cfset bPriceBrackets = thisTag.stPDFBodyInfo.bOperatorPriceBrackets>
   <cfset bOpenDate = thisTag.stPDFBodyInfo.bOperatorOpenDate>
   <cfset bDateNeeded = thisTag.stPDFBodyInfo.bOperatorDateNeeded>
   <cfset bExpectedDate = thisTag.stPDFBodyInfo.bDistributorExpectedDate>
   <cfset bEstValueVolume = thisTag.stPDFBodyInfo.bOperatorEstValueVolume>
<cfelse>
<!--- If it is a "distributor" letter, get the template setting to display/not display certain pieces of info --->
   <cfset bPriceBrackets = thisTag.stPDFBodyInfo.bDistributorPriceBrackets>
   <cfset bOpenDate = thisTag.stPDFBodyInfo.bDistributorOpenDate>
   <cfset bDateNeeded = thisTag.stPDFBodyInfo.bDistributorDateNeeded>
   <cfset bExpectedDate = thisTag.stPDFBodyInfo.bDistributorExpectedDate>
   <cfset bEstValueVolume = thisTag.stPDFBodyInfo.bDistributorEstValueVolume>
</cfif>

<cfset thisTag.stPDFHeaderInfo.program_title = Trim(thisTag.stPDFHeaderInfo.program_title)>
<cfset thisTag.stPDFIntroInfo.template_name = Trim(thisTag.stPDFIntroInfo.template_name)>

<cfif thisTag.stPDFIntroInfo.price_protection_date neq "">
<!--- Dev Note: Milan (38601).
Remove price protection date from the letter header. 
Note: If in the future, one more entry needs to be added on the left side of the header, the price protection code
can be modified in this file so that the other entry can replace the price protection date.
Another option is to add the code for a new entry, but it would be better to modify the price protection date as
it is not being used.
To show "price protection date" on the letter, below line of code needs to be uncommented.
	<cfset bPriceProtectionDate = 1>
--->
</cfif>

<cfscript>
/* 32417 - split program title into 3 lines */
	// clean up extra white spaces - replace double blank spaces with single blank space
	vars.program_title = replace(thisTag.stPDFHeaderInfo.program_title,'  ', ' ', 'all');
	
	// when program title is all upper case limit no. of chars per line to 22
  if (compare(vars.program_title, uCase(vars.program_title)) eq 0) {
		titleCutOffAt =  22;
	}
	else {
		titleCutOffAt = 30;
	}
	
	// extract program title for 1st line
	programTitlePart1 = application.util.string.fullLeft(vars.program_title, titleCutOffAt);
	programTitlePart2 = '';
	programTitlePart3 = '';
	
	// program title is longer than 1 line
	if (len(vars.program_title) gt len(programTitlePart1) + 1) {
		// remove programTitlePart1 leading part from vars.program_title
	  vars.program_title = trim(right(vars.program_title, len(vars.program_title) - len(programTitlePart1)));
		programTitlePart2 = application.util.string.fullLeft(vars.program_title, titleCutOffAt);
		
		// program title is longer than 2 lines
		if (len(vars.program_title) gt len(programTitlePart2) + 1) {
			// remove programTitlePart2 leading part from vars.program_title
	  	vars.program_title = trim(right(vars.program_title, len(vars.program_title) - len(programTitlePart2)));
		  programTitlePart3 = application.util.string.fullLeft(vars.program_title, titleCutOffAt);

			// program title is longer than 3 lines, add ellipsis
			if (len(vars.program_title) gt len(programTitlePart3) + 1) {
				programTitlePart3 = programTitlePart3 & "...";
			}
		}
	}

/* 37669 - split template name into 3 lines.
Note: As of now, the logic for program title and template name is the same.
*/

	// clean up extra white spaces - replace double blank spaces with single blank space
	vars.template_name = replace(thisTag.stPDFIntroInfo.template_name,'  ', ' ', 'all');

	// when template name is all upper case limit no. of chars per line to 22
  if (compare(vars.template_name, uCase(vars.template_name)) eq 0) {
		templateCutOffAt = 22;
	}
	else {
		templateCutOffAt = 30;
	}
	
	// extract template name for 1st line
	templateNamePart1 = application.util.string.fullLeft(vars.template_name, templateCutOffAt);
	templateNamePart2 = '';
	templateNamePart3 = '';
	
	// template name is longer than 1 line
	if (len(vars.template_name) gt len(templateNamePart1) + 1) {
		// remove templateNamePart1 leading part from vars.template_name
	  vars.template_name = trim(right(vars.template_name, len(vars.template_name) - len(templateNamePart1)));
		templateNamePart2 = application.util.string.fullLeft(vars.template_name, templateCutOffAt);
		
		// template name is longer than 2 lines
		if (len(vars.template_name) gt len(templateNamePart2) + 1) {
			// remove templateNamePart2 leading part from vars.template_name
	  	vars.template_name = trim(right(vars.template_name, len(vars.template_name) - len(templateNamePart2)));
		  templateNamePart3 = application.util.string.fullLeft(vars.template_name, templateCutOffAt);

			// template name is longer than 3 lines, add ellipsis
			if (len(vars.template_name) gt len(templateNamePart3) + 1) {
				templateNamePart3 = templateNamePart3 & "...";
			}
		}
	}
</cfscript>

<!--- WHENEVER ANY NEW PIECE OF DATA IS ADDED OR DELETED TO THE HEADER, ONE MIGHT HAVE TO TAKE THIS EXTRA STEP ALSO:
	- Enter the Y value for any additional row, left side OR right side. --->
<cfset Data_Row1_Y = 755>
<cfset Data_Row2_Y = 743>
<cfset Data_Row3_Y = 732>
<cfset Data_Row4_Y = 719>
<cfset Data_Row5_Y = 707>
<cfset Data_Row6_Y = 696>
<cfset Data_Row7_Y = 684>
<cfset Data_Row8_Y = 672>

<!--- Left side X value --->
<cfset LeftSideData_X = 155>

<!--- Right side X value --->
<cfset RightSideData_X = 410>


<!--- LEFT SIDE HEADER DISPLAY --->
<cfset LeftSideDataInclude = 0>
<cfset LeftSideDataRowCount = 0>



<!--- Show Estimated Value/Vol and Price Bracket and price protection date --->
<cfif bEstValueVolume AND bPriceBrackets AND bPriceProtectionDate>
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom. --->
	<cfset LeftSideDataInclude = 1>

	<cfset LeftSideDataLabel_1 = "Est Value/Vol: ">
	<cfset LeftSideData_1 = dollarFormat(thisTag.stPDFIntroInfo.program_spend) & '/' & ' ' & trim(numberformat(round(thisTag.stPDFIntroInfo.program_qtg_cases),'___,___,___,___,___,___')) & ' ' & 'cs' >
	
	<cfset LeftSideDataLabel_2 = "Price List Date: ">
	<cfset LeftSideData_2 = "#thisTag.stPDFIntroInfo.price_list_start_date#">

	<cfset LeftSideDataLabel_3 = "Price Protection Date: ">
	<cfset LeftSideData_3 = "#thisTag.stPDFIntroInfo.price_protection_date#">
	
	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 3>

<!--- Show Estimated Value/Vol and  Price Bracket --->
<cfelseif bEstValueVolume AND bPriceBrackets>
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->
	<cfset LeftSideDataInclude = 2>

	<cfset LeftSideDataLabel_1 = "Est Value/Vol: ">
	<cfset LeftSideData_1 = dollarFormat(thisTag.stPDFIntroInfo.program_spend) & '/' & ' ' & trim(numberformat(round(thisTag.stPDFIntroInfo.program_qtg_cases),'___,___,___,___,___,___')) & ' ' & 'cs' >
	
	<cfset LeftSideDataLabel_2 = "Price List Date: ">
	<cfset LeftSideData_2 = "#thisTag.stPDFIntroInfo.price_list_start_date#">

	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 2>
	
<!--- Show Estimated Value/Vol and price protection date --->	
<cfelseif bEstValueVolume AND bPriceProtectionDate>	
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->
	<cfset LeftSideDataInclude = 3>	

	<cfset LeftSideDataLabel_1 = "Est Value/Vol: ">
	<cfset LeftSideData_1 = dollarFormat(thisTag.stPDFIntroInfo.program_spend) & '/' & ' ' & trim(numberformat(round(thisTag.stPDFIntroInfo.program_qtg_cases),'___,___,___,___,___,___')) & ' ' & 'cs' >

	<cfset LeftSideDataLabel_2 = "Price Protection Date: ">
	<cfset LeftSideData_2 = "#thisTag.stPDFIntroInfo.price_protection_date#">
	
	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 2>

<!--- Show Price Bracket and and price protection date --->	
<cfelseif bPriceBrackets AND bPriceProtectionDate>	
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->
	<cfset LeftSideDataInclude = 4>	

	<cfset LeftSideDataLabel_1 = "Price List Date: ">
	<cfset LeftSideData_1 = "#thisTag.stPDFIntroInfo.price_list_start_date#">

	<cfset LeftSideDataLabel_2 = "Price Protection Date: ">
	<cfset LeftSideData_2 = "#thisTag.stPDFIntroInfo.price_protection_date#">
	
	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 2>


<!--- Show Estimated Value/Vol only --->	
<cfelseif bEstValueVolume>	
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->
	<cfset LeftSideDataInclude = 5>	

	<cfset LeftSideDataLabel_1 = "Est Value/Vol: ">
	<cfset LeftSideData_1 = dollarFormat(thisTag.stPDFIntroInfo.program_spend) & '/' & ' ' & trim(numberformat(round(thisTag.stPDFIntroInfo.program_qtg_cases),'___,___,___,___,___,___')) & ' ' & 'cs' >

	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 1>

<!--- Show Price Bracket only --->	
<cfelseif bPriceBrackets>	
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->
	<cfset LeftSideDataInclude = 6>	

	<cfset LeftSideDataLabel_1 = "Price List Date: ">
	<cfset LeftSideData_1 = "#thisTag.stPDFIntroInfo.price_list_start_date#">

	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 1>

<!--- Show price protection date only --->	
<cfelseif bPriceProtectionDate>	
	<!---	Left side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->
	<cfset LeftSideDataInclude = 7>	

	<cfset LeftSideDataLabel_1 = "Price Protection Date: ">
	<cfset LeftSideData_1 = "#thisTag.stPDFIntroInfo.price_protection_date#">

	<!---Count for categories of information --->
	<cfset LeftSideDataRowCount = 1>

</cfif>

<!--- If the program title is on 2 lines, then increase the row count for the left side by 1. --->
<cfif Len(programTitlePart2) GT 0>
	<cfset LeftSideDataRowCount = LeftSideDataRowCount + 1>
</cfif>

<!--- RIGHT SIDE HEADER DISPLAY --->
<cfset RightSideDataInclude = 0>
<cfset RightSideDataRowCount = 0>

<!--- Show Open Date and Date Needed and Expected Date --->
<cfif bOpenDate AND bDateNeeded AND bExpectedDate>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->	
	<cfset RightSideDataInclude = 1>

	<cfset RightSideDataLabel_1 = "Open Date: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.open_date,'MM/DD/YYYY')#">	
	<cfset RightSideDataLabel_2 = "Date Needed: ">
	<cfset RightSideData_2 = "#DateFormat(thisTag.stPDFIntroInfo.date_needed,'MM/DD/YYYY')#">
	<cfset RightSideDataLabel_3 = "Program Award Date: ">
	<cfset RightSideData_3 = "#DateFormat(thisTag.stPDFIntroInfo.expected_reply_date,'MM/DD/YYYY')#">
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 3>

<!--- Show Open Date and Date Needed --->		
<cfelseif bOpenDate AND bDateNeeded>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->	
	<cfset RightSideDataInclude = 2>

	<cfset RightSideDataLabel_1 = "Open Date: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.open_date,'MM/DD/YYYY')#">		
	<cfset RightSideDataLabel_2 = "Date Needed: ">
	<cfset RightSideData_2 = "#DateFormat(thisTag.stPDFIntroInfo.date_needed,'MM/DD/YYYY')#">
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 2>
	
<!--- Show Open Date and Expected Date --->		
<cfelseif bOpenDate AND bExpectedDate>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->	
	<cfset RightSideDataInclude = 3>

	<cfset RightSideDataLabel_1 = "Open Date: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.open_date,'MM/DD/YYYY')#">		
	<cfset RightSideDataLabel_2 = "Program Award Date: ">
	<cfset RightSideData_2 = "#DateFormat(thisTag.stPDFIntroInfo.expected_reply_date,'MM/DD/YYYY')#">
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 2>
	
<!--- Show Date Needed and Expected Date --->		
<cfelseif bDateNeeded AND bExpectedDate>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->	
	<cfset RightSideDataInclude = 4>

	<cfset RightSideDataLabel_1 = "Date Needed: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.date_needed,'MM/DD/YYYY')#">
	<cfset RightSideDataLabel_2 = "Program Award Date: ">
	<cfset RightSideData_2 = "#DateFormat(thisTag.stPDFIntroInfo.expected_reply_date,'MM/DD/YYYY')#">
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 2>
	
<!--- Show Open Date only --->		
<cfelseif bOpenDate>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->	
	<cfset RightSideDataInclude = 5>

	<cfset RightSideDataLabel_1 = "Open Date: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.open_date,'MM/DD/YYYY')#">	
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 1>
	
<!--- Show Date Needed only --->		
<cfelseif bDateNeeded>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom.--->	
	<cfset RightSideDataInclude = 6>

	<cfset RightSideDataLabel_1 = "Date Needed: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.date_needed,'MM/DD/YYYY')#">
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 1>
	
<!--- Show Expected Date only --->		
<cfelseif bExpectedDate>
	<!---	Right side of the header: Used to decide where the data should be displayed on the screen, since we use (X,Y) - X being from left and Y being 
		from bottom. --->		
	<cfset RightSideDataInclude = 7>

	<cfset RightSideDataLabel_1 = "Program Award Date: ">
	<cfset RightSideData_1 = "#DateFormat(thisTag.stPDFIntroInfo.expected_reply_date,'MM/DD/YYYY')#">
	
	<!---Count for categories of information --->
	<cfset RightSideDataRowCount = 1>
</cfif>


