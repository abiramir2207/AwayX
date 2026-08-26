<!-----------------------------------------------------------------------------
FILE NAME:		Custom_Dedcution_Workflow.cfm
DESCRIPTION: This file has code for custom dedecution work flow which was introdcued in WR 70923 for Kerry Foods.
CREATED BY:		Dinesh 08/16/2017
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
------------------------------------------------------------------------------>
<cfset jQuery.version ="1.12.4">
<cfset jQueryUI.version ="1.12.1">

<cfinclude template="/Common_Files/jQuery.cfm">
<script src="/Script/javascript/dhtml.js" type="text/javascript"></script>
<script src="/script/javascript/chosen/chosen.jquery.js" type="text/javascript"></script>
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<link rel="stylesheet" href="/styles/chosen/chosen.css" type="text/css">
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<div style="width:100%;color:Navy;text-align:center;font-size:13px;font-weight:bold;">REASSIGN DEDUCTION</div>
<HR COLOR="Navy"><BR>
<cfset disableBasedOnClassification = 0>
<cfset  DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
<cfset disableBasedOnClassification = DeductionManager.DisableLinks(URL.Deduction_ID,1)/>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

	<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
	<cfif useLakebaseForDeductionsProfilesSettings>
		<cftry>
			<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions_profiles_settings", {
					"select" = "dd_internal_notes,dd_access_level",
					"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
				}),
				"dd_internal_notes,dd_access_level"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDeductionsProfilesSettings = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeductionsProfilesSettings>
	<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
		SELECT DD_Internal_Notes, DD_ACCESS_LEVEL
		FROM Deductions_Profiles_Settings
		WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</cfquery>
	</cfif>

	<cfset useLakebaseForDD_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDD_Details>
		<cftry>
			<cfset DD_Details = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"deduction_id" = "eq.#URL.Deduction_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDD_Details = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDD_Details>
	<CFQUERY NAME="DD_Details" DATASOURCE="#Application.Datasource#">
		SELECT * 
		FROM Deductions 
		WHERE Deduction_ID = '#URL.Deduction_ID#'
	</CFQUERY>
	</cfif>

	<CFQUERY NAME="Get_All" DATASOURCE="#Application.Datasource#">
		SELECT 		Deduction_ID,
					DD_DedID,
					SP_Number,
					DD_Amount,
					BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Ship_To,
					_Users.Name_First,
					_Users.Name_Last,
					Deductions.Is_Locked,
					Locked_By,
					DD_DedID_SP_Number
		FROM 		Deductions
		LEFT JOIN	BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		AND BSA_Foodservice_Customers.Deleted=0
		<!--- Change users left join to Inner join once saru is done with his job. --->
		LEFT JOIN	_Users
		ON _Users.User_ID = Deductions.Analyst_User_ID
		AND _Users.Deleted=0
		WHERE 		DD_DedID = '#DD_Details.DD_DedID#'
		AND 	Deductions.Deleted=0
		AND   Deductions.DD_Status NOT IN (4,5)
		ORDER BY 	SP_Number
	</CFQUERY>

<!--- Get Classifications List --->
<cfset useLakebaseForGet_Classifications = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForGet_Classifications>
	<cftry>
		<cfset Get_Classifications = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"deleted" = "eq.0",
				"order" = "dd_classification_desc.asc"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Classifications = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Classifications>
<CFQUERY NAME="Get_Classifications" datasource="#application.datasource#">
	Select		*
	From		DD_Classification
	Where Deleted = 0
	Order by	DD_Classification_Desc
</CFQUERY>
</cfif>
<!--- Get Action List --->
<cfset useLakebaseForGet_Actions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForGet_Actions>
	<cftry>
		<cfset Get_Actions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_stage", {
				"deleted" = "eq.0",
				"order" = "dd_stage_description.asc"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Actions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Actions>
<CFQUERY NAME="Get_Actions" datasource="#application.datasource#">
	Select		*
	From		DD_Stage
	Where Deleted = 0
	Order by	DD_Stage_Description
</CFQUERY>
</cfif>
<form name="Reassign" action="Custom_Deduction_Workflow_Action.cfm" method="Post">
<cfoutput>
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
	<INPUT TYPE="Hidden" NAME="URLDeduction_ID" VALUE="#URL.Deduction_ID#">
	<INPUT TYPE="Hidden" NAME="From_Analyst" VALUE="#DD_Details.Analyst_User_ID#">
	<INPUT TYPE="Hidden" NAME="Is_Parent" VALUE="#DD_Details.DD_IsParent#">
