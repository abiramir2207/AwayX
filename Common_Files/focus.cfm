<cfprocessingdirective suppressWhitespace="true">
<!---------------------------------------------------------------------------------------------------------------------
			Template:  \Common_Files\focus.cfm
					Date:  2015 Sep 18
				Author:  Chris Nguyen
			 Purpose:  Apply special style for focused element on the page

			 Remarks:  Include this template right before the ending </html> tag
						Our Application.cfc inserts the same code onto the page, but it places the code BELOW the </html> tag!

		 Parameter:  none
----------------------------------------------------------------------------------------------------------------------->
<cf_include files="/script/javascript/focus.js">
<!--- set up variable to avoid Application.cfc inserting this same logic onto the page --->
<cfset request.focusHiLightOff = true>
</cfprocessingdirective>