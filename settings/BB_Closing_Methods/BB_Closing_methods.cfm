<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title>Document</title>
	<cfsavecontent variable="head_content">
		<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
		<cfset jQueryUI.version = "1.8.23">
		<cfset jQueryUI.widgets = "full">
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include files="/styles/css-loader.css, /Script/javascript/Ajax_JS/jquery.dimensions.js, /Script/javascript/Ajax_JS/jquery.suggest.js, /Script/javascript/Ajax_JS/jquery.suggest.css, /Script/javascript/dom_common.js">
		<style>
			#stored_records th {
				font-weight: bold;
				font-size: 12px;
				text-align: left;
				vertical-align: top;
			}
  			span.ui-displayRow { position2: absolute; margin-left2: -1.2em; display: inline-block; }
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<cfparam name="form.action" default="">
<!--- handle clicking on save sequence --->
<cfif form.action is "save_sequence">
	<cfloop collection="#form#" item="sequence">
		<cfif listFirst(sequence, "_") is "sequence">
			<cfquery name="update" datasource="#application.datasource#">
				UPDATE Billback_Closing_Methods
				   SET Display_Sequence = #form[ sequence ]#
				 WHERE iBillback_Closing_Method_ID = #listGetAt(sequence, 2, "_")#
			</cfquery>
		</cfif>
	</cfloop>
</cfif>

<!-----------------------------------------------------------------------------

FILE NAME:		BB_Closing_Methods.cfm
DESCRIPTION:	This file displays the settings for BB closing Methods
              [Done for D18281]
CREATED BY:		Anand Rao/27-May-09
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

------------------------------------------------------------------------------>

<!--- <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"> --->
<CFSET URL.PageTitle="Billback Closing Methods">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() /> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfquery NAME="Get_Data" datasource="#application.datasource#">
	SELECT	*
	FROM  	Billback_Closing_Methods
	WHERE Hide = 0
	ORDER BY Display_Sequence
</cfquery>
<!--- change the order to description when display sequences are not yet assigned --->
<cfif val(get_data.display_sequence) eq 0>
	<cfquery NAME="Get_Data" datasource="#application.datasource#">
		SELECT	*
		FROM  	Billback_Closing_Methods
		WHERE Hide = 0
		ORDER BY vchBillback_Closing_Method_Desc 
	</cfquery>
</cfif>

<cfquery NAME="getUpdatedBy" datasource="#application.datasource#">
	SELECT	 top 1 Updated_On,Updated_By
	FROM  	Billback_Closing_Methods
	WHERE Hide = 0
	ORDER BY Updated_On DESC
</cfquery>
<cfoutput>
<cfif isdefined("getUpdatedBy.Updated_By")>
	<cfinvoke component="components.user.usermanager" method="getusername" userid="#getUpdatedBy.Updated_By#" returnvariable="SettingsUpdateUser">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
		<TR><TD>
		<FONT SIZE="2"><B>The settings were last updated on #dateformat(getUpdatedBy.Updated_On, 'mm/dd/yyyy')# #timeformat(getUpdatedBy.Updated_On, 'hh:mm:ss TT')# by #SettingsUpdateUser#</B></FONT>
		</TD></TR>
	</TABLE>
	<br>
</cfif>
</cfoutput>

