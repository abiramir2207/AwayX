<cfsetting enablecfoutputonly="Yes">
<!---------------------------------------------------------------------
  Custom Tag: <cf_easydate>
    URL: http://www.suwyn.com/customtags/easydate/index.cfm
    Release: 7/11/1999
    
  Author: Brett Suwyn
  mailto:brett@suwyn.com
    
  What does it do?
    <cf_easydate> is a custom control written in javascript and
    coldfusion.  It adds the additional functionality of having "plus"
    and "minus" buttons to a text field to increment the date provided
    in the text box easily and quickly. With an optional attribute
    to adjust the speed of the double click that increases/decreases
    the date.  Also you may toggle a pop-up calendar feature that
    opnes a new window with a calendar that enables the user to choose
    their desired date;
      
  Disclaimer:
      This custom tag will lose all functionality when javascript is
      turned off or is not supported by the browser.
      SEE ADDITIONAL NOTES for compatability concerns;
     
  Input Parameters 
    Parameter Name [data type](default value):
    Required:
      FormName [string]: This is the name of the form <cf_easydate> is called
          in.  ie. the "name" attribute of your form tag.
          ********  THIS IS CASE SENSITIVE  ***************;
      FieldName [string]: This is the name you wish the text box to be given;
      
    Optional:
      Format [mask]("mm/dd/yyyy"): Date mask to apply to <cf_easydate>
          Currently <cf_easydate> only supports "mm/dd/yyyy" and "dd/mm/yyyy"
          But you may add yours below... It's pretty easy do figure it out!
          See line 290.
      DBLSpeed [integer](3): Number of days <cf_easydate>
          is to be incremented in the event of a double click;
      Default [date](Null): This is the default value of <cf_easydate>;
      Required [boolean] (no): If set to yes, if easydate is left blank it will
          reset itself to either today's date or the date input as the default;
      ShowCalanderButton [boolean] (yes): Toggles the display of the pop-up
          calenar button.
      WriteFile [boolean] (yes): Toggles whether cf_easydate writes cal.htm in
          the current directory if it doesn't exist.  cal.htm is required for
          the calendar pop-up feature to function properly.
          
  Modification List:
    02/08/2000: (1) Added custom date mask support;
    01/27/2000: (1) Added Studio Support;    
    08/08/1999: (1) Added calendar pop-up feature.
    07/11/1999: (1) Added stricter js date validation;
                (2) Added "Required" optional parameter to control action if 
                  <cf_easydate> is left blank;

    06/27/1999: (1) Added browser check to "hide" action buttons if 
                  users browser is not a 4th+ generation browser;
                (2) Polished for display;
                
    11/08/1998: (1) Created;
                    
  Additional Notes:
    <cf_easydate> will check the client's browser version and if it finds
    that the bowser is less than a 4th generation browser it will not include
    the action buttons.  This provides support for non-supporting browsers ;)
    <cf_easydate> is only compatible with CF 4.01+;
    If you have any problems,comments, or make any improvements to this tag please
    email me at brett@suwyn.com and let me know.
        
  Usage:
    <cf_easydate 
      formname="easyDateDemo" 
      fieldname="Date" 
      format="mm/dd/yyyy"
      default="#Now()#" 
      dblspeed="3"
      ShowCalanderButton="Yes"
      writefile="yes"
    >

    <cf_easydate 
      formname="MyFormName" 
      fieldname="Date" 
      format="dd/mm/yyyy"
      default="#MyQuery.Date#"
    >

------------------------------------------------------------------------------->

<!--- Validation for Required Attribs (FormName & FieldName) --->
<cfif NOT isDefined("Attributes.FormName")><!--- Check required parameter FormName --->
  <!--- Error Found! Get outta my tag --->
  <cfabort showerror="<blockquote><b>Error in the execution of cf_easydate</b><BR><BR>
    The attribute ""FormName"" is required for a execution of cf_easydate#RepeatString("&nbsp;",10)#<p>&nbsp;<p>">

