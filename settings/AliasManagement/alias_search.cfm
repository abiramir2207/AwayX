

<!--- Give parameters to values used on this page --->
<CFPARAM NAME="Alias" 				DEFAULT="">
<CFPARAM NAME="Name" 				DEFAULT="">
<CFPARAM NAME="Number" 				DEFAULT="">
<CFPARAM NAME="Created_By" 			DEFAULT="">
<CFPARAM NAME="Alias_Type" 			DEFAULT="0">
<CFPARAM NAME="FORM.DOSEARCH" 		DEFAULT="0">
<CFPARAM NAME="Alias_ID"			DEFAULT="">
<CFPARAM NAME="startrow" 			DEFAULT="1">
<CFPARAM NAME="frompage" 			DEFAULT="1">
<cf_Number_of_Rows maxrows		=	50>

<CFSET PAGE_TITLE="Search for an Alias">

<!---Initialize components used --->
<cfset aliasManager = CreateObject("component", "components.settings.AliasManagement.Alias").init() />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=20>


	<SCRIPT>
		function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{
			isSearching = 1;
			var formObj;
			formObj = document.all.MyForm;
			formObj.sort_by.value = thisSortItem;
			formObj.sort_Order.value = thisSortOrder;
			if(formObj.frompage.value.length == 0)	formObj.frompage.value = 1;
			if(formObj.startrow.value.length == 0)	formObj.startrow.value = 1;
			formObj.submit();
			return false;
		}
	</SCRIPT>

<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}
</style>



<!---End queries limiting distributor list by permission--->
<SCRIPT language="JavaScript">
	function reset_Form_Fields()
	{
		resetSelect("Created_By");
		resetSelect("Alias_Type");

		document.all.Name.value = "";
		document.all.Number.value = "";
		document.all.Alias.value = "";

	}

	function resetSelect(selName)
	{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			sObj.fireEvent('onchange');
		}
	}
