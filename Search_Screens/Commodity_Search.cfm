
<CFSET thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#">
<CFIF isdefined("URL.FormName")>
	<CFPARAM NAME="URL.ReturnFieldName"				Default="Commodities_Symbol_ID">
	<CFPARAM NAME="URL.AllowImportAll"				Default="0">
	<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
		<!-------------- basic info ----------->
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FieldName#</CFOUTPUT>">		
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="ReturnFieldName" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.ReturnFieldName#</CFOUTPUT>">
		<INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.AllowImportAll#</CFOUTPUT>">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="0">
	</FORM>
	<script>	
		var parentForm = window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>;
		if(parentForm)
		{
			this.document.all.FinalItemList.value = parentForm.<CFOUTPUT>#URL.FieldName#</CFOUTPUT>.value;
			if(parentForm.SelectSingleSearchResultOnly)
			{
				this.document.all.SelectSingleSearchResultOnly.value = parentForm.SelectSingleSearchResultOnly.value;
			}
			document.all.MyForm.submit()
		}
		else
		{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br>
</SPAN>
<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>


<CFSET PAGE_TITLE="Select Commodity">
<CFSET GROUP="Search Screens">
<CFSET Singular_Desc = "commodity">
<CFSET Plural_Desc = "commodities">

<!------ Basic Form Variables ---------------->
<CFPARAM NAME="FORM.SelectedITEMS" 					DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" 		DEFAULT="0">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">
<CFPARAM NAME="FORM.AllowImportAll"					Default="0">
<CFPARAM NAME="FORM.ReturnFieldName"				Default="Commodities_Symbol_ID">

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFSET Records_Per_Page = 14>
<cf_Number_of_Rows maxrows="#Records_Per_Page#">

<!--------- build the final selected list ------------>	
<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
		<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<!------- search is complete, submit form ----->
<CFIF FORM.finishedselectingitems EQ 1>
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.<CFOUTPUT>#Form.FieldName#</CFOUTPUT>.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit();
		window.close()
	</script>
	<CFABORT>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

<CFSET Input_Select_Width = 200>
<SCRIPT LANGUAGE="JavaScript">
	function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
	{
		var formObj;
		formObj = document.all.MyForm;
		formObj.sort_by.value = thisSortItem;
		formObj.sort_order.value = thisSortOrder;
		formObj.submit();
		return false;
	}	 
</SCRIPT>
<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
<!---------- read me first link, uncomment when ready ------------------>
<!------
<BR><B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Help">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
----->
	
<!---------- search form ---------->
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	<CFOUTPUT>
    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#Singular_Desc# search</LEGEND>
	</CFOUTPUT>
	<!-------- Lookup queries ------->
	
	<!-------- Commodity_Exchange_Type ------------->
	<CFQUERY NAME="Get_Exchange_Type" DATASOURCE="#application.datasource#">
		SELECT	Commodity_Exchange_Type_ID, Commodity_Exchange_Type_Description
		FROM	Commodity_Exchange_Type
		ORDER BY Commodity_Exchange_Type_ID
	</CFQUERY>
	
	<!-------- Commodity_Exchange_Detail ------------->
	<CFQUERY NAME="Get_Exchange_Detail" DATASOURCE="#application.datasource#">
		SELECT	Exchange_Detail_Abrev, Exchange_Detail_Name, Commodity_Exchange_Type_ID
		FROM	Commodities_Exchange_Detail
		ORDER BY Commodity_Exchange_Type_ID, Exchange_Detail_Name
	</CFQUERY>
	
	<!-------- Commodities_Symbol ------------->
	<CFQUERY NAME="Get_Commodities_Symbol" DATASOURCE="#application.datasource#">
		SELECT	Symbol, Symbol_Description, Commodity_Exchange_Type_ID
		FROM	Commodities_Symbol CS
		INNER JOIN	Commodities_Exchange_Detail ON 
					Commodities_Exchange_Detail.Exchange_Detail_ID = CS.Exchange_Detail_ID
		WHERE CS.Deleted = 0
		ORDER BY Commodity_Exchange_Type_ID, CS.Exchange_Detail_Abrev, CS.Symbol_Description
	</CFQUERY>
	
	<!------- Give Defaults ---------->
	<CFPARAM NAME="FORM.Exchange_Family" 	DEFAULT="">
	<CFPARAM NAME="FORM.Exchange" 	DEFAULT="">
	<CFPARAM NAME="FORM.Commodity" 	DEFAULT="">
	<CFPARAM NAME="FORM.Description" 	DEFAULT="">
	<CFPARAM NAME="FORM.sort_by" 	DEFAULT="Commodity">
	<CFPARAM NAME="FORM.sort_Order" 	DEFAULT="ASC">
	
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" BGCOLOR="WhiteSmoke">
		<TR>
			<TD>
			<span ID="searchItemLabel"><B>Exchange Family</B></span><BR>
			<SELECT NAME="Exchange_Family" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px">
				<OPTION VALUE="">**ALL** Exchange Families</OPTION>
				<CFOUTPUT QUERY="Get_Exchange_Type">
				<OPTION VALUE="#Commodity_Exchange_Type_ID#"#IIF(trim(FORM.Exchange_Family) EQ Commodity_Exchange_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Commodity_Exchange_Type_Description)#</OPTION>
				</CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Exchange</B></span><BR>
			<SELECT NAME="Exchange" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px">
				<OPTION VALUE="">**ALL** Exchanges</OPTION>
				<CFOUTPUT QUERY="Get_Exchange_Detail">
				<OPTION VALUE="#Trim(Exchange_Detail_Abrev)#"#IIF(FORM.Exchange EQ trim(Exchange_Detail_Abrev), DE(" SELECTED"), DE(""))#>#trim(Exchange_Detail_Name)#</OPTION>
				</CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Description</B></span><BR>
			<CFOUTPUT>
			<INPUT TYPE="Text" NAME="Description" VALUE="#FORM.Description#" STYLE="WIDTH:<CFOUTPUT>#Evaluate(Input_Select_Width * 6 / 4)#</CFOUTPUT>px"> 
			</CFOUTPUT>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2">
			<span ID="searchItemLabel"><B>Commodity</B></span><BR>
			<SELECT NAME="Commodity" STYLE="WIDTH:<CFOUTPUT>#Evaluate(Input_Select_Width * 2)#</CFOUTPUT>px">
				<OPTION VALUE="">**ALL** Commodities</OPTION>
				<CFOUTPUT QUERY="Get_Commodities_Symbol">
				<OPTION VALUE="#Trim(Symbol)#"#IIF(FORM.Commodity EQ trim(Symbol), DE(" SELECTED"), DE(""))#>#trim(Symbol_Description)#</OPTION>
				</CFOUTPUT>
			</SELECT>
			</TD>
			<TD VALIGN="bottom" ALIGN="right">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="javascript:resetform();">reset</a><FONT COLOR="FF0000">]</FONT></B>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.MyForm.startrow.value=1;document.MyForm.frompage.value=1;document.MyForm.submit();"><CFOUTPUT>search #Plural_Desc#</CFOUTPUT></a><FONT COLOR="#FF0000">]</FONT></B>
			</TD>
		</TR>
	</TABLE>
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	<INPUT TYPE="Hidden" NAME="sort_by" VALUE="#FORM.Sort_By#">
	<INPUT TYPE="Hidden" NAME="sort_order" VALUE="#FORM.Sort_Order#">
	</CFOUTPUT>
