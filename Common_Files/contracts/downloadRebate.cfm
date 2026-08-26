<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\contracts\downloadRebate.cfm
      Date:     2014 June
      Author:   Chris Nguyen
      Purpose:  Export rebate
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title><cfoutput>#Application.RebateLabel# - Download #application.returned_customer_setting.item_label#s</cfoutput></title>
  <style>
  .action { font-weight:bold; margin:0 3px 0 3px; }
  .right { text-align:right; }
  .even { background-color:#efe; }
  div.head span {
    display: inline-block;
  }
  div.head {
    margin:5px 0;
    font-size:1.15em;
    font-weight:bold;
    color:navy;
  }
  </style>
</head>

<body>
<cfparam name="URL.Business_Segment_ID" default="0">
<cfset businessSegmentsOn = 0>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager")>
<cfif businessSegManager.isEnabled() AND businessSegManager.isEnabledForProduct()>
	<cfset businessSegmentsOn = 1>
</cfif>
  <cfset exportProducts()>
</body>
</html>

<!------------------------------------------------------------------------------------------------------------------->
<cffunction name="selectComponent" output="true">
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<cfscript>
  variables.Contract_Main_ID = cryp.value;

  Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume");
  Program_Volume.Load_Basic_Information(variables.Contract_Main_ID, request.AccessStructure.Company_Main_ID);
  programDetails = CreateObject("component", "mvc.Models.Program.Volume.VolumeApplicator");
  qryProgramDetails = programDetails.getProgramDetails(variables.Contract_Main_ID, request.AccessStructure.User_ID);

  comp = createObject("component","components.programs.rebates.RebateComponent");

  programManager = CreateObject("component", "components.programs.ProgramManager");
  genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
  appSettings = genSettingsManager.get();
  GetSettings = programManager.getProgramTemplateInfo(variables.Contract_Main_ID);

  CSL_Contract_Main_ID = variables.Contract_Main_ID;
</cfscript>


<cfinclude template="commonqueries.cfm" />

<cfscript>
  arAllowList = ArrayNew(1);
  bTemplateLevelComponentFilter = 1;

  if ( appSettings.getOperatingGroupOn() ) {
    operatingGroupManager       = CreateObject("component", "components.Operating_Group.OperatingGroupManager").init();
    programLevel2Level        = operatingGroupManager.getProgramLevel2Level();
    // <!------ Get the operating group for this program ----->
    operatingGroupProgramLevel2   = operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=FORM.Contract_Main_ID);
    qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 2);
    componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID);
    arAllowList[ArrayLen(arAllowList) + 1] = componentsUnderOperatingGroupLevel2;
    bTemplateLevelComponentFilter = 0;
  }

  // <!------ Operating Group ----->
  if ( bTemplateLevelComponentFilter ) {
    qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(GetSettings.ProgramControl_Panel_Options_ID, 2, 1);
    lTemplateAllowList = ValueList(qComponents.Component_ID);
    arAllowList[ArrayLen(arAllowList) + 1] = lTemplateAllowList;
  }

  isUSDA = 0;
  // <!---Return only usda components --->
  if ( CSLGetContractInfo.Generic_Type IS "USDA NOI" ) {
    isUSDA = 1;
  }

  qGetActiveComps = comp.getActive(
      profileId=request.AccessStructure.Profiles_ID,
      isUSDA=isUSDA,
      Price_Protection_on=getSettings.Price_Protection_on,
      arAllowList=arAllowList);
</cfscript>