<CFIF Get_All.recordcount GT 1>
	<INPUT TYPE="Hidden" NAME="HaveSplit" VALUE="1">
<CFELSE>
	<INPUT TYPE="Hidden" NAME="HaveSplit" VALUE="0">
	<INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#URL.Deduction_ID#">
</CFIF>
	<INPUT TYPE="Hidden" NAME="Action_Completed" VALUE="0">
</cfoutput>

<CFIF Get_All.recordcount GT 1>

	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline" WIDTH="100%">
		<TR BGCOLOR="FFE083">
			<TD ID="header"><input TYPE="checkbox" NAME="allbox" onClick="javaScript: selectAll(this);"></TD>
			<TD STYLE="font-size : 11px;"><B>DEDUCTION #</B></TD>
			<TD STYLE="font-size : 11px;"><B>AMOUNT<BR><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></B></TD>
			<TD STYLE="font-size : 11px;"><B>ANALYST</B></TD>
		</TR>
		<CFOUTPUT QUERY="Get_All">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD VALIGN="Top"><INPUT TYPE="CheckBox" NAME="Deduction_ID" VALUE="#Deduction_ID#" <CFIF Is_Locked EQ 1 AND Locked_By NEQ request.AccessStructure.User_ID>DISABLED</CFIF>></TD>
			<TD VALIGN="Top" <CFIF URL.Deduction_ID EQ Deduction_ID>Title="Currently you are on this deduction"</CFIF>>
				<CFIF URL.Deduction_ID EQ Deduction_ID>
					<a>#application.util.string.actionLinkFormat2('#DD_DedID_SP_Number#')#</a>
				<CFELSE>
					#application.util.string.actionLinkFormat2('#DD_DedID_SP_Number#')#
				</CFIF>
				<CFIF SP_Number EQ "">
					<CFSET child_count = recordcount - 1>
					<img src="/Images/parent_New.gif" title="Original deductions." width="13" height="13" border="0">
				<CFELSE>
					<CFSET Original = "#DD_DedID#-000">
					<img src="/Images/child_New.gif" title="Split from original deduction." width="13" height="13" border="0">
				</CFIF>
			</TD>
			<TD VALIGN="Top" <CFIF Name NEQ "">TITLE="#application.returned_customer_setting.shard_ship_to_label#: #Ship_To#"</CFIF>>#DollarFormat(DD_Amount)#<BR><CFIF Name NEQ "">#Name#<CFELSE>None selected.</CFIF></TD>
			<TD VALIGN="Top">#Name_First# #Name_Last#&nbsp;</TD>
		</TR>
		</CFOUTPUT>
	</TABLE>
</CFif>
<div style="width: 100%;height: 25px">&nbsp;</div>
<table border="0">
	<tr>
		<td colspan="4" align="left" style="height: 25px;">&nbsp;<b>Reassign by Classification</b></td>
	</tr>
	<tr>
		<td colspan="4" align="left" style="height: 25px;"><input type="checkbox" name='updateClassification' value="1" id="updateClassification"><b>Only Update Classification</b></td>
	</tr>		
	<tr>
		<td width="5px"><span id="CR"><input type="radio" value="1" name="ReassignBy" id="ReassignBy"></span></td>
		<td>
			<select name="Classifications" id="classifications" style="width:250px" data-placeholder="Select a classification..." >
				<option value=""> </option>
				<cfoutput query="Get_Classifications">
					<option value="#DD_Classification_ID#">#DD_Classification_Desc#</option>
				</cfoutput>
			</select>
		</td>
		<td>
			<span id="CA">
			<select name="To_Analyst" id="ClassificationAnalyst" style="width:250px" data-placeholder="Select an Analyst..." >
				<option value=""> </option>
			</select>
			</span>
		</td>
		<td>
			<span id="CRC">
			<select name="Reason_code" id="ClassificationReasonCode" style="width:250px" data-placeholder="Select a Reason Code..." >
				<option value=""> </option>
			</select>
			</span>
		</td>
	</tr>
