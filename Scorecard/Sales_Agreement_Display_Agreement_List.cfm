<!---
	Name: Sales_Agreement_display_agreement_list.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		Displays the list of programs in a table format.
	Usage:
		Called whenever programs listing is required, scorecard, search, etc.
--->	

<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags"> 

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFPARAM name="URL.ShowCheckBoxes" default="0">
<CFPARAM name="URL.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="Form.SelectedPrograms" default="">
<CFPARAM name="form.ILPL_PreSubmit" default="">
<CFPARAM name="printresults" default="0">
<CFPARAM name="form.currentProgramList" default="">
<CFPARAM name="form.currentStatusList" default="">
<CFPARAM name="SECTION_TO_OPEN" default="" />


<CFINCLUDE TEMPLATE="Tables_Measures.cfm">
<cfinclude template="sales_agreement_status_tool_tip.cfm" />
<cfoutput>#programStatusToolTip#</cfoutput>

<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
<STYLE> 
 thead { display: table-header-group } 
</STYLE> 
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();");
function initTheTooltip(ToolTipText)
{
	/*if(ToolTipText != '')
	{
	textHolder = ToolTipText;
		messages[0]="";
		messages[0]= "" + textHolder + ""
		popUp(0)
	}
	else
	{*/
	popUp(-1)
	
}
</SCRIPT>
<!-----  the header of the table goes here  ----->
<cfif printresults EQ 1>
	<TABLE border="0" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" cellspacing="0" cellpadding="4" CLASS="Maintable">
	<THEAD>
	<cfoutput>
		<tr bordercolordark="000000" bgcolor="000000">
			<td width="#Status_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">STATUS</td>
      <td nowrap width="#Number_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">AGREEMENT</td>
      <td width="#Type_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">TYPE</td>
			<td width="#Title_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">TITLE</td>
			<td width="#Evaluate(SD_Width+ED_Width)#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">START/END</td>
			<td width="#Quantity_Width#" STYLE="color:##FFFFFF;font-size:8pt;font-weight:bold">QTY.</td>
		</tr>
	</cfoutput>
	</THEAD>

<CFELSE>
	<TABLE border="0" WIDTH="910" cellspacing="0" cellpadding="2" CLASS="Maintable">
</cfif>


<cfif printresults EQ 1>
	<cfset StartRow = 1>
	<cfset MaxRows = TheQuery.Recordcount>
</cfif>
<CFIF MaxRows LT 1 or Not IsNumeric(MaxRows)>
	<cfset MaxRows = 1>
</CFIF>

<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
		
	<cf_cryp string="#TheQuery.Export_Sales_Agreement_ID#" type="en" key="#request.key#">

		<CFIF currentrow mod 2>
			<CFSET BG_COLOR = "white">
		<CFELSE>
			<CFSET BG_COLOR = "ccffcc">
		</CFIF>

	<TR BGCOLOR="#BG_COLOR#" VALIGN="TOP">
		<TD NOWRAP ALIGN="left" WIDTH="10%">
		#getProgramStatusImageString(TheQuery.Contract_Status_Type_IDX)#
			<cfif printresults EQ 0>
		</cfif>
		</TD>
		
		<TD nowrap WIDTH="22%">
	     <cfif TheQuery.Contract_Attachments_Count GT 0>
		   <img src="/images/doc.gif" width="13" height="16" ALT="This Sales Agreement has #TheQuery.Contract_Attachments_Count# attached document(s)" height="16" width="13">
			<cfelse>
		   <img src="/images/fill.gif" width="13" height="16">
		</cfif>
		<CF_CRYP type="en" key="#request.key#" string="#TheQuery.Export_Sales_Agreement_ID#">
		<CFSET CID = cryp.value>
		<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

		<cfset windowWidth = 815>
		<cfset windowHeight = 650>
		<cfset targetURL = "/common_files/contracts/Sales_Agreement_Edit_Menu.cfm?CID=#CID#">
		<cfset targetWindow = "_parent">
        

		<cfif URL.SearchIsConductedFromOtherWindow EQ 0>
			<A target="#targetWindow#" HREF="#targetURL#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Export_Sales_Agreement_Number#">
			#Export_Sales_Agreement_Number#
		</cfif>
			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
		</TD>
		<TD WIDTH="22%">
			&nbsp;#Export_Sales_Agreement_Name#	
		</TD>
		<TD WIDTH="22%">&nbsp;#Name#</TD>
		<TD WIDTH="25%">#dateformat(Export_Start_Date, 'mm/dd/yyyy')#<br />#dateformat(Export_End_Date, 'mm/dd/yyyy')#</TD>
		</TR>
</CFOUTPUT>			
</TABLE>