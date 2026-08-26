<!DOCTYPE HTML>
<html>
<head></head>
<cfsilent>
<!---
FILE:
FILENAME: 	billbacks/scorecard/billback_search_result.cfm
CREATED: 	01/24/2008 - RBL
EDITED:		11/17/2008 - RBL

FUNCTIONALITY:
- This template facilitates displaying billback search results...
--->

</cfsilent>

<!------
program_Search_Result.cfm
----->
<!------ D10185 (DRK): Remove Segment Field on Billbacks if client doesn't use that feature.  ----->
<!------ check if business segment is on at the application level ----->
<CFPARAM name="form.IFRAME_Extra_URL" 					default="">
<CFPARAM name="Form.PL_PostSubmit" 						default="">
<CFPARAM name="Form.PL_PreSubmit" 						default="">
<CFPARAM name="Form.PL_Final" 							default="">
<CFPARAM name="form.PL_ImportProducts"  				default="0">
<CFPARAM name="form.PL_ImportAllProducts"  				default="0">
<CFPARAM name="printresults" 							default="0">
<CFPARAM name="url.title"			 					default="">
<CFPARAM name="form.title" 								default="#url.title#">
<CFPARAM name="url.SearchIsConductedFromOtherWindow" 	default="0">
<CFPARAM name="ExcludeLockedBillbacks" 					default="0">

<cfif url.SearchIsConductedFromOtherWindow EQ 1>
	<CFSET Form.IFRAME_Extra_URL = "?SearchIsConductedFromOtherWindow=1">

	<cf_List_Compare List1="#Form.PL_PostSubmit#" List2="#Form.PL_PreSubmit#">

	<cfif listlen(trim(LC_Results1)) GT 0>
		<CFSET Form.PL_Final = listappend(Form.PL_Final, LC_Results1)>
	</cfif>

	<cfif listlen(trim(LC_Results2)) GT 0>
		<cfloop index="x" list="#LC_Results2#">
			<CFSET ItemPosition = listfind(Form.PL_Final, x)>
			<cfif ItemPosition NEQ 0>
				<cfset Form.PL_Final = listdeleteAt(Form.PL_Final, ItemPosition)>
			</cfif>
		</cfloop>
	</cfif>

</cfif>

<cfif form.PL_ImportProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#Form.PL_Final#';
		window.close();
	</script>
	</cfoutput>
<cfabort>
</cfif>

<cfif form.PL_ImportAllProducts EQ 1>
	<cfoutput>
	<script>
		window.parent.returnValue = '#form.PL_AllProductList#';
		window.close();
	</script>
	</cfoutput>
</cfif>

<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>

<CFINCLUDE TEMPLATE="billback_Table_Measures.cfm">

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent; overflow-x: hidden;" allowTransparency="true">
<cfset variables.savedRequestFileName = application.util.io.TempFileName( prefix='object_save' )>
<CFIF isdefined("FORM.DOSEARCH")>

<cfif NOT isDefined("MATCHCentral")>
 <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
</cfif>
<!--- <CFFLUSH> D17544 RBL 11/17/08 --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<!------<CFPARAM NAME="FORM.ProgramType" DEFAULT="0">----->

