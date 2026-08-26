<cfparam name="URL.ItemLanguageCode" default="">
<cfparam name="URL.delLanguageCode" default="">
<cfparam name="URL.renameLangCode" default="">
<cfparam name="URL.newLangCodeName" default="">
<cfparam name="URL.NewItemLanguageCode" default="0" type="boolean">

<!--- DELETE LABEL SET --->
<cfif URL.delLanguageCode NEQ "">
	<cfset updateNotice =  request.qLabels.DeleteItemLanguageCode(URL.delLanguageCode)>
	<cfset genSettingsManager.save(13) />
</cfif>

<!--- RENAME LABEL SET --->
<cfif URL.renameLangCode NEQ "">
	<cfset updateNotice =  request.qLabels.RenameItemLanguageCode(URL.renameLangCode,URL.newLangCode)>
	<cfset genSettingsManager.save(13) />
	<cfset URL.ItemLanguageCode = URL.newLangCode>
</cfif>

<!--- NEW LABEL --->
<cfif URL.newLangCodeName NEQ "">
	<cfset updateNotice =  request.qLabels.CreateNewItemDesc(URL.newLangCodeName,URL.newItemNumber,URL.newItemDescription)>
	<cfset genSettingsManager.save(13) />
	<cfset URL.ItemLanguageCode = URL.newLangCodeName>
</cfif>

<!--- GET LABEL SET VALUES --->
<cfif URL.ItemLanguageCode NEQ "">
	<cfset getItemLanguageDescByCode = request.qLabels.GetItemLanguageDescByCode(URL.ItemLanguageCode)>
	<cfset getItemLangDescCode = request.qLabels.GetItemLangDescCode(getItemLanguageDescByCode.language_code)>
</cfif>

<!--- FILL IN DEFAULT LABELS IN TABLE WHEN CREATING NEW --->
<cfif URL.NewItemLanguageCode>
	<cfset getItemLanguageDescByCode = request.qLabels.getItemLanguageDescByCode("",false)>
</cfif>

<!--- GET ITEM DESCRIPTION CODES --->
<cfset GetItemLanguageCode = request.qLabels.GetItemLanguageCode()>

<!--- NAVIGATION SESSION VARIABLES TO MAINTAIN CURRENT LABEL MODE --->
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfoutput>
<!--- <style>div {border:1px solid black;}</style> --->
<script>
// REDIRECTS THE USER BASED ON MODE SELECTION
function selectSet(dropdown)
{
    var myindex  = dropdown.selectedIndex;
    var baseURL = dropdown.options[myindex].value;
    location.href = baseURL;

    return true;
}
</script>

<cfset navURLBase = "#labelURL##session.labelMode#&appSetCode=#session.appSetCode#&incFile=#session.incFile#">

<!--- LABEL MODE SELECTION DROPDOWN --->
<form name="itemLangCode" method="post">
	<div id="masterContainer">
		Item Language Description Code:
			<select name="ItemLanguageCode" onchange="selectSet(this.form.ItemLanguageCode);">
				<option value="#navURLBase#">** Select Language Code -->#RepeatString("&nbsp;",20)#</option>
				<cfloop query="GetItemLanguageCode">
					<cfset ItemLanguageCode = GetItemLanguageCode.Language_Code>
					<cfset navURLEdit = "#navURLBase#&ItemLanguageCode=#ItemLanguageCode#">
					<option value="#navURLEdit#" <cfif URL.ItemLanguageCode EQ ItemLanguageCode>style="color:red;" selected</cfif>>
						<cfif URL.ItemLanguageCode EQ ItemLanguageCode>
							#ucase("#ItemLanguageCode#")#
						<cfelse>
							#ItemLanguageCode#
						</cfif>
					</option>
				</cfloop>
			</select>
		<cfif NOT URL.NewItemLanguageCode>
			<cfset navURLNew = "#navURLBase#&NewItemLanguageCode=1">
			<a href="#navURLNew#">Create New</a> | <a href="##" onclick="
					if($('FileUploadDiv').style.display == 'none') {
						new Effect.BlindDown('FileUploadDiv',{duration: .2});
					} else {
						new Effect.BlindUp('FileUploadDiv',{duration: .1});
					}
				">Upload .txt file</a>
		</cfif>
	</div>
