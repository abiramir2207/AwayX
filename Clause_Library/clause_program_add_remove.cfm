<!------ clause_library_add_remove.cfm ----->
<CFOUTPUT>

<script language="JavaScript">
	function submitForm(thisForm, sCommand, orderBy)
	{
		thisForm.orderBy.value = orderBy;
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
</script>

<!---set defaults--->
<cfset formName = "frmClauseAddRemove">
<cfparam name="url.programId" 		default="0">
<cfparam name="form.programId" 		default="#url.programId#">
<cfparam name="url.programTypeId" 	default="0">
<cfparam name="form.programTypeId" 	default="#url.programTypeId#">
<cfparam name="form.state" 			default="0">
<cfparam name="form.lClauseIds" 	default="">
<cfparam name="fieldName" 			default="genOptClauseId">
<cfparam name="form.lReqApproval" 	default="" />
<cfparam name="url.orderBy" 		default="ASC">
<cfparam name="form.orderBy" 		default="#url.orderBy#">
<cfparam name="form.discType_0" 	default="">
<cfparam name="form.isRequiredPgmIds_0" 	default="">
<cfparam name="form.excludeList" 	default="">
<cfparam name="url.orderBy" 	default="ASC">
<cfparam name="form.orderBy" 	default="#url.orderBy#">
<cfparam name="form.ClauseLibraryId" 	default="">

<!---//////////////////////////////////// CONTROLLER SECTION //////////////////////////////////////////////--->

<!---create instances of objects we need--->
<cfset qGetDiscountTypes = CreateObject("component","components.programs.Program").getDiscountTypes(form.programId) />
<cfset clauseProgram = CreateObject("component","components.clause_library.ClauseProgramManager") />
<cfset clauseLibrary = CreateObject("component","components.clause_library.ClauseLibraryManager") />

<!---get access rights--->
<cfset clauseAccess = clauseProgram.getClauseEditRemoveAccess(request.AccessStructure.Profiles_ID) />

<!------ loop through and set defaults ----->	
<cfloop query="qGetDiscountTypes">
	<cfparam name="form.discType_#Product_Type_ID#" 	default="">
	<cfparam name="form.isRequiredIds_#Product_Type_ID#" 	default="">
	<cfparam name="form.isRequiredPgmIds_#Product_Type_ID#" 	default="">
</cfloop>


<cfset tableWidth = 800>
<cfset scrollWidth = 20>
<cfset tdWidth = 80 />

	<!------ program tabs display section ----->
	<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
	
	<CF_CRYP type="en" string="#form.programId#" key="#request.key#" return="Enc">
	<CFSET url.CID = Enc.value>
	<CFSET CSL_Contract_Main_ID = form.programId>
	<CFSET CSL_CallingPageCode = "clause"> 
	<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 566px; z-index: 1; left: 0px; top: 0px">
<CFINCLUDE TEMPLATE="/Common_Files/Contracts/contract_status_legend.cfm"> </div>
<cfelse>
	<CFINCLUDE TEMPLATE="/Common_Files/Contracts/contract_status_legend.cfm">
	</cfif>
	<blockquote>
	<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:300px; z-index:1; left: 90px; top: 30px;">	</cfif>
	<CFSET FORM.Contract_Main_ID = form.programId>
 	<cfinclude template="/Common_Files/Contracts/minimal_contract_info.cfm">
	
	<cfinclude template="/Common_Files/Contracts/Contract_Documents_Menu.cfm">
	
	<!---////////////////////////////////////////////////////////////////////////////////////////////////--->
	<!---////////////////////////////////////////////// STATE ///////////////////////////////////////////--->
	<!---////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cfif not form.state>
		
		<cfset qGetInitPrgmClse = clauseProgram.getProgramClause(form.programId) />
		
		<cfset form.lClauseIds = ValueList(qGetInitPrgmClse.Clause_Library_Id) />
		<!---loop over clauses and set required id lists--->
		<cfloop query="qGetInitPrgmClse">
		
			<!---handle for required clauses--->
			<cfif isRequired>
				<!---set for different clause types--->			
				<cfif Clause_Type eq 1>
					<cfset form.isRequiredPgmIds_0 = ListAppend(form.isRequiredPgmIds_0, Clause_Library_ID) />
				<cfelse>
					<cfset "form.isRequiredPgmIds_#Discount_Type_ID#" = ListAppend(Evaluate("form.isRequiredPgmIds_#Discount_Type_ID#"), Clause_Library_ID) />
				</cfif>
				<cfset form.excludeList = ListAppend(form.excludeList, Clause_Category_ID, ",")>
			</cfif>
			
		</cfloop>
		
		<cfif clauseAccess>
			<cfset form.excludeList = "">
		</cfif>
		
		<cfset form.ClauseLibraryId = ValueList(qGetInitPrgmClse.Clause_Library_Id) />
		
 		<!---see which discount types were checked--->
		<cfset useLakebaseForgetGenLibId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetinitprgmclse")>
<cfif useLakebaseForgetGenLibId>
	<cftry>
		<cfset getGenLibId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetinitprgmclse", {
				"clause_type" = "eq.1",
				"select" = "clause_library_id,clause_category_id"
			}), "clause_library_id,clause_category_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGenLibId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGenLibId>
