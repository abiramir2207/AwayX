<cfsilent>
<!---
FILE:
FILENAME: 	billbacks/scorecard/scorecard_content.cfm
CREATED: 	??/??/???? - ???
EDITED:		04/16/2009 - RBL

FUNCTIONALITY:
- This template is a piece of the display billback search results puzzle...
--->
</cfsilent>

<cfheader name="Cache-Control" value="no-store">
<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="ALL">
<CFPARAM NAME="SHEXP" Default="All">
<CFPARAM NAME="Source" default="Search">
<CFPARAM NAME="URL.filterIds" default="">


<cfinclude template="/get_access_profile.cfm">

<!------ D10185 (DRK): Remove Segment Field on Billbacks if client doesn't use that feature.  ----->
<!------ check if business segment is on at the application level ----->
<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>

<CFINCLUDE TEMPLATE="billback_Table_Measures.cfm">

<!---Section variables--->
<CFPARAM NAME="SECTION_TITLE" DEFAULT="">
<CFPARAM NAME="QUERY_PREFIX" DEFAULT="WIP">
<CFPARAM NAME="SECTION_RECORDCOUNT" DEFAULT="0">
<CFPARAM NAME="SECTION_IMAGE" DEFAULT="WIP.GIF">

<!--- D17544 RBL 11/17/08 [begin] --->
<cfparam name="url.sortBy" 		default="#Default_Sort#">
<cfparam name="url.sortOrder" 	default="#Default_Sort_Order#">
<!--- <CFPARAM NAME="URL.SORTBY" DEFAULT="#Default_Sort#">
<cfparam name="URL.SORTORDER" 	default="#Default_Sort_Order#">
--->

<!--- <CFSET sql_Sort_By="dbo.billback.Billback_ID" --->

<!---How the data is sorted--->
<cfswitch expression="#url.sortBy#">
	<!---Payable number--->
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
	<!---Variance Amount--->
	<cfcase value="BBV">
		<cfset sql_Sort_By="BB_Variance">
	</cfcase>
	<!---Deviation Amount--->
	<cfcase value="BBDev">
		<cfset sql_Sort_By="dbo.Billback.BB_Deviation">
	</cfcase>
	<!---Payment Processor--->
	<cfcase value="PP">
		<cfset sql_Sort_By="ppUsers.Name_Last">
	</cfcase>
	<!--- sort by segment --->
	<cfcase value="BBSE">
		<cfset sql_Sort_By="business_unit_desc">
	</cfcase>
	<cfcase value="BBDEVIATED">
		<cfset sql_Sort_By="Billback.Deviated">
	</cfcase>
	<cfcase value="BBCLOSURE">
		<cfset sql_Sort_By="Billback.BB_Closing_Method">
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

<CFIF url.sortOrder EQ "DESC">
	<CFSET sql_Sort_By="#sql_Sort_By# DESC">
<CFELSE>
	<CFSET sql_Sort_By="#sql_Sort_By# ASC">
</CFIF>

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!--- some case sensitivity changes applied above as well as adding a defaultcase at end of switch INSTEAD of the set at the top of the switch.
It appears that this is the behavior desired but coded incorrectly prior. RBL
D17544 RBL 11/17/08 [end] --->

<!--- <CFFLUSH> D17544 RBL 11/17/08 --->

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFINCLUDE TEMPLATE="unlock_billbacks.cfm">

<!---Gets the current user's position--->
<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">

