<!--- Select Enable/Disable and click apply to Enable/Disable Business Segments for programs.
<p> --->
<cfset stBusinessSegmentSettings = businessSegManager.getEnabled() />
<cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>s are currently <b><cfif businessSegManager.isEnabled()>Enabled<cfelse>Disabled</cfif></b><p>
<!---if a business segment exists then display the option to enable--->
<cfif businessSegManager.segmentsExist()>

	<TABLE border="0" cellpadding="1" cellspacing="0">
		<TR>
			<td>
			<cfoutput>#appSettings.getbusiness_segment_label()# enabled:</cfoutput>
			</td>
			<td>
				<select name="enable">
					<option value="1" <cfif stBusinessSegmentSettings.Enabled>selected</cfif>>Enable</option>
					<option value="0" <cfif not stBusinessSegmentSettings.Enabled>selected</cfif>>Disable</option>
				</select>&nbsp;
			</td>
		</TR>
		<TR>
			<td>
			<cfoutput>#appSettings.getbusiness_segment_label()# enabled for #LCase(application.returned_customer_setting.distributor_label_singular)#:</cfoutput>
			</td>
			<td>
				<select name="distributor_enable" id="distributor_enable">
					<option value="1" <cfif stBusinessSegmentSettings.DistributorEnabled>selected</cfif>>Enable</option>
					<option value="0" <cfif not stBusinessSegmentSettings.DistributorEnabled>selected</cfif>>Disable</option>
				</select>&nbsp;
			</td>
		</TR>
		<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START--->
		<TR>
			<td>
			<cfoutput>#appSettings.getbusiness_segment_label()# enabled for #LCase(application.returned_customer_setting.Operator_label_singular)#:</cfoutput>
			</td>
			<td>
				<select name="Operator_enable" id="Operator_enable">
					<option value="1" <cfif stBusinessSegmentSettings.OperatorEnabled>selected</cfif>>Enable</option>
					<option value="0" <cfif not stBusinessSegmentSettings.OperatorEnabled>selected</cfif>>Disable</option>
				</select>&nbsp;
			</td>
		</TR>
		<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END--->
		<TR>
			<td>
			<cfoutput>#appSettings.getbusiness_segment_label()# enabled for #LCase(application.returned_customer_setting.ITEM_Label)#:</cfoutput>
			</td>
			<td>
				<select name="product_enable" id="product_enable">
					<option value="1" <cfif stBusinessSegmentSettings.ProductEnabled>selected</cfif>>Enable</option>
					<option value="0" <cfif not stBusinessSegmentSettings.ProductEnabled>selected</cfif>>Disable</option>
				</select>&nbsp;
			</td>
		</TR>
		<TR>
			<cfoutput>
			<td>
			#appSettings.getbusiness_segment_label()# enabled for vendor:
			</td>
			<td>
				<!---
				1: Business_Segment_ID will be stored in Vendor_Master table.
				2: Business_Segment_ID will not be stored in Vendor_Master table. Business_Segment_ID will be stored in Vendor_Segment_Xref table.
				--->
				<select name="vendor_enable">
					<option value="1" <cfif stBusinessSegmentSettings.VendorEnabledType eq 1>selected</cfif>>Enable - One vendor has single #appSettings.getbusiness_segment_label()#</option>
					<option value="2" <cfif stBusinessSegmentSettings.VendorEnabledType eq 2>selected</cfif>>Enable - One vendor has multiple #appSettings.getbusiness_segment_label()#</option>
					<option value="0" <cfif stBusinessSegmentSettings.VendorEnabledType eq 0>selected</cfif>>Disable</option>
				</select>&nbsp;
			</td>
			</cfoutput>
		</TR>
		<!--- 65015 :: Auto Pay by Segment START --->
			<TR>
				<td>Auto Pay by <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>	</td>
				<td>
					<select name="Auto_Pay_Segment_Enable">
						<option value="1" <cfif stBusinessSegmentSettings.AutoPay_Segment_Enable>selected</cfif>>Enable</option>
						<option value="0" <cfif not stBusinessSegmentSettings.AutoPay_Segment_Enable>selected</cfif>>Disable</option>
					</select>&nbsp;
				</td>
			</TR>
		<!--- 65015 :: Auto Pay by Segment END --->
		<!--- START: 108967: Autopay access by Segment / Anand Rao / 10-Nov-21 --->
		<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
			<TR>
				<td><cfoutput>User #appSettings.getbusiness_segment_label()# filters autopay results:</cfoutput></td>
				<td>
					<select name="User_Segment_Filters_Autopay_Results">
						<option value="1" <cfif stBusinessSegmentSettings.User_Segment_Filters_Autopay_Results>selected</cfif>>Enable</option>
						<option value="0" <cfif not stBusinessSegmentSettings.User_Segment_Filters_Autopay_Results>selected</cfif>>Disable</option>
					</select>&nbsp;					
				</td>	
			</TR>
		<cfelse>
			<input type="hidden" name="User_Segment_Filters_Autopay_Results" value="0">
		</cfif>
		<!--- END: 108967: Autopay access by Segment / Anand Rao / 10-Nov-21 --->
		<!--- 64860 :: Update Segments selection on programs START --->
			<TR>
				<td>Allow multiple <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>	</td>
				<td>
					<select name="Allow_Multiple_Segment">
						<option value="1" <cfif stBusinessSegmentSettings.Allow_Multiple_Segment>selected</cfif>>Enable</option>
						<option value="0" <cfif not stBusinessSegmentSettings.Allow_Multiple_Segment>selected</cfif>>Disable</option>
					</select>&nbsp;
				</td>
			</TR>
		<!--- 64860 :: Update Segments selection on programs END --->
		<!--- 76383 :: Allow Segment to be changed on revise/copy/in Edit mode START --->
		<cfset info = "#appsettings.getbusiness_segment_label()# change is not allowed when #appsettings.getbusiness_segment_label()# is enabled for distributor, operator or product.">
		<cfif stBusinessSegmentSettings.DistributorEnabled  OR stBusinessSegmentSettings.OperatorEnabled  OR stBusinessSegmentSettings.ProductEnabled>
			<cfset disabled = 'disabled'>
		<cfelse>
			<cfset disabled = ''>
		</cfif>
		<cfoutput>
			<TR>
				<td>
					Allow #appSettings.getbusiness_segment_label()# change <img src="/images/help_small.gif" title="#info#"/>
				</td>
				<td>
					<input type="radio" name="Allow_Segment_Change" value="1" <cfif stBusinessSegmentSettings.Allow_Segment_Change>Checked</cfif> #disabled#> Yes
					<input type="radio" name="Allow_Segment_Change" value="0" <cfif stBusinessSegmentSettings.Allow_Segment_Change EQ 0>Checked</cfif> #disabled#> No
				</td>
			</TR>
		</cfoutput>
		<!--- 76383 :: Allow Segment to be changed on revise/copy/in Edit mode END --->
		<!--- 77185	Budgets & Segment START --->
			<TR>
				<td><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput> enabled for budgets	</td>
				<td>
					<select name="Budget_Segment_Enabled">
						<option value="1" <cfif stBusinessSegmentSettings.Budget_Segment_Enabled>selected</cfif>>Enable</option>
						<option value="0" <cfif not stBusinessSegmentSettings.Budget_Segment_Enabled>selected</cfif>>Disable</option>
					</select>&nbsp;
				</td>
			</TR>
		<!--- 77185	Budgets & Segment END --->
			<TR>
				<td>Display <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput> in billbacks</td>
				<td>
					<select name="Display_Segment_In_Billbacks">
						<option value="1" <cfif stBusinessSegmentSettings.Display_Segment_In_Billbacks>selected</cfif>>Enable</option>
						<option value="0" <cfif not stBusinessSegmentSettings.Display_Segment_In_Billbacks>selected</cfif>>Disable</option>
					</select>&nbsp;
				</td>
			</TR>
		<!--- 99161 Update volume plan to use Segment START --->
			<TR>
				<td><cfoutput>#Application.PlannerLabel# volume plan by #appSettings.getbusiness_segment_label()#</cfoutput> </td>
				<td>
					<select name="Planner_Volume_Plan_Segment_Enable">
						<option value="1" <cfif stBusinessSegmentSettings.Planner_Volume_Plan_Segment_Enable>selected</cfif>>Enable</option>
						<option value="0" <cfif not stBusinessSegmentSettings.Planner_Volume_Plan_Segment_Enable>selected</cfif>>Disable</option>
					</select>&nbsp;
				</td>
			</TR>
		<!--- 99161 Update volume plan to use Segment END --->
		<TR>
			<TD>
				<BR>
				<CF_smallLink
					title = "apply"
					url = "##"
					parameters = "onClick=""javascript: return submitForm('enable');"""
				>
			</TD>
		</TR>
	</TABLE>
<script>

	$("#distributor_enable,#Operator_enable,#product_enable").change(function() {

		var distributor = $( "#distributor_enable option:selected" ).val();
		var operator = $( "#Operator_enable option:selected" ).val();
		var product = $( "#product_enable option:selected" ).val();

		if(distributor == 1 || operator == 1 || product == 1){
			$("input[type=radio]").attr('disabled', true);
		}else{
			$("input[type=radio]").attr('disabled', false);
		}

	});

</script>
<cfelse>
<b><font color="##FF0000">There are currently no Active <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>s. You must have Active <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>s in order to enable this feature.</font></b>
</cfif>