<cfquery name="getGenLibId" dbtype="query">
			SELECT 	Clause_Library_Id, Clause_Category_Id
			FROM	qGetInitPrgmClse
			WHERE	Clause_Type = 1
		</cfquery>
</cfif>
		
		<!---set clause lib id's for clauses assigned to general --->
		<cfset form.discType_0 = ValueList(getGenLibId.Clause_Library_Id) />
		<cfset selectecCatId_0 = ValueList(getGenLibId.Clause_Category_Id) />
		<cfloop query="qGetDiscountTypes">

			<!---see which discount types were checked--->
			<cfset useLakebaseForgetDistLibId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetinitprgmclse")>
<cfif useLakebaseForgetDistLibId>
	<cftry>
		<cfset getDistLibId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetinitprgmclse", {
				"clause_type" = "eq.2",
				"discount_type_id" = "eq.#qGetDiscountTypes.Product_Type_ID#",
				"select" = "clause_library_id,clause_category_id"
			}), "clause_library_id,clause_category_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDistLibId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDistLibId>
<cfquery name="getDistLibId" dbtype="query">
				SELECT 	CLAUSE_LIBRARY_Id, Clause_Category_Id
				FROM	qGetInitPrgmClse
				WHERE	Clause_Type = 2
				AND		Discount_Type_ID = #qGetDiscountTypes.Product_Type_ID#
			</cfquery>
</cfif>
			
			<cfset "form.discType_#Product_Type_ID#" = ValueList(getDistLibId.Clause_Library_Id) />
			<cfset "selectecCatId_#Product_Type_ID#" = ValueList(getDistLibId.Clause_Category_Id) />
			
		</cfloop>
		
		<!---turn state on--->
		<cfset form.state = 1 />
	
	<cfelse>
		
		<!------ biuld selected clause category ids ----->
		<cfset selectecCatId_0 = "" />
		<cfloop list="#form.discType_0#" delimiters="," index="thisLibId">
			<cfparam name="form.ClauseCategoryId_#thisLibId#" 	default="">
			<cfset selectecCatId_0 = ListAppend(selectecCatId_0, Evaluate("form.ClauseCategoryId_#thisLibId#"), ",") />
		</cfloop>
		
		<cfloop query="qGetDiscountTypes">
		
			<cfset "selectecCatId_#Product_Type_ID#" = "" />
			<cfloop list="#Evaluate("form.discType_#Product_Type_ID#")#" delimiters="," index="thisLibId">
				<cfparam name="form.ClauseCategoryId_#thisLibId#" 	default="">
				<cfset "selectecCatId_#Product_Type_ID#" = ListAppend(Evaluate("selectecCatId_#Product_Type_ID#"), Evaluate("form.ClauseCategoryId_#thisLibId#"), ",") />
			</cfloop>
		
		</cfloop>
		
	</cfif>
	<!---////////////////////////////////////////////////////////////////////////////////////////////////--->
	<!---//////////////////////////////////////////// END STATE /////////////////////////////////////////--->
	<!---////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<cfset qGetPrgmClse = clauseLibrary.getList(form.lClauseIds) />
	
	<!---get a distinct list of clause id's from the qGetPrgmClse--->
	<cfquery name="lClauseIdDist" dbtype="query">
		SELECT 	DISTINCT(Clause_Library_ID), Clause_Category_ID, Clause_Category_Name, Clause_Library_Status
		FROM	qGetPrgmClse
		ORDER BY Clause_Category_Name #form.orderBy#
	</cfquery>
	
	<!---set the clause id's from the clause id list query--->
	<cfset form.lClauseIds = ValueList(lClauseIdDist.Clause_Library_Id) />
	<cfparam name="form.lExistingClauseIds" default="#form.lClauseIds#" />
	
	<cfset clauseTemplate = CreateObject("component","components.clause_library.ClauseTemplateManager").getTemplateAvailClause(form.programTypeId, form.lClauseIds) />
	<!------ <cfdump var="#clauseTemplate#" /> ----->
	<cfloop query="clauseTemplate">
		
		<cfif Require_Approval>
			<cfif not ListFindNoCase(form.lReqApproval, Clause_Library_ID)>
				<cfset form.lReqApproval = ListAppend(form.lReqApproval, Clause_Library_ID) />
			</cfif>
		</cfif>
		
	</cfloop>

