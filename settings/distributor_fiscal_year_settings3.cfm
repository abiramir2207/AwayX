<CFQUERY NAME="getDistributorFiscalCalendar" datasource="#application.datasource#">
	SELECT *
	FROM Distributor_Fiscal_Year
	WHERE Deleted = 0 AND Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	ORDER BY Start_Date 
</CFQUERY>

<CFOUTPUT QUERY="getDistributorFiscalCalendar">
	<CFPARAM NAME="Period_#currentrow#_Length_Default" DEFAULT="#getDistributorFiscalCalendar.Period_Length#">
	<CFPARAM NAME="Period_#currentrow#_Starting_Date_Default" DEFAULT="#dateformat(getDistributorFiscalCalendar.Start_Date, 'm/d/yyyy')#">
	<CFPARAM NAME="Period_#currentrow#_Ending_Date_Default" DEFAULT="#dateformat(getDistributorFiscalCalendar.End_Date, 'm/d/yyyy')#">
</CFOUTPUT>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Select Dates</TITLE>

<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET pagetitle="Distributor Fiscal Year">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Ask for the length of the periods in the fiscal year											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT>
	calcDate=function(textboxObject){
		var temptempString=""
		if(textboxObject.value.length == 0 && textboxObject.name != "Period_1_Length" ||  textboxObject.value == "0") {
			
			
			tempArray = textboxObject.name.split("_")
			tempString = tempArray[0] + "_" + tempArray[1] + "_";

			if(textboxObject.value == "0") {
				textboxObject.value = ""
			}				
			
			temptempString="document.all." + tempArray[0] + "_" + (parseInt(tempArray[1])-1) + "_Length.value.length";
			temptempString=eval(temptempString)
			
			
			if(temptempString == 0) {
				textboxObject.disabled = true;
				textboxObject.style.backgroundColor = "WhiteSmoke";
			}

			eval("document.all." + tempString + "Ending_Date.value = ''")
			eval("document.all." + tempString + "Starting_Date.value = ''")
			
			temptempString=""
			temptempString="document.all." + tempArray[0] + "_" + (parseInt(tempArray[1])+1) + "_Length";
			temptempString=eval(temptempString)
			if(temptempString != null){
				temptempString.disabled=true;
				temptempString.style.backgroundColor = "WhiteSmoke";
			}

			
			return false;
		}
		
		nameArray = textboxObject.name.split("_")
		
		elementNumber = parseInt(nameArray[1])
		if(textboxObject.value.length > 0){
		if(elementNumber == 1){
			startDate = new Date(document.all.Day_One.value)
			
			endDate = DateAdd(startDate, parseInt(textboxObject.value),0,0)
			startDate = (startDate.getMonth() +1) + "/" + startDate.getDate() + "/" + startDate.getFullYear()
			endDate =  DateAdd(endDate, -1,0,0)
			endDate = (endDate.getMonth() +1) + "/" + endDate.getDate() + "/" + endDate.getFullYear()
			
			eval('document.all.Period_' + elementNumber + '_Starting_Date.value = startDate');
			eval('document.all.Period_' + elementNumber + '_Ending_Date.value = endDate');
			
			eval('document.all.Period_' + (elementNumber+1) + '_Length.style.backgroundColor = "white"')
			eval('document.all.Period_' + (elementNumber+1) + '_Length.disabled = false')
		}
		else {
			
			startDate = eval('document.all.Period_' + (elementNumber - 1) + '_Ending_Date.value')
			startDate = new Date(startDate)
			startDate = DateAdd(startDate, 1,0,0)
			endDate = DateAdd(startDate, parseInt(textboxObject.value),0,0)
			
			startDate = (startDate.getMonth() +1) + "/" + startDate.getDate() + "/" + startDate.getFullYear()
			eval('document.all.Period_' + elementNumber + '_Starting_Date.value = startDate');
			endDate =  DateAdd(endDate, -1,0,0)
			endDate = (endDate.getMonth() +1) + "/" + endDate.getDate() + "/" + endDate.getFullYear()
			eval('document.all.Period_' + elementNumber + '_Ending_Date.value = endDate');
			
			if(elementNumber == '<cfoutput>#Form.Number_of_Periods#</cfoutput>') {
				testDate = new Date(document.all.Day_One.value)
				testDate = DateAdd(testDate, 0,0,1)
				testDate = DateAdd(testDate, -1,0,0)
				testDateEnd = new Date(endDate)
				if(testDateEnd > testDate){
					alert("Your Entries Exceed One Year")
					eval('document.all.Period_' + elementNumber + '_Starting_Date.value = ""');
					eval('document.all.Period_' + elementNumber + '_Ending_Date.value = ""');
					eval(textboxObject.value = "");
					return
				}
				return
			}

			eval('document.all.Period_' + (elementNumber+1) + '_Length.style.backgroundColor = "white"')
			eval('document.all.Period_' + (elementNumber+1) + '_Length.disabled = false')			
		}
	}
	}

	function propagatePeriodChanges(){
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.Number_Of_Periods#" STEP="1">
calcDate(document.all.Period_<CFOUTPUT>#LoopCount#_Length)</CFOUTPUT>
		</cfloop>
			
	}
	
	function verifyDataInAllFields(){
		ErrorCount = 0
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.Number_Of_Periods#" STEP="1">
if(document.all.Period_<CFOUTPUT>#LoopCount#_Length.value.length == 0) ErrorCount++;</CFOUTPUT>
		</cfloop>
		
		if(ErrorCount != 0){
			alert("Enter A Length For All The Periods")
			return false;
		}
		return true;
	}

	
function DateAdd(startDate, numDays, numMonths, numYears)
{
	var returnDate = new Date(startDate.getTime()+3600000);
	var yearsToAdd = numYears;
	
	var month = returnDate.getMonth()	+ numMonths;
	if (month > 11)
	{
		yearsToAdd = Math.floor((month+1)/12);
		month -= 12*yearsToAdd;
		yearsToAdd += numYears;
	}
	returnDate.setMonth(month);
	returnDate.setFullYear(returnDate.getFullYear()	+ yearsToAdd);
	
	returnDate.setTime(returnDate.getTime()+60000*60*24*numDays);
	
	return returnDate;

}

function YearAdd(startDate, numYears)
{
		return DateAdd(startDate,0,0,numYears);
}

function MonthAdd(startDate, numMonths)
{
		return DateAdd(startDate,0,numMonths,0);
}

function DayAdd(startDate, numDays)
{
		return DateAdd(startDate,numDays,0,0);
}



function populateWithNewDate()
{
	DateToday = new Date(parseInt(document.all.year.value),parseInt(document.all.month.value)-1,parseInt(document.all.day.value))
	NewDate = DayAdd(DateToday, 1)
	document.all.new_month.value = NewDate.getMonth() + 1
	document.all.new_day.value = NewDate.getDate()
	document.all.new_year.value = NewDate.getFullYear()
}

function initPage() {
	for(var x=1; x<=<cfoutput>#FORM.Number_of_Periods#</cfoutput>; x++){
		textObject = eval('document.all.Period_' + x + '_Length')
		if(textObject.value.length > 0){
			textObject.disabled = false;
			textObject.style.backgroundColor = 'white'
		}
	}
	propagatePeriodChanges()
}

function submitForm(){
	if(verifyDataInAllFields()){
		document.all.MyForm.submit()
	}
}

</SCRIPT>



<SPAN CLASS="title2">Step III</SPAN><BR>
<HR COLOR="Orange">

You have defined <CFOUTPUT>#Form.Number_of_Periods#</CFOUTPUT> accounting periods

<BR><BR>



<FORM ACTION="distributor_fiscal_year_settings4.cfm" METHOD="post" NAME="MyForm">

<SPAN CLASS="title2">Step IV</SPAN><BR>
<HR COLOR="Orange">


<TABLE>
<TR>
	<TD>Please define the first day of the first period:</TD>
	<TD>
	<CFIF isdefined("Period_1_Starting_Date_Default")>
		<CFSET PeriodStartDate = Period_1_Starting_Date_Default>
	<CFELSE>
		<CFSET PeriodStartDate = now()>
	</CFIF>
	
    <cf_easydate 
      formname="MyForm" 
      fieldname="Day_One" 
      format="mm/dd/yyyy"
      default="#PeriodStartDate#"
    >	
	<script>
		document.all.Day_One.onafterupdate=propagatePeriodChanges
	</script>
	</TD>
</TR>
</TABLE>

<BR>

<SPAN CLASS="title2">Step V</SPAN><BR>
<HR COLOR="Orange">


Please define the length of each period (in days):<BR><BR>


<!--- Number of columns to display --->
<CFSET number_of_columns=2>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="2">
	<CFSET tablecounter=0>
	<TR>
	<CFOUTPUT>
	<CFLOOP INDEX="i" FROM="1" TO="#Form.Number_of_Periods#">
		<TD>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD NOWRAP WIDTH="60">Period #i#:&nbsp;&nbsp;</TD>
					<TD><INPUT STYLE="width: 50px;" TYPE="text" NAME="Period_#i#_Length" onkeyup="propagatePeriodChanges();nextBox(this, 'NONE', 3);calcDate(this)" <cfif i NEQ 1>disabled STYLE="background-color: WhiteSmoke;"</cfif> value="<cfif isdefined("Period_#i#_Length_Default")>#evaluate("Period_#i#_Length_Default")#</cfif>"></TD>
					<TD><INPUT TYPE="text" NAME="Period_#i#_Starting_Date" STYLE="width: 75px; border: Solid 0px;" value="<cfif isdefined("Period_#i#_Starting_Date_Default")>#evaluate("Period_#i#_Starting_Date_Default")#</cfif>" READONLY></TD>
					<TD><INPUT TYPE="text" NAME="Period_#i#_Ending_Date" STYLE="width: 75px; border: Solid 0px;" value="<cfif isdefined("Period_#i#_Ending_Date_Default")>#evaluate("Period_#i#_Ending_Date_Default")#</cfif>" READONLY></TD>
				</TR>
			</TABLE>
		</TD>
		<CFSET tablecounter=tablecounter+1>
		#IIf(tablecounter Mod number_of_columns,DE(''),DE('</TR><TR>'))#
	</CFLOOP>
	</CFOUTPUT>
</TABLE>



<BR><BR>


<CF_button
	button_name		=	"MyButton"
	button_caption	=	"save"
	button_action	=	"javascript:submitForm();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
<input NAME="Number_Of_Periods" TYPE="Hidden" VALUE="<CFOUTPUT>#NUMBER_OF_PERIODS#</CFOUTPUT>">
<input NAME="Distributor_ID" TYPE="Hidden" VALUE="<CFOUTPUT>#Distributor_Name#</CFOUTPUT>">
</FORM>
<script>initPage()</script>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



