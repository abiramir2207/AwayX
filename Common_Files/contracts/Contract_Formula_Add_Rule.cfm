<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="">

<CFIF FORM.Rule_ID NEQ "">
	<CFQUERY NAME="Get_Formula_ID" DATASOURCE="#application.datasource#">
		SELECT	Formula_Pricing_Rule.Formula_Pricing_Rule_ID
		FROM	Program_Formula_Pricing_Rule_Mapped
				LEFT JOIN Formula_Pricing_Rule
				ON
				Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
				AND
				Formula_Pricing_Rule.Active_Code = 1
				AND
				Formula_Pricing_Rule.Deleted = 0
		WHERE
				Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = '#FORM.Rule_ID#'
				AND
				Program_Formula_Pricing_Rule_Mapped.Deleted = 0				
	</CFQUERY>
	<CFPARAM NAME="FORM.New_Formula_Pricing_Rule_ID" 	DEFAULT="#Get_Formula_ID.Formula_Pricing_Rule_ID#">
</CFIF>

<CFPARAM NAME="FORM.New_Formula_Pricing_Rule_ID" 	DEFAULT="">

<CFPARAM NAME="FORM.CID" 	DEFAULT="">
<CFPARAM NAME="URL.CID" 	DEFAULT="#FORM.CID#">
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET PAGE_TITLE="Add Formula pricing Rule">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
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
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 60px; top: 10px;"></cfif>


<cfinclude template="minimal_contract_info.cfm">


<CFPARAM NAME="FORM.Rule_Name" 	DEFAULT="">
<CFPARAM NAME="FORM.No_of_Comms" 	DEFAULT="">
<CFPARAM NAME="FORM.Operator_No_of_Comms" 	DEFAULT="">
<CFPARAM NAME="FORM.Exchange_Type" 	DEFAULT="">
<CFPARAM NAME="FORM.Exchange" 	DEFAULT="">
<CFPARAM NAME="FORM.Commodity" 	DEFAULT="">

<cfparam name="FORM.startrow"  default="1">
<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
<cfparam name="FORM.pageLength"  default=8>
<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">
 
<SCRIPT LANGUAGE="JavaScript">
	function searchRule()
	{
		event.returnValue = false;
		document.SearchForm.submit();
		return false;
	}
	
	function addRule()
	{
		event.returnValue = false;
		var saveForm = document.SearchForm;
		if(saveForm.New_Formula_Pricing_Rule_ID.value.length > 0)
		{	
			<CFIF FORM.Rule_ID EQ "">
			saveForm.action = "Contract_Formula_Add_Products.cfm";
			<CFELSE>
			saveForm.action = "Contract_Formula_Add_Rule_Action.cfm";
			</CFIF>
			saveForm.submit();
		}
		else
		{
			alert("You have to select a rule");
		}
		return false;
	}
	
	function enableDisableComms(thisObj)
	{
		var oInp =document.all.No_of_Comms;
		if(thisObj.value == "")
		{
			oInp.disabled = true;
			oInp.style.backgroundColor='cccccc';
			oInp.value = "";
		}
		else
		{
			oInp.disabled = false;
			oInp.style.backgroundColor='ffffff';
		}
	}
	
	function setExchange_Symbol(exVal,sVal)
	{
		<CFIF FORM.Exchange_Type NEQ "">
			var Exchange_Type = "<CFOUTPUT>#FORM.Exchange_Type#</CFOUTPUT>";
			var oExchange_Type = document.all.Exchange_Type;
			setSelectDefault(oExchange_Type, Exchange_Type);
			eval("SearchForm_Exchange_Type_Populate_Select_Box(1);");
		</CFIF>
		<CFIF FORM.Exchange NEQ "">
			var Exchange = "<CFOUTPUT>#FORM.Exchange#</CFOUTPUT>";
			var oExchange = document.all.Exchange;
			setSelectDefault(oExchange, Exchange);
			eval("SearchForm_Exchange_Type_Populate_Select_Box(2);");
		</CFIF>
		<CFIF FORM.Commodity NEQ "">
			var Commodity = "<CFOUTPUT>#FORM.Commodity#</CFOUTPUT>";
			var oCommodity = document.all.Commodity;
			setSelectDefault(oCommodity, Commodity);
		</CFIF>
		
		/*
		var oExchange = document.all.Exchange;
		var oSymbol = document.all.Symbol;
		setSelectDefault(oExchange, exVal);
		SearchFormExchangeChangeMenu();
		if(sVal.length > 0)
		{
			setSelectDefault(oSymbol, sVal);
		}
		*/
	}
	
	function setSelectDefault(oSelect, sVal)
	{
		var i;
		for(i=0;i<oSelect.options.length;i++)
		{
			if(oSelect.options[i].value == sVal)
			{
				oSelect.selectedIndex = i;
				break;
			}
		}
	}
	
	function resetForm()
	{
		event.returnValue = false;
		var saveForm = document.SearchForm;
		saveForm.reset();
		saveForm.Rule_Name.value = "";
		saveForm.Operator_No_of_Comms.selectedIndex = 0;
		enableDisableComms(saveForm.Operator_No_of_Comms);
		return false;
	}
	
