<cfsetting  showdebugoutput="false">
<cfparam name="searchType" default="DD">
<cfscript>
	genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
	appSettings = genSettingsManager.get();
	stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct();
</cfscript>

<HTML>
<HEAD>
	<TITLE>Match Central Search</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="css/MatchCentralStyle.css">
</HEAD>

<BODY>

<div id="searchBox">
	<div id="tabHeader">
		<cfif searchType EQ "DD">
			<div id="tabSelected">Deductions</div>
		<cfelse>
			<div id="tab"><a href="javascript:workListSearch('DD');">Deductions</a></div>
		</cfif>
		<cfif searchType EQ "BB">
			<div id="tabSelected">Billbacks</div>
		<cfelse>
			<div id="tab"><a href="javascript:workListSearch('BB');">Billbacks</a></div>
		</cfif>
		<CFIF appSettings.getDDAllowNegativeAmountCredits()>
			<cfif searchType EQ "CR">
				<div id="tabSelected">Credits</div>
			<cfelse>
				<div id="tab"><a href="javascript:workListSearch('CR');">Credits</a></div>
			</cfif>
		</CFIF>
	</div>
	<div id="formValidationError" style="display:none;color:red;width:100%;padding:10px 0 0 10px;">
		You must fill out at least one of the fields below.
	</div>
	<div style="padding-top:15px;">
		<form name="workListFrm" id="workListFrm" style="display:inline;">
			<input type="hidden" name="randomValue" id="randomValue" value="">

			<input type="hidden" name="SelectedDD" id="SelectedDD" value="">
			<input type="hidden" name="SelectedBB" id="SelectedBB" value="">
			<input type="hidden" name="SelectedCR" id="SelectedCR" value="">
			<textarea ID="createList" NAME="createList" ROWS="10" COLS="30" style="display:none;"></textarea>

			<cfoutput>
			<table border="0" cellspacing="0" cellpadding="5" width="100%">
			<cfswitch expression="#searchType#">
				<cfcase value="DD">
					<tr>
						<td colspan="100%" style="font-size:16px;font-weight:bold;">Deduction Search</td>
					</tr>
					<input type="hidden" name="typ" value="DD">
					<cfscript>
						DDObj = createObject("Component","components.Match_Central.MatchCentral").init();
						DDAnalysts = DDObj.getDDAnalysts();
					</cfscript>
					<tr>
						<td>Deduction Number:</td>
						<td><input type="text" name="ddnum" id="ddnum" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>Deduction Analyst:</td>
						<td>
							<select name="analystid" id="analystid" onkeypress="return onEnter(event,this.form,'#searchType#');">
								<option value="" style="color:##999;">** Deduction Analyst</option>
								<cfloop query="DDAnalysts">
									<option value="#User_ID#">#Name_First# #Name_Last#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.shard_ship_to_label# ##/ #application.returned_customer_setting.billto_label# ##:<br /><em style="color:##FF3333;">(Enter ID followed by enter key)</em></td>
						<td><textarea NAME="Distributor" id="Distributor" cols="20" rows="3"></textarea></td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.shard_ship_to_label# / #application.returned_customer_setting.billto_label#:<br /><em style="color:##FF3333;">(Enter Name followed by enter key)</em></td>
						<td><textarea NAME="Distributor_Name" id="Distributor_Name" cols="20" rows="3"></textarea></td>
					</tr>
					<tr>
						<td>#stDeductionLabels["Reference"]#:</td>
						<td><input type="text" name="DD_Ref" id="DD_Ref" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.broker_label_singular#:</td>
						<td><input type="text" name="Broker_Name" id="Broker_Name" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>Check Number:</td>
						<td><input type="text" name="Check_No" id="Check_No" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>

				</cfcase>
				<cfcase value="BB">
					<tr>
						<td colspan="100%" style="font-size:16px;font-weight:bold;">Billback Search</td>
					</tr>
					<input type="hidden" name="typ" id="typ" value="BB">
					<tr>
						<td>#application.returned_customer_setting.Shard_Ship_To_Label# ##:</td>
						<td><input type="text" name="soldToNo" id="soldToNo" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.Shard_Ship_To_Label#:</td>
						<td><input type="text" name="Distributor_Name" id="Distributor_Name" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>Payable ##:</td>
						<td><input type="text" name="bb_code" id="bb_code" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>Billback Number:</td>
						<td><input type="text" name="Billback_Number" id="Billback_Number" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.reference_number_label#:</td>
						<td><input type="text" name="ReferenceNum" id="ReferenceNum" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>

					<tr>
						<td>Billback Title:</td>
						<td><input type="text" name="bb_title" id="bb_title" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
				</cfcase>
				<cfcase value="CR">
					<tr>
						<td colspan="100%" style="font-size:16px;font-weight:bold;">Credit Search</td>
					</tr>
					<input type="hidden" name="typ" id="typ" value="CR">
					<cfscript>
						DDObj = createObject("Component","components.Match_Central.MatchCentral").init();
						DDAnalysts = DDObj.getDDAnalysts();
					</cfscript>
					<tr>
						<td>Credit Number:</td>
						<td>
							<input type="text" name="ddnum" id="ddnum" onkeypress="return onEnter(event,this.form,'#searchType#');">
						</td>
					</tr>
					<tr>
						<td>Deduction Analyst:</td>
						<td>
							<select name="analystid" id="analystid" onkeypress="return onEnter(event,this.form,'#searchType#');">
								<option value="" style="color:##999;">** Deduction Analyst</option>
								<cfloop query="DDAnalysts">
									<option value="#User_ID#">#Name_First# #Name_Last#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.shard_ship_to_label# ## / #application.returned_customer_setting.billto_label# ##:<br /><em style="color:##FF3333;">(Enter ID followed by enter key)</em></td>
						<td><textarea NAME="Distributor" id="Distributor" cols="20" rows="3"></textarea></td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.shard_ship_to_label# / #application.returned_customer_setting.billto_label#:<br /><em style="color:##FF3333;">(Enter Name followed by enter key)</em></td>
						<td><textarea NAME="Distributor_Name" id="Distributor_Name" cols="20" rows="3"></textarea></td>
					</tr>
					<tr>
						<td>Reference ##:</td>
						<td><input type="text" name="DD_Ref" id="DD_Ref" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>#application.returned_customer_setting.broker_label_singular#:</td>
						<td><input type="text" name="Broker_Name" id="Broker_Name" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
					<tr>
						<td>Check Number:</td>
						<td><input type="text" name="Check_No" id="Check_No" onkeypress="return onEnter(event,this.form,'#searchType#');"></td>
					</tr>
				</cfcase>
			</cfswitch>

			<tr>
				<td colspan="100%" align="right">
					<CF_smallLink
						title = "search"
						url = "javascript:DoWorkListSearch('#searchType#');"> &nbsp; &nbsp;
					<CF_smallLink
						title = "cancel"
						url = "javascript:toggleSearchDiv();"> &nbsp; &nbsp;
					<CF_smallLink
						title = "reset"
						url = "javascript:document.forms.workListFrm.reset();"> &nbsp; &nbsp;
				<!--- 75568 :: Match Central - mass select and create list options START  ---->
					<CF_smallLink
						title = "create list"
						url = "javascript:createlist('#searchType#');"> &nbsp; &nbsp;
				 <!--- 75568 :: Match Central - mass select and create list options END ---->
				</td>
			</tr>
		</table>
		</cfoutput>
	</form>
</div>
</div>

</BODY>
</HTML>