<cfsilent>
<!---
Copyright (c)2016 Blacksmith Applications, Inc.
Filename:       C:\Work\base\AwayX\billbacks\CustomerInvoice\billback_list.cfm
Created:            2/29/2016
Developer:      drachala
Description:     This File is used to display Billbacks associated with BB reference number and uploaded id passed through as URL variables.
Usage:          in Search Customer Invoice search functionality
--->
	<cfset appSettings = application.appSettingsGet />

    <cfquery name="billbackList" datasource="#application.datasource#">
        SELECT  BB_Title
               ,B.BB_Start_Date
               ,B.BB_End_Date
               ,B.BB_Amount
               ,B.BB_Code
               ,BB_Status_Description
               ,Abbreviation
               ,Paid_Amount AS Paid
               ,B.BB_Amount AS Claimed
               ,BB_Expected_Amount AS Expected
               ,( BB_Expected_Amount - B.BB_Amount ) AS Deviated
               ,B.Billback_ID
               ,Deviation_Ran_Date
              ,Auto_Billback
               ,B.Billback_Status_ID
               ,BA.Check_Number
               , (SELECT Top 1 d.DD_DedID_SP_Number
                  FROM   DD_Closure_Detail dc
                         INNER JOIN Deductions d ON d.Deduction_ID = dc.Deduction_ID
                  WHERE  dc.DD_Closure_ID = B.Billback_ID
                         AND dc.Deleted = <cfqueryparam value=0>
               ) as Deduction_Number
        FROM    Billback B
        INNER JOIN Billback_Status BS
                ON BS.Billback_Status_ID = B.Billback_Status_ID
        INNER JOIN Billback_Txt_Upload_Header_log BTUH
                ON BTUH.Billback_ID = B.Billback_ID
        INNER JOIN Billback_Closing_Methods BCM
                ON iBillback_Closing_Method_ID = BB_Closing_Method
        LEFT JOIN BB_Approved BA
                ON BA.Billback_ID = B.Billback_ID
        WHERE   B.BB_Reference = <cfqueryparam value='#url.bbreference#'>
                AND B.Deleted = <cfqueryparam value=0>
                AND upload_id = <cfqueryparam value=#url.Upload_ID#>
    </cfquery>


    <cfquery name="variables.products" datasource="#application.datasource#">
        SELECT  b.BB_Code
               ,b.BB_Reference
               ,b.BB_Start_Date
               ,b.BB_End_Date
               ,BB_Title
               ,Item
               ,Description
               ,CASE WHEN BB_Product_UOM = 1 THEN Cast(IsNull(Expected_Rate_CS, 0) * IsNull(Item_E_Volume_CS, 0) AS DECIMAL(18, 2))
                     ELSE Cast(IsNull(Expected_Rate_LB, 0) * IsNull(Item_E_Volume_LB, 0) AS DECIMAL(18, 2))
                END AS Expected_Amount
               ,Cast(BB_Rate AS DECIMAL(18, 2)) AS Claimed_Amount
               ,CASE WHEN BB_Product_UOM = 1 THEN Cast(IsNull(Paid_Rate_CS, 0) * IsNull(Item_Volume_Paid_CS, 0) AS DECIMAL(18, 2))
                     ELSE Cast(IsNull(Paid_Rate_LB, 0) * IsNull(Item_Volume_Paid_LB, 0) AS DECIMAL(18, 2))
                END AS Paid_Amount
               ,CASE WHEN BB_Product_UOM = 1 THEN Cast(IsNull(Expected_Rate_CS, 0) * IsNull(Item_E_Volume_CS, 0) - BB_Rate AS DECIMAL(18, 2))
                     ELSE Cast(IsNull(Expected_Rate_LB, 0) * IsNull(Item_E_Volume_LB, 0) - BB_Rate AS DECIMAL(18, 2))
                END AS Deviated_Amount
        FROM    Billback B
        INNER JOIN Billback_Program BPG
                ON B.Billback_ID = BPG.Billback_ID
        INNER JOIN Billback_Product BP
                ON B.Billback_ID = BP.Billback_ID
                   AND BPG.Billback_Program_ID = BP.Billback_Program_ID
        INNER JOIN Billback_Product_Detail BPD
                ON BP.Billback_Product_ID = BPD.Billback_Product_ID
        INNER JOIN Billback_Txt_Upload_Header_log BTUH
                ON BTUH.Billback_ID = B.Billback_ID
        INNER JOIN BSA_Foodservice_Items_Master BFIM
                ON Product_ID = BSA_Foodservice_Items_Master_ID
        LEFT JOIN BB_Item_Final BBIF
                ON BP.Billback_Product_ID = BBIF.Billback_Product_ID
                   AND BBIF.Deleted = 0
        LEFT JOIN BB_Item_Final_Detail BBIFD
                ON BBIF.BB_Item_Final_ID = BBIFD.BB_Item_Final_ID
                   AND BBIFD.Deleted = 0
        WHERE   B.BB_Reference = <cfqueryparam value='#url.bbreference#'>
                AND B.Deleted = 0
                AND BPG.Deleted = 0
                AND BP.Deleted = 0
                AND BPD.Deleted = 0
                AND BTUH.upload_id = <cfqueryparam value=#url.Upload_ID#>
    </cfquery>

    <cfset filename ="Billbacks for Invoice #url.bbreference#">
    <cfset PageTitle="  For Invoice ## #url.bbreference#">