</SCRIPT>


	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width: 700;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">alias search</LEGEND>

			<TABLE border="0" width="675" align="left">
				<cfoutput><TR>

					<TD ><!--- Alias --->
						<span ID="searchItemLabel">Alias</span><BR>

						<input type="text" size="35" maxlength="50" name="Alias" value="#Alias#">
					</TD>

					<TD ><!--- Name --->
						<span ID="searchItemLabel"> Name</span><BR>

						<input type="text" size="35" maxlength="50" name="Name" value="#Name#">
					</TD>

					<TD ><!--- Number --->
						<span ID="searchItemLabel">Number</span><BR>

						<input type="text" size="35" maxlength="50" name="Number" value="#Number#">
					</TD>
					</tr><tr>
					<TD ><!--- Created_By --->
						<span ID="searchItemLabel">Created By</span><BR>

						<cfquery name="GetAliasCreators" datasource="#application.datasource#">
						SELECT DISTINCT User_ID, Name_First, Name_Last, User_Code
						FROM _Users WHERE USER_ID IN (SELECT DISTINCT Created_By FROM Alias_Distributor WHERE Deleted = 0)
						OR USER_ID IN (SELECT DISTINCT Created_By FROM Alias_Product WHERE Deleted = 0)
						</cfquery>

						<select name="Created_By">
							<option value="">All creators</option>
							<cfparam name="form.created_by" default="">
							<cfloop query="GetAliasCreators">
								<option <cfif form.created_by eq GetAliasCreators.User_ID>selected</cfif> value="#User_ID#">#Name_First# #Name_Last# (#User_Code#)</option>
							</cfloop>

						</select>

					</TD>

					<td>
					#application.returned_customer_setting.distributor_label_singular# <input type="radio" name="Alias_Type" value="1" <cfif Alias_Type IS 0 OR Alias_Type IS 1> checked</cfif>>&nbsp; &nbsp;
					Product <input type="radio" name="Alias_Type" value="2" <cfif Alias_Type IS 2> checked</cfif>>
				</td>


				<input type="hidden" name="DoSearch" value="1">
					<td colspan="100%" align="center">
					<CF_smallLink
				title = "search for this alias"
				url = "##"
				parameters = "onClick=""javascript: submitDataForm('search');return false;"""
				>

				</td>

			</TR></cfoutput>

			</TABLE>

	</FIELDSET>


	<CFSET Open_Layer_Caption = "currently selected aliases">


	<cfif form.DoSearch IS 1>

	<cfset compAlias = CreateObject("component","components.settings.AliasManagement.Alias")>
	<cfset GetAlias = compAlias.searchAlias(form.Alias,form.Name,form.Number,form.Created_By,form.Alias_Type)>


	<cfif GetAlias.Recordcount IS 1>
		<cfset Aliasdesc = "alias">
	<cfelse>
		<cfset Aliasdesc = "aliases">
	</cfif>


			<CFIF GetAlias.recordcount EQ 0>
			<p></p>
				No aliases returned. Please search again.<p></p>

				To return more search results, include less information in your search. You should also check that you are searching in the correct alias type (product or <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>).


	<cfelse>

		<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width: 700; display:block;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#GetAlias.Recordcount# #Aliasdesc#</cfoutput> <CFIF GetAlias.recordcount EQ 1>matched<CFELSE>match</CFIF> your search critera</LEGEND>

		<CFIF GetAlias.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="left" WIDTH="675" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">

				<cfoutput>
				<CFSET HeaderNameList = "">

				<cfif form.Alias_Type EQ 1>
					<CFSET HeaderNameList = ListAppend(HeaderNameList, "#application.returned_customer_setting.distributor_label_singular# Name, Alias, Ship To, Shared Ship To, Created By, &nbsp; , &nbsp; ")>
				<cfelse>
					<CFSET HeaderNameList = ListAppend(HeaderNameList, "Product Name, Alias, Item ##, UPC, Created By, &nbsp; , &nbsp; ")>
				</cfif>

				<CFSET Counter = 1>
				<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">

					<TD ID="header" align="left" NOWRAP><b>#this_Header#</b></TD>
					<CFSET Counter = Counter + 1>
					</CFLOOP>
				</cfoutput>

				</TR>

			<CFOUTPUT QUERY="GetAlias" startrow="#StartRow#"  maxrows="#MaxRows#">
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD  NOWRAP>#Name#</TD>
					<TD >#Alias_String#</TD>
					<TD >#Number1#&nbsp;</TD>
					<TD  NOWRAP>#Number2#&nbsp;</TD>
					<td>#Name_First# #Name_Last# (#User_Code#<cfif len(trim(User_Code))EQ 0>Automatic</cfif>)</td>
				<cfif Alias_type IS 1>
					<td nowrap><A href="##" STYLE="COLOR:##0000FF; "onClick="editDistributorAlias('#Alias_ID#');">#application.util.string.actionLinkFormat('edit alias')#</A></td>
					<td nowrap><A href="##" STYLE="COLOR:##0000FF; "onClick="deleteDistributorAlias('#Alias_ID#');">#application.util.string.actionLinkFormat('delete alias')#</A></td>
				<cfelse>
					<td nowrap><A href="##" STYLE="COLOR:##0000FF; "onClick="editProductAlias('#Alias_ID#');">#application.util.string.actionLinkFormat('edit alias')#</A></td>
					<td nowrap><A href="##" STYLE="COLOR:##0000FF; "onClick="deleteProductAlias('#Alias_ID#');">#application.util.string.actionLinkFormat('delete alias')#</A></td>
				</cfif>
 				</TR>
			</CFOUTPUT>
			</TABLE>
			<p></p>
		</FIELDSET>
<CFIF GetAlias.recordcount GT 0>
<!--- <HR COLOR="Orange" SIZE="2" WIDTH="760px"> --->
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
&nbsp;&nbsp;&nbsp;<CF_Next_Previous_For_Forms
	formname="DataForm"
	query="GetAlias"
	maxpages="40"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
</DIV>
</cfif>

<!---This pagination should be here regardless of the number of records returned --->
	<script language="javascript">
		function showstartingWith(sValue)
		{
			document.DataForm.Name.value =sValue;
			submitDataForm('search');
		}
		</script>
		<TABLE CELLPADDING="2" CELLSPACING="1" width="675" BORDER="0" ALIGN="left"><TR>
		<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
					<TD>
						<B>
						<CFIF chr(LoopCount) EQ form.Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
					 <CFIF chr(LoopCount) EQ form.Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
					<TD>
						<B>
						<CFIF LoopCount EQ form.Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
						<CFIF LoopCount EQ form.Name>
							<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
					<TD>
						<B>
						<CFIF "" EQ form.Name>
						 <FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
					 <CFIF "" EQ form.Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
	</cfoutput>
	 </TR>
	</TABLE>
<INPUT TYPE="Hidden" NAME="startrow" VALUE="1">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="1">

		</CFIF>
		<!--- No records returned --->
</CFIF>

</CFIF>



