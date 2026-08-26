<!---
FILE:
FILENAME: 	ReportWriter/apply_deviations.cfm
CREATED: 	??/??/???? - ???
EDITED:		12/03/2008 - RBL [D17605]
			2016 April - ChrisN 48219
FUNCTIONALITY:
- This template facilitates the managing of applying deviations...
--->
<cfparam name="nav_index" default="0">
<cfmodule template="/customTags/layout.cfm"
                            layoutID = "autoPay"
                            selectedIndex = #nav_index#>
<cfsilent>
<cfset BillbackApplyDeviations = CreateObject("component", "components.Billback.BillbackApplyDeviations") />
<cfset BillbackAssignmentManager = CreateObject("component", "components.Billback.BillbackAssignmentManager") />

<CFSET PAGE_TITLE="Unapplied Deviations">
<CFSET GROUP="Billbacks">

<!--- These parameters are required for this template to process correctly --->
<CFPARAM NAME="URL.Customer_Info" default="">
<CFPARAM NAME="URL.Billback_Info" default="">
<CFPARAM NAME="URL.BB_Analyst_ID" default="0">
<CFPARAM NAME="URL.Deviation_Status" default="Active">
<CFPARAM NAME="URL.Sort_By" default="Adjustment Amount">
<CFPARAM NAME="URL.Sort_Order" default="Desc">
<CFPARAM NAME="URL.RecalcNow" default="Desc">

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<CFPARAM NAME="form.Sort_By" default="#URL.Sort_By#">
<CFPARAM NAME="form.Sort_Order" default="#URL.Sort_Order#">
<CFPARAM NAME="FORM.Deviation_Status" default="#URL.Deviation_Status#">
<CFPARAM NAME="form.BB_Analyst_ID" default="#URL.BB_Analyst_ID#">
<CFPARAM NAME="FORM.blnSubmit" default="0">
<CFPARAM NAME="form.Customer_Info" default="#URL.Customer_Info#">
<CFPARAM NAME="form.Billback_Info" default="#URL.Billback_Info#">
<CFPARAM NAME="FORM.Date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.BB_Date" 	default="">
<CFSET GTE_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
<CFSET GTE_Operator_Symbols=" ,>=,=,<=">

</cfsilent>

<cf_Number_of_Rows maxrows=100>

<!--- Process saved values --->
<cfif form.blnSubmit IS 1>
	<cfloop list="#form.DeviationList#" index="BB_Adjustment_ID">
		<cfset SafeAdjustmentID = replace(BB_Adjustment_ID, "-", "_", "all")>
		<cfset VarName="form.BB_Adjustment_#SafeAdjustmentID#">
		<Cfif isdefined(VarName)>

			<cfset DeviationType = evaluate("form.BB_Adjustment_#SafeAdjustmentID#")>
			<cfset updateAdjustments = BillbackApplyDeviations.updateDeviation(BB_Adjustment_ID,DeviationType,request.accessstructure.user_id)>
		</CFIF>
	</cfloop>

</cfif>
<CFIF URL.RecalcNow EQ 1>
	<cfset ExecRecalc = BillbackApplyDeviations.recalcNow()>
	<CFSET URL.RecalcNow = 0>
</CFIF>