</form>
<cfform method="post" enctype="multipart/form-data" name="uploadFile" action="#navURLBase#">
	<div id="FileUploadDiv"
		style="position:absolute;
				left:50px;
				width:500px;
				height:40px;
				display:none;
				border:1px solid black;
				background-color:##ffce84;
				padding:4px;
				filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=3, OffY=3, Color='black', Positive='true')
					">
		<strong>Language Code File Upload:</strong><br />
			<cfinput type="file" name="txtFileName" size="60" style="height:20px;font-size:10px;">
			<cfinput type="submit" name="submit" value="Upload File" style="height:20px;font-size:10px;">
	</div>
</cfform>

<cfif isDefined("updateNotice")>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">#updateNotice#</strong>
	</div>
</cfif>

<cfif URL.ItemLanguageCode NEQ "" OR URL.NewItemLanguageCode>

<div id="masterContainer">

<cfif NOT URL.NewItemLanguageCode>
	<div id="MainBtnCont" align="left" style="width:50px;margin:2px 10px 2px 0;float:left;">
		<input
			type="button"
			onclick="
				if($('newLangCodeDesc').style.display == 'none') {
					new Effect.BlindDown('newLangCodeDesc',{duration: .2});
					new Effect.BlindDown('note',{duration: .2});
					this.value = 'Cancel Add';
				} else {
					new Effect.BlindUp('newLangCodeDesc',{duration: .1});
					new Effect.BlindUp('note',{duration: .2});
					this.value = 'Add Label';
				}
			"
			value="Add Code">
	</div>
	<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
		<div id="MainBtnCont" align="left" style="width:50px;margin:2px 10px 2px 0;float:left;">
			<input type="button" onclick="
					if (confirm('Are you sure you want to delete label set (#URL.ItemLanguageCode#)?')){
					    location.href = '#navURLBase#&delLanguageCode=#URL.ItemLanguageCode#';
					}
			"
			value="Delete Code">
		</div>
	</CFIF>
	<div id="MainBtnCont" align="left" style="width:50px;margin:2px 10px 2px 0;float:left;">
		<input type="button" onclick="new Effect.Appear('renameLangCodeForm',{duration: .3});" value="Rename Code">
	</div>
	<div id="renameLangCodeForm"
		style="position:absolute;
			width:200px;
			height:40px;
			display:none;
			border:1px solid black;
			background-color:##ffce84;
			padding:4px;
			filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=3, OffY=3, Color='black', Positive='true')
				">
		<cfset actionURL = navURLBase & "&renameLangCode=#URL.ItemLanguageCode#">
		New Code:<br />
		<input id="newLangCode" type="text" name="newLangCode" maxlength="1" size="4">
		<input type="button" value="Save" onclick="
				var newName = $('newLangCode').value;
				var url = '#actionURL#&newLangCode='+newName;
				location.href = url;
					">
		<div style="cursor:pointer;float:right;">
			<span onmouseover="this.style.color='green',this.style.fontWeight='bold'"
				onmouseout="this.style.color='',this.style.fontWeight=''"
				onclick="new Effect.Fade('renameLangCodeForm',{duration: .5});">
					[ X ]
			</span>
		</div>
	</div>

</cfif>

<form name="itemLanguageModify" action="#navURLBase#" method="post">
<cfif URL.NewItemLanguageCode>
	<div style="margin:0px;padding:0px;">Enter a new Code: <input name="LangCode" type="text" size="4" maxlength="1"></div>
	<input type="hidden" name="itemLanguageModify" value="2">
<cfelse>
	<input name="LangCode" type="hidden" value="#URL.ItemLanguageCode#">
	<input type="hidden" name="itemLanguageModify" value="1">
