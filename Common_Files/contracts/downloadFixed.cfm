<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\contracts\downloadFixed.cfm
      Date:     2014 Sep
      Author:   Chris Nguyen
      Purpose:  Export products in a fixed program
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <title><cfoutput>Download #application.returned_customer_setting.item_label#s</cfoutput></title>
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

  // local.templateManager = CreateObject("component", "components.programs.template.TemplateManager").init();
  // local.qGetProgramTemplate = local.templateManager.getProgramTemplate(programId = url.cmi);




  local.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');
  local.qFixedPricedItems = local.programCFC.getFixedPriceOnEmail( URL.cmi );

  form.csvFileName = application.util.io.filterFilename(lcase("fixed"
                                                               & "_" & application.returned_customer_setting.item_label
                                                               & "_" & local.Program_Volume.Contract_Number
                                                               & "_" & local.compDetails.component_name
                                                               & "_" & GetTickCount()));

  form.contract_main_id = url.cmi;
  form.dtps_program_id  = url.cmi;
  form.Product_Status   = 'A';
  //form.firstParentID    = local.qGetProgramTemplate.First_Parent_ID;
  form.businessSegmentsOn = businessSegmentsOn;
  form.Business_Segment_ID = URL.Business_Segment_ID;

  // generate a unique output file name
  local.outputFileName = application.Doc_Path & "\temp_files\" & "exportFixed" & getTickCount() & ".csv";
  lOCAL.NewLine = (Chr( 13 ) & Chr( 10 ));

  local.csvNonGroup = '';
  local.csvGroup = '';
  // writedump(var=local.qFixedPricedItems, abort=true);   // TODO: remove this

  local.jRates = createObject( "java", "java.util.ArrayList" ).init();   // java array
  local.cfRates = [];   // cf array
</cfscript>

<cfloop query="local.qFixedPricedItems">
  <cfscript>
    local.jRates.add( local.qFixedPricedItems.BSA_Foodservice_Items_Master_ID );   // add item GUID into java array for searching with indexof() function
    local.uom = '';
    if (trim(local.qFixedPricedItems.abbreviation) eq 'cs')
      local.uom = 'CS';
    else
      local.uom = 'LBS';
    arrayAppend(local.cfRates, { rate=local.qFixedPricedItems.Fixed_Price_Value, uom=local.uom });
  </cfscript>
</cfloop>

<!--- gather non group products --->
<cfif ( url.ngp eq "true" )>
  <cfscript>
    local.productManager = CreateObject("component", "components.products.ProductManager").init();
    local.nonGroupProducts = local.productManager.search(search = form, useCache = 1);
  </cfscript>

  <cfsavecontent variable="local.csvNonGroup">
    <cfloop query="local.nonGroupProducts"><cfset local.aPosition = local.jRates.IndexOf( local.nonGroupProducts.bsa_FoodService_Items_Master_Id ) + 1>
      #local.nonGroupProducts.Item#,#replace(replace(local.nonGroupProducts.Description,",","","all"),"#chr(34)#","","all")#,#(local.aPosition gt 0 ? local.cfRates[local.aPosition].Rate : '')#,#(local.aPosition gt 0 ? local.cfRates[local.aPosition].UOM : '')#,#local.nonGroupProducts.Bsa_FoodService_Items_Master_Id##local.newLine#
    </cfloop>
  </cfsavecontent>

</cfif>

<!--- Write the spreadsheet to a file, replacing any existing file.  --->
<cffile action="write" file="#local.outputFileName#" output="Item,Description,Rate,UOM,*** internal-row-id ***#local.newLine##local.csvNonGroup#" nameconflict="overwrite" />

<cfheader name="Content-Disposition" value="attachment;filename=#form.csvFileName#.csv"  />
<cfcontent type="application/csv" file="#local.outputFileName#"  />
</cffunction>