<!--- end saved processing --->

	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
		TR.redTR TD
		{
			color: red;
		}

		#previewlink:hover {text-decoration:underline;}
		select  {width: 165px; font-size: 11px; }
	</STYLE>
		<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
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

		function doSearchNow()
		{
			//add restricted search
			var oSearchForm = document.MyForm;

				oSearchForm.startrow.value = 1;
				oSearchForm.frompage.value = 1;
				oSearchForm.submit();

			return false;
		}

		function saveSelections()
		{
			/******************************************************************************
			// This part of the function is no more required as the warning Message
			it has been removed now.

			if (document.MyForm.WarningMessage.value != 0)
			{
				if (confirm("You are about to hide deviations worth $" + document.MyForm.WarningMessage.value))
				{
					document.MyForm.blnSubmit.value = 1;
					document.MyForm.submit();
				}
				else
				{
					return false;
				}
			}
			else
			{
			*******************************************************************************/
				document.MyForm.blnSubmit.value = 1;
				document.MyForm.submit();
			// }
		}
		/******* This function is no more used on this page. *******/
		function ShowWarningMessage(AmountToAdd)
		{
			var CurrentAmount = document.MyForm.WarningMessage.value;
			var NewAmount = (CurrentAmount*1) + (AmountToAdd*1);
			document.MyForm.WarningMessage.value = NewAmount;
			return false;
		}

		function RecalcNow()
		{
			//D35392: GM Pullback Log entries
			window.location.href="<cfoutput>#CGI.SCRIPT_NAME#</cfoutput>?Disp=ApplyDeviations&RecalcNow=1&Customer_Info=<CFOUTPUT>#FORM.Customer_Info#</CFOUTPUT>&Billback_Info=<CFOUTPUT>#FORM.Billback_Info#</CFOUTPUT>&BB_Analyst_ID=<CFOUTPUT>#FORM.BB_Analyst_ID#</CFOUTPUT>&Deviation_Status=<CFOUTPUT>#FORM.Deviation_Status#</CFOUTPUT>&sort_by=<CFOUTPUT>#sort_by#</CFOUTPUT>&sort_Order=<CFOUTPUT>#FORM.sort_Order#</CFOUTPUT>";
		}

		function showDeviationReport()
		{
			NewWindow("about:blank", "deviation_report", "500", "300", "Yes", "No");
			window.MyForm.target = "deviation_report";
			window.MyForm.action = "/billbacks/deviation/Deviation_Detail_Report.cfm";
			window.MyForm.submit();
			window.MyForm.target = "_self";
			window.MyForm.action = "apply_deviations.cfm";
			return false;
		}
		function GTE_Operator(spName,thisObj)
		{
			var bDis = (thisObj.selectedIndex == 0)? true: false;
			disableDiv(spName,bDis,false);
		}
		function disable_Comparsion_Operators()
		{
			GTE_Operator('SP_Date',document.all.Date_Operator);
			document.all.BB_Date.style.fontSize=10;
		}
	</SCRIPT>
<script>
 	document.body.onload=new Function ("disable_Comparsion_Operators();")
</script>
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

	<!--- Field widths --->
	<cfset Row1 = "80">
	<cfset Row2 = "250">
	<cfset Row3 = "210">
	<cfset Row4 = "70">
	<cfset Row5 = "45">
	<cfset Row6 = "60">
	<cfset Row7 = "50">
	<cfset Row8 = "55">

	<cfset TotalWidth = Row1 + Row2 + Row3 + Row4 + Row5 + Row6 + Row7 + Row8>
	<cfset FourColumnWidth = Row5 + Row6 + Row7 + Row8>
	<cfset Fieldsetwidth = TotalWidth + 10>
	<cfset FieldsetwidthLong = TotalWidth + 20>

<!---D35392: GM Pullback Log entries --->
	<FORM ACTION="<cfoutput>#CGI.SCRIPT_NAME#?Disp=ApplyDeviations</cfoutput>" METHOD="post" NAME="MyForm" ID="MyForm">
<p>&nbsp;</p>
<blockquote>
<table bgcolor="" style="border: 3px solid orange; font-size: 18px;"  width="<cfoutput>#FieldsetwidthLong#px</cfoutput>" cellpadding="8">
	<tr>
		<td nowrap><strong><font color="navy">Unapplied deviation dollars:</font></strong></td>
		<td align="left"><cfoutput><strong>#lscurrencyformat(BillbackApplyDeviations.GetDeviationSums().TotalDeviationAmount)#</strong></cfoutput></td>
		<td width="200">&nbsp;</td>
		<td nowrap><strong> <font color="navy">Number of unapplied deviations:</font></strong></td>
		<td align="left"><cfoutput><strong>#BillbackApplyDeviations.GetDeviationSums().NumberofDeviations#</strong></cfoutput></td>
	</tr>
