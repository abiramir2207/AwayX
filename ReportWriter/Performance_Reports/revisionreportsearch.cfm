<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script>
function showSearchResult()
{
	document.SearchForm.submit();
}
function start_End_Date(start_D,thisObj)
	{
		var spName;
		if(start_D == 1)
		{
			spName = "SP_Start_date";
		}
		else
		{
			spName = "SP_End_date";			
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}
	
	function disable_start_End_Date()
	{
		start_End_Date(1,SearchForm.Start_date_Operator);
		start_End_Date(2,SearchForm.End_date_Operator);
		SearchForm.Start_date.style.fontSize=10;
		SearchForm.End_date.style.fontSize=10;
	}
</script>

<body onload="disable_start_End_Date();">
<cfparam name="form.Generic_Type" default = "0">
<cfparam name="form.Program_Number" default="">
<FORM TARGET="revisionreportresults" STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="revisionreport.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" TARGET="Search_Result">
<FIELDSET STYLE="padding:8px; width: 750px; border: 1px solid Blue;display:table;" ALIGN="Center">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Revision Report Search</LEGEND>
<TABLE align="center">
<TR>
<TD>
<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
<cfif discountIdentifierManager.discountIdentifierOn()>
				<span ID="searchItemLabel"><B>Discount Identifier</B></span><BR>
				<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
				<cfset qDiscountIdentifiers = discountIdentifierManager.getActive()>
				<SELECT NAME="Discount_Identifier">
					<OPTION VALUE="0">**ALL** Discount Identifier</OPTION>
					<CFOUTPUT QUERY="qDiscountIdentifiers"><OPTION VALUE="#trim(Discount_Identifier_ID)#"#IIF(trim(FORM.Discount_Identifier) EQ Discount_Identifier_ID, DE(" SELECTED"), DE(""))#>#trim(Discount_Identifier_Desc)#</OPTION></CFOUTPUT>
				</SELECT>
			<cfelse>
				<span ID="searchItemLabel"><B>Program Generic Type</B></span><BR>
				<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
				<CFQUERY NAME="Get_Generic_Types" DATASOURCE="#application.datasource#">
				Select	Generic_Type
				From 	Generic_Type
				Order By Generic_Type
				</CFQUERY>
				<SELECT NAME="Generic_Type">
					<OPTION VALUE="0">**ALL** Generic Type</OPTION>
					<CFOUTPUT QUERY="Get_Generic_Types"><OPTION VALUE="#trim(Generic_Type)#"#IIF(trim(FORM.Generic_Type) EQ Generic_Type, DE(" SELECTED"), DE(""))#>#trim(ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label))#</OPTION></CFOUTPUT>
				</SELECT>
			</cfif></TD>
				
<TD>
			<span ID="searchItemLabel"><B>Program Status</B></span><BR>
				<CFQUERY NAME="Get_Status" DATASOURCE="#application.datasource#">
					Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
					From 	Contract_Status_Types
					Where	
						Contract_Status_Type_ID <> 3
					Order By Contract_Status_Type_ID
					</CFQUERY>
					<CFPARAM NAME="FORM.Status" DEFAULT="-1">
					<SELECT NAME="Status">
						<OPTION VALUE="0">**ALL** Status</OPTION>
						<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.region_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetRegions" DATASOURCE="#application.datasource#">
			SELECT Service_Region_ID, Region_Name
			FROM Service_Regions
			WHERE Deleted = 0
			AND len(Region_Name) > 0
			ORDER BY Region_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="0">
			<SELECT NAME="Service_Region_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Service_Region_ID) EQ Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<cfif  application.returned_customer_setting.Responsible_Person EQ 1>
			<cfset qUsers = CreateObject("component", "components.user.UserManager").search() />
			<TD>
				<span ID="searchItemLabel"><B><CFOUTPUT>Responsible Sales Person</CFOUTPUT><!--- User Position ---></B></span><BR>				
				<SELECT NAME="Responsible_Sales_Person">
					<OPTION VALUE="" SELECTED>**ALL** Users</OPTION>
					<CFOUTPUT QUERY="qUsers"><OPTION VALUE="#trim(User_ID)#">#trim(User_Full_Name)#</OPTION></CFOUTPUT>
				</SELECT>
			</TD>
			</cfif>
</TR>
<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
	<CFSET Date_Operator_Symbols=" ,>=,=,<=">
<TR>			
			
			<TD>
			<span ID="searchItemLabel"><B>Approval Start Date</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0" Width="170">
				<TR><TD>
				<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(1,this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.Start_date" DEFAULT="#Now()#">
				<SPAN ID="SP_Start_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
				</SPAN>
				</TD>
			</TR></TABLE>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Approval End Date</B></span><BR>
			<CFOUTPUT>
			<TABLE CELLPADDING="0" CELLSPACING="0" width="170">
				<TR><TD>
				<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(2,this);" NAME="End_date_Operator" ID="End_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.End_date" DEFAULT="#Now()#">
				<SPAN ID="SP_End_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
				</SPAN>
				</TD>
				</TR></TABLE>
			</CFOUTPUT>			
			</TD>
			
		<TD align="left">
		<TABLE CELLPADDING="0" CELLSPACING="0">
			<TR><TD>
		<span ID="searchItemLabel"><B>Sort By</B></span><br>
			<SELECT NAME="sort_by">
					<OPTION VALUE="contract_number" SELECTED>Program Number</OPTION>
					<cfif discountIdentifierManager.discountIdentifierOn()>
					<OPTION VALUE="Discount_Identifier_Desc">Discount Identifier</OPTION>
					<cfelse>
					<OPTION VALUE="generic_type">Generic Type</OPTION>
					</cfif>
					<OPTION VALUE="contract_status_type_idx">Status</OPTION>
					<OPTION VALUE="service_region_id">Region</OPTION>
					<OPTION VALUE="Responsible_user_id">Responsible Sales Person</OPTION>
					<OPTION VALUE="contract_start_date">Start Date</OPTION>
					<OPTION VALUE="contract_end_date">End Date</OPTION>
			</SELECT></TD>
				<TD>
			<span ID="searchItemLabel"><B>Sort Order</B></span><br>
			<SELECT NAME="sort_order">
					<OPTION VALUE="asc" SELECTED>asc</OPTION>
					<OPTION VALUE="desc">desc</OPTION>
			</SELECT>
					</TD>
				</TR></TABLE>
		</TD>
		<TD><table>
		<tr>
		<td>
		<B>Program Number</B> <br><INPUT TYPE="Text" NAME="Program_Number" STYLE="WIDTH:100px;" <CFIF len(trim(FORM.Program_Number)) GT 0>VALUE="#trim(FORM.Program_Number)#"</CFIF>>
		</td>
		<TD><B>Approval Status</B> <br>
					<SELECT NAME="approval_type">
					<OPTION VALUE="0" SELECTED>All</OPTION>
					<OPTION VALUE="1">Approved</OPTION>
					<OPTION VALUE="2">Not Approved</OPTION>
					</SELECT></TD>
		</tr>
		</table></TD>	
</TR>
<TR>
		<TD>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.SearchForm.reset();disable_start_End_Date();">reset form</a><FONT COLOR="FF0000">]</FONT></B>
			&nbsp;&nbsp;
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:showSearchResult();">search</a><FONT COLOR="#FF0000">]</FONT></B>
			
			</TD>
</TR>
</TABLE>
</FIELDSET>
<input type ="hidden" name="dosearch" value="1">
</form>
</body>
</html>