<!---//////////////////////////////////// END CONTROLLER SECTION //////////////////////////////////////////--->
<br><br>
<FORM ACTION="#thisPage#" METHOD="post" name="#formName#" style="display:inline">
<!---//////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////// TABLE HEADER /////////////////////////////////////////////////--->
<!---//////////////////////////////////////////////////////////////////////////////////////////////////--->

<table CLASS="Maintable" width="#Evaluate(tableWidth + scrollWidth)#" BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<cfset discCount = (qGetDiscountTypes.recordCount + 1)>
	<colgroup>
		<col span="1" width="#Evaluate(tableWidth - (discCount * tdWidth))#"></col>
		<col span="#discCount#" width="#tdWidth#"></col>
	<colgroup>
	<tr valign="bottom">
		<td BGCOLOR="##FFCE84" id="tdTitle" style="font-size: 12px;">
			<img src="/Images/fill.gif" width="13" height="10" border="0">
			<a href="##" onClick="submitForm(document.#formName#, 'dClauseProgram', <cfif form.orderBy eq "ASC">'DESC'<cfelse>'ASC'</cfif>);"><b>Clause</b>
			<cfif form.orderBy eq "ASC">
				<img src="/Images/up_1.gif" border="0">			
			<cfelse>
				<img src="/Images/down_1.gif" border="0">
			</cfif>
			</a>
		</td>
		<td align="center" width="#scrollWidth#" bgcolor="white"></td>
	</tr>
	<tr>
		<td colspan="100%" style="border:none">
			<span id="SP_Details" style="overflow:auto;width:100%;height:80px;">
			<table CLASS="Maintable" WIDTH="#tableWidth#" BORDER="0" CELLPADDING="0" CELLSPACING="0" id="oDetailTable">
			
			
			<!---//////////////////////////////////////////////////////////////////////////////////////////////////--->
			<!---///////////////////////////////////// TABLE BODY /////////////////////////////////////////////////--->
			<!---//////////////////////////////////////////////////////////////////////////////////////////////////--->
				<cfloop query="lClauseIdDist">
					
					<!---set the clause library id for each record in the loop--->
					<cfset clauseLibId = Clause_Library_ID />
					<cfset clauseCategoryId = Clause_Category_ID />
					
					
					<!---set whether edit requires approval--->
					<cfif ListFindNoCase(form.lReqApproval, clauseLibId)>
						<cfset bEditReqApprvl = 1 />
					<cfelse>
						<cfset bEditReqApprvl = 0 />
					</cfif>
					<tr>
						<td id="tdTitle" width="" nowrap>
							<table width="100%" border="0" cellpadding="0" cellspacing="0" class="NotMaintable">
								<tr>
									<td width="80%">
										<cfif Clause_Library_Status EQ 3>
											<img src="/Images/asterix.gif" width="10" height="10" border="0">
										<cfelse>
											<img src="/Images/fill.gif" width="10" height="10" border="0">
										</cfif>
										<A HREF="/Clause_Library/index.cfm?id=#clauseLibId#&command=dClause" onClick="NewWindow(this.href,'name','625','450','Yes', 'Yes');return false;"><FONT FACE="Arial, Helvetica, sans-serif" COLOR="##000099">#Clause_Category_Name#</font></a>
										<input type="Hidden" name="ClauseCategoryId_#clauseLibId#" value="#Clause_Category_ID#">
										<input type="Hidden" name="ClauseLibraryId" value="#clauseLibId#">
									</td>
									<td width="20%" align="right">
										&nbsp;
									</td>
								</tr>
							</table>
						</td>
					</tr>
				
				</cfloop>
				
			</table>
			</span>
		</td>
	</tr>
