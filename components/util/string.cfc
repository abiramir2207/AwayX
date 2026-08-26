<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\string.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all string manipulation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="String" output="false" hint="This has user defined functions for string manipulation.">

	<cffunction name="Init" access="public" returntype="any" output="false">
		<cfargument name="Library" type="any" required="true" />

		<cfscript>
			// The library variable is a reference to the main UDF library. This is
			// going to be used to reference other parts of the library that are not
			// in this specific component.
			variables.Library = arguments.Library;
			return( this );
		</cfscript>
	</cffunction>


	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="listDeDuplicates" access="public" returntype="string" output="false">
		<cfargument name="input" type="string" required="true">
		<!---
		    Create an look up index. This is a struct whose only
		    purpose is to provide a fast key-lookup for existing values.
		--->
		<cfset local.objExistingKeys = {} />

		<!---
		    We are going to create a new array to hold our "new" list
		    values. This will be our ordered copy of the list with only
		    unique values.
		--->
		<cfset local.arrNewList = [] />

		<!---
		    Now, let's loop over the existing list and build our new
		    list IN ORDER with only unique values.
		--->
		<cfloop index="local.strItem" list="#arguments.input#" delimiters=",">
		    <!--- Check to see if this item has been used already. --->
		    <cfif NOT StructKeyExists( local.objExistingKeys, local.strItem )>
		        <!---
		            This list item is not a key in our look up index
		            which means that it has NOT been used in our new
		            list yet. Let's add it to our new list array.
		        --->
		        <cfset ArrayAppend( local.arrNewList, local.strItem ) />
		        <!---
		            Add the item to our look up index so that we don't
		            use it again on further loop iterations.
		        --->
		        <cfset local.objExistingKeys[ local.strItem ] = true />
		    </cfif>
		</cfloop>

		<!---
		    Now that we have copied over all the unique values in
		    order to our new list, let's collaps the array down into
		    a string list.
		--->
		<cfreturn arrayToList( local.arrNewList ) />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
	/**
	 * Removes HTML from the string.
	 * v2 - Mod by Steve Bryant to find trailing, half done HTML.
	 * v4 mod by James Moberg - empties out script/style blocks
	 *
	 * @param string      String to be modified. (Required)
	 * @return Returns a string.
	 * @author Raymond Camden (ray@camdenfamily.com)
	 * @version 4, October 4, 2010
	 */
	function stripHTML(str) {
	    str = reReplaceNoCase(str, "<*style.*?>(.*?)</style>","","all");
	    str = reReplaceNoCase(str, "<*script.*?>(.*?)</script>","","all");

	    str = reReplaceNoCase(str, "<.*?>","","all");
	    //get partial html in front
	    str = reReplaceNoCase(str, "^.*?>","");
	    //get partial html at end
	    str = reReplaceNoCase(str, "<.*$","");
	    return trim(str);
	}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="linkFormat" access="public" returntype="string" output="false" hint="Format link with jquery ui icon">
		<cfargument name="action" type="string" required="true" />
		<cfargument name="class"  type="string" required="false" default="" hint="this argument controls the overall style of the action link"/>
		<cfargument name="icon"   type="string" required="false" default="" hint="jquery ui icon name to be used with the link"/>

		<cfscript>
			// determine the jquery ui icon to be used based on action argument
			     if (arguments.action contains "deactivate") local.icon = "ui-icon-minusthick";
			else if (arguments.action contains "activate")   local.icon = "ui-icon-power";
			else if (arguments.action contains "add")        local.icon = "ui-icon-plus";
			else if (arguments.action contains "alias")      local.icon = "fas fa-exchange-alt";            // font awesome classes
			else if (arguments.action contains "apply")      local.icon = "ui-icon-check";
			else if (arguments.action contains "approve")    local.icon = "ui-icon-check";
			else if (arguments.action contains "assign")     local.icon = "ui-icon-grip-solid-horizontal";
			else if (arguments.action contains "browse")     local.icon = "ui-icon-folder-open";
			else if (arguments.action contains "cancel")     local.icon = "ui-icon-close";
			else if (arguments.action contains "close")      local.icon = "ui-icon-close";
			else if (arguments.action contains "create")     local.icon = "ui-icon-newwin";
			else if (arguments.action contains "copy")       local.icon = "ui-icon-copy";
			else if (arguments.action contains "deselect")   local.icon = "ui-icon-close";
			else if (arguments.action contains "edit")       local.icon = "ui-icon-pencil";
			else if (arguments.action contains "email")      local.icon = "ui-icon-mail-closed";
			else if (arguments.action contains "export")     local.icon = "ui-icon-arrowthickstop-1-s";
			else if (arguments.action contains "find")       local.icon = "ui-icon-search";
			else if (arguments.action contains "delete")     local.icon = "ui-icon-trash";
			else if (arguments.action contains "detail")     local.icon = "ui-icon-lightbulb";
			else if (arguments.action contains "disagree")   local.icon = "ui-icon-cancel";
			else if (arguments.action contains "download")   local.icon = "ui-icon-arrowstop-1-s";
			else if (arguments.action contains "hide")       local.icon = "ui-icon-carat-1-n";
			else if (arguments.action contains "home")       local.icon = "ui-icon-home";
			else if (arguments.action contains "legend")     local.icon = "ui-icon-flag";
			else if (arguments.action contains "import all") local.icon = "ui-icon-circle-plus";
			else if (arguments.action contains "import")     local.icon = "ui-icon-arrowthickstop-1-n";
			else if (arguments.action contains "options")    local.icon = "ui-icon-gear";
			else if (arguments.action contains "print")      local.icon = "ui-icon-print";
			else if (arguments.action contains "reset")      local.icon = "ui-icon-arrowreturnthick-1-w";
			else if (arguments.action contains "refresh")    local.icon = "ui-icon-refresh";
			else if (arguments.action contains "remove")     local.icon = "ui-icon-scissors";
			else if (arguments.action contains "restore")    local.icon = "ui-icon-arrowrefresh-1-e";
			else if (arguments.action contains "return")     local.icon = "ui-icon-arrowreturnthick";
			else if (arguments.action contains "rfa")        local.icon = "ui-icon-circle-check";
			else if (arguments.action contains "save")       local.icon = "ui-icon-disk";
			else if (arguments.action contains "select")     local.icon = "ui-icon-check";
			else if (arguments.action contains "setting")    local.icon = "ui-icon-gear";
			else if (arguments.action contains "search")     local.icon = "ui-icon-search";
			else if (arguments.action contains "show")       local.icon = "ui-icon-carat-1-s";
			else if (arguments.action contains "spread")     local.icon = "ui-icon-transferthick-e-w";
			else if (arguments.action contains "update")     local.icon = "ui-icon-pencil";
			else if (arguments.action contains "upload")     local.icon = "ui-icon-arrowstop-1-n";
			else if (arguments.action contains "view")       local.icon = "ui-icon-play";
			else if (arguments.action contains "back")       local.icon = "ui-icon-arrowreturn-1-w";
			
			else                                             local.icon = "";

			return "<b" & (arguments.class eq "" 
								? "" 
								: " class='#arguments.class#'")
						& ">"
						& "<i class='k86'>[</i> "
		    			& (arguments.icon neq "" 
		    					? "<i class='ui-icon " & arguments.icon & "'></i>" 
		    					: (local.icon eq "" 
		    							? "" 
                                        : local.icon contains "ui-icon"
                                            ? "<i class='ui-icon #local.icon#'></i>"        // jquery ui icon library
                                            : "<i class='#local.icon#'></i>"                // other icon libraries (e.g. font awesome)
                                            )
                            )
						& " " & arguments.action
						& " <i class='k86'>]</i></b>";
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="actionLinkFormat2" access="public" returntype="string" output="false" hint="Optimized version without using the font tags">
		<cfargument name="action" type="string" required="true" />
		<cfargument name="class" type="string" required="false" default="" hint="this argument controls the overall style of the action link"/>

		<cfscript>
			if (arguments.class eq "important") {
				return "<b><i class='k86'>[</i> <u>" & arguments.action & "</u> <i class='k86'>]</i></b>";
			}
			else if (arguments.class eq "") {
				return "<b><i class='k86'>[</i> " & arguments.action & " <i class='k86'>]</i></b>";
			}
			else {
				return "<b class='#arguments.class#'><i class='k86'>[</i> " & arguments.action & " <i class='k86'>]</i></b>";
			}
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="actionLinkFormat" access="public" returntype="string" output="false">
		<cfargument name="action" type="string" required="true" />
		<cfargument name="secondary" type="boolean" required="false" default="false" hint="send true if this action is for cancel, reset, go back"/>
		<cfargument name="style" type="string" required="false" default="classic"/>

		<cfscript>
			switch (arguments.style) {
				case "classic":
				  // different visual for secondary action
				  if ( arguments.secondary ) {
					  return "<b>" & arguments.action & "</b>"; break;
					}
				  else {
				    // stand-out visual for primary action
					  return "<b><font color='red'>[ </font>" & arguments.action & " <font color='red'> ]</font></b>"; break;
					}
				default:
					return arguments.action;
			}
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="ParseHTMLTag" access="public" returntype="struct" output="false" hint="Parses the given HTML tag into a ColdFusion struct.">
		<cfargument name="HTML" type="string" required="true" hint="The raw HTML for the tag." />
		<cfset var LOCAL = StructNew() />
		<!--- Create a structure for the taget tag data. --->
		<cfset LOCAL.Tag = StructNew() />
		<cfset LOCAL.Tag.HTML = ARGUMENTS.HTML />
		<cfset LOCAL.Tag.Name = "" />
		<cfset LOCAL.Tag.Attributes = StructNew() />
		<!---
			Create a pattern to find the tag name. While it might seem overkill to create a pattern just to
			find the name, I find it easier than dealing with token / list delimiters.
		--->
		<cfset LOCAL.NamePattern = CreateObject("java","java.util.regex.Pattern").Compile("^<(\w+)")/>

		<!--- Get the matcher for this pattern. --->
		<cfset LOCAL.NameMatcher = LOCAL.NamePattern.Matcher(ARGUMENTS.HTML) />

		<!---
			Check to see if we found the tag. We know there can only be ONE tag name, so using an IF statement
			rather than a conditional loop will help save us processing time.
		--->
		<cfif LOCAL.NameMatcher.Find()>

			<!--- Store the tag name in all upper case. --->
			<cfset LOCAL.Tag.Name = UCase(
				LOCAL.NameMatcher.Group( 1 )
				) />

		</cfif>
		<!---
			Now that we have a tag name, let's find the attributes of the tag. Remember, attributes may
			or may not have quotes around their values. Also, some attributes (while not XHTML compliant) might
			not even have a value associated with it (ex. disabled, readonly).
		--->
		<cfset LOCAL.AttributePattern = CreateObject("java","java.util.regex.Pattern").Compile("\s+(\w+)(?:\s*=\s*(""[^""]*""|[^\s>]*))?")/>

		<!--- Get the matcher for the attribute pattern. --->
		<cfset LOCAL.AttributeMatcher = LOCAL.AttributePattern.Matcher(ARGUMENTS.HTML) />
		<!---
			Keep looping over the attributes while we
			have more to match.
		--->
		<cfloop condition="LOCAL.AttributeMatcher.Find()">
			<!--- Grab the attribute name. --->
			<cfset LOCAL.Name = LOCAL.AttributeMatcher.Group( 1 ) />
			<!---
				Create an entry for the attribute in our attributes structure. By default, just set it the empty string.
				For attributes that do not have a name, we are just going to have to store this empty string.
			--->
			<cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = "" />

			<!---
				Get the attribute value. Save this into a scoped variable because this might return a NULL value
				(if the group in our name-value pattern failed to match).
			--->
			<cfset LOCAL.Value = LOCAL.AttributeMatcher.Group( 2 ) />
			<!---
				Check to see if we still have the value. If the
				group failed to match then the above would hav returned NULL and destroyed our variable.
			--->
			<cfif StructKeyExists( LOCAL, "Value" )>
				<!---
					We found the attribute. Now, just remove any leading or trailing quotes. This way, our values
					will be consistent if the tag used quoted or non-quoted attributes.
				--->
				<cfset LOCAL.Value = LOCAL.Value.ReplaceAll("^""|""$","") />
				<!---
					Store the value into the attribute entry back
					into our attributes structure (overwriting the
					default empty string).
				--->
				<cfset LOCAL.Tag.Attributes[ LOCAL.Name ] = LOCAL.Value />
			</cfif>
		</cfloop>


		<!--- Return the tag. --->
		<cfreturn LOCAL.Tag />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
	/**
	 * An enhanced version of left() that doesn't cut words off in the middle.
	 * Minor edits by Rob Brooks-Bilson (rbils@amkor.com) and Raymond Camden (rbils@amkor.comray@camdenfamily.com)
	 *
	 * Updates for version 2 include fixes where count was very short, and when count+1 was a space. Done by RCamden.
	 *
	 * @param str      String to be checked.
	 * @param count      Number of characters from the left to return.
	 * @return Returns a string.
	 * @author Marc Esher (rbils@amkor.comray@camdenfamily.comjonnycattt@aol.com)
	 * @version 2, April 16, 2002
	 */
	function fullLeft(str, count) {
	    if (not refind("[[:space:]]", str) or (count gte len(str)))
	        return Left(str, count);
	    else if(reFind("[[:space:]]",mid(str,count+1,1))) {
	          return left(str,count);
	    } else {
	        if(count-refind("[[:space:]]", reverse(mid(str,1,count)))) return Left(str, (count-refind("[[:space:]]", reverse(mid(str,1,count)))));
	        else return(left(str,1));
	    }
	}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
	/**
	 * Returns a string with words capitalized for a title.
	 * Modified by Ray Camden to include var statements.
	 * Modified by James Moberg to use structs, added more words, and reset-to-all-caps list.
	 *
	 * @param initText 	 String to be modified. (Required)
	 * @return Returns a string.
	 * @author Ed Hodder (&#101;&#100;&#46;&#104;&#111;&#100;&#100;&#101;&#114;&#64;&#98;&#111;&#119;&#110;&#101;&#46;&#99;&#111;&#109;)
	 * @version 3, October 7, 2011
	 */
	function capFirstTitle(initText){
	       var j = 1; var m = 1;
	       var doCap = true;
	       var tempVar = "";
	       /* Make each word in text an array variable */
	       var Words = ListToArray(LCase(trim(initText)), " ");
	       var excludeWords = structNew();
	       var ResetToALLCAPS = structNew();
	       /* Words to never capitalize */
	       tempVar =  ListToArray("a,above,after,ain't,among,an,and,as,at,below,but,by,can't,don't,for,from,from,if,in,into,it's,nor,of,off,on,on,onto,or,over,since,the,to,under,until,up,with,won't");
	       for(j=1; j LTE (ArrayLen(tempVar)); j = j+1){
	               excludeWords[tempVar[j]] = 0;
	       }
	       /* Words to always capitalize */
	       tempVar = ListToArray("II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,XVII,XVIII,XIX,XX,XXI");
	       for(j=1; j LTE (ArrayLen(tempVar)); j = j+1){
	               ResetToALLCAPS[tempVar[j]] = 0;
	       }
	       /* Check words against exclude list */
	       for(j=1; j LTE (ArrayLen(Words)); j = j+1){
	               doCap = true;
	               /* Word must be less than four characters to be in the list of excluded words */
	               if(LEN(Words[j]) LT 4){
	                       if(structKeyExists(excludeWords,Words[j])){ doCap = false; }
	               }
	               /* Capitalize hyphenated words */
	               if(ListLen(trim(Words[j]),"-") GT 1){
	                       for(m=2; m LTE ListLen(Words[j], "-"); m=m+1){
	                               tempVar = ListGetAt(Words[j], m, "-");
	                               tempVar = UCase(Mid(tempVar,1, 1)) & Mid(tempVar,2, LEN(tempVar)-1);
	                               Words[j] = ListSetAt(Words[j], m, tempVar, "-");
	                       }
	               }
	               /* Automatically capitalize first and last words */
	               if(j eq 1 or j eq ArrayLen(Words)){ doCap = true; }
	               /* Capitalize qualifying words */
	               if(doCap){ Words[j] = UCase(Mid(Words[j],1, 1)) & Mid(Words[j],2, LEN(Words[j])-1); }
	               if (structKeyExists(ResetToALLCAPS, Words[j])) Words[j] = ucase(Words[j]);
	       }
	       return ArrayToList(Words, " ");
	}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="isGUID" access="public" returntype="boolean" output="false" hint="returns true if is a valid GUID.">
	  <cfargument name="str" required="true" type="string">
	   
	  <!---
	  Returns true for a valid GUID (a UUID in the Microsoft form).
	  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (8-4-4-4-12)
	  --->
	  <cfreturn REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$", arguments.str) />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="parseEmailAddresses" access="public" returntype="array" output="false" hint="returns an array of valid email addresses with extra stuffs removed">
	  <cfargument name="str" required="true" type="string">
	  <!---
	  Example:  input = "some garbae@.ca garbage@ca.a real@email.com another@garbage whatever another@email.com oh my!"
	  					output = array of 2 elements:
	  											array[1] = "real@gmail.com"
												array[2] = "another@email.com"

  				input = "cnguyen@gmail.com,Joshua.O'Brien@kraftfoods.com";
	  					output = array of 2 elements:
	  											array[1] = "cnguyen@gmail.com"
												array[2] = "Joshua.O'Brien@kraftfoods.com"
	  --->
		<cfscript>
			var email   = "(['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.((aero|coop|info|museum|name|jobs|travel)|([a-z]{2,3})))";
			var res     = "";
			var marker  = 1;
			var matches = "";

		    matches = reFindNoCase(email, arguments.str, marker, marker);

		    while(matches.len[1] gt 0) {
				res     = listAppend(res, mid(str, matches.pos[1], matches.len[1]));
				marker  = matches.pos[1] + matches.len[1];
				matches = reFindNoCase(email, str, marker, marker);
		    }

		    return listToArray(res);
		</cfscript>   
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="compress" access="public" returntype="string" output="false" hint="compress a string, replace multiple white spaces, carriage returns, line feeds, tabs with a single blank space">
	  <cfargument name="str" required="true" type="string">

	  <cfreturn reReplace(arguments.str, "\s{2,}|#chr(13)#|#chr(9)#|\n|\r", " ", "ALL" )/>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="wrapText" hint="Break a long string into multiple lines">
	  <cfargument name="inputText" type="string" required="true">
	  <cfargument name="minimumNumberOfCharsPerLine" type="numeric" required="false" default="20">
	  <cfargument name="numberOfLines" type="numeric" required="false" default="2">

	  <!--- break input string into at least 2 lines
	        , allow minimum of 20 chars on each line
	        , replace carriage returns inserted by the wrap function with br tags --->
	  <cfreturn replace( wrap( arguments.inputText
	                          ,max(arguments.minimumNumberOfCharsPerLine, len(arguments.inputText) / arguments.numberOfLines) )
	                     , chr(13)
	                     , "<br>"
	                     , "all")>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="cellFormat" output="true" hint="Format a numeric value, when the value is negative wrap it inside a span tag with a negative class">
	  <cfargument name="value" required="true">
	  <cfargument name="category" required="false" default="dollar">
	  <cfargument name="decimalplaces" required="false" default="">
	  <cfscript>
	    // ignore non-numeric value and blank value
	    if ( ( not isNumeric(arguments.value) ) || ( trim(arguments.value) eq "" ) ) {
	      return arguments.value;
	    }

	    // determine if negative class is needed
	    local.class = (arguments.value < 0 ? "neg" : "");

	    // apply friendly formatting
	    if (arguments.category eq "dollar") {
	      local.value = numberFormat(arguments.value, "($9,.____");
	    }
	    else if (arguments.category eq "dollar2") {
	      local.value = numberFormat(arguments.value, "($9,");
	    }
	    else if (arguments.category eq "dollar3") {
	      local.value = dollarFormat(arguments.value);
	     }
	    else if (arguments.category eq "percent") {
	      local.value = numberFormat(arguments.value, "-,_") & " %";
	    }
	    else if (arguments.category eq "percent2") {
	      local.value = numberFormat(arguments.value, "-,_._") & "%";
	    }
		else if (arguments.category eq "percent3") {
	      local.value = numberFormat(arguments.value, "(_,____)") & "%";
	    }
	    else if (arguments.category eq "deci") {
	      local.value = numberFormat(arguments.value, "(,_._)");
	    }
	    else {
	      local.value = numberFormat(arguments.value, "(,_)");
	    }

	    // apply decimal formatting
	    if (len(arguments.decimalplaces)) {
	    	 local.value = numberFormat(arguments.value, arguments.decimalplaces);
	    }
	    
	    // wrap formatted value with negative span tag if needed
	    return   (local.class eq "" ? "" : "<span class=#local.class#>")
	           &  local.value
	           & (local.class eq "" ? "" : "</span>");
	  </cfscript>

	</cffunction>  <!--- name="cellFormat" --->

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="GoogleTranslate" output="true" hint="Translate content into specified language using Google paid translation service">
	  <cfargument name="content" required="true">
	  <cfargument name="target"  required="true">
	  <cfargument name="source"  required="false" default="en">

		<cfhttp url="https://www.googleapis.com/language/translate/v2" method="post" result="local.result" charset="utf-8">
		  <cfhttpparam type="header"     name="X-HTTP-Method-Override"  value="GET">
		  <cfhttpparam type="formfield"  name="key"     value = "AIzaSyDaJOL2-QjUnQWYJdp2C3wstOiH7HADtuE">
		  <cfhttpparam type="formfield"  name="source"  value = "#arguments.source#">
		  <cfhttpparam type="formfield"  name="target"  value = "#arguments.target#">
		  <cfhttpparam type="formfield"  name="q"       value = "#arguments.content#">
		</cfhttp>

			<cfset local.json = DeserializeJSON( local.result.FileContent )>
		<!---<cfset local.json = DeserializeJSON( local.result.FileContent.toString("UTF-8") )>--->
    <cfreturn local.json.data.translations[1].translatedText>
	</cffunction>  <!--- name="cellFormat" --->

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="actionTextGrayedOut" output="false">
  		<cfargument name="caption" required="true">
  		<cfreturn "<b><font color='Gray'>[ " & (arguments.caption) & " ]</font></b>">
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="actionTextGrayedOutSmall" output="false">
  		<cfargument name="caption" required="true">
  		<cfreturn "<b style='font-size: 7pt;'><font color='Gray'>[ " & (arguments.caption) & " ]</font></b>">
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="fCase" output="false">
  		<cfargument name="text" required="true">

  		<cfif len(arguments.text) lt 2>
			<cfreturn uCase(arguments.text)>
		<cfelse>
  			<cfreturn ucase(mid(arguments.text, 1, 1)) & lcase(mid(arguments.text, 2, len(arguments.text) - 1))>
		</cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="csvFormat" returntype="string">
		<cfargument required="true" name="data">

		<!--- remove all commas --->
		<cfset local.data = replace(arguments.data, ',', ' ', 'all')>

		<!--- wrap large numeric value inside a pair of double quotes and prefixed with an equal sign --->
		<cfif !isNumeric(local.data)>
			<cfreturn local.data>
		<cfelseif val(local.data) gt 99999>
			<cfreturn '="' & local.data & '"'>
		<!--- special handling for zero value :: for some reasons 0.00000000 was converted into 0.0E-9 --->
		<cfelseif val(local.data) eq 0>
			<cfreturn '0'>
		<cfelse>
			<cfreturn local.data>
		</cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="splitToArray" output="false"  hint="Convert a long string into an array of smaller strings & avoid breaking words in the middle.">
		<cfargument required="true" name="long_string">
		<cfargument required="false" name="short_string_length" default="50" type="numeric">

		<cfreturn REMatch( ".{1," & arguments.short_string_length & "}(?=([\s\-:]|$))", arguments.long_string )>		
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="replaceQuotes" output="false" hint="Replace single/double quote characters in a given string with HTML code">
		<cfargument required="true" name="given">

		<cfreturn replace( replace( arguments.given, '"', "&quot;", "all" ), "'", "&apos;", "all" )>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="foregroundColor" output="false" hint="Return foreground color based on background color.">
		<cfargument required="true" name="background_color" hint="Background color in hex value.">

		<cfscript>
			try {				
				if ( trim(arguments.background_color) neq "" ) {
					arguments.background_color = replace(arguments.background_color, "##", "", "all");
					// <!--- Get red in decimal format. --->
			        local.intRed = InputBaseN( Mid( arguments.background_color, 1, 2 ), 16 );

		            // <!--- Get green in decimal format. --->
		            local.intGreen = InputBaseN( Mid( arguments.background_color, 3, 2 ), 16 );

		            // <!--- Get blue in decimal format. --->
		            local.intBlue = InputBaseN( Mid( arguments.background_color, 5, 2 ), 16 );

					// this logic was copied from jscolor.js version 2
					return ((0.213 * local.intRed) + (0.715 * local.intGreen) + (0.072 * local.intBlue)) gt ( 255 / 2)
								? "##333"
								: "##FFF";
				}
			}
			catch (any e) {	};
			return "##333";   // dark gray
		</cfscript>

    </cffunction>
    
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="usdFormat" output="false">
        <cfargument name="number" required="true">
        <cfargument name="format" required="true" type="string">

        <cfif isNumeric(arguments.number)>
            <cfreturn arguments.number lt 0
                    ? replace( numberFormat(arguments.number, arguments.format), "(", "($" )
                    : '$' & numberFormat(arguments.number, arguments.format)>
        <cfelse>
            <cfreturn arguments.number>
        </cfif>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="pctFormat" output="false">
        <cfargument name="number" required="true">
        <cfargument name="format" required="true" type="string">

        <cfif isNumeric(arguments.number)>
            <cfreturn arguments.number lt 0
                        ? replace(numberFormat(arguments.number, arguments.format), ")", "%)")
                        : numberFormat(arguments.number, arguments.format) & '%'>
        <cfelse>
            <cfreturn arguments.number>
        </cfif>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="substringCount" output="false" hint="Returns number of substrings inside a given string">
        <cfargument name="string" required="true" type="string">
        <cfargument name="substring" required="true" type="string">
        
            <cfreturn ( len(arguments.string) - len(replace(arguments.string, arguments.substring, '', 'all')) ) / len(arguments.substring)>
    </cffunction>

</cfcomponent>