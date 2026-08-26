<cfsetting enableCFoutputOnly = "yes">
<!---
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2019 October 30
  *
  * @Remarks: jQuery multiselect and filter widgets library
  *
  * @Requirements: Need to load jQuery version 1.12.4 in the parent code
  *
  *    <cfset jQuery.version = "1.12.4">
  *    <cfinclude template="/common_files/jQuery.cfm">
  *
  * ====================================================================================================
--->
<cfparam name="request.multiselect_version" default="3">

<cfif request.multiselect_version is "3">
	<cfoutput>
        <cf_include files="#arrayToList(
                        [    
                              '/script/javascript/jquery-ui-1.12.1.custom/jquery-ui.min.js'
                            , '/script/javascript/multiselect/3.0/jquery.multiselect.js'
                            , '/script/javascript/multiselect/3.0/jquery.multiselect.css'
                            , '/script/javascript/multiselect/3.0/jquery.multiselect.filter.js'
                            , '/script/javascript/multiselect/3.0/jquery.multiselect.filter.css'
                            , '/script/javascript/jquery-ui-1.12.1.custom/jquery-ui.min.css'
                        ] 
                        )#">
                        
        <style>
            /* move checkboxes down to line up with text */
            input[type=checkbox][name^="multiselect"] {
                position: relative;
                top: 3px;
            }
        </style>

        <script>
            // global variable, shared with parent code
            if (typeof config == 'undefined')
                config = {};

            // global default settings, override them in the parent code please do NOT change them here
            config.multiselect = { autoOpen: false
                                    , header: ['checkAll', 'uncheckAll']
                                    , linkInfo: {
                                            checkAll: { text: "select all", title: "Check all boxes" }
                                            ,uncheckAll: { text: "clear all", title: "Un-check all boxes" }
                                        }
                                    , noneSelectedText: "Select options"
                                    , selectedList: 5 
                                };

            // global default filter settings, override them in the parent code                    
            config.multiselectfilter = { label: "Find"
                                            , placeholder: ""
                                            , width: "160px" 
                                        };
        </script>
    </cfoutput>
</cfif>

<cfsetting enableCFoutputOnly = "no">
