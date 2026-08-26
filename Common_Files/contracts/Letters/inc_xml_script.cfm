<cfsilent>
<!--- 
FILE: 		
FILENAME: 	Common_Files/contracts/Letters/inc_xml_script.cfm
CREATED: 		02/07/2008 - RBL
EDITED:			08/15/2008 - RBL

FUNCTIONALITY:
- This file contains the cfscript with which we search and grab pieces of the deal letters xml files for specific data from a letter's prior state..
RBL utilized cfscript for this since it is generally viewed as faster.
--->

<!--- These parameters are required for this template to process correctly
na
--->

	<cfscript>
        xProgramFile = XmlParse(xProgramXML);
        
        // A.) Distributor Names...
        aProgramLetterDistributorNamesByLetter = XmlSearch(xProgramFile, "/program/info/program_letter_distributor_names");
        // IF we Have an array AND something is in it...
        if (isArray(aProgramLetterDistributorNamesByLetter) AND arrayLen(aProgramLetterDistributorNamesByLetter))
        {
            lsDistributorNamesByLetterFromXML = "";
            
            for (current_distributor_name = 1; current_distributor_name LTE ArrayLen(aProgramLetterDistributorNamesByLetter); current_distributor_name = current_distributor_name + 1)
            {
                lsDistributorNamesByLetterFromXML = listAppend(lsDistributorNamesByLetterFromXML,trim(aProgramLetterDistributorNamesByLetter[current_distributor_name].XmlText),",");
            }
        }
        else
        {
            lsDistributorNamesByLetterFromXML = "";
        }
        
        // B.) Distributor IDs...
        aProgramLetterDistributorIDsByLetter = XmlSearch(xProgramFile, "/program/info/program_letter_distributor_ids");
        // IF we Have an array AND something is in it...
        if (isArray(aProgramLetterDistributorIDsByLetter) AND arrayLen(aProgramLetterDistributorIDsByLetter))
        {
            lsDistributorIDsByLetterFromXML = "";
            
            for (current_distributor_id = 1; current_distributor_id LTE ArrayLen(aProgramLetterDistributorIDsByLetter); current_distributor_id = current_distributor_id + 1)
            {
                lsDistributorIDsByLetterFromXML = listAppend(lsDistributorIDsByLetterFromXML,trim(aProgramLetterDistributorIDsByLetter[current_distributor_id].XmlText),",");
            }
        }
        else
        {
            lsDistributorIDsByLetterFromXML = "";
        }
    
        // C.) Operator Names...
        aProgramLetterOperatorNamesByLetter = XmlSearch(xProgramFile, "/program/info/program_letter_operator_names");
        // IF we Have an array AND something is in it...
        if (isArray(aProgramLetterOperatorNamesByLetter) AND arrayLen(aProgramLetterOperatorNamesByLetter))
        {
            lsOperatorNamesByLetterFromXML = "";
            
            for (current_operator_name = 1; current_operator_name LTE ArrayLen(aProgramLetterOperatorNamesByLetter); current_operator_name = current_operator_name + 1)
            {
                lsOperatorNamesByLetterFromXML = listAppend(lsOperatorNamesByLetterFromXML,trim(aProgramLetterOperatorNamesByLetter[current_operator_name].XmlText),",");
            }
        }
        else
        {
            lsOperatorNamesByLetterFromXML = "";
        }
        
        // D.) Operator IDs...
        aProgramLetterOperatorIDsByLetter = XmlSearch(xProgramFile, "/program/info/program_letter_operator_ids");
        // IF we Have an array AND something is in it...
        if (isArray(aProgramLetterOperatorIDsByLetter) AND arrayLen(aProgramLetterOperatorIDsByLetter))
        {
            lsOperatorIDsByLetterFromXML = "";
            
            for (current_operator_id = 1; current_operator_id LTE ArrayLen(aProgramLetterOperatorIDsByLetter); current_operator_id = current_operator_id + 1)
            {
                lsOperatorIDsByLetterFromXML = listAppend(lsOperatorIDsByLetterFromXML,trim(aProgramLetterOperatorIDsByLetter[current_operator_id].XmlText),",");
            }
        }
        else
        {
            lsOperatorIDsByLetterFromXML = "";
        }
        
        // E.) Show Customer Product Numbers...
        aAddCustomerProductNumbers = XmlSearch(xProgramFile, "/program/info/show_customer_product_numbers");
        // IF we Have an array AND something is in it...
        if (isArray(aAddCustomerProductNumbers) AND arrayLen(aAddCustomerProductNumbers))
        {
            // grab the first on ONLY row
            bAddCustomerProductNumbersFromXML = trim(aAddCustomerProductNumbers[1].XmlText);
        }
        else
        {
            // always default to no throughout...
            bAddCustomerProductNumbersFromXML = 0;
        }
    
        // F.) Include Volume Page...
        aIncludeVolumePage = XmlSearch(xProgramFile, "/program/info/include_volume_page");
        // IF we Have an array AND something is in it...
        if (isArray(aIncludeVolumePage) AND arrayLen(aIncludeVolumePage))
        {
            // grab the first on ONLY row
            bIncludeVolumePageFromXML = trim(aIncludeVolumePage[1].XmlText);
        }
        else
        {
            // always default to no throughout...
            bIncludeVolumePageFromXML = 0;
        }
    
        // G.) Insert Watermark...
        aInsertWatermark = XmlSearch(xProgramFile, "/program/info/insert_watermark");
        // IF we Have an array AND something is in it...
        if (isArray(aInsertWatermark) AND arrayLen(aInsertWatermark))
        {
            // grab the first on ONLY row
            bInsertWatermarkFromXML = trim(aInsertWatermark[1].XmlText);
        }
        else
        {
            // always default to no throughout...
            bInsertWatermarkFromXML = 0;
        }
    
        // H.) Include Freight Page...
        aIncludeFreightPage = XmlSearch(xProgramFile, "/program/info/include_freight_page");
        // IF we Have an array AND something is in it...
        if (isArray(aIncludeFreightPage) AND arrayLen(aIncludeFreightPage))
        {
            // grab the first on ONLY row
            bLetterDisplayFreightFromXML = trim(aIncludeFreightPage[1].XmlText);
        }
        else
        {
            // always default to no throughout...
            bLetterDisplayFreightFromXML = 0;
        }
        
        // I.) Customer Freight UOM...
        aCustomerFreightUom = XmlSearch(xProgramFile, "/program/info/customer_freight_uom");
        // IF we Have an array AND something is in it...
        if (isArray(aCustomerFreightUom) AND arrayLen(aCustomerFreightUom))
        {
            // grab the first on ONLY row
            customerFreightUomFromXML = trim(aCustomerFreightUom[1].XmlText);
        }
        else
        {
            // always default to no or empty string throughout...
            customerFreightUomFromXML = '';
        }
    
        // J.) pages to delete from prior letter...
        aPagesToDeleteFromPriorLetter = XmlSearch(xProgramFile, "/program/info/pages_to_delete_from_prior_letter");
        // IF we Have an array AND something is in it...
        if (isArray(aPagesToDeleteFromPriorLetter) AND arrayLen(aPagesToDeleteFromPriorLetter))
        {
            // grab the first on ONLY row
            pagesToDeleteFromPriorLetterFromXML = trim(aPagesToDeleteFromPriorLetter[1].XmlText);
        }
        else
        {
            // always default to no or empty string throughout...
            pagesToDeleteFromPriorLetterFromXML = '';
        }
    
        // K.) pages to delete from this letter...
        aPagesToDeleteFromThisLetter = XmlSearch(xProgramFile, "/program/info/pages_to_delete_from_this_letter");
        // IF we Have an array AND something is in it...
        if (isArray(aPagesToDeleteFromThisLetter) AND arrayLen(aPagesToDeleteFromThisLetter))
        {
            // grab the first on ONLY row
            pagesToDeleteFromThisLetterFromXML = trim(aPagesToDeleteFromThisLetter[1].XmlText);
        }
        else
        {
            // always default to no or empty string throughout...
            pagesToDeleteFromThisLetterFromXML = '';
        }
    
        // L.) Contract Number...
        aContractNumber = XmlSearch(xProgramFile, "/program/contract_number");
        // IF we Have an array AND something is in it...
        if (isArray(aContractNumber) AND arrayLen(aContractNumber))
        {
            // grab the first on ONLY row
            contractNumberFromXML = trim(aContractNumber[1].XmlText);
        }
        else
        {
            // always default to no or empty string throughout...
            contractNumberFromXML = '';
        }
        
        // M.) Contract Start Date...
        aContractStartDate = XmlSearch(xProgramFile, "/program/contract_start_date");
        // IF we Have an array AND something is in it...
        if (isArray(aContractStartDate) AND arrayLen(aContractStartDate))
        {
            // grab the first on ONLY row
            contractStartDateFromXML = trim(aContractStartDate[1].XmlText);
        }
        else
        {
            // always default to no or empty string throughout...
            contractStartDateFromXML = createODBCDate(now());
        }
        
        // N.) Contract End Date...
        aContractEndDate = XmlSearch(xProgramFile, "/program/contract_end_date");
        // IF we Have an array AND something is in it...
        if (isArray(aContractEndDate) AND arrayLen(aContractEndDate))
        {
            // grab the first on ONLY row
            contractEndDateFromXML = trim(aContractEndDate[1].XmlText);
        }
        else
        {
            // always default to no or empty string throughout...
            contractEndDateFromXML = createODBCDate(now());
        }
        
        // 0.) Title...
        aProgramLetterTitle = XmlSearch(xProgramFile, "/program/letter_title");
        // IF we Have an array AND something is in it...
        if (isArray(aProgramLetterTitle) AND arrayLen(aProgramLetterTitle))
        {
            // grab the first on ONLY row
            programLetterTitle = aProgramLetterTitle[1].XmlText;
        }
        else
        {
            programLetterTitle = "";
        }
        
        // 1.) Distributor...
        aDistributorIDsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/distributors/distributor/id");
        // IF we Have an array AND something is in it...
        if (isArray(aDistributorIDsInitiallyIncludedInThisProgramLetter) AND arrayLen(aDistributorIDsInitiallyIncludedInThisProgramLetter))
        {
            lsDistributorIDsFromXML = "";
            for (current_distributor_id = 1; current_distributor_id LTE ArrayLen(aDistributorIDsInitiallyIncludedInThisProgramLetter); current_distributor_id = current_distributor_id + 1)
            {
                lsDistributorIDsFromXML = listAppend(lsDistributorIDsFromXML,trim(aDistributorIDsInitiallyIncludedInThisProgramLetter[current_distributor_id].XmlText),",");
            }
        }
        else
        {
            // numbers
            lsDistributorIDsFromXML = "0";
        }
        
        // 2.) Operator...
        aOperatorIDsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/operators/operator/id");
        // IF we Have an array AND something is in it...
        if (isArray(aOperatorIDsInitiallyIncludedInThisProgramLetter) AND arrayLen(aOperatorIDsInitiallyIncludedInThisProgramLetter))
        {
            lsOperatorIDsFromXML = "";
            for (current_operator_id = 1; current_operator_id LTE ArrayLen(aOperatorIDsInitiallyIncludedInThisProgramLetter); current_operator_id = current_operator_id + 1)
            {
                lsOperatorIDsFromXML = listAppend(lsOperatorIDsFromXML,trim(aOperatorIDsInitiallyIncludedInThisProgramLetter[current_operator_id].XmlText),",");
            }
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            // numbers
            lsOperatorIDsFromXML = "0";
        }
        
        // 3.) Fixed Price Products...
        aFixedPriceProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/fixed_price/product/bsa_id_uom_comp_id");
        // IF we Have an array AND something is in it...
        if (isArray(aFixedPriceProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter) AND arrayLen(aFixedPriceProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter))
        {
            lsFixedPriceProductIDUOMCOMPsFromXML = "";
            for (current_fixedPriceProduct_id = 1; current_fixedPriceProduct_id LTE ArrayLen(aFixedPriceProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter); current_fixedPriceProduct_id = current_fixedPriceProduct_id + 1)
            {
                lsFixedPriceProductIDUOMCOMPsFromXML = listAppend(lsFixedPriceProductIDUOMCOMPsFromXML,trim(aFixedPriceProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter[current_fixedPriceProduct_id].XmlText),",");
            }
            //lsFixedPriceProductIDUOMCOMPsFromXML = listQualify(lsFixedPriceProductIDUOMCOMPsFromXML,"'",",");
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            //strings
            lsFixedPriceProductIDUOMCOMPsFromXML = "No FIXED PRICE Products in this particular letter's XML dna";
        }
        
        // 3.A. OPTIONAL Fixed Price Product CUSTOMER PRODUCT NUMBERS
        aFixedPriceProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/fixed_price/product/customer_product_number");
        // IF we Have an array AND something is in it...
        if (isArray(aFixedPriceProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aFixedPriceProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter))
        {
            bFixedPriceCustomerProductNumbers = 1;
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            bFixedPriceCustomerProductNumbers = 0;
        }
    
        // 4.) Rebate Products...
        aRebateProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/rebate/product/bsa_id_uom_comp_id");
        // IF we Have an array AND something is in it...
        if (isArray(aRebateProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter) AND arrayLen(aRebateProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter))
        {
            lsRebateProductIDUOMCOMPsFromXML = "";
            for (current_rebateProduct_id = 1; current_rebateProduct_id LTE ArrayLen(aRebateProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter); current_rebateProduct_id = current_rebateProduct_id + 1)
            {
                lsRebateProductIDUOMCOMPsFromXML = listAppend(lsRebateProductIDUOMCOMPsFromXML,trim(aRebateProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter[current_rebateProduct_id].XmlText),",");
            }
            //lsRebateProductIDUOMCOMPsFromXML = listQualify(lsRebateProductIDUOMCOMPsFromXML,"'",",");
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            //strings
            lsRebateProductIDUOMCOMPsFromXML = "No REBATE Products in this particular letter's XML dna";
        }
    
        // 4.A. OPTIONAL Rebate Product CUSTOMER PRODUCT NUMBERS
        aRebateProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/rebate/product/customer_product_number");
        // IF we Have an array AND something is in it...
        if (isArray(aRebateProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aRebateProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter))
        {
            bRebateCustomerProductNumbers = 1;
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            bRebateCustomerProductNumbers = 0;
        }
    
        // 5.) Bid Request Products...
        aBidRequestProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/bid_request/product/bsa_id_uom_comp_id");
        // IF we Have an array AND something is in it...
        if (isArray(aBidRequestProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter) AND arrayLen(aBidRequestProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter))
        {
            lsBidRequestProductIDUOMCOMPsFromXML = "";
            for (current_bidRequestProduct_id = 1; current_bidRequestProduct_id LTE ArrayLen(aBidRequestProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter); current_bidRequestProduct_id = current_bidRequestProduct_id + 1)
            {
                lsBidRequestProductIDUOMCOMPsFromXML = listAppend(lsBidRequestProductIDUOMCOMPsFromXML,trim(aBidRequestProductIDUOMCOMPsInitiallyIncludedInThisProgramLetter[current_bidRequestProduct_id].XmlText),",");
            }
            //lsBidRequestProductIDUOMCOMPsFromXML = listQualify(lsBidRequestProductIDUOMCOMPsFromXML,"'",",");
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            //strings
            lsBidRequestProductIDUOMCOMPsFromXML = "No BID REQUEST Products in this particular letter's XML dna";
        }
    
        // 5.A. OPTIONAL Bid Request Product CUSTOMER PRODUCT NUMBERS
        aBidRequestProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/bid_request/product/customer_product_number");
        // IF we Have an array AND something is in it...
        if (isArray(aBidRequestProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aBidRequestProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter))
        {
            bBidRequestCustomerProductNumbers = 1;
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            bBidRequestCustomerProductNumbers = 0;
        }
    
        // 6.) Lump Sum...
        aLumpSumIDsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/lump_sum/product/bsa_id_comp_id");

        // IF we Have an array AND something is in it...
        if (isArray(aLumpSumIDsInitiallyIncludedInThisProgramLetter) AND arrayLen(aLumpSumIDsInitiallyIncludedInThisProgramLetter))
        {
            lsLumpSumIDsFromXML = "";
            for (current_lumpSum_id = 1; current_lumpSum_id LTE ArrayLen(aLumpSumIDsInitiallyIncludedInThisProgramLetter); current_lumpSum_id = current_lumpSum_id + 1)
            {
                lsLumpSumIDsFromXML = listAppend(lsLumpSumIDsFromXML,trim(aLumpSumIDsInitiallyIncludedInThisProgramLetter[current_lumpSum_id].XmlText),",");
            }
            //lsLumpSumIDsFromXML = listQualify(lsLumpSumIDsFromXML,"'",",");
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            //strings
            lsLumpSumIDsFromXML = "No LUMP SUMS in this particular letter's XML dna";
        }

	    
        // 4.A. OPTIONAL Lumpsum Product CUSTOMER PRODUCT NUMBERS
        aLumpsumProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/lump_sum/product/customer_product_number");
        // IF we Have an array AND something is in it...
        if (isArray(aLumpsumProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter) AND arrayLen(aLumpsumProductCustomerProductNumbersInitiallyIncludedInThisProgramLetter))
        {
            bLumpsumCustomerProductNumbers = 1;
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            bLumpsumCustomerProductNumbers = 0;
        }
        
        // 7.) Growth On Deck...
        
        // 8.) Clauses...
		
		/* TEMPORARILY COMMENT OUT CLAUSE [begin]
        aClauseIDsInitiallyIncludedInThisProgramLetter = XmlSearch(xProgramFile, "/program/clauses/id");
        // IF we Have an array AND something is in it...
        if (isArray(aClauseIDsInitiallyIncludedInThisProgramLetter) AND arrayLen(aClauseIDsInitiallyIncludedInThisProgramLetter))
        {
            lsClauseIDsFromXML = "";
            for (current_clause_id = 1; current_clause_id LTE ArrayLen(aClauseIDsInitiallyIncludedInThisProgramLetter); current_clause_id = current_clause_id + 1)
            {
                lsClauseIDsFromXML = listAppend(lsClauseIDsFromXML,trim(aClauseIDsInitiallyIncludedInThisProgramLetter[current_clause_id].XmlText),",");
            }
        }
        // IF we DON'T have an array OR nothing is in it...
        else
        {
            // numbers
            lsClauseIDsFromXML = "0";
        }
		TEMPORARILY COMMENT OUT CLAUSE [end] */
		
    </cfscript>

</cfsilent>