
<!--- ----------------------------------------------------------------------------------------- --->
<!--- global settings, variables and functions that need to be accessed everywhere ------------ --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- function to remove decimals from dollar format because dollarformat always shows 2 decimals --->
<cfscript>
	function mydollarformat(money_string){
		money_string = DollarFormat(money_string);
		money_string = rereplaceNoCase(money_string, '\.\d{2}', '');
		return(money_string);
	}
	/*usage is: #mydollarformat(value goes here)# */
</cfscript>
<!--- ----------------------------------------------------------------------------------------- --->




<!--- ----------------------------------------------------------------------------------------- --->
<!--- Capitalizes the first letter in each word ----------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<cffunction name="CapFirst" returntype="string" output="false">
    <cfargument name="str" type="string" required="true" />
    
    <cfset var newstr = "" />
    <cfset var word = "" />
    <cfset var separator = "" />
    
    <cfloop index="word" list="#arguments.str#" delimiters=" ">
        <cfset newstr = newstr & separator & UCase(left(word,1)) />
        <cfif len(word) gt 1>
            <cfset newstr = newstr & lcase(right(word,len(word)-1)) />
        </cfif>
        <cfset separator = " " />
    </cfloop>

    <cfreturn newstr />
</cffunction>

<!--- ----------------------------------------------------------------------------------------- --->



<!--[if gte IE 9]><style type="text/css">.gradient_fix, div.gradient_fix, legend.gradient_fix {filter: none;}</style><![endif]-->




<CFPARAM NAME="content" DEFAULT='nodata.cfm'>
<CFPARAM NAME="logo_image" DEFAULT='ball_blue.png'>

<cfswitch expression="#content#">

    <cfcase value="75718-73349-64488-74924">
		<cfset content="program_search.cfm">
        <cfset page_name = "Search Programs">
	</cfcase>

    <cfcase value="14363-32470-12748-79810">
		<cfset content="program_display_list.cfm">
        <cfset page_name = "Programs">
	</cfcase>

    <cfcase value="52840-22364-22102-87888">
		<cfset content="program_display_details.cfm">
        <cfset page_name = "Programs">
	</cfcase>

    <cfcase value="59613-88929-18962-37888">
		<cfset content="gains_loses.cfm">
        <cfset page_name = "Gains & Loses">
	</cfcase>

    <cfdefaultcase>
		<cfset content="nodata.cfm">
		<cfset page_name="select dashboard">
	</cfdefaultcase>

</cfswitch>