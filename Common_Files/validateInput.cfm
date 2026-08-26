<!--- validation is based on the following criteria: invalid character, or data is not existing in the database --->
<!--- the format of the interface will be like as follows:
								Validation
		Data1					yes
		Data2					no
			Continue	Back	Email
--->
<cfparam name="FORM.passedPrgList" default="" />
<cfparam name="URL.currObj" default = ""/>
<cfparam name="url.CID" default = "">	<!--- french translation --->
<cfparam name="url.ProgramID" default = "">	<!--- french translation --->
<cfparam name="form.Program_ID" default="0" />
<cfparam name="fromPrgUpload" default="0" /> <!--- Checks if user coming from rebate upload page --->
<cfparam name="form.discountype" default ="0"/>

<cfif (form.Program_ID EQ 0 OR form.Program_ID EQ "") AND URL.ProgramID NEQ "">
	<cfset passProgram_ID = URL.ProgramID  />
<cfelse>
	<cfset passProgram_ID = form.Program_ID />
</cfif>
<!---  57142 GM request for partial match & exact match--->
<cfif not structKeyExists(form, "match_type")>
	<cfset form.match_type = (application.appSettingsget.getExact_List_Matching_On() ? "exact" : "partial")>
</cfif>

<!---77408 Product Group sequencing START--->
<cfset ApplicationSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").get(1) />
<!---77408 Product Group sequencing END--->

<cf_include files="/styles/css-loader.css">
<cfinclude template="/Common_Files/jQuery.cfm">

<cfif (isDefined("FORM.passedPrgList") AND FORM.passedPrgList NEQ "" AND FORM.thisObject EQ "PROGRAM")>
<cfoutput>
	<script language="javascript">
		callerWindowObj = null;
		// ChromeFix :: dialogArguments is not defined
		if(typeof dialogArguments != 'undefined'){
			callerWindowObj = dialogArguments;
		}
		else{
			callerWindowObj = window.parent.opener;
		}
		//eval("callerWindowObj.document.all.MyForm.ProgramList.value = " + #FORM.PassedItemList#);
		//eval("callerWindowObj.document.all.MyForm.submit()" );
		//eval('callerWindowObj.document.all.MyForm.itemList.value' + '=' + '\"' + #FORM.PassedItemList# + '\"');
		callerWindowObj.document.all.MyForm.ProgramList.value = "#FORM.passedPrgList#";
		callerWindowObj.document.all.MyForm.submit();
		window.close();
	</script>
</cfoutput>
<cfabort>
</cfif>

<style>
	.ValidCategory{
		background-color:FFDEAD;
		border-top: 2px solid #808080;
		border-bottom: 2px solid #808080;
		font-size:14;
		font-weight:bold;
	}
	.InValidCategory{
		background-color:FA8072;
		border-top: 2px solid #808080;
		border-bottom: 2px solid #808080;
		font-size:14;
		font-weight:bold;
	}
	.InvalidSummary{
		font-size:12;
		font-weight:bold;
		text-decoration:underline;
	}
	TABLE.Maintable TD{
		border-bottom:solid #000000 1px;
		font-size : 10px;
	}
</style>

<html>
<head>
	<title></title>
</head>

<cfif Not isDefined("form.thisObject")>
  <cfset form.thisObject = "">
</cfif>
<cfset tablename = '####'&#replace(request.AccessStructure.User_ID,'-','_','ALL')#&'_Program_upload_'&#form.Program_ID#>
<CFSET objHandle = CreateObject("component", "components.general.Create_List")>
<CFSET validationHandle = CreateObject("component", "components.general.CreateList_Validation")>
<cfset Validation = validationHandle.getDataValidationInfo(ListToArray(form.passedItemList, ","), form.thisObject, form.match_type, passProgram_ID, fromPrgUpload,tablename, form.discountype)>  <!--- 57142 --->

<!---77408 Product Group sequencing START--->
<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1' AND form.Program_ID>
	<cfset pricingLevel = validationHandle.updatePricingLevels(tablename)/>
</cfif>
<!---77408 Product Group sequencing END--->

<cfparam name="valid_count" 	default="0" >
<cfparam name="invalid_count" 	default="0" >
<cfparam name="duplicate_count" default="0" >

	<cfif fromPrgUpload>
		<!--- Below function will update pricing level if upload data has only 1 product group level and items OR only items --->
		<cfset ProductGroupLevelIdCount = createObject("component","components.programs.rebates.Rebate").UpdatePricingLevel(tablename)>
	</cfif>
