<!------ deduction_search_popup.cfm ----->
<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Search - Deductions</TITLE>
	<style>
	.searchHeader {
		border-bottom:1px solid black;
		font-weight:bold;
		background-color:##ffce84;
	}
	</style>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<cfscript>
	DDObj = createObject("Component","components.Match_Central.MatchCentral").init();
	DDAnalysts = DDObj.getDDAnalysts();
	stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct();
</cfscript>


<CFSET thisPage = CGI.SCRIPT_NAME>
<cfparam NAME="URL.SelectedDeduction" 	default="">
<cfparam NAME="FORM.SelectedDeduction" 	default="">
<cfparam NAME="FORM.Selected_Deduction_ID" 	default="">
<cfparam NAME="FORM.FinalItemList" 	default="">
<cfparam NAME="FORM.FinisedSearching" 	default="0">
<cfparam name="URL.SelectSingleSearchResultOnly" 	default="1">
<cfparam name="FORM.SelectSingleSearchResultOnly" 	default="#URL.SelectSingleSearchResultOnly#">
<cfparam NAME="URL.Dist_ID" DEFAULT="">
<cfparam NAME="FORM.Dist_ID" DEFAULT="">
<cfparam NAME="URL.BBApprovedAmt" DEFAULT="">
<cfparam name="URL.Filter_Distributor"  default="0">
<cfparam name="FORM.Filter_Distributor"  default="0">

<cfset importType = "" />
<cfif FORM.SelectSingleSearchResultOnly EQ 1>
	<cfset importType = "single" />
</cfif>

<CFIF URL.SelectedDeduction neq "">
	<cfset FORM.SelectedDeduction = URL.SelectedDeduction>
</cfif>

<cfmodule template="/search_screens/Popup_Search.cfm"
	FirstFormNameVariable="URL.FormName"
	FirstFieldNameVariable="URL.FieldName"
	ActionPage="#thisPage#"
	id="#FORM.Selected_Deduction_ID#"
	Dist_ID="#URL.Dist_ID#"	
	FinalItemList="#FORM.FinalItemList#"
	ReturnFinalItemListVariable="FORM.FinalItemList"
	FinisedSearching="#FORM.FinisedSearching#"
	LastFormNameVariable="FORM.Formname"
	LastFieldNameVariable="FORM.FieldName"			
	SelectSingleSearchResultOnly="#URL.SelectSingleSearchResultOnly#"
	importType="#importType#"			
	BBApprovedAmt="#BBApprovedAmt#"
	Filter_Distributor="#Filter_Distributor#"
	SelectedDeduction = "#SelectedDeduction#"
	>

<cfparam name="FORM.state" 	default="0">
<!------ This page default settings ----->
<cfparam name="FORM.DD_Number" 	default="">
<cfparam name="FORM.Analyst_User_ID" default="">
<cfparam name="FORM.DD_Ref" default="">
<cfparam name="FORM.Broker_Name" default="">
<cfparam name="FORM.Check_No" default="">
<cfparam name="FORM.Distributor" default="">
<cfparam name="FORM.Distributor_Name" default="">
<cfparam name="FORM.SORT_BY" default="DD_DedID_SP_Number">
<cfparam name="FORM.SORT_ORDER" default="ASC">


<cfif form.SORT_BY eq "">
	<cfset form.SORT_BY = "DD_DedID_SP_Number">
</cfif>

<cfif form.SORT_ORDER eq "">
	<cfset form.SORT_ORDER = "ASC">
</cfif>

<!--- Below variables are used on "/deductions/search_screens/ded_search_query.cfm" --->
<cfset SearchSource = "Billback">
<cfset FORM.Filter_Closed = 1>
<cfset FORM.Filter_Attached = 1>	
<cfset FORM.apply_pagination = 1>
<cfset businessSegmentID = "">
<cfset FORM.DistributorBillToID = "">

