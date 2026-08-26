<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<CFIF NOT IsDefined("FORM.Number_Of_Periods")><!---- for edit ----->
	<!--- load from db ---->
	<CFSET program_ID = cryp.value>
	<cfset useLakebaseForGet_Current_Periods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForGet_Current_Periods>
	<cftry>
		<cfset Get_Current_Periods = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_periods", {
				"program_id" = "eq.#program_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "start_date.asc",
				"select" = "start_date,end_date,release_date"
			}), "start_date,end_date,release_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Current_Periods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Current_Periods>
<CFQUERY NAME="Get_Current_Periods" DATASOURCE="#application.datasource#">
		SELECT Start_Date, End_Date, Release_Date
		FROM Program_Formula_Pricing_Periods
		WHERE Program_ID = #program_ID#
		AND
			DELETED = 0
		AND 
			ACTIVE = 1
		ORDER BY Start_Date	
	</CFQUERY>
</cfif>
	<CFIF Get_Current_Periods.RecordCount GT 0>
		<CFSET FORM.Number_Of_Periods = Get_Current_Periods.RecordCount>		
		<CFSET i = 1>	
		<CFLOOP QUERY="Get_Current_Periods">
			<CFSET "Period_#i#_Starting_Date_Default" = DateFormat(Start_Date, "mm/dd/yyyy")>
			<CFSET "Period_#i#_Ending_Date_Default" = DateFormat(End_Date, "mm/dd/yyyy")>
			<CFSET "Period_#i#_Release_Date" = DateFormat(Release_Date, "mm/dd/yyyy")>
			<CFSET "Period_#i#_Length_Default" = DateDiff("d", Start_Date, End_Date) + 1>
			<CFSET i = i + 1>
		</CFLOOP>
		<CFSET Disable_Periods = 0>
	</CFIF>
</CFIF>

<CFPARAM NAME="Disable_Periods" DEFAULT="1">
<CFPARAM NAME="FORM.Number_Of_Periods" DEFAULT="1">


