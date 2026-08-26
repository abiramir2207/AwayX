<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\programTranslate.cfm
      Date:     2014 December
      Author:   Chris Nguyen
      Purpose:  Google translation for program
----------------------------------------------------------------------------------------------------------------------->
<cfset variables.debug71 = 0>             <!--- TODO: change this value to zero prior to checking into CVS --->
<cfif variables.debug71>
    <cfoutput>
        <cfdump var="#url#">
        <cfdump var="#form#">
    </cfoutput>
</cfif>

<!--- determine current program number based on URL parameters --->
<cfsilent>
<cfif isDefined("url.CID") and len(url.CID)>                          <!--- encrypted program ID --->
    <CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
    <cfset variables.cmid71 = cryp.value>

<cfelseif isDefined("url.program_id") and len(url.program_id)>
    <cfset variables.cmid71 = url.program_id>

<cfelseif isDefined("url.programid") and len(url.programid)>
    <cfset variables.cmid71 = url.programid>

<cfelseif isDefined("url.Contract_Main_ID") and len(url.Contract_Main_ID)>
    <cfset variables.cmid71 = url.Contract_Main_ID>

<cfelseif isDefined("url.prgID") and len(url.prgID)>
    <cfset variables.cmid71 = url.prgID>

<cfelseif isDefined("form.program_id") and len(form.program_id)>
    <cfset variables.cmid71 = form.program_id>

<cfelseif isDefined("url.contract_number") and len(url.contract_number)>
    <cfset variables.cmid71 = url.contract_number>

<cfelse>                                                              <!--- exception scenario: program info not available!!! --->
    <cfset variables.cmid71 = '-999'>
</cfif>


<!--- retrieve program template language setting if it is not yet available or it is for a different program --->
<cfif not isDefined("session.program.contract_main_id")
    or session.program.Contract_Main_ID neq variables.cmid71
    or not isDefined("session.program.label_set_default")>

    <cfquery name="variables.pcpo07" datasource="#application.datasource#">
        SELECT DISTINCT rtrim(ltrim(pcpo.Label_Set_Default)) As Label_Set_Default
          FROM  Contract_Main cm
                INNER JOIN Program_Control_Panel_Options pcpo ON pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
          WHERE  Contract_Main_ID IN(#ListQualify(variables.cmid71, "'", ",")#)
    </cfquery>

    <cfset label_set_default = "">

<!--- If at least one program has "French" ON, set the language to "French". --->
    <cfloop query="variables.pcpo07">
	<cfif variables.pcpo07.Label_Set_Default neq "">
		<cfset label_set_default = variables.pcpo07.Label_Set_Default>
		<cfbreak>
	</cfif>
    </cfloop>

    <cfscript>
        // create program structure only if it does not exist so its existing content remains the same
        if ( not structKeyExists(session, "program")  or not isStruct("session.program") ) {
            session.program = {};
        }
        session.program.Contract_Main_ID  = variables.cmid71;                      // associate to current encrypted program ID
        session.program.label_set_default = label_set_default;    // language setting for current program
    </cfscript>

</cfif>

<!---
<cfscript>
    variables.language07 = ( isDefined("cookie.googtrans") and listlen(cookie.googtrans, '/') gte 2 ? listGetAt(cookie.googtrans, 2, '/') : 'en' );
</cfscript>
--->
</cfsilent>

<cfif variables.debug71>
    <cfoutput>
        <h5>variables.cmid71 = [#variables.cmid71#]<br>
            session.program.Label_Set_Default = [#session.program.Label_Set_Default#]
        </h5>
    </cfoutput>
</cfif>

<cfif isDefined("request.AccessStructure.User_Language") and request.AccessStructure.User_Language eq "French" and session.program.Label_Set_Default eq "French">
    <style type="text/css">
        #google_translate_element {
            display: none;
            float: left;
            margin-top: -40px !important;
            top: -40px !important;
        }
    </style>
    <div id="google_translate_element"></div><br/>
    <script>
        function googleTranslateElementInit() {
          new google.translate.TranslateElement( { pageLanguage: 'en',
                                                    includedLanguages: 'fr,en',
                                                    layout: google.translate.TranslateElement.InlineLayout.SIMPLE }, 'google_translate_element' );
        }
    </script>
    <script src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
</cfif>