<CFPARAM NAME="FORM.UP" DEFAULT="0">
<CFPARAM NAME="FORM.PNF" DEFAULT="0">
<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
<CFPARAM NAME="FORM.Status" DEFAULT="0">
<CFPARAM NAME="FORM.Programs" DEFAULT="0">
<cfparam name="FORM.Payee_Filter" 	default="Broker">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Bill_To_ID" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_ID" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
<cfparam name="FORM.Billback_Number" 	default="">
<cfparam name="FORM.Payable_Number" 	default="">
<CFPARAM NAME="FORM.Amount_Operator" DEFAULT="">
<cfparam name="FORM.Amount" 	default="">
<CFPARAM NAME="FORM.Date_Operator" DEFAULT="">
<cfparam name="FORM.BB_Date_Type" 	default="">
<cfparam name="FORM.BB_Date" 	default="">
<CFPARAM NAME="FORM.Start_Date_Operator" DEFAULT="">
<cfparam name="FORM.Start_Date" 	default="">
<CFPARAM NAME="FORM.Billback_Title" DEFAULT="">
<CFPARAM NAME="FORM.End_Date_Operator" DEFAULT="">
<cfparam name="FORM.End_Date" 	default="">
<cfparam name="FORM.BB_Aging" 	default=0>
<CFPARAM NAME="FORM.Contract_Number" 	DEFAULT="">
<cfparam name="AlreadySelected" default="">
<cfparam name="form.PP_User_ID" default="">
<CFPARAM NAME="FORM.User_Position_Operator" DEFAULT="=">
<CFPARAM NAME="FORM.BB_Closing_Method" DEFAULT="">
<cfparam name="Form.Include_Eligible_Programs" 	default="">
<CFPARAM NAME="Form.Deviated" Default="0">
<cfparam name="Form.referenceNum" default="" />
<cfparam name="form.user_Position" default="" />
<cfparam name="form.user_Position_of" default="" />
<cfparam name="form.program_status" default="" />
<cfparam name="MATCHCentral" default="false" />
<cfparam name="HideAllSplitBB" default="false" />
<cfparam name="filterAmount" default="true" />
<cfparam name="matchToCredit" default="false" />
<cfparam name="FORM.MC_Shr_Ship_to" default="" />
<cfparam name="FORM.MC_Distributor_Name" default="" />
<cfparam name="FORM.MC_Bill_To_Name" default="" />
<cfparam name="FORM.MC_Shr_Bill_To" default="" />
<cfparam name="FORM.Check_Number" 	default="">

<!--- temp hack fixes --->
<cfparam name="form.soldToNo" default="" />
<cfparam name="form.operatorid" default="" />
<cfparam name="form.vendorid" default="" />

<CFPARAM NAME="FORM.TITLE" DEFAULT="#url.title#">

<CFPARAM NAME="Form.ShowIncompleteBillbacks" default="0">
<CFPARAM NAME="Form.Uploaded_Billback" default="0">
<cfparam name="form.Search_Filter_Analyst_User_ID" default="" />

<cfparam name="url.Type_search" default=""><!---D30516:Element TYPE_SEARCH is undefined in URL --->
<CFPARAM NAME="Form.Program_Template" default="0">
<CFSET Table_Width=750>


<CFINCLUDE TEMPLATE="unlock_billbacks.cfm">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFINCLUDE TEMPLATE="../../billbacks/Billback_Access_Permission.cfm">
<!---------------------------------------------------
Access Permission End
---------------------------------------------------->

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<cfsilent>

	<!--- D17544 RBL 11/17/08 [begin] --->
    <cfparam name="form.sort_by" 		default="#Default_Sort#">
    <cfparam name="form.sort_order" 	default="#Default_Sort_Order#">
    <!--- <CFPARAM NAME="FORM.SORT_BY" DEFAULT="#Default_Sort#">
    <cfparam name="FORM.SORT_ORDER" 	default="#Default_Sort_Order#">
    --->

    <!--- <CFSET sql_Sort_By="dbo.billback.Billback_ID"> --->

    <!---How the data is sorted--->
    <cfswitch expression="#form.sort_by#">
        <!---Billback number--->
        <cfcase value="BBI">
            <cfset sql_Sort_By="dbo.Billback.BB_Code">
        </cfcase>
        <!---Billback number--->
        <cfcase value="BBNUM">
            <cfset sql_Sort_By="dbo.Billback.BB_Reference">
        </cfcase>
        <!---Billback title--->
        <cfcase value="BBT">
            <cfset sql_Sort_By="dbo.Billback.BB_Title">
        </cfcase>
        <!---Billback title--->
        <cfcase value="Pay">
            <cfset sql_Sort_By="Payee_Name">
        </cfcase>
        <!---Billback Date--->
        <cfcase value="BBD">
            <cfset sql_Sort_By="dbo.Billback.BB_Date">
        </cfcase>
        <!---Billback Start Date--->
        <cfcase value="BBSD">
            <cfset sql_Sort_By="dbo.Billback.BB_Start_Date">
        </cfcase>
        <!---Billback End Date--->
        <cfcase value="BBED">
            <cfset sql_Sort_By="dbo.Billback.BB_End_Date">
        </cfcase>
        <!---Billback Amount--->
        <cfcase value="BBA">
            <cfset sql_Sort_By="dbo.Billback.BB_Amount">
        </cfcase>
        <!---Deviation Amount--->
        <cfcase value="BBDev">
            <cfset sql_Sort_By="dbo.Billback.BB_Deviation">
        </cfcase>
        <!--- sort by segment --->
        <cfcase value="BBSE">
            <cfset sql_Sort_By="business_unit_desc">
        </cfcase>
        <cfcase value="BBSTAT">
            <cfset sql_Sort_By="Billback.Billback_Status_ID">
        </cfcase>
        <cfcase value="BBDEVIATED">
            <cfset sql_Sort_By="Billback.Deviated">
        </cfcase>
        <cfcase value="BBCLOSURE">
            <cfset sql_Sort_By="Billback.BB_Closing_Method">
        </cfcase>
        <cfcase value="BBApprovedAmount">
            <cfset sql_Sort_By="BB_Approved.BB_Approved_Amount">
        </cfcase>
        <cfcase value="BBREFN">
            <cfset sql_Sort_By="Billback.referenceNum">
        </cfcase>
        <cfcase value="BBANA">
            <cfset sql_Sort_By="BBanalyst.Name_Last">
        </cfcase>
        <cfdefaultcase>
            <cfset sql_Sort_By="dbo.billback.Billback_ID">
        </cfdefaultcase>
    </cfswitch>

    <cfif form.sort_order EQ "DESC">
        <cfset sql_Sort_By="#sql_Sort_By# DESC">
    <cfelse>
        <cfset sql_Sort_By="#sql_Sort_By# ASC">
    </cfif>
    <cfif form.source EQ "Deductions"><!------ If from deduction ----->
        <cfif appSettings.getMatch_BB_DD_Based_On_Same_ReferenceNum()><!------ If Deduction - Billback Association Based on Same Reference Num = 1 ----->
            <cfif form.sort_by NEQ "BBNUM">
                <cfset sql_Sort_By="Billback.BB_Reference ASC, #sql_Sort_By#">
            </cfif>
        </cfif>
    </cfif>