</table>



	<FIELDSET STYLE="padding:14px; border: 1px solid Blue; width: <cfoutput>#Fieldsetwidth#</cfoutput>px">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">deviation search</LEGEND>
			<table border="0" width="<cfoutput>#TotalWidth#px</cfoutput>">
				<TR>
					<TD ><!--- Customer --->
						<span ID="searchItemLabel"><strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Number/Name</strong></span><BR>

						<CFPARAM NAME="FORM.Customer_Info" DEFAULT="">
						<input type="text" name="Customer_Info" value="<cfoutput>#form.Customer_Info#</cfoutput>" style="width:165px">
					</TD>
					<TD><!--- Billback --->
						<span ID="searchItemLabel"><strong>Billback Information</strong></span>
						<img src="/images/i.gif" title="Searches reference number, payable number and title">
						<br>
						<CFPARAM NAME="FORM.Billback_Info" DEFAULT="">
						<input type="text" name="Billback_Info" value="<cfoutput>#form.Billback_Info#</cfoutput>" style="width:165px">
					</TD>
					<td>
						<!--- Billback analyst --->
						<span ID="searchItemLabel"><strong>Billback Analyst</strong></span><BR>
						<cfset GetBBAnalysts = BillbackAssignmentManager.getAnalysts()>
						<select name="BB_Analyst_ID">
							<option value="0">**ALL**</option>
							<cfoutput query="GetBBAnalysts">
							<option value="#Analyst_User_ID#" <cfif form.BB_Analyst_ID IS Analyst_User_ID>selected</cfif>>#Name_First# #Name_Last#</option>
							</cfoutput>
						</select>

					</td>

					<TD NOWRAP ALIGN="left">
					<strong>Status</strong><BR>
					<CFPARAM NAME="FORM.sort_Order" DEFAULT="DESC">
					<SELECT ID="Deviation_Status" NAME="Deviation_Status">
						<OPTION VALUE="Active" SELECTED >**Apply & Ignore**</OPTION>
						<OPTION VALUE="Applied"<CFIF FORM.Deviation_Status EQ "Applied"> SELECTED</CFIF>>Applied</OPTION>
						<OPTION VALUE="Hidden"<CFIF FORM.Deviation_Status EQ "Hidden"> SELECTED</CFIF>>Removed</OPTION>
						<OPTION VALUE="Ignore"<CFIF FORM.Deviation_Status EQ "Ignore"> SELECTED</CFIF>>Ignored</OPTION>
						<OPTION VALUE="Recalc"<CFIF FORM.Deviation_Status EQ "Recalc"> SELECTED</CFIF>>Recalc</OPTION>
						<!--- <OPTION VALUE="Deleted"<CFIF FORM.Deviation_Status EQ "Deleted"> SELECTED</CFIF>>Deleted</OPTION> --->
					</SELECT>
					</TD>
					<TD style="width:165px"></TD>
				</tr>
				<tr>

                    <!--- D17605 [begin] 12/3/08 RBL (1 of 2)
					Make the text in the drop down called Sort By match the column header names
					Change Adjustment Amount to Deviation $
					Change Billback Date to BB Age
					Change Distributor Name to Distributor
					Change Payable Number to Billback
					--->
                    <cfsilent>
						<cfscript>
                            // LET'S SET EVERYTHING IN ONE PLACE RIGHT HERE
							// A.) Sort
                            variables.aDeviationCols = arrayNew(2);
                            //[1] = View
                            variables.aDeviationCols[1][1] = 'Deviation $';
                            //[2] = SQL Sort By for switch statement below
                            variables.aDeviationCols[1][2] = 'Adjustment Amount';
                            variables.aDeviationCols[2][1] = 'Billback';
                            variables.aDeviationCols[2][2] = 'Payable Number';
                            variables.aDeviationCols[3][1] = application.returned_customer_setting.distributor_label_singular;
                            variables.aDeviationCols[3][2] = 'Distributor Name';
                            variables.aDeviationCols[4][1] = 'BB Age';
                            variables.aDeviationCols[4][2] = 'Billback Date';
                            variables.aDeviationCols[5][1] = 'Apply';
                            variables.aDeviationCols[5][2] = 'Apply';
                            variables.aDeviationCols[6][1] = 'Remove';
                            variables.aDeviationCols[6][2] = 'Hidden';
                            variables.aDeviationCols[7][1] = 'Ignore';
                            variables.aDeviationCols[7][2] = 'Ignore';
                            variables.aDeviationCols[8][1] = 'Recalc';
                            variables.aDeviationCols[8][2] = 'Recalculate';
                            // B.) Headers
                            variables.lsDeviationCols = '';
							variables.lsDeviationLabels = '';
                            for(currentItem=1; currentItem lte arrayLen(variables.aDeviationCols); currentItem=currentItem+1)
                            {
                                variables.lsDeviationCols = listAppend(variables.lsDeviationCols,variables.aDeviationCols[currentItem][2]);
                                variables.lsDeviationLabels = listAppend(variables.lsDeviationLabels,variables.aDeviationCols[currentItem][1]);

                            }
                        </cfscript>
                    </cfsilent>
                    <!--- D17605 thought...
					<cfset variables.lsDeviationColsPart1 = "Deviation $,Billback,
					<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, BB Age">
                    <cfset variables.lsDeviationColsPart2 = "Apply, Remove, Ignore, Recalc">
                    <cfset variables.lsDeviationCols = listAppend(variables.lsDeviationColsPart1,variables.lsDeviationColsPart2,',')>
					D17605 --->
					<TD style="width:165px">
						<table cellpadding="0" cellspacing="0" border="0" style="width:165px">
						<tr><td colspan="100%"><b>Billback Created Date</b></td></tr>
						<tr>
							<td>
							<cfoutput>
								<select OnChange="JavaScript: GTE_Operator('SP_Date',this);" name="Date_Operator" ID="Date_Operator" style="width:50px">
                								<cfset cnt=0>
								<cfloop list="#GTE_Operators#" index="thisOperator">
									<cfset cnt=cnt+1>
									<option value="#Trim(thisOperator)#"<cfif FORM.Date_Operator EQ Trim(thisOperator)> selected</cfif>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</option>
								</cfloop>
								</select>
							</td>
							<td valign="bottom" style="width:120px">
								<span ID="SP_Date">
								<cf_easydate formname="MyForm" fieldname="BB_Date" format="mm/dd/yyyy" default="#FORM.BB_Date#">
								</span>
							</td>
							</cfoutput>
						</tr>
						</table>
					</TD>
					<TD NOWRAP ALIGN="left">
					<strong>Sort By</strong><br />
                    <!--- Legacy...
                    <cfset sort_By_List=variables.lsDeviationColsPart1>
                    <CFSET sort_By_List="Adjustment Amount,Payable Number,Distributor Name,Billback Date">
					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					D17605 --->
					<cfoutput>
					<!--- Legacy...
					<CFSET sort_By_List=ListSort(sort_By_List,"Text")> D17605 --->
					<SELECT ID="sort_by" NAME="sort_by">
					<!--- Legacy...
					<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
						<CFSET thisItem=Trim(thisItem)>
						<OPTION VALUE="#thisItem#"<CFIF thisItem EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
					</CFLOOP>
					A.) Sort - D17605 --->
                    <cfloop from="1" to="8" index="currentSort">
                        <option value="#trim(variables.aDeviationCols[currentSort][2])#"<cfif trim(variables.aDeviationCols[currentSort][2]) EQ FORM.sort_by> selected</cfif>>#variables.aDeviationCols[currentSort][1]#</option>
                    </cfloop>
					</SELECT>
					</cfoutput>
                    <!--- D17605 [end] 12/3/08 RBL (1 of 2) --->
					</TD>
					<TD NOWRAP ALIGN="left">
					<strong>Order</strong><BR>
					<CFPARAM NAME="FORM.sort_Order" DEFAULT="DESC">
					<SELECT ID="sort_Order" NAME="sort_Order">
						<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
						<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
					</SELECT>
					</TD>
					<TD ALIGN="right" valign="bottom" NOWRAP>
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search deviations</a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
					<TD ALIGN="left"  valign="bottom" NOWRAP>
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="apply_deviations.cfm">reset</a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
				</tr>
			</table>
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>

