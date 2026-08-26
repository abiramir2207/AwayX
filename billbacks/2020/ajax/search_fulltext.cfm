<!---
  * ==================================================================================================== 
  *    @File: \billbacks\gm\ajax\search_fulltext.cfm
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

    

    //delimiter = '|';
    //form.statusListSelect = listToArray( form.statusListSelect );

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
    
    if(form.statusListSelect == 'PA'){
        st = structNew();
        st.id = 202;
        st.description = 'Pending Approval';
        search_param.statusListSelect = [st];
    }
    else{
        search_param.statusListSelect = [];
    }
    
    search_param.typeListSelect               = [];

    search_param.called_from                  = "search_bb_2020";
</cfscript>

<cfinvoke   component      = "mvc.Models.Billback.BillbackSearchManager"
            method         = "filterRemoteData"
            userid         = "#request.AccessStructure.user_id#"
            BBFILTERPARAMS = #search_param#
            returnvariable = "matching_bbs">

<!--- 
    <cfset request.dumpToEmail_address = "cnguyen@blacksmithapplications.com"> 
    <cfset application.util.io.dumpToEmail(search_param, matching_bbs)> 
--->

<cfoutput>#serializeJSON( matching_bbs.f )#</cfoutput>
