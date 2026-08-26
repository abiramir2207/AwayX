<CFSET s1="Retrieving position tree">
<CFSET s2="Confirming access levels">
<CFSET s3="Retrieving primary data">
<CFSET s4="Retrieving relational data">
<CFSET s5="Performing calculations">
<CFSET s6="Compiling results">
<CFSET s7="Storing data">
<CFSET s8="Deleting temporary data">
<CFSET s9="Rendering data">


<CFSET itemlist=S1&","&S2&","&S3&","&S4&","&S5&","&S6&","&S7&","&S8&","&S9>


<!------------------------------------------
Input that can be provided are the following
PW.Total_Time : Sets the Total Estimated Time 
PW_DoNotCFFLUSH : Some pages which has Easy data in it has problem with CFFlush, so this won't be flushed
PW.Message_List : Default messages can be overrided by providing a list of messages.
PW.Show_Last_Check : 0 - does not show the last check
					 NEQ 0 - Will show the last check 
------------------------------------------->
<CFPARAM NAME="PW.Total_Time" 	DEFAULT=2>
<CFPARAM NAME="PW_DoNotCFFLUSH" DEFAULT="0">
<CFPARAM NAME="PW.Message_List" DEFAULT="#itemlist#">
<CFPARAM NAME="PW.Show_Last_Check" DEFAULT="0">

<CFSET itemlist = PW.Message_List>


<CFOUTPUT>
<HTML>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<SCRIPT LANGUAGE="JavaScript">
var Total_Time = #PW.Total_Time#;
var ColumnLength = #ListLen(itemlist)#;

var text_Interval = 0.1;

var Total_Text_Time = text_Interval * ColumnLength;
var Total_Remaining_Time = Total_Time - Total_Text_Time;
var check_Interval = Total_Remaining_Time/ColumnLength;
var whichRow = 0;

var oTimerCheck, oTimerText;
oTimerText = setTimeout("showText()", text_Interval * 1000);

//To Verify the Total Time Taken
var startTime = new Date();

function showText()
{
	var showObj;
	var message_Table = document.all.plswait_message_Table;
	if(message_Table.length)
	{
		if(message_Table.length > whichRow)
		{
			showThisText(message_Table[whichRow].rows[0].cells[0]);
		}
		else
		{
			//To Verify the Total Time Taken
			var endTime = new Date();			
			//alert("Took " + secs_less(endTime,startTime) + " secs");
		}
	}
	else if(whichRow == 0)
	{
		showThisText(message_Table.rows[0].cells[0]);
	}
}


function showCheck()
{
	var showObj;
	var message_Table = document.all.plswait_message_Table;
	if(message_Table.length)
	{
		<CFIF PW.Show_Last_Check EQ "0">
		if(message_Table.length > (whichRow+1))
		<CFELSE>
		if(message_Table.length > whichRow)
		</CFIF>		
		{
			showThisCheck(message_Table[whichRow].rows[0].cells[1]);
			whichRow = whichRow + 1;
		}		
	}
	<CFIF PW.Show_Last_Check NEQ "0">
	else if(whichRow == 0)
	{
		showThisCheck(message_Table.rows[0].cells[1]);
	}
	</CFIF>
}

function showThisText(oCell)
{
	eval("showObj=oCell.all.SP_TX_" + whichRow + ";");
	showObj.style.visibility = "visible";
	oTimerCheck = setTimeout("showCheck()",check_Interval * 1000);
}

function showThisCheck(oCell)
{
	eval("showObj=oCell.all.SP_CH_" + whichRow + ";");
	showObj.style.visibility = "visible";
	oTimerText = setTimeout("showText()",text_Interval * 1000);
}
/*
////need only to verify the ime taken , at the end 
function secs_less(date1, date2) {

    // The number of milliseconds in one day
    // Convert both dates to milliseconds
    var date1_ms = date1.getTime()
    var date2_ms = date2.getTime()

    // Calculate the difference in milliseconds
    //var difference_ms = Math.abs(date1_ms - date2_ms)
	var difference_ms = date1_ms - date2_ms;
    
    // Convert back to days and return
    //return Math.round(difference_ms/1000)
	return difference_ms/1000

}
*/
</SCRIPT>
</CFOUTPUT> 

<CFOUTPUT>
<CFSET counter=0>
<CFLOOP INDEX="item" LIST="#itemlist#">
 <TABLE WIDTH="600" ID="plswait_message_Table" NAME="plswait_message_Table" ALIGN="CENTER" CELLSPACING="0" CELLPADDING="0">
 <TR>
  <TD WIDTH="300" STYLE="border-bottom:solid WhiteSmoke 1px;"><SPAN STYLE="color: Navy; font-size: 12px; font-weight: bold;" ID="SP_TX_#counter#">#item#</SPAN></TD>
  <TD ALIGN="CENTER" STYLE="border-bottom:solid WhiteSmoke 1px;">&nbsp;<SPAN STYLE="visibility: hidden;" ID="SP_CH_#counter#"><IMG SRC="/images/yes_small.gif" ALT="" WIDTH="12" HEIGHT="12" BORDER="0"></SPAN></TD>
 </TR>
 </TABLE>
 <CFSET counter=counter+1>
</CFLOOP>
 </CFOUTPUT>
 </BODY>
 </HTML>
<!------
<CFIF PW_DoNotCFFLUSH EQ 0>
	<CFFLUSH>
</CFIF>
----->