<body>
	<cfoutput>
	<cfinclude template="/common_files/programTranslate.cfm">      <!--- french translation --->
	<div align="center">
		<table border="0"  cellspacing="5" cellpadding="5" width="300">
			<tr HEIGHT="10" >
				<td width="80%" align="left" class="ValidCategory" bgcolor="##009900" >
					Valid Records
				</td>
				<cfif fromPrgUpload>
					<cfquery name="GetvalidCount" datasource="#application.datasource#">
						SELECT count(*) AS Valid
						FROM #tablename#
						WHERE inValid = 0
						AND Removed = 0
						AND Duplicate = 0
            AND InDB = 0
					</cfquery>
					<cfset ValidTotal = #GetvalidCount.Valid#>
				<cfelse>
					<!---<cfset ValidTotal = #ArrayLen(Validation.ValidData)#>--->
					<!---
					The different items returned for one keyword search exist in one element of the array and so
					we need to loop through the array and get the list length of that array element.
					This is needed when "partial search" option is selected from the "create list" popup page.
					--->
					<cfset ValidTotal = 0>
					<cfloop index="i" from="1" to="#ArrayLen(Validation.validListData)#">
						<cfset ValidTotal = ValidTotal + ListLen(Validation.validListData[i])>
					</cfloop>
				</cfif>
				<td width="20%" align="right" class="ValidCategory">#ValidTotal#</td>
			</tr>
			<tr HEIGHT="10">
				<cfif fromPrgUpload>
					<cfquery name="GetinvalidCount" datasource="#application.datasource#">
						SELECT count(InValid) AS InValid
						FROM #tablename#
						WHERE inValid = 1
						AND  InDB = 0
					</cfquery>
					<cfset inValidTotal = #GetinvalidCount.InValid#>
				<cfelse>
					<cfset inValidTotal = #ArrayLen(Validation.InValidData)#>
				</cfif>
				<td width="80%" align="left" class="InValidCategory">
					Invalid Records<BR>
					<table align="right" class="Maintable">
						<cfif fromPrgUpload>
							<cfif inValidTotal>
								<a onClick="javascript: return showDetails(0);" style="cursor:pointer;font-size:12px;font-weight: lighter;">#application.util.string.actionLinkFormat("view list of invalid records")#</a>
							</cfif>
						<cfelse>
							<cfloop index="i" from="1" to="#ArrayLen(Validation.InValidData)#" step="1">
								<tr>
									<td>#Validation.InValidData[i]#</td>
								</tr>
							</cfloop>
						</cfif>
					</table>
				</td>
  				<td width="20%" align="right" class="InValidCategory">#inValidTotal#</td>
			</tr>
			<!--- list of invalid inputs --->
			<tr HEIGHT="10">
				<cfif fromPrgUpload>
					<cfquery name="GetDupCount" datasource="#application.datasource#">
						SELECT count(Duplicate) AS Duplicate
						FROM #tablename#
						WHERE Duplicate = 1
						AND Reason = 'Duplicate item'
						AND  InDB = 0
					</cfquery>
					<cfset DuplicateTotal = #GetDupCount.Duplicate#>
				<cfelse>
					<cfset DuplicateTotal = #ArrayLen(Validation.DuplicateData)#>
				</cfif>
				<td width="80%" align="left" class="InValidCategory">Duplicate Records <br>
					<table align="right" class="Maintable">
						<cfif fromPrgUpload>
							<cfif DuplicateTotal>
								<a onClick="javascript: return showDetails(0);" style="cursor:pointer;font-size:12px;font-weight: lighter;">#application.util.string.actionLinkFormat("view list of duplicate records")#</a>
							</cfif>
						<cfelse>
							<cfloop index="i" from="1" to="#ArrayLen(Validation.DuplicateData)#" step="1">
								<tr>
									<td>#Validation.DuplicateData[i]#</td>
								</tr>
							</cfloop>
						</cfif>
  					</table>
				</td>
				<td width="20%" align="right" class="InValidCategory">#DuplicateTotal#</td>
			</tr>
		<cfif fromPrgUpload>
			<tr HEIGHT="10">
				<cfquery name="GetRemovedCount" datasource="#application.datasource#">
					SELECT count(Removed) AS Removed
					FROM #tablename#
					WHERE Removed = 1
					AND Reason = 'Deleted Record'
					AND  InDB = 0
				</cfquery>
				<td width="80%" align="left" class="InValidCategory">Deleted Records <br>
				<cfif GetRemovedCount.Removed>
					<a onClick="javascript: return showDetails(1);" style="cursor:pointer;font-size:12px;font-weight: lighter;">#application.util.string.actionLinkFormat("view list of deleted records")#</a>
				</cfif>
				</td>
				<td width="20%" align="right" class="InValidCategory">#GetRemovedCount.Removed#</td>
			</tr>
                  	</cfif>
  			<tr HEIGHT="10" >
				<td width="80%" align="left" class="ValidCategory">Total Records</td>
				<cfset totalRecords =  ValidTotal + inValidTotal + DuplicateTotal>
				<cfif fromPrgUpload>
					<cfset totalRecords =  totalRecords + GetRemovedCount.Removed>
				</cfif>
				<td width="20%" align="right" class="ValidCategory">#totalRecords#</td>
			</tr>
		</table>
		<BR><BR>
		<!--- Dev Note: kvangapalli;  D13278: Make the create list tool just like the distributor search --->
		<cfset itemList = ListQualify(ArrayToList(Validation.ValidListData, ","), "'", ",", "ALL") >
		<blockquote style="color:red;font-weight:bold;font-style:italic;">
			Only valid items which are allowed on<BR> this template type will be returned
			<cfif fromPrgUpload>
				<br><br>Duplicate item will update rate/UOM of item.
			</cfif>
		</blockquote>
		<table>
			<tr>
				<td>
					<cfif fromPrgUpload AND ProductGroupLevelIdCount GT 1 AND ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') neq '1'>
						<cfset action = "showDetails(3);">
						<cfset caption = "Pricing Level Picker">
					<cfelse>
						<cfparam name="GetRemovedCount.Removed" default="0">
						<cfset action = "contHandler(#inValidTotal#,#DuplicateTotal#,#ValidTotal#,#GetRemovedCount.Removed#);">
						<cfset caption = "Continue">
					</cfif>
					<CF_button
						button_name		=	""
						button_caption	=	"#caption#"
						button_action	=	"#action#"
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
					<cfif fromPrgUpload>
						<cfset buttonaction = "window.history.back();">
					<cfelse>
						<cfset buttonaction = "document.all.frmCallBack.submit();">
					</cfif>
					<CF_button
						button_name		=	""
						button_caption	=	"Back"
						button_action	=	"#buttonaction#"
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
<!--- THIS FORM USED TO SUBMIT UPLOAD REBATE DATA --->
<cfif fromPrgUpload>
	<FORM action="Create_Product_Rate_List.cfm?discountype=<cfoutput>#form.discountype#</cfoutput>" METHOD="post" NAME="UploadSubmit" ID="UploadSubmit" STYLE="DISPLAY:INLINE" target="_self">
		<input type="hidden" name="programid" value="<cfoutput>#form.Program_ID#</cfoutput>" >
		<input type="hidden" name="finalSave" id="finalSave" value="0" >
	</FORM>
