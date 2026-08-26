<cfparam name="URL.ProgramLabelSet" default="">
<cfparam name="URL.delLabelSet" default="">
<cfparam name="URL.renameLabelSet" default="">
<cfparam name="URL.newLabel" default="">
<cfparam name="URL.NewProgramLabelSet" default="0" type="boolean">

<!--- DELETE LABEL SET --->
<cfif URL.delLabelSet NEQ "">
	<cfset updateNotice =  request.qLabels.DeleteProgramLabelSet(URL.delLabelSet)>
	<cfset genSettingsManager.save(13) />
</cfif>

<!--- RENAME LABEL SET --->
<cfif URL.renameLabelSet NEQ "">
	<cfset updateNotice =  request.qLabels.RenameProgramLabelSet(URL.renameLabelSet,URL.newLabelSetName)>
	<cfset genSettingsManager.save(13) />
	<cfset URL.ProgramLabelSet = URL.newLabelSetName>
</cfif>

<!--- NEW LABEL --->
<cfif URL.newLabel NEQ "">
	<cfset updateNotice =  request.qLabels.CreateNewLabel(URL.newLabel,URL.newBALabel,URL.newCustLabel,URL.ItemDescriptions)>
	<cfset genSettingsManager.save(13) />
	<cfset URL.ProgramLabelSet = URL.newLabel>
</cfif>

<!--- GET LABEL SET VALUES --->
<cfif URL.ProgramLabelSet NEQ "">
	<cfset getProgramLabelSetBySetName = request.qLabels.GetProgramLabelSetBySetName(URL.ProgramLabelSet)>
	<cfset getProgramLabels = request.qLabels.getProgramLabels(URL.ProgramLabelSet,false)>
	<cfset getItemLangDescCode = request.qLabels.GetItemLangDescCode(getProgramLabelSetBySetName.item_language_code)>
</cfif>

<!--- FILL IN DEFAULT LABELS IN TABLE WHEN CREATING NEW --->
<cfif URL.NewProgramLabelSet>
	<cfset getProgramLabels = request.qLabels.getProgramLabels("",false)>
</cfif>

<!--- GET LABEL SET NAMES FOR DROPDOWN NAVIGATION --->
<cfset getProgramLabelSetNames = request.qLabels.GetProgramLabelSetNames()>

<!--- GET ITEM DESCRIPTION CODES --->
<cfset GetItemLanguageCode = request.qLabels.GetItemLanguageCode()>

<!--- NAVIGATION SESSION VARIABLES TO MAINTAIN CURRENT LABEL MODE --->
<cfif URL.labelMode NEQ "">
	<cfset session.labelMode = URL.labelMode>
</cfif>
<cfif URL.appSetCode NEQ "">
	<cfset session.appSetCode = URL.appSetCode>
</cfif>
<cfif URL.incFile NEQ "">
	<cfset session.incFile = URL.incFile>
</cfif>

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
<form name="labelSetSelect" method="post">
<div id="masterContainer">
	Program Label Set:
	<select name="ProgramLabelSet" onchange="selectSet(this.form.ProgramLabelSet);">
		<option value="#navURLBase#">** Select Label Set -->#RepeatString("&nbsp;",20)#</option>
		<cfloop query="getProgramLabelSetNames">
			<cfset ProgramLabelSet = getProgramLabelSetNames.Label_Set_Name>
			<cfset navURLEdit = "#navURLBase#&ProgramLabelSet=#ProgramLabelSet#">
			<option value="#navURLEdit#" <cfif URL.ProgramLabelSet EQ ProgramLabelSet>style="color:red;" selected</cfif>>
				<cfif URL.ProgramLabelSet EQ ProgramLabelSet>
					#ucase("#ProgramLabelSet#")#
				<cfelse>
					#ProgramLabelSet#
				</cfif>
			</option>
		</cfloop>
	</select>
	<cfif NOT URL.NewProgramLabelSet>
		<cfset navURLNew = "#navURLBase#&NewProgramLabelSet=1">
		<a href="#navURLNew#">Create New</a>
	</cfif>