</cfsilent>
<cf_layout-bare page_title="#filename#">
    <cfsavecontent variable="variables.uncompressed">
        <cf_include file_to_include="/Common_Files/datatable.css"/>
        <style>
        .right {
            text-align: right;
        }
        .action {
            margin-right: 20px;
        }
        </style>

        <cfinclude template="/settings/settings_title.cfm">

        <a href="javascript:getCSVData();" class="action"><cfoutput>#application.util.string.actionLinkFormat2("export")#</cfoutput></a>
        <a href="javascript:getCSVData2();" class="action"><cfoutput>#application.util.string.actionLinkFormat2("export product detail")#</cfoutput></a>

        <table class="datagrid" id="Billbacklist">
          <thead>
            <tr>
            <th>Payable #</th>
            <th>Title</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Status &nbsp; </th>
            <th>Type &nbsp; </th>
            <th>Claimed</th>
            <th>Expected</th>
            <th>Paid</th>
            <th>Deviated</th>
            </tr>
          </thead>
          <tbody>
        <cfoutput query="billbackList">
            <tr>
                <td>
                    <a href="/billbacks/capture/bb_preview.cfm?BBID=#Billback_ID#" id="previewlink" target="preview_window" >#application.util.string.actionLinkFormat2(bb_code)#</a>
                    <cfif len(Deviation_Ran_Date) AND Billback_Status_ID gte 2 AND Auto_Billback NEQ 1>

						<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
							<cfset newWindowPage ="/billbacks/deviation/deviation_main.cfm">
							<!--- Originally, we used "AgGridBB" here instead of "BBAgGridScoreCard". So that the billback gets locked/unlocked when we view the deviation popup from here,
							"BBAgGridScoreCard" is being used below.
							--->
							<cfset callerArg = "BBAgGridScoreCard">
						<cfelse>
							 <cfset newWindowPage ="/flex/Billback/BillbackDevAppFX.cfm">
							<!--- Originally, we used "flexBB" here instead of "BBFlexScoreCard". So that the billback gets locked/unlocked when we view the deviation popup from here,
							"BBFlexScoreCard" is being used below.
							--->
							 <cfset callerArg = "BBFlexScoreCard">
						</cfif>

                        <a href="##" title="Deviation Tool" onclick="javascript:window.open('#newWindowPage#?bbid=#Billback_ID#&userID=#request.AccessStructure.User_ID#&caller=#callerArg#','BBDeviation','location=1,status=1,scrollbars=1,resizable=1,width=1350,left=0,height=800');return false;">
                            <img src="/images/worksheet.gif" border="0" width="10" height="10">
                        </a>
                    </cfif>
                </td>
                <td>#bb_title#</td>
                <td>#dateformat(bb_start_date,'mm/dd/yyyy')#</td>
                <td>#dateformat(bb_end_date,'mm/dd/yyyy')#</td>
                <td>#bb_status_description#</td>
                <td>#Abbreviation# <cfif billbackList.Abbreviation eq "pmt">#billbackList.check_number#<cfelseif billbackList.Abbreviation eq "ded">#billbackList.deduction_number#</cfif></td>
                <td class="right">#dollarformat(bb_amount)#</td>
                <td class="right">#dollarformat(Expected)#</td>
                <td class="right">#dollarformat(Paid)#</td>
                <td class="right">#dollarformat(Deviated)#</td>
            </tr>
        </cfoutput>
          </tbody>
        </table>

        <table id="product_detail" class="datagrid">
          <thead>
            <tr>
                <th>Payable #</th>
                <th>Billback #</th>
                <th>Title</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Product</th>
                <th>Claimed</th>
                <th>Expected</th>
                <th>Paid</th>
                <th>Deviated</th>
            </tr>
          </thead>
          <tbody>
            <cfoutput query="variables.products">
                <tr>
                    <td>#variables.products.bb_code#</td>
                    <td>#variables.products.bb_reference#</td>
                    <td>#variables.products.bb_title#</td>
                    <td>#dateFormat(variables.products.bb_start_date, "m/d/yyyy")#</td>
                    <td>#dateFormat(variables.products.bb_end_date, "m/d/yyyy")#</td>
                    <td>#variables.products.item# #variables.products.description# </td>
                    <td class="right">#dollarFormat(variables.products.claimed_amount)#</td>
                    <td class="right">#dollarFormat(variables.products.Expected_Amount)#</td>
                    <td class="right">#dollarFormat(variables.products.Paid_Amount)#</td>
                    <td class="right">#dollarFormat(variables.products.Deviated_Amount)#</td>
                </tr>
            </cfoutput>
          </tbody>
        </table>

        <form action="/common_files/csv.cfm" method ="post" id="csv_form">
          <input type="hidden" name="csv_text" id="csv_text">
          <input type="hidden" name="csv_file_name" id="csv_file_name">
        </form>

        <!--- <cfinclude template="/Common_Files/jQuery.cfm"> --->
        <cfinclude template="/Common_Files/dataTables.cfm">
        <cf_include file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js"/>
    </cfsavecontent>

    <cfoutput>#application.util.string.compress( variables.uncompressed )#</cfoutput>
    <script>
        $('#Billbacklist, #product_detail').dataTable( {
              "bSortClasses": false
            , "bAutoWidth": false
            , "bPaginate": true
            , "bProcessing": true
            , "bScrollCollapse": true
            , "sScrollY": Math.floor(jQuery(window).height()) - 300
            , "sDom": "rpti"
            , "iDisplayLength": 100
            , "aaSorting": []
            , "aoColumns": [
                                    {"bSortable":true}
                                ,   {"bSortable":true}
                                ,   {"bSortable":true}
                                ,   {"bSortable":true}
                                ,   {"bSortable":true}
                                ,   {"bSortable":true}
                                ,   {"bSortable":true, "sClass": "currency"}
                                ,   {"bSortable":true, "sClass": "currency"}
                                ,   {"bSortable":true, "sClass": "currency"}
                                ,   {"bSortable":true, "sClass": "currency"}
                                ]
        } );

        getCSVData = function() {
         var csv_value = $('#Billbacklist').table2CSV({ sScrollY: 1 });
         $("#csv_file_name").val("<cfoutput>#replace(filename,' ', '_', 'all')#</cfoutput>_" + random367() + ".csv");
         $("#csv_text").val(csv_value);
         $("#csv_form").submit();
        }

        getCSVData2 = function() {
         var csv_value = $('#product_detail').table2CSV({ sScrollY: 1 });
         $("#csv_file_name").val("<cfoutput>#replace(filename,' ', '_', 'all')#</cfoutput>_" + random367() + ".csv");
         $("#csv_text").val(csv_value);
         $("#csv_form").submit();
        }
    </script>
</cf_layout-bare>