</cfif>

	<div id="MainBtnCont" align="right" style="width:40px;padding-right:15px;margin-top:2px;margin-bottom:2px;float:right;">
		<CF_button
				button_name		=	"itemLanguageModify"
				button_caption	=	"save"
				button_action	=	"itemLanguageModify.submit(document.itemLanguageModify);"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"10"
				font_weight		=	"bold"
				>
	</div>

	<div id="headerContainer">
		<div id="innerHeaderContainer">Item Number</div>
		<div id="innerHeaderContainer">Alternate Description</div>
		<cfif NOT URL.NewItemLanguageCode>
			<div id="innerHeaderContainerSM" style="float:right;">Active</div>
		</cfif>
	</div>
	<div id="newLangCodeDesc" style="background-color:##BBB;display:none;">
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				New: <input type="text" name="newItemNumber">
			</div>
			<div id="innerBodyContainer">
				<input type="text" name="newItemDescription" size="70">
				<input type="hidden" value="1" name="NewActive">
			</div>
			<div id="innerBodyContainerSM" nowrap style="text-align:left;float:left;">
				<cfset actionURLnewLangCodeName = navURLBase & "&newLangCodeName=#URL.ItemLanguageCode#">
				<input
					type="button"
					name="newLableSave"
					value="Add"
					onclick="
					var newItemNumber = $('newItemNumber').value;
					var newItemDescription = $('newItemDescription').value;
					var url = '#actionURLnewLangCodeName#&newItemNumber='+newItemNumber+'&newItemDescription='+newItemDescription;
					location.href = url;
				">
			</div>
		</div>
	</div>
	<div id="note" style="display:none;">
		<strong style="color:red; font-size:12px;">NOTE** These labels are case sensitive, (i.e. "case sensitive" will not match "Case sensitive").</strong>
	</div>
	<cfset rowCounter = 0>
<cfif URL.NewItemLanguageCode>
	<cfloop from="1" to="50" index="i">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<input type="hidden" name="loopCnt" value="#rowCounter#">
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				<input type="text" name="ItemNumber#rowCounter#">
			</div>
			<div id="innerBodyContainer">
				<input type="text" name="ItemDescription#rowCounter#" size="70">
			</div>
		</div>
	</cfloop>
<cfelse>
	<cfloop query="getItemLanguageDescByCode">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
	<input type="hidden" name="program_summary_label_item_id#rowCounter#" value="#getItemLanguageDescByCode.program_summary_label_item_id#">
	<input type="hidden" name="loopCnt" value="#rowCounter#">
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#getItemLanguageDescByCode.item_number# <input type="hidden" name="ItemNumber#rowCounter#" value="#getItemLanguageDescByCode.item_number#">
			</div>
			<div id="innerBodyContainer">
				<input type="text" onKeyUp="modified();" name="ItemDescription#rowCounter#" value="#getItemLanguageDescByCode.item_description#" size="70">
			</div>
			<div id="innerBodyContainerSM" nowrap style="text-align:center;float:right;">
				<div nowrap
					style="text-align:center; padding:5 6 3 6;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
							modified();
							var imgYes = $('imgYes#rowCounter#');
							var imgNo = $('imgNo#rowCounter#');
							var box = $('box#rowCounter#');
							if (imgYes.style.display == 'none') {
								imgYes.style.display='block';
								imgNo.style.display='none';
								box.checked=true;
							} else {
								imgYes.style.display='none';
								imgNo.style.display='block';
								box.checked=false;
							}
						">
				<cfif getItemLanguageDescByCode.active EQ 1>
					<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
					<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
				<cfelse>
					<cfif getItemLanguageDescByCode.item_description NEQ "">
						<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
				</cfif>
				<input id="box#rowCounter#"
						type="checkbox"
						value="1"
						name="Active#rowCounter#"
						style="display:none;"
						<cfif getItemLanguageDescByCode.active EQ 1>
							CHECKED
						</cfif>
						>

				</div>
			</div>
		</div>
	</cfloop>
</cfif>
	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	"itemLanguageModify"
				button_caption	=	"save"
				button_action	=	"itemLanguageModify.submit(document.itemLanguageModify);"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"10"
				font_weight		=	"bold"
				>
	</div>
</form>
</div>
</cfif>
</cfoutput>