</SCRIPT>

<!------<CFQUERY NAME="get_data" datasource="#application.datasource#">
	Select		Commodities_Symbol.*,
				Commodities_Exchange_Detail.*
				
	From		Commodities_Symbol,
				Commodities_Exchange_Detail
				
	Where		Commodities_Symbol.Exchange_Detail_Abrev	=	Commodities_Exchange_Detail.Exchange_Detail_Abrev
	
	Order by	Commodities_Symbol.Exchange_Detail_Abrev, Commodities_Symbol.Symbol
</CFQUERY>----->

<CFQUERY NAME="get_data" datasource="#application.datasource#">
	Select		Commodity_Exchange_Type.Commodity_Exchange_Type_Description, Commodity_Exchange_Type.Commodity_Exchange_Type_ID,
				Commodities_Exchange_Detail.*,
				Commodities_Symbol.*
				
	From		
				Commodity_Exchange_Type
				INNER JOIN Commodities_Exchange_Detail
				ON
				Commodity_Exchange_Type.Commodity_Exchange_Type_ID = Commodities_Exchange_Detail.Commodity_Exchange_Type_ID
				INNER JOIN Commodities_Symbol
				ON
				Commodities_Symbol.Exchange_Detail_Abrev = Commodities_Exchange_Detail.Exchange_Detail_Abrev
	Order by	Commodity_Exchange_Type.Commodity_Exchange_Type_Description, Commodities_Symbol.Exchange_Detail_Abrev, Commodities_Symbol.Symbol
</CFQUERY>