<p>Click & drag stored records using the mouse to place them in a desired sequence. This controls the closing methods order on billback basic info page.</p>
<table border="0" cellspacing="10" cellpadding="0" WIDTH="850">
		<tr>
			<td VALIGN="top" style="width:50%">
				<SPAN class="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<form name="stored_records" method="post">
					<input type="hidden" name="action" value="">
					<table border="0" cellspacing="0" cellpadding="2" class="Maintable" id="stored_records">
						<thead>
							<tr>
								<th>Description</th>
								<th>Status</th>
								<th>Default for <br>Manual BB</th>
								<!---97929 :: Quick Pay START--->
								<th>Default for <br>Advance QP</th>
								<!---97929 :: Quick Pay END--->
							</tr>
						</thead>
						<tbody class="sortable">
							<cfoutput QUERY="Get_Data">
								<tr>
									<td>
										<span class="ui-displayRow ui-icon ui-icon-arrowthick-2-n-s"></span>
										<A HREF="BB_Closing_Methods.cfm?BCID=#iBillback_Closing_Method_ID#">#vchBillback_Closing_Method_Desc#
											<cfif bEnabled EQ 1>(Enabled)<cfelse>(Disabled)</cfif>
										</A>
										<!---internal hidden input to keep track of sequence to save in db, value gets updated right after clicking on save--->
										<input type="hidden" name="sequence_#iBillback_Closing_Method_ID#" class="seq">
									</td>
									<td NOWRAP>
										<CFIF Deleted EQ 0>
											<IMG SRC="/images/yes_small.gif" TITLE="active record...">
										<CFELSE>
											<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
										</CFIF>
									</td>
									<td>
										<cfif bDefault eq 1>
											default
										<cfelseif bDefault eq 0 and Deleted eq 0>
											<A HREF="Save_Closing_Methods.cfm?BCID=#iBillback_Closing_Method_ID#&setDefault=1">
												#application.util.string.actionLinkFormat("set")#
											</A>
										<cfelse>
											inactive
										</cfif>
									</td>
									<!---97929 :: Quick Pay START--->
									<td>
										<cfif qpDefault eq 1>
											default
										<cfelseif qpDefault eq 0 and Deleted eq 0>
											<A HREF="Save_Closing_Methods.cfm?BCID=#iBillback_Closing_Method_ID#&setDefault=2">
												#application.util.string.actionLinkFormat("set")#
											</A>
										<cfelse>
											inactive
										</cfif>
									</td>
									<!---97929 :: Quick Pay END--->
									</tr>
							</cfoutput>
						</tbody>
					</table>
				</form>
				<BR>

				<span style="margin-right:20px;"><IMG SRC="/images/yes_small.gif" border="0" ALT="" ALIGN="middle"> - active record</span>
				<IMG SRC="/images/no_small.gif" border="0" ALT="" ALIGN="middle"> - inactive record<br>
				<div style="margin-top:9px;">
					<cfoutput><a href="##" id="save_sequence">#application.util.string.linkFormat("save sequence")#</a></cfoutput>
				</div>
			</td>
			<td VALIGN="top">

				<SPAN class="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.BCID" DEFAULT="0">

<CFPARAM NAME="Get_Item.DD_Reason_Code_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Need_Approval" DEFAULT="0">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">
<CFPARAM NAME="Get_Item.Show_Operator" DEFAULT="0">
<CFPARAM NAME="Get_Item.Closing_Method" DEFAULT="0">
<cfparam name="form.gl_account_code" default="" />

<cfquery NAME="Get_Item" datasource="#application.datasource#">
		SELECT	iBillback_Closing_Method_ID
					,vchBillback_Closing_Method_Desc
					,bEnabled
					,tiAutoPay_BB_Status
					,Deleted
					,Abbreviation
					,isnull(nullif(Payee_Type,''),0) As Payee_Selection
					,bDefault
					,Exclude_From_Payment_History
					,Vendor_Required
					,Require_bank_info
					,Allow_Operator_Payee
					,qpDefault
					,Display_In_Advance_QP <!---97929--->
	FROM  	Billback_Closing_Methods
	WHERE	iBillback_Closing_Method_ID	= #URL.BCID#
	AND Hide = 0
	ORDER BY Display_Sequence
</cfquery>

<cfquery NAME="getBBStatus" datasource="#application.datasource#">
	SELECT *
	FROM   Billback_Status
	WHERE  Billback_Status_ID IN (2,3,4)
	ORDER BY Billback_Status_ID