</table>
<div style="width: 100%;height: 25px">&nbsp;</div>
<HR COLOR="Navy">
<div style="width: 100%;height: 25px">&nbsp;</div>
	<table border="0" <cfif DD_Details.DD_Classification_ID EQ 0 OR disableBasedOnClassification EQ 1>Style="Display:none;"</cfif>>
	<tr>
		<td colspan="3" align="left" style="height: 25px;">&nbsp;<b>Reassign by Action</b></td>
	</tr>
	<tr>
		<td colspan="3" align="left" style="height: 25px;"><input type="checkbox" name='updateAction' value="1" id="updateAction"><b>Only Update Action</b></td>
	</tr>		
	<tr>
		<td width="5px"><span id="AR"><input type="radio" value="2" name="ReassignBy" id="ReassignBy"></span></td>
		<td>
			<select name="Actions" id="Actions" style="width:250px" data-placeholder="Select a Action..." >
				<option value="0">Select an action</option>
				<cfoutput query="Get_Actions">
					<option value="#DD_Stage_ID#">#DD_Stage_Description#</option>
				</cfoutput>
			</select>
			</td>
		<td>
			<span id="AA">
			<select name="To_Analyst" id="ActionAnalyst" style="width:250px" data-placeholder="Select an Analyst..." >
				<option value=""> </option>
			</select>
			</span>
		</td>
	</tr>
	<tr style="display:none;" id="aComments">
		<td colspan="2"><div style="font-weight:bold;font-size:12px;margin-top: 5px;margin-bottom: 5px;">Add a Comment</div>
		<textarea name="txtaComments" cols="100" rows="10" onPaste="javaScript: return textareaChecklength('500', this);"  onkeyPress="javaScript: return textareaChecklength('500', this);"></textarea>
		<br>
		<input type="radio" name="rdCommentsFlag" value="0" <cfif DeductionsProfilesSettings.DD_Internal_Notes neq 1>checked</cfif>>External
		<cfif DeductionsProfilesSettings.DD_Internal_Notes eq 1><input type="radio" name="rdCommentsFlag" value="1">Internal</cfif>
		</td>
	</tr>
</table>
<div style="width:98%;text-align: center;padding-top:5px;clear: both" align="middle">
<cfoutput>
	<cfif len(DD_Details.DD_User_Reference2)>
		<a href="javaScript:Validate();">#application.util.string.actionLinkFormat2('Reassign')#</a>	
	<cfelse>	
		<span title="Please update #stDeductionLabels["User Ref 2"]#" style="cursor: hand">#application.util.string.actionLinkFormat2('Reassign')#</span>
	</cfif>
