<!-----------------------------------------------------------------------------

FILE NAME:		validateInput.cfm
DESCRIPTION:	Used for validating the given input
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	20-Nov-2014	

------------------------------------------------------------------------------> 
 
<cfparam name="FORM.passedPrgList" default="" /> 
<cfparam name="URL.currObj" default = ""/>
 
<cfif (isDefined("FORM.passedPrgList") AND FORM.passedPrgList NEQ "" AND FORM.thisObject EQ "PROGRAM")>
<cfoutput>
  <script language="javascript">
    callerWindowObj = dialogArguments;
    callerWindowObj.document.all.MyForm.ProgramList.value = "#FORM.passedPrgList#";
		callerWindowObj.document.all.MyForm.submit();
		window.close();
   </script>
</cfoutput>
<cfabort>
</cfif> 

 
<style>
	.ValidCategory
	{
		background-color:FFDEAD;
		border-top: 2px solid #808080;
		border-bottom: 2px solid #808080;
		font-size:14;
		font-weight:bold;
	}
	.InValidCategory
	{
		background-color:FA8072;
		border-top: 2px solid #808080;
		border-bottom: 2px solid #808080;
		font-size:14;
		font-weight:bold;
	}
	.InvalidSummary
	{
		font-size:12;
		font-weight:bold;
		text-decoration:underline; 
	}
	
	TABLE.Maintable TD	{border-bottom:solid #000000 1px; font-size : 10px;}
</style>

<cfif Not isDefined("form.thisObject")>
	<cfset form.thisObject = "">
</cfif>
 
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(form.groupLevelId) />
<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups()>
<cfset InputList = ListToArray(form.PassedItemList, ",")/>
	<!--- <cfquery name="DynamicValidator" dbtype="query">
			SELECT	*
			FROM	qGetApprovalGroups
			WHERE	Group_Number 
			<cfloop index="i" from="1" to="#ArrayLen(InputList)#" step="1">
				<cfset this.DataToBeValidated = #InputList[i]# />
				like (			
			 		'%#this.DataToBeValidated#%'
					)	
				<cfif i LT ArrayLen(InputList)>
					OR Group_Number
				</cfif>		
			</cfloop>
		</cfquery> --->
<cfloop index="i" from="1" to="#ArrayLen(InputList)#" step="1">
	<cfset this.DataToBeValidated = #InputList[i]# />
		<cfif ListFind(ArrayToList(approvalGroupManager.fnGet(1), ","), this.DataToBeValidated)>
			<cfset approvalGroupManager.fnSet("Duplicate", this.DataToBeValidated)/>
		</cfif>	
	<cfquery name="DynamicValidator" dbtype="query">
			SELECT	*
			FROM	qGetApprovalGroups
			WHERE	Group_Number 
				like (			
			 		'%#this.DataToBeValidated#%'
					)	
	</cfquery> 
	<cfif DynamicValidator.RecordCount EQ 0>
		<cfset approvalGroupManager.fnSet("Invalid",  this.DataToBeValidated)/>
	<cfelseif DynamicValidator.RecordCount EQ 1>
		<cfset approvalGroupManager.fnSet("ValidList",  this.DataToBeValidated)/>
		<cfset approvalGroupManager.fnSet("Valid",  this.DataToBeValidated)/>		
	</cfif>
</cfloop>		

<cfset Validation = approvalGroupManager.fnGet(2) />
 
<html>
<head>
	<title>Validation</title>
</head>

<cfparam name="valid_count" 	default="0" >
<cfparam name="invalid_count" 	default="0" >
<cfparam name="duplicate_count" default="0" >

<body>
<cfoutput>
	<div align="center">
		<table border="0"  cellspacing="5" cellpadding="5" width="250">
			<tr HEIGHT="10" >
				<td	width="80%" align="left" class="ValidCategory" bgcolor="##009900" >
					Valid Records
				</td>
				<td width="20%" align="right" class="ValidCategory">#ArrayLen(Validation.ValidData)#</td>
			</tr>
			<tr HEIGHT="10">
				<td width="80%" align="left" class="InValidCategory">
					Invalid Records<BR>
					<table align="right" class="Maintable">
						<cfloop index="i" from="1" to="#ArrayLen(Validation.InValidData)#" step="1">
							<tr>
								<td>#Validation.InValidData[i]#</td>
							</tr>
						</cfloop>
					</table>
				</td>
				<td width="20%" align="right" class="InValidCategory">#ArrayLen(Validation.InValidData)#</td>
			
			</tr>
			<!--- list of invalid inputs --->
			<tr HEIGHT="10">
				<td width="80%" align="left" class="InValidCategory">Duplicate Records
					<table align="right" class="Maintable">
						<cfloop index="i" from="1" to="#ArrayLen(Validation.DuplicateData)#" step="1">
							<tr>
								<td>#Validation.DuplicateData[i]#</td>
							</tr>
						</cfloop>
					</table>
				</td>
				<td width="20%" align="right" class="InValidCategory">#ArrayLen(Validation.DuplicateData)#</td>
			</tr>			
			<tr HEIGHT="10" >
				<td width="80%" align="left" class="ValidCategory">Total Records</td>
				<td width="20%" align="right" class="ValidCategory">#ArrayLen(Validation.InValidData) + ArrayLen(Validation.DuplicateData) + ArrayLen(Validation.ValidData)#</td>
			</tr>
		</table>
		<BR><BR>
		<!--- Dev Note: kvangapalli;  D13278: Make the create list tool just like the distributor search --->
		<cfset itemList = ListQualify(ArrayToList(Validation.ValidListData, ","), "'", ",", "ALL") >
		<blockquote style="color:red;font-weight:bold;font-style:italic;">Only valid items which are allowed on<BR> this template type will be returned</blockquote>

		<table>
			<tr>
				<td>
					<CF_button
							button_name		=	""
							button_caption	=	"Continue"
							button_action	=	"contHandler(#ArrayLen(Validation.InValidData)#, #ArrayLen(Validation.DuplicateData)#,#ArrayLen(Validation.ValidData)#);"
							button_type		=	"javascript_link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						> 
				</td>
				<td>
						<CF_button
						button_name		=	""
						button_caption	=	"Back"
						button_action	=	"document.all.frmCallBack.submit();"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						> 				
				</td>
			</tr>
		</table>
	</div>
</cfoutput>

<form name="frmCallBack" id="frmCallBack" action="createListForm.cfm" method="post">
	<input type="hidden" name="hiddenForm" id="hiddenForm" value="<cfoutput>#form.hiddenForm#</cfoutput>">
	<input type="hidden" name="passObj" id="passObj" value="<cfoutput>#form.thisObject#</cfoutput>">
	<input type="hidden" name="validList" id="validList" value="<cfoutput>#trim(ArrayToList(Validation.ValidData))#</cfoutput>">
	<input type="hidden" name="invalidList" id="invalidList" value="<cfoutput>#trim(ArrayToList(Validation.InValidData))#</cfoutput>">
</form>


</body>
</html>

<script>
	function contHandler(invalidCount, duplicateCount, validCount) {
		<cfwddx action = "CFML2JS" input = "#itemList#" topLevelVariable = "itemList" >
		if (!itemList)
			itemList = 0;
		if (invalidCount > 0)	{
			var rv = confirm(invalidCount + " Invalid and " + duplicateCount + " duplicate records exist." + "\n" + "Select OK only returns " + validCount + " valid records.");
			if (!rv)
			return false;
		}
		callerWindowObj = dialogArguments;
		var currForm = document.getElementById("hiddenForm").value;
		eval("callerWindowObj.document.all." + currForm + ".passed_form.value = 'comCreateListForm' ");
		eval("callerWindowObj.document.all." + currForm + ".itemList.value" + "=" + "\"" + itemList + "\"");
		eval("callerWindowObj.document.all." + currForm + ".submit()" );
		window.close();
		return true;
	}
</script>
 