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
<cfset URL.Email = 1>

<cfscript>
  vars = StructNew();
  vars.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
  vars.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');

  vars.qOperators = vars.programCFC.getOperators( URL.Contract_Main_ID );
  vars.qFixedPricedItems = vars.programCFC.getFixedPriceOnEmail( URL.Contract_Main_ID );
  vars.qRebateItems = vars.programCFC.getRebateOnEmail( URL.Contract_Main_ID );
</cfscript>

<cfinvoke component="components.programs.business_segment.BusinessSegmentManager" 
            method="isEnabled" 
            returnVariable="busSegMgr.isEnabled">
</cfinvoke>
<cfset vars.qPrgDistributors = vars.programCFC.getDistributors( URL.Contract_Main_ID, busSegMgr.isEnabled, false )>

<cfoutput>
  <cfif not StructKeyExists(URL, "All_Distributors")>
    <cfquery name="vars.qDistributors" dbtype="query">
      SELECT *
        FROM vars.qPrgDistributors
       WHERE BSA_Foodservice_Customers_ID IN (<cfqueryparam value='#form.operLtrDistributors#' list="true">)
    </cfquery>
  </cfif>
</cfoutput>

<!--- 
<cfdump var="#vars.qDistributors#" label="qDistributors"/>
<cfdump var="#vars.qOperators#" label="qOperators"/>
<cfdump var="#vars.qFixedPricedItems#" label="qFixedPricedItems"/>
<cfdump var="#vars.qRebateItems#" label="qRebateItems"/>
<cfabort /> --->

<!--- Queries for the page --->
<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
  <cfquery name="vars.qProgram" Datasource="#application.datasource#">
    SELECT   Contract_Main_ID
           , Contract_Title
           , Contract_Number
           , Revision_Version = Right('000' + cast(Revision_Version as varchar(10)),3) 
           , Contract_Created_Date
           , Effective_Start_Date
           , Effective_End_Date
           , DateDiff(d, Effective_Start_Date, Effective_End_Date)+1 as Effective_Span
           , RSP_Name = _Users.Name_First + ' ' + _Users.Name_Last
           , RSP_Phone = _Users.Work_Phone_1 + ' ' + _Users.Work_Phone_2 + ' ' + _Users.Work_Phone_3
           , RSP_Email = _Users.User_Email
           , Creator = _Users2.Name_First + ' ' + _Users2.Name_Last
           , ProgramType_ID
      FROM Contract_Main
      INNER JOIN _Users ON Contract_Main.Responsible_user_ID = _Users.User_ID
      INNER JOIN _Users _Users2 ON Contract_Main.Creator_ID = _Users2.User_ID
     WHERE Contract_Main.Contract_Main_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfparam name="request.language" default="">

  <cfquery name="vars.qTemplateLetterSettings" datasource="#application.datasource#">
    SELECT  CM.ProgramType_ID,
            PCPO.Label_Set_Default,PCPO.Operator_Letters_Required,PCPO.Distributor_Letters_Required,PCPO.Distributor_Fixed_Pricing,PCPO.Operator_Fixed_Pricing,
            PCPO.Distributor_Rebate,PCPO.Operator_Rebate,PCPO.Distributor_Lumpsum,PCPO.Operator_Lumpsum,PCPO.Distributor_Paysto_Opr,PCPO.Distributor_Paysto_Dis,
            PCPO.Operator_Paysto_Opr,PCPO.Operator_Paysto_Dis,PCPO.Operator_Bid_Request,PCPO.Distributor_Bid_Request,PCPO.Pre_Defined_Page_Break,
            PCPO.Include_Freight_Summary,PCPO.Freight_UOM,PCPO.Distributor_UOM,PCPO.Operator_UOM,PCPO.Distributor_Discount_Type,PCPO.Operator_Discount_Type,
            PCPO.Distributor_Component_Name,PCPO.Operator_Component_Name,PCPO.Distributor_Claim_Mechanism,PCPO.Operator_Claim_Mechanism,PCPO.Distributor_Payable_To,PCPO.Operator_Payable_To,
            PCPO.Distributor_Pricing_Type,PCPO.Operator_Pricing_Type,PCPO.Distributor_Payment_Frequency,PCPO.Operator_Payment_Frequency,PCPO.Distributor_GTIN,PCPO.Operator_GTIN,
            PCPO.Distributor_Product_Attribute_1,PCPO.Operator_Product_Attribute_1,PCPO.Email_Letters_On_Approval,PCPO.Generate_Letters_On_Approval,
            PCPO.Distributor_Price_Brackets,PCPO.Operator_Price_Brackets,PCPO.Distributor_Open_Date,PCPO.Operator_Open_Date,PCPO.Distributor_Date_Needed,PCPO.Operator_Date_Needed,
            PCPO.Distributor_Expected_Date,PCPO.Operator_Expected_Date,PCPO.Distributor_Est_Value_Volume,PCPO.Operator_Est_Value_Volume,PCPO.Distributor_Dist_Product_Codes,
            PCPO.Distributor_Customer_Acceptance_Block,PCPO.Operator_Customer_Acceptance_Block,PCPO.Distributor_Line,PCPO.Operator_Line,PCPO.Distributor_Notes,PCPO.Operator_Notes,
            PCPO.Letters_Accepted_By
    FROM    Program_Control_Panel_Options PCPO
    INNER JOIN Contract_Main CM
      ON CM.Contract_Main_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
    WHERE PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
  </cfquery>

  <cfquery name="vars.qDiscountTypes" datasource="#application.datasource#">
    SELECT DISTINCT( dt.Discount_Type_desc )
      FROM Contract_Products cp
           INNER JOIN Discount_Type dt 
           ON cp.Product_Type_Id = dt.Discount_Type_Id
           AND dt.Deleted = 0
     WHERE cp.Contract_Main_Id = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
           AND cp.Product_Type_Id <> 3 --- not a lump sum
           AND cp.Deleted = 0
     UNION
    SELECT TOP 1 Discount_Type_desc
      FROM Discount_Type dt
           INNER JOIN Program_Lump_Sums ls 
           ON ls.Program_Id = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
           AND ls.Deleted = 0
     WHERE dt.Discount_Type_Id = 3 --- lump sum
  </cfquery>

  <cfquery name="vars.qClauses" datasource="#application.datasource#">
    SELECT l.Clause_Library_Body, l.Clause_Library_Body_French
      FROM Clause_Program p
           INNER JOIN dbo.Clause_Library l ON l.Clause_Library_ID = p.Clause_Library_ID AND l.Deleted = 0
     WHERE p.Program_Id = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
           AND p.Deleted = 0
  </cfquery>