<!--- Get the "business segment" of the payee --->
<cfif form.Dist_ID neq "">
	<cfset useLakebaseForgetDIstributorInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
	<cfif useLakebaseForgetDIstributorInfo>
		<cftry>
			<cfset getDIstributorInfo = application.oLakebase.toQuery(
				application.oLakebase.selectRows("bsa_foodservice_customers", {
					"select" = "business_segment_id,distributor_bill_to_id",
					"bsa_foodservice_customers_id" = "eq.#form.Dist_ID#"
				}),
				"business_segment_id,distributor_bill_to_id"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForgetDIstributorInfo = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForgetDIstributorInfo>
	<cfquery name="getDIstributorInfo" datasource="#application.datasource#">
		SELECT		Business_Segment_ID,Distributor_Bill_To_ID
		FROM		BSA_Foodservice_Customers
		WHERE		BSA_Foodservice_Customers_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.Dist_ID#" />
	</cfquery>
	</cfif>

	<cfif getDIstributorInfo.Business_Segment_ID neq "" AND getDIstributorInfo.Business_Segment_ID neq 0>
		<cfset businessSegmentID = getDIstributorInfo.Business_Segment_ID>
	</cfif>

	<cfset FORM.DistributorBillToID = getDIstributorInfo.Distributor_Bill_To_ID>
</cfif>

<script language="JavaScript">
	function reset_Form_Fields(searchForm)
	{
		searchForm.reset();
	}
	function searchData(colName,colOrder)
	{
		document.frmDeductionSearchPopup.startrow.value=1;
		document.frmDeductionSearchPopup.frompage.value=1;
		document.frmDeductionSearchPopup.SORT_BY.value = colName;
		document.frmDeductionSearchPopup.SORT_ORDER.value = colOrder;
		document.frmDeductionSearchPopup.submit();
		return false;
	}
	function finishedSearching(searchForm)
	{
		searchForm.FinisedSearching.value = 1;
		searchForm.submit();
		return false;
	}
	function EnableDisableSearch()
	{
		if($('##Filter_Distributor').prop('checked') == true){
			$('##Distributor_Name').prop("disabled", true);
			$('##Distributor').prop("disabled", true);
		}
		else{
			$('##Distributor_Name').prop("disabled", false);
			$('##Distributor').prop("disabled", false);
		}
	}
</script>

<FORM ACTION="#thisPage#" METHOD="post" name="frmDeductionSearchPopup">
<FIELDSET STYLE="padding:8px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">deduction search</LEGEND>
	<TABLE cellpadding="2" cellspacing="0" border="0">
	<TR>
	<TD valign="top">
		<strong>Deduction Number</strong><br>
		<INPUT TYPE="Text" NAME="DD_Number" VALUE="#FORM.DD_Number#" STYLE="Width:170px">
	</TD>

	<TD valign="top"><strong>#stDeductionLabels["Reference"]#<strong><br><input type="text" name="DD_Ref" id="DD_Ref" STYLE="Width:170px" value="#form.DD_Ref#"></TD>	
	<TD valign="top"><strong>#application.returned_customer_setting.broker_label_singular# Name</strong><br><input type="text" name="Broker_Name" id="Broker_Name" value="#form.Broker_Name#" STYLE="Width:170px"></TD>	
	<TD valign="top"><strong>Check Number</strong><br><input type="text" name="Check_No" id="Check_No" value="#form.Check_No#" STYLE="Width:170px"></TD>
	</TR>
	<TR>
	<TD valign="top"><strong>#application.returned_customer_setting.shard_ship_to_label# ##/ #application.returned_customer_setting.billto_label# ##</strong>
	<br><em style="color:##FF3333;">(Enter ID followed by enter key)</em><br>
	<textarea NAME="Distributor" id="Distributor" cols="20" rows="3" <cfif Form.Filter_Distributor eq 1>disabled</cfif>>#form.Distributor#</textarea>
	</TD>
	<TD valign="top"><strong>#application.returned_customer_setting.shard_ship_to_label#/ #application.returned_customer_setting.billto_label#</strong>
	<br><em style="color:##FF3333;">(Enter Name followed by enter key)</em><br>
	<textarea NAME="Distributor_Name" id="Distributor_Name" cols="20" rows="3" <cfif Form.Filter_Distributor eq 1>disabled</cfif>>#form.Distributor_Name#</textarea>
	</TD>
	<TD valign="top"><strong>Deduction Analyst</strong><br>
		<SELECT NAME="Analyst_User_ID" id="Analyst_User_ID">
			<option value="" style="color:##999;">** select option **</option>
			<cfloop query="DDAnalysts">
				<option value="#User_ID#" <cfif form.Analyst_User_ID eq User_ID>SELECTED</cfif>>#Name_First# #Name_Last#</option>
			</cfloop>
		</SELECT>
	</TD>
	<TD valign="top"><strong>Filter #application.returned_customer_setting.BillTo_Label# / #application.returned_customer_setting.Shard_Ship_To_Label#</strong>
	<br><input type="checkbox" name="Filter_Distributor" id="Filter_Distributor" value="1" <cfif Form.Filter_Distributor eq 1>checked</cfif> onClick="EnableDisableSearch()">
	<br><br><br>
		<FONT COLOR="##ff0000">&nbsp;&nbsp;&nbsp;<B>[</B></FONT><A HREF="javascript: reset_Form_Fields(document.frmDeductionSearchPopup);"><B>reset</B></A><FONT COLOR="ff0000"><B>]</B></FONT>
		&nbsp;&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="searchData('DD_DedID_SP_Number','ASC')">search</a><FONT COLOR="FF0000">]</FONT></B>
	</TD>		
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

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=50>