</cfsilent>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<cfinclude template="deduction_age.cfm">

<!--- some case sensitivity changes applied above as well as adding a defaultcase at end of switch INSTEAD of the set at the top of the switch.
It appears that this is the behavior desired but coded incorrectly prior. RBL
D17544 RBL 11/17/08 [end] --->

<!--- D17544 RBL 11/17/08 [begin]
IMPORTANT: we have created a new BillbackSearch.cfc which will be cached as application.oBillbackSearch
and employed in all Billback searches to improve performamce. We will pass an argument collection to it's method -
searchBillbacks() consisting of all 'variables' scopes vars first, and then all'form' scoped vars second (overwriting).
Selected request scope vars were also considered if needed but we should not grab all of the request scope due to the fact
that multiple copies of appSettings are in multiple scopes.
Below will be commented out for presentation purposes but should eventually go away. The appsettings should get addressed at some point. RBL
--->

<!--- TODO: remove this next line --->
<cfif isDefined("application.oBillbackSearch")>  <cfset structDelete(application,"oBillbackSearch")>  </cfif>

<cfscript>
	request.stSearch = structNew();
	// 1 variables
	structAppend(request.stSearch,variables,true);
	// 2 form
	structAppend(request.stSearch,form,true);
	// 3 specific variables var
	structInsert(request.stSearch,'appsettings',variables.appSettings,true);

	application.oController.getObject("components.Billback.BillbackSearch").init();
</cfscript>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
D17544 let's persist a really important objects for our billback searching... [begin]
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- application.oBillbackSearch --->
<!---
	******** TO REMOVE THE BILLBACK SEARCH STRUCT IF YOU MADE CHANGES TO THE SEARCH QUERY, UNCOMMENT THIS CFSET TAG

	<cfset structDelete(application,"oBillbackSearch")>
--->


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
D17544 let's persist a really important objects for our billback searching...   [end]
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cfparam name="FORM.startrow" 	default="1">
<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
<cfparam name="FORM.pageLength" 	default=100>

<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cfset max_length = 100 />

<cf_Number_of_Rows maxrows="#max_length#">

<!---
// save search criteria onto a file :: it
--->

<cfif NOT MATCHCentral>
	<!--- <cfdump var="#request.stSearch#" abort="true"> --->
	<cfscript>
		objectSave(request.stSearch, variables.savedRequestFileName);
	</cfscript>
	<cfset request.stSearch.startrow = startrow />
	<cfset request.stSearch.endrow = startrow + max_length - 1 />
