<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \common_files\dhx_message.cfm
          Date: 2017 June   
        Author: Chris Nguyen
       Purpose: Load files that are needed for dhtmlx message
----------------------------------------------------------------------------------------------------------------------->
</cfsilent>

<cf_include files="/script/javascript/dhtmlx/message/codebase/skins/dhtmlxmessage_dhx_terrace.css, /script/javascript/dhtmlx/message/codebase/dhtmlxmessage.js, /script/javascript/dhx_message.js">

<style> 
    /* Override primary button color to use BSA color */
    .dhtmlx_popup_button:first-child {
      background: #406be4;
      border: 1px solid #406be4;
    }
    /* override 300px default to allow longer message - 85971 */
    .dhtmlx_modal_box { 
        width: auto; 
        max-width: 70%;
    }
</style>