</FIELDSET>
<!---------- search form ---------->

	
<CFIF isdefined("FORM.DOSEARCH")>


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<CFSET sql_Sort_By="CS.Symbol">

<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Exchange">
		<CFSET sql_Sort_By="CED.Exchange_Detail_Name, CS.Symbol">
	</CFCASE>
	<CFCASE value="Exchange_Family">
		<CFSET sql_Sort_By="CET.Commodity_Exchange_Type_Description, CED.Exchange_Detail_Name, CS.Symbol">
	</CFCASE>	
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>
<CFSET sql_Sort_By="#sql_Sort_By# #sql_Sort_By_Order#">


<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	SELECT	CS.Commodities_Symbol_ID, 
			RTRIM(LTRIM(CS.Symbol)) AS Symbol, 
			CS.Symbol_Description,
			CED.Exchange_Detail_Name + ' ' +  CED.Exchange_Detail_Abrev AS Exchange_Detail_Name, 
			CET.Commodity_Exchange_Type_Description
	FROM	Commodities_Symbol CS
	INNER JOIN	Commodities_Exchange_Detail CED ON
		CED.Exchange_Detail_ID = CS.Exchange_Detail_ID
		<CFIF FORM.Exchange NEQ "">
		AND CED.Exchange_Detail_Abrev = '#FORM.Exchange#'
		</CFIF>
	INNER JOIN Commodity_Exchange_Type CET ON
		CET.Commodity_Exchange_Type_ID = CED.Commodity_Exchange_Type_ID
		<CFIF FORM.Exchange_Family NEQ "">
		AND CET.Commodity_Exchange_Type_ID = #FORM.Exchange_Family#
		</CFIF>
	WHERE
			CS.Deleted = 0 AND 
			EXISTS (select Commodities_Symbol_Id from Commodities C where C.Commodities_Symbol_Id = CS.Commodities_Symbol_ID)
			<CFIF FORM.Commodity NEQ "">
			AND CS.Symbol = '#FORM.Commodity#'
			</CFIF>
			<CFIF FORM.Description NEQ "">
			AND
			(
				CS.Symbol_Description LIKE '%#FORM.Description#%'
				OR
				CED.Exchange_Detail_Name LIKE '%#FORM.Description#%'
				OR
				CET.Commodity_Exchange_Type_Description LIKE '%#FORM.Description#%'
			)
			</CFIF>
	ORDER BY #sql_Sort_By#
