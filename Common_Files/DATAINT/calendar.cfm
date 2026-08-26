<CFOutput>
<!--- <CFLOOP INDEX="datecounter" FROM="0" TO="90" STEP="30"> --->
<CFLOOP INDEX="datecounter" FROM="0" TO="-3" step="-1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This month's calendar																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get this month --->
<script>
function changebgcolor() 
{
var allTDs = document.getElementsByTagName("td")
for (var i = 0; i < allTDs.length; i++) 
 {
   allTDs[i].style.backgroundColor = '##ffffff'
 }
}
</script>

<!--- <CFSET thisdate=evaluate(now()-datecounter)> --->
<CFSET thisdate=DateAdd("m", datecounter, now())>
<!--- <cfoutput>#thisdate#</cfoutput> --->
<CFSET boxsize=18>

<STYLE>
	td.calendar {font: 11px Arial;}
	a			{text-decoration: none; color: blue;}
	.xxx {
		background-color : ##BFFDB5;
	}
</STYLE>

<CFLoop From = "#month(thisdate)#" To = "#month(thisdate)#" Index = "Month">

		<CFSet objDate = CreateDateTime(Year(thisdate), Month, 1, 0, 0, 1)>
		<CFSet MonthStartDay = DayOfWeekAsString(DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), 1, 0, 0, 1)))>
		<CFSet MonthEndDay = DayOfWeekAsString(DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), DaysInMonth(objDate), 0, 0, 1)))>
		<CFIF DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), 1, 0, 0, 1)) IS 1>
			<CFSet GrayDayStart = 0>
		<CFElse>
			<CFSet GrayDayStart = Evaluate(DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), 1, 0, 0, 1))-1)>
		</CFIF>
		<CFSet GrayDayEnd = Evaluate(7 - DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), DaysInMonth(objDate), 0, 0, 1)))>

			<Table BGCOLOR="FFFFFF" Border = "0" Cellpadding = "0" Cellspacing = "0">
				<TR ALIGN="center">
					<TD COLSPAN="7" BGCOLOR="White" STYLE="font-family: Arial;">
						<DIV STYLE="color: Gray; font-size: 14px; font-weight: bold;">#ucase(left(MonthAsString(Month(objDate)),3))# #Year(thisdate)#</DIV>
					</TD>

				</TR>
				<TR>
					<CFLoop From = "1" To = "7" Index = "x">
						<TD Align = "Center" CLASS="calendar" STYLE=" border-bottom: 1 solid Silver;"><B><DIV STYLE="color: Silver;">#left(DayOfWeekAsString(x),1)#</DIV></B></TD>
					</CFLoop>
				</TR>
				<TR>
					<CFIF NOT GrayDayStart IS 0>
						<CFLoop From = "1" To = "#GrayDayStart#" Index = "x">
							<TD BGColor = "FFFFFF" Width = "#boxsize#" Height = "#boxsize#" CLASS="calendar">&nbsp;</TD>
						</CFLoop>
					</CFIF>
					<CFLoop From = "1" To = "#DaysInMonth(objDate)#" Index = "x">
					    <!---  see if their was any activity for this day and highlight the cell --->
							<cfquery datasource="#application.datasource#" name="qDataIntDates">
									SELECT      count(*) as ifcount
									FROM         Data_integration_Upload
									WHERE			datepart(mm, created_date)	 = 	<CFqueryparam value="#datepart("m",createdate(year(thisdate),  month(objDate),  x))#">
										and  		datepart(dd, created_date)	 =	<CFqueryparam value="#datepart("d",createdate(year(thisdate),  month(objDate),  x))#">
										and			datepart(yyyy, created_date) =	<CFqueryparam value="#datepart("yyyy",createdate(year(thisdate),  month(objDate),  x))#">
							</cfquery>
							
							
					<!--- Check if this is today's date. If it is change the color of the cell background to ........... --->
					<CFIF  CreateDate(year(now()), #month(thisdate)#, #x#) eq CreateDate(year(now()), month(now()), day(now()))>
						<CFSET daystyle="border: 1 solid red;">
						<CFSET daystlon="1 solid red">
						<CFSET daystlout="1 solid red">
						<cfset tbord = "bordon">
					<CFELSE>
						<CFSET daystyle="border: 1 solid white;">
						<CFSET daystlon="1 solid red">
						<CFSET daystlout="1 solid white">
						<cfset tbord = "bordoff">
					</CFIF>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<TD Width = "#boxsize#" Height = "#boxsize#" ALIGN="center" CLASS="calendar" STYLE="#daystyle#" onmouseover="this.style.border='#daystlon#'" onmouseout="this.style.border='#daystlout#'" onclick="changebgcolor();this.style.backgroundColor = '##BFFDB5'" title="#qDataIntDates.ifcount# Interfaces Run"><cfif qDataIntDates.ifcount gt 0><A HREF="dataIntViewer.cfm?m=#month(thisdate)#&d=#x#&y=#year(thisdate)#" style="cursor:pointer;color:red;" TARGET="dataIntMainwindow">#x#</a><cfelse><span title="No Data Integration Activity"><A HREF="dataIntViewer.cfm?m=#month(thisdate)#&d=#x#&y=#year(thisdate)#" style="cursor:default;" TARGET="dataIntMainwindow">#x#</A></span></cfif></TD>
						<CFIF #Evaluate((x + GrayDayStart)/7)# IS #Int(Evaluate((x + GrayDayStart)/7))#>
							</TR>
							<CFIF NOT #x# IS #DaysInMonth(objDate)#>
								<TR>
							</CFIF>
						</CFIF>
					</CFLoop>
					<CFIF NOT #GrayDayEnd# IS 0>
						<CFLoop From = "1" To = "#GrayDayEnd#" Index = "x">
							<TD BGColor = "FFFFFF" Width = "#boxsize#" Height = "#boxsize#" CLASS="calendar">&nbsp;</TD>
						</CFLoop>
					</CFIF>
				</TR>
				
			</Table>

</CFLoop>

<!--- <BR><BR> ---> 

</CFLOOP>
</CFOutput>
<table align="center">
<TR align="center">
	<TD colspan="7"><!--- Activity in <span style="color:red">red</span>. --->
		<a href="dataIntViewer_blank.cfm"  TARGET="dataIntMainwindow" title="Data Integration Home"><span style="color:Navy">Integration Home</span></a>
	</TD></TR><!--- ##EAFFEA B5FDE6 FEC7C0  <span style="background-color: #C5FDBB;"> red.</span>--->
</table>
<!--- </td>
</tr>
</table> --->