</cfoutput>
</div>
</form>
<script type="text/javascript">
		$(document).ready(function(){
			$("#updateClassification").on('click', function(){
					if ( $(this).is(':checked') ) {
						$('#CA').hide();
						$('#CR').hide();
						$('#CRC').hide();
						$("input[name='ReassignBy']").attr("checked", false);
					} 
				else{
					$('#CA').show();
					$('#CR').show();
					$('#CRC').show();
				}
			})
			$("#updateAction").on('click', function(){
					if ( $(this).is(':checked') ) {
						$('#AA').hide();
						$('#AR').hide();
						$("input[name='ReassignBy']").attr("checked", false);
					} 
				else{
					$('#AA').show();
					$('#AR').show();
				}
			})
		$("#classifications,#ClassificationAnalyst,#Actions,#ActionAnalyst,#ClassificationReasonCode").chosen()
		//POPULATE CLASSIFICATION ANALYST DROP-DOWN
		 $( "#classifications" ).change( function( ){
								       		$.ajax( {
													type: "POST",
													url: "/components/Deduction/DeductionManager.cfc?method=getAnalystNames&ReturnFormat=json",
													data: ({	DDClassificationID: $(this).val()}),
													dataType: 'json',
													success: function(response){
															$('#ClassificationAnalyst').empty();
															if(response.DATA.length > 0){
													      for (var i = 0; i < response.DATA.length; i++){
													      		$('#ClassificationAnalyst').append('<option value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
													      }
												      }else{
													     	$('#ClassificationAnalyst').append('<option value="0">No Analyst</option>');
													    }
													    $('#ClassificationAnalyst').trigger("chosen:updated");
													},
													error: function(xhr, textStatus, errorThrown){ alert('request failed');}
												});
										});
			 $( "#classifications" ).change( function( ){
								       		$.ajax( {
													type: "POST",
													url: "/components/Deduction/DeductionManager.cfc?method=getClassificationReasonCode&ReturnFormat=json",
													data: ({	DDClassificationID: $(this).val()}),
													dataType: 'json',
													success: function(response){
															$('#ClassificationReasonCode').empty();
													if(response.DATA.length > 0){
																$('#ClassificationReasonCode').append('<option value="">Select a Reason Code</option>');
													      for (var i = 0; i < response.DATA.length; i++){
													      		$('#ClassificationReasonCode').append('<option value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
													      }
												      }else{
													     	$('#ClassificationReasonCode').append('<option value="0">No Reason Code</option>');
													   }
													    $('#ClassificationReasonCode').trigger("chosen:updated");
													},
													error: function(xhr, textStatus, errorThrown){ alert('request failed');}
												});
										});
		//POPULATE ACTION ANALYST DROP-DOWN
		 $( "#Actions" ).change(function(){
								       		$.ajax( {
													type: "POST",
													url: "/components/Deduction/DeductionManager.cfc?method=getAnalystNames&ReturnFormat=json",
													data: ({ DDStageID: $(this).val() }),
													dataType: 'json',
													success: function(response){
															$('#ActionAnalyst').empty();
															if(response.DATA.length > 0){
												       for (var i = 0; i < response.DATA.length; i++){
													      	$('#ActionAnalyst').append('<option value="' + response.DATA[i][0] + '">' + response.DATA[i][1] + '</option>');
													      }
													    }else{
													     	$('#ActionAnalyst').append('<option value="0">No Analyst</option>');
													    }
													    $('#ActionAnalyst').trigger("chosen:updated");
													},
													error: function(xhr, textStatus, errorThrown){ alert('request failed');}
												});
										});
		})
		$( "#Actions" ).change(function(){
			$("#aComments").show();
		})

function anyCheckBoxChecked(chObj){
	var bChecked = false;
	if(chObj.length){
		var i, chLen;
		chLen = chObj.length;
		for(i=0;i<chLen;i++){
			if(chObj[i].checked){
				bChecked = true;
				break;
			}
		}
	}else{
		if(chObj.checked){
			bChecked = true;
		}
	}
	return bChecked;
}
function selectAll(thisobj){
	var bCheck = thisobj.checked;
	var chObjs = document.all.Deduction_ID;

	if(chObjs.length){
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++){
			chObjs[i].checked = bCheck;
		}
	}else{
		chObjs.checked = bCheck;
	}
}
function Validate(){
	var x=document.Reassign;
	var submit_Ok = 1;
	var updateClassification = $('input[name=updateClassification]:checked').is(':checked');
	var updateAction = $('input[name=updateAction]:checked').is(':checked');

	//if(! updateClassification && ! updateAction){
		if	(x.HaveSplit.value == 1){
			if(!anyCheckBoxChecked(x.Deduction_ID)){
				alert("Please pick at least one deduction to reassign.");
				submit_Ok = 0
				return;
			}
		}
	//}
if( ! updateClassification && ! updateAction){
	if($('input[name=ReassignBy]:checked').length<=0){
		alert("Please pick type of reassign.");
		submit_Ok = 0
		return;
	}
}
else{
	if(updateClassification){
		if(x.Classifications.value =='' || x.Classifications.value ==0){
		alert("Please select option for classifications.");
		return;
		}
	}
	if(updateAction){
		if(x.Actions.value == '' || x.Actions.value == 0){
		alert("Please select option for actions.");
		return;
		}
	}
}
  if($("[name=ReassignBy]:checked").val() ==1 && (x.Classifications.value =='' || x.Classifications.value ==0)){
		alert("Please select option for classifications.");
		submit_Ok = 0
		return;
  }
  if($("[name=ReassignBy]:checked").val() ==2 && (x.Actions.value == '' || x.Actions.value == 0)){
		alert("Please select option for actions.");
		submit_Ok = 0
		return;
  }
  if($("[name=ReassignBy]:checked").val() ==2 && $('input[name=rdCommentsFlag]:checked').length<=0){
		alert("Please select type of comment.");
		submit_Ok = 0
		return;
  }

  if(!updateClassification){
	/* If an entry is selected for "Classifications", then a "reason code" needs to be selected as well. */
	if(x.Classifications.value !=='' && (x.ClassificationReasonCode.value =='' || x.ClassificationReasonCode.value ==0)){
		alert("Please select option for reason code");
		return;
	}
  }
	if (submit_Ok == 1){
		document.all.Form_Submitted.value=1;
		if($("[name=ReassignBy]:checked").val() ==2){
			document.all.Action_Completed=1;
		}
		document.Reassign.submit();
		//disableButton("reassign_table", true, false);
	}
}
</script>