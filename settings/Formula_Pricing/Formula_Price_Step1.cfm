<CFPARAM NAME="URL.RID" 	DEFAULT="">

<CFIF URL.RID NEQ "">
	<CFSET FORMULA_PAGE_NAME="5">
<CFELSE>
	<CFSET FORMULA_PAGE_NAME="3">
</CFIF>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "formulaPricing"
							formula_page_name = #formula_page_name#
							selectedIndex = "#(formula_page_name - 1)#" >

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script>
	function submitForm(){
		if(trim(document.all.Rule_Name.value).length == 0)
		{
			alert("Please Name This Rule.");
		}
		else if(trim(document.all.Commodity_List.value).length == 0)
		{
			alert("You have to select atleast one commodity");
		}
		else
		{
			document.all.MyForm.action = "Formula_Price_Step2.cfm";
			document.all.MyForm.submit();
		}
	}
</script>


<CFIF URL.RID NEQ "">
	<cfset useLakebaseForSaved_Formula_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_rule")>
<cfif useLakebaseForSaved_Formula_Info>
	<cftry>
		<cfset Saved_Formula_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_pricing_rule", {
				"formula_pricing_rule_id" = "eq.#URL.RID#",
				"deleted" = "eq.0",
				"order" = "rule_name.asc",
				"select" = "rule_name,number_of_comms,show_details"
			}), "rule_name,number_of_comms,show_details"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSaved_Formula_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaved_Formula_Info>
<CFQUERY NAME="Saved_Formula_Info" DATASOURCE="#application.datasource#">
		SELECT	Rule_Name,Number_Of_Comms, Show_Details
		FROM	Formula_Pricing_Rule
		WHERE
				Formula_Pricing_Rule_ID = '#URL.RID#'
				AND
				Deleted = 0
		ORDER BY	RULE_NAME
	</CFQUERY>
</cfif>
	<CFQUERY NAME="Get_All_Commodities" DATASOURCE="#application.datasource#">
		SELECT 	LTRIM(RTRIM(Symbol)) AS Symbol
		FROM 	Program_Formula_Pricing_Rule_Comm_Data
		WHERE
				Program_Formula_Pricing_Rule_ID = '#URL.RID#'
				AND Deleted = 0
				AND Active = 1
		ORDER BY COMM_COUNT
	</CFQUERY>
<CFELSE>
	<CFSET Saved_Formula_Info = QueryNew("")>
	<CFQUERY NAME="Get_All_Commodities" DATASOURCE="#application.datasource#">
		SELECT Symbol
		FROM 	Program_Formula_Pricing_Rule_Comm_Data
		WHERE
				1 = 2
	</CFQUERY>
</CFIF>


<CFIF Saved_Formula_Info.recordCount GT 0>
	<CFPARAM NAME="FORM.Rule_Name" 	DEFAULT="#Saved_Formula_Info.Rule_Name#">
	<CFPARAM NAME="FORM.Number_Of_Comms" 	DEFAULT="#Saved_Formula_Info.Number_Of_Comms#">
	<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="#Saved_Formula_Info.Show_Details#">
<CFELSE>
	<CFSET FORM.RID = "">
</CFIF>

<CFSET Old_Commodity_List = ValueList(Get_All_Commodities.Symbol)>
<CFIF Get_All_Commodities.recordCount GT 0>
	<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="#ValueList(Get_All_Commodities.Symbol)#">
</CFIF>
<CFPARAM NAME="FORM.Rule_Name" 			DEFAULT="">
<CFPARAM NAME="FORM.Number_Of_Comms" 	DEFAULT="1">
<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="1">
<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="">


<SCRIPT LANGUAGE="JavaScript">
function deleteThisItem(distID)
{
	event.returnValue = false;
	var Commodity_List_Obj = document.all.Commodity_List;
	var original_Comm_List;
	if(Commodity_List_Obj.length)
	{
		original_Comm_List = Commodity_List_Obj[0].value;
	}
	else
	{
		original_Comm_List = Commodity_List_Obj.value;
	}
	var resultString = ListDeleteItem(original_Comm_List, ",", distID);

	var bDelete = true;
	if(resultString == original_Comm_List)
	{
		resultString = ListAppendItem(original_Comm_List, ",", distID);
		bDelete = false;
	}
	if(Commodity_List_Obj.length)
	{
		var i;
		for(i=0;i<Commodity_List_Obj.length;i++)
		{
			Commodity_List_Obj[i].value = resultString;
		}
	}
	else
	{
		Commodity_List_Obj.value = resultString;
	}
	var srcObj = event.srcElement;
	var tdObj = getParentObject(srcObj, "TD");
	if(tdObj)
	{
		if(bDelete)
		{
			tdObj.style.backgroundColor = "#CCCCCC";
			tdObj.style.textDecoration = "line-through";
			srcObj.alt = "undo delete";
		}
		else
		{
			tdObj.style.backgroundColor = "WhiteSmoke";
			tdObj.style.textDecoration = "none";
			srcObj.alt = "delete this item";
		}
	}
}
</SCRIPT>