</div>
</form>

<cfif isDefined("updateNotice")>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">#updateNotice#</strong>
	</div>
</cfif>

<cfif URL.ProgramLabelSet NEQ "" OR URL.NewProgramLabelSet>


<form name="frmprogramLabelsModify" action="#navURLBase#" method="post">
<cfif NOT URL.NewProgramLabelSet>
<div id="masterContainer" style="border-top:1px solid black; padding-top:4px;">
	<div id="MainBtnCont" align="left" style="width:500px;margin-top:2px;margin-bottom:2px;float:left;">
		Item Language Description Code:
		<select name="ItemDescriptions" onchange="modified();">
			<option value="">Default Descriptions</option>
			<cfloop query="GetItemLanguageCode">
				<cfset langCode = GetItemLanguageCode.Language_Code>
				<option value="#langCode#" <cfif langCode EQ getItemLangDescCode>selected</cfif>>
					#langCode#
				</option>
			</cfloop>
		</select>
	</div>
</div>
</cfif>

<div id="masterContainer">

<cfif NOT URL.NewProgramLabelSet>
	<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
		<div id="MainBtnCont" align="left" style="width:100px;margin-top:2px;margin-bottom:2px;float:left;">
			<input type="button" onclick="
					if (confirm('Are you sure you want to delete label set (#URL.ProgramLabelSet#)?')){
					    location.href = '#navURLBase#&delLabelSet=#URL.ProgramLabelSet#';
					}
			"
			value="Delete Set">
		</div>
	</CFIF>
	<div id="MainBtnCont" align="left" style="width:100px;margin-top:2px;margin-bottom:2px;float:left;">
		<input
			type="button"
			onclick="
				if($('newLabel').style.display == 'none') {
					new Effect.BlindDown('newLabel',{duration: .2});
					new Effect.BlindDown('note',{duration: .2});
					this.value = 'Cancel Add';
				} else {
					new Effect.BlindUp('newLabel',{duration: .1});
					new Effect.BlindUp('note',{duration: .2});
					this.value = 'Add Label';
				}
			"
			value="Add Label">
	</div>
	<div id="MainBtnCont" align="left" style="width:100px;margin-top:2px;margin-bottom:2px;float:left;">
		<input type="button" onclick="new Effect.Appear('renameLabelSetForm',{duration: .3});" value="Rename Set">
	</div>
	<div id="renameLabelSetForm"
		style="position:absolute;
			width:250px;
			height:40px;
			display:none;
			border:1px solid black;
			background-color:##ffce84;
			padding:4px;
			filter:progid:DXImageTransform.Microsoft.dropshadow(OffX=3, OffY=3, Color='black', Positive='true')
				">
		<cfset actionURL = navURLBase & "&renameLabelSet=#URL.ProgramLabelSet#">
		New Name:<br />
		<input id="newLabelSetName" type="text" name="newLabelSetName">
		<input type="button" value="Save" onclick="
				var newName = $('newLabelSetName').value;
				var url = '#actionURL#&newLabelSetName='+newName;
				location.href = url;
					">
		<div style="cursor:pointer;float:right;">
			<span onmouseover="this.style.color='green',this.style.fontWeight='bold'"
				onmouseout="this.style.color='',this.style.fontWeight=''"
				onclick="new Effect.Fade('renameLabelSetForm',{duration: .5});">
					[ X ]
			</span>
		</div>
	</div>

</cfif>
	<cfset rowCounter = 0>
<cfif URL.NewProgramLabelSet>
	<div style="margin:0px;padding:0px;">Enter a name for this new Label Set: <input name="labelSetName" type="text" size="30" maxlength="25"></div>
	<input type="hidden" name="programLabelsModify" value="2">
<cfelse>
	<input name="labelSetName" type="hidden" value="#URL.ProgramLabelSet#">
	<input type="hidden" name="programLabelsModify" value="1">