<CFIF URL.RecalcNow EQ 1>
	<CFSET FORM.DOSEARCH = 1>
</CFIF>

<CFIF isdefined("FORM.DOSEARCH")>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFSET sql_Sort_By="dbo.BB_Adjustment.Adjustment_Amount">
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Payable Number">
		<CFSET sql_Sort_By="dbo.Billback.BB_Code">
	</CFCASE>
	<CFCASE value="Adjustment Amount">
		<CFSET sql_Sort_By="dbo.BB_Adjustment.Adjustment_Amount">
	</CFCASE>
	<CFCASE value="Distributor Name">
		<CFSET sql_Sort_By="dbo.BSA_Foodservice_Customers.Name">
	</CFCASE>
	<CFCASE value="Billback Date">
		<CFSET sql_Sort_By="dbo.Billback.BB_Date">
	</CFCASE>
	<CFCASE value="Hidden">
		<CFSET sql_Sort_By="dbo.BB_Adjustment.Hidden">
	</CFCASE>
	<CFCASE value="Ignore">
		<CFSET sql_Sort_By="dbo.BB_Adjustment.Ignore">
	</CFCASE>
	<CFCASE value="Recalculate">
		<CFSET sql_Sort_By="dbo.BB_Adjustment.Recalculate">
	</CFCASE>
	<CFCASE value="Apply">
		<CFSET sql_Sort_By="dbo.BB_Adjustment.Recalculate,dbo.BB_Adjustment.Ignore,dbo.BB_Adjustment.Hidden">
	</CFCASE>