</cfif>

<cfinvoke
	component="#application.oBillbackSearch#"
	method="searchBillbacks"
    argumentcollection="#request.stSearch#"
    returnvariable="variables.qBillbackSearchResults">
	<!--- D17544 F&R 11/18/08 RBL --->

	<cfif NOT MATCHCentral>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF variables.qBillbackSearchResults.recordcount GT 0>
			<cfparam name="FORM.startrow" 	default="1">
			<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
			<cfparam name="FORM.pageLength" 	default=7>

			<CFSET startrow=FORM.startrow>
			<CFSET frompage=FORM.frompage>
			<cfif source IS "Deductions">
			<cf_Number_of_Rows maxrows="#variables.qBillbackSearchResults.Recordcount#">
			<cfelse>
			<cf_Number_of_Rows maxrows="20">
			</cfif>

			<cfset variables.record_count = variables.qBillbackSearchResults.record_count />
			<cfif variables.record_count  EQ ''>
				<cfset variables.record_count  = 0 />
				<cfset request.stSearch.startrow  = 0 />
				<cfset request.stSearch.endRow  = 0 />
			</cfif>

			<cfif request.stSearch.endRow GT variables.record_count>
				<cfset request.stSearch.endRow = variables.record_count />
			</cfif>
			<CFSET SC_QUERY=variables.qBillbackSearchResults>

            <!--- IF we do NOT have some schtuff... --->
            <!--- <cfif NOT url.bHaveResults>
            	<cfwindow
                  center="true"
                  closable="false"
                  draggable="true"
                  height=70
                  initShow="true"
                  modal="true"
                  name="billbackSearchResultWindow"
                  resizable="false"
                  source="display_Billback_List.cfm?bHaveResults=1"
                  title="Your Billback Search Results"
                  width=340/> --->
            <!--- </cfif> --->

			<CFINCLUDE TEMPLATE="display_Billback_List.cfm">

			<TABLE WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>"  CELLSPACING="0" CELLPADDING="0" border="0">
				<tr><td colspan="100%" align="center">
			<cfif form.source IS "Deductions">
			<!--- <a HREF="#" onClick="javascript: finishedSearching()"><strong>[ add to deduction ]</strong></a> --->
			<CFIF appSettings.getMultiple_BB_Per_Deduction()>
			<SPAN ID="SP_ASSOCIATE_MULTIPLE_BB_ENABLED" STYLE="DISPLAY:NONE;">
			<CF_smallLink
				title = "add to deduction"
				url = "##"
				parameters = "onClick='javascript: return finishedSearching();'"
			>
			</SPAN>
			<SPAN ID="SP_ASSOCIATE_MULTIPLE_BB_DISABLED" >
			<CF_smallLink
				title = "add to deduction"
				url = "##"
				enabled = 0
			>
			</SPAN>
			<CFELSE>
				<CF_smallLink
				title = "add to deduction"
				url = "##"
				parameters = "onClick='javascript: return finishedSearching();'"
			>
			</CFIF>
</cfif>
<!--- D29824 New Settings.. --->
			<cfif CanDelete EQ 1 AND source IS NOT "Deductions" AND (url.Type_search NEQ "impBillBacks")>

			<CF_smallLink
				title = "delete billbacks"
				url = "##"
				parameters = "onClick='javascript: return deleteSelected();'"
			>

				<cfelseif url.Type_search EQ "impBillBacks">

					<CF_button
							button_name		=	""
							button_caption	=	"Import Billbacks"
							button_action	=	"importbillbacks()"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>

			</cfif>
		</td>
	</tr>
