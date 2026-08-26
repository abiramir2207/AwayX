<CFOUTPUT>
<cfparam name="url.doAction" 	default="select">
<cfparam name="form.doAction" 	default="#url.doAction#">
<cfparam name="FORM.sort_by" 	default="Postal Code">
<cfparam name="FORM.sort_order" 	default="ASC">
	
	
<CFSET formName = "frmMarketZipCode">

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">
	function submitForm(sAction)
	{
		var oForm = document.#formName#;
		oForm.doAction.value = sAction;
		oForm.submit();
		return false;
	}
	function confirmAssign(recCountObj, destName)
	{
		var recCount = listLength(recCountObj.value, ",");
		if(window.confirm("Do you want to assign all " + recCount + " postal codes to the market '" + destName + "'"))
		{
			submitForm('save');
			show_please_wait(document.all.Hide_For_Please_Wait);
		}
		return false;
	}	
</script>

<CFPARAM NAME="FORM.marketID_List" 	DEFAULT="0">
<CFPARAM NAME="FORM.zipCodes" 	DEFAULT="">

<form action="#ThisPage#" method="post" name="#formName#">	
	<input type="Hidden" name="mode" value="#FORM.mode#">
	<input type="Hidden" name="doAction" value="#FORM.doAction#">	
	<INPUT type="Hidden" name="marketID_List" value="#FORM.marketID_List#">	
	<INPUT type="Hidden" name="zipCodes" value="#FORM.zipCodes#">

<cfset market = CreateObject("component", "components.geography.market") />
<cfset zipcode = CreateObject("component","components.geography.zipcode") />
<cfif FORM.marketID_List>
	<cfset GetMarkets = market.getMarket(FORM.marketID_List)>
</cfif>

<cfset StSearch = StructNew()>
<cfset StSearch.idList = FORM.zipCodes>	
<cfset Get_ZipCodes = zipcode.getZipCode(StSearch, form.sort_by, form.sort_order)>	

<cfif form.doAction EQ "save">	
	<cfif IsNumeric(FORM.marketID_List) AND FORM.marketID_List NEQ "">
		<cfset zipcode.saveMarket(FORM.marketID_List, FORM.zipCodes, request.AccessStructure.User_ID)>
		<script language="JavaScript">
			submitForm('message');
		</script>
	</cfif>
<cfelseif form.doAction EQ "message">
	<BR><BR>
	<center>
	<span class="Title2">The following postal codes have been assigned successfully to '#GetMarkets.Market_Name#' market.</span></center>
	<cfset qSource = Get_ZipCodes>	
	<cfset fieldName = "ZIPCode">
	<cfset maxRows = 15>
	<cfinclude template="../success_display.cfm">
<cfelse>

	<!------ <cfinclude template="markets.cfm"> ----->
	<!------ Market ----->
	<SPAN CLASS="Title2">Postal Code - Assign</SPAN>
	<HR COLOR="Orange">
	Select a Market then search for Postal Codes that you would like to assign to that Market.
	<p>
	<SPAN CLASS="Title2">Market</SPAN>&nbsp;&nbsp;&nbsp;
	<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onclick="javaScript: return search_popup('/search_screens/market_Search.cfm?FormName=#formName#&FieldName=marketID_List&importType=single');">search market</a><FONT COLOR="FF0000">]</FONT></B>
	<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR BGCOLOR="FFCE84">
		<TD ID="Header">
			<b>Market</b>
		</TD>
		<TD ID="Header"><B>Region</B></TD>
		<td ID="Header"><B>Zone</B></td>
		<td ID="Header">&nbsp;</td>
	</TR>
	<TR>
	<cfif FORM.marketID_List>
		<CFIF GetMarkets.RecordCount GT 0>
		<td>
			 #GetMarkets.Market_Name#<BR>
		</td>
		<td>
		 	#GetMarkets.Region_Name#
		</td>			
		<td>
			#GetMarkets.Zone_Name#
		</td>
		<td>
			<A HREF="javascript: void(0);"  OnClick="NewWindow('zipcode/assignedZipCodes.cfm?MID=#GetMarkets.Service_Market_ID#', 'Market_zipcode', '800', '600', 'Yes', 'No', true);">postal codes in this market</A>
		</td>
		</cfif>
	<cfelse>
		<td colspan="5">NONE SELECTED</td>
	</cfif>
	</tr>
	</table>
	<BR><BR>
	<!------ Zip Code ----->
	<SPAN CLASS="Title2">Postal Code</SPAN>&nbsp;&nbsp;&nbsp;
	<B><FONT COLOR="FF0000">[</FONT><a HREF="##" onclick="javaScript: return search_popup('/search_screens/zipCode_Search.cfm?FormName=#formName#&FieldName=zipCodes');">search postal code</a><FONT COLOR="FF0000">]</FONT></B>

	<cfif Get_ZipCodes.RecordCount GT 0>
		<CFSET pageLength = 8>
		<CFSET SourceQuery = Get_ZipCodes>
		<CFSET showDelete  = true>
		<CFSET inputName = "zipCodes">
		<CFSET skeyword = "zip code">
		<CFINCLUDE template="displayZipCodeList.cfm">
	<cfelse>
		<TABLE width="90%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
			<TR ID="HEADER" BGCOLOR="FFCE84">
				<TD STYLE="font-size:11px;">
					<b>Postal Codes</b>
				</TD>
			</TR>
			<tr>
				<td>NONE SELECTED</td>
			</tr>
		</table>
	</cfif>


	<cfif FORM.marketID_List AND FORM.zipCodes NEQ "">
		<BR>
		<CENTER><B><FONT COLOR="FF0000">[</FONT><a HREF="javaScript: void(0);" onclick="javaScript: return confirmAssign(document.all.zipCodes, '#GetMarkets.Market_Name#');">assign</a><FONT COLOR="FF0000">]</FONT></B></CENTER>
	</cfif>

</cfif>
</form>
</CFOUTPUT>