<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Search - postal code</TITLE>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFSET thisPage = CGI.SCRIPT_NAME>
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.ZIPCode" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="URL.ExcludeListFieldname" 	DEFAULT="">

<CF_Popup_Search
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.ZIPCode#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			ExcludeListFieldname="#URL.ExcludeListFieldname#"
			>


<CFPARAM NAME="FORM.ExcludeList" 	DEFAULT="">

<CFPARAM NAME="form.StateCode" DEFAULT="">
<CFPARAM NAME="form.city" DEFAULT="">
<CFPARAM NAME="form.county" DEFAULT="">
<CFPARAM NAME="form.state" 	DEFAULT="0">
<cfparam name="form.showAssigned" 	default="0">
<cfparam name="form.operatorExist" 	default="0">
<cfparam name="form.search_zipCode" 	default="">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of states from the States table.
Don't use the list from the Zipcodes table since the list also includes military installation --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" DATASOURCE="#application.datasource#" cachedWithin = "#CreateTimeSpan(30, 0, 0, 0)#">
	Select		DISTINCT StateCode, State
	From		zipCodes
	Order by 	State
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<script language="JavaScript">
	function reset_Form_Fields(searchForm)
	{
		searchForm.reset();
		searchForm.City.value = "";
		searchForm.County.value = "";
		searchForm.showAssigned.checked = false;
		searchForm.operatorExist.checked = false;
		searchForm.search_zipCode.value = "";
	}
</script>
<FORM ACTION="#thisPage#" METHOD="post" name="frmZipCodes">

<FIELDSET STYLE="padding:8px; width: 500px; border: 1px solid Blue;display:table;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">postal code search</LEGEND>
	<TABLE cellpadding="2" cellspacing="0" border="0">
	<TR>
		<TD>
		<B>City:</B><BR>
		<INPUT NAME="City" TYPE="text" value="#form.city#">
		</TD>
		<TD>
		<B>County:</B><br>
		<INPUT NAME="County" TYPE="text" value="#form.county#">
		</TD>
		<TD>
		<B>State:</B><br>
		<SELECT NAME="StateCode">
			<OPTION VALUE="">Select the state...</OPTION>
			<CFLOOP QUERY="Get_States">
			<OPTION VALUE="#statecode#" <CFIF form.StateCode EQ statecode> SELECTED</CFIF>>#state#</OPTION>
			</CFLOOP>
		</SELECT>
		</TD>
		<TD>
		<B>Sort by:</B><br>
		<SELECT NAME="Sort_By">
			<OPTION VALUE="ZipCodes.ZIPCode" SELECTED>Postal Codes</OPTION>
			<OPTION VALUE="ZipCodes.City">City</OPTION>
		</SELECT>
		</TD>
		<TD>
		<B>Sort Order:</B><br>
		<SELECT NAME="Order_By">
			<OPTION VALUE="Asc" SELECTED>Ascending</OPTION>
			<OPTION VALUE="Desc">Descending</OPTION>
		</SELECT>
		</TD>
	</TR>
	<SCRIPT language="JavaScript">
	function marketSelected(selObj)
	{
		if(selObj.selectedIndex > 0)
		{
			selObj.form.showAssigned.checked = true;
		}
	}
	function showAssignedSelected(thisObj)
	{
		if(!thisObj.checked)
		{
			thisObj.form.Market_ID.selectedIndex = 0;
		}
	}
	</SCRIPT>
	<TR>
		<TD valign="bottom">
		<B><CFOUTPUT>#application.returned_customer_setting.market_label_singular#</CFOUTPUT></B><BR>
		<CFQUERY NAME="GetMarkets" datasource="#application.datasource#">
		SELECT *
		FROM Service_Markets
		WHERE len(Market_Name) > 0 AND Deleted = 0
		ORDER BY Market_Name
		</CFQUERY>
		<cfparam name="FORM.Market_ID" 	default="">		
		<SELECT NAME="Market_ID" style="width: 200px;" onChange="javaScript: marketSelected(this);">
			<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.market_label_plural#</CFOUTPUT></OPTION>
			<CFLOOP QUERY="GetMarkets"><OPTION VALUE="#trim(GetMarkets.Service_Market_ID)#"#IIF(trim(FORM.Market_ID) EQ GetMarkets.Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(GetMarkets.Market_Name)#</OPTION></CFLOOP>
		</SELECT>	
		</TD>
		<TD valign="bottom" nowrap>
		<INPUT onClick="javaScript: showAssignedSelected(this);" NAME="showAssigned" TYPE="checkbox" value="1"<CFIF form.showAssigned> CHECKED</CFIF>> <B>Show Assigned</B><BR>
		<INPUT NAME="operatorExist" TYPE="checkbox" value="1"<CFIF form.operatorExist> CHECKED</CFIF>> <B>Check For <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></B>
		</TD>
		<TD valign="bottom">
		<B>Postal Code</B><br>
		<INPUT NAME="search_zipCode" TYPE="text" value="#form.search_zipCode#">
		</TD>
		<TD VALIGN="bottom"><FONT COLOR="##ff0000">&nbsp;&nbsp;&nbsp;<B>[</B></FONT><A HREF="javascript: reset_Form_Fields(document.frmZipCodes);"><B>reset</B></A><FONT COLOR="ff0000"><B>]</B></FONT> </TD>
		<TD COLSPAN="2" VALIGN="bottom">
		&nbsp;&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="document.frmZipCodes.startrow.value=1;document.frmZipCodes.frompage.value=1;document.frmZipCodes.submit();return false;">search</a><FONT COLOR="FF0000">]</FONT></B>
		</TD>
		<!------ <TD valign="bottom">
			<INPUT NAME="" TYPE="submit" value="search">
		</TD> ----->
	</TR>
	</TABLE>
