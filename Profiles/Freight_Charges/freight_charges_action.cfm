<SCRIPT language="JavaScript">
	function CellOn(CellName)
		{
			eval("CellName.bgColor = 'CCFFCC'")
		}

	function CellOff(CellName)
		{
			eval("CellName.bgColor = 'FFFFFF'")
		}
</SCRIPT>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 
: R            = radius of sphere
: (Lat1, Log1) = latitude and longitude of point 1.
: (Lat2, Log2) = latitude and longitude of point 2.
: D12          = great circle distance between points 1 and 2. 
: Then 
: D12 =
:   R x arccos[ sin(Lat1) x sin(Lat2) + cos(Lat1) x cos(Lat2) x cos(Log1-Log2) ]

 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get City, County and State																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_City = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("zipcodes")>
<cfif useLakebaseForGet_City>
	<cftry>
		<cfset Get_City = application.oLakebase.toQuery(
			application.oLakebase.selectRows("zipcodes", {
				"zipcode" = "eq.#Zip_Code#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_City = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_City>
<CFQUERY NAME="Get_City" datasource="#application.datasource#">
Select		*
From 		ZipCodes
Where		ZipCode	=	#Zip_Code#
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the freight details																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Freight_Details" datasource="#application.datasource#">
Select		*
From		BSA_Foodservice_Freight_Charges
Where		Zip_From	<=	'#Zip_Code#'
			and
			Zip_To		>=	'#Zip_Code#'
Order By	Warehouse
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If there are no records give message and stop													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Get_Freight_Details.Recordcount EQ 0>
	<BR><BR><BR>
	<BLOCKQUOTE><BLOCKQUOTE>
	<CFOUTPUT><H4>There are no records that match this Zip Code.<BR>Please try a different Zip Code</H4></CFOUTPUT></BLOCKQUOTE></BLOCKQUOTE>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</BODY>
	</HTML>
	<CFABORT>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<style>
	TABLE.Maintable TD 
		{border-bottom:solid #93BEE2 1px; font-size : 11px;}
</style>

<TABLE CELLSPACING="20" BORDER="0">
<TR>
	<TD VALIGN="top" COLSPAN="2">
	
<TABLE>
	<TR>
		<TD>
		<CFOUTPUT QUERY="Get_City">
			<SPAN CLASS="title2">Shipping To:</SPAN>
				<HR SIZE="1" COLOR="Orange">
				<B>#City#, #CountyName#, #Zip_Code#, #StateName#</B>
		</CFOUTPUT>
		</TD>
		<TD>
			<TABLE WIDTH=250 BORDER=0 CELLPADDING=0 CELLSPACING=0>
				<TR>
					<TD>
						<IMG SRC="/images/truck_01.gif" WIDTH=21 HEIGHT=77></TD>
					<TD>
						<IMG SRC="/images/<CFOUTPUT>#RANDRANGE(1,6)#</CFOUTPUT>.gif" WIDTH=71 HEIGHT=77></TD>
					<TD>
						<IMG SRC="/images/truck_03.gif" WIDTH=158 HEIGHT=77></TD>
				</TR>
				<TR>
					<TD COLSPAN=3>
						<IMG SRC="/images/truck_04.gif" WIDTH=250 HEIGHT=51></TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
</TABLE>
	
	</TD>
</TR>
<TR>
	<CFOUTPUT QUERY="Get_Freight_Details" GROUP="Warehouse">
	<TD VALIGN="top" VALIGN="top">
		<SPAN CLASS="title2">Shipping From:</SPAN>
		<HR SIZE="1" COLOR="Orange">
		<SPAN CLASS="title2">#Warehouse#</SPAN><BR>#Address#<BR>
		Minimum Order #numberformat(Min_Order, '_,___,___')#lbs.<BR>#Terms#<BR>Effective: #dateformat(Effective, 'mm/dd/yyyy')#
		<TABLE CELLPADDING="2" CELLSPACING="0" BGCOLOR="dddddd" WIDTH="100%"  CLASS="Maintable">
			<TR>
				<TD NOWRAP BGCOLOR="White"><B>From - To (Lbs.)</B></TD>
				<TD BGCOLOR="White"><B>$/Lbs. (*)</B></TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>2,500 - 4,999</TD>
				<TD>#numberformat(Pounds_2500_4999, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>5,000 - 9,999</TD>
				<TD>#numberformat(Pounds_5000_9999, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>10,000 - 14,999</TD>
				<TD>#numberformat(Pounds_10000_14999, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>10,000 - 19,999</TD>
				<TD>#numberformat(Pounds_10000_19999, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>15,000 - 20,000</TD>
				<TD>#numberformat(Pounds_15000_20000, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>20,000 - 29,999</TD>
				<TD>#numberformat(Pounds_20000_29999, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>20,001 - Truck Load&nbsp;&nbsp;&nbsp;</TD>
				<TD>#numberformat(Pounds_20001_TL, '0.00')#</TD>
			</TR>
			<TR BGCOLOR="White" onMouseOver="CellOn(this)" onMouseOut="CellOff(this)">
				<TD>30,000 - Truck Load&nbsp;&nbsp;&nbsp;</TD>
				<TD>#numberformat(Pounds_30000_TL, '0.00')#</TD>
			</TR>
		</TABLE>
	</TD>
	</CFOUTPUT>
</TR>
</TABLE>
&nbsp;&nbsp;&nbsp;
(*) A zero denotes that the weight bracket does not apply to this warehouse.

