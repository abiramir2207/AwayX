<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
  Template: /Common_Files/tailwind-css.cfm
  Date:     2019 January
  Author:   Chris Nguyen
  Purpose:  Load tailwind.css file, for documentation go to this page below.
				https://confluence.awayx.com/display/PD/Work+Requests
				https://tailwindcss.com/docs/what-is-tailwind/			
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="request.tailwind_version" default="0.7">

<cfoutput><cf_include files="/styles/tailwind/#trim(request.tailwind_version)#/tailwind.min.css"></cfoutput>

<cfsavecontent variable="bsa_custom_styles">
	<style>
		.bg-blue-darkest {
			background-color: #222A97;
        }
        /* add back Chrome button styles due to tailwind-css */
        button {
            -webkit-appearance: button;
            -webkit-writing-mode: horizontal-tb !important;
            text-rendering: auto;
            color: buttontext;
            letter-spacing: normal;
            word-spacing: normal;
            text-transform: none;
            text-indent: 0px;
            text-shadow: none;
            display: inline-block;
            text-align: center;
            align-items: flex-start;
            cursor: default;
            background-color: buttonface;
            box-sizing: border-box;
            margin: 0em;
            padding: 1px 6px;
            border-width: 2px;
            border-style: outset;
            border-color: buttonface;
            border-image: initial;
        }
	</style>
</cfsavecontent>

<cfoutput>#application.util.string.compress( bsa_custom_styles )#</cfoutput>

<cfsetting enableCFoutputOnly = "no">