<cfelse>
	<form name="frmCallBack" id="frmCallBack" <cfoutput>action="createListForm.cfm?CID=#URL.CID#&ProgramID=#url.ProgramID#"</cfoutput> method="post">
		<input type="hidden" name="hiddenForm" id="hiddenForm" value="<cfoutput>#form.hiddenForm#</cfoutput>">
		<input type="hidden" name="passObj" id="passObj" value="<cfoutput>#form.thisObject#</cfoutput>">
		<input type="hidden" name="validList" id="validList" value="<cfoutput>#trim(ArrayToList(Validation.ValidData))#</cfoutput>">
		<input type="hidden" name="invalidList" id="invalidList" value="<cfoutput>#trim(ArrayToList(Validation.InValidData))#</cfoutput>">
	</form>
</cfif>
</body>
</html>

<script>
	function contHandler(invalidCount, duplicateCount, validCount, deletedCount) {
		<cfwddx action = "CFML2JS" input = "#itemList#" topLevelVariable = "itemList" >
		if (!itemList)
			itemList = 0;
		if (invalidCount > 0 || duplicateCount > 0)	{
			var rv = confirm("Data has" + "\n" + invalidCount + " Invalid records" + "\n" + duplicateCount + " duplicate records" + "\n" + deletedCount + " deleted records" + "\n" + "Select OK only returns " + validCount + " valid records.");
			if (!rv)
			return false;
		}
	<cfif fromPrgUpload>
		document.getElementById('finalSave').value=1;
		document.UploadSubmit.submit();
		show_loader( "SAVING CHANGES, PLEASE WAIT...");
	<cfelse>
		callerWindowObj = null;
		// ChromeFix :: dialogArguments is not defined
	  	if(typeof dialogArguments != 'undefined'){
			callerWindowObj = dialogArguments;
		}else{
			/* "window.parent.parent" for Chrome. I think the last ".parent" is needed because a new window
			is spawned when "showModalDialog" is used for Chrome - "Script\javascript\nonIE.js".
			With a regular popup, "window.parent.opener" is used.
			*/
			callerWindowObj = window.parent.parent;
		}
		var currForm = document.getElementById("hiddenForm").value;
		eval("callerWindowObj.document.all." + currForm + ".passed_form.value = 'comCreateListForm' ");
		eval("callerWindowObj.document.all." + currForm + ".itemList.value" + "=" + "\"" + itemList + "\"");
		show_loader( "SAVING CHANGES, PLEASE WAIT...");
		eval("callerWindowObj.document.all." + currForm + ".submit()" );
		window.parent.close();
		return true;
	</cfif>
	}
function showDetails(id){
	var sURL = "Create_Product_Rate_List_Error.cfm?type=Invalid&programId=<cfoutput>#form.Program_ID#&discountype=#form.discountype#</cfoutput>&selectedTab="+id;
	if(id ==3){
		var winName = 'productRateList';
		window.location.href = sURL;
	}else{
		var winName = 'Upload Errors';
		NewWindowTopLeft(sURL, winName, "600", "500", "no","no","yes", "yes");
	}
}
</script>