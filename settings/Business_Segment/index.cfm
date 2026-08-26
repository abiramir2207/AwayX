<!---
  * ==================================================================================================== 
  *    @File: \settings\Business_Segment\index.cfm
  *  @Author: Unknown
  *    @Date: 2018-07-31 09:45:25
  * 
  * @Remarks: Business segment setting main controller
  *
  *
  * 
  *  
  * ==================================================================================================== 
--->
<cfsilent>
<CFPARAM NAME="url.command" DEFAULT="dEnable">
<CFPARAM NAME="form.command" DEFAULT="#url.command#">
<CFPARAM NAME="form.id" DEFAULT="0">
<CFPARAM NAME="form.returnCommand" DEFAULT="">
<CFPARAM NAME="form.canDeactivate" DEFAULT="1">
<CFPARAM NAME="form.Allow_Segment_Change" DEFAULT="0">
<cfset selectedIndex = 99>
<cfset actionDisplay = "Edit">
<cfswitch expression="#form.command#">
	<cfcase value="dEnable">
		<cfset selectedIndex = 0>
		<cfset actionDisplay = "Enable">
	</cfcase>
	<cfcase value="dActiveBusinessSegment">
		<cfset actionDisplay = "Active">
		<cfset selectedIndex = 1>
	</cfcase>
	<cfcase value="dInActiveBusinessSegment">
		<cfset selectedIndex = 2>
		<cfset actionDisplay = "Inactive">
	</cfcase>
</cfswitch>
</cfsilent>
<cfmodule template="/customTags/layout.cfm"
							layoutID = "businessSegments"
							selectedIndex = "#selectedIndex#" >

<cf_include files="/Script/javascript/format_functions.js, /script/javascript/string_functions.js ,/Script/javascript/dom_common.js, business_segment.js">
<cfinclude template="/common_files/jQuery.cfm">
	
<CFOUTPUT>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings        = genSettingsManager.get()>
<CFSET PAGETITLE          = "PROGRAMS: #appSettings.getbusiness_segment_label()#s">

<!---check to see if business segments are turned on --->
<CFIF application.returned_customer_setting.business_segments_on NEQ 1>
	<p>
	<h1>#appSettings.getbusiness_segment_label()#s are not turned on. Contact our <a href = "send_email_form.cfm?nature=functional">application administrator</a> to have them turned on.</h1>
	</p>
</CFIF>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!---create and instance of the BusinessSegmentManager--->

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<!--- set whether segments can be disabled--->
<cfif businessSegManager.getActive().RecordCount eq 1 and businessSegManager.isEnabled()>
	<cfset form.canDeactivate = 0 />
<cfelse>
	<cfset form.canDeactivate = 1 />
</cfif>

<!---****************************** START COMMANDS ***********************************--->

<cfif form.command eq "enable">

	<!---if the command is enable then update the enable bit and reset the command back to dEnable--->
	<cfset businessSegManager.setEnabled(form.enable, form.distributor_enable, form.product_enable, form.vendor_enable, form.Operator_enable, form.Auto_Pay_Segment_Enable, form.Allow_Multiple_Segment, form.Allow_Segment_Change, form.Budget_Segment_Enabled,form.Display_Segment_In_Billbacks,form.Planner_Volume_Plan_Segment_Enable, form.User_Segment_Filters_Autopay_Results) />
	<cfset form.command = "dEnable" />

<cfelseif form.command eq "dActiveBusinessSegment">

	<!---get business segments to display--->
	<cfset qGetBusSegments = businessSegManager.getActive() />

<cfelseif form.command eq "dInActiveBusinessSegment">

	<!---get business segments to display--->
	<cfset qGetBusSegments = businessSegManager.getInActive() />

<cfelseif form.command eq "sBusinessSegment">

	<!---save business segment--->
	<cfset businessSegManager.save(form.id, form.Business_Unit_ID, form.Business_Unit_Desc, form.Company_Code_ID, form.Variable_1, form.Variable_2, form.Variable_3, form.Variable_4, form.Variable_5, form.Variable_6) />
	<cflocation url="index.cfm?command=#form.returnCommand#" />