<CFPARAM NAME="WIP_Count"		DEFAULT="0">
<CFPARAM NAME="RFA_Count"		DEFAULT="0">
<CFPARAM NAME="Approved_Count"	DEFAULT="0">
<CFPARAM NAME="Paid_Count"		DEFAULT="0">
<CFPARAM NAME="Auth_Sequence_ID"	DEFAULT="0">
<CFPARAM NAME="Auth_Sequence_Order"	DEFAULT="0">
<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>
	<CFSET Auth_Sequence_Order = 0>
	<CFSET Auth_Sequence_ID = 0>
	<CFQUERY NAME="AuthoritySeq" DATASOURCE="#Application.Datasource#">
		SELECT Authority_Sequence_Order, Authority_Sequence_ID FROM Authority_Sequence WHERE Authority_Sequence_ID = (SELECT Authority_Sequence_ID FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#')
	</CFQUERY>
	<CFIF AuthoritySeq.recordCount GT 0>
		<CFSET Auth_Sequence_Order = AuthoritySeq.Authority_Sequence_Order>
		<CFSET Auth_Sequence_ID = AuthoritySeq.Authority_Sequence_ID>
	</CFIF>
</CFIF>

<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />

<!--- some case sensitivity changes applied above as well as adding a defaultcase at end of switch INSTEAD of the set at the top of the switch.
D17544 RBL 11/17/08 [end] --->

<!--- D17544 RBL 11/17/08 [begin]
IMPORTANT: we have created a new BillbackSearch.cfc which will be cached as application.oBillbackSearch
and employed in all Billback searches to improve performamce. We will pass an argument collection to it's method -
getScorecardBillbackContent() consisting of all 'variables' scopes vars first, and then all'form' scoped vars second (overwriting).
Selected request scope vars were also considered if needed but we should not grab all of the request scope due to the fact
that multiple copies of appSettings are in multiple scopes.
Below will be commented out for presentation purposes but should eventually go away. The appsettings should get addressed at some point. RBL
--->

<cfscript>
 //structDelete(application,"oBillbackSearch",false); //TESTING
 request.stSearch = structNew();
 // 1 variables
 structAppend(request.stSearch,variables,true);
 // 2 form
 structAppend(request.stSearch,form,true);
 // 3 specific variables var
 structInsert(request.stSearch,'appsettings',variables.appSettings,true);
 // 4 specific URL vars
 structInsert(request.stSearch,'section_to_open',URL.SECTION_TO_OPEN,true);
 structInsert(request.stSearch,'program_agree_status_ID',URL.Program_Agree_Status_ID,true);
 structInsert(request.stSearch,'bbFilterIds',URL.filterIds,true);
 /* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 D17544 let's persist BillbackSearch object via mvc... [begin]
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
 application.oController.getObject("components.Billback.BillbackSearch");
 /* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 D17544 let's persist BillbackSearch object via mvc...  [end]
 :::::::::::::::::::::::::::::::::::::::::::::::::::::::::: */
</cfscript>

<cfparam name="FORM.startrow" 	default="1">
<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
<cfparam name="FORM.pageLength" 	default=100>

<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cfset max_length = 100 />

<cf_Number_of_Rows maxrows="#max_length#">


<cfset request.stSearch.startrow = startrow />
<cfset request.stSearch.endrow = startrow + max_length - 1 />

<cfinvoke
	component="#application.oBillbackSearch#"
	method="getScorecardBillbackContent"
    argumentcollection="#request.stSearch#"
    returnvariable="variables.qScorecardBillbackContent">
<cfset variables.record_count = variables.qScorecardBillbackContent.record_count />
<cfif variables.record_count  EQ ''>
	<cfset variables.record_count  = 0 />
	<cfset request.stSearch.startrow  = 0 />
	<cfset request.stSearch.endRow  = 0 />
</cfif>

<cfif request.stSearch.endRow GT variables.record_count>
	<cfset request.stSearch.endRow = variables.record_count />
</cfif>
<!--- D17544 F&R 11/18/08 RBL --->

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>

<!--- Open layer Options--->
<CFSCRIPT>
	Border="Yes";
	BorderSize=1;
	BorderColor="Silver";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";
	WIDTH="95%";
</CFSCRIPT>

<!---Sort by header--->

<CFSET SCURL="scorecard_detail.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#">

<cfset Section_Number = URL.SECTION_TO_OPEN>



<!---Set section variables--->
<CFIF Section_Number IS 1>
	<cfset SECTION_TITLE="Work In Progress">
<CFELSEIF Section_Number IS 2>
	<cfset SECTION_TITLE="Request for Approval">
<CFELSEIF Section_Number IS 3>
	<cfset SECTION_TITLE="Approved">
<CFELSE>
	<cfset SECTION_TITLE="Paid">
</CFIF>

<!--- This width (Table_Width) is probably not being used, as  "\billbacks\scorecard\billback_table_measures.cfm"
seems to override it.
--->
<CFSET Table_Width=1250>

	<CFSET SC_QUERY=variables.qScorecardBillbackContent>

	<CFINCLUDE TEMPLATE="display_Billback_List.cfm">

	<TABLE WIDTH="98%" CELLSPACING="0" CELLPADDING="0">
	<TR>
		<TD>
		<cfif variables.qScorecardBillbackContent.record_count GT 0>
			<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="variables.qScorecardBillbackContent"
				maxpages="30"
				record_count="#variables.qScorecardBillbackContent.record_count#"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
		</cfif>
		</TD>
		<TD ALIGN="RIGHT">
			<FONT COLOR="Red" SIZE="2"><B>[<CFOUTPUT>&nbsp;#request.stSearch.startrow# - #request.stSearch.endRow# of #variables.record_count#</CFOUTPUT> <CFIF variables.record_count EQ 1>Billback<CFELSE>Billbacks</CFIF>]</B></FONT>
		</TD>
	</TR>
	</TABLE>
<CFOUTPUT>
<FORM ACTION="#CGI.SCRIPT_NAME#?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#<CFIF IsDefined("URL.Program_Agree_Status_ID")>&Program_Agree_Status_ID=#URL.Program_Agree_Status_ID#</CFIF>&SORTBY=#URL.SORTBY#&SORTORDER=#SORTORDER#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="currentBillbackList" VALUE="#form.currentBillbackList#">

</FORM>

<SCRIPT>
			function navigate(frompage, startrow)
			{
				document.all.MyForm.frompage.value = frompage;
				document.all.MyForm.startrow.value = startrow;
				document.all.MyForm.submit();
				if(window.parent.document.all.DeleteBillbacks)
				{
					window.parent.document.all.DeleteBillbacks.checked = false;
				}
			}

			</script>
</CFOUTPUT>


</BODY>
</HTML>

<Script>
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

			function addToSelectedList(selectedBB)
				{
					//add to list
					if(currentBillbackList.length == 0)
						{currentBillbackList = selectedBB.value;}
					else
						{currentBillbackList = currentBillbackList + ',' + selectedBB.value;}

					if(MyForm.currentBillbackList.value != undefined)
						MyForm.currentBillbackList.value = currentBillbackList;

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
					if(MyForm.currentBillbackList.value != undefined)
						MyForm.currentBillbackList.value = currentBillbackList;
				}

				function deleteSelected()
			{
				var allBillbacks = currentBillbackList;
				if (window.confirm("Are you sure you want to delete these billbacks?")){
					window.parent.DeleteSelected.BillbacksToDelete.value = allBillbacks;
					window.parent.DeleteSelected.submit();
				}
				return false;
			}
				<!--- END D11948 code --->
</script>

<cfif source IS NOT "Deductions"  AND (URL.SECTION_TO_OPEN LT 3 OR URL.SECTION_TO_OPEN IS "All")>
	<cfif CanDelete EQ 1>
			<div align="center">
			<CF_smallLink
				title = "delete billbacks"
				url = "##"
				parameters = "onClick=""javascript: return deleteSelected();"""
			>
				</div>
		</cfif>
			</cfif>
