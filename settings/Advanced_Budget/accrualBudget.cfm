<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Advanced_Budget\accrualBudget.cfm
      Date:     June 10, 2011
      Author:   Chris Nguyen
      Purpose:  Add/Edit accrual budget
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.Holdback_Percentage"         	      default="0">
<cfparam name="form.Participation_Required"      		default="0">
<cfparam name="form.Recapture"                   			default="0">
<cfparam name="form.Overlays"                    			default="0">
<cfparam name="form.Corporate_And_Local_Rate"       default="0">
<cfparam name="form.Overlay_Recapture"           		default="0">
<cfparam name="form.Budget_Status"               			default="">
<cfparam name="form.Position_Control_Type"       		default="1">
<cfparam name="form.Budget_Owner_Position_ID"    	default="0">
<cfparam name="form.Recapture_Forecast_Days"     	default="90">   <!--- 34591 --->
<cfparam name="form.Price_List_ID"     					default="">
<cfparam name="form.overlay_calculation"         		default="0">
<cfparam name="form.calculation_frequency"         		default="0"><!--- D56006 --->
<cfparam name="form.Calculation_Start_Date"              default=""><!--- D56006 --->
<cfparam name="form.Calculation_End_Date"               default=""><!--- D56006 --->
<cfparam name="form.Added_From_Number"               default="">

<cfparam name="form.bySearch"      default="">
<cfset url.bySearch = form.bySearch>