<CFSET PAGE_TITLE="Formula pricing Period : Step 2">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
		<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>
		<CF_MessageWindow>
		<SCRIPT>
		calcDate=function(textboxObject){
			var temptempString=""
			var thisVal = parseInt(textboxObject.value);
			if((thisVal == 0) || (isNaN(thisVal))) 
			{
				textboxObject.value = ""
			}
			
			nameArray = textboxObject.name.split("_")
			elementNumber = parseInt(nameArray[2])
			var previous_Index = getPreviousIndex(elementNumber);
			var next_Index = getNextIndex(elementNumber);
			var firstIndex = getFirstIndex();
			if(firstIndex == elementNumber)
			{
				eval('document.all.Period_Length_' + firstIndex + '.style.backgroundColor = "white"')
				eval('document.all.Period_Length_' + firstIndex + '.disabled = false')
			}
			
			if((textboxObject.value.length == 0 || textboxObject.disabled)) 
			{
				tempArray = textboxObject.name.split("_")
				//tempString = tempArray[0] + "_" + tempArray[1] + "_";
	
				if(textboxObject.value == "0") 
				{
					textboxObject.value = ""
				}				
				
				//if(textboxObject.name != "Period_1_Length")
				if(previous_Index != null)
				{
					temptempString="document.all." + "Period_Length_" + previous_Index + ".value.length";
					temptempString=eval(temptempString)
					
					
					if(temptempString == 0) 
					{
						textboxObject.disabled = true;
						textboxObject.style.backgroundColor = "WhiteSmoke";
					}
				}
				
				eval("document.all.Period_Ending_Date_" + elementNumber + ".value = ''")
				eval("document.all.Period_Starting_Date_" + elementNumber + ".value = ''")
				
				temptempString=""
				temptempString="document.all." + "Period_Length_" + next_Index;
				temptempString=eval(temptempString)
				if(temptempString != null)
				{
					temptempString.disabled=true;
					temptempString.style.backgroundColor = "WhiteSmoke";
				}
	
				
				return false;
			}
			
			
			
			if(textboxObject.value.length > 0)
			{			
				//if(elementNumber == 1){
				if(previous_Index == null)
				{
					startDate = new Date(document.all.Day_One.value)
					
					endDate = DateAdd(startDate, parseInt(textboxObject.value),0,0)
					startDate = PadString((startDate.getMonth() +1), 2, "0") + "/" + PadString(startDate.getDate(), 2, "0") + "/" + startDate.getFullYear()
					endDate =  DateAdd(endDate, -1,0,0)
					endDate = PadString((endDate.getMonth() +1), 2, "0") + "/" + PadString(endDate.getDate(), 2, "0") + "/" + endDate.getFullYear()
					
					
	
						eval('document.all.Period_Starting_Date_' + elementNumber + '.value = startDate');
						eval('document.all.Period_Ending_Date_' + elementNumber + '.value = endDate');
					
					if(eval('document.all.Period_Starting_Date_' + next_Index) != null)
					{					
						eval('document.all.Period_Length_' + next_Index + '.style.backgroundColor = "white"')
						eval('document.all.Period_Length_' + next_Index + '.disabled = false')
					}
				}
				else 
				{
					startDate = eval('document.all.Period_Ending_Date_' + previous_Index + '.value')
					startDate = new Date(startDate)
					startDate = DateAdd(startDate, 1,0,0)
					endDate = DateAdd(startDate, parseInt(textboxObject.value),0,0)
					
					startDate = PadString((startDate.getMonth() +1), 2, "0") + "/" + PadString(startDate.getDate(), 2, "0") + "/" + startDate.getFullYear()				
					endDate =  DateAdd(endDate, -1,0,0)
					endDate = PadString((endDate.getMonth() +1), 2, "0") + "/" + PadString(endDate.getDate(), 2, "0") + "/" + endDate.getFullYear()
					
					eval('document.all.Period_Starting_Date_' + elementNumber + '.value = startDate');
					eval('document.all.Period_Ending_Date_' + elementNumber + '.value = endDate');
					
					if(eval('document.all.Period_Length_' + next_Index) != null)
					{	
						eval('document.all.Period_Length_' + next_Index + '.style.backgroundColor = "white"')
						eval('document.all.Period_Length_' + next_Index + '.disabled = false')			
					}
				}
			}
		}
	
		function getPreviousIndex(thisIndex)
		{
			var returnIndex = null;
			var i;
			for(i=(thisIndex-1);i>0;i--)
			{
				thisInterval = eval("document.all.Period_Length_" + i);
				if(thisInterval)
				{
					returnIndex = i;
					break;
				}
			}
			return returnIndex;
		}
		
		function getNextIndex(thisIndex)
		{
			var returnIndex = null;
			var i;
			var Number_Of_Periods = parseInt(document.all.Number_Of_Periods.value);
			for(i=(thisIndex+1);i<=Number_Of_Periods;i++)
			{
				thisInterval = eval("document.all.Period_Length_" + i);
				if(thisInterval)
				{
					returnIndex = i;
					break;
				}
			}
			return returnIndex;
		}
		
		function getLastIndex()
		{
			var returnIndex = null;
			var i;
			var Number_Of_Periods = parseInt(document.all.Number_Of_Periods.value);
			for(i=Number_Of_Periods;i>0;i--)
			{
				thisInterval = eval("document.all.Period_Length_" + i);
				if(thisInterval)
				{
					returnIndex = i;
					break;
				}
			}
			return returnIndex;
		}
		
		function getFirstIndex()
		{
			var returnIndex = null;
			var i;
			var Number_Of_Periods = parseInt(document.all.Number_Of_Periods.value);
			for(i=1;i<=Number_Of_Periods;i++)
			{
				thisInterval = eval("document.all.Period_Length_" + i);
				if(thisInterval)
				{
					returnIndex = i;
					break;
				}
			}
			return returnIndex;
		}
		
		function propagatePeriodChanges(){
			var i;
			var Number_Of_Periods = parseInt(document.all.Number_Of_Periods.value);
			for(i=1;i<=Number_Of_Periods;i++)
			{
				thisInterval = eval("document.all.Period_Length_" + i);
				if(thisInterval)
				{
					calcDate(thisInterval);
				}
			}
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
			textObject = eval('document.all.Period_Length_' + x)
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
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE><BLOCKQUOTE>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;"> </cfif>

<CFSET PeriodEndDate = DateFormat(CSLGetContractInfo.Contract_End_Date, "mm/dd/yyyy")>
<cfinclude template="minimal_contract_info.cfm">
<SCRIPT>
<CFOUTPUT>	
	function recalculate_Remaining_Days()
	{
		var thisForm = document.MyForm;
		if(thisForm.Day_One.value)
		{
			if(thisForm.Day_One.value != "")
			{
				//var pStartDate1 = new Date(thisForm.Day_One.value);
				var sd1 = thisForm.Day_One.value.split("/");
				var pStartDate1 = new Date(sd1[2],parseInt(sd1[0], 10)-1,sd1[1]);
				
				var totalLen = parseInt(document.all.Number_Of_Periods.value);
				var i, thisPeriodLen, totalPeriodLen;
				totalPeriodLen = 0;
				for(i=1;i<=totalLen;i++)
				{
					thisInterval = eval("document.all.Period_Length_" + i);
					if(thisInterval)
					{
						if(!eval("thisPeriodLen = thisForm.Period_Length_" + i + ".disabled"))
						{
							eval("thisPeriodLen = thisForm.Period_Length_" + i + ".value");
							thisPeriodLen = parseInt(thisPeriodLen);
							if(!isNaN(thisPeriodLen))
							{
								totalPeriodLen = totalPeriodLen + thisPeriodLen;
							}
						}
					}
				}			
				
				
				//var contractEndDate = new Date(#DateFOrmat(DateAdd('m',-1,CSLGetContractInfo.Contract_End_Date),'yyyy,mm,dd')#);
				var contractEndDate = new Date(#Year(PeriodEndDate)#, #Evaluate(Month(PeriodEndDate)-1)#, #Day(PeriodEndDate)#);
				var dateDifference = contractEndDate - pStartDate1;
				var diff = new Date();
				diff.setTime(Math.abs(pStartDate1.getTime() - contractEndDate.getTime()));
				var timediff = diff.getTime();
				var days = Math.round(timediff / (1000 * 60 * 60 * 24)); 
				if(pStartDate1.getTime() - contractEndDate.getTime() > 0)
					days = days * -1;
				days = days - totalPeriodLen + 1;
				document.all.remaining_days.innerText = days;
			}
		}		
	}
	</CFOUTPUT>
</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>

<FORM ACTION="Contract_Formula_Pricing_Periods_save_periods.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">

<table CELLPADDING="0" CELLSPACING="0" width="850">
	<TR>
		<TD WIDTH="800">
			<SPAN STYLE="font-weight:bold;color:Navy;font-size:16px;">Define the Pricing Periods:</SPAN>
			<HR WIDTH="800" COLOR="Orange">
		</TD>
	</TR>
</table>

<TABLE width="850">
<TR>
	<TD width="298"><B>Please define the first day of the first period:</B></TD>
	<TD width="5"><span ID="periodoneStart"></span>
	<TD width="531">
	<CFIF isdefined("Period_1_Starting_Date_Default")>
		<CFSET PeriodStartDate = Period_1_Starting_Date_Default>
	<CFELSE>
		<!--- start date of 1st period is start of program --->
		<CFSET PeriodStartDate = CSLGetContractInfo.Contract_Start_Date>
		<CFIF DateDiff("d",PeriodStartDate,Now()) GT 0>
			<!---<CFSET PeriodStartDate = now()>--->
			<CFSET PeriodStartDate = DateFormat(now(),"mm/dd/yyyy")>
		</CFIF>
		<!--- <CFSET PeriodStartDate = now()> --->
	</CFIF>
	<CFSET PeriodStartDate = DateFormat(PeriodStartDate, "mm/dd/yyyy")>
    <cf_easydate 
      formname="MyForm" 
      fieldname="Day_One" 
      format="mm/dd/yyyy"
      default="#PeriodStartDate#"
    >
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>	
	<script>
		document.all.Day_One.onafterupdate=propagatePeriodChanges
		
		function addPeriod()
		{
			var srcObj = event.srcElement;
			var tabObj = getParentObject(srcObj, "table");
			var lastIndex = getLastIndex();
			if(lastIndex != null)
			{
				addFilterRows(tabObj, tabObj.rows[lastIndex], tabObj.rows.length - 1, lastIndex);				
				document.all.Number_Of_Periods.value = tabObj.rows.length;
			}
		}
		
		function incrementName(checkHTML, replaceNumber, srcIndex)
	 	{
	  		var regExp = new RegExp("((name|id)=.*?_(.*?))[\"\\s>]", "igm");
	  		var arr = checkHTML.match(regExp);
	  		var i;
	  		var newHTML = checkHTML;
			if (arr)
			{
				for(i=0;i<arr.length;i++)
	  			{
	   				var idField = arr[i];
	   				var arr2 = /_([^_]*?)$/.exec(idField);
	   				var indexNumber = RegExp.$1;
	   
	   				newIndexNumber = replaceNumber;
	   				//newIndexNumber = parseFloat(indexNumber);
	   				if(!isNaN(newIndexNumber))
	   				{
	    				//newIndexNumber = newIndexNumber + 1;						
	    				var regExp = new RegExp("_" + indexNumber, "igm");
	    				newIDField = idField.replace(regExp, "_" + newIndexNumber + idField.substr(idField.length-1));
	    				var regExp = new RegExp(idField, "igm");
	    				var newHTML = newHTML.replace(regExp, newIDField); 
	   				}  
				} 
	  		}
			var regExp = new RegExp("Period_Release_Date_" + srcIndex, "igm");			
	 		var newHTML = newHTML.replace(regExp, "Period_Release_Date_" + replaceNumber); 
			return newHTML;
	 	}
		
		
		function addFilterRows(pObj, trObj, trIndex, srcIndex)
	    {
			var rObj = pObj.insertRow(trIndex+1);			
		 	var coLen = trObj.cells.length;
		 	for (i=0;i<coLen;i++)
		 	{
				var cObj = rObj.insertCell(i);
				if (trObj.cells[i].align)
				{
					cObj.align = trObj.cells[i].align;
				}
	     		cObj.innerHTML = incrementName(trObj.cells(i).innerHTML, trIndex + 1, srcIndex);				
				//alert(cObj.innerHTML + "\n\n\n\n" + trObj.cells(i).innerHTML);
				var inputCol = cObj.getElementsByTagName("input");
				for (j=0;j<inputCol.length;j++)
				{
					if (inputCol[j].type == "text")
					{
						inputCol[j].value = "";
					}
					
					if (inputCol[j].type == "checkbox")
					{
						inputCol[j].checked = true;
					}
				}
				
				var inputCol = cObj.getElementsByTagName("select");
				for (j=0;j<inputCol.length;j++)
				{
					inputCol[j].selectedIndex = 0;
				}
				
				var inputCol = cObj.getElementsByTagName("span");
				for (j=0;j<inputCol.length;j++)
				{
					emptyMessageSpan(inputCol[j]);
				}	
				
				var inputCol = cObj.getElementsByTagName("div");
				for (j=0;j<inputCol.length;j++)
				{
					inputCol[j].innerText = "";					
				}				
		 	}
			rObj.cells[0].innerHTML = "Period " + (trIndex + 1) + ":&nbsp;&nbsp;";
		}
		
		
		var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";
		function emptyMessageSpan(oSpan)
		{
			oSpan.innerHTML = empty_String;
			oSpan.style.width = 0;
			oSpan.style.backgroundImage = "";	
		}
		function deleteThisPeriod()
		{
			var srcObj = event.srcElement;
			//var trObj = document.getElementById("TR_" + index);
			var trObj = getParentObject(srcObj, "tr");
			var index = trObj.rowIndex;
			var bDelete;			
			bDelete = srcObj.bDelete;
			
			if(trObj)
			{
				if(bDelete)
				{ 
					emptyMessageSpan(eval("document.all.Period_DurationError_" + index));
					emptyMessageSpan(eval("document.all.lastPeriodEndStart_" + index));
					emptyMessageSpan(eval("document.all.Period_ReleaseError_" + index));
					
					trObj.height = trObj.offsetHeight;
					
					trObj.cells[2].innerHTML = empty_String;
					trObj.cells[3].innerHTML = empty_String;
					trObj.cells[4].innerHTML = empty_String;					
					disableDiv(trObj.cells[6], true, false);
	
					propogateProperty(trObj, "style.backgroundColor", "#CCCCCC", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);				
	
					srcObj.alt = "undo " + srcObj.sMessage;
					srcObj.src = undodeleteImg.src;
				}
				else
				{
					var cellContent = "";
					//cellContent = cellContent + "<SPAN ID=\"Period_" + index + "_DurationError\"></SPAN>"
					//cellContent = cellContent + "<SPAN ID=\"lastPeriodEndStart_" + index + "\"></SPAN>"
					cellContent = cellContent + "<INPUT STYLE=\"width: 50px;\" TYPE=\"text\" NAME=\"Period_Length_" + index + "\" onkeyup=\"propagatePeriodChanges();nextBox(this, 'NONE', 3);calcDate(this);recalculate_Remaining_Days(this);\""
					<CFIF Disable_Periods EQ 1>
						if(index != 1)
						{
							cellContent = cellContent + "disabled STYLE=\"background-color: WhiteSmoke;\"";
						}
					</cfif>
					cellContent = cellContent + ">";
					trObj.cells[2].innerHTML = cellContent;
					
					cellContent = "<INPUT TYPE=\"text\" NAME=\"Period_Starting_Date_" + index + "\" STYLE=\"width: 75px; border: Solid 0px;\" READONLY>";
					trObj.cells[3].innerHTML = cellContent;
					
					cellContent = "<INPUT TYPE=\"text\" NAME=\"Period_Ending_Date_" + index + "\" STYLE=\"width: 75px; border: Solid 0px;\" READONLY>";
					trObj.cells[4].innerHTML = cellContent;
					
					disableDiv(trObj.cells[6], false, false);
	
					propogateProperty(trObj, "style.backgroundColor", "#FFFFFF", false);
					propogateProperty(trObj, "style.textDecoration", "none", true);				
					
					srcObj.alt = "" + srcObj.sMessage;		
					srcObj.src = deleteImg.src;			
				}
				propagatePeriodChanges();
				recalculate_Remaining_Days();
				srcObj.bDelete = !bDelete;				
			}
		}
	</script>
	</TD>
</TR>
<TR>
	<TD COLSPAN="3">
	<CFOUTPUT>
	<font class="fc_red">
	Start Date for the first period should be on or after the Start Date of the Program '#DateFOrmat(CSLGetContractInfo.Contract_Start_Date,'mm/dd/yyyy')#'
	<br>End Date for the last period should be on the End Date of the Program '#DateFOrmat(PeriodEndDate,'mm/dd/yyyy')#'</font>
	<br>
	You have <b><span id="remaining_days">#Evaluate(DateDiff("d",PeriodStartDate, PeriodEndDate)+1)#</span></b> day(s) remaining in the program.
	</CFOUTPUT>
	</TD>
</TR>
</TABLE>



	<TABLE CLASS="Maintable" CELLPADDING="3" CELLSPACING="0" BORDER="0">
		<!--- TABLE HEADERS --->
		<TR BGCOLOR="#FFCE84" VALIGN="bottom">
			<TD ID="header" WIDTH="70"><B>Period</B></TD>
			<TD ID="header" WIDTH="10">&nbsp;</TD>
			<TD ID="header" WIDTH="80"><B>Duration</B></TD>
			<TD ID="header" WIDTH="80"><B>Start Date</B></TD>
			<TD ID="header" WIDTH="80"><B>End Date</B></TD>
			<TD ID="header" WIDTH="10">&nbsp;</TD>
			<TD ID="header" WIDTH="80"><B>Release Date</B></TD>
			<TD ID="header" ALIGN="right" VALIGN="middle" WIDTH="40">
			<img src="/images/plus4.gif" alt="add period" border="0" onclick="addPeriod()" style="cursor: pointer;">
			</TD>
		</TR>
		
		<!--- TABLE DATA QUERY --->
		<CFOUTPUT>
		<CFLOOP INDEX="i" FROM="1" TO="#FORM.Number_Of_Periods#" STEP="1">
			<TR <!--- BGCOLOR="#IIf(i Mod 2, DE('ffffff'), DE('C6FFC6'))#" ---> VALIGN="top">
					<TD NOWRAP WIDTH="60">Period #i#:&nbsp;&nbsp;</TD>
					<TD><IMG SRC="/Images/fill.gif" width="1" height="1"><SPAN ID="Period_DurationError_#i#"></SPAN><SPAN ID="lastPeriodEndStart_#i#"></SPAN></TD>
					<TD><INPUT STYLE="width: 50px;" TYPE="text" NAME="Period_Length_#i#" onkeyup="propagatePeriodChanges();nextBox(this, 'NONE', 3);calcDate(this);recalculate_Remaining_Days(this);" <cfif i NEQ 1 AND Disable_Periods EQ 1>disabled STYLE="background-color: WhiteSmoke;"</cfif> value="<cfif isdefined("Period_#i#_Length_Default")>#evaluate("Period_#i#_Length_Default")#</cfif>"></TD>
					<TD><INPUT TYPE="text" NAME="Period_Starting_Date_#i#" STYLE="width: 75px; border: Solid 0px;" value="<cfif isdefined("Period_#i#_Starting_Date_Default")>#evaluate("Period_#i#_Starting_Date_Default")#</cfif>" READONLY></TD>
					<TD><INPUT TYPE="text" NAME="Period_Ending_Date_#i#" STYLE="width: 75px; border: Solid 0px;" value="<cfif isdefined("Period_#i#_Ending_Date_Default")>#evaluate("Period_#i#_Ending_Date_Default")#</cfif>" READONLY></TD>
					<TD><SPAN ID="Period_ReleaseError_#i#"></SPAN>&nbsp;</TD>
					<TD>
						<CFSET This_Release_Date = "">
						<CFIF IsDefined("Period_#i#_Release_Date")>
							<CFSET This_Release_Date = Evaluate("Period_#i#_Release_Date")>
						</CFIF>
						 <cf_easydate2
						      formname="MyForm" 
						      fieldname="Period_Release_Date_#i#" 
						      format="mm/dd/yyyy"
						      default="#This_Release_Date#"
						    >
					</TD>
					<TD ALIGN="right" VALIGN="middle">
					<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" sMessage="delete this perod" alt="delete this perod" border="0" onclick="deleteThisPeriod()" style="cursor: pointer;">
					</TD>			
			</TR>
		</CFLOOP>
		</CFOUTPUT>
	</TABLE> 
	<BR>
		<CF_button
			button_name		=	""
			button_caption	=	"continue"
			button_action	=	"submitForm();"
			button_type		=	"javascript_link"
			button_width	=	"75"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>

<CFOUTPUT>
	<input NAME="Number_Of_Periods" TYPE="HIDDEN" VALUE="#FORM.Number_Of_Periods#">
	<input NAME="PROGRAM_ID" 		TYPE="HIDDEN" VALUE="#URL.CID#">
</CFOUTPUT>
</FORM>
<cfif application.programlayout EQ 1></div></cfif>
			
<Script>
		function compareDates(sd1,sd2){
		 var d1 = new Date(sd1);
		 var d2 = new Date(sd2);
		 if (d1.getDate() == d2.getDate() && d1.getMonth() == d2.getMonth
		() && d1.getFullYear() == d2.getFullYear())
		  return true;
		 else
		  return false;
		}


		function verifyDataInAllFields(){
			ErrorCount = 0
			<CFOUTPUT>

			<CFSET theDate 		= DateFOrmat(DateAdd('m',-1,CSLGetContractInfo.Contract_Start_Date),'yyyy,mm,dd')>
			<CFSET theEndDate 	= DateFOrmat(DateAdd('m',-1,PeriodEndDate),'yyyy,mm,dd')>
			<CFSET todaysDate 	= DateFOrmat(DateAdd('m',-1,Now()),'yyyy,mm,dd')>
			
			Program_Start_Date 	= new Date(#theDate#);
			//Program_End_Date 	= new Date(#theEndDate#);
			var Program_End_Date = new Date(#Year(CSLGetContractInfo.Contract_End_Date)#, #Evaluate(Month(CSLGetContractInfo.Contract_End_Date)-1)#, #Day(CSLGetContractInfo.Contract_End_Date)#);
			Todays_Date 		= new Date(#todaysDate#)

			periodsStartDate 	= new Date(document.all.Day_One.value);
			var lastIndex 		= getLastIndex();
			if(lastIndex == null)
			{
				queueMessage("You have to have atleast one period", null);
				showMessageWindow()
				return false;
			}
			lastPeriodEndDate   = new Date(eval("document.all.Period_Ending_Date_" + lastIndex + ".value"))
			
			//make sure start date is on or after program end
			if(periodsStartDate < Program_Start_Date)
			{
				ErrorCount++;
				queueMessage("Day 1 of Pricing Period 1 can not be before Program start date.", document.all.periodoneStart);
			}
			else
			{
				clearQueue(document.all.periodoneStart);
			}
			var Number_Of_Periods = parseInt(document.all.Number_Of_Periods.value);
			
			for(i=1;i<=Number_Of_Periods;i++)
			{
				thisInterval = eval("document.all.Period_Length_" + i);
				if(thisInterval)
				{
					obj2 = eval("document.all.Period_DurationError_" + i);
					//duration error
					if(thisInterval.value.length == 0){
						ErrorCount++;
						queueMessage("Enter A Duration For This Period", obj2);
					}
					else{
						clearQueue(obj2);
					}				
	
					obj1 = eval("document.all.Period_Release_Date_" + i);
					obj2 = eval("document.all.Period_ReleaseError_" + i);
					//release data
					if(obj1.value.length == 0){
						ErrorCount++;
						queueMessage("Supply The Release Date For This Period", obj2);
					}
					else{
						clearQueue(obj2);
					}				
				}
			}
			
			if(ErrorCount == 0){
				var first_Index = getFirstIndex();
				var obj1 = eval("document.all.Period_Release_Date_" + first_Index);
				var obj2 = eval("document.all.Period_Starting_Date_" + first_Index);
				thisPeriodReleaseDate 	= new Date(obj1.value);
				thisPeriodStartDate		= new Date(obj2.value);
				var next_index = getNextIndex(first_Index);
				var this_error = 0;
				if(thisPeriodReleaseDate > thisPeriodStartDate)
				{
					this_error++;
				}
				
				if(next_index != null)
				{
					var obj2 = eval("document.all.Period_Release_Date_" + next_index);
					nextPeriodReleaseDate 			= new Date(obj2.value)
					if(thisPeriodReleaseDate >= nextPeriodReleaseDate)
					{
						this_error++;
					}
				}
				
				var obj2 = eval("document.all.Period_DurationError_" + first_Index);
				if(this_error > 0)
				{			
					if(next_index != null)
					{
						queueMessage("The release date of the first period must be on or before the period start date and cannot be on or after the next period\'s release date", obj2);
					}
					else
					{
						queueMessage("The release date must be on or before the period start date", obj2);
					}
					ErrorCount++;
				}
				else
				{
					clearQueue(obj2);
				}
			
				for(i=2;i<=Number_Of_Periods;i++)
				{
					previous_index 	= getPreviousIndex(i);
					next_index 		= getNextIndex(i);

					if(previous_index != null)//mean first valid period
					{
						durationObj = eval("document.all.Period_Length_" + i);
						if(durationObj)
						{
							previousPeriodReleaseObj = eval("document.all.Period_Release_Date_" + previous_index);
							previousPeriodReleaseDate 	= new Date(previousPeriodReleaseObj.value);
							thisPeriodReleaseObj = eval("document.all.Period_Release_Date_" + i);
							thisPeriodReleaseDate		= new Date(thisPeriodReleaseObj.value);
							thisPeriodStartObj = eval("document.all.Period_Starting_Date_" + i);
							thisPeriodStartDate			= new Date(thisPeriodStartObj.value);
							nextPeriodStartObj			= eval("document.all.Period_Starting_Date_" + next_index)
							if(nextPeriodStartObj)
							{
								nextPeriodStartDate			= new Date(nextPeriodStartObj.value)
							}
							
							errObj1 = eval("document.all.Period_DurationError_" + i);
							if(thisPeriodReleaseDate > thisPeriodStartDate)
							{
								ErrorCount++;
								queueMessage("The release date of this period cannot be after it begins", errObj1);
							}
							else if(thisPeriodReleaseDate <= previousPeriodReleaseDate)
							{
								ErrorCount++;
								queueMessage("The release date of this period must be after the previous period\'s release date.", errObj1);
							}
							else if(i != lastIndex && lastIndex != null && thisPeriodReleaseDate > nextPeriodStartDate)
							{
								ErrorCount++;
								queueMessage("The release date of this period cannot be after it begins", errObj1);
							}
							else
							{
								clearQueue(errObj1);
							}
						}
					}
				}
			}


			</CFOUTPUT>			
			
			//make sure end date is on program end
			//if(lastPeriodEndDate != "NaN"){
			
				var Number_Of_Periods = parseInt(document.all.Number_Of_Periods.value);
				for(i=1;i<=Number_Of_Periods;i++)
				{
					var last_Period_Error_Obj = eval("document.all.lastPeriodEndStart_" + i);
					clearQueue(last_Period_Error_Obj);
				}
				compareDates(lastPeriodEndDate,Program_End_Date)
				last_Period_Error_Obj = eval("document.all.lastPeriodEndStart_" + lastIndex);
				
				if(compareDates(lastPeriodEndDate,Program_End_Date) == false){
					ErrorCount++;
					queueMessage("The last periods end date must be on the end of the program.", last_Period_Error_Obj);
				}
			//}
			
			
			if(ErrorCount != 0){
				showMessageWindow()
				return false;
			}
			return true;
		}
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	document.all.Day_One.onpropertychange=new Function ("recalculate_Remaining_Days();");
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