<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js">
</SCRIPT>
<FORM ACTION="Contract_Formula_Add_Rule.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" STYLE="DISPLAY:INLINE">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" VALUE="#FORM.startrow#" NAME="startrow">
	<INPUT TYPE="Hidden" VALUE="#FORM.frompage#" NAME="frompage">
	</CFOUTPUT>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Formula Pricing Rule Search</LEGEND>
	<CFOUTPUT>
	<TABLE WIDTH="750" CELLPADDING="2" CELLSPACING="0" BORDER="0">
		<TR VALIGN="top">			
			<TD COLSPAN="3" ROWSPAN="2">
			<!------<CF_TwoSelectsRelated
				QUERY="get_data"
				NAME1="Exchange"
				NAME2="Symbol"
				ForceWidth1="200"
				ForceWidth2="200"
				DISPLAY1="Exchange_Detail_Name"
				DISPLAY2="Symbol_Description"
				VALUE1="Exchange_Detail_ID"
				VALUE2="Symbol"
				SIZE1="1"
				SIZE2="1"
				HTMLBETWEEN=""
				AUTOSELECTFIRST="Yes"
				EmptyText1="-----Any Exchange------"
				EmptyText2="-----Any Commodity------"
				FORMNAME="SearchForm">----->
			<CFPARAM NAME="ThreeSelectsRelated_DataSource" 	DEFAULT="">
		<CF_ThreeSelectsRelated
			QUERY="get_data"
			NAME1="Exchange_Type"
			NAME2="Exchange"
			NAME3="Commodity"
			ForceWidth1="200"
			ForceWidth2="200"
			ForceWidth3="400"
			DISPLAY1="Commodity_Exchange_Type_Description"
			DISPLAY2="Exchange_Detail_Name"
			DISPLAY3="Symbol_Description"
			VALUE1="Commodity_Exchange_Type_ID"
			VALUE2="Exchange_Detail_ID"
			VALUE3="Symbol"
			TITLE1="Exchange Family"
			TITLE2="Exchange"
			TITLE3="Commodity"
			SIZE1="1"
			SIZE2="1"
			SIZE3="1"
			HTMLBETWEEN1=""
			HTMLBETWEEN2=""
			AUTOSELECTFIRST="Yes"
			EmptyText1="-----Any Exchange Type------"
			EmptyText2="-----Any Exchange------"
			EmptyText3="-----Any Commodity------"
			FORMNAME="SearchForm"
			DataSource_ReturnVariableName="ThreeSelectsRelated_DataSource"
			DataSource="#ThreeSelectsRelated_DataSource#">
			</TD>
			<TD>
			<B>Rule Name</B>
			<BR>
			<INPUT TYPE="TEXT" NAME="Rule_Name" VALUE="#FORM.Rule_Name#">
			</TD>
			<TD NOWRAP>
			<B>## of Commodites</B>
			<BR>
			<CFSET Comparison_Operator_List_Display = " ,Equal To,Greater Than,Less Than">
			<CFSET Comparison_Operator_List_Value = " ,=,>,<">
			<SELECT NAME="Operator_No_of_Comms" onChange="javaScript: enableDisableComms(this);">
			<CFSET Counter = 1>
			<CFLOOP LIST="#Comparison_Operator_List_Value#" INDEX="ThisOperator">
			<CFSET opDisplay = ListGetAt(Comparison_Operator_List_Display, Counter, ",")>
			<OPTION VALUE="#Trim(ThisOperator)#"<CFIF FORM.Operator_No_of_Comms EQ Trim(ThisOperator)> SELECTED</CFIF>>#opDisplay#</OPTION>
			<CFSET Counter = Counter + 1>
			</CFLOOP>
			</SELECT>
			<INPUT<CFIF FORM.Operator_No_of_Comms EQ ""> DISABLED STYLE="background-color:##cccccc;"</CFIF> SIZE="3" TYPE="TEXT" NAME="No_of_Comms" VALUE="#FORM.No_of_Comms#" onKeyUp="clenseText(this, '0123456789');">
			</TD>
		</TR>
		<TR>
			<TD VALIGN="bottom">
				<B><FONT COLOR="FF0000">[</FONT><a HREF="" onclick="javaSCript: return resetForm();">reset</a><FONT COLOR="FF0000">]</FONT></B>
				&nbsp;&nbsp;
				<B><FONT COLOR="FF0000">[</FONT><a HREF="" onclick="javaSCript: return searchRule();">search pricing rule</a><FONT COLOR="FF0000">]</FONT></B>
			</TD>			
		</TR>
	</TABLE>
	</CFOUTPUT>
	</FIELDSET>
	
	<CFOUTPUT>
	<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="">	
	<INPUT TYPE="hidden" NAME="CID" ID="CID" VALUE="#URL.CID#">
	<INPUT TYPE="hidden" NAME="Rule_ID" ID="Rule_ID" VALUE="#FORM.Rule_ID#">
	</CFOUTPUT>


<CFQUERY NAME="Search_Pricing_Rule" DATASOURCE="#application.datasource#">
	SELECT	*, Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID
	FROM	Formula_Pricing_Rule
			LEFT JOIN Program_Formula_Pricing_Rule_Mapped
			ON
			Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = Formula_Pricing_Rule.Formula_Pricing_Rule_ID
			AND
			Program_Formula_Pricing_Rule_Mapped.Deleted = 0
			AND
			Program_Formula_Pricing_Rule_Mapped.Program_ID = #FORM.Contract_Main_ID#
			<CFIF FORM.Rule_ID NEQ "">
			AND
			Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID <> '#FORM.Rule_ID#'
			</CFIF>
	WHERE
			Formula_Pricing_Rule.Deleted = 0
			AND			
			Formula_Pricing_Rule.Active_Code = 1
			<CFIF FORM.Rule_Name NEQ "">
			AND
			Formula_Pricing_Rule.RULE_NAME LIKE '%#FORM.Rule_Name#%'
			</CFIF>
			<CFIF FORM.No_of_Comms NEQ "">
			<CFIF IsNumeric(FORM.No_of_Comms)>
			<CFSWITCH EXPRESSION="#FORM.Operator_No_of_Comms#">
				<CFCASE DELIMITERS="," VALUE="=,>,<">
					AND
					Formula_Pricing_Rule.NUMBER_OF_COMMS #FORM.Operator_No_of_Comms# #FORM.No_of_Comms#
				</CFCASE>
			</CFSWITCH>
			</CFIF>
			</CFIF>
			<CFIF FORM.Exchange NEQ "" OR FORM.Commodity NEQ "" OR FORM.Exchange_Type NEQ "">
			AND EXISTS
			(
				SELECT	*
				FROM	Program_Formula_Pricing_Rule_Comm_Data
						<CFIF FORM.Exchange_Type NEQ "">
						INNER JOIN Commodities_Symbol
						ON
						Commodities_Symbol.Symbol = Program_Formula_Pricing_Rule_Comm_Data.Symbol
						INNER JOIN Commodities_Exchange_Detail
						ON
						Commodities_Symbol.Exchange_Detail_Abrev = Commodities_Exchange_Detail.Exchange_Detail_Abrev
						AND
						Commodities_Exchange_Detail.Commodity_Exchange_Type_ID = #FORM.Exchange_Type#
						</CFIF>
				WHERE
						Program_Formula_Pricing_Rule_ID = Formula_Pricing_Rule.Formula_Pricing_Rule_ID
						AND
						Program_Formula_Pricing_Rule_Comm_Data.Deleted = 0
						<CFIF FORM.Exchange NEQ "">
						AND
						Program_Formula_Pricing_Rule_Comm_Data.Exchange = '#FORM.Exchange#'
						</CFIF>
						<CFIF FORM.Commodity NEQ "">
						AND
						Program_Formula_Pricing_Rule_Comm_Data.Symbol = '#FORM.Commodity#'
						</CFIF>
			)
			</CFIF>
	ORDER BY	Formula_Pricing_Rule.RULE_NAME
