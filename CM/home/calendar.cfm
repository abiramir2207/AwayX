<!--- Get this month --->
<CFPARAM NAME="thisdate" DEFAULT=#now()#>

<!--- The size of the boxes --->
<CFSET boxsize=15>

<STYLE>
td.calendar {font: 10px Arial;}
a	{STYLE="text-decoration: none;"}

</STYLE>

<CFLoop From = "#month(thisdate)#" To = "#month(thisdate)#" Index = "Month">
	<CFOutput>
		<CFSet objDate = #CreateDateTime(Year(Now()), Month, 1, 0, 0, 1)#>
		<CFSet MonthStartDay = #DayOfWeekAsString(DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), 1, 0, 0, 1)))#>
		<CFSet MonthEndDay = #DayOfWeekAsString(DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), DaysInMonth(objDate), 0, 0, 1)))#>
		<CFIF #DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), 1, 0, 0, 1))# IS 1>
			<CFSet GrayDayStart = 0>
		<CFElse>
			<CFSet GrayDayStart = #Evaluate(DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), 1, 0, 0, 1))-1)#>
		</CFIF>
		<CFSet GrayDayEnd = #Evaluate(7 - DayOfWeek(CreateDateTime(Year(objDate), Month(objDate), DaysInMonth(objDate), 0, 0, 1)))#>

			<Table BGCOLOR="FFFFFF" Border = "0" Cellpadding = "0" Cellspacing = "0">
			<!--- <Table BGCOLOR="4169E1" Border = "0" Cellpadding = "0" Cellspacing = "1"> --->
				<TR ALIGN="center">
					<TD COLSPAN="7" BGCOLOR="White" STYLE="font-family: Arial;">

						<!--- Previous month is.... --->
						<CFSET previousdate=DateAdd("m", -1, createdate(year(thisdate),month(thisdate),1))> 

						<!--- Next month is... --->
						<CFSET nextdate=DateAdd("m", 1, createdate(year(thisdate),month(thisdate),1))> 
						
						<A HREF="index.cfm?thisdate=#month(previousdate)#/#day(previousdate)#/#year(previousdate)#"><IMG SRC="/cm/images/previous_small.gif" ALT="previous month..." BORDER="0"></A>
						<B><FONT SIZE="1">#ucase(left(MonthAsString(Month(objDate)),3))# #Year(thisdate)#</FONT></B>
						<A HREF="index.cfm?thisdate=#month(nextdate)#/#day(nextdate)#/#year(nextdate)#"><IMG SRC="/cm/images/next_small.gif" ALT="next month..." BORDER="0"></A>

					</TD>
				</TR>
				<TR>
					<CFLoop From = "1" To = "7" Index = "x">
						<TD Align = "Center" CLASS="calendar" STYLE=" border-bottom: 1 solid black;"><B>#left(DayOfWeekAsString(x),1)#</B></TD>
					</CFLoop>
				</TR>
				<TR>
					<CFIF NOT #GrayDayStart# IS 0>
						<CFLoop From = "1" To = "#GrayDayStart#" Index = "x">
							<TD BGColor = "FFFFFF" Width = "#boxsize#" Height = "#boxsize#" CLASS="calendar">&nbsp;</TD>
						</CFLoop>
					</CFIF>
					<CFLoop From = "1" To = "#DaysInMonth(objDate)#" Index = "x">

					<!--- Check if this is today's date. If it is change the color of the cell background to ........... --->
					<CFIF  CreateDate(year(now()), #month(thisdate)#, #x#) eq CreateDate(year(now()), month(now()), day(now()))>
						<CFSET daystyle="border: 1 solid red;">
					<CFELSE>
						<CFSET daystyle="border: 0 solid silver;">
					</CFIF>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

						<A HREF="scorecards/index.cfm?id=#month(thisdate)#/#x#/#year(thisdate)#" TARGET="mainwindow" STYLE="text-decoration: none; color: White;"><TD Width = "#boxsize#" Height = "#boxsize#" ALIGN="center" CLASS="calendar" STYLE="cursor: hand; #daystyle#">#x#</TD></A>

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

	</CFOutput>
</CFLoop>


