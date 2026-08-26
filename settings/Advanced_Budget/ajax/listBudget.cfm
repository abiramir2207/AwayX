<!---------------------------------------------------------------------------------------------------------------------
	  Template: \settings\Advanced_Budget\ajax\listBudget.cfm
	  Date:     2014 Feb
	  Author:   Chris Nguyen
	  Purpose:  aJax processing for list of budgets

	  Remarks:  Columns information ( position starts with zero due to javaScript/aJax )
				   0 = Code
				   1 = Description
				   2 = Class
				   3 = Group
				   4 = Type
				   5 = Segment (only when segment is enabled)
				   6 = Budget
				   7 = Committed
				   8 = Actual
				   9 = Action

	  Required parameters:
					URL.segmentIsOn
					URL.userBusinessSegments
					URL.byClassIDs
					URL.byGroupIDs
					URL.byBudgetTypeIDs
					URL.bySegmentIDs
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="100">
  <cfparam name="url.sEcho"           default="10">
  <cfparam name="url.iSortCol_0"      default="0">
  <cfparam name="url.SSORTDIR_0"      default="asc">

  <cfscript>
	reply = {};

	page_size   = val(url.iDisplayLength);
	if ( page_size eq -1) {
	  start_row   = 1;
	  end_row     = -1;
	}
	else {
	  start_row   = url.iDisplayStart + 1;
	  end_row     = url.iDisplayStart + page_size;
	}
	url.sSearch = trim(url.sSearch);
	unknown     = 'unknown';
	dSearch     = ( isDate(url.sSearch) ? dateFormat(parseDateTime(url.sSearch),'short') : unknown );

	// parse search string into an array of words
	if ( len(url.sSearch) ) {
	  arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
	}
	else {
	  arrayOfWords = [];
	}
	// concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
	listOfWords        = arrayToList(arrayOfWords, "%");
	url.iSortCol_0     = val(url.iSortCol_0);
	appSettings        = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	qGetCreateBudget   =  CreateObject("component", "components.user.profile").getCreateViewBudgetSetting(request.Accessstructure.Profiles_ID);
	businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
  </cfscript>

  <cfoutput>
  <cfquery name="qRows" datasource="#application.datasource#">
	SELECT  DISTINCT
			b.Budget_ID
		   , b.Budget_Code
		   , b.Budget_Desc
		   , b.Active
		   , b.Budget_Status
		   , ISNULL(b.Budget_Dollar, 0) AS Budget_Dollar
		   , ISNULL(b.Committed_Dollar, 0) AS Committed_Dollar
		   , ISNULL(b.Actual_Dollar, 0) AS Actual_Dollar
		   , bcft.Contribution_Factor_Type
		   , bcft.Budget_Contribution_Factor_Type_ID
		   , bc.Budget_Class_Desc
		   , bg.Budget_Group_Desc
		   , bs.Business_Unit_Desc
		   , ISNULL(b.Added_From_Number, '') as Added_From_Number
	  FROM Budget b
			<cfif businessSegManager.getClassCodesOn()>
				INNER JOIN Class_Code ON b.business_segment_id  = Class_Code.Business_Segment_ID
				INNER JOIN User_Class_Code ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_Id
				AND User_Class_Code.User_ID = '#request.AccessStructure.User_ID#'
				AND User_Class_Code.Deleted = 0
			<cfelseif URL.segmentIsOn eq '1' and URL.userBusinessSegments eq '1'>
					INNER JOIN User_Business_Segment ubs
					  ON ubs.Business_Segment_Id = b.Business_Segment_Id
						  AND ubs.Deleted = 0
						  AND ubs.User_Id = '#request.AccessStructure.User_ID#'
			</cfif>
			LEFT JOIN Budget_Class bc ON b.Budget_Class_ID = bc.Budget_Class_ID
			LEFT JOIN Budget_Contribution_Factor_Type bcft ON b.Budget_Contribution_Factor_Type_ID = bcft.Budget_Contribution_Factor_Type_ID
			LEFT JOIN Budget_Group bg ON b.Budget_Group_ID = bg.Budget_Group_ID
			LEFT JOIN Business_Segment bs ON b.business_segment_id = bs.business_segment_id
	 WHERE b.Deleted = 0

			<cfif len(trim(url.byClassIDs))>
			  AND b.budget_Class_ID in ( <cfqueryparam value="#url.byClassIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>
			 <cfif len(url.sSearch)>
				AND (    b.Budget_Code LIKE '%#listOfWords#%'
					  OR b.Budget_Desc LIKE '%#listOfWords#%'
					  OR bc.Budget_Class_Desc LIKE '%#listOfWords#%'
					  OR bg.Budget_Group_Desc LIKE '%#listOfWords#%'
					  OR bcft.Contribution_Factor_Type LIKE '%#listOfWords#%'
					  <cfif URL.segmentIsOn eq '1'>
						OR bs.Business_Unit_Desc LIKE '%#listOfWords#%'
					  </cfif>
					)
			 </cfif>

		  <cfif len(trim(url.byBudgetCodes))>
		 		AND b.Budget_Code in ( <cfqueryparam value="#url.byBudgetCodes#" cfsqltype="cf_sql_varchar" list="yes"> )
		  </cfif>
		  
			<cfif len(trim(url.byGroupIDs))>
			  AND bg.Budget_Group_ID in ( <cfqueryparam value="#url.byGroupIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>
			
			<cfif len(trim(url.byBudgetTypeIDs))>
			  AND bcft.Budget_Contribution_Factor_Type_ID in ( <cfqueryparam value="#url.byBudgetTypeIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>

			<cfif len(trim(url.bySegmentIDs))>
			  AND bs.Business_Segment_ID in ( <cfqueryparam value="#url.bySegmentIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>

	<cfswitch expression="#url.iSortCol_0#">
	  <cfcase value=1> ORDER BY b.Budget_Code #url.sSortDir_0# </cfcase>
	  <cfcase value=2> ORDER BY b.Budget_Desc #url.sSortDir_0# </cfcase>
	  <cfcase value=3> ORDER BY bc.Budget_Class_Desc #url.sSortDir_0# </cfcase>
	  <cfcase value=4> ORDER BY bg.Budget_Group_Desc #url.sSortDir_0# </cfcase>
	  <cfcase value=5> ORDER BY bcft.Contribution_Factor_Type #url.sSortDir_0# </cfcase>
	</cfswitch>

	<cfif url.iSortCol_0 gt 5>
	  <cfif URL.segmentIsOn eq '1'>
		 <!--- segment is on - segment column exists --->
		<cfswitch expression="#url.iSortCol_0#">
		  <cfcase value=6> ORDER BY bs.Business_Unit_Desc #url.sSortDir_0# </cfcase>
		  <cfcase value=7> ORDER BY Budget_Dollar #url.sSortDir_0# </cfcase>
		  <cfcase value=8> ORDER BY Committed_Dollar #url.sSortDir_0# </cfcase>
		  <cfcase value=9> ORDER BY Actual_Dollar #url.sSortDir_0# </cfcase>
		</cfswitch>
	  <cfelse>
		<!--- segment is off - segment column does NOT exists --->
		<cfswitch expression="#url.iSortCol_0#">
		  <cfcase value=6> ORDER BY Budget_Dollar #url.sSortDir_0# </cfcase>
		  <cfcase value=7> ORDER BY Committed_Dollar #url.sSortDir_0# </cfcase>
		  <cfcase value=8> ORDER BY Actual_Dollar #url.sSortDir_0# </cfcase>
		</cfswitch>
	  </cfif>
	</cfif>   <!--- url.iSortCol_0 gt 4 --->
  </cfquery>

  </cfoutput>

  <!---get total number of records BEFORE filtering--->
  <cfif len(url.sSearch) eq 0>
	<!--- no filtering so grap the count from existing query --->
	<cfset reply.iTotalRecords = qRows.recordCount>
  <cfelse>
	<cfquery name="totalBeforeFilter" datasource="#application.datasource#">
		  SELECT COUNT(1) AS rownbr
		  FROM Budget b
		 WHERE b.Deleted = 0
			<cfif len(trim(url.byClassIDs))>
			  AND b.budget_Class_ID in ( <cfqueryparam value="#url.byClassIDs#" cfsqltype="cf_sql_integer" list="yes"> )
			</cfif>
	</cfquery>
	<cfset reply.iTotalRecords = totalBeforeFilter.rownbr>
  </cfif>
  <cfset reply.iTotalDisplayRecords = qRows.recordCount>

  <!--- Generate JSON from Query --->
  <cfset reply.aaData = [] >
  <cfif end_row eq -1>
	<cfset start_row = 1>
	<cfset end_row   = qRows.recordCount>
  <cfelse>
	<cfset end_row   = min(end_row, qRows.recordCount)>
  </cfif>

  <cfoutput>
  <cfloop query="qRows" startRow="#start_row#" endRow="#end_row#">
	<cfscript>
	  dArrayTmp = [];

	  if ( qRows.active )
		toggleActive = "deactivate";
	  else if ( (qRows.budget_status eq "validated") or (qRows.budget_status eq "calculated") or (qRows.Budget_Contribution_Factor_Type_ID eq 3) )
		toggleActive = "activate";
	  else
		toggleActive = "";

	  if ( qRows.Budget_Contribution_Factor_Type_ID == 2)
		showcalculate = "1";
	  else
		showcalculate = "0";

	  if ( qRows.Budget_Contribution_Factor_Type_ID == 1)
		showFixedEdit = "1";
	  else
		showFixedEdit = "0";

	  arrayAppend(dArrayTmp, '<input type="checkbox" name="chkBudgetID" value="#qRows.Budget_ID#"     class="cb">');
	  arrayAppend(dArrayTmp, qRows.Budget_Code);
	  arrayAppend(dArrayTmp, qRows.Budget_Desc);
	  arrayAppend(dArrayTmp, qRows.Budget_Class_Desc);
	  arrayAppend(dArrayTmp, qRows.Budget_Group_Desc);
	  arrayAppend(dArrayTmp, qRows.Contribution_Factor_Type);

	  if ( url.segmentIsOn eq '1')
	   arrayAppend(dArrayTmp, qRows.Business_Unit_Desc);

	  arrayAppend(dArrayTmp, DollarFormat(qRows.Budget_Dollar));

	  cellContent = DollarFormat(qRows.Committed_Dollar);
	  if ( qRows.Committed_Dollar neq 0 ) {
		cellContent = '<a href="committed.cfm?budget_id=#qRows.budget_id#&byClassIDs=#trim(url.byClassIDs)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&bySearch=#trim(url.bySearch)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#
" class="rpt">' & cellContent & '</a>';
	  }
	  arrayAppend(dArrayTmp, cellContent & displayBalance(qRows.Budget_Dollar - qRows.Committed_Dollar));

	  cellContent = DollarFormat(qRows.Actual_Dollar);
	  if ( qRows.Actual_Dollar neq 0 ) {
		cellContent = '<a href="actual.cfm?budget_id=#qRows.budget_id#&byClassIDs=#trim(url.byClassIDs)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&bySearch=#trim(url.bySearch)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#
" class="rpt">' & cellContent & '</a>';
	  }
	  arrayAppend(dArrayTmp, cellContent & displayBalance(qRows.Budget_Dollar - qRows.Actual_Dollar));
	</cfscript>

	<cfif qGetCreateBudget.Create_Budget eq 1 AND qRows.Added_From_Number eq "">
	  <cfsavecontent variable="cellContent">
			<a href="javascript:editbudget(#qRows.budget_id#,#qRows.Budget_Contribution_Factor_Type_ID#)" class="action">
				#application.util.string.actionLinkFormat("edit &nbsp;")#
			</a>
			<a href="javascript:deletebudget(#qRows.budget_id#, '#qRows.budget_code#', #Val(qRows.Committed_Dollar)#, #Val(qRows.Actual_Dollar)#)" class="action">
				#application.util.string.actionLinkFormat("delete")#
			</a>
			<cfif showcalculate eq 1 AND appSettings.get_Setting('Accrual_Budgets_Calculation_By_Client') neq '1'>
				<a href="javascript:window.location='index.cfm?command=calculateAccrual&calculate=1&budget_id=#qRows.budget_id#&calculateActionLink=1&byClassIDs=#trim(url.byClassIDs)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&bySearch=#trim(url.bySearch)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#
';" class="action">
					#application.util.string.actionLinkFormat("calculate")#
				</a>
			</cfif>
			<br><a href="javascript:copybudget(#qRows.budget_id#)" class="action">#application.util.string.actionLinkFormat("copy")#</a>
	</cfsavecontent>
	</cfif>

	<cfif not (qGetCreateBudget.Create_Budget eq 1 AND qRows.Added_From_Number eq "")>
		<cfsavecontent variable="cellContent">
				<a href="javascript:viewbudget(#qRows.budget_id#,#qRows.Budget_Contribution_Factor_Type_ID#)" class="action">
					#application.util.string.actionLinkFormat("view")#
				</a>
				<cfif showcalculate eq 1 AND appSettings.get_Setting('Accrual_Budgets_Calculation_By_Client') neq '1'>
					<a href="javascript:window.location='index.cfm?command=calculateAccrual&calculate=1&budget_id=#qRows.budget_id#&calculateActionLink=1&byClassIDs=#trim(url.byClassIDs)#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#trim(url.byGroupIDs)#&bySearch=#trim(url.bySearch)#&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#&bySegmentIDs=#trim(url.bySegmentIDs)#
';" class="action">
						#application.util.string.actionLinkFormat("calculate")#
					</a>
				</cfif>
		</cfsavecontent>
	</cfif>

	<cfif len(toggleActive) AND qGetCreateBudget.Create_Budget eq 1 AND qRows.Added_From_Number eq "">
		<cfsavecontent variable="cellContent">
			#cellContent#
			<a href="javascript:#toggleActive#(#qRows.budget_id#, '#qRows.budget_code#', #Val(qRows.Committed_Dollar)#, #Val(qRows.Actual_Dollar)#)" class="action">
				#application.util.string.actionLinkFormat(toggleActive)#
			</a>
		</cfsavecontent>
	</cfif>

	<cfscript>
	  arrayAppend(dArrayTmp, cellContent);
	  arrayAppend(reply.aaData, dArrayTmp);
	</cfscript>
  </cfloop>
  </cfoutput>

  <cfscript>
	reply.sEcho = javacast('int', url.sEcho);
	sOut        = SerializeJSON( reply );
	sOut        = Replace (sOut, 'SECHO', 'sEcho', 'one');
	sOut        = Replace (sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
	sOut        = Replace (sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');
	sOut        = Replace (sOut, 'AADATA', 'aaData', 'one');
  </cfscript>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#sOut#</cfoutput>
</cfprocessingdirective>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="displayBalance" output="true">
  <cfargument name="balance" required="true">

  <cfset local.content = DollarFormat( arguments.balance )>
  <cfif arguments.balance lt 0>
	<cfsavecontent variable="local.content"><span class="neg">#local.content#</span></cfsavecontent>
  </cfif>

  <cfreturn "<br/>&laquo; " & local.content>
</cffunction>