</cfif>

	<div id="MainBtnCont" align="right" style="width:40px;padding-right:15px;margin-top:2px;margin-bottom:2px;float:right;">
		<CF_button
				button_name		=	"programLabelsModify"
				button_caption	=	"save"
				button_action	=	"frmprogramLabelsModify.submit(document.programLabelsModify);"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"10"
				font_weight		=	"bold"
				>
	</div>
<cfif NOT (URL.NewProgramLabelSet)>
	<div id="headerContainer">
		<div id="innerHeaderContainer">Default Label</div>
		<div id="innerHeaderContainer">Client Label</div>
		<cfif NOT URL.NewProgramLabelSet>
			<div id="innerHeaderContainerSM" style="float:right;">Active</div>
		</cfif>
	</div>
	<div id="newLabel" style="background-color:##BBB;display:none;">
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				New: <input type="text" name="NewBALabel">
			</div>
			<div id="innerBodyContainer">
				<input type="text" name="NewCustomLabel" size="70">
				<input type="hidden" value="1" name="NewActive">
			</div>
			<div id="innerBodyContainerSM" nowrap style="text-align:left;float:right;">
				<cfset actionURLNewLabel = navURLBase & "&newLabel=#URL.ProgramLabelSet#">
				<input
					type="button"
					name="newLableSave"
					value="Add"
					onclick="
					var newBALabel = $('NewBALabel').value;
					var newCustLabel = $('NewCustomLabel').value;
					var ItemDescriptions = $('ItemDescriptions').value;
					var url = '#actionURLNewLabel#&newBALabel='+newBALabel+'&newCustLabel='+newCustLabel+'&ItemDescriptions='+ItemDescriptions;
					location.href = url;
				">
			</div>
		</div>
	</div>
	<div id="note" style="display:none;">
		<strong style="color:red; font-size:12px;">NOTE** These labels are case sensitive, (i.e. "case sensitive" will not match "Case sensitive").</strong>
	</div>

	<cfloop query="getProgramLabels">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
	<input type="hidden" name="program_summary_labels_id#rowCounter#" value="#getProgramLabels.program_summary_labels_id#">
  <input type="hidden" name="loopCnt" value="#rowCounter#">
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#getProgramLabels.ba_label# <input type="hidden" name="BALabel#rowCounter#" value="#getProgramLabels.ba_label#">
			</div>
			<div id="innerBodyContainer">
				<cfif URL.NewProgramLabelSet>
					<input type="text" name="CustomLabel#rowCounter#" size="70">
				<cfelse>
					<input type="text" onKeyUp="modified();" name="CustomLabel#rowCounter#" value="#getProgramLabels.custom_label#" size="70">
				</cfif>
			</div>
			<cfif NOT URL.NewProgramLabelSet>
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
					<cfif getProgramLabels.active EQ 1>
						<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<cfif getProgramLabels.custom_label NEQ "">
							<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
							<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
						</cfif>
					</cfif>
					<input id="box#rowCounter#"
							type="checkbox"
							value="1"
							name="Active#rowCounter#"
							style="display:none;"
							<cfif getProgramLabels.active EQ 1>
								CHECKED
							</cfif>
							>

					</div>
				</div>
			<cfelse>
				<input type="hidden" value="1" name="Active#rowCounter#">
			</cfif>
		</div>
	</cfloop>



	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	"programLabelsModify"
				button_caption	=	"save"
				button_action	=	"frmprogramLabelsModify.submit(document.programLabelsModify);"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"10"
				font_weight		=	"bold"
				>
	</div>
</cfif>
  <cfif rowCounter EQ 0 OR URL.NewProgramLabelSet>
    <cfset rowCounter = 1 />
	  <input type="hidden" name="loopCnt" value="#rowCounter#">
    <input type="hidden" name="program_summary_labels_id1" value="1" />
    <input type="hidden" name="BALabel1" />
    <input type="hidden" name="CustomLabel1" />
  </cfif>

</form>
</div>
</cfif>
</cfoutput>