<FORM ACTION="" METHOD="post" NAME="MyForm" ID="MyForm">


<FIELDSET STYLE="padding:10px; width: 750px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rule Information</LEGEND>
	<!------<INPUT TYPE="Hidden" NAME="Old_Number_Of_Comms" ID="Old_Number_Of_Comms" VALUE="<CFOUTPUT>#FORM.Number_Of_Comms#</CFOUTPUT>">----->
	<INPUT TYPE="Hidden" NAME="Old_Commodity_List" ID="Old_Commodity_List" VALUE="<CFOUTPUT>#Old_Commodity_List#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="From_Step_1" ID="From_Step_1" VALUE="1">
	<table WIDTH="100%">
		<TR>
			<TD ALIGN="right"><B>Rule Name:</B></TD>
			<TD WIDTH="90%"><INPUT TYPE="text" NAME="Rule_Name" ID="Rule_Name" SIZE="64" MAXLENGTH="254" VALUE="<CFOUTPUT>#FORM.Rule_Name#</CFOUTPUT>"></TD>
		</TR>
		<TR VALIGN="top">
			<TD ALIGN="right"><B>Commodities:</B></TD>
			<TD VALIGN="top">
			<SCRIPT>
				function showSearchWindow()
				{
					event.returnValue = false;
					NewWindow("/Search_Screens/Commodity_Search.cfm?Formname=MyForm&ReturnFieldName=Symbol&FieldName=Commodity_List", "productwindow", 800, 600, "yes", "yes")
				}
			</SCRIPT>
			<B>
			<FONT COLOR="#FF0000">[</FONT>
			<a href="##" ONCLICK="javascript: showSearchWindow();">click here to select commodities</a>
			<FONT COLOR="#FF0000">]</FONT>
			</B>
			<BR><BR>
			<CFSCRIPT>
				Border="Yes";					BorderSize=1;				BorderColor="orange";			Image="/images/plus3.gif";
				ImageOpen="/images/minus3.gif";	TitleColor="Blue";			TitleFont="Arial";				TitleSize=8;
				IsClosed="No";					Width=550;
			</CFSCRIPT>

			<CFQUERY NAME="Get_Current_Commodity_Info" DATASOURCE="#application.datasource#">
				SELECT	RTRIM(LTRIM(Commodities_Symbol.Symbol)) AS Symbol, Commodities_Symbol.Symbol_Description
				FROM	Commodities_Symbol
				WHERE
						<CFIF Form.Commodity_List NEQ "">
						RTRIM(LTRIM(Commodities_Symbol.Symbol)) IN (#ListQualify(Form.Commodity_List, "'", ",")#)
						<CFELSE>
						1=2
						</CFIF>
			</CFQUERY>
			<CFSET CommCount_String = "Selected Commodities">
			<CFIF Get_Current_Commodity_Info.RecordCount GT 0>
				<CFSET CommCount_String = "#CommCount_String# (#Get_Current_Commodity_Info.RecordCount#)">
			</CFIF>
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"
				BorderColor="#BorderColor#"
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Hide #CommCount_String#"
				TitleClosed="View #CommCount_String#"
				TitleTooltip="Click here to togle view"
				TitleColor="#TitleColor#"
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">

				<CFIF Get_Current_Commodity_Info.recordCount GT 0>
					<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="100%">
						<TR BGCOLOR="ffffff">
						<CFOUTPUT QUERY="Get_Current_Commodity_Info">
						<TD BGCOLOR="EEEEEE">
						<A HREF="void(0);" onClick="javaScript:return deleteThisItem('#Symbol#');"><IMG SRC="/Images/scissor.gif" BORDER="0" ALT="delete this item"></A>&nbsp;
						<SPAN CLASS="normal">#lcase(Symbol_Description)#</SPAN>
						</TD>
						#IIf(Currentrow Mod 2,DE(''),DE('</TR><TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ffffff'))#">'))#
						</CFOUTPUT>
					</TABLE>
				</CFIF>

				</CF_openLayer>
			<INPUT TYPE="Hidden" NAME="Commodity_List" ID="Commodity_List" VALUE="<CFOUTPUT>#FORM.Commodity_List#</CFOUTPUT>">
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"submitForm();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
	</FIELDSET>
	<CFOUTPUT>
	<CFIF len(trim(URL.RID)) GT 0>
		<INPUT TYPE="hidden" NAME="Rule_ID" ID="Rule_ID" VALUE="#URL.RID#">
		<INPUT TYPE="hidden" NAME="Original_Rule_Name" ID="Original_Rule_Name" VALUE="#FORM.Rule_Name#">
		<INPUT TYPE="hidden" NAME="Original_Comm_Count" ID="Rule_ID" VALUE="#FORM.Number_Of_Comms#">
	</CFIF>

	</CFOUTPUT>
</FORM>

</cfmodule>