<cfelseif NOT isDefined("Attributes.FieldName")><!--- Check required parameter FieldName --->
  <!--- Error Found! Get outta my tag --->
  <cfabort showerror="<blockquote><b>Error in the execution of cf_easydate</b><BR><BR>
    The attribute ""FieldName"" is required for a execution of cf_easydate#RepeatString("&nbsp;",10)#<p>&nbsp;<p>">

<!--- Validation for invalid data types passed in attributes --->
<cfelseif IsDefined("Attributes.Default") AND Len(Attributes.Default) AND NOT isDate(Attributes.Default)><!--- Make sure "default" is a valid date --->
  <!--- Error Found! Get outta my tag --->
  <cfabort showerror="<blockquote><b>Error in the execution of cf_easydate</b><BR><BR>
    The attribute ""Default"" must be a valid date#RepeatString("&nbsp;",10)#<p>&nbsp;<p>"> 

<!--- Validation for invalid yes/no passed in attributes --->
<cfelseif IsDefined("Attributes.Required") AND NOT isBoolean(Attributes.Required)><!--- Make sure "required" is a valid yes/no --->
  <!--- Error Found! Get outta my tag --->
  <cfabort showerror="<blockquote><b>Error in the execution of cf_easydate</b><BR><BR>
    The attribute ""Required"" must be a valid boolean value#RepeatString("&nbsp;",10)#<p>&nbsp;<p>">

<cfelseif isDefined("Attributes.DBLSpeed") AND NOT isNumeric(Attributes.DBLSpeed)><!--- Make sure "DBLSpeed" is a valid number --->
  <!--- Error Found! Get outta my tag --->
  <cfabort showerror="<blockquote><b>Error in the execution of cf_easydate</b><BR><BR>
    The attribute ""DBLSpeed"" must be a valid number#RepeatString("&nbsp;",10)#<p>&nbsp;<p>">
</cfif>

<!--- Optional Attributes --->
<cfparam name="Attributes.DBLSpeed" default="3">
<cfparam name="Attributes.Default" default="">
<cfparam name="Attributes.Format" default="mm/dd/yyyy">
<cfparam name="Attributes.Required" default="No">
<cfparam name="Attributes.ShowCalanderButton" default="Yes">
<cfparam name="Attributes.WriteFile" default="Yes">
<cfparam name="ResetDate" default="#IIf(Len(Attributes.Default),DE(Attributes.Default),DE(Now()))#">
<CFPARAM NAME="Attributes.INP_ARGUMENTS" 	DEFAULT="">

<!--- **** IMPORTANT *****
      If you do not have access to the cffile tag
      You need to cut and paste the code from the output of the
      cffile tag below into cal.htm and place it in the same directory
      as the calling template  --->
      