</cfoutput>
<!--------------------------------------------------------------------------------------------------------------------->


<!-------------------------------------------------- Google Translate -------------------------------------------------->
<link rel="stylesheet" href="/common_files/960_16_col.css" />   <!--- see knowledgebase for more info on this framework --->
<cfif URL.Email neq "1">
  <style type="text/css">
    .mb74 { margin-bottom: 7px; }
  </style>
  <cfinclude template="/common_files/jQuery.cfm">

  <div class="container_16 mb74">
    <div class="grid_2">
      <div id="google_translate_element">
        <cfif request.AccessStructure.User_Language eq "French" AND vars.qTemplateLetterSettings.Label_Set_Default eq "French">
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
	</div>

  <script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
  <script>
    $(function(){
      // if price confirmation is on the screen language is english otherwise language is french
      var lang = ( $.FindNoCase('Program ID', $("#pc13").text()) ? "english" : "french" );        
      
      // detect english language & hide French clauses
      if ( $("#pc13:contains(price confirmation)") ) {
        $('.english').show();
        $('.french').hide();
      }
    });
  </script>
</cfif>
<!--------------------------------------------------------------------------------------------------------------------->


<!--------------------------------------------------------------------------------------------------------------------->
<!---------------------------------------------------- QuoteLetter ---------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------------------->

<!--- Call the functions to generate the different content sections of letter --->
<!--- Get products & rate section; This is common for both the operators & distributor letters --->
<cfset variables.letterProductRateSection =  "" />  <!--- temp variable for letter body --->