<!--- D29824 New Settings.. --->
			<TR>
			<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<CF_Next_Previous_For_Forms
					formname="MyForm"
					query="variables.qBillbackSearchResults"
					maxpages="30"
					record_count="#variables.qBillbackSearchResults.record_count#"
					previous		=	"<IMG SRC='/images/previous.gif' ALIGN='middle' BORDER='0'>"
					next			=	"<IMG SRC='/images/next.gif' ALIGN='middle' BORDER='0'>"
					previousseries	=	"<IMG SRC='/images/previous_series.gif' ALIGN='middle' BORDER='0'>"
					nextseries		=	"<IMG SRC='/images/next_series.gif' ALIGN='middle' BORDER='0'>"
					addparams="">
			</DIV>
			</TD>
			<TD ALIGN="RIGHT">
			<FONT COLOR="Red" SIZE="2"><B>[<CFOUTPUT>&nbsp;#request.stSearch.startrow# - #request.stSearch.endRow# of #variables.record_count#</CFOUTPUT> <CFIF variables.record_count EQ 1>Billback<CFELSE>Billbacks</CFIF>]</B></FONT>
		</TD>
			</TR>
			</TABLE>
			<SCRIPT LANGUAGE="javaScript">
				function getthisPage(thisObj)
				{
					window.parent.showSearchResult(false, thisObj.startrow.value,thisObj.frompage.value);
					return false;
				}
			</SCRIPT>
			<CFOUTPUT>

			<cfif source IS "Deductions">
			<!--- <FORM ACTION="/billback/scorecard/billback_Search_Result.cfm#form.IFRAME_Extra_URL#&title=#url.title#" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javaScript: return getthisPage(this);"> --->
			<FORM ACTION="/deductions/search_screens/billbacks.cfm" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javaScript: return getthisPage(this);">
			<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
			<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
			<INPUT TYPE="Hidden" NAME="currentBillbackList" VALUE="#form.currentBillbackList#">
			</FORM>
			<cfelse>
			<FORM ACTION="/billbacks/scorecard/program_Search_Result.cfm" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="javaScript: return getthisPage(this);">
			<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
			<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
			</FORM>
			</cfif>


			</CFOUTPUT>
			<Cfif source IS "Deductions">
			<SCRIPT>
				var currentBillbackList = <cfoutput>"#form.currentBillbackList#"</cfoutput>
				function addToSelectedList(selectedBB,passedValue)
				{
					var proceed = 0;
					//add to list
					if(currentBillbackList.length == 0){
							currentBillbackList = selectedBB.value;
							proceed=1
						}
					else{
								if(currentBillbackList.indexOf(selectedBB.value) < 0){
									currentBillbackList = currentBillbackList + ',' + selectedBB.value;
									proceed=1
								}
								else{
									proceed=0
								}
						}
						if (proceed) {
							if (document.all.MyForm.currentBillbackList.value != undefined)
								document.all.MyForm.currentBillbackList.value = currentBillbackList;
							if (window.parent.window.globalCurrentBillbackList != undefined)
								window.parent.window.globalCurrentBillbackList = currentBillbackList;
							if (document.all.SearchForm.currentBillbackList.value != undefined)
								document.all.SearchForm.currentBillbackList.value = currentBillbackList;
							if (document.all.ReturnResults.currentBillbackList.value != undefined)
								document.all.ReturnResults.currentBillbackList.value = currentBillbackList;
							if (document.all.SearchForm.selectedItemValue.value != undefined)
								document.all.SearchForm.selectedItemValue.value = parseFloat(document.all.SearchForm.selectedItemValue.value) + parseFloat(passedValue);
						}
				}

				function removefromSelectedList(selectedBB,passedValue)
				{
					//remove from list
					var tempArray = currentBillbackList.split(",");
					var tempcurrentBillbackList = "";
					document.getElementById("SelectAll").checked = false;

					for(var x=0; x<tempArray.length; x++)	{
						if(tempArray[x] != selectedBB.value)
						{
							if(tempcurrentBillbackList.length == 0){
								tempcurrentBillbackList = tempArray[x];
							}
							else{
								tempcurrentBillbackList = tempcurrentBillbackList + ',' + tempArray[x];
							}

						}
					}

					currentBillbackList = tempcurrentBillbackList;
					if(document.all.MyForm.currentBillbackList.value != undefined)
						document.all.MyForm.currentBillbackList.value = currentBillbackList;
					if(window.parent.window.globalCurrentBillbackList != undefined)
						window.parent.window.globalCurrentBillbackList = currentBillbackList;
					if(document.all.SearchForm.currentBillbackList.value != undefined)
						document.all.SearchForm.currentBillbackList.value = currentBillbackList;
					if(document.all.ReturnResults.currentBillbackList.value != undefined)
						document.all.ReturnResults.currentBillbackList.value = currentBillbackList;
					if(document.all.SearchForm.selectedItemValue.value != undefined)
					document.all.SearchForm.selectedItemValue.value = parseFloat(document.all.SearchForm.selectedItemValue.value) - parseFloat(passedValue);
				}
			</SCRIPT>
			<cfelse>
			<SCRIPT>
				var currentBillbackList = <cfoutput>"#form.currentBillbackList#"</cfoutput>

				function addToSelectedList(selectedBB)
				{
					//add to list
					if(currentBillbackList.length == 0)
						{currentBillbackList = selectedBB.value;}
					else
						{currentBillbackList = currentBillbackList + ',' + selectedBB.value;}

					if(window.parent.SearchForm.currentBillbackList.value != undefined)
						window.parent.SearchForm.currentBillbackList.value = currentBillbackList;

				}

				function removefromSelectedList(selectedBB,passedValue)
				{
					//remove from list
					var tempArray = currentBillbackList.split(",");
					var tempcurrentBillbackList = "";

					for(var x=0; x<tempArray.length; x++)
					{
						if(tempArray[x] != selectedBB.value)
						{
							if(tempcurrentBillbackList.length == 0)
							{
								tempcurrentBillbackList = tempArray[x];
							}
							else
							{
								tempcurrentBillbackList = tempcurrentBillbackList + ',' + tempArray[x];
							}
						}
					}

					currentBillbackList = tempcurrentBillbackList;
					if(window.parent.SearchForm.currentBillbackList.value != undefined)
						window.parent.SearchForm.currentBillbackList.value = currentBillbackList;
				}

				function deleteSelected()
			{
				var allBillbacks = currentBillbackList;
				window.parent.DeleteSelected.BillbacksToDelete.value = allBillbacks;
				window.parent.DeleteSelected.submit();
				return false;
			}


			function addRemoveBillback(thisObj)
			{	var thisAmount = 0

				if(thisObj.checked)
					{
							addToSelectedList(thisObj,thisAmount);
					}
					else
					{
							removefromSelectedList(thisObj,thisAmount);
					}

			}

			</SCRIPT>
			</CFIF>
			<SCRIPT>
			function navigate(frompage, startrow)
			{
				window.parent.showSearchResult(false, startrow,frompage);
				if(window.parent.document.all.DeleteBillbacks)
				{
					window.parent.document.all.DeleteBillbacks.checked = false;
				}
			}
<!--- D70951 :: ‘Please Wait’ Indicator     Release START --->
			parent.document.getElementById("divWait1").style.display='none';
<!--- D70951 :: ‘Please Wait’ Indicator     Release END --->

			<!---
			// display download option after search result is shown
			--->
			window.parent.document.getElementById('dnload012').style.display = 'inline';
			window.parent.document.getElementById('uploadDocs').style.display = 'inline';
			</script>

		<CFELSE>
			<script>
<!--- D70951 :: ‘Please Wait’ Indicator     Release START --->
//				window.parent.clearHandler();
				parent.document.getElementById("divWait1").style.display='none';
<!--- D70951 :: ‘Please Wait’ Indicator     Release END --->

			</script>
			<!--- <BR>
			<FONT COLOR="Red" SIZE="2"><B></B></FONT> --->
			<p style="text-align:center; color:red; font-weight:bold; font-size:12px">
				There are no billbacks that match the above criteria
			</p>
		</CFIF>
	</CFIF>
</CFIF>
<cfinclude template="/common_files/jQuery.cfm">
<!--- D29824 New Settings.. --->
<script>
jQuery.noConflict();
var savedRequestFileName = '<cfoutput>#urlEncodedFormat(variables.savedRequestFileName)#</cfoutput>';
//alert(savedRequestFileName)
function importbillbacks()
{
	var bb_id = "";
  	jQuery("input:checkbox[name=selectedReasons]:checked").each(function()
	{
		   bb_id = bb_id.concat(jQuery(this).val());
		   bb_id = bb_id.concat(',');
	});
 window.parent.importbillbacks(bb_id);
}
</script>
<!--- D29824 New Settings.. --->
<!--- D17544 RBL 11/17/08 [end]
NOTE: from here up, a Find & Replace done as follows: TheQuery > variables.qBillbackSearchResults [Match Case = no, Ignore Whitespace = yes] --->
</BODY>
</html>