<!--- Write Cal.htm in current directory if it doesn't exist --->
<CFSET Calender_File_Name = "cal1.htm">
<cfif Attributes.ShowCalanderButton AND Attributes.WriteFile AND NOT FileExists(GetDirectoryFromPath(GetTemplatePath())&"#Calender_File_Name#")>
<cffile action="WRITE" file="#GetDirectoryFromPath(GetTemplatePath())##Calender_File_Name#" addnewline="Yes"
  output="
    <!-- Begin html code for cal.htm -->
    <HTML>
     <HEAD>
	 	<TITLE>Calendar</TITLE>
     <SCRIPT LANGUAGE=""JavaScript""><!--
     function Calendar(Month,Year) {
         var output = '';
         
         output += '<FORM NAME=""Cal""><TABLE BGCOLOR=""##F5F5F5"" ALIGN=""center"" HEIGHT=""100%""><TR><TD ALIGN=""center"" HEIGHT=""100%""><TABLE BGCOLOR=""##F5F5F5"" BORDER=0><TR><TD ALIGN=LEFT WIDTH=100%>';
         output += '<FONT COLOR=""##0000BB"" FACE=""Arial"" SIZE=+1>' + names[Month] + ' ' + Year + '<\/FONT><\/TD><TD WIDTH=50% ALIGN=RIGHT>';
         output += '<SELECT NAME=""Month"" onChange=""changeMonth();"">';
    
         for (month=0; month<12; month++) {
             if (month == Month) output += '<OPTION VALUE=""' + month + '"" SELECTED>' + names[month] + '<\/OPTION>';
             else                output += '<OPTION VALUE=""' + month + '"">'          + names[month] + '<\/OPTION>';
         }
    
         output += '<\/SELECT><SELECT NAME=""Year"" onChange=""changeYear();"">';
    
         for (year=1900; year<2101; year++) {
             if (year == Year) output += '<OPTION VALUE=""' + year + '"" SELECTED>' + year + '<\/OPTION>';
             else              output += '<OPTION VALUE=""' + year + '"">'          + year + '<\/OPTION>';
         }
    
         output += '<\/SELECT><\/TD><\/TR><TR><TD ALIGN=CENTER COLSPAN=2>';
    
         firstDay = new Date(Year,Month,1);
         startDay = firstDay.getDay();
    
         if (((Year % 4 == 0) && (Year % 100 != 0)) || (Year % 400 == 0))
              days[1] = 29; 
         else
              days[1] = 28;
    
         output += '<TABLE CALLSPACING=0 CELLPADDING=0 BORDER=1 BORDERCOLORDARK=""##FFFFFF"" BORDERCOLORLIGHT=""##C0C0C0""><TR>';
    
         for (i=0; i<7; i++)
             output += '<TD WIDTH=50 ALIGN=CENTER VALIGN=MIDDLE><FONT SIZE=-1 COLOR=""##000000"" FACE=""ARIAL""><B>' + dow[i] +'<\/B><\/FONT><\/TD>';
    
         output += '<\/TR><TR ALIGN=CENTER VALIGN=MIDDLE>';
    
         var column = 0;
         var lastMonth = Month - 1;
         if (lastMonth == -1) lastMonth = 11;
    
         for (i=0; i<startDay; i++, column++)
             output += '<TD WIDTH=50 HEIGHT=30><FONT SIZE=-1 COLOR=""##808080"" FACE=""ARIAL"">' + (days[lastMonth]-startDay+i+1) + '<\/FONT><\/TD>';
    
         for (i=1; i<=days[Month]; i++, column++) {
             output += '<TD WIDTH=50 HEIGHT=30>' + '<A HREF=""javascript:changeDay(' + i + ')""><FONT SIZE=-1 FACE=""ARIAL"" COLOR=""##0000FF"">' + i + '<\/FONT><\/A>' +'<\/TD>';
             if (column == 6) {
                 output += '<\/TR><TR ALIGN=CENTER VALIGN=MIDDLE>';
                 column = -1;
             }
         }
    
         if (column > 0) {
             for (i=1; column<7; i++, column++)
                 output +=  '<TD WIDTH=50 HEIGHT=30><FONT SIZE=-1 COLOR=""##808080"" FACE=""ARIAL"">' + i + '<\/FONT><\/TD>';
         }
    
         output += '<\/TR><\/TABLE><\/FORM><\/TD><\/TR><\/TABLE><\/TD><\/TR><\/TABLE>';
    
         return output;
     }
    
     function changeDay(day) {
	 	 opener.day = day + '';
         opener.restart();
         self.close;
     }
    
     function changeMonth() {
         opener.month = document.Cal.Month.options[document.Cal.Month.selectedIndex].value + '';
         location.href = '#Calender_File_Name#';
     }
    
     function changeYear() {
         opener.year = document.Cal.Year.options[document.Cal.Year.selectedIndex].value + '';
         location.href = ""#Calender_File_Name#"";
     }
    
     function makeArray0() {
         for (i = 0; i<makeArray0.arguments.length; i++)
             this[i] = makeArray0.arguments[i];
     }
   
	 function GetFocus() {
	 	if(window.top.name == 'CalendarWindow'){
		//self.focus()
		}
	 }    
     var names     = new makeArray0('January','February','March','April','May','June','July','August','September','October','November','December');
     var days      = new makeArray0(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
     var dow       = new makeArray0('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
     
	 //--></SCRIPT>
	 </HEAD>
    
     <BODY BGCOLOR=""##F5F5F5"" TOPMARGIN=2 LEFTMARGIN=5>

     <P><CENTER>
    
     <SCRIPT LANGUAGE=""JavaScript""><!--
     document.write(Calendar(opener.month,opener.year));
     self.focus();
	 //--></SCRIPT>
    
     </CENTER>
     </BODY>
     </HTML>
     <!-- End html code for cal.htm -->
    ">
<!--- End of Writefile Tag --->

<cfelseif Attributes.ShowCalanderButton AND NOT Attributes.WriteFile AND NOT FileExists(GetDirectoryFromPath(GetTemplatePath())&"#Calender_File_Name#")>
  <!--- Error Found! Get outta my tag --->
  <cfabort showerror="<blockquote><b>Error in the execution of cf_easydate</b><BR><BR>
    The required file #Calender_File_Name# must be present in the #GetDirectoryFromPath(GetTemplatePath())# directory in order
    for the pop-up calendar to function.  Either enable the attribute ""WriteFile=yes"" to have cf_easydate
    write the file or cut and paste the code from inside cf_easydate's cffile tag. #RepeatString("&nbsp;",10)#<p>&nbsp;<p>">
</cfif>

<cfset Attributes.DBLSpeed = Attributes.DBLSpeed - 1><!--- Adjust DBLSpeed to account for the single click --->
<cfset Attributes.DBLSpeed = Abs(Int(Attributes.DBLSpeed))><!--- Make sure DBLSpeed is an positive integer --->

<!--- Place Style Sheet and JavaScript in document header --->
<!---<cfhtmlhead text="--->
<cfoutput>
<style type="text/css">
<!--
.DateButtons {
  font-family: MS Sans Serif;
  font-size: x-small;
  font-weight: bold;
}
// -->
</style>
<script type="text/javascript" language="JavaScript">
<!--
  // returns array with days in the months
    function Easy_Date_arrayOfDaysInMonths(adm_isLeapYear) {
      this[0] = 31;
      this[1] = 28;
      // if Leap Year there is 29 days in Feb
        if (adm_isLeapYear)
          this[1] = 29;
      this[2] = 31;
      this[3] = 30;
      this[4] = 31;
      this[5] = 30;
      this[6] = 31;
      this[7] = 31;
      this[8] = 30;
      this[9] = 31;
      this[10] = 30;
      this[11] = 31;
    }
 
 // _________________________________________________________
 // The next two functions handle the formatting of the date.
 // To add a new mask you only need to added the conversion
 // to the next two functions respectively
 // _________________________________________________________
 
 // Split the date based on format
    function Easy_Date_SplitDate(stDate, format){
  		arryDate = stDate.split('/');
	    arryNewDate = new Array(3);
    	if (format == 'mm/dd/yyyy')
        	arryNewDate = new Array(arryDate[0]-0,arryDate[1]-0,arryDate[2]-0);
	    else if(format == 'dd/mm/yyyy')
    	    arryNewDate = new Array(arryDate[1]-0,arryDate[0]-0,arryDate[2]-0);
      	return arryNewDate; //Return date array: [0] = month, [1] = day, [2] = year		
    }
 // Join the date based on format 
    function Easy_Date_JoinDate(arryDate, format){ //arryDate: [0] = month, [1] = day, [2] = year
	  if (format == 'mm/dd/yyyy')
        var stDate = (arryDate[0]<10?'0'+arryDate[0]:arryDate[0]) + '/' + (arryDate[1]<10?'0'+arryDate[1]:arryDate[1]) + '/' + arryDate[2];
      else if(format == 'dd/mm/yyyy')
        var stDate = (arryDate[1]<10?'0'+arryDate[1]:arryDate[1]) + '/' + (arryDate[0]<10?'0'+arryDate[0]:arryDate[0]) + '/' + arryDate[2];
	  return stDate      
    }  
    
 // Returns the days in the given month and year
   function Easy_Date_daysInMonth(dim_month,dim_year) {
     // Check for leap year
       var dim_isLeapYear = (((dim_year % 4 == 0) && ( dim_year % 100 != 0)) || (dim_year % 400 == 0));
     // Create array of days in each month
       var dim_monthDays = new Easy_Date_arrayOfDaysInMonths(dim_isLeapYear);
     // Return the days in month
       return dim_monthDays[dim_month];
   }
	
  	// Validates date on onBlur of date field
	function Easy_Date_ValidateDate(ObjDate) {
		var strDate = ObjDate.value;
		var required = false;
		if(ObjDate.required)
		{
			required = true;
		}
		if(strDate.length == 0) strDate='x'
		arryDate = Easy_Date_SplitDate(strDate, ObjDate.format);	// Split the date up into a month day year array
		if ((!required || strDate.length) && (isNaN(parseInt(arryDate[2])) || arryDate[2] > 9999 || arryDate[2] < 1000 || isNaN(parseInt(arryDate[0])) || arryDate[0] > 12 || arryDate[0] < 1 || isNaN(parseInt(arryDate[1])) || arryDate[1] < 1 || arryDate[1] > Easy_Date_daysInMonth(arryDate[0] - 1,arryDate[2]))) {
			arryDate[0] = ObjDate.Month_ResetDate;
			arryDate[1] = ObjDate.Day_ResetDate;
			arryDate[2] = ObjDate.Year_ResetDate;
		}
	    ObjDate.value = Easy_Date_JoinDate(arryDate, ObjDate.format);
	}			
  
	// Make sure date being processed is valid if not, set date to today
	function Easy_Date_isValidDate(dateObj) {
		if (isNaN(parseInt(dateObj[0])) || isNaN(parseInt(dateObj[1])) || isNaN(parseInt(dateObj[2]))) {
			dateObj[0] = dateObj.Month_ResetDate;
			dateObj[1] = dateObj.Day_ResetDate;
			dateObj[2] = dateObj.Year_ResetDate;
		}
		return (dateObj);
	}				
		
  function Easy_Date_nextDay(n, thisObj) {
  		Easy_Date_ValidateDate(thisObj);
		currDate = thisObj.value;
		arryDate = Easy_Date_SplitDate(currDate, thisObj.format);		// Split the date up into a month day year array
		arryDate = Easy_Date_isValidDate(arryDate);
		daysinCurrMonth = Easy_Date_daysInMonth(parseInt(arryDate[0])-1,parseInt(arryDate[2]));		// Get the number of days in the current month
		arryDate[1] = parseInt(arryDate[1]) + n;		// Add one to the day
		// Check for day value to be more than days in the month
		if (arryDate[1] > daysinCurrMonth) {
			nextMonth = parseInt(arryDate[0]) + 1;
			if (nextMonth > 12) {
				arryDate[0] = 1;
				arryDate[2] = parseInt(arryDate[2]) + 1;
			}
			else
				arryDate[0] = nextMonth;
			arryDate[1] = 1;
		}
		thisObj.value = Easy_Date_JoinDate(arryDate, thisObj.format);
  }    
  function Easy_Date_previousDay(n, thisObj) {
  		Easy_Date_ValidateDate(thisObj);
		currDate = thisObj.value;
		arryDate = Easy_Date_SplitDate(currDate, thisObj.format);
		arryDate = Easy_Date_isValidDate(arryDate);
		daysinPrevMonth = Easy_Date_daysInMonth(parseInt(arryDate[0])-2,parseInt(arryDate[2]));
		arryDate[1] = parseInt(arryDate[1]) - n;
		// Check for day of zero
		if (arryDate[1] < 1) {
			prevMonth = parseInt(arryDate[0]) - 1;
			if(prevMonth == 0) {
				arryDate[0] = 12;
				arryDate[2] = parseInt(arryDate[2]) - 1;
				arryDate[1] = 31;
			}
			else {
				arryDate[0] = prevMonth;
				arryDate[1] = daysinPrevMonth;
			}
		}
		thisObj.value = Easy_Date_JoinDate(arryDate, thisObj.format);
  }

  function y2k(number)    { return (number < 1000) ? number + 1900 : number; }
  
  var today = new Date();
  var day   = today.getDate();
  var month = today.getMonth();
  var year  = y2k(today.getFullYear());
  var activeDateField;
  
function restart() {
	arryDate = new Array((parseInt(month)+1),day,year)
	//alert(activeDateField.value);
    activeDateField.value = Easy_Date_JoinDate(arryDate, activeDateField.format);
    mywindow.close();
}
  
  function Easy_Date_newWindow(DateField) {
      if (DateField.value != ''){
    		arryDate = Easy_Date_SplitDate(DateField.value, DateField.format);
        month = arryDate[0]-1;
        year = arryDate[2];
        day = arryDate[1];
      }
      activeDateField = DateField;
	  var leftdistance = (screen.width - 350) / 2;
	  var topdistance = (screen.height - 270) / 2;
      mywindow=open('#Calender_File_Name#','CalendarWindow','resizable=no,width=350,height=270, top='+topdistance+', left='+leftdistance);
	  mywindow.location.href = '#Calender_File_Name#';
      if (mywindow.opener == null) mywindow.opener = self;
	
  }
// -->
</script>
</cfoutput>

<!---">--->
<cfoutput>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is my version of the code that was distributed. It uses iamges instead of buttons		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif Mid(CGI.HTTP_USER_AGENT,9,4) gte 4.0>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD ROWSPAN="2"><input type="Text" name="#Attributes.FieldName#" size="10" maxlength="10" value="#DateFormat(Attributes.default,Attributes.Format)#" onFocus="this.select();" onblur="Easy_Date_ValidateDate(this);" STYLE="font-size:10pt;" required format="#Attributes.Format#" Year_ResetDate="#Year(ResetDate)#" Day_ResetDate="#Day(ResetDate)#" Month_ResetDate="#Month(ResetDate)#" #Attributes.INP_ARGUMENTS#>&nbsp;</TD>
	<TD ROWSPAN="2"><cfif Attributes.ShowCalanderButton><IMG SRC="/images/calendar2.gif" BORDER="0" TITLE="Click here to get a calendar" onClick="Easy_Date_newWindow(document.#Attributes.FormName#.#Attributes.FieldName#);" STYLE="cursor: pointer;"></cfif></TD>
	<TD><IMG SRC="/images/up2.gif" BORDER="0"CLASS="DateButtons" TITLE="Click to go forward one day" onClick="Easy_Date_nextDay(1, document.#Attributes.FormName#.#Attributes.FieldName#);"  onDblClick="Easy_Date_nextDay(#Attributes.DblSpeed#, document.#Attributes.FormName#.#Attributes.FieldName#);" STYLE="cursor: pointer;"></TD>
</TR>
<TR>
	<TD><IMG SRC="/images/down2.gif" BORDER="0" CLASS="DateButtons" TITLE="Click to go back one day" onClick="Easy_Date_previousDay(1, document.#Attributes.FormName#.#Attributes.FieldName#);" onDblClick="Easy_Date_previousDay(#Attributes.DblSpeed#, document.#Attributes.FormName#.#Attributes.FieldName#);"STYLE="cursor: pointer;"></TD>
</TR>
</TABLE>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the original code as it was distributed												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---																									 
<input type="Text" name="#Attributes.FieldName#" size="10" maxlength="10" value="#DateFormat(Attributes.default,Attributes.Format)#" onFocus="this.select();" onblur="#Attributes.FieldName#ValidateDate(this.value);">
<nobr>
<cfif Mid(CGI.HTTP_USER_AGENT,9,4) gte 4.0>
	<input type="Button" class="DateButtons" name="Previous" value=" - " onClick="#Attributes.FieldName#previousDay(1);" onDblClick="#Attributes.FieldName#previousDay(#Attributes.DblSpeed#);">
	<nobr>
	<cfif Attributes.ShowCalanderButton>
		<INPUT TYPE="button" class="DateButtons" VALUE="<c>" onClick="#Attributes.FieldName#newWindow(document.#Attributes.FormName#.#Attributes.FieldName#);">
		<nobr>
	</cfif>
<input type="Button" name="Next" class="DateButtons" value=" + " onClick="#Attributes.FieldName#nextDay(1);" onDblClick="#Attributes.FieldName#nextDay(#Attributes.DblSpeed#);">
</cfif>
 --->
 
</cfoutput>

<cfsetting enablecfoutputonly="No">