</cfquery>

	<SCRIPT language="JavaScript">
	function alert_and_delete(){
		var confirmdelete = confirm("Click OK to permanently inActivate this data. You won't be able to undo this change...");
		if (confirmdelete == true){
			document.all.DeleteRecord.value=1;
			document.MyForm.submit();
		}			
	}	
	function Validate(){
		show_loader("SAVING CHANGES...", 500);			
		document.all.MyForm.submit()
	} 
	</SCRIPT>	
	
	<FORM ACTION="save_Closing_Methods.cfm" METHOD="post" NAME="MyForm">
		<table cellspacing="10" cellpadding="0" border="0">
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Closing Method:</B></td>
				<td VALIGN="top">
					<cfif URL.BCID EQ 0>
						NONE SELECTED
					<cfelse>
					<cfoutput>
						#Get_Item.vchBillback_Closing_Method_Desc#
						<input type="hidden" name="BBClosingMethod_ID" value="#URL.BCID#" />
					</cfoutput>
					</cfif>				
				</td>
			</tr>
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Interface Enabled:</B></td>
				<td VALIGN="top">
					<cfoutput>
					<INPUT TYPE="CheckBox" NAME="chkEnabled" VALUE="1" <CFIF Get_Item.bEnabled EQ 1>CHECKED</CFIF>>
					</cfoutput><br>
					<font color="red"><strong>NOTE:</strong>  
						Before turning ON any closing methods, check with your system  
						administrator to see if the settlement interfaces are configured for the closing method
					</font>
				</td>
			</tr>
			<tr>
				<td VALIGN="top" ALIGN="right"><B>AutoPay Billback Status:</B></td>
				<td VALIGN="top">
					<select name="selBBStatus">
						<cfoutput query="getBBStatus">
							<option value="#Billback_Status_ID#" <cfif Get_Item.tiAutoPay_BB_Status EQ Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
						</cfoutput>
					</select>
				</td>
			</tr> 			 
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Availability:</B></td>
				<td VALIGN="top">
					<!--- Is this record deleted? --->
					<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
						<CFSET active=" CHECKED">
						<CFSET inactive="">
					<CFELSE>
						<CFSET active="">
						<CFSET inactive=" CHECKED">
					</CFIF>					
					<cfset disabled = "" />
					<CFIF Get_Item.bDefault EQ 1>
						<cfset disabled = "disabled" />
					</CFIF>
					<cfoutput>
						<INPUT TYPE="radio" VALUE="0" NAME="rdoDeleted"#active# #disabled#>Active&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="rdoDeleted"#inactive# #disabled#>Inactive
						<CFIF Get_Item.bDefault EQ 1>
							&nbsp;<img src="/images/help_small.gif" title="Default Closing Methods cannot be set to Inactive. Default another Closing Method to make this Inactive."/>
						</CFIF>
					</cfoutput>				
				</td>
			</tr>
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Exclude From Payment History:</B></td>
				<td VALIGN="top">
					<cfoutput>
						<INPUT TYPE="CheckBox" NAME="Exclude_From_Payment_History" VALUE="1" <CFIF Get_Item.Exclude_From_Payment_History EQ 1>CHECKED</CFIF>>
					</cfoutput>
				</td>
			</tr>
			<!---D55703 :: Vendor required setting in closing method settings panel START--->
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Vendor Required:</B></td>
				<td VALIGN="top">
					<cfoutput>
						<INPUT TYPE="CheckBox" NAME="Vendor_Required" VALUE="1" <CFIF Get_Item.Vendor_Required EQ 1>CHECKED</CFIF>>
					</cfoutput>
				</td>
			</tr>
			<!---D55703 :: Vendor required setting in closing method settings panel END--->
			<tr>
				<td VALIGN="top" ALIGN="right"><B>When a program has a claim mechanic set to auto pay and the user selects 'select payee', then search in the:</B></td>
				<td VALIGN="top">
					<!--- Dev Note: 20466 (I have added vendor as ID 5 in "Payment_Paid_To_Types" table). I chose ID 5 for consistency,as 1-4 are already taken  --->
					<select name="Payee_Selection">
						<option value="1" <cfif Get_Item.Payee_Selection EQ 1>selected</cfif>><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></option>
						<option value="5" <cfif Get_Item.Payee_Selection EQ 5 or Get_Item.Payee_Selection EQ 0>selected</cfif>>Vendor</option>
					</select>
				</td>
			</tr>		 
			<tr>
						<td valign="top" align="right"><B>Require Bank Info:</B></td>   <!--- 55346 --->
						<td valign="top">
             				<cfoutput>
								<input type="checkbox" name="require_bank_info" value="1" <cfif Get_Item.require_bank_info eq 1>checked</cfif>>
							</cfoutput>
						</td>
			</tr>
			<!--- Dev Note:(72368) - When "Closing method" is "credit memo" --->
			<cfif URL.BCID eq 5>
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Allow for Operator Payee:</B></td>
				<td VALIGN="top">
					<!--- Dev Note: 72368 - Allow for "operator" as a payee, when the closing method is "credit memo". --->
						<INPUT TYPE="CheckBox" NAME="Allow_Operator_Payee" VALUE="1" <CFIF Get_Item.Allow_Operator_Payee EQ 1>CHECKED</CFIF>>
				</td>
			</tr>
			</cfif>
		 <!---97929 :: Quick Pay START--->
			<tr>
				<td VALIGN="top" ALIGN="right"><B>Display in Advance QP:</B></td>
				<td VALIGN="top">
					<!--- Dev Note: 72368 - Allow for "operator" as a payee, when the closing method is "credit memo". --->
						<INPUT TYPE="CheckBox" NAME="Display_In_Advance_QP" VALUE="1" <CFIF Get_Item.Display_In_Advance_QP EQ 1>CHECKED</CFIF>>
				</td>
			</tr>
			<!---97929 :: Quick Pay END--->
  			<tr>
				<td VALIGN="top" ALIGN="right"></td>
				<td VALIGN="top">
					<A HREF="javascript: Validate()"><cfoutput>#application.util.string.linkFormat("save data")#</cfoutput></A>
				</td>
			</tr>
		</table>
	</FORM>
	</td>
	</tr>
	</table>

<script>
	$("tbody.sortable").sortable();

	$("#save_sequence").click(function(){
		show_loader("SAVING CHANGES...", 500);
		let seq = 100;
		$(".seq").each(function() { seq = seq + 10;
				/*assign sequence value based on position*/
				$(this).val( seq );
		});
		$("input[name=action]").val( "save_sequence" );
		$("form[name=stored_records]").submit();
	});
</script>
<cfinclude template="/common_Files/focus.cfm">
</body>
</html>