<CFIF FORM.state EQ 1>
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
<cfinclude template="/deductions/search_screens/ded_search_query.cfm">

<cfscript>	
if(form.SORT_ORDER EQ "ASC"){
	SORT_IMAGE = "/images/up_1.gif";
	form.SORT_ORDER = "DESC";
}else{
	SORT_IMAGE = "/images/down_1.gif";
	form.SORT_ORDER = "ASC";
}	
</cfscript>

<FIELDSET STYLE="padding:8px; width: 700px; border: 1px solid Blue;">		
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <cfif Get_Data.record_count EQ 1>Is<CFELSE>Are</cfif> #Get_Data.record_count#<cfif Get_Data.record_count EQ 1>&nbsp;deduction<CFELSE>&nbsp;deductions</cfif> That <cfif Get_Data.record_count EQ 1>Matched<CFELSE>Match</cfif> The Above Criteria</LEGEND>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0"  CLASS="MainTable">
		<TR>
			<TD class="searchHeader" width="15px" style="border-bottom:0px;">&nbsp;</TD>
			<TD class="searchHeader" width="150px" style="border-bottom:0px;">
				<cfif form.SORT_BY EQ "DD_DedID_SP_Number">
					<a href="javascript:searchData('DD_DedID_SP_Number','#form.SORT_ORDER#');">DD Number</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('DD_DedID_SP_Number','ASC');">DD Number</a>
				</cfif>
			</TD>
			<TD class="searchHeader" width="345px" style="border-bottom:0px;">
				<cfif form.SORT_BY EQ "Distributor_Name">
					<a href="javascript:searchData('Distributor_Name','#form.SORT_ORDER#');">#application.returned_customer_setting.distributor_label_singular#</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('Distributor_Name','ASC');">#application.returned_customer_setting.distributor_label_singular#</a>
				</cfif>
			</TD>

			<TD class="searchHeader" width="100px" style="border-bottom:0px;">
				<cfif form.SORT_BY EQ "DD_Date">
					<a href="javascript:searchData('DD_Date','#form.SORT_ORDER#');">DD Date</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('DD_Date','ASC');">DD Date</a>
				</cfif>
			</TD>
			<TD class="searchHeader" width="100px" style="border-bottom:0px;">
				<cfif form.SORT_BY EQ "DD_Amount">
					<a href="javascript:searchData('DD_Amount','#form.SORT_ORDER#');">Amount</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('DD_Amount','ASC');">Amount</a>
				</cfif>
			</TD>
		</TR>
		<!--- Second Row Header Start --->
		<TR>
			<TD class="searchHeader" width="15px">&nbsp;</TD>
			<TD class="searchHeader" width="150px">
				<cfif form.SORT_BY EQ "DD_Check_Number">
					<a href="javascript:searchData('DD_Check_Number','#form.SORT_ORDER#');">Chk ##</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('DD_Check_Number','ASC');">Chk ##</a>
				</cfif>
			</TD>
			<TD class="searchHeader" width="240px">
				<cfif form.SORT_BY EQ "Broker_Name">
					<a href="javascript:searchData('Broker_Name','#form.SORT_ORDER#');">#application.returned_customer_setting.broker_label_singular#</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('Broker_Name','ASC');">#application.returned_customer_setting.broker_label_singular#</a>
				</cfif>
			</TD>
			<TD class="searchHeader" width="100px">
				<cfif form.SORT_BY EQ "DD_Reference">
					<a href="javascript:searchData('DD_Reference','#form.SORT_ORDER#');">#stDeductionLabels["Reference"]#</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('DD_Reference','ASC');">#stDeductionLabels["Reference"]#</a>
				</cfif>
			</TD>
			<TD class="searchHeader" width="100px">
				<cfif form.SORT_BY EQ "Name_Last">
					<a href="javascript:searchData('Name_Last','#form.SORT_ORDER#');">Analyst</a>
					<img src="#SORT_IMAGE#">
				<cfelse>
					<a href="javascript:searchData('Name_Last','ASC');">Analyst</a>
				</cfif>
			</TD>
		</TR>

		<CFLOOP QUERY="Get_Data">
		<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
			<TD>
			<INPUT TYPE="radio" NAME="Selected_Deduction_ID" VALUE="#Deduction_ID#"
			<cfif listfind(FORM.SelectedDeduction, Deduction_ID) NEQ 0>CHECKED</cfif>>	
			</TD>
			<TD>#DD_DedID_SP_Number#</TD>
			<TD>#Distributor_Name#</TD>
			<TD>#trim(dateformat(DD_Date, 'mm/dd/yyyy'))#</TD>
			<TD>#trim(dollarFormat(DD_Amount))#</TD>
		</TR>
		<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
			<TD>&nbsp;</TD>
			<TD>#DD_Check_Number#</TD>
			<TD>#Broker_Name#</TD>
			<TD>#DD_Reference#</TD>
			<TD>#trim(Name_First)# #trim(Name_Last)#</TD>
		</TR>
		</CFLOOP>
	</TABLE>