<INPUT NAME="state" TYPE="hidden" value="1">

</FIELDSET>

<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="Blue";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";  
	WIDTH="500px";
</CFSCRIPT>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="already selected postal codes"  
	TitleClosed="already selected postal codes"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	<CFSET cntr = 1>
	<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
		<TR>
		<CFLOOP list="#FORM.FinalItemList#" delimiters="," index="thisItem">
			<TD NOWRAP BGCOLOR="eeeeee">#thisItem#</TD>
			<CFIF cntr mod 4><CFELSE></TR><TR></CFIF>
			<CFSET cntr = cntr + 1>
		</CFLOOP>
		</TR>
		 <tr>	<td></td></tr> 
	</TABLE>	
</CF_openLayer>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=12>

<CFIF FORM.state EQ 1>
	<!------ <CFIF form.StateCode NEQ '' OR form.city NEQ '' OR form.county EQ ''> ----->
		
		<STYLE TYPE="text/css">
			body,td
				{
					font: 11px Arial;
				}
			A
				{
					color: blue;
					text-decoration: none;	
				}
			A:HOVER
				{
					color: red;
					text-decoration: underline;	
				}
		</STYLE>
		

		
		<!--- Get the records that match the selected criterria --->
		<CFQUERY NAME="Get_ZipCodes" DATASOURCE="#application.datasource#">
			Select		DISTINCT ZipCodes.ZIPCode, ZipCodes.City, ZipCodes.County, ZipCodes.State, ZipCodes.AreaCode, ZipCodes.TimeZone, ZipCodes.Latitude, ZipCodes.Longitude,
						Service_Markets.Market_Name
			From		ZipCodes
						LEFT JOIN Market_ZipCode
						ON
						Market_ZipCode.ZipCode = ZipCodes.ZIPCode
						AND
						Market_ZipCode.Deleted = 0
						LEFT JOIN Service_Markets
						ON
						Service_Markets.Deleted = 0
						AND
						Service_Markets.Service_Market_ID = Market_ZipCode.Service_Market_ID						
						<CFIF form.operatorExist>
						INNER JOIN BSA_Operator
						ON
						BSA_Operator.Deleted = 0
						AND
						Left(BSA_Operator.Operator_Zip, 5) = ZipCodes.ZIPCode
						</CFIF>
			Where		1	=	1
						<CFIF form.StateCode NEQ "">
							and
							ZipCodes.StateCode	=	'#form.StateCode#'
						</CFIF>
						<CFIF form.city NEQ "">
							and	
							ZipCodes.City		like	'%#form.city#%'
						</CFIF>
						<CFIF form.county NEQ "">
							and	
							ZipCodes.county		like	'%#form.county#%'
						</CFIF>						
						 <CFIF NOT form.showAssigned>
							and 
							Market_ZipCode.Market_ZipCode_ID IS NULL
						</CFIF>
						<CFIF form.search_zipCode NEQ "">
							and	
							ZipCodes.ZIPCode		like	'%#form.search_zipCode#%'
						</CFIF>
						<CFIF FORM.Market_ID NEQ "">
							and
							Service_Markets.Service_Market_ID = #FORM.Market_ID#
						</CFIF>				
						and
						ZipCodes.CityType	=	'D'
			Order by	#form.Sort_By# #form.Order_By#
		</CFQUERY>
		<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">		
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF Get_ZipCodes.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#Get_ZipCodes.recordcount#</CFOUTPUT> <CFIF Get_ZipCodes.recordcount EQ 1>postal code<CFELSE>postal codes</CFIF> That <CFIF Get_ZipCodes.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="90%" CLASS="MainTable">
		<TR BGCOLOR="##ffce84">
			<TD>
			<INPUT TYPE="checkbox" NAME="AllZIPCode" VALUE="" onClick="javaScript: CHSelectAll('ZIPCode', this.checked);">			
			</TD>
			<TD ID="Header"><B>Postal Code</B></TD>
			<TD ID="Header"><B>City</B></TD>
			<TD ID="Header"><B>County</B></TD>
			<TD ID="Header"><B>State</B></TD>
			<TD ID="Header"><B>AreaCode</B></TD>
			<TD ID="Header"><B>TimeZone</B></TD>
			<TD ID="Header"><B>Market</B></TD>
		</TR>
		
		<CFSET AllList = ValueList(Get_ZipCodes.ZIPCode)>
		<CFSET AlreadySelectedItems = "">
		<CFLOOP QUERY="Get_ZipCodes" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
		<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
			<TD>
			<INPUT TYPE="checkbox" NAME="ZIPCode" VALUE="#ZIPCode#"
			<CFIF listfind(FORM.FinalItemList, ZIPCode) NEQ 0>CHECKED
				<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, ZIPCode, ",")>
			</CFIF>
			></TD>
			<TD><A HREF="http://tiger.census.gov/cgi-bin/mapgen?lat=37.0000&lon=-96.0000&wid=50&ht=25&iwd=540&iht=380&mlat=#Latitude#&mlon=#Longitude#&on=&off=BACK&msym=smalldot&mlabel=#City#" onclick="NewWindow(this.href,'name','560','405','No', 'No');return false;">#ZIPCode#</A></TD>
			<TD>#City#</TD>
			<TD>#County#</TD>
			<TD>#State#	</TD>
			<TD>#AreaCode#</TD>
			<TD>#TimeZone#</TD>
			<TD>#Market_Name#&nbsp;</TD>
		</TR>
		</CFLOOP>
		</TABLE>
		</FIELDSET>
	<!------ </CFIF> ----->
	
	<DIV STYLE="font-size: 12px; color: Red;">
		<CF_Next_Previous_For_Forms
		formname="frmZipCodes"
		query="Get_ZipCodes"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: return finishedSearching(document.frmZipCodes)"> import selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: return importAll(document.frmZipCodes)"> import all record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: return removeAll(document.frmZipCodes)"> removed selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<script language="JavaScript">
		function finishedSearching(searchForm)
		{
			searchForm.FinisedSearching.value = 1;
			searchForm.submit();
			return false;
		}
		function importAll(searchForm)
		{
			var AllList = "#AllList#";
			if(window.confirm("Do you want to import all the records from the search result?"))
			{
				searchForm.AlreadySelectedItems.value = "";
				searchForm.FinalItemList.value = AllList;
				finishedSearching(searchForm);
			}
			return false;
		}
		function removeAll(searchForm)
		{
			searchForm.AlreadySelectedItems.value = "";
			searchForm.FinalItemList.value = "";
			searchForm.AllZIPCode.checked = true;
			searchForm.AllZIPCode.click();
			return false;
		}
	</script>