<cfelseif form.command eq "daBusinessSegment">

	<!---deActivate business segment if allowed--->
	<cfset canMakeActive = businessSegManager.makeInActive(form.id) />
	<cflocation url="index.cfm?command=dActiveBusinessSegment" />

<cfelseif form.command eq "aBusinessSegment">

	<!---save business segment--->
	<cfset businessSegManager.makeActive(form.id) />
	<cflocation url="index.cfm?command=dActiveBusinessSegment" />

<cfelseif form.command eq "cancel">

	<!---on cancel relocation to display--->
	<cflocation url="index.cfm?command=#form.returnCommand#" />

<cfelseif form.command eq "copy">

	<cfset new_segment_id     = businessSegManager.copy_existing_segment( form.id )>
	<cfset form.id            = new_segment_id>
	<cfset form.command       = "eaBusinessSegment">
	<cfset form.returnCommand = "dActiveBusinessSegment">

	<!---get business segments to edit--->
	<cfset qGetBusSegments = businessSegManager.get( form.id )>

<cfelseif ListFindNoCase("eaBusinessSegment,eiBusinessSegment", form.command)>

	<!---get business segments to edit--->
	<cfset qGetBusSegments = businessSegManager.get(form.id) />

</cfif>

<!---****************************** END COMMANDS ***********************************--->


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!--- <cfinclude template="business_segment_header.cfm" /> --->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">
<!---actionDisplay comes from the business_segment_header.cfm include above--->
<SPAN CLASS="Title2">#appSettings.getbusiness_segment_label()#s - #actionDisplay#</SPAN>&nbsp;&nbsp;&nbsp;

<HR COLOR="Orange">
<!---switch for each action--->
<cfswitch expression="#form.command#">

	<cfcase value="dEnable">
		<cfinclude template="business_segment_enable.cfm" />
	</cfcase>

	<cfcase value="dActiveBusinessSegment">
		<cfinclude template="business_segment_active_list.cfm" />
	</cfcase>

	<cfcase value="dInActiveBusinessSegment">
		<cfinclude template="business_segment_inactive_list.cfm" />
	</cfcase>

	<cfcase value="ceBusinessSegment">
		<cfinclude template="business_segment_create_edit.cfm" />
	</cfcase>

	<cfcase value="cBusinessSegment,eBusinessSegment">
		<cfinclude template="business_segment_create_edit.cfm" />
	</cfcase>

	<cfcase value="eaBusinessSegment,eiBusinessSegment">
		<cfinclude template="business_segment_create_edit.cfm" />
	</cfcase>

	<cfcase value="dClassCodes">
		<cfinclude template="class_code_list.cfm" />
	</cfcase>

	<cfcase value="eClassCodes,sClassCodes">
		<cfif form.id>
			<cfinclude template="class_code_update.cfm" />
		<cfelse>
			<cfinclude template="class_code_create_edit.cfm" />
		</cfif>
	</cfcase>

	<cfcase value="eBudgetPercentage,sBudgetPercentage">
		<cfinclude template="class_code_budget_percentage_edit.cfm" />
	</cfcase>

</cfswitch>

<!---hidden form fields--->
<input name="command" type="hidden" value="#form.command#" />
<input name="id" type="hidden" value="#form.id#" />
<input name="returnCommand" type="hidden" value="#form.returnCommand#" />
<input name="canDeactivate" type="hidden" value="#form.canDeactivate#" />
</cfoutput>
</FORM>
<script>
		function exportAll(){
  	popupInCenter( "/Common_Files/exportAll.cfm?" + "&type=Segment_Report"                                              		
												  <cfoutput>	+ "&friendlyFileName=#urlEncodedFormat('Segment_Report')#"</cfoutput>
													,"", 800, 200 );
	}		
</script>
</cfmodule>