<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">
<!---
  * ==================================================================================================== 
  *    @File: Deployment\Redistribution\ajax\validate_correction.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2019 June - 85971
  * 
  * @Remarks:
  *  
  * ==================================================================================================== 
--->
<cfscript>
    outcome   = { messages:[], status:"" };
    submitted = structKeyExists(form, "submitted_json") and isJSON(form.submitted_json)
                     ? deserializeJSON(form.submitted_json)
                     : {};

    // required header/detail json structures are missing
    if ( ( structKeyExists(submitted, "header") and structKeyExists(submitted, "detail") ) is false ) {
        arrayAppend(outcome.messages, "Expected header and detail are missing");
    }
    else {
        sourceType             = "";
        strBBClaimSourceXREFID = "";
        rch                    = CreateObject("component","mvc.Models.Admin.Redi.vos.RediCorrectionHeader");
        objRediEditDAO         = CreateObject("component","mvc.Models.Admin.Redi.RediEditDAO");
        objRediDAO             = CreateObject("component","mvc.Models.Admin.Redi.RediDAO");
        objRediMan             = CreateObject("component","mvc.Models.Admin.Redi.RediManager");
        objRediEditMan         = CreateObject("component","mvc.Models.Admin.Redi.RediEditManager");

        rch.rediCorrectionHeaderId = submitted.header.row_identity;
        qRediEditHeaderData        = objRediDAO.getRediHeaderData(rch);
        arrH                       = objRediMan.getRediCorrectionHeaderObj(qRediEditHeaderData);

        if (arraylen(arrH) > 0){
            rch = arrH[1];
        }
        rch.finalCustomer.shipTo    = submitted.header.final_customer_ship_to;
        rch.originalCustomer.shipTo = submitted.header.original_customer_ship_to;
        qDet                        = objRediEditDAO.getRediEditDetailData(rch);

        arr = [];
        for (intRow = 1 ; intRow LTE qDet.recordCount; intRow ++){
            stRcd                           = {};
            stRcd["__type__"]               = "mvc.Models.Admin.Redi.vos.RediCorrectionDetail";
            stRcd["rediCorrectionHeaderId"] = qDet.REDI_H_ID[intRow];
            stRcd["rediCorrectionDetailId"] = qDet.REDI_D_ID[intRow];
            
            stRcd["itemDesc"]       = qDet.Description[intRow];
            stRcd["itemPackSize"]   = 0;
            stRcd["aliasItem"]      = qDet.Alias_Item_Number[intRow];
            stRcd["aliasItemDesc"]  = qDet.Alias_Item_Desc[intRow];
            stRcd["aliasRecordId"]  = qDet.Alias_Record_Id[intRow];
            stRcd["invoiceCases"]   = qDet.qty[intRow];
            stRcd["invoicePriceCS"] = qDet.Unit_Price[intRow];
            stRcd["errorMessage"]   = qDet.Err_Msg[intRow];
            stRcd["item"]           = "";

            for (i=1;i lte arrayLen(submitted.detail); i=i+1) {
                // find detail record and update it with selected item on frontend
                if (submitted.detail[i].row_identity == qDet.redi_ec_detail_id[intRow]) {
                    stRcd["item"] = submitted.detail[i].item;
                    break;
                }
            }
            arrayAppend(arr, stRcd);
        }

        rch["arrRediCorrectionItems"] = arr;        
        validate_result               = objRediEditMan.validateRediCorrection(rch);

        if (validate_result.invoiceNumber contains "error" or trim(validate_result.errorMessage) gt '') {
            outcome.status   = "failure";
            outcome.messages = validate_result.errorMessage & ".";
        }
        else {
            outcome.status   = "success";
            outcome.messages = submitted.header.row_identity & " - invoice " & validate_result.invoiceNumber & " created.";
        }
    }
</cfscript>

<cfoutput>{"STATUS":"#outcome.status#","MESSAGES":"#outcome.messages#"}</cfoutput>