</FIELDSET>

<DIV STYLE="font-size: 12px; color: Red;">
	<CF_Next_Previous_For_Forms
		formname="frmDeductionSearchPopup"
		query="Get_Data"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams=""
		record_count="#val(Get_Data.record_count)#">
</DIV>
	
<div align="center">
	<a HREF="##" onClick="javascript: return finishedSearching(document.frmDeductionSearchPopup)">#application.util.string.actionLinkFormat2("import selected record")#</a>
</div>
</CFIF>

<!------ popup search code ----->
<INPUT TYPE="Hidden" NAME="Formname" VALUE="#FORM.FormName#">
<INPUT TYPE="Hidden" NAME="FieldName" VALUE="#FORM.FieldName#">
<INPUT TYPE="Hidden" NAME="FinalItemList" VALUE="#FORM.FinalItemList#">
<INPUT TYPE="HIDDEN" NAME="FinisedSearching"  VALUE="0">
<INPUT TYPE="HIDDEN" NAME="startrow"  VALUE="#FORM.startrow#">
<INPUT TYPE="HIDDEN" NAME="frompage"  VALUE="#FORM.frompage#">
<INPUT TYPE="Hidden" NAME="SelectSingleSearchResultOnly" VALUE="#FORM.SelectSingleSearchResultOnly#">	
<INPUT TYPE="Hidden" NAME="Dist_ID" VALUE="#FORM.Dist_ID#">
<INPUT TYPE="Hidden" NAME="BBApprovedAmt" VALUE="#FORM.BBApprovedAmt#">
<INPUT TYPE="Hidden" NAME="SORT_BY">
<INPUT TYPE="Hidden" NAME="SORT_ORDER">
<INPUT TYPE="Hidden" NAME="SelectedDeduction" VALUE="#FORM.SelectedDeduction#">
</FORM>
</BODY>
</HTML>
</CFOUTPUT>