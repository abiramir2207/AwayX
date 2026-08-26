<!---------------------------------------------------------------------------------------------------------------------
      Template: C:\Forge\base\AwayX\Common_Files\contracts\Letters\quoteLetter\custom3.cfm
      Date:     2014 August
      Author:   Chris Nguyen
      Purpose:  Generate Quote Letter Custom Type 3 ( Kraft )

      Required parameter:
      - URL.Contract_Main_ID (integer)
      - URL.Email (bit) 1 = email quote letter
----------------------------------------------------------------------------------------------------------------------->
<cfprocessingdirective pageencoding="utf-8">

<cfoutput>
<cfparam name="request.language" default="">

<link rel="stylesheet" href="/common_files/960_16_col.css" />   <!--- see knowledgebase for more info on this framework --->
<cfif URL.Email neq "1">
  <style type="text/css">
    .mb74 { margin-bottom: 7px; }
  </style>
  <cfinclude template="/common_files/jQuery.cfm">

  <div class="container_16 mb74">
    <div class="grid_2">
      <div id="google_translate_element">
        <cfquery name="vars.qTemplateLanguage" datasource="#application.datasource#">
          SELECT Label_Set_Default, b.ProgramType_ID
            FROM Program_Control_Panel_Options a
                 INNER JOIN Contract_Main b ON b.Contract_Main_ID = #URL.Contract_Main_ID#
           WHERE ProgramControl_Panel_Options_ID = b.ProgramType_ID
        </cfquery>

        <cfif request.AccessStructure.User_Language eq "French" AND vars.qTemplateLanguage.Label_Set_Default eq "French">
          <style type="text/css">body {position: static !important; top:0px !important;}</style>

          <script>
            var current_lang = '';
            function googleTranslateElementInit() {
              new google.translate.TranslateElement({pageLanguage: 'en', includedLanguages: 'fr,en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
            }

            $(function(){
              window.setInterval(function(){
               var lang = $(".goog-te-menu-value span:first").text();
               if (lang !== current_lang && lang !== 'Select Language') {
                  current_lang = lang;
                  // alert(current_lang);
                  if (current_lang.toLowerCase() == "french") {
                    $('.english').hide();
                    $('.french').show();
                  }
                  else {
                    $('.english').show();
                    $('.french').hide();
                  }
               }
              }, 2000);
            });
          </script>
          <script src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
        <cfelse>
          &nbsp;
        </cfif>
      </div>
    </div>

    <div class="grid_2 prefix_4">
    	<a href="##" id="em249" class="nonprintable">#application.util.string.actionLinkFormat2("email")#</a>
    </div>
    <div class="grid_2 prefix_1 suffix_5">
    	<a href="##" onClick="window.print()" class="nonprintable">#application.util.string.actionLinkFormat2("print")#</a>
    </div>
	</div>

  <script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
  <script>
    $(function(){
      $("##em249").click(function(){
        // if price confirmation is on the screen language is english otherwise language is french
        var lang = ( $.FindNoCase('price confirmation', $("##pc13").text()) ? "english" : "french" );
        window.location = 'emailQuoteLetter.cfm?Contract_Main_ID=#url.Contract_Main_ID#&Contract_Number=#vars.qProgram.Contract_Number#&lang=' + lang;
      });

      // detect english language & hide French clauses
      if ( $("##pc13:contains(price confirmation)") ) {
        $('.english').show();
        $('.french').hide();
      }
    });
  </script>
</cfif>
<cfset QuoteLetter()>
</cfoutput>
<cfreturn>


<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="QuoteLetter" returntype="string" output="true">
<style type="text/css">
p { font-size:8pt; line-height:120%; }
hr {
    padding: 3px 0;
    border:none;
    border-top: 1px solid ##333;
}
.dollar {
  text-align:right !important;
}
.center {
  text-align:center !important;
}
.right {
  text-align:right !important;
}
.opa_group {
  color:##000;
  margin:35px 0 5px 0;
  font-weight: bold;
}
.small {
  font-size:10px;
  font-weight:normal;
  position:relative;
  top:-5px;
}
table.Design2 {
  border-top:1px solid ##666;
  border-left:1px solid ##666;
  margin-bottom:10px;
  width:99%;
}
table.Design2 td {
  border-right:1px solid ##666;
  border-bottom:1px solid ##666;
  padding:.4em .4em;
  vertical-align: top;
}
table.Design2 th {
  border-right:1px solid ##666;
  border-bottom:1px solid ##666;
  border-collapse: collapse;
  font-weight:400;
  padding:.4em .4em;
}
table.Design2 th.Corner {
  text-align:left;
}
table.Design2 thead th {
  background-color:##E5E5E5;
  color:##000;
  font-weight: bold;
  font-size: 10px;
  text-align:left;
}
div.confidentiality { margin-top:20px; }
</style>

<cfquery name="vars.qDiscountTypes" datasource="#application.datasource#">
  SELECT DISTINCT( dt.Discount_Type_desc )
    FROM Contract_Products cp
         INNER JOIN Discount_Type dt ON cp.Product_Type_Id = dt.Discount_Type_Id
                                        AND dt.Deleted = 0
   WHERE cp.Contract_Main_Id = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
         AND cp.Product_Type_Id <> 3 --- not a lump sum
         AND cp.Deleted = 0
   UNION
  SELECT TOP 1 Discount_Type_desc
    FROM Discount_Type dt
         INNER JOIN Program_Lump_Sums ls ON ls.Program_Id = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
                                        AND ls.Deleted = 0
   WHERE dt.Discount_Type_Id = 3 --- lump sum
</cfquery>

<cfquery name="vars.qClauses" datasource="#application.datasource#">
  SELECT l.Clause_Library_Body, l.Clause_Library_Body_French
    FROM Clause_Program p
         INNER JOIN dbo.Clause_Library l ON l.Clause_Library_ID = p.Clause_Library_ID AND l.Deleted = 0
   WHERE p.Program_Id = #url.Contract_Main_ID#
         AND p.Deleted = 0
</cfquery>

<cfset vars.customerProduct = false>

<cfsavecontent variable="variables.letterContent">
<cfoutput>
<!----------------->
<!---  HEADING  --->
<!----------------->
<!---need to specify the full URL so image would be shown up on email--->
<div class="container_16 mb74">
  <div class="grid_16 mb74">
    <img src="http://#cgi.server_name#/#vars.appsettings.getletterscompanylogopath()#" height="50" width="131" title="Company Logo">
  </div>
  <div class="grid_2"><b>Date:<br><br>Contract Name:</b></div>
  <div class="grid_7">#DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br><br>#vars.qProgram.Contract_Title#</div>
  <div class="grid_7" id="pc13"><b>Price Confirmation:</b> #vars.qProgram.Contract_Number#</div>
</div>

<cfif vars.qOperators.recordCount>
  <div class="container_16 mb74">
    <div class="grid_2"><b>#application.returned_customer_setting.operator_label_singular#:</b></div>
    <div class="grid_7 suffix_7">
      #vars.qOperators.Operator_Name#<br>
      #vars.qOperators.Operator_Address#<br>
      #trim(vars.qOperators.Operator_City)# #trim(vars.qOperators.Operator_State)# #vars.qOperators.Operator_Zip#
    </div>
  </div>
</cfif>

<div class="container_16 mb74">
  <div class="grid_16"><hr></div>
  <div class="grid_2"><b>Effective Dates:<br>Print Date:</b></div>
  <div class="grid_7">#DateFormat(vars.qProgram.Effective_Start_Date,'long')# Through #DateFormat(vars.qProgram.Effective_End_Date,'long')#<br>#DateFormat(now(),'long')#</div>
  <div class="grid_7"><b>Price Type:</b> #valueList(vars.qDiscountTypes.Discount_Type_desc, ", ")#</div>
  <div class="grid_16"><hr></div>
</div>

<!----------------->
<!---  MESSAGE  --->
<!----------------->
<div class="container_16">
  <div class="grid_16">
  <cfif vars.qOperators.recordCount>
    <p>#trim(vars.qOperators.Operator_Name)#,</p>
  </cfif>

  <p>We are pleased to confirm pricing information for orders requested for delivery between #DateFormat(vars.qProgram.Effective_Start_Date,'long')# and #DateFormat(vars.qProgram.Effective_End_Date,'long')# <cfif vars.qOperators.recordCount>for the above name operator Contractee</cfif>. During this time period, <cfif vars.qOperators.recordCount>#trim(vars.qOperators.Operator_Name)#</cfif> orders through your authorized distributor will be priced by #application.returned_customer_setting.company_name# to your authorized distributor at a maximum of the #lcase(valueList(vars.qDiscountTypes.Discount_Type_desc,", "))# type for the product(s) found in the pricing table (showing prices, allowance and contract volume).</p>

  <p>The prices do not include any distributor mark-up or distributor surcharges.  Distributor mark-ups and other distributor charges are to be negotiated solely between the distributor and operator.</p>

  <p>This letter deals with pricing, compliance and confidentiality matters only and is not to be construed as a guarantee of product availability or supply.</p>

  <p>Sincerely,</p>

  <br><br><br>
  <p>#vars.qProgram.RSP_Name#</p>
  <p>#application.returned_customer_setting.company_name# Representative</p>
  </div>
</div>
</cfoutput>

<!----------------->
<!---  CLAUSES  --->
<!----------------->
<cfif request.language neq "french">
  <cfloop query="vars.qClauses">
    <div class="container_16 notranslate english">
      <div class="grid_16">
        #vars.qClauses.Clause_library_body#
      </div>
    </div>
  </cfloop>
</cfif>

<cfif vars.qClauses.recordCount and len(vars.qClauses.Clause_library_body_French)>
  <div class="container_16 notranslate french">
    <div class="grid_16">
        #vars.qClauses.Clause_library_body_French#
    </div>
  </div>
</cfif>

<!---------------------->
<!---  DISTRIBUTORS  --->
<!---------------------->
<div class="container_16">
  <div class="grid_16">
    <p class="opa_group">List of Authorized #application.returned_customer_setting.distributor_label_plural#</p>
    <table id="opa_distributors" class="Design2" cellspacing="0" cellpadding="0">
      <thead>
        <tr>
          <th>Customer Number</th>
          <th>Company Name</th>
          <th>Address</th>
        </tr>
      </thead>
      <tbody>
        <cfoutput query="vars.qDistributors"<!---  group="Shr_Ship_To" --->>
          <tr>
			<cfif (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
				<td>#vars.qDistributors.Shr_Ship_To#</td>
			<cfelse>
				<td>#vars.qDistributors.Ship_To#</td>
			</cfif>	
            <td>#vars.qDistributors.Name#</td>
            <td>#trim(vars.qDistributors.Address_1)# #trim(vars.qDistributors.City)# #vars.qDistributors.State# #vars.qDistributors.ZipCode#</td>
          </tr>
        </cfoutput>
      </tbody>
    </table>
  </div>
</div>

<!---------------------------->
<!---  FIXED RATE PRODUCTS --->
<!---------------------------->
<cfif vars.qFixedPricedItems.recordCount gt 0>
  <div class="container_16">
    <div class="grid_16">
      <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>Confirmation No. #vars.qProgram.Contract_Number# - Fixed Price</p>
      <table class="Design2" cellspacing="0" cellpadding="0">
      <thead>
        <tr>
          <th>SCC##</th>
          <th>#application.returned_customer_setting.Item_Label# Description</th>
          <cfif vars.customerProduct>
            <th>Customer #application.returned_customer_setting.Item_Label# Number</th>
          </cfif>
          <th class="center">Est Volume</th>
          <th class="center">UOM</th>
          <th class="center">Fixed Rate</th>
        </tr>
      </thead>
      <tbody>
        <cfloop query="vars.qFixedPricedItems" >
          <tr>
            <td>#vars.qFixedPricedItems.Item#</td>
            <td>#vars.qFixedPricedItems.Description#</td>
            <td class="right">
              <cfif trim(vars.qFixedPricedItems.abbreviation) eq 'cs'>
                #numberFormat( vars.qFixedPricedItems.volume_cs, ",_" )#
              <cfelse>
                #numberFormat( vars.qFixedPricedItems.volume_lb, ",_.__" )#
              </cfif>
            </td>  <!--- est vol --->
            <td class="center">#vars.qFixedPricedItems.Abbreviation#</td>
            <td class="dollar">#numberformat(vars.qFixedPricedItems.Fixed_Price_Value,"$_.__")#</td>
          </tr>
        </cfloop>
      </tbody>
      </table>
    </div>
  </div>
</cfif>

<!------------------------>
<!---  REBATE PRODUCTS --->
<!------------------------>
<cfif vars.qFixedAllowances.recordCount gt 0>
  <div class="container_16">
    <div class="grid_16">
      <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>Confirmation No. #vars.qProgram.Contract_Number# - Rebates</p>

      <!--- gather unique items --->
      <cfquery name="vars.qItems" dbtype="query">
        SELECT DISTINCT(bsa_FoodService_Items_Master_Id), Item, Description, inventory_um, volume_cs, volume_lb, abbreviation
          FROM vars.qFixedAllowances
          ORDER BY Item
      </cfquery>

      <table class="Design2" cellspacing="0" cellpadding="0">
        <thead>
          <tr>
            <th>SCC##</th>
            <th>#application.returned_customer_setting.Item_Label# Description</th>
            <cfif vars.customerProduct>
              <th>Customer #application.returned_customer_setting.Item_Label# Number</th>
            </cfif>
            <th class="center">Est Volume</th>
            <th class="center">UOM</th>
            <!--- display each rebate component in a separate column --->
            <cfoutput query="vars.qFixedAllowances" group="Program_Rebates_Component_Name">
              <th class="center">#vars.qFixedAllowances.Program_Rebates_Component_Name#</th>
            </cfoutput>
          </tr>
        </thead>

        <tbody>
          <!--- loop thru all unique items --->
          <cfloop query="vars.qItems">
            <tr>
              <td>#(vars.qItems.item eq '' ? 'Group' : vars.qItems.item)#</td>
              <td>#vars.qItems.Description#</td>
              <td class="right">
                <cfif trim(vars.qItems.Abbreviation) eq 'cs' or trim(vars.qItems.Abbreviation) eq '%'>
                  #numberFormat( vars.qItems.volume_cs, ",_" )#
                <cfelse>
                  #numberFormat( vars.qItems.volume_lb, ",_.__" )#
                </cfif>
              </td>  <!--- est vol --->
              <td class="center">#vars.qItems.Abbreviation#</td>

              <cfoutput query="vars.qFixedAllowances" group="Program_Rebates_Component_Name">
                <!--- get the rate for the component --->
                <cfquery name="vars.qRate" dbtype="query">
                  SELECT *
                    FROM vars.qFixedAllowances
                   WHERE bsa_FoodService_Items_Master_Id = '#vars.qItems.bsa_FoodService_Items_Master_Id#'
                     AND Program_Rebates_Component_Name = '#vars.qFixedAllowances.Program_Rebates_Component_Name#'
                </cfquery>

                <td class="dollar">
                  <cfif trim(vars.qItems.Abbreviation) eq '%'>
                    #numberformat(vars.qRate.Rate, "_.____")#%
                  <cfelse>
                    #numberformat(vars.qRate.Rate, "$_.__")#
                  </cfif>
                </td>
              </cfoutput>   <!--- query="vars.qFixedAllowances" group="Program_Rebates_Component_Name"> --->
            </tr>
          </cfloop>  <!--- query="vars.qItems"> --->
        </tbody>
      </table>
    </div>
  </div>
</cfif>

<!------------------>
<!---  LUMP SUM  --->
<!------------------>
<cfscript>
  LSDataManager       = createObject("component", "components.programs.lump_sum_components.DataManager").init() ;
  PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") ;
  templateManager     = CreateObject("component", "components.programs.template.TemplateManager").init() ;
  vars.qLumpSums      = vars.programCFC.getLumpSums( URL.Contract_Main_ID );
</cfscript>

<cfif vars.qLumpSums.recordCount gt 0>
  <div class="container_16">
    <div class="grid_16">
      <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>Confirmation No. #vars.qProgram.Contract_Number# - #Application.LumpsumLabel# Incentives</p>
    </div>  <!--- class="grid_16"> --->

    <cfloop query="vars.qLumpSums">
      <cfset vars.qLumpSumProducts = LSDataManager.getProgramLumpSumProducts(vars.qLumpSums.Program_Lump_Sum_ID, URL.Contract_Main_ID) />
      <cfif vars.qLumpSumProducts.recordCount>
        <div class="grid_16">
          <table class="Design2" cellspacing="0" cellpadding="0">
          <thead>
            <tr>
              <th>SCC##</th>
              <th>#application.returned_customer_setting.Item_Label# Description</th>
            </tr>
          </thead>
          <tbody>
            <cfloop query="vars.qLumpSumProducts">
              <tr>
                <td>#(vars.qLumpSumProducts.item eq '' ? 'Group' : vars.qLumpSumProducts.item)#</td>
                <td>#vars.qLumpSumProducts.Description#</td>
              </tr>
            </cfloop> <!--- query="vars.qLumpSumProducts.recordCount"> --->
          </tbody>
          </table>
        </div>  <!--- class="grid_16"> --->
      </cfif>  <!--- vars.qLumpSumProducts.recordCount> --->

      <div class="grid_8">
        <b>Component</b>: #vars.qLumpSums.Program_lump_sum_name#<br>
        <b>Payable To</b>: #templateManager.getPaymentPaidToTypeDesc(paidToID = vars.qLumpSums.Component_Paid_To, paidToDesc="")#<br>
        <b>#vars.qLumpSums.Program_Lump_Sum_Name#</b><br>
        <i>(#vars.qLumpSums.Lump_Sum_Description#)</i>
      </div>

      <div class="grid_8">
        <b>Claim Mechanism:</b> #vars.qLumpSums.Payment_Type_Name#<br>
        <b>Payment Cycle</b>: #PaymentCycleManager.getPaymentCycleDescription(PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 3, vars.qLumpSums.Program_Lumps_Sum_Ext_Id))#<br>
        <b>Amount</b>: #dollarFormat(vars.qLumpSums.Lump_Sum_Amount)#
      </div>
    </cfloop>  <!--- query="vars.qLumpSums"> --->
  </div>  <!--- class="container_16"> --->
</cfif>  <!--- vars.qLumpSums.recordCount gt 0> --->

<!---------------->
<!---  GROWTH  --->
<!---------------->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset getComponents      = vars.programCFC.getgrowthComponents(URL.Contract_Main_ID, vars.appSettings.getGrowthExpansion1())>

<cfif getComponents.recordCount>
  <div class="container_16">
    <div class="grid_16">
      <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>Confirmation No. #vars.qProgram.Contract_Number# - #Application.GrowthLabel# Rates</p>
    </div>  <!--- class="grid_16"> --->

    <cfloop query="getComponents">
      <cfset getComponentTiers    = vars.programCFC.getComponentTiers(URL.Contract_Main_ID, getComponents.Program_Growth_Component_ID)>
      <cfset displayGroupType     = genSettingsManager.getDisplayGroupType(vars.appSettings.getViewProgramProductGroupType()) />
      <cfset getComponentProducts = vars.programCFC..getComponentProducts(getComponents.Program_Growth_Component_ID, URL.Contract_Main_ID, displayGroupType)>

      <!------------------------------->
      <!---  GROWTH  |   PRODUCTS   --->
      <!------------------------------->
      <cfif getComponentProducts.recordCount>
        <div class="grid_16">
          <table class="Design2" cellspacing="0" cellpadding="0">
            <thead>
              <tr>
                <th>SCC##</th>
                <th>#application.returned_customer_setting.Item_Label# Description</th>
                <th>FPL</th>
                <th>Rates</th>
              </tr>
            </thead>
            <tbody>
              <cfloop query="getComponentProducts">
                <cfset getComponentProductTierData  = vars.programCFC.getComponentProductTierData(URL.Contract_Main_ID,getComponentProducts.Contract_Products_ID)>
                <tr>
                  <td>#(getComponentProducts.item eq '' ? 'Group' : getComponentProducts.item)#</td>
                  <td>#getComponentProducts.Description#</td>
                  <td>#getComponentProducts.DisplayGroupName#</td>
                  <td>
                    <cfloop query="getcomponentproducttierdata">
                      Tier #Tier_Number#:
                      <cfif len(trim(getComponentProductTierData.Rate)) EQ 0>
                        Pending...
                      <cfelse>
                        <cfif trim(getComponentProductTierData.Abbreviation) EQ "%">
                          #trim(numberformat(getComponentProductTierData.Rate, vars.programCFC.getRateFormatMask(0)))# #left(getComponentProductTierData.Abbreviation,2)#
                        <cfelse>
                          <cfif getComponentProductTierData.Unit_Of_Measure_ID EQ 1>
                            $#trim(numberformat(getComponentProductTierData.Rate, "_.__"))# per  #left(getComponentProductTierData.Abbreviation,2)#
                          <cfelse>
                            #trim(numberformat(getComponentProductTierData.Rate, vars.programCFC.getRateFormatMask()))# per  #left(getComponentProductTierData.Abbreviation,2)#
                          </cfif>   <!--- getComponentProductTierData.Unit_Of_Measure_ID EQ 1> --->
                        </cfif>   <!--- trim(getComponentProductTierData.Abbreviation) EQ "%"> --->
                      </cfif>   <!--- len(trim(getComponentProductTierData.Rate)) EQ 0 --->
                      <br>
                    </cfloop>  <!--- query="getcomponentproducttierdata" startrow="2"> --->
                  </td>
                </tr>
              </cfloop>  <!--- query="getComponentProducts"> --->
            </tbody>
          </table>
        </div>  <!--- class="grid_16"> --->
      </cfif>  <!--- getComponentProducts.recordCount> --->


      <!------------------------------->
      <!---  GROWTH  |   COMPONENT  --->
      <!------------------------------->
        <div class="grid_6">
          <b>Component</b>: #getComponents.Component_Name#<br>
          <b>Payable To</b>: #templateManager.getPaymentPaidToTypeDesc( paidToID=getComponents.Component_Paid_To, paidToDesc="" )#<br>
          <cfloop query="getComponentTiers">
             <b>Tier</b>: #getComponentTiers.Tier_Number#<br>
          </cfloop>  <!--- query="getComponentTiers"> --->
        </div>  <!--- class="grid_6"> --->

        <div class="grid_6">
          <b>Description:</b> #replace(getComponents.Component_Description,"&##44",",","ALL")#<br>
          <b>Payment Cycle</b>:
              <cfmodule template="\common_files\contracts\payment_cycle_selection.cfm"
                Template_ID               = "#vars.qProgram.ProgramType_ID#"
                Program_ID                = "#URL.Contract_Main_ID#"
                discount_Type_ID          = "4"
                Selected_Payment_Cycle_ID = "#PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 4, Growth_Component_Name_Id)#"
                Component_ID              = "#getComponents.Program_Growth_Component_ID#"
                Action                    = "display"
                ><br>
          <cfset tierFormat = "___,___,___,___,___,___,___," />
          <cfif getComponents.component_UOM EQ 3 AND appSettings.getGrowthDecimal4PercentTier() EQ 1>
            <cfset tierFormat = "___,___,___,___,___,___,___.___" />
          </cfif>
          <cfloop query="getComponentTiers">
            <b>Range</b>: #trim(numberformat(val(getComponentTiers.Range_Start), tierFormat))# <cfif trim(getComponentTiers.Range_End) EQ "*"> or More<cfelse>to #trim(numberformat(val(getComponentTiers.Range_End), tierFormat))#</cfif><br>
          </cfloop>  <!--- query="getComponentTiers"> --->
        </div>  <!--- class="grid_6"> --->

        <div class="grid_4">
          <br>
          <br>
          <cfloop query="getComponentTiers">
            <b>Amount</b>: #numberformat(getComponentTiers.Growth_Amount, '$,_')#<br>
          </cfloop>  <!--- query="getComponentTiers"> --->
        </div>  <!--- class="grid_4"> --->
        <br><br>
    </cfloop>  <!--- query="getComponents"> --->
  </div>  <!--- class="container_16"> --->
</cfif>  <!---  getComponents.recordCount> --->

<div class="container_16 confidentiality">
  <div class="grid_16">
    #application.returned_customer_setting.confidentiality_content#
  </div>
</div>
</cfsavecontent>   <!--- variable="variables.letterContent"> --->


<cfif request.language eq "french">
  #application.util.string.GoogleTranslate( application.util.string.compress( variables.letterContent ), 'fr' )#
<cfelse>
  #application.util.string.compress( variables.letterContent )#
</cfif>
</cffunction>

