<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!------ Clause_Template_Add_Remove.cfm ----->

<cfoutput>

<html>
<head>
	<title>Program Template - Clause</title>
  <LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/dataTable.css">
  <style>
    ##hd34 { margin:10px 0; }
    ##table98 th, ##table98 td { text-align:center; }
    .disc31 { text-align:center; }
    ##applys { margin-bottom:10px; }
  </style>
</head>

<body>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<CFSET PAGETITLE = "PROGRAM TEMPLATES: CLAUSES">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset ThisPage = CGI.SCRIPT_NAME>
<cfset formName = "frmTemplateClause">
<cfparam name="form.command" 	default="">
<cfset requiredList = "1,0">
<cfset tableBorderColor = "##93BEE2">

<script language="JavaScript">
	function search_popup(sUrl)
	{
		NewWindow(sUrl, 'clause_search', '800', '600', 'Yes', 'No', true);
		return false;
	}
</script>


<cfinclude template="/script/cf/string_functions.cfm">
<cfinclude template="/Clause_Library/Clause_Functions.cfm">
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script language="JavaScript">
	function deleteRow(srcInput, sPairFieldName, sVal, skeyword)
	{
		var srcObj = event.srcElement;		
		var trObj = getParentObject(srcObj, "tr");
		var bDelete = true;
		var srcInputObj = eval("document.all." + srcInput);
		var srcValue = srcInputObj.value;
		var resultString = ListDeleteItem(srcValue, ",", sVal);
		if(resultString == srcValue)
		{
			resultString = ListAppendItem(srcValue, ",", sVal);
			bDelete = false;
		}
		addDeleteFromNotAllow(bDelete, sVal, sPairFieldName);
		
		srcInputObj.value = resultString;
		var emptyString = "<img src=\"/Images/fill.gif\" height=\"1\">";
		if(trObj)
		{
			if(bDelete)
			{
				propogateProperty(trObj, "style.backgroundColor", "##DDDDDD", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				srcObj.title = "undo delete " + skeyword;
				srcObj.src = undodeleteImg.src;
			}
			else
			{
				var bgCol = "##FFFFFF";				
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				srcObj.title = "delete this " + skeyword;
				srcObj.src = deleteImg.src;
			}
			srcObj.bDelete = !bDelete;
		}		
	}
	var NotAllowList = new Array();

	function addDeleteFromNotAllow(bDelete, sVal, sPairFieldName)
	{
		var oInput, newVal;
		oInput = eval("document.all." + sPairFieldName);
		newVal = oInput.value;
		if(bDelete)
		{
			newVal = ListDeleteItem(newVal, ",", sVal);
		}
		else
		{
			newVal = ListAppendItem(newVal, ",", sVal);
		}
		oInput.value = newVal;

	}
	
	function buildFieldName(sStart, bRequired, clauseType, discountType)
	{
		return sStart + "_" + bRequired + "_" + clauseType + "_" + discountType;
	}
	
	function onlyOneChecked(thisObj)
	{
		if(event.propertyName != "checked")
		{
			return;
		}
		var trObj = getParentObject(thisObj, "tr");
		var checkOk = true;
		var bChecked = thisObj.checked;
		
		if(thisObj.sPairName)
		{
			currObj = eval("trObj.all." + thisObj.sPairName);
			if(currObj)
			{
				if(currObj.checked && bChecked)
				{
					currObj.checked = false;
				}
			}
			
		}		
	}
	
	function trColor(thisObj)
	{
		var chObjs = thisObj.getElementsByTagName("input");
		var i, chLen;
		var chChecked = false;
		var bgColor = "##CCCCCC";
		chLen = chObjs.length;
		for(i=0;i<chLen;i++)
		{
			if(chObjs[i].checked)
			{
				chChecked = true;
				break;
			}
		}
		if(chChecked)
		{
			bgColor = "##FFFFFF";
		}
		return bgColor;
	}
	
	function simulateCheckAll(thisObj, bRequired, clauseType, discountType)
	{
		thisObj.bChecked = !thisObj.bChecked;
		// thisObj.style.fontWeight = (thisObj.bChecked)?'bold':'normal';
		CHSelectAll(buildFieldName('Clause', bRequired, clauseType, discountType), thisObj.bChecked);
		if(thisObj.bChecked)
		{
			thisObj.title = "click here to unselect all";
		}
		else
		{
			thisObj.title = "click here to select all";
		}
	}	
</script>

<!------ Clause_Template_Add_Remove.cfm ----->

<!------ set defaults ----->
<cfparam name="form.state" 	default="0">
<cfparam name="form.id" 	default="0">
<cfparam name="url.id" 	default="#form.id#">
<cfparam name="form.Clause_List" 	default="">
<cfset clauseFieldName = "Clause_List">
<cfset selectedClauseIds = "">



<cfif url.id>

	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset template = templateManager.get(url.id)>
	<cfset qGetAllDiscountTypes = templateManager.getAllDiscountTypes(url.id)>
	<cfset clauseTemplateManager = CreateObject("component", "components.clause_library.ClauseTemplateManager").init() />
	<cfset clauseLibraryManager = CreateObject("component", "components.clause_library.ClauseLibraryManager").init() />
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<!------ set defaults ----->
	<CF_Clause_Formvals
			Clause_Type = "1"
			setDefault = "1"
			>
	<cfloop query="qGetAllDiscountTypes">
		<CF_Clause_Formvals
				Clause_Type = "2"
				Discount_Type_ID = "#Discount_Type_ID#"
				setDefault = "1"
				>
	</cfloop>
	
	
	<cfset pageName = "clause">	
	<cfif form.command EQ "save">
		
		<cfset clauseTemplateManager.save(url.id, form)>
		<cfset id = url.id>
		
		<!------ Redirect to next page ----->		
		<cfinclude template="Next_Page.cfm" />
		
	<cfelse>
		
		<!------ display header ----->
		<cfset Created_Type = template.getCreatedType()>
		<cfset Generic_Type = template.getGenericType()>
		<cfset Active = template.getActive()>
		<cfset Action = "edit">		
		<cfinclude template="header.cfm">

		
	  <div id="hd34">
	    <B>Clauses</B> &nbsp; &nbsp; <B><FONT COLOR="FF0000">[</FONT><a HREF="##" onclick="javaScript: return search_popup('/Clause_Library/index.cfm?command=spClause&FormName=#formName#&FieldName=#clauseFieldName#&importType=multiple');"> search clause </a><FONT COLOR="FF0000">]</FONT></B>  &nbsp; &nbsp; <b>R</b> - Required <b>O</b> - Optional
	  </div>
	  
		<form name="#formName#" method="post" action="#ThisPage#" style="display:inline;">
		<cfset getClauseAllProgramsSettings = clauseTemplateManager.getClauseAllProgramsSettings(url.id)>
		<div id="applys">
  		<input name="Apply_Existing" type="radio" value="1" <cfif getClauseAllProgramsSettings.Apply_Clause_All_Programs EQ 1>checked</cfif>>Apply to Existing Non Approved Programs
  		<input name="Apply_Existing" type="radio" value="2" <cfif getClauseAllProgramsSettings.Apply_Clause_All_Programs EQ 2>checked</cfif>>Apply to All Existing Programs (including approved)
  		<input name="Apply_Existing" type="radio" value="0" <cfif getClauseAllProgramsSettings.Apply_Clause_All_Programs EQ 0>checked</cfif>>Apply changes for new programs alone
		</div>
		<!---<hr color="orange">--->
		
		<cfif form.state>
			<cfset getTemplateClause = clauseLibraryManager.getList(Evaluate("form.#clauseFieldName#")) />
		<cfelse>
			<cfset getTemplateClause = clauseTemplateManager.getTemplateClause(url.id)>
			<cfset selectedClauseIds = ValueList(getTemplateClause.Clause_Library_ID)>
		</cfif>
		
			<CF_Clause_Formvals
					Clause_Type = "1"
					setDefault = "0"
					>
			<cfloop query="qGetAllDiscountTypes">
				<CF_Clause_Formvals
						Clause_Type = "2"
						Discount_Type_ID = "#Discount_Type_ID#"
						setDefault = "0"
						>
			</cfloop>
		
		
		
		<cfquery name="qGetDistinctClause" dbtype="query">
			SELECT 	DISTINCT Clause_Library_ID, Clause_Category_ID, Clause_Category_Name
			FROM	getTemplateClause
			ORDER BY Clause_Category_Name
		</cfquery>
		<cfset tableWidth = 750>
		<cfset scrollWidth = 35>
		<cfset tdWidth = 40>
		
    <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( listToArray( "5," & repeatString("1,", (qGetAllDiscountTypes.recordCount + 1) * (appSettings.getSimpleClause() eq 1 ? 1 : 2)) ) )>
		
		<table cellpadding="0" cellspacing="0" border="0" class="MainTable datagrid" width="100%" id="table98">	
			<cfset discCount = (qGetAllDiscountTypes.recordCount + 1) * 2>
    	<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
        <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
      </cfloop>
			<thead>
  			<tr>
  				<th id="clauseTitle">Clause</th>
  				<th colspan="2" id="discType0">General</th>
  				<cfloop query="qGetAllDiscountTypes">
  				  <th colspan="2" id="discType#Discount_Type_ID#">#Discount_Type_Desc#</th>
  				</cfloop>
  			</tr>
  			<tr>
  				<th>&nbsp;</th>
  				<th id="header" bChecked="true" onclick="simulateCheckAll(this, 1, 1, '');" style="cursor:pointer;font-weight:bold;" title="click here to unselect all">R</th>
  				<th id="header" bChecked="true" onclick="simulateCheckAll(this, 0, 1, '');" style="cursor:pointer;font-weight:bold;" title="click here to unselect all">O</th>
  				<cfloop query="qGetAllDiscountTypes">
    				<th id="header" bChecked="true" onclick="simulateCheckAll(this, 1, 2, #Discount_Type_ID#);" style="cursor:pointer;font-weight:bold;" title="click here to unselect all">R</th>
    				<th id="header" bChecked="true" onclick="simulateCheckAll(this, 0, 2, #Discount_Type_ID#);" style="cursor:pointer;font-weight:bold;" title="click here to unselect all">O</th>
  				</cfloop>
  			</tr>
			</thead>
			
			<cfif qGetDistinctClause.recordCount eq 0>
  			<tr>
  				<td colspan="100%" id="header"><B>No clause selected</B></td>
  			</tr>
			<cfelse>
  				<cfloop query="qGetDistinctClause">
      			<tr>
      					<cfset clauseId = Clause_Library_ID>
      					<cfset categoryId = Clause_Category_ID>
      					<cfset bgColor = "##CCCCCC">
      					<cfif ListFindNoCase(selectedClauseIds, clauseId, ",")>
      						<cfset bgColor = "##FFFFFF">
      					</cfif>
      					
    						<td id="clauseTitle" title="#Clause_Category_Name#" style="text-align:left;"><A HREF="/Clause_Library/index.cfm?id=#Clause_Library_ID#&command=dClause" onClick="NewWindow(this.href,'Clause_Display','625','450','Yes', 'Yes');return false;">#showRestrictedLength(Clause_Category_Name, 30)#</A>
    						<input type="Hidden" name="ClauseTemplateId_#clauseId#" value="#Clause_Category_ID#" />
    						</td>
    						
    						<CF_Clause_Sections
    							Clause_Type = "1"
    							Display_Title = "Generic"
    							clauseId = "#clauseId#"
    							categoryId = "#categoryId#"
    							>
    						<cfloop query="qGetAllDiscountTypes">
      							<CF_Clause_Sections
      								Clause_Type = "2"
      								Display_Title = "#Discount_Type_Desc#"
      								Discount_Type_ID = "#Discount_Type_ID#"
      								clauseId = "#clauseId#"
      								categoryId = "#categoryId#"
      								>
      					</cfloop>
      			</tr>
  				</cfloop>
			</cfif>
		</table>
		
		<input type="Hidden" name="discountTypeIds" value="#ValueList(qGetAllDiscountTypes.Discount_Type_ID)#">
		<input type="Hidden" name="#clauseFieldName#" value="#ValueList(qGetDistinctClause.Clause_Library_ID)#">
		<input type="hidden" name="id" value="#url.id#">
		<input type="hidden" name="state" value="1">
		<input type="hidden" name="command" value="#form.command#">
		</form>
		<br>
		<table align="center" id="oTableButton" border="0" cellpadding="10" cellspacing="10">
		<tr>
		<td>
		<CF_button
			button_name		=	""
			button_caption	=	"search clause"
			button_action	=	"search_popup('/Clause_Library/index.cfm?command=spClause&FormName=#formName#&FieldName=#clauseFieldName#&importType=multiple');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"search clause"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		<td>
		<!--- Dev Note: KAL - D7952 : Lock/Unlock Template --->
		<cfif LockedBy_Current_User EQ 1>
		<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"submitForm(document.#formName#, 'save');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</cfif>
		</td>
		<td>
		<CF_button
			button_name		=	""
			button_caption	=	"reset"
			button_action	=	"javascript:document.#formName#.reset();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"reset"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		</tr>
		</table>
	</cfif>
</cfif>


<script language="JavaScript">
	function submitForm(thisForm, sCommand)
	{
		var apply1 = thisForm.Apply_Existing[0].checked;
		var apply2 = thisForm.Apply_Existing[1].checked;
		if(apply1 || apply2)
		{
			if (!confirm("Only required clauses will be applied to programs. Click OK to continue."))
			return;
		}

		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
	<cfif qGetDistinctClause.recordCount>
		document.body.onload = new Function("adjustTableWidth();setDetailDivHeight();");
	</cfif>
	function adjustTableWidth()
	{
		adjustThisTD("clauseTitle");
		adjustThisTD("discType0");
		<cfloop query="qGetAllDiscountTypes">
			adjustThisTD("discType#Discount_Type_ID#");
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
		// oDiv = document.all.SP_Details;
		// oDiv.style.height = getDetailsDivHeight();	
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
			
			lastRowTop = lastRowTop + oSave_Link_TABLE_offsetHeight + 45;
			maxHeight = maxHeight - oSave_Link_TABLE_offsetHeight - 45;
				
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
<br>

<cfif LockedBy_Current_User NEQ 1>
  <cfinclude template="/common_files/jQuery.cfm">
  <script>
 	  $("##hd34 a, ##oTableButton a").attr("disabled", "disabled").attr("onclick", "");
  </script>
</cfif>

</body>
</html>
</cfoutput>