</CFIF>
	<!------ popup search code ----->
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#FORM.ExcludeList#">	
</FORM>
</BODY>
</HTML>
</CFOUTPUT>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Database Fields Explanations for the zipcodes tahle --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---  
Field Data				Type Field Description 

ZIPCode nchar(5) 		5-digit ZIP Code representing a geographic delivery route. 

ZIPCodeType char(1)		The type of ZIP Code, for example: 
						S- Standard ZIP Code 
						P - PO Box Only 
						U - Used for Organizations such as large businesses or buildings 
						M - Military, often used for military vessels, but mostly for military bases 

City varchar(30)		The name of the city or organization designated by that ZIP Code. 

CityType char(1)		Tells if the city name is recommended by the USPS. 
						D - Default City Name - recommended by the USPS 
						A - Alternate City Name, also used by the USPS, although not the primary name of that ZIP Code. 
						N - Not-recommended City Name, identifies the name of the ZIP Code - often used by locals as a place name. Not used, nor accepted, by the USPS. 

County varchar(30)		The name of the county (and sometimes parish) of the ZIP Code. APO and FPO do not have a county. 

CountyFIPS nchar(5)		FIPS stands for "Federal Information Processing Standard". It is used to designate a county, region, or parish within a state. It is often blank when the City is APO or FPO. 

State varchar(75)		The full name of the state (or territory), i.e. California, Texas, etc. 

StateCode char(2)		The two-letter abbreviation for the state name. Military ZIP Codes have abbreviations such as AP, AA, AE, etc. 

StateFIPS nchar(2)		The two-digit number that uniquely identifies a state or territory. 

MSA nchar(4)			Metro Service Area code that groups ZIP Codes in a geographic region together by a common population center. Not all ZIP Codes - many rural - do not have an MSA code. 

Area Code nchar(3)		Area Code belonging to that particular ZIP Code. APO and FPO ZIP Codes will usually not have an area code. 

Time Zone varchar(15)	The Time Zone to which that ZIP Code belongs, as in the case with military (APO/FPO) ZIP Codes, it will usually not have a Time Zone associated with it. 

GMTOffset int 			Indicates the difference in hours between GMT and the time zone for that particular ZIP Code. 

DST char(1) 			Tells if the particular ZIP Code obeys the Daylight Savings change. The field has two values - "Y" for Yes and "N" for No. 

Latitude numeric 		Latitude in degrees of the center (centroid) of the ZIP Code. For military ZIP Codes the Latitude will be 0.0 

Longitude numeric		Longitude in degrees of the center (centroid) of the ZIP Code. For military ZIP Codes the Longitude will be 0.0 
 --->

 
 
 
