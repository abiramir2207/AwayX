<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFPARAM NAME="URL.Program_Id" 	DEFAULT="0">
<CFPARAM NAME="URL.Contract_Products_Id" 	DEFAULT="0">
<CFPARAM NAME="form.Contract_Products_Id" 	DEFAULT="#URL.Contract_Products_Id#">
<CFIF URL.RID NEQ "">
	<CFSET FORMULA_PAGE_NAME="5">
<CFELSE>
	<CFSET FORMULA_PAGE_NAME="3">
</CFIF>
<CFPARAM NAME="form.Program_Fixed_Component_ID_Component_Name_ID" 	DEFAULT="">

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script>
	function submitForm(){
		/*
		if(trim(document.all.Rule_Name.value).length == 0)
		{
			alert("Please Name This Rule.");
		}
		*/
		if(trim(document.all.Commodity_List.value).length == 0)
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
<cfscript>
	appSettings = application.appSettingsGet;
</cfscript>
<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
	<cfquery name="qUpdSelectedScheduleOptions" datasource="#application.datasource#">
			UPDATE R SET FP_Schedule_Option_ID = (SELECT Formula_Price_Rebate_Type from Contract_main Where contract_main_id = '#URL.Program_Id#')
			FROM Program_Formula_Pricing_Rules R
			WHERE R.Program_Formula_Pricing_Rule_ID =  '#trim(URL.RID)#'
			  AND R.Deleted = 0 AND
			  ISNULL(R.FP_Schedule_Option_ID,0) = 0
	</cfquery>
</cfif>
<cfscript>
	oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
	q = oFormula.getProgramFormula(URL.Program_Id,URL.Contract_Products_Id,trim(URL.RID));
	if(q.recordCount > 0){
		url.RID = q.Program_Formula_Pricing_Rule_ID;	
	}
	qSchedule = oFormula.getFormulaSchedule();
	qTypes = oFormula.getFormulaTypes();
	qComponents = oFormula.getFormulaComponentFromProgram(URL.Program_Id);
</cfscript>

<CFIF URL.RID NEQ "">
	<CFQUERY NAME="Saved_Formula_Info" DATASOURCE="#application.datasource#">
		SELECT	*
		FROM	Program_Formula_Pricing_Rules
		WHERE
				Program_Formula_Pricing_Rule_ID = '#URL.RID#'
				AND
				Deleted = 0
		ORDER BY	RULE_NAME
	</CFQUERY>
	<CFQUERY NAME="Get_All_Commodities" DATASOURCE="#application.datasource#">
		SELECT 	LTRIM(RTRIM(Symbol)) AS Symbol,Commodities_Symbol_ID
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
		SELECT Symbol,Commodities_Symbol_ID
		FROM 	Program_Formula_Pricing_Rule_Comm_Data
		WHERE
				1 = 2
	</CFQUERY>
</CFIF>
<!--- NEED TO GET RULE NAME --->
	<CFQUERY NAME="Program_Info" DATASOURCE="#application.datasource#">
		SELECT	Contract_Main.*, pcpo.Formula_Pricing_Type
		FROM	Contract_Main
				INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_Id = Contract_Main.ProgramType_ID
		WHERE	Contract_Main.Contract_Main_ID = '#URL.Program_Id#'
	</CFQUERY>


<CFIF Saved_Formula_Info.recordCount GT 0>
	<CFPARAM NAME="FORM.Rule_Name" 	DEFAULT="#Saved_Formula_Info.Rule_Name#">
	<CFPARAM NAME="FORM.Number_Of_Comms" 	DEFAULT="#Saved_Formula_Info.Number_Of_Comms#">
	<CFPARAM NAME="FORM.Saved" 	DEFAULT="#Saved_Formula_Info.Saved#">
<!---	<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="#Saved_Formula_Info.Show_Details#">--->
<CFELSE>
	<CFPARAM NAME="FORM.Rule_Name" 	DEFAULT="#Program_Info.Contract_Number#">
	<CFSET FORM.RID = "">
	<CFPARAM NAME="FORM.Saved" 	DEFAULT="0">
</CFIF>

<CFSET Old_Commodity_List = ValueList(Get_All_Commodities.Commodities_Symbol_ID)>
<CFIF Get_All_Commodities.recordCount GT 0>
	<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="#ValueList(Get_All_Commodities.Commodities_Symbol_ID)#">
</CFIF>
<CFPARAM NAME="FORM.Rule_Name" 			DEFAULT="">
<CFPARAM NAME="FORM.Number_Of_Comms" 	DEFAULT="1">
<!---<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="1">--->
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
	<INPUT TYPE="Hidden" NAME="Contract_Products_Id" ID="Contract_Products_Id" VALUE="<CFOUTPUT>#form.Contract_Products_Id#</CFOUTPUT>">
	
	<table WIDTH="100%">
		<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
			<TR>
				<TD ALIGN="right">  <B>Rule Name:</B>  </TD>
				<TD WIDTH="90%"><INPUT TYPE="Text" NAME="Rule_Name" ID="Rule_Name" SIZE="64" MAXLENGTH="254" VALUE="<CFOUTPUT>#FORM.Rule_Name#</CFOUTPUT>"></TD>
			</TR>
		<CFELSE>
			<TR>
				<TD ALIGN="right"> <!---  <B>Rule Name:</B>  ---> </TD>
				<TD WIDTH="90%"><INPUT TYPE="Hidden" NAME="Rule_Name" ID="Rule_Name" SIZE="64" MAXLENGTH="254" VALUE="<CFOUTPUT>#FORM.Rule_Name#</CFOUTPUT>"></TD>
			</TR>
		</CFIF>
		<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
			<cfset checked = ''>
			<cfif FORM.Saved eq 1>
				<cfset checked = 'checked'>
			</cfif>
			<TR>
				<TD ALIGN="right">  <B>Save:</B>  </TD>
				<TD WIDTH="90%"><INPUT TYPE="Checkbox" NAME="Saved" ID="Saved" <CFOUTPUT>#checked#</CFOUTPUT> Value="1"></TD>
			</TR>
		<CFELSE>
			<INPUT TYPE="Hidden" NAME="Saved" ID="Saved" SIZE="64" MAXLENGTH="254" VALUE="<CFOUTPUT>#FORM.Saved#</CFOUTPUT>">
		</CFIF>
		<TR VALIGN="top">
			<TD ALIGN="right"><B>Schedule:</B></TD>
			<TD VALIGN="top">
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
					<SELECT NAME="FP_Schedule_Option_ID">
						<cfoutput query="qSchedule">
							<cfset s = "">
							<cfif q.FP_Schedule_Option_ID eq qSchedule.FP_Schedule_Option_ID> <cfset s = "selected"></cfif>
							<OPTION VALUE="#qSchedule.FP_Schedule_Option_ID#" #s#>#qSchedule.Price_Day_Description# :: #qSchedule.Effective_Day_Description#</OPTION>
						</cfoutput>
					</SELECT>
				<cfelse>
					<cfoutput query="qSchedule">
						<cfif q.FP_Schedule_Option_ID eq qSchedule.FP_Schedule_Option_ID>
							#qSchedule.Price_Day_Description# :: #qSchedule.Effective_Day_Description#
							<INPUT TYPE="Hidden" NAME="FP_Schedule_Option_ID" ID="FP_Schedule_Option_ID" VALUE="#q.FP_Schedule_Option_ID#">
						</cfif>
					</cfoutput>
				</cfif>
			</TD>
		</TR>
		<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
		<TR VALIGN="top">
			<TD ALIGN="right"><B>Type:</B></TD>
			
				<SELECT NAME="FP_Formula_Type_ID">
					<cfoutput query="qTypes">
						<cfset s = "">
						<cfif q.FP_Formula_Type_ID eq qTypes.FP_Formula_Type_ID> <cfset s = "selected"></cfif>
						<OPTION VALUE="#qTypes.FP_Formula_Type_ID#" #s#>#qTypes.Formula_Type_Description#</OPTION>
					</cfoutput>
				</SELECT>
			</TD>
		</TR>
		</cfif>
		<TR>
			<TD ALIGN="right"><B>Item:</B></TD>
			<TD WIDTH="90%"><cfoutput>#q.Item# - #q.Description#</cfoutput></TD>
		</TR>
		<cfif Program_Info.Formula_Pricing_Type eq 2>
			<TR>
				<TD ALIGN="right"><B>Component Name:</B></TD>
				<TD VALIGN="top">
					<SELECT NAME="Program_Fixed_Component_ID_Component_Name_ID">
						<cfoutput query="qComponents">
							<cfset s = "">
							<cfif Saved_Formula_Info.Program_Fixed_Component_Name_Id eq qComponents.Program_Fixed_Component_Name_Id 
								or form.Program_Fixed_Component_ID_Component_Name_ID eq "#qComponents.Program_Fixed_Component_Name_ID#_#qComponents.Program_Fixed_Component_ID#">
								<cfset s = "selected">
							</cfif>
							<OPTION VALUE="#qComponents.Program_Fixed_Component_Name_ID#_#qComponents.Program_Fixed_Component_ID#" #s#>#qComponents.Program_Fixed_Component_Name#</OPTION>
						</cfoutput>
					</SELECT>
				</TD>
			</TR>
		</cfif>
		
		<TR VALIGN="top">
			<TD ALIGN="right"><B>Commodities:</B></TD>
			<TD VALIGN="top">
			<SCRIPT>
				function showSearchWindow()
				{
					event.returnValue = false;
					NewWindow("/Search_Screens/Commodity_Search.cfm?Formname=MyForm&ReturnFieldName=Commodities_Symbol_ID&FieldName=Commodity_List", "productwindow", 825, 625, "yes", "yes")
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
				SELECT	RTRIM(LTRIM(Commodities_Symbol.Symbol)) AS Symbol, Commodities_Symbol.Symbol_Description, Commodities_Symbol_ID
				FROM	Commodities_Symbol
				WHERE
						<CFIF Form.Commodity_List NEQ "">
						RTRIM(LTRIM(Commodities_Symbol.Commodities_Symbol_ID)) IN (#ListQualify(Form.Commodity_List, "'", ",")#)
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
						<A HREF="##" onClick="javaScript:deleteThisItem('#Commodities_Symbol_ID#');"><IMG SRC="/Images/scissor.gif" BORDER="0" ALT="delete this item"></A>&nbsp;
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
		<INPUT TYPE="hidden" NAME="Program_Id" ID="Program_Id" VALUE="#URL.Program_Id#">
	<CFIF len(trim(URL.RID)) GT 0>
		<INPUT TYPE="hidden" NAME="Rule_ID" ID="Rule_ID" VALUE="#URL.RID#">
		<INPUT TYPE="hidden" NAME="Original_Rule_Name" ID="Original_Rule_Name" VALUE="#FORM.Rule_Name#">
		<INPUT TYPE="hidden" NAME="Original_Comm_Count" ID="Rule_ID" VALUE="#FORM.Number_Of_Comms#">
	</CFIF>

	</CFOUTPUT>
</FORM>
