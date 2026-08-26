<!---
  * ====================================================================================================
  *    @File: \billbacks\gm\ajax\search.cfm
  *  @Author: Chris Nguyen
  *    @Date: January 2020
  *
  * @Remarks: Search billbacks - search tab Ajax backend (under home tab)
  *
  * ====================================================================================================
--->
<cfsetting showDebugOutput="no">
<cfsetting enablecfoutputonly="true">

<cfscript>
    param form.statusListSelect     = '';
    param form.actionSelect         = '';
    param form.BBCodeKeyword        = '';
    param form.BBNumberKeyword      = '';
    param form.currentIncludingPaid = '';
    param form.programKeyword       = '';
    param form.entityKeyword        = '';
    param form.entitySelect         = '';
    param form.checkNoKeyword       = '';
    param form.conditionSelect       = '';

    delimiter = '|';
    form.statusListSelect = listToArray( form.statusListSelect );

    search_param                              = createObject("mvc.Models.Billback.vos.BBFilterParams").init();
    search_param.actionSelect                 = form.actionSelect;

    search_param.amountCriteriaSelect         = '';
    search_param.amountTypeSelect             = '';
    search_param.amountValueKeyword           = '';

    search_param.analystListSelect            = [];
    search_param.BBCodeKeyword                = form.BBCodeKeyword;
    search_param.BBNumberKeyword              = form.BBNumberKeyword;
    search_param.bSearchAmount                = '';

    search_param.bSearchDateRangeEnd          = '';
    search_param.bSearchDateRangeStart        = '';

    search_param.checkNoKeyword               = form.checkNoKeyword;
    search_param.closingMethodSelect          = [];
    search_param.conditionSelect              = form.conditionSelect;
    search_param.currentIncludingPaid         = form.currentIncludingPaid contains "paid" ? 1 : 0;

    search_param.dateRangeEndCriteriaSelect   = form.dateRangeEndCriteriaSelect;
    search_param.dateRangeEndTypeSelect       = form.dateRangeEndTypeSelect;
    search_param.dateRangeEndValueKeyword     = form.dateRangeEndValueKeyword;

    search_param.dateRangeStartCriteriaSelect = form.dateRangeStartCriteriaSelect;
    search_param.dateRangeStartTypeSelect     = form.dateRangeStartTypeSelect;
    search_param.dateRangeStartValueKeyword   = form.dateRangeStartValueKeyword;

    search_param.entityKeyword                = form.entityKeyword;
    search_param.entitySelect                 = form.entitySelect;

    search_param.historySelect                = '';
    search_param.historyUsernameSelect        = [];

    search_param.payeeKeyword                 = form.payeeKeyword;
    search_param.programKeyword               = form.programKeyword;

    search_param.statusListSelect             = [];
    search_param.typeListSelect               = [];

    search_param.called_from                  = "search_bb_2020";
</cfscript>

<cfinvoke   component      = "mvc.Models.Billback.BillbackLoadManager"
            method         = "getBillbackHeader"
            userid         = "#request.AccessStructure.user_id#"
            BBFILTERPARAMS = #search_param#
            returnvariable = "qRows">

<!--- ~~~~~~~~~~~~~ hidden columns are placed in the leading positions ~~~~~~~~~~~~~~ --->
<cfoutput>{ "COUNT":#(isDefined("qRows.NumberofRecords") ? -999 : qRows.recordCount)#
            ,"ROWS":#application.util.query.toDtJSON(qRows,
                                                    arrayToList([
                                                        <!---  0 --->  "Billback_ID_Int"
                                                        <!---  1 --->  ,"Analyst_User_Int"
                                                        <!---  2 --->  ,"BB_Type_Description"
                                                        <!---  3 --->  ,"Created_Date"
                                                        <!---  4 --->  ,"BB_Request_Approval_Date"
                                                        <!---  5 --->  ,"Date_Approved"
                                                        <!---  6 --->  ,"Paid_Date"
                                                        <!---  7 --->  ,"Billback_ID"
                                                        <!---  8 --->  ,"BB_Status_Abbreviation"
                                                        <!---  9 --->  ,"BB_Code"
                                                        <!--- 10 --->  ,"BB_Reference"
                                                        <!--- 11 --->  ,"BB_Title"
                                                        <!--- 12 --->  ,"BB_Received_Date"
                                                        <!--- 13 --->  ,"Payee"
                                                        <!--- 14 --->  ,"VendorPayee"
                                                        <!--- 15 --->  ,"BB_Start_Date"
                                                        <!--- 16 --->  ,"BB_End_Date"
                                                        <!--- 17 --->  ,"BB_Amount"
                                                        <!--- 18 --->  ,"Approved_Amount"
                                                        <!--- 19 --->  ,"Billback_Closing_Method_Abbreviation"
                                                        <!--- 20 --->  ,"vendorPayeeId"
                                                        <!--- 21 --->  ,"Creator_User_Int"
                                                        <!--- 22 --->  ,"Request_Approval_User_Int"
                                                        <!--- 23 --->  ,"Approved_User_Int"
                                                        <!--- 24 --->  ,"Disagree_User_Int"
                                                        <!--- 25 --->  ,"Reset_User_Int"
                                                        <!--- 26 --->  ,"ResetAllowed"
                                                        <!--- 27 --->  ,"DeleteAllowed"
                                                        <!--- 28 --->  ,"HoldAllowed"
                                                        <!--- 29 --->  ,"ReleaseAllowed"
                                                        <!--- 30 --->  ,"ReassignAllowed"
                                                        <!--- 31 --->  ,"MassApproveAllowed"
                                                        <!--- 32 --->  ,"Document_Attached"
                                                        <!--- 33 --->  ,"Discrepancy"
                                                        <!--- 34 --->  ,"notAcknowledged"
                                                        <!--- 35 --->  ,"Approved_User"
                                                        <!--- 36 --->  ,"Reset_User"
                                                        <!--- 37 --->  ,"Disagree_User"
                                                        <!--- 38 --->  ,"Request_Approval_User"
                                                        <!--- 39 --->  ,"Creator_User"
                                                        <!--- 40 --->  ,"Analyst_User"
                                                        <!--- 41 --->  ,"BB_Upload_Dup_Group_ID"
                                                        
                                                    ])
)#}</cfoutput>