</CFQUERY>
	
	<SCRIPT>
		function CA() 
		{
			if(<CFIF Records_Per_Page GTE 100>confirm("Your browser may seem to lock up if there are too many programs in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) 
			{
				for (var i=0;i<MyForm.elements.length;i++)
				{
					var e = MyForm.elements[i];
					if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) 
					{
						e.checked = MyForm.allbox.checked;
					}
				}
			}
			else 
			{
				document.all.allbox.checked = false;
			}
		}
	</SCRIPT>	
	
	<!------ Display Result -------->
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
		<CFOUTPUT>
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> #TheQuery.recordcount# <CFIF TheQuery.recordcount EQ 1>#Singular_Desc#<CFELSE>#Plural_Desc#</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		</CFOUTPUT>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="685" CLASS="Maintable">
				<!----- Display header ----->
				<TR ID="header" BGCOLOR="#ffce84">
				<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
					<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Programs"></TD>
				<CFELSE>
					<TD>&nbsp;</TD>
				</CFIF>
				<CFSET HeaderNameList="Commodity,Exchange,Exchange Family">
				<CFOUTPUT>
				<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
					<CFSET sortImage="">				
					<CFIF this_Header EQ Form.SORT_BY>
						<CFIF FORM.SORT_ORDER EQ "DESC">
							<CFSET New_Sort_Order="ASC">
							<CFSET sortImage="up_1.gif">
						<CFELSE>
							<CFSET New_Sort_Order="DESC">
							<CFSET sortImage="down_1.gif">
						</CFIF>
					<CFELSE>
						<CFSET New_Sort_Order="ASC">
					</CFIF>
						<TD ID="header" align="left" nowrap><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
				</CFLOOP>
				</CFOUTPUT>
				</TR>
			<CFIF StartRow GT TheQuery.RecordCount>
				<CFSET startrow = 1>
				<CFSET frompage = 1>
				<cf_Number_of_Rows maxrows="#Records_Per_Page#">
			</CFIF>
			<!----- Display records ---->
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<CFSET Return_Field_Value = trim(Evaluate("TheQuery.#FORM.ReturnFieldName#"))>
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center">
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#Return_Field_Value#" <CFIF listfind(FORM.FinalItemList, Return_Field_Value) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, Return_Field_Value, ",")></CFIF>>
						<CFELSE>
							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#Return_Field_Value#" <CFIF listfind(FORM.FinalItemList, Return_Field_Value) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, Return_Field_Value, ",")></CFIF>>
						</CFIF>
					</TD>
					<TD NOWRAP WIDTH="50%">#TheQuery.Symbol_Description#&nbsp;</TD>
					<TD TITLE="#TheQuery.Exchange_Detail_Name#" WIDTH="25%">
					<CFSET Display_Title=Left(TheQuery.Exchange_Detail_Name,55)>
					<CFIF len(trim(TheQuery.Exchange_Detail_Name)) GT 55>
						#Display_Title#...
					<CFELSEIF len(trim(TheQuery.Exchange_Detail_Name)) EQ 0>
						&nbsp;
					<CFELSEIF len(trim(TheQuery.Exchange_Detail_Name)) LTE 55>
						#Display_Title#	
					</CFIF>						
					</TD>
					<TD NOWRAP WIDTH="25%">#TheQuery.Commodity_Exchange_Type_Description#</TD>
 				</TR>
			</CFOUTPUT>
			</TABLE>

			<!----- page numbers ------>
			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
		</CFIF>
	</FIELDSET>	
</CFIF>

<CFPARAM name="TheQuery.Recordcount" default="0">
<SCRIPT>
	function resetform() 
	{
		var This_Form = document.MyForm;
		This_Form.Exchange_Family.selectedIndex = 0;
		This_Form.Exchange.selectedIndex = 0;
		This_Form.Commodity.selectedIndex = 0;
		This_Form.Description.value = "";
	}
</SCRIPT>
<!---------- Form variables to be passed ---------->
<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="FieldName" 				VALUE="#FORM.FieldName#">	
	<INPUT TYPE="hidden" NAME="ParentFormname" 			VALUE="#FORM.ParentFormname#">	
	<INPUT TYPE="hidden" NAME="FinalItemList" 			VALUE="#Form.FinalItemList#">
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 	VALUE="#Form.AlreadySelectedItems#">
	<INPUT TYPE="hidden" NAME="finishedselectingitems" 	VALUE="0">
	<INPUT TYPE="hidden" NAME="LoadSavedOperators" 		VALUE="0">
	<INPUT TYPE="Hidden" NAME="startrow" 				VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" 				VALUE="#frompage#">
	<INPUT TYPE="HIDDEN" NAME="AllowImportAll" 			VALUE="#FORM.AllowImportAll#">
	<INPUT TYPE="HIDDEN" NAME="ReturnFieldName" 		VALUE="#FORM.ReturnFieldName#">
	<INPUT TYPE="HIDDEN" NAME="SelectSingleSearchResultOnly" 		VALUE="#FORM.SelectSingleSearchResultOnly#">	
</CFOUTPUT>
</FORM>
<!----- Bottom links ----->
<CFIF TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"><CFOUTPUT>import selected <CFIF FORM.SelectSingleSearchResultOnly EQ 1>#Singular_Desc#<CFELSE>#Plural_Desc#</CFIF></CFOUTPUT></a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"><CFOUTPUT> import all returned #Plural_Desc# </CFOUTPUT></a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"><CFOUTPUT> remove all selected #Plural_Desc# </CFOUTPUT></a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<BR>	
	</DIV>
	</CFIF>
</CFIF> 


<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount)
		{
			var recordcount = <CFOUTPUT>#TheQuery.RecordCount#</CFOUTPUT>;
			if(parseInt(recordcount) == 1)
			{
				pString = "Product";
			}			
			else 
			{
				pString = "Products";
			}
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?"))
			{
				document.all.allbox.checked = true;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0)
				{
					<CFIF LCase(FORM.ReturnFieldName) EQ LCase("Commodities_Symbol_ID")>
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.Commodities_Symbol_ID)#</CFOUTPUT>";
					<CFELSE>
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.Symbol)#</CFOUTPUT>";
					</CFIF>
				}
				else
				{
					<CFIF LCase(FORM.ReturnFieldName) EQ LCase("Commodities_Symbol_ID")>
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.Commodities_Symbol_ID)#</CFOUTPUT>";
					<CFELSE>
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.Symbol)#</CFOUTPUT>";
					</CFIF>
					
				}	
				document.MyForm.submit();
			}
		}
		
		function removeAllProducts()
		{			
			if(confirm("By pressing OK all selected records will be unselected"))
			{
				document.all.allbox.checked = false;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 0;
				document.MyForm.FinalItemList.value 	= "";
				document.MyForm.AlreadySelectedItems.value 	= "";
			}
		}	
		
		function finishedSearching() 
		{
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}	
	</cfif>
</SCRIPT>