<cfsavecontent variable="vars.htmlHead">
	<style>
		td.extra { width: 150px; }
		.label2 { font-weight:bold; padding-left:5px; }
		.label3 { font-weight:bold; padding-left:5px; }
		.fieldset2 { clear:both; margin:0.5em 0; padding:0 1em .5em; border:0 none; border-top:#cccccc 1px solid; width:98%}
		.legend2 { margin:0.5em; padding:0 1.5em; background:transparent; color:#003366; font-size:1.1em; font-weight:bold; }
		.label { text-align: left; width: 210px; font-weight:bold; margin:8px 0 0 4px; display:inline-block; }
		.content { text-align: left; width: 210px; font-weight:bold; margin:8px 0 0 4px; display:inline-block; }
		.label4 { width: 210px !important; }
		.notif { margin:0 0 4px 0;}
	</style>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
	<script type="text/javascript" src="/script/tTip.js"></script>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfif form.clicked_save eq "1">
  <cfset saveAccrualBudget()>
  <cfoutput>
  <script type="text/javascript">
    <!---place the new budget id into the form element when applicable--->
    if ( document.forms[budget_form].budget_id.value == "0" ) {
      document.forms[budget_form].budget_id.value = "#form.budget_id#";
    }
    document.forms[budget_form].load_fromdb.value  = "1";
    document.forms[budget_form].command.value = "editDistributors";
    document.forms[budget_form].submit();
  </script>
  </cfoutput>
</cfif>
<!----- Load form from database ----->
<cfif form.load_fromdb eq "1">
  <cfset loadAccrualBudget()>
</cfif>

<cfif form.Added_From_Number neq "">
    <cfset QuerySetCell(qGetCreateBudget, "Create_Budget", 0) />
</cfif>


<div style="margin:0px">
<fieldset id="mainfieldset" style="padding:1%; width:98%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Budget - <cfif form.budget_id eq 0>Add<cfelse><cfif ! qGetCreateBudget.Create_Budget>View<cfelse>Edit</cfif></cfif></legend>


<cfquery name="getBudgetInfo" datasource="#application.datasource#">
	SELECT  Budget_Activated_By,	
			Budget_Activated_Date,
			Budget_DeActivated_By,
			Budget_DeActivated_Date,
			Active,
			u1.Name_First + ' ' + u1.Name_Last AS Budget_Activated_User,
			u2.Name_First + ' ' + u2.Name_Last 	AS Budget_Deactivated_User 
	FROM Budget b
	LEFT JOIN _Users u1 ON u1.User_ID = b.Budget_Activated_By
	LEFT JOIN _Users u2 ON u2.User_ID = b.Budget_DeActivated_By
	WHERE 	b.Budget_ID = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	AND 	b.Deleted = 0
</cfquery>
<cfif (isDefined("getBudgetInfo") AND getBudgetInfo.RecordCount NEQ 0 AND (getBudgetInfo.Budget_Activated_By NEQ "" OR getBudgetInfo.Budget_DeActivated_By NEQ ""))>
<cfoutput>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0"  ALIGN="center" width="600">
	<TR>
	<TD align="center">
		<FONT SIZE="2"><B>
			<cfif getBudgetInfo.Active EQ 1>
				This Budget was activated on #dateformat(getBudgetInfo.Budget_Activated_Date, 'mm/dd/yyyy')# #timeformat(getBudgetInfo.Budget_Activated_Date, 'hh:mm:ss TT')# by #getBudgetInfo.Budget_Activated_User#
			<cfelse>
				This Budget was deactivated on #dateformat(getBudgetInfo.Budget_DeActivated_Date, 'mm/dd/yyyy')# #timeformat(getBudgetInfo.Budget_DeActivated_Date, 'hh:mm:ss TT')# by #getBudgetInfo.Budget_Deactivated_User#
			</cfif>
		</B></FONT>
	</TD>
	</TR>
	</TABLE>
</cfoutput>	<br><br><br>
</cfif>
<cfinclude template="budgetgeneral.cfm">

<CF_MessageWindow>

<cfscript>
  const = {};                // constants structure
  const.unselected = -1;     // unselected value for drop-down option
  // unique css class constants used as jQuery selectors
  class = {};
  positionManager = CreateObject("component", "components.geography.position").init();
  qGetHQPosition  = positionManager.getHQPosition();
  HQPositionLabel = qGetHQPosition.Position_Label;
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="vars.qPosition" datasource="#application.datasource#">
  SELECT '(' + Position_Label + ')' as Position_Label
    FROM User_Positions
   WHERE User_Positions_ID = <cfqueryparam value="#Val(form.Budget_Owner_Position_ID)#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="qAnyAccrualAdjustment" datasource="#application.datasource#">
 	SELECT 	top 1 1 as Adj_Exist
    FROM 	dbo.Budget_Adjustment
	WHERE 	Budget_ID = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	AND 	Deleted = 0
</cfquery>
<cfquery name="qSelectedMarketInvoice" datasource="#application.datasource#">
 	SELECT User_Position_ID FROM Budget_Position_Filter
	WHERE 	Budget_ID = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	AND 	Deleted = 0
</cfquery>
<cfparam name="form.Market_Invoice_Filter_ID"   default="#valuelist(qSelectedMarketInvoice.User_Position_ID)#">


<cfset bDisallowEditAllocationControl = 0 />
<cfif qAnyAccrualAdjustment.RecordCount>
	<cfset bDisallowEditAllocationControl = 1 />
</cfif>


<cfoutput>
<div style="float:left; margin-left:20px;">
<div class="notif">
<label class="label label4">Hold Back:<span id="error_holdback_percentage"></span></label>
<input name="holdback_percentage" value="#form.Holdback_Percentage#" size="5" maxlength="10" type="text" class="numeric" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>%
</div>

<div class="notif">
<label class="label label4">Allocation Control:</label>
<input name="position_control_type" type="radio" value="1"  <cfif not bDisallowEditAllocationControl>onclick="pct(this)"</cfif> <cfif form.Position_Control_Type eq "1">checked<cfelseif bDisallowEditAllocationControl OR qGetCreateBudget.Create_Budget EQ 0>disabled</cfif>><b>Point</b><span id="error_allocation_position_level"></span>
<span style="margin-left:15px;"><select id="select_point" name="allocation_position_level" <cfif form.Position_Control_Type neq "1">style="display:none"</cfif> <cfif bDisallowEditAllocationControl OR qGetCreateBudget.Create_Budget EQ 0>disabled</cfif>>
 <option value="#const.unselected#">select</option>
 <option <cfif form.Allocation_Position_Level eq 0>selected</cfif> value="0">#HQPositionLabel#</option>
 <option <cfif form.Allocation_Position_Level eq 1>selected</cfif> value="1">#application.returned_customer_setting.zone_label_plural#</option>
 <option <cfif form.Allocation_Position_Level eq 2>selected</cfif> value="2">#application.returned_customer_setting.region_label_singular#</option>
 <option <cfif form.Allocation_Position_Level eq 3>selected</cfif> value="3">#application.returned_customer_setting.market_label_singular#</option>
 <option <cfif form.Allocation_Position_Level eq 4>selected</cfif> value="4">Customer</option>
</select></span>
<cfif form.Position_Control_Type eq "1" and bDisallowEditAllocationControl><input name="allocation_position_level" type="hidden" value="#form.Allocation_Position_Level#"></cfif>
</div>
<div class="notif">
<label class="label label4">&nbsp;</label>
<input name="position_control_type" type="radio" value="2" <cfif not bDisallowEditAllocationControl>onclick="pct(this)"</cfif> <cfif form.Position_Control_Type eq "2">checked<cfelseif bDisallowEditAllocationControl  OR qGetCreateBudget.Create_Budget EQ 0>disabled</cfif>><b>Position</b> <span id="allocation_position">#vars.qPosition.Position_Label#</span><a name="select_position" id="select_position" href="javascript:select_position()" <cfif form.Position_Control_Type neq "2" or bDisallowEditAllocationControl>style="margin-left:15px;display:none"<cfelse>style="margin-left:15px;"</cfif>>#LCase(ActionText("select position"))#</a>
<br>
<label class="label">&nbsp;</label>
<cfif appSettings.getUseInvoiceMarket() AND !bDisallowEditAllocationControl>
	<cfif qGetCreateBudget.Create_Budget EQ 0>
		#LCase(ActionText("#application.returned_customer_setting.market_label_singular# Invoice Filter"))#
	<cfelse>
		<a name="Invoice_filter" id="Invoice_filter" href="javascript:Invoice_Filter()" <cfif form.Position_Control_Type neq "1">style="margin-left:15px;display:none"<cfelse>style="margin-left:15px;"</cfif>>#LCase(ActionText("#application.returned_customer_setting.market_label_singular# Invoice Filter"))#</a>
	</cfif>
</cfif>
<cfif appSettings.getUseInvoiceMarket()>
	<cfif ! qGetCreateBudget.Create_Budget>
		#LCase(ActionText("view Invoice filter"))#
	<cfelse>
		<a name="view_Invoice_filter" id="view_Invoice_filter" href="javascript:view_Invoice_Filter()" <cfif form.Position_Control_Type neq "1">style="margin-left:15px;display:none"<cfelse>style="margin-left:15px;"</cfif>>
			#LCase(ActionText("view Invoice filter"))#
		</a>
	</cfif>
<span onmouseover="popUpTip(event,'invoice_filter_tip');" onmouseout="popUpTip(event,'invoice_filter_tip');"><img src="/images/help_small.gif" /></span>
              <div id="invoice_filter_tip" class="tip">
                <p style="margin-left:5px;">When selecting an Allocation Point or Position, you have the option to select specific sales hierarchy positions for the budgets [this step is optional].   Whichever position(s) is selected, it will be used to only include invoice dollars from that specific position.  Also note that the distributors (or distributor planning groups) associated to the budget are another filter that determines which invoice dollars to be used for the accrual budget calculations.   </p>
              </div>
</cfif>
</div>
<cfif bDisallowEditAllocationControl><div style="color:red;">The Allocation Control Point cannot be changed because there are existing accrual adjustments on the budget</div></cfif>

<div class="notif">
<label class="label">Notification Threshold Actual:<span id="error_notification_threshold_actuals"></span></label>
<input name="notification_threshold_actuals" value="#form.Notification_Threshold_Actuals#" size="5" maxlength="10" type="text" class="numeric" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>%
</div>
<div class="notif">
<label class="label">Notification Threshold Commitment:<span id="error_notification_threshold_commitments"></span></label>
<input name="notification_threshold_commitments" value="#form.Notification_Threshold_Commitments#" size="5" maxlength="10" type="text" class="numeric" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>%
</div>
<cf_emailRecipient
          intEmails_name  = "notification_emails"
          intEmails_value = "#form.Notification_Emails#"
          intEmails_size  = "rows=5 cols=88"
          intEmails_label = '<strong>Notification Emails:</strong>'
          include         = "internal"
          include_jQuery   = false
          include_jQueryUI = true
          include_jQueryCSS= true
          table_class      = "none"
          position         = ""
          >
</div>

<!--------------------------------------------------------------------------------------------------------------------->
<!---<hr style="clear:both;color:##F7B64A"/>--->
<fieldset class="fieldset2">
<legend class="legend2">Attributes</legend>
<div style="margin-left:100px">

  <table cellspacing="5" border="0">
<!---D56006 New Budget Feature - Accrual:  calculate once and stop. START --->
  <tr>
  		 <td class="label" valign="top">Calculation Frequency:<span id="error_Calculation_Frequency"></span></td>
		 <td class="content" valign="top">
			<select name="Calculation_Frequency" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif> onchange="showCalDates(this);">
				<option <cfif form.calculation_frequency eq '0'>selected=selected</cfif> value="0" >Dynamic</option>
				<option <cfif form.calculation_frequency eq '1'>selected=selected</cfif> value="1" >Static</option>
			</select>
		<br>
        <span id="caldates" <cfif ! form.calculation_frequency>style="display:none;"</cfif>>
			<cfoutput>
				<b>Calculation Start Date : <span id="error_Calculation_Start_Date"></span></b>&nbsp; <CF_EASYDATE FORMNAME="BudgetForm" FIELDNAME="Calculation_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#form.Calculation_Start_Date#">
				<b>Calculation End Date : <span id="error_Calculation_End_Date"></span></b>&nbsp;  <CF_EASYDATE FORMNAME="BudgetForm" FIELDNAME="Calculation_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#form.Calculation_End_Date#">
			</cfoutput>
		</span>
		</td>
        <cfif appSettings.get_Setting('Budget_Participation') neq '1'>
          <td>&nbsp;</td>
       </cfif>
  </tr>
<!---D56006 New Budget Feature - Accrual:  calculate once and stop. END --->
  <tr>
       <cfif appSettings.get_Setting('Budget_Participation') eq '1'>
         <td class="label">Participation Required?</td>
         <td class="content"><input name="participation_required" value="1" <cfif form.Participation_Required eq "1">checked</cfif>
                  type="radio" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>Yes
             <input name="participation_required" value="0" <cfif form.Participation_Required eq "0">checked</cfif>
                  type="radio" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>No
         </td>
       </cfif>
       <td class="label extra">Recapture Base?</td>
       <td class="content"><input name="recapture" class="recapture" value="1" <cfif form.Recapture eq "1">checked</cfif>
                type="radio" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>Yes
           <input name="recapture" class="recapture" value="0" <cfif form.Recapture eq "0">checked</cfif>
                type="radio" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>No
       </td>
       <cfif appSettings.get_Setting('Budget_Participation') neq '1'>
          <td>&nbsp;</td>
       </cfif>
  </tr>
  <tr>
       <cfif appSettings.get_Setting('Budget_Overlay') eq '1'>
         <td class="label">Overlay Calculation:</td>
         <td class="content"><select name="overlay_calculation" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>>  <!--- 36933 --->
                <option <cfif form.overlay_calculation eq '0'>selected=selected</cfif> value="0" >No</option>
                <option <cfif form.overlay_calculation eq '1'>selected=selected</cfif> value="1" >Each Customer</option>
                <option <cfif form.overlay_calculation eq '2'>selected=selected</cfif> value="2" >Each Planning Group</option>
                <option <cfif form.overlay_calculation eq '3'>selected=selected</cfif> value="3" >All Customers Aggregated</option>
             </select>
             <span onmouseover="popUpTip(event,'overlays_tip');" onmouseout="popUpTip(event,'overlays_tip');"><img src="/images/help_small.gif" /></span>
              <div id="overlays_tip" class="tip">
                <p style="margin-left:5px;">If 'Each customer' is selected, purchases by each distinct customer in the budget will contribute towards attainment of each Overlay category goal.  The application will not discriminate based upon how the customers are identified - via planning group or individually selected.  This is the default option.</p>
                <p style="margin-left:5px;">If 'Each planning group' is selected, purchases by customers from each planning group in the budget will contribute towards attainment of each Overlay category goal.  If a budget also contains individual customers along with one or more planning groups, those individual customers will need to attain their overlay target individually [e.g., assuming they are not included in any of the planning groups associated].  Overlay qualification will be calculated for each planning group and each individual customer selected that does not belong to one of the planning groups involved.</p>
                <p style="margin-left:5px;">If 'All customers aggregated' is selected, purchases for all customers associated with the budget [regardless of their inclusion via planning group or individually selected] will contribute towards attainment of each Overlay category goal.  With the 'All customers' option, there will be a single outcome for the budget.</p>
              </div>
         </td>
       </cfif>
       <td class="label extra">Recapture Overlay?</td>
       <td class="content"><input name="overlay_recapture" value="1" <cfif form.Overlay_Recapture eq "1">checked</cfif>
              type="radio" class="overlay_recapture" <cfif form.overlays eq "0" OR ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>Yes
           <input name="overlay_recapture" value="0" <cfif form.Overlay_Recapture eq "0">checked</cfif>
              type="radio"  class="overlay_recapture" <cfif form.overlays eq "0" OR ! qGetCreateBudget.Create_Budget>Disabled</cfif>/>No
       </td>
       <cfif appSettings.get_Setting('Budget_Overlay') neq '1'>
          <td>&nbsp;</td>
       </cfif>
  </tr>
  <!--- 34591 --->
  <tr id="rfp" <cfif form.Overlay_Recapture neq "1" and form.Recapture neq "1">style="display:none;"</cfif>>
		<cfif appSettings.getPriceListByTemplate() EQ 1>
		<td class="label extra">Select a Price list</td>
		<td class="content">
		<cfset useLakebaseForqGetPriceList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_list_header")>
<cfif useLakebaseForqGetPriceList>
	<cftry>
		<cfset qGetPriceList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("price_list_header", {
				"deleted" = "eq.0",
				"order" = "price_list_description.asc",
				"select" = "price_list_id,price_list_description"
			}), "price_list_id,price_list_description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPriceList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPriceList>
<cfquery name="qGetPriceList" datasource="#application.datasource#">
			select	Price_List_ID, Price_List_Description
			from	price_list_header
			where	deleted = 0
			order by    Price_List_Description
		</cfquery>
</cfif>
		<select name="Price_List_ID" <cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>>
			<option value="" selected>Select a price list</option>
			<cfloop query="qGetPriceList">
				<option value="#Price_List_ID#" <cfif form.Price_List_ID eq Price_List_ID> selected</cfif>>#Price_List_ID#-#Price_List_Description#</option>
			</cfloop>
		</select>
		</td>
		<cfelse>
		<td></td><td></td>
		</cfif>

       <td class="label extra">Recapture Forecast<br/>Parameter</td>
       <td class="content">
				<input name="recapture_forecast_days" value="#form.Recapture_Forecast_Days#" size="5" maxlength="10" type="text" class="numeric"<cfif ! qGetCreateBudget.Create_Budget>Disabled</cfif>/> days
       </td>
  </tr>
  </table>
</div>

<input name="budget_status" type="hidden" value="#form.Budget_Status#"/>
<input name="budget_owner_position_id" type="hidden" value="#form.Budget_Owner_Position_ID#"/>
<input name="Market_Invoice_Filter_ID" type="hidden" value="#form.Market_Invoice_Filter_ID#"/>

<!----- action links ----->
<div style="margin:10px 0 0 225px">
	<cfif ! qGetCreateBudget.Create_Budget>
		#LCase(ActionText("save"))#
	<cfelse>
 		<a href="javascript:saveaccrual()">#LCase(ActionText("save"))#</a>
	</cfif>
 <a href="javascript:window.location='index.cfm?bySearch=#form.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';" style="margin:20px">#LCase(ActionText("return to budgets list"))#</a>
 <cfif  ((form.Budget_Status contains "validated") or (form.Budget_Status contains "calculated")) AND appSettings.get_Setting('Accrual_Budgets_Calculation_By_Client') neq '1' AND form.Added_From_Number eq "">
  <a href="javascript:calcaccrual();" style="margin-right:20px">#LCase(ActionText("calculate"))#</a>
 </cfif>
 <cfif form.Budget_Status contains "calculated">
  <a href="javascript:report();">#LCase(ActionText("report"))#</a>
 </cfif>
</div>
</cfoutput>
</fieldset>   <!---Attributes--->
</fieldset>
</div>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="labelInMessage" output="false">
  <cfargument name="label" required="true">
  <!---make the label in lowered case and remove the colon--->
  <cfreturn Lcase(Replace(arguments.label, ":", ""))>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="loadAccrualBudget" output="false">
  <cfset var vars = {}>
  <cfquery name="vars.qBudget" datasource="#application.datasource#">
      SELECT Budget_desc
             , Budget_Group_Id
             , Budget_Class_Id
             , Budget_Contribution_Factor_Type_Id
             , Budget_Code
             , Notification_Threshold_Commitments
             , Notification_Threshold_Actuals
             , Allocation_Position_Level
             , Holdback_Percentage
             , Participation_Required
             , Recapture
             <!--- , Net_Contribution --->
             , Overlays
             , Corporate_And_Local_Rate
             , Overlay_Recapture
             , Budget_Status
             , Business_Segment_Id
             , Position_Control_Type
             , Budget_Owner_Position_ID
             , Notification_Emails
             , Recapture_Forecast_Days          <!--- 34591 --->
             , Overlay_Calculation
             , Price_List_ID
             , Calculation_Frequency <!--- D56006 --->
             ,Calculation_Start_Date<!--- D56006 --->
             ,Calculation_End_Date<!--- D56006 --->
			 ,Is_Perpetual<!---D64149 --->
			 , ISNULL(Added_From_Number, '') as Added_From_Number
        FROM Budget
       WHERE Budget.Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfscript>
     form.Budget_desc      = vars.qBudget.Budget_desc;
     form.Budget_Group_Id  = vars.qBudget.Budget_Group_Id;
     form.Budget_Class_Id  = vars.qBudget.Budget_Class_Id;
     form.Budget_Contribution_Factor_Type_Id = vars.qBudget.Budget_Contribution_Factor_Type_Id;
     form.Budget_Code      = vars.qBudget.Budget_Code;
     form.Notification_Threshold_Commitments  =  vars.qBudget.Notification_Threshold_Commitments;
     form.Notification_Threshold_Actuals      =  vars.qBudget.Notification_Threshold_Actuals;
     form.Allocation_Position_Level           =  vars.qBudget.Allocation_Position_Level;
     form.Holdback_Percentage                 =  vars.qBudget.Holdback_Percentage;
     form.Participation_Required = vars.qBudget.Participation_Required;
     form.Recapture              = vars.qBudget.Recapture;
     //form.Net_Contribution       = vars.qBudget.Net_Contribution;
     form.Overlays                 = vars.qBudget.Overlays;
     form.Corporate_And_Local_Rate = vars.qBudget.Corporate_And_Local_Rate;
     form.Overlay_Recapture        = vars.qBudget.Overlay_Recapture;
     form.Budget_Status            = vars.qBudget.Budget_Status;
     form.Business_Segment_Id      = vars.qBudget.Business_Segment_Id;
     form.Position_Control_Type    = vars.qBudget.Position_Control_Type;
     form.Budget_Owner_Position_ID = vars.qBudget.Budget_Owner_Position_ID;
     form.Notification_Emails      = vars.qBudget.Notification_Emails;
     form.Recapture_Forecast_Days  = vars.qBudget.Recapture_Forecast_Days;    // 34591
     form.overlay_calculation      = vars.qBudget.overlay_calculation;
     form.Price_List_ID     	   = vars.qBudget.Price_List_ID;
     form.calculation_frequency = vars.qBudget.Calculation_Frequency;//D56006
     form.Calculation_Start_Date = vars.qBudget.Calculation_Start_Date;//D56006
     form.Calculation_End_Date = vars.qBudget.Calculation_End_Date;//D56006
     form.Is_Perpetual = vars.qBudget.Is_Perpetual; //D64149
     form.Added_From_Number = vars.qBudget.Added_From_Number;
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="NumericValue" output="false" hint="I return the numeric value of a string.">
  <cfargument name="numericString" required="true" hint="I am the numeric string.">
  <cfif Len(Trim( arguments.numericString )) eq 0>
    <cfreturn 0>
  <cfelseif IsNumeric( arguments.numericString )>
    <cfreturn arguments.numericString>
  <cfelse>
    <cfreturn 0>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveAccrualBudget" output="false">
  <cfset var vars = {}>
  <!---clear out position id when allocation control point is selected--->
  <cfif form.Position_Control_Type eq "1">
    <cfset form.Budget_Owner_Position_ID = 0>
  <cfelse>
    <!---clear out allocation control point when allocation control position is selected--->
    <cfset form.Allocation_Position_Level = 0>
  </cfif>
  <cftransaction>
  <cfset form.overlays = form.overlay_calculation eq "0" ? 0 : 1>
  <cfquery name="vars.saveBudget" datasource="#application.datasource#">
    <!---budget_id is greater than zero, update existing budget--->
    <cfif form.Budget_Id gt 0>
    	DECLARE @Allocation_Position_Level INT, @Position_Control_Type INT
			SELECT  @Allocation_Position_Level = Allocation_Position_Level
			       ,@Position_Control_Type     = Position_Control_Type
			  FROM Budget
			 WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">

      UPDATE Budget
         SET   Budget_Code = <cfqueryparam value="#form.Budget_Code#" cfsqltype="cf_sql_varchar">
             , Budget_Desc = <cfqueryparam value="#form.Budget_Desc#" cfsqltype="cf_sql_varchar">
             , Budget_Group_Id = <cfqueryparam value="#form.Budget_Group_ID#" cfsqltype="cf_sql_integer">
             , Budget_Class_Id = <cfqueryparam value="#form.Budget_Class_ID#" cfsqltype="cf_sql_integer">
             , Budget_Contribution_Factor_Type_ID = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
             , Notification_Threshold_Commitments = <cfqueryparam value="#NumericValue(form.Notification_Threshold_Commitments)#" cfsqltype="cf_sql_integer">
             , Notification_Threshold_Actuals = <cfqueryparam value="#NumericValue(form.Notification_Threshold_Actuals)#" cfsqltype="cf_sql_integer">
             , Allocation_Position_Level = <cfqueryparam value="#Val(form.Allocation_Position_Level)#" cfsqltype="cf_sql_integer">
             , Holdback_Percentage = <cfqueryparam value="#NumericValue(form.Holdback_Percentage)#" cfsqltype="cf_sql_integer">
             , Participation_Required = <cfqueryparam value="#form.Participation_Required#" cfsqltype="cf_sql_bit">
             , Recapture = <cfqueryparam value="#form.Recapture#" cfsqltype="cf_sql_bit">
             <!--- , Net_Contribution = <cfqueryparam value="#form.Net_Contribution#" cfsqltype="cf_sql_bit"> --->
             , Overlays = <cfqueryparam value="#form.Overlays#" cfsqltype="cf_sql_bit">
             , Corporate_And_Local_Rate = <cfqueryparam value="#form.Corporate_And_Local_Rate#" cfsqltype="cf_sql_bit">
             , Overlay_Recapture = <cfqueryparam value="#form.Overlay_Recapture#" cfsqltype="cf_sql_bit">
             , Business_Segment_Id = <cfqueryparam value="#Val(form.Business_Segment_Id)#" cfsqltype="cf_sql_integer">
             , Position_Control_Type = <cfqueryparam value="#form.Position_Control_Type#" cfsqltype="cf_sql_integer">
             , Budget_Owner_Position_ID = <cfqueryparam value="#Val(form.Budget_Owner_Position_ID)#" cfsqltype="cf_sql_integer">
             , Notification_Emails = <cfqueryparam value="#form.Notification_Emails#" cfsqltype="cf_sql_varchar">
             , Recapture_Forecast_Days = <cfqueryparam value="#val(form.Recapture_Forecast_Days)#" cfsqltype="cf_sql_integer">  <!--- 34591 --->
             , Overlay_Calculation = <cfqueryparam value="#form.overlay_calculation#" cfsqltype="cf_sql_integer">
             , Price_List_ID = <cfqueryparam value="#form.Price_List_ID#" cfsqltype="cf_sql_varchar">
	       ,Calculation_Frequency = <cfqueryparam value="#form.Calculation_Frequency#" cfsqltype="cf_sql_bit"><!---D56006 --->
              ,Calculation_Start_Date = <cfqueryparam value="#form.Calculation_Start_Date#" cfsqltype="CF_SQL_DATE"><!---D56006 --->
              ,Calculation_End_Date = <cfqueryparam value="#form.Calculation_End_Date#" cfsqltype="CF_SQL_DATE"><!---D56006 --->
			  , Is_Perpetual = <cfqueryparam value="#form.Is_Perpetual#" cfsqltype="cf_sql_bit">	<!---D64149 --->
       WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">

      <cfinclude template="last_update.cfm">       <!--- 36874 --->

      <!---zap out existing budget adjustments when allocation control point is changed--->
      IF  (@Allocation_Position_Level != <cfqueryparam value="#Val(form.Allocation_Position_Level)#" cfsqltype="cf_sql_integer">)
       OR (@Position_Control_Type     != <cfqueryparam value="#form.Position_Control_Type#" cfsqltype="cf_sql_integer">)
      BEGIN
        UPDATE Budget_Adjustment
           SET Deleted = 1
         WHERE Budget_Id = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">

        <!---reset adjustment dollars, budget amounts--->
				UPDATE Budget_Distributor_Allocation
				   SET Adjustment_Dollar = 0
				       ,Budget_Dollar = ISNULL(Original_Budget_Dollar, 0)
				 WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">

				UPDATE Budget_Position_Allocation
				   SET Adjustment_Dollar = 0
				       ,Budget_Dollar = ISNULL(Original_Budget_Dollar, 0)
				 WHERE Budget_ID = <cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">
      END
    <cfelse>
    	SET NOCOUNT ON
      INSERT INTO BUDGET
          ( <!---01---> Budget_Desc
          , <!---02---> Budget_Group_ID
          , <!---03---> Budget_Class_ID
          , <!---04---> Budget_Contribution_Factor_Type_ID
          , <!---05---> Notification_Threshold_Commitments
          , <!---06---> Notification_Threshold_Actuals
          , <!---07---> Allocation_Position_Level
          , <!---08---> Holdback_Percentage
          , <!---09---> Participation_Required
          , <!---10---> Recapture
          <!---, 11 Net_Contribution--->
          , <!---12---> Overlays
          , <!---13---> Corporate_And_Local_Rate
          , <!---14---> Overlay_Recapture
          , <!---15---> Active
          , <!---16---> Budget_Code
          , <!---17---> Business_Segment_Id
          , <!---18---> Position_Control_Type
          , <!---19---> Budget_Owner_Position_ID
          , <!---20---> Notification_Emails
          , <!---21---> Recapture_Forecast_Days           <!--- 34591 --->
          , <!---22---> Last_Updated_By
          , <!---23---> Overlay_Calculation
          , <!---24---> Price_List_ID
          , <!---25--->Calculation_Frequency <!---D56006 --->
          , <!---26--->Calculation_Start_Date <!---D56006 --->
          , <!---27--->Calculation_End_Date <!---D56006 --->
		  , <!---28---> Is_Perpetual<!---D64149 --->
          )
      VALUES
          ( <!---01---> <cfqueryparam value="#form.Budget_Desc#" cfsqltype="cf_sql_varchar">
          , <!---02---> <cfqueryparam value="#form.Budget_Group_ID#" cfsqltype="cf_sql_integer">
          , <!---03---> <cfqueryparam value="#form.Budget_Class_ID#" cfsqltype="cf_sql_integer">
          , <!---04---> <cfqueryparam value="2" cfsqltype="cf_sql_integer">
          , <!---05---> <cfqueryparam value="#NumericValue(form.Notification_Threshold_Commitments)#" cfsqltype="cf_sql_integer">
          , <!---06---> <cfqueryparam value="#NumericValue(form.Notification_Threshold_Actuals)#" cfsqltype="cf_sql_integer">
          , <!---07---> <cfqueryparam value="#Val(form.Allocation_Position_Level)#" cfsqltype="cf_sql_integer">
          , <!---08---> <cfqueryparam value="#NumericValue(form.Holdback_Percentage)#" cfsqltype="cf_sql_integer">
          , <!---09---> <cfqueryparam value="#form.Participation_Required#" cfsqltype="cf_sql_bit">
          , <!---10---> <cfqueryparam value="#form.Recapture#" cfsqltype="cf_sql_bit">
          <!---, 11 <cfqueryparam value="#form.Net_Contribution#" cfsqltype="cf_sql_bit">--->
          , <!---12---> <cfqueryparam value="#form.Overlays#" cfsqltype="cf_sql_bit">
          , <!---13---> <cfqueryparam value="#form.Corporate_And_Local_Rate#" cfsqltype="cf_sql_bit">
          , <!---14---> <cfqueryparam value="#form.Overlay_Recapture#" cfsqltype="cf_sql_bit">
          , <!---15---> 0
          , <!---16---> <cfqueryparam value="#form.Budget_Code#" cfsqltype="cf_sql_varchar">
          , <!---17---> <cfqueryparam value="#Val(form.Business_Segment_Id)#" cfsqltype="cf_sql_integer">
          , <!---18---> <cfqueryparam value="#form.Position_Control_Type#" cfsqltype="cf_sql_integer">
          , <!---19---> <cfqueryparam value="#Val(form.Budget_Owner_Position_ID)#" cfsqltype="cf_sql_integer">
          , <!---20---> <cfqueryparam value="#form.Notification_Emails#" cfsqltype="cf_sql_varchar">
          , <!---21---> <cfqueryparam value="#val(form.Recapture_Forecast_Days)#" cfsqltype="cf_sql_integer">    <!--- 34591 --->
          , <!---22---> <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
          , <!---23---> <cfqueryparam value="#form.overlay_calculation#" cfsqltype="cf_sql_integer">
          , <!---24---> <cfqueryparam value="#form.Price_List_ID#" cfsqltype="cf_sql_varchar">
	      , <!---25---> <cfqueryparam value="#form.Calculation_Frequency#" cfsqltype="cf_sql_bit"><!---D56006 --->
          , <!---26---> <cfqueryparam value="#form.Calculation_Start_Date#" cfsqltype="CF_SQL_DATE"><!---D56006 --->
          , <!---27---> <cfqueryparam value="#form.Calculation_End_Date#" cfsqltype="CF_SQL_DATE"><!---D56006 --->
          , <!---28---> <cfqueryparam value="#form.Is_Perpetual#" cfsqltype="cf_sql_bit"><!---D64149 --->
          )
      <!---get the new Budget_Id--->
    	SELECT Budget_Id = @@IDENTITY
    	SET NOCOUNT OFF
    </cfif>
  </cfquery>
	<cfquery name="vars.delInvoiceFilter" datasource="#application.datasource#">
		UPDATE Budget_Position_Filter SET Deleted = 1 WHERE Budget_ID = <cfqueryparam value="#form.Budget_Id#" cfsqltype="cf_sql_integer">
	</cfquery>


	 	<cfloop list= "#FORM.Market_Invoice_Filter_ID#" index = "position_ID">
			<cfif position_ID NEQ "0">
	  	 		<cfquery name="vars.saveInvoiceFilter" datasource="#application.datasource#">
					INSERT INTO Budget_Position_Filter
					(
						Budget_Id,
						User_Position_ID,
						Created_Date,
						Updated_By
					)
					VALUES
					(
						<cfqueryparam value="#form.budget_id#" cfsqltype="cf_sql_integer">,
						#position_ID#,
						GetDate(),
						<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
					)
				</cfquery>
			</cfif> <!--- <cfif position_ID NEQ "0"> --->
		</cfloop>


  <cfif form.Budget_Id eq 0>
    <!---get the new Budget_Id--->
    <cfset form.Budget_Id = vars.saveBudget.Budget_Id>
  <cfelse>
    <cfinclude template="validateAccrual.cfm">
  </cfif>

  </cftransaction>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cfset files_to_pull = [  "/script/javascript/jquery.cfjs.min.js"
                        , "/script/javascript/google/base.min.js"
                        , "/script/javascript/google/string.min.js"
                        , "/script/javascript/google/emailaddress.min.js"  ]>
<cf_include files="#arrayToList(files_to_pull)#">

<script type="text/javascript">
document.forms[budget_form].load_fromdb.value  = "0";
// forceNumeric() plug-in implementation
$.fn.forceNumeric = function () {
   return this.each(function () {
       $(this).keydown(function (e) {
           var key = e.which || e.keyCode;
           if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
           <!---numbers--->
               ( key >= 48 && key <= 57 ) ||
           <!---Numeric keypad--->
               ( key >= 96 && key <= 105 ) ||
           <!---comma, period and minus--->
              key == 190 || key == 188 || key == 109 ||
           <!---Backspace and Tab and Enter--->
              key == 8 || key == 9 || key == 13 ||
           <!---Home and End--->
              key == 35 || key == 36 ||
           <!---left, up and right, down arrows--->
              ( key >= 37 && key <= 40 ) ||
           <!---Decimal point on numeric keypad--->
              key == 110 ||
           <!---Del and Ins--->
              key == 46 || key == 45) {
             return true;
           }
           return false;
       });
   });
}
$('.numeric').forceNumeric();
<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
const report_url = "index.cfm"
                    + "?byClassIDs=#trim(url.byClassIDs)#"
                    + "&byBudgetCodes=#trim(url.byBudgetCodes)#"
                    + "&byGroupIDs=#trim(url.byGroupIDs)#"
                    + "&bySearch=#trim(url.bySearch)#"
                    + "&byBudgetTypeIDs=#trim(url.byBudgetTypeIDs)#"
                    + "&bySegmentIDs=#trim(url.bySegmentIDs)#"
                    + "&command=calculateAccrual"
                    + "&budget_id=" + document.forms[budget_form].budget_id.value;    
</cfoutput>

function calcaccrual() {
    window.location = report_url + "&calculate=1";
}
<!--------------------------------------------------------------------------------------------------------------------->
function overlay( enabled ) {
  $('.overlay_recapture').attr('disabled', enabled!=1);
  if (enabled != 1)
    document.forms[budget_form].overlay_recapture.value = "0";
}
<!--------------------------------------------------------------------------------------------------------------------->
function report() {
  window.location = report_url;
}
<!--------------------------------------------------------------------------------------------------------------------->
function pct( obj ) {
  if ($(obj).val() == 1) {  <!---allocation control point--->
  	$('#select_point').show();
  	$('#select_position').hide();
//	$('#Invoice_filter').show();
//	$('#view_Invoice_filter').show();
  }
  else {                 <!---allocation control by position--->
  	$('#select_position').show();
  	$('#select_point').hide();
//	$('#Invoice_filter').hide();
//	$('#view_Invoice_filter').hide();
  }
}
<!--------------------------------------------------------------------------------------------------------------------->
function saveaccrual() {
  var error_cnt = 0;
  <!---validate form fields--->
  if ( $.trim(document.forms[budget_form].budget_code.value).length )
    clearQueue(document.all.error_budget_code);
  else {
    error_cnt++; queueMessage("Please enter the " + <cfoutput>"#labelInMessage(formlabels.code)#."</cfoutput>, document.all.error_budget_code);
  }
  if ( $.trim(document.forms[budget_form].budget_desc.value).length )
    clearQueue(document.all.error_budget_desc);
  else {
    error_cnt++; queueMessage("Please enter the " + <cfoutput>"#labelInMessage(formlabels.desc)#."</cfoutput>, document.all.error_budget_desc);
  }
  if ( document.forms[budget_form].budget_class_id.value > 0 )
    clearQueue(document.all.error_budget_class_id);
  else {
    error_cnt++; queueMessage("Please select the " + <cfoutput>"#labelInMessage(formlabels.class)#."</cfoutput>, document.all.error_budget_class_id);
  }
  if ( document.forms[budget_form].budget_group_id.value > 0 )
    clearQueue(document.all.error_budget_group_id);
  else {
    error_cnt++; queueMessage("Please select the " + <cfoutput>"#labelInMessage(formlabels.group)#."</cfoutput>, document.all.error_budget_group_id);
  }
  if ( $.trim(document.forms[budget_form].notification_threshold_commitments.value).length
    && $.IsValid("integer", document.forms[budget_form].notification_threshold_commitments.value)
    && $.IsValid("range", document.forms[budget_form].notification_threshold_commitments.value, 0, 999) )
    clearQueue(document.all.error_notification_threshold_commitments);
  else {
    error_cnt++; queueMessage("Please enter a whole number between 0 and 999 for notification threshold for commitment.", document.all.error_notification_threshold_commitments);
  }
  if ( $.trim(document.forms[budget_form].notification_threshold_actuals.value).length
   &&  $.IsValid("integer", document.forms[budget_form].notification_threshold_actuals.value)
   &&  $.IsValid("range", document.forms[budget_form].notification_threshold_actuals.value, 0, 999) )
    clearQueue(document.all.error_notification_threshold_actuals);
  else {
    error_cnt++; queueMessage("Please enter a whole number between 0 and 999 for notification threshold for actual.", document.all.error_notification_threshold_actuals);
  }
  if ($('input[name=position_control_type]:checked').val() == 1) {
    if ( document.forms[budget_form].allocation_position_level.value != <cfoutput>#const.unselected#</cfoutput> )
      clearQueue(document.all.error_allocation_position_level);
    else {
      error_cnt++; queueMessage("Please select the allocation control point.", document.all.error_allocation_position_level);
    }
  }
  else {
    clearQueue(document.all.error_allocation_position_level);
  }
  <cfif busSegMgr.isEnabled>
    if ( document.forms[budget_form].business_segment_id.value != 0 )
      clearQueue(document.all.error_business_segment_id);
    else {
      error_cnt++; queueMessage("Please select the " + <cfoutput>"#labelInMessage(formlabels.segment)#."</cfoutput>, document.all.error_business_segment_id);
    }
  </cfif>

  if ( $.trim(document.forms[budget_form].holdback_percentage.value).length
    &&  $.IsValid("integer", document.forms[budget_form].holdback_percentage.value)
    &&  $.IsValid("range", document.forms[budget_form].holdback_percentage.value, 0, 100) )
    clearQueue(document.all.error_holdback_percentage);
  else {
    error_cnt++; queueMessage("Please enter a whole number between 0 and 100 for hold back.", document.all.error_holdback_percentage);
  }

  if ( (goog.string.isEmpty(document.all.notification_emails.value)) || (goog.format.EmailAddress.isValidAddress(document.all.notification_emails.value)) ) {
    clearQueue(document.all.error_notification_emails);
  }
  else {
    error_cnt++; queueMessage("Please review and correct the email addresses", document.all.error_notification_emails);
  }
  //D56006 :: New Budget Feature - Accrual:  calculate once and stop. START
  if ( document.forms[budget_form].Calculation_Frequency.value == 1) {
		if ($.trim(document.forms[budget_form].Calculation_Start_Date.value).length == 0 || $.trim(document.forms[budget_form].Calculation_End_Date.value).length == 0) {
			error_cnt++;
			queueMessage("Please enter Calculation Start Date Calculation End Date.", document.all.error_Calculation_Frequency);
		}
		else {
			clearQueue(document.all.error_Calculation_Frequency);
		}

  		if (document.forms[budget_form].Calculation_Start_Date.value >= '<cfoutput>#DateFormat(now(), 'mm/dd/yyyy')#</cfoutput>') {
			error_cnt++;
			queueMessage("Calculation Start Date should be in past.", document.all.error_Calculation_Start_Date);
		}
		else {
			clearQueue(document.all.error_Calculation_Start_Date);
		}

            if (document.forms[budget_form].Calculation_End_Date.value >= '<cfoutput>#DateFormat(now(), 'mm/dd/yyyy')#</cfoutput>') {
                  error_cnt++;
                  queueMessage("Calculation End Date should be in past.", document.all.error_Calculation_End_Date);
            }
            else {
                  clearQueue(document.all.error_Calculation_End_Date);
            }

        if (document.forms[budget_form].Calculation_Start_Date.value > document.forms[budget_form].Calculation_End_Date.value ) {
                 error_cnt++;
                queueMessage("Calculation End Date should be greater than Calculation Start Date.", document.all.error_Calculation_End_Date);
            }
          else {
                clearQueue(document.all.error_Calculation_End_Date);
          }
 }
   //D56006 :: New Budget Feature - Accrual:  calculate once and stop. END

  if ( error_cnt > 0 ) {
    showMessageWindow();
  }
  else {
  <cfoutput>
    document.forms[budget_form].action = 'index.cfm?bySearch=#form.bySearch#&byClassIDs=#url.byClassIDs#&byBudgetCodes=#trim(url.byBudgetCodes)#&byGroupIDs=#url.byGroupIDs#&byBudgetTypeIDs=#url.byBudgetTypeIDs#&bySegmentIDs=#url.bySegmentIDs#';  
   </cfoutput>
    document.forms[budget_form].command.value = "saveAccrual";
    document.forms[budget_form].clicked_save.value = "1";
    document.forms[budget_form].submit();
  }
}
<!--------------------------------------------------------------------------------------------------------------------->
function select_position() {
 if ($('input[name=position_control_type]:checked').val() == 2)
   NewWindow("/Search_Screens/Select_User_Position.cfm?FormName=" + budget_form
              + "&FieldName=budget_owner_position_id"
              + "&SelectSingleSearchResultOnly=1"
              + "&AllowImportAll=0"
              + "&EnableListOfPositionsAboveMine=1&Business_Segment_Id=" +<cfoutput>#form.Business_Segment_Id#</cfoutput>
              , "Positionwindow", 850, 600, "yes", "yes");
}<!--- D28618: Position Drop Down Fields filtered based on Program Business Segment   Added URL variable Business Segment ID--->
<!--------------------------------------------------------------------------------------------------------------------->
function Invoice_Filter() {
 if ($('input[name=position_control_type]:checked').val() == 1)
    NewWindow("/Search_Screens/Select_User_Position.cfm?FormName=" + budget_form
			  + "&FieldName=Market_Invoice_Filter_ID"
              + "&SelectSingleSearchResultOnly=0"
              + "&AllowImportAll=1"
			  + "&RestrictPositionLevel=3"
              + "&EnableListOfPositionsAboveMine=1&Business_Segment_Id=" +<cfoutput>#form.Business_Segment_Id#</cfoutput>
              , "Positionwindow", 850, 600, "yes", "yes");
}
function view_Invoice_Filter()
{
 if ($('input[name=position_control_type]:checked').val() == 1)
   NewWindow("/budget/view_market_purchase_filter.cfm?budget_id=" +<cfoutput>#form.Budget_ID#</cfoutput>
              , "InvoiceFilter", 850, 600, "yes", "yes");
}
<!--- 49540: App Setting - Use_Invoice_Market/Anand Rao/21-Apr-2015  --->

<!--------------------------------------------------------------------------------------------------------------------->
function switchfactor( factor ) {
  if ( factor.value == 2 )
    return false;
  if ( factor.value == 1 )
    document.forms[budget_form].command.value = "editFixed";
  if ( factor.value == 3 )
    document.forms[budget_form].command.value = "editVariable";
  document.forms[budget_form].submit();
}
<!--------------------------------------------------------------------------------------------------------------------->
<!--- 34591 --->
$('.overlay_recapture, .recapture').change( function() {
	// if either recapture base is yes OR recapture overlay is yes enable recapture forecast parameter (rfp) input
	if ($('input[name=overlay_recapture]:checked').val() == 1 || $('input[name=recapture]:checked').val() == 1) {
		$('#rfp').fadeIn('slow');
	}
	else {
		$('#rfp').fadeOut('slow');
	}
});
function showCalDates(FreqVal){
	if(FreqVal.value == 1){
		document.getElementById('caldates').style.display = 'block';
	}
	else{
		document.getElementById('caldates').style.display = 'none';
	}
}
</script>