<!----------------------->
<!--- operator letter --->
<!----------------------->
<cfif vars.qOperators.recordCount AND vars.qTemplateLetterSettings.Operator_Letters_Required >

  <!--- operator letter body --->
  <cfset variables.letterProductRateSection =  fnletterProducts(
      letterType  = 1,
      discountTypeDisplay = vars.qTemplateLetterSettings.Operator_Discount_Type,
      componentNameDisplay = vars.qTemplateLetterSettings.Operator_Component_Name,
      operPaysToDisplay = vars.qTemplateLetterSettings.Operator_Paysto_Opr,
      distPaysToDisplay = vars.qTemplateLetterSettings.Operator_Paysto_Dis,
      payableToDisplay = vars.qTemplateLetterSettings.Operator_Payable_To
    ) /> 

  <cfset variables.operatorStruct = structNew() >
  <cfset variables.distributorStruct = structNew() >
  <cfset variables.operatorStruct =  { Name=vars.qOperators.Operator_Name, Address=vars.qOperators.Operator_Address, City=vars.qOperators.Operator_City, State=vars.qOperators.Operator_State, Zip=vars.qOperators.Operator_Zip }>

  <!--- add header section --->
  <cfset variables.letterHeaderSection =  fnLetterHeader(letterType="1", operatorStruct=variables.operatorStruct, distributorStruct=variables.distributorStruct) />
  <!--- add message section --->
  <cfset variables.letterMessageSection =  fnLetterMessage(letterType="1", operatorName="#vars.qOperators.Operator_Name#", distributorName="") />
  <!--- add distributor sections --->
  <cfset variables.letterDistributorsSection ="" >
  <cfif len(form.operLtrDistributors)>  
    <cfset variables.letterDistributorsSection =  fnLetterDistributors() />
  </cfif>

  <cfset variables.letterContentGenerated = variables.letterHeaderSection & variables.letterMessageSection & variables.letterDistributorsSection & variables.letterProductRateSection >

  <cfif request.language eq "french">
    <cfset variables.letterContentFinal =  application.util.string.GoogleTranslate( application.util.string.compress( variables.letterContentGenerated ), 'fr' ) />
  <cfelse>
    <cfset variables.letterContentFinal = application.util.string.compress( variables.letterContentGenerated ) />
  </cfif>

  <cfset fnSaveLetter(1, vars.qOperators.Operator_Name, vars.qOperators.BSA_Operator_ID) />

</cfif>



<!-------------------------->
<!--- distributor letter --->
<!-------------------------->
  
<cfif len(form.distLtrDistributors)>

  <cfquery name="vars.qLtrDistributors" dbtype="query">
    SELECT *
      FROM vars.qPrgDistributors
     WHERE BSA_Foodservice_Customers_ID IN (<cfqueryparam value='#form.distLtrDistributors#' list="true">)
  </cfquery>

  <!--- distributor letter body --->  
  <cfset variables.letterProductRateSection =  fnletterProducts(
      letterType  = 1,
      discountTypeDisplay = vars.qTemplateLetterSettings.Distributor_Discount_Type,
      componentNameDisplay = vars.qTemplateLetterSettings.Operator_Component_Name,
      operPaysToDisplay = vars.qTemplateLetterSettings.Distributor_Paysto_Opr,
      distPaysToDisplay = vars.qTemplateLetterSettings.Distributor_Paysto_Dis,
      payableToDisplay = vars.qTemplateLetterSettings.Distributor_Payable_To
    ) /> 

  <cfset variables.operatorStruct = structNew() >
  <cfset variables.operatorStruct =  { Name=vars.qOperators.Operator_Name, Address=vars.qOperators.Operator_Address, City=vars.qOperators.Operator_City, State=vars.qOperators.Operator_State, Zip=vars.qOperators.Operator_Zip }>

  <cfoutput query="vars.qLtrDistributors">
    <cfset variables.distributorStruct = structNew() >
    <cfset variables.distributorStruct =  { Name=vars.qLtrDistributors.Name, Address=vars.qLtrDistributors.Address_1, City=vars.qLtrDistributors.City, State=vars.qLtrDistributors.State, Zip=vars.qLtrDistributors.ZipCode }>

    <!--- add header section --->
    <cfset variables.letterHeaderSection =  fnLetterHeader(letterType="2", operatorStruct=variables.operatorStruct, distributorStruct=variables.distributorStruct) />
    <!--- add message section --->
    <cfset variables.letterMessageSection =  fnLetterMessage(letterType="2", operatorName="#vars.qOperators.Operator_Name#", distributorName="#vars.qLtrDistributors.Name#") />
    <!--- add distributor sections --->
    <cfset variables.letterDistributorsSection =  ""/>

    <cfset variables.letterContentGenerated = variables.letterHeaderSection & variables.letterMessageSection & variables.letterDistributorsSection & variables.letterProductRateSection >

    <cfif request.language eq "french">
      <cfset variables.letterContentFinal =  application.util.string.GoogleTranslate( application.util.string.compress( variables.letterContentGenerated ), 'fr' ) />
    <cfelse>
      <cfset variables.letterContentFinal = application.util.string.compress( variables.letterContentGenerated ) />
    </cfif>

  <cfset fnSaveLetter(2, vars.qLtrDistributors.Name, vars.qLtrDistributors.Shr_Ship_To) />
  </cfoutput>
