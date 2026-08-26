<cfsilent>
    <cfparam NAME="url.display" 					default="view">
    <cfparam NAME="url.CID" 							default="">
    <cfparam NAME="url.Contract_Main_ID"	default="#url.CID#">
    <cfparam name="url.generate" 					default="0">
    <cfparam name="request.language" 			default="">

        <cfquery name="qGetProgramLetterSettings" datasource="#application.datasource#">
        SELECT	pcpo.operator_letters_required, pcpo.distributor_letters_required, pcpo.Label_Set_Default, pcpo.Custom_RFP_Letter
        FROM	Contract_Main cm
                inner join Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
        WHERE 	Contract_Main_ID = '#URL.CID#'
    </cfquery>

    <cfif isDefined("cookie.googtrans") AND listGetAt(cookie.googtrans,2,'/') eq "Fr" 
        AND qGetProgramLetterSettings.Label_Set_Default eq "French">
            <cfset request.language = "french" >
    </cfif>

    <CFINCLUDE TEMPLATE="/get_access_profile.cfm">
    <cfquery name="qGetLetters" datasource="#application.datasource#">
        SELECT	COUNT(Program_Letters_ID) as Letter_Count
        FROM	Program_Letters
        WHERE 	program_id = '#URL.CID#'
    </cfquery>

    <cfif Get_Profile_Settings.Generate_Program_letters AND NOT qGetLetters.Letter_Count>
        <cfset url.display = "edit" />
    </cfif>

    <cfset selectedIndex = 99>
    <cfswitch expression="#url.display#">
        <cfcase value="view">	<cfset selectedIndex = 0> 	</cfcase>
        <cfcase value="edit">	<cfset selectedIndex = 1> 	</cfcase>
    </cfswitch>
</cfsilent>
    

<cfmodule template="/customTags/layout.cfm"
		layoutID = "viewLetters"
		selectedIndex = "#selectedIndex#">

    <style>
        body {
            padding: 5px;
        }
    </style>
    <cfset request.html_started = true>

    <cf_include files="/Script/javascript/format_functions.js, /script/javascript/string_functions.js, /Script/javascript/dom_common.js">

    <!--------------------------------------------------------------------------------------------------------------------->
    <!-------------------------------------------------- Google Translate -------------------------------------------------->
    <!--------------------------------------------------------------------------------------------------------------------->
    
    <style type="text/css"> #google_translate_element {float:left; margin-top:-40px !important; top:-40px !important; display:none;} </style>
    
    <div class="container_16">
        <div class="grid_2 suffix_14">
            <cfif request.AccessStructure.User_Language eq "French" AND qGetProgramLetterSettings.Label_Set_Default eq "French">
                <div id="google_translate_element"></div><br/>
                    <!--- <style type="text/css">body {position: static !important; top:0px !important;}</style> --->
            <script>
                function googleTranslateElementInit() {
                new google.translate.TranslateElement({pageLanguage: 'en', includedLanguages: 'fr,en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
                }
            </script>
            <script src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>	        
        <cfelse>
            &nbsp;
        </cfif>
        </div>
    </div>
    <!--------------------------------------------------------------------------------------------------------------------->
    
    <cfinclude template="include_display_letters.cfm">
        
	<cfoutput>
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

		<!---switch for each action--->
		<cfswitch expression="#url.display#">

			<cfcase value="view">
				<cfinclude template="#includeLettersFilename#" />
			</cfcase>

			<cfcase value="edit">
				<cfinclude template="distributors_custom3.cfm" />
			</cfcase>

		</cfswitch>

	</cfoutput>

</cfmodule>