</CFSWITCH>


<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>
<!---
	There is no field to order for the "Apply" So we try to reverse sort the others so that
	"Apply" column will be ordered correctly.
--->
<cfif Form.sort_by EQ "Apply" AND sql_Sort_By_Order EQ " DESC">
	<CFSET sql_Sort_By="dbo.BB_Adjustment.Recalculate ASC,dbo.BB_Adjustment.Ignore ASC,dbo.BB_Adjustment.Hidden">
	<cfset sql_Sort_By_Order = " ASC">
<cfelseif Form.sort_by EQ "Apply" AND sql_Sort_By_Order EQ " ASC">
	<cfset sql_Sort_By_Order = " DESC">
	<CFSET sql_Sort_By="dbo.BB_Adjustment.Recalculate DESC,dbo.BB_Adjustment.Ignore DESC,dbo.BB_Adjustment.Hidden">
</cfif>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
        <cfif form.Date_Operator neq "" and  form.BB_Date neq "">
	<cfset TheQuery = BillbackApplyDeviations.searchDeviations(
	form.Customer_Info,
	form.Billback_Info,
	form.BB_Analyst_ID,
	sql_Sort_By,
	sql_Sort_By_Order,
	form.Deviation_Status,
	form.Date_Operator,
	form.BB_Date
	)>
        <cfelse>
	<cfset TheQuery = BillbackApplyDeviations.searchDeviations(form.Customer_Info,form.Billback_Info,form.BB_Analyst_ID,sql_Sort_By,sql_Sort_By_Order,form.Deviation_Status)>
        </cfif>

	<BR>

	<FIELDSET STYLE="padding:5px; border: 1px solid Blue; width: <cfoutput>#Fieldsetwidth#</cfoutput>px;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>deviation<CFELSE>deviations</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> your criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="<cfoutput>#TotalWidth#</cfoutput>" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">

					<cfoutput>
                    <!--- B.) Headers - D17605 [begin] 12/3/08 RBL (2 of 2) --->
                    <cfset HeaderNameList = variables.lsDeviationLabels>
					<cfset HeaderColumnList = variables.lsDeviationCols>
                    <!--- Legacy...
					<CFSET HeaderNameList = "Deviation $,Billback,<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>, BB Age, Apply, Remove, Ignore, Recalc">
					<CFSET HeaderColumnList = "Adjustment Amount,Payable Number,Distributor Name,Billback Date,Apply,Remove,Ignore,Recalc">
					D17605 [end] 12/3/08 RBL (2 of 2) --->
					<CFSET Counter = 1>
					<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
					<CFSET sortImage="">
					<CFIF listgetat(HeaderColumnList,Counter) EQ Form.SORT_BY>
						<CFIF FORM.SORT_ORDER EQ "DESC">
							<CFSET New_Sort_Order="ASC">
							<CFSET sortImage="up_1.gif">
						<CFELSE>
							<CFSET New_Sort_Order="DESC">
							<CFSET sortImage="down_1.gif">
						</CFIF>
						<CFELSE>
							<CFSET New_Sort_Order="DESC">
						</CFIF>
						<TD ID="header" align="left" width="#evaluate("Row#Counter#")#">
						<A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A><br>
						<cfif #this_Header# eq "Apply">
							&nbsp;&nbsp;&nbsp;<input type="radio" name="selectall" id="selectall_0" value="1" onclick="javascript:massUpdateCheckAll(0);" title="Show All Settings">
						<cfelseif #this_Header# eq "Remove">
							&nbsp;&nbsp;&nbsp;<input type="radio" name="selectall" id="selectall_1" value="1" onclick="javascript:massUpdateCheckAll(1);" title="Show All Settings">
						<cfelseif #this_Header# eq "Ignore">
							&nbsp;<input type="radio" name="selectall" id="selectall_2" value="1" onclick="javascript:massUpdateCheckAll(2);" title="Show All Settings">
						<cfelseif #this_Header# eq "Recalc">
							&nbsp;<input type="radio" name="selectall" id="selectall_3" value="1" onclick="javascript:massUpdateCheckAll(3);" title="Show All Settings">
						</cfif>
						</TD>
						<CFSET Counter = Counter + 1>
						</CFLOOP>
					</cfoutput>

				</TR>
			</table>

			<cfif TheQuery.recordcount GT 10>
				<cfset divHght = "height:300px;" />
				<cfset divTableWidth = "680" />
			<cfelse>
				<cfset divHght = "" />
				<cfset divTableWidth = "680" />
			</cfif>
			 <cfoutput> <DIV STYLE="position:relative;overflow:auto;#divHght#"></cfoutput>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="<cfoutput>#TotalWidth#</cfoutput>" CLASS="Maintable">
			<Cfset Deviation_List = "">
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
			<cfset Deviation_List = listappend(Deviation_List,BB_Adjustment_ID)>
			<cfset SafeAdjustmentID = replace(BB_Adjustment_ID, "-", "_", "all")>

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> id='#BB_Adjustment_ID#'>

					<td valign="top" width="#Row1#">#lscurrencyformat(Adjustment_Amount)#</td>
					<td valign="top" width="#Row2#"><a href="/billbacks/capture/bb_preview.cfm?BBID=#Billback_ID#" target="preview_window">#BB_Code# (#BB_Title#)</a>
					<br>
					<a href="/billbacks/claimsummary_report.cfm?Billback_ID=#Billback_ID#" style="color:RGB(0,0,0)" id="previewlink" target="preview_window">Deviations</a>
					<cfif len(trim(Updated_By)) GT 0>
					(#Updated_By# #dateformat(Last_Updated_Date, 'mm/dd/yyyy')#)
					</cfif>
					</td>
					<td valign="top" width="#Row3#">#Distributor_Name# (#Ship_To#)</td>
					<td valign="top" width="#Row4#">#Billback_Age# days<br>#Dateformat(BB_Date, 'mm/dd/yyyy')#</td>
					<cfif Applied IS 0 AND Deleted IS 0>
					<td valign="top" width="#Row5#"><input type="radio" name="BB_Adjustment_#SafeAdjustmentID#" id="#BB_Adjustment_ID#_0" value="0" title="Apply" checked></td>
					<td valign="top" width="#Row6#"><input type="radio" name="BB_Adjustment_#SafeAdjustmentID#" id="#BB_Adjustment_ID#_1" value="1" title="Remove"   <cfif Hidden IS 1> checked</cfif>></td> <!--- onClick="ShowWarningMessage('#Adjustment_Amount#')" --->
					<td valign="top" width="#Row7#"><input type="radio" name="BB_Adjustment_#SafeAdjustmentID#" id="#BB_Adjustment_ID#_2" value="2" title="Ignore" <cfif Ignore IS 1>checked</cfif>></td>
					<td valign="top" width="#Row8#"><input type="radio" name="BB_Adjustment_#SafeAdjustmentID#" id="#BB_Adjustment_ID#_3" value="3" title="Recalculate" <cfif Recalculate IS 1>checked</cfif>></td>


					<cfelseif Deleted IS 1>
					<td colspan="4" valign="top" width="#FourColumnWidth#">Deleted</td>
					<cfelse>
					<td colspan="4" valign="top"  width="#FourColumnWidth#">Applied</td>
					</cfif>
				</TR>
			</CFOUTPUT>
			</TABLE>
			</div>
			<input type="hidden" name="DeviationList" value="<cfoutput>#Deviation_List#</cfoutput>">

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

			<TABLE border="0" cellspacing="0" cellpadding="3" align="center">
			<TR>
			<TD>
			&nbsp; &nbsp;
			<CF_button
			button_name		=	""
			button_caption	=	"save this page"
			button_action	=	"saveSelections();"
			button_type		=	"javascript_link"
			button_width	=	"75"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			></TD>
			<TD>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<CF_button
			button_name		=	""
			button_caption	=	"recalc now"
			button_action	=	"RecalcNow();"
			button_type		=	"javascript_link"
			button_width	=	"75"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			></TD>
			<TD>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<CF_button
			button_name		=	""
			button_caption	=	"#lcase("#application.appSettingsGet.getDeviationLabel()# report")#"
			button_action	=	"showDeviationReport();"
			button_type		=	"javascript_link"
			button_width	=	"75"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			></TD>
			</TR>
			</TABLE>
			</DIV>

		</CFIF>
	</FIELDSET>
<INPUT TYPE="Hidden" NAME="Billback_ID_List" VALUE="<CFOUTPUT>#Valuelist(TheQuery.Billback_ID)#</CFOUTPUT>">

</CFIF>

</blockquote>
                
<CFOUTPUT>
<input type="hidden" name="blnSubmit" value="0">
<input type="hidden" name="WarningMessage" value="0">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="nav_index" VALUE="#nav_index#">
 </CFOUTPUT>
</FORM>

<cfinclude template="/common_files/jQuery.cfm">
<script>
function massUpdateCheckAll(vRadio)
{
	var aRowAmt = document.getElementById('selectall_' + vRadio).checked;
	var aRowAmt0 = document.getElementById('selectall_0');


	if (document.getElementById('selectall_' + vRadio).checked == true)
	{
		for (var i=0; i<4; i++)
		{
			if(i != vRadio) {
				document.getElementById('selectall_'+i).checked =false;
			}

		}
		$('input:checked').each(function(){
			var sRowID = $(this).closest('tr[id]').attr('id');
			var sRowID = sRowID+"_"+vRadio;
			$("#" + sRowID).attr("checked", "checked");
      		 });
	}
}
</script>
</cfmodule>