</cfif>

<cfreturn />

<!--------------------------------------------------------------------------------------------------------------------->



<!----------------------->
<!--- create and save --->
<!----------------------->
<cffunction name="fnSaveLetter" returntype="void" output="true">
  <cfargument name="letterType" type="numeric">   <!--- letterType 1=operator; 2=distributor --->
  <cfargument name="customerName" type="string">
  <cfargument name="customerNumber" type="string">

  <!------------------------------------ save the letters for operator & distrubutor ------------------------------------>  
  <!--- file name format:  Program #  Program Title  Operator Name  Date generated --->
  <cfset vars.fileName = "#vars.qProgram.Contract_Number#-#vars.qProgram.Revision_Version# #vars.qProgram.Contract_Title# #arguments.customerName# #customerNumber# #dateformat(now(), "mm_dd_yyyy")#"> 
  <cfset vars.fileName  = ReplaceNoCase(vars.fileName, '/', '_', 'all')>
  <cfset vars.fileName  = ReplaceNoCase(vars.fileName, ' ', '_', 'all')>

  <!--- file content with css/grid formatting --->
  <cfsavecontent variable="variables.letterFileContent">
    <html>
    <head>
    <title>#vars.fileName#</title>
    <style>
      <cfinclude template="/common_files/main_style.css">
      <cfinclude template="/common_files/960_16_col.css">
      p{font-size:8pt;line-height:120%}
      hr{padding:3px 0;border:none;border-top:1px solid ##333}
      .dollar{text-align:right!important}
      .center{text-align:center!important}
      .right{text-align:right!important}
      .opa_group{color:##000;margin:35px 0 5px 0;font-weight:bold}
      .small{font-size:10px;font-weight:normal;position:relative;top:-5px}
      table.Design2{border-top:1px solid ##666;border-left:1px solid ##666;margin-bottom:10px;width:99%}
      table.Design2 td{border-right:1px solid ##666;border-bottom:1px solid ##666;padding:.4em .4em;vertical-align:top}
      table.Design2 th{border-right:1px solid ##666;border-bottom:1px solid ##666;border-collapse:collapse;font-weight:400;padding:.4em .4em}
      table.Design2 th.Corner{text-align:left}
      table.Design2 thead th{background-color:##E5E5E5;color:##000;font-weight:bold;font-size:10px;text-align:left}
      div.confidentiality{margin-top:20px}
    </style>
    </head>
    <body>
    #variables.letterContentFinal#
    </body>
    </html>
  </cfsavecontent>

  <!--- write the html letter and save a pdf version of the letter --->
  <cfset vars.tempFilePath = "">
  <cfif IsDefined("request.ApplicationPath")>
    <cfset vars.tempFilePath = request.ApplicationPath>
  <cfelseif IsDefined("ApplicationPath")>
    <cfset vars.tempFilePath = ApplicationPath>
  </cfif>
  <cfif IsDefined("Application.Doc_Path")>
    <cfset vars.tempFilePath = Application.Doc_Path>
  </cfif>

  <!--- folder path --->
  <cfset vars.folderPath = "#vars.tempFilePath#\data_files\created\contracts\letters\output\" >
  <cfif arguments.letterType eq 1>
  <cfset vars.folderPath =  vars.folderPath & "operators" >
  <cfelse>
    <cfset vars.folderPath =  vars.folderPath & "distributors">
  </cfif> 
  <cfset vars.folderPath =  vars.folderPath & "\#vars.qProgram.Contract_Main_ID#" />
  <cfif NOT DirectoryExists(vars.folderPath) >
    <cfdirectory action = "create" directory="#vars.folderPath#" />
  </cfif>

  <!--- html file path --->
  <cfset vars.htmlfilePath = "#vars.folderPath #\#vars.fileName#.htm" >
  <cfset vars.htmlfilePath  = ReplaceNoCase(vars.htmlfilePath, '/', '\', 'all')>
  <!--- <cffile action="write" file="#vars.htmlfilePath#" output="#variables.letterFileContent#"> --->

  <!--- convert it into pdf format --->
  <cfset pdf_footer = "#vars.qProgram.Contract_Number# #vars.qProgram.Revision_Version# - " />
  <cfdocument format="PDF" name="vars.pdf">
    <cfif len(trim(pdf_footer))>
      <!--- Use a footer with current page of totalpages format. --->
      <cfdocumentitem type="footer">
        <div style="text-align:center;font:arial;font-size:10px;">
          #pdf_footer# Page #cfdocument.currentPageNumber# of #cfdocument.TotalPageCount#
        </div>
      </cfdocumentitem>
    </cfif>
      #variables.letterFileContent#
  </cfdocument>

  <!--write pdf file-->
  <cfset vars.pdfFilePath = ReplaceNoCase(vars.htmlfilePath, '.htm', '.pdf')>
  <cfpdf action="write" destination="#vars.pdfFilePath#" source="vars.pdf" overwrite="yes">
  <!--------------------------------------------------------------------------------------------------------------------->

  
  <!------------------------------------ make entries in the db for the letter view page -------------------------------->  
  <!--- check if there is a letter with the same name created by the same user on the same date. --->
  <cfquery name="vars.qCheckLetterExists"  datasource="#application.datasource#">
    SELECT Program_Letters_ID
    FROM Program_Letters
    WHERE Program_ID = <cfqueryparam value="#vars.qProgram.Contract_Main_ID#" cfsqltype="cf_sql_integer">
      AND Letter_Type = <cfqueryparam value="#arguments.letterType#" cfsqltype="cf_sql_numeric">
      AND Letter_Name = <cfqueryparam value="#vars.fileName#" cfsqltype="cf_sql_varchar">
      <cfif arguments.letterType eq 1>
      AND Operator_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">
      <cfelse>
      AND Distributor_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">
      </cfif>
      AND Created_By = <cfqueryparam value="#request.accessstructure.user_ID#" cfsqltype="cf_sql_varchar">
      AND Deleted = 0
  </cfquery>

  <cfif vars.qCheckLetterExists.recordCount>
    <cfquery name="vars.qUpdateLetters" datasource="#application.datasource#">
      UPDATE Program_Letters
      SET Letter_Type = <cfqueryparam value="#arguments.letterType#" cfsqltype="cf_sql_numeric">,
          Letter_Name = <cfqueryparam value="#vars.fileName#" cfsqltype="cf_sql_varchar">, 
          Letter_Path = <cfqueryparam value="#vars.pdfFilePath#" cfsqltype="cf_sql_varchar">, 
          <cfif arguments.letterType eq 1>
          Operator_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">, 
          <cfelse>
          Distributor_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">, 
          </cfif>
          Program_ID = <cfqueryparam value="#vars.qProgram.Contract_Main_ID#" cfsqltype="cf_sql_integer">, 
          Created_By = <cfqueryparam value="#request.accessstructure.user_ID#" cfsqltype="cf_sql_varchar">
      WHERE Program_Letters_ID = <cfqueryparam value="#vars.qCheckLetterExists.Program_Letters_ID#" cfsqltype="cf_sql_integer">
        AND Deleted = 0
    </cfquery>
  <cfelse>  
    <cfquery name="vars.qInsertLetters" datasource="#application.datasource#">
      INSERT INTO Program_Letters (Program_ID,Letter_Type,Letter_Name,Letter_Path,Operator_Name,Distributor_Name,Created_By)
      VALUES ('#vars.qProgram.Contract_Main_ID#',
              #arguments.letterType#,
              '#vars.fileName#',
              '#vars.pdfFilePath#',
              <cfif arguments.letterType eq 1>
              '#arguments.customerName#','',
              <cfelse>
              '','#arguments.customerName#',
              </cfif>
              '#request.accessstructure.user_ID#')
    </cfquery>
  </cfif>
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->


<!---------------------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------- Letter Content --------------------------------------------------->
<!---------------------------------------------------------------------------------------------------------------------->

<!---------------------->
<!---     HEADER     --->
<!---------------------->
<cffunction name="fnLetterHeader" returntype="string" output="true">
  <cfargument name="letterType" type="numeric"> <!--- letterType 1=operator; 2=distributor --->
  <cfargument name="operatorStruct" type="struct" >
  <cfargument name="distributorStruct" type="struct" >

  <cfsavecontent variable="variables.sLetterHeader">
      <!---need to specify the full URL so image would be shown up on email--->
      <div class="container_16 mb74">
        <div class="grid_16 mb74" style="margin-bottom:10px;">
          <img src="http://#cgi.server_name#/#vars.appsettings.getletterscompanylogopath()#" title="Company Logo">
        </div>
      </div>
      <div class="container_16 mb74">
        <div class="grid_2"><b>Date:<br><br>Program Name:</b></div>
        <div class="grid_7">#DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br><br>#vars.qProgram.Contract_Title#</div>
        <div class="grid_7" id="pc13"><b>#application.returned_customer_setting.program_number_label# :</b> #vars.qProgram.Contract_Number#</div>
      </div>

      <cfif vars.qOperators.recordCount>
        <div class="container_16 mb74">
          <div class="grid_2"><b>#application.returned_customer_setting.operator_label_singular#:</b></div>
          <div class="grid_7">
            #arguments.operatorStruct.Name#<br>
            #arguments.operatorStruct.Address#<br>
            #trim(arguments.operatorStruct.City)# #trim(arguments.operatorStruct.State)# #arguments.operatorStruct.Zip#
          </div>
          <div class="grid_7">
            <cfif arguments.letterType eq 2>  
            <b>#application.returned_customer_setting.distributor_label_singular#:</b><br>
            #arguments.distributorStruct.Name#<br>
            #arguments.distributorStruct.Address#<br>
            #trim(arguments.distributorStruct.City)# #trim(arguments.distributorStruct.State)# #arguments.distributorStruct.Zip#
            </cfif>
            &nbsp;
          </div>
        </div>
      </cfif>

      <div class="container_16 mb74">
        <div class="grid_16"><hr></div>
        <div class="grid_2"><b>Effective Dates:<br>Print Date:</b></div>
        <div class="grid_7">#DateFormat(vars.qProgram.Effective_Start_Date,'long')# through #DateFormat(vars.qProgram.Effective_End_Date,'long')#<br>#DateFormat(now(),'long')#</div>
        <div class="grid_7"><b>Price Type:</b> #valueList(vars.qDiscountTypes.Discount_Type_desc, ", ")#</div>
        <div class="grid_16"><hr></div>
      </div>

  </cfsavecontent> <!--- variables.sLetterHeader --->

  <cfreturn variables.sLetterHeader />
</cffunction>


<!--------------------------->
<!---   MESSAGE SECTION   --->
<!--------------------------->
<cffunction name="fnLetterMessage" returntype="string" output="true">
  <cfargument name="letterType" type="numeric"> <!--- letterType 1=operator; 2=distributor --->
  <cfargument name="operatorName" type="string"  >
  <cfargument name="distributorName" type="string" >

  <!--- variable for message section  --->
  <cfsavecontent variable="variables.sLetterMessage">
    <cfoutput>
      <div class="container_16">
        <div class="grid_16">
          <p><cfif arguments.letterType eq 1>#trim(arguments.operatorName)#<cfelse>#trim(arguments.distributorName)#</cfif>,</p>

          <cfif arguments.letterType eq 1>
          <p>We are pleased to confirm pricing information for orders requested for delivery between #DateFormat(vars.qProgram.Effective_Start_Date,'long')# and #DateFormat(vars.qProgram.Effective_End_Date,'long')# for the above named operator. During this time period, #trim(arguments.operatorName)# orders through your authorized distributor will be priced by Kraft to your authorized distributor at a maximum of the #lcase(valueList(vars.qDiscountTypes.Discount_Type_desc,", "))# type for the product(s) found in the pricing table (showing prices, allowance and contract volume).</p>
          <cfelse>
          <p>We are pleased to confirm pricing information for orders requested for delivery between #DateFormat(vars.qProgram.Effective_Start_Date,'long')# and #DateFormat(vars.qProgram.Effective_End_Date,'long')#  for the above named operator only.   During this time period, product sold to #trim(arguments.distributorName)# for delivery to #trim(arguments.operatorName)# will receive the #lcase(valueList(vars.qDiscountTypes.Discount_Type_desc,", "))# type price to #trim(arguments.distributorName)# the product(s) found in the pricing table (showing prices and rates).</p>
          </cfif>

          <p>The prices do not include any distributor mark-up or distributor surcharges.  Distributor mark-ups and other distributor charges are to be negotiated solely between the distributor and operator.</p>

          <p>This letter deals with pricing, compliance and confidentiality matters only and is not to be construed as a guarantee of product availability or supply.</p>

          <p>Sincerely,</p>

          <br><br>
          <p>#vars.qProgram.RSP_Name#</p>
          <p>Kraft Representative</p>
        </div>
      </div>
    </cfoutput>
  </cfsavecontent>

  <cfreturn variables.sLetterMessage />
</cffunction>


<!--------------------------------------------->
<!---  DISTRIBUTORS LIST IN OPERATOR LETTER --->
<!--------------------------------------------->
<cffunction name="fnLetterDistributors" returntype="string" output="true">
  <!--- variable for products section  --->
  <cfsavecontent variable="variables.sLetterDistributors">
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
                <td>#vars.qDistributors.Shr_Ship_To#</td>
                <td>#vars.qDistributors.Name#</td>
                <td>#trim(vars.qDistributors.Address_1)# #trim(vars.qDistributors.City)# #vars.qDistributors.State# #vars.qDistributors.ZipCode#</td>
              </tr>
            </cfoutput>
          </tbody>
        </table>
      </div>
    </div>
  </cfsavecontent> <!--- variables.sLetterDistributors --->

  <cfreturn variables.sLetterDistributors />
</cffunction>



<!--------------------------------->
<!---  PRODUCTS & RATE PRODUCTS --->
<!--------------------------------->
<cffunction name="fnletterProducts" returntype="string" output="true">

  <cfargument name="letterType" type="numeric"> 	<!--- letterType 1=operator; 2=distributor --->
  <cfargument name="discountTypeDisplay" type="numeric">
  <cfargument name="componentNameDisplay" type="numeric">
  <cfargument name="operPaysToDisplay" type="numeric">
  <cfargument name="distPaysToDisplay" type="numeric">
  <cfargument name="payableToDisplay" type="numeric">
  
  <cfset vars.customerProduct = false>

  <cfsavecontent variable="variables.letterProducts">

    <!---------------------------->
    <!---  FIXED RATE PRODUCTS --->
    <!---------------------------->
    <cfif vars.qFixedPricedItems.recordCount gt 0>
      <!--- display the components only if the components paysto is set to display in template letter settings --->
      <cfif (distPaysToDisplay AND findNoCase('1', "#valuelist(vars.qFixedPricedItems.Fixed_Component_Paid_to)#")) OR 
            (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qFixedPricedItems.Fixed_Component_Paid_to)#"))>
        
        <!--- gather unique items --->
        <cfquery name="vars.qFixedUniqueItems" dbtype="query">
          SELECT DISTINCT (bsa_FoodService_Items_Master_Id), Item, Description, volume_cs, volume_lb, abbreviation
            FROM vars.qFixedPricedItems
            ORDER BY Item
        </cfquery>

        <div class="container_16">
          <div class="grid_16">
            <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>#vars.qProgram.Contract_Number# - <cfif arguments.discountTypeDisplay>Fixed Price</cfif></p>
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
                  <!--- display each component in separate column only if paysto is set as display in template letter --->
                  <cfoutput query="vars.qFixedPricedItems" group="Program_Fixed_Component_Name" >
                    <cfif (distPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '1') OR
                          (operPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '2')>
                      <th class="center">
                        <cfif arguments.componentNameDisplay>#vars.qFixedPricedItems.Program_Fixed_Component_Name#</cfif>
                        <cfif arguments.payableToDisplay><br> Pays To: #(vars.qFixedPricedItems.Fixed_Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#</cfif>
                        &nbsp;
                      </th>
                    </cfif>
                  </cfoutput>
                </tr>
              </thead>
              
              <tbody>
                <!--- loop thru all unique items --->
                <cfloop query="vars.qFixedUniqueItems" >
                  <tr>
                    <td>#vars.qFixedUniqueItems.Item#</td>
                    <td>#vars.qFixedUniqueItems.Description#</td>
                    <td class="right">
                      <cfif trim(vars.qFixedUniqueItems.abbreviation) eq 'cs'>
                        #numberFormat( ((vars.qFixedUniqueItems.volume_cs * vars.qProgram.Effective_Span)/7.00), ",_" )#
                      <cfelse>
                        #numberFormat( ((vars.qFixedUniqueItems.volume_lb * vars.qProgram.Effective_Span)/7.00), ",_.__" )#
                      </cfif>
                    </td>  <!--- est vol --->
                    <td class="center">#vars.qFixedUniqueItems.Abbreviation#</td>

                    <!--- loop over matching items and display the rates --->                   
                    <cfoutput query="vars.qFixedPricedItems" group="BSA_Foodservice_Items_Master_ID" >
                      <cfif vars.qFixedUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qFixedPricedItems.BSA_Foodservice_Items_Master_ID>
                        <cfif (distPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '1') OR
                              (operPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '2')>                    
                          <td class="dollar">#numberformat(vars.qFixedPricedItems.Fixed_Price_Value,"$_.__")#</td>                    
                        </cfif> 
                      </cfif> 
                    </cfoutput>
                    <!--- loop over matching items and display the rates --->
                  </tr>
                </cfloop> <!--- query="vars.qFixedUniqueItems" --->
              </tbody>
            </table>
          </div>  <!--- grid_16 --->
        </div>  <!--- container_16 --->
      </cfif> <!--- display based on template letters paysTo setting --->
    </cfif> <!--- vars.qFixedPricedItems.recordCount  --->


    <!------------------------>
    <!---  REBATE PRODUCTS --->
    <!------------------------>
    <cfif vars.qRebateItems.recordCount gt 0>
      <cfif (distPaysToDisplay AND findNoCase('1', "#valuelist(vars.qRebateItems.Component_Paid_to)#")) OR 
            (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qRebateItems.Component_Paid_to)#"))>

        <!--- gather unique items --->
        <cfquery name="vars.qRebateUniqueItems" dbtype="query">
          SELECT DISTINCT (bsa_FoodService_Items_Master_Id), Item, Description, volume_cs, volume_lb, abbreviation
            FROM vars.qRebateItems
            ORDER BY Item
        </cfquery>
        
        <div class="container_16">
          <div class="grid_16">
            <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>#vars.qProgram.Contract_Number# - <cfif arguments.discountTypeDisplay>Rebate</cfif></p>
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
                  <!--- display each component in separate column only if paysto is set as display in template letter --->
                  <cfoutput query="vars.qRebateItems" group="Program_Rebates_Component_Name">
                    <cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR
                          (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
                      <th class="center">
                        <cfif arguments.componentNameDisplay>#vars.qRebateItems.Program_Rebates_Component_Name#</cfif>
                        <cfif arguments.payableToDisplay><br>Pays To: #(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#</cfif>
                        &nbsp;
                      </th>
                    </cfif> 
                  </cfoutput>
                </tr>
              </thead>

              <tbody>
                <!--- loop thru all unique items --->
                <cfloop query="vars.qRebateUniqueItems" >
                  <tr>
                    <td>#(vars.qRebateUniqueItems.item eq '' ? 'Group' : vars.qRebateUniqueItems.item)#</td>
                    <td>#vars.qRebateUniqueItems.Description#</td>
                    <td class="right">
                      <cfif trim(vars.qRebateUniqueItems.Abbreviation) eq 'cs' or trim(vars.qRebateUniqueItems.Abbreviation) eq '%'>
                        #numberFormat( ((vars.qRebateUniqueItems.volume_cs * vars.qProgram.Effective_Span)/7.00), ",_" )#
                      <cfelse>
                        #numberFormat( ((vars.qRebateUniqueItems.volume_lb * vars.qProgram.Effective_Span)/7.00), ",_.__" )#
                      </cfif>
                    </td>  <!--- est vol --->
                    <td class="center">#vars.qRebateUniqueItems.Abbreviation#</td>
                    
                    <!--- loop over matching items and display the rates --->
                    <cfoutput query="vars.qRebateItems" group="BSA_Foodservice_Items_Master_ID">                       
                      <cfif vars.qRebateUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qRebateItems.BSA_Foodservice_Items_Master_ID>
                        <cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR
                              (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
                          <td class="dollar">
                            <cfif trim(vars.qRebateItems.Abbreviation) eq '%'>
                              #numberformat(vars.qRebateItems.Rate, "_.____")#%
                            <cfelse>
                              #numberformat(vars.qRebateItems.Rate, "$_.__")#
                            </cfif>                          
                          </td>                      
                        </cfif> 
                      </cfif> 
                    </cfoutput>   
                    <!--- loop over matching items and display the rates --->
                  </tr>
                </cfloop>  <!--- vars.qRebateUniqueItems --->
              </tbody>
            </table>
          </div>  <!--- grid_16 --->
        </div>  <!--- container_16 --->
      </cfif> <!--- display based on template letters paysTo setting --->
    </cfif> <!--- vars.qRebateItems.recordCount  --->

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
          <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>#vars.qProgram.Contract_Number# - <cfif arguments.discountTypeDisplay>#Application.LumpsumLabel#</cfif></p>
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
          <p class="opa_group">Date: #DateFormat(vars.qProgram.Contract_Created_Date, "long")#<br>#vars.qProgram.Contract_Number# - <cfif arguments.discountTypeDisplay> #Application.GrowthLabel#</cfif></p>
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

    <div class="container_16 confidentiality">
      <div class="grid_16">
        #application.returned_customer_setting.confidentiality_content#
      </div>
    </div>
  </cfsavecontent>   <!--- variable="variables.letterProducts"> --->

  <cfreturn variables.letterProducts />
</cffunction>