</table>

<input type="hidden" name="discTypes" value="#ValueList(qGetDiscountTypes.product_type_id)#" />
<input type="hidden" name="command" value="#form.command#" />
<input type="hidden" name="programId" value="#form.programId#" />
<input type="hidden" name="programTypeId" value="#form.programTypeId#" />
<input type="hidden" name="state" value="#form.state#" />
<input type="hidden" name="userId" value="#request.AccessStructure.user_id#" />
<input type="hidden" name="lClauseIds" value="#form.lClauseIds#" />
<input type="hidden" name="lExistingClauseIds" value="#form.lExistingClauseIds#" />
<input type="hidden" name="excludeList" value="#form.excludeList#" />
<input type="hidden" name="isRequiredPgmIds_0" value="#form.isRequiredPgmIds_0#" />
<cfloop query="qGetDiscountTypes">
	<input type="hidden" name="isRequiredIds_#Product_Type_ID#" value="#Evaluate("form.isRequiredIds_#Product_Type_ID#")#" />
	<input type="hidden" name="isRequiredPgmIds_#Product_Type_ID#" value="#Evaluate("form.isRequiredPgmIds_#Product_Type_ID#")#" />
</cfloop>
<input type="hidden" name="lReqApproval" value="#form.lReqApproval#" />
<input type="hidden" name="orderBy" value="#form.orderBy#" />

</form>
</blockquote>
<cfif application.programlayout EQ 1></div></cfif>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script language="JavaScript">
document.body.onload = new Function("adjustTableWidth();setDetailDivHeight();");
//document.body.onload = new Function("adjustTableWidth();");
	function adjustTableWidth()
	{
		adjustThisTD("tdTitle");
		adjustThisTD("td0");
		<cfloop query="qGetDiscountTypes">
			adjustThisTD("td#Discount_Type_ID#");
		</cfloop>
	}
		
	function adjustThisTD(TDName)
	{
		var tCells = document.getElementsByName(TDName);
		var i, tCellLen;
		tCellLen = tCells.length;
		if(tCellLen >= 2)
		{
			if(tCells[1].style.offsetWidth > tCells[0].offsetWidth)
			{
				tCells[0].style.width = tCells[1].offsetWidth;
			}
			else
			{
				tCells[1].style.width = tCells[0].offsetWidth;
			}
		}			
	}
	
	var oDiv;
	function setDetailDivHeight()
	{
		oDiv = document.all.SP_Details;
		oDiv.style.height = getDetailsDivHeight();	
	}
	function getDetailsDivHeight()
	{
		var retunValue = "";
		var oTable_Product_List = document.all.oDetailTable;
		var oRows = oTable_Product_List.rows;
		if(oRows.length > 0)
		{
			var lastRow = oRows[oRows.length-1];
			var lastRowTop = getTotalOffsetProperty(lastRow, "body", "offsetTop", 0);
			maxHeight = document.body.clientHeight - getTotalOffsetProperty(oDiv, "body", "offsetTop", 0);

			var oSave_Link_TABLE_offsetHeight = 0;
			var oSave_Link_TABLE = document.all.oTableButton;
			if(oSave_Link_TABLE)
			{
				oSave_Link_TABLE_offsetHeight = oSave_Link_TABLE_offsetHeight + oSave_Link_TABLE.offsetHeight;
			}
			
			lastRowTop = lastRowTop + oSave_Link_TABLE_offsetHeight + 25;
			maxHeight = maxHeight - oSave_Link_TABLE_offsetHeight - 25;
				
			if(lastRowTop < maxHeight)
			{
				maxHeight = lastRowTop;
			}
			else
			{
				maxHeight = maxHeight;
			}
			
			retunValue = maxHeight;
			var detailsTableHeight = oTable_Product_List.offsetHeight + 1;
			if(retunValue > detailsTableHeight)
			{
				retunValue = detailsTableHeight;
			}
			if(retunValue <=0)
			{
				retunValue = 30;
			}			
			
			retunValue = retunValue + "px";
		}
		return retunValue;
	}
</script>
</CFOUTPUT>