<div style="width:100%">
  <cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
      #application.returned_customer_setting.company_name#</div>   <!--- the starting div tag is in the include template --->
  <B><font size="+1" color="Navy">[#Program_Volume.Contract_Number#] - #Program_Volume.Contract_Title#</FONT></B>
</div>

<div class="head">
  <span style="width:30%;">#Application.RebateLabel# - Download #application.returned_customer_setting.item_label#s</span>
  <span style="width:69%;text-align:right;">#qryProgramDetails.Contract_Start_Date# - #qryProgramDetails.Contract_End_Date# (#qryProgramDetails.Contract_Span#)</span>
</div>
<HR COLOR="Navy">


<form name="exportRebate" method="post">
<input type="hidden" name="contract_main_id" value="#variables.contract_main_id#">
<input type="hidden" name="program_rebates_component_name">

<cfsavecontent variable="variables.componentsDropdown">
<select name="program_rebates_component_name_id">
  <option value="">Select #Application.RebateLabel# Component...</option>
  <cfloop query="qGetActiveComps">
    <option value="#qGetActiveComps.Program_Rebates_Component_Name_ID#">#qGetActiveComps.Program_Rebates_Component_Name#<cfif application.returned_customer_setting.external_id_on EQ 1><cfif Len(qGetActiveComps.External_ID) GT 0> (#qGetActiveComps.External_ID#)</cfif></cfif><cfif len(trim(qGetActiveComps.Allowance_Code_Number))> - (#qGetActiveComps.Allowance_Code_Number#)</cfif></option>
  </cfloop>
</select>
</cfsavecontent>

<div style="margin:10px 0;">
#application.util.string.compress( variables.componentsDropdown )#
&nbsp; &nbsp; <a href="##" id="export243">#application.util.string.actionLinkFormat(lcase("download #application.returned_customer_setting.item_label#s"))#</a>
</div>

</form>

<cfinclude template="/common_files/jQuery.cfm">
<script>
  $("##export243").click( function() {
    var selectedValue = $("select[name=program_rebates_component_name_id]").val();
    if ( selectedValue == '' ) {
      alert( "Please select a " + "#lCase(application.rebateLabel)# component to include in the download and try again.");
      return false;
    }

    $("input[name=program_rebates_component_name]").val( $("select[name=program_rebates_component_name_id] option:selected").text() );
    $('form[name=exportRebate]').submit();
  });
</script>
</cffunction>

<!------------------------------------------------------------------------------------------------------------------->
<cffunction name="exportProducts" output="true">
<!---   <cfdump abort="true" var="#url#"> --->
<cfscript>
  // url.coi = rebate component id
  // url.dti = discount type id
  // url.cmi = program contract main id ( integer )
  // url.ngp = non group product checkbox ( true | false )
  local.Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume");
  local.Program_Volume.Load_Basic_Information(url.cmi, request.AccessStructure.Company_Main_ID);

  local.compInfo = CreateObject("component","components.programcomponents.programcomponents");
  local.compDetails = local.compInfo.GetComponentDetails(url.coi, url.dti);

  local.templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
  local.qGetProgramTemplate = local.templateManager.getProgramTemplate(programId = url.cmi);

  local.ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init();
  local.qGetProductGroupAttributesGroupTemplateAll = local.ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1, FirstParentID=local.qGetProgramTemplate.First_Parent_ID);

  form.csvFileName = application.util.io.filterFilename(lcase(application.RebateLabel
                                                                   & "_" & application.returned_customer_setting.item_label
                                                                   & "_" & local.Program_Volume.Contract_Number
                                                                   & "_" & local.compDetails.component_name
                                                                   & "_" & getTickCount() )  // append an arbitrary unique substring to prevent opening same file problem in Excel
                                                       );

  form.contract_main_id = url.cmi;
  form.dtps_program_id  = url.cmi;
  form.Product_Status   = 'A';
  form.firstParentID    = local.qGetProgramTemplate.First_Parent_ID;
  form.qGetProductGroupAttributesGroupTemplate = local.qGetProductGroupAttributesGroupTemplateAll;
  form.businessSegmentsOn = businessSegmentsOn;
  form.Business_Segment_ID = URL.Business_Segment_ID;
  
  // generate a unique output file name
  local.outputFileName = application.Doc_Path & "\temp_files\" & "exportRebate" & getTickCount() & ".csv";
  lOCAL.NewLine = (Chr( 13 ) & Chr( 10 ));

  local.productRateManager = CreateObject("component", "mvc.Models.Program.Component.ProductRateManager");
  local.rebateRates = local.productRateManager.getRebateProductRateData(programId=url.cmi, includeGroups=1, componentNameID=url.coi);

  local.csvNonGroup = '';
  local.csvGroup = '';
  // writedump(var=local.rebateRates, abort=true);   // TODO: remove this

  local.jRates = createObject( "java", "java.util.ArrayList" ).init();   // java array
  local.cfRates = [];   // cf array
</cfscript>

<cfloop query="local.rebateRates">
  <cfscript>
    local.jRates.add( local.rebateRates.ItemGUID );   // add item GUID into java array for searching with indexof() function
    local.uom = '';
    if (local.rebateRates.UOMID eq '1')
      local.uom = 'CS';
    else if (local.rebateRates.UOMID eq '2')
      local.uom = 'LBS';
    arrayAppend(local.cfRates, { rate=local.rebateRates.rate, uom=local.uom });
  </cfscript>
</cfloop>

<!--- gather group products --->
<cfif ( url.gp neq "" and url.gp neq 'null')>
  <!--- 58043 - we no longer include group products --->
  <cfset local.csvGroup = ''>
</cfif>

<!--- gather non group products --->
<cfif ( url.ngp eq "true" )>
  <cfscript>
    local.productManager = CreateObject("component", "components.products.ProductManager").init();
    local.nonGroupProducts = local.productManager.search(search = form, useCache = 1);
  </cfscript>

  <!--- <cfsavecontent variable="local.csvNonGroup">
    <cfloop query="local.nonGroupProducts">
      <cfquery dbtype="query" name="local.rateForProduct">
        SELECT *
          FROM local.rebateRates
         WHERE ItemGUID = '#local.nonGroupProducts.bsa_FoodService_Items_Master_Id#'
      </cfquery>
      #local.nonGroupProducts.Item#,"#local.nonGroupProducts.Description#",#(local.rateForProduct.recordCount gt 0 ? local.rateForProduct.Rate : '')#,#(local.rateForProduct.recordCount gt 0 ? local.rateForProduct.UOMID : '')#,"#local.nonGroupProducts.Bsa_FoodService_Items_Master_Id#"#local.newLine#
    </cfloop>
  </cfsavecontent> --->

  <cfsavecontent variable="local.csvNonGroup">
    <cfloop query="local.nonGroupProducts"><cfset local.aPosition = local.jRates.IndexOf( local.nonGroupProducts.bsa_FoodService_Items_Master_Id ) + 1>
      #local.nonGroupProducts.Item#,#replace(replace(local.nonGroupProducts.Description,",","","all"),"#chr(34)#","","all")#,#(local.aPosition gt 0 ? local.cfRates[local.aPosition].Rate : '')#,#(local.aPosition gt 0 ? local.cfRates[local.aPosition].UOM : '')#,#local.nonGroupProducts.Bsa_FoodService_Items_Master_Id##local.newLine#
    </cfloop>
  </cfsavecontent>

</cfif>

<!--- Write the spreadsheet to a file, replacing any existing file.  --->
<cffile action="write" file="#local.outputFileName#" output="Item,Description (Group Number),Rate,UOM,*** internal-row-id ***#local.newLine##local.csvGroup##local.csvNonGroup#" nameconflict="overwrite" />

<cfheader name="Content-Disposition" value="attachment;filename=#form.csvFileName#.csv"  />
<cfcontent type="application/csv" file="#local.outputFileName#"  />
</cffunction>
