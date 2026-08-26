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
	
	function reqApproveAlert(bIsRequired, type, thisObj)
	{
		//handle for edit type
		if (type == 'edit')
		{
			//if it is required then confirm
			if (bIsRequired)
			{
				if (confirm("Editing the clause requires approval. Do you want to continue?"))
				{
					NewWindow(thisObj,'name','950','600','Yes', 'Yes');
				}
			}
			else
			{
				NewWindow(thisObj,'name','950','600','Yes', 'Yes');
			}
		}
		//handle for remove type
		else if (type == 'remove')
		{
			//if it is required then confirm
			if (bIsRequired)
			{
				//verify if checkbox is checked
				if (!thisObj.checked)
				{
					if (!confirm("Removing the clause requires approval. Do you want to remove it?"))
						thisObj.checked = true;
				}
			}
		}
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

<!---set the clause type list--->
<!--- <cfset lClauseType = "General"/> --->

<!---loop through discount types and add to clause list based on type id--->
<!--- <cfloop query="qGetDiscountTypes">

	<cfswitch expression="#product_type_id#">
	
		<cfcase value="1"><cfset lClauseType = ListAppend(lClauseType, "Fixed Price") /></cfcase>
		<cfcase value="2"><cfset lClauseType = ListAppend(lClauseType, "Rebate") /></cfcase>
		<cfcase value="3"><cfset lClauseType = ListAppend(lClauseType, "Lump Sum") /></cfcase>
		<cfcase value="4"><cfset lClauseType = ListAppend(lClauseType, "Growth") /></cfcase>
		<cfcase value="5"><cfset lClauseType = ListAppend(lClauseType, "Formula Pricing") /></cfcase>
		<cfcase value="8"><cfset lClauseType = ListAppend(lClauseType, "Off-Invoice") /></cfcase>
		
	</cfswitch>

</cfloop> --->

<cfset tableWidth = 800>
<cfset scrollWidth = 20>
<cfset tdWidth = 80 />

<cfif form.command eq "sClauseProgram">
		
	<cfset clauseProgram.saveFromProgram(form) />
	<cflocation addtoken="no" url="/Clause_Library/index.cfm?command=dClauseProgram&programId=#form.programId#&programTypeId=#form.programTypeId#" />
		
<cfelse>

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
		<cfquery name="getGenLibId" dbtype="query">
			SELECT 	Clause_Library_Id, Clause_Category_Id
			FROM	qGetInitPrgmClse
			WHERE	Clause_Type = 1
		</cfquery>
		
		<!---set clause lib id's for clauses assigned to general --->
		<cfset form.discType_0 = ValueList(getGenLibId.Clause_Library_Id) />
		<cfset selectecCatId_0 = ValueList(getGenLibId.Clause_Category_Id) />
		<cfloop query="qGetDiscountTypes">

			<!---see which discount types were checked--->
			<cfquery name="getDistLibId" dbtype="query">
				SELECT 	CLAUSE_LIBRARY_Id, Clause_Category_Id
				FROM	qGetInitPrgmClse
				WHERE	Clause_Type = 2
				AND		Discount_Type_ID = #qGetDiscountTypes.Product_Type_ID#
			</cfquery>
			
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

</cfif>
<!---//////////////////////////////////// END CONTROLLER SECTION //////////////////////////////////////////--->

<br>
<CF_smallLink 
	title = "add category / pick clause version" 
	url = "##"
	parameters = "onClick=""javascript: return search_popup('index.cfm?command=spClause&FormName=#formName#&FieldName=lClauseIds&templateId=#form.programTypeId#&importType=multiple&ExcludeListFieldname=excludeList');"""
>
<!--- <B>
	<FONT COLOR="FF0000">[</FONT>
		<a href="##" onclick="javaScript: return search_popup('index.cfm?command=spClause&FormName=#formName#&FieldName=lClauseIds&templateId=#form.programTypeId#&importType=multiple&ExcludeListFieldname=excludeList');">add category / pick clause version</a>
	<FONT COLOR="FF0000">]</FONT>
</B> --->
<br><br>
<FORM ACTION="#thisPage#" METHOD="post" name="#formName#" style="display:inline">
<table border="0" cellpadding="1" cellspacing="0" width="800">
	<tr>
		<td>
			<font face="Arial, Helvetica, sans-serif" color="##FF0000">R</font>
			<font face="Arial, Helvetica, sans-serif">=</font>
			<font face="Arial, Helvetica, sans-serif">Required</font>
			&nbsp;&nbsp;&nbsp;
		</td>
		<td>
			<font face="Arial, Helvetica, sans-serif" color="##FF0000">O</font>
			<font face="Arial, Helvetica, sans-serif">=</font>
			<font face="Arial, Helvetica, sans-serif">Optional</font>
			&nbsp;&nbsp;&nbsp;
		</td>
		<td>
			<font face="Arial, Helvetica, sans-serif" color="##FF0000">RRA</font>
			<font face="Arial, Helvetica, sans-serif">=</font>
			<font face="Arial, Helvetica, sans-serif">Revision Requires Approval</font>
			&nbsp;&nbsp;&nbsp;
		</td>
		<td>
			<img src="/Images/asterix.gif" width="10" height="10" border="0">
			<font face="Arial, Helvetica, sans-serif">=</font>
			<font face="Arial, Helvetica, sans-serif">Clause was edited</font>
			&nbsp;&nbsp;&nbsp;
		</td>
	</tr>
</table>
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
		<td BGCOLOR="##FFCE84" id="td0" align="center" style="font-size: 12px;">
			<b>General</b>
		</td>
		<cfloop query="qGetDiscountTypes">
			<td BGCOLOR="##FFCE84" id="td#Discount_Type_ID#" align="center" style="font-size: 12px;">
				<b>#Discount_Type_Desc#</b>
			</td>
		</cfloop>
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
										<cfif clauseAccess>
											<a href="#thisPage#?command=eClauseProgram&id=#Clause_Library_ID#&editFromProgram=1&programId=#form.programId#&submitForm=#formName#" onClick="reqApproveAlert(#bEditReqApprvl#, 'edit', this.href);return false;">(edit)</a>
											<cfif bEditReqApprvl>
												-&nbsp;<font face="Arial, Helvetica, sans-serif" color="##FF0000">RRA</font>
											<cfelse>
												<span style="width:27px;">&nbsp;</span>	
											</cfif>
										<cfelse>
											&nbsp;
										</cfif>
										&nbsp;
									</td>
								</tr>
							</table>
						</td>
						
						<!---///////////////////////////////////////// GENERAL ////////////////////////////////////////////////--->
						<cfset bGenRemReqApprvl =0 />
						
						<!---check to see if this is required or optional if it exists in template--->
						<cfquery name="qGetReqOpt" dbtype="query">
							SELECT 	isRequired
							FROM	clauseTemplate
							WHERE	Clause_Category_ID = #clauseCategoryId#
							AND		Clause_Type = 1
						</cfquery>						
						
						<!---set whether remove requires approval for generic--->
						<cfif bEditReqApprvl>
							<cfif qGetReqOpt.RecordCount and qGetReqOpt.isRequired>
								<cfset bGenRemReqApprvl = 1 />
							</cfif>
						</cfif>
						
						<td style="border-left:solid ##FFCE84 1px;" align="center" id="td0" onMouseOver="highlightRowCol(this, '##CCFFCC', 0, '##93BEE2')" onMouseOut="highlightRowCol(this, '##ffffff', 0)">
							<cfif qGetReqOpt.RecordCount>
								<cfif ListFindNoCase(form.ClauseLibraryId, clauseLibId, ",")>									
									<cfset clauseChecked = ListFindNoCase(form.discType_0, clauseLibId) />
								<cfelse>
									<cfset clauseChecked = ListFindNoCase(selectecCatId_0, clauseCategoryId) />
								</cfif>
								<input name="discType_0" type="checkbox" onClick="reqApproveAlert(#bGenRemReqApprvl#, 'remove', this);" <cfif not clauseAccess and qGetReqOpt.isRequired>disabled</cfif> value="#clauseLibId#" <cfif clauseChecked>checked</cfif> />
								<!------ <cfif not clauseAccess and ListFindNoCase(form.isRequiredPgmIds_0, clauseLibId)> ----->
								<cfif not clauseAccess and qGetReqOpt.isRequired>
									<cfif clauseChecked>
										<input type="hidden" name="discType_0" value="#clauseLibId#" style="position:absolute" />
									</cfif>
								</cfif>
								<font face="Arial, Helvetica, sans-serif" color="##FF0000">
								<cfif qGetReqOpt.isRequired>R<cfelse>O</cfif>
								</font>
							<cfelse>
								-
							</cfif>
						</td>
						
						<!---////////////////////////////////////////// DISCOUNT TYPES ///////////////////////////////////////////////--->
						<cfloop query="qGetDiscountTypes">
							
							<cfset bDiscRemReqApprvl = 0 />
							<!---check to see if this is required or optional if it exists in template--->
							<cfquery name="qGetReqOptDisc" dbtype="query">
								SELECT 	isRequired
								FROM	clauseTemplate
								WHERE	Clause_Category_ID = #clauseCategoryId#
								AND		Clause_Type = 2
								AND		Discount_Type_ID = #Product_Type_ID#
							</cfquery>
							<!---set whether remove requires approval for discount--->
							<cfif bEditReqApprvl>
								<cfif qGetReqOptDisc.RecordCount and qGetReqOptDisc.isRequired>
									<cfset bDiscRemReqApprvl = 1 />
								</cfif>
							</cfif>
							<td style="border-left:solid ##FFCE84 1px;" align="center" id="td#Discount_Type_ID#" onMouseOver="highlightRowCol(this, '##CCFFCC', 0, '##93BEE2')" onMouseOut="highlightRowCol(this, '##ffffff', 0)">
								<cfif qGetReqOptDisc.RecordCount>																		
									<cfif ListFindNoCase(form.ClauseLibraryId, clauseLibId, ",")>									
										<cfset clauseChecked = ListFindNoCase(Evaluate("discType_#Product_Type_ID#"), clauseLibId) />
									<cfelse>
										<cfset clauseChecked = ListFindNoCase(Evaluate("selectecCatId_#Product_Type_ID#"), clauseCategoryId) />
									</cfif>									<input name="discType_#Product_Type_ID#" type="checkbox" onClick="reqApproveAlert(#bDiscRemReqApprvl#, 'remove', this);" <cfif not clauseAccess and qGetReqOptDisc.isRequired>disabled</cfif> value="#clauseLibId#" <cfif clauseChecked>checked</cfif> />
									<cfif not clauseAccess and qGetReqOptDisc.isRequired>
										<cfif clauseChecked>
											<input type="hidden" name="discType_#Product_Type_ID#" value="#clauseLibId#" style="position:absolute" />
										</cfif>
									</cfif>
									<font face="Arial, Helvetica, sans-serif" color="##FF0000">
									<cfif qGetReqOptDisc.isRequired>R<cfelse>O</cfif>
									</font>
								<cfelse>
									-
								</cfif>
							</td>
						</cfloop>
						
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

<table id="oTableButton">
	<tr>
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"Save"
				button_action	=	"submitForm(document.#formName#, 'sClauseProgram');"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
</table>
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