</CFQUERY>
<BR>
<B><FONT COLOR="FF0000">[</FONT><a HREF="" onclick="javaScript: return addRule();">
<CFIF FORM.Rule_ID EQ "">add<CFELSE>edit</CFIF>
 rule
</a><FONT COLOR="FF0000">]</FONT></B>
<BR>
<!------<FORM ACTION="Contract_Formula_Add_Rule_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">----->
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<CFOUTPUT><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF Search_Pricing_Rule.RecordCount GT 1>are<CFELSE>is</CFIF> #Search_Pricing_Rule.RecordCount# result<CFIF Search_Pricing_Rule.RecordCount GT 1>s</CFIF> that match the above criteria</LEGEND></CFOUTPUT>
	<TABLE CLASS="MainTable" CELLPADDING="1" CELLSPACING="0" WIDTH="750">
		<TR ID="HEADER" BGCOLOR="#FFCE84">
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD><B>Rule Name</B></TD>
			<TD><B># Commodites</B></TD>
			<TD>&nbsp;</TD>
		</TR>
		<CFOUTPUT QUERY="Search_Pricing_Rule" startrow="#StartRow#" maxrows="#MaxRows#">
			<CFSET Disable_This = false>
			<CFIF Program_Formula_Pricing_Rule_Mapped_ID NEQ "">
				<CFSET Disable_This = true>
			</CFIF>
			<CFIF NOT Disable_This>
				<TR<CFIF CurrentRow Mod 2> BGCOLOR="CCFFCC"</CFIF>>
				<TD>&nbsp;</TD>
				<TD><INPUT TYPE="RADIO" NAME="Ch_Rule_ID" VALUE="#Formula_Pricing_Rule_ID#" ONCLICK="javaScript: this.form.New_Formula_Pricing_Rule_ID.value = this.value;"<CFIF FORM.New_Formula_Pricing_Rule_ID EQ Formula_Pricing_Rule_ID> CHECKED</CFIF>></TD>
			<CFELSE>
				<TR BGCOLOR="silver">
				<TD>&nbsp;</TD>
				<TD><INPUT TYPE="RADIO" DISABLED></TD>
			</CFIF>
				<TD WIDTH="80%" ALIGN="left" STYLE="cursor:pointer;" onClick="NewWindow('/Settings/Formula_Pricing/Formula_Display.cfm?Formula_ID=#Formula_Pricing_Rule_ID#','name','500','400','Yes', 'No');return false;">#RULE_NAME#</TD>
				<TD ALIGN="left">#NUMBER_OF_COMMS#</TD>				
				<TD WIDTH="">&nbsp;</TD>
			</TR>
			
		</CFOUTPUT>
	</TABLE>
</FIELDSET>	
	<INPUT TYPE="Hidden" NAME="New_Formula_Pricing_Rule_ID" VALUE="<CFOUTPUT>#FORM.New_Formula_Pricing_Rule_ID#</CFOUTPUT>">
<!------</FORM>----->
</FORM>

<HR COLOR="Orange">
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="SearchForm"
    query="Search_Pricing_Rule"
    maxpages="40"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>

<cfif application.programlayout EQ 1></div></cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>
<SCRIPT LANGUAGE="JavaScript">
	setExchange_Symbol('<CFOUTPUT>#FORM.Exchange#</CFOUTPUT>','<CFOUTPUT>#FORM.Commodity#</CFOUTPUT>');
	findselectboxes();
</SCRIPT>
</BODY>
</HTML>
