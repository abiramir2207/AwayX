<!--- 
Custom Tag: cf_changecase
Version: 1.0
Date: July 24 2001
Author: Rizal Firmansyah (rizal.firmansyah@kindara.com)
Disclaimer: 
I, in no way, shape, or form, guarantee this tag. Use it at your own risk :)
This tag may be used by anyone for any purpose, all or in part,
as long as you keep any header in changecase.cfm
If you have any question please let me know.  

-------------------------------------------------------------------------------

Cf_changecase is a custom tag to format case (ie capitalize, lowercase, etc)
	
Usage:
  <cf_changecase case="formatcase" string="string to format" result="YourVar">
  to return the result into YourVar variable.
or simply
  <cf_changecase case="formatcase" string="string to format">
  to directly output the result
  
input attributes:
text = "sentencecase|titlecase|lowercase|uppercase" (mandatory)
string = "string to format" (mandatory)
result = name of variables in calling page that will hold the result

example:
1. <cf_changecase case="sentencecase" string=" the first try of change case " result="MyStr">
   Mystr will then contains: "The first try of change case"
   Try outputting the variables in caller script: <cfoutput>#MyStr#</cfoutput>
   
2. <cf_changecase case="titlecase" string="rIZal firMansyah">
   Output: Rizal Firmansyah

-------------------------------------------------------------------------------

Hope you find this tag useful.

Regards,
Rizal Firmansyah
 --->

<!--- 
changecase.cfm
cf_changecase is a simple custom tag to format case in given string.
(c) 2001, Rizal Firmansyah, rizal.firmansyah@kindara.com

Input var:
* case (mandatory)
	possible inputs are 
			- sentencecase: Sentence case (default)
			- titlecase: Title Case
			- lowercase: lowercase
			- uppercase: UPPER CASE
* string (mandatory)
	input string to format
* result
	TRIMMED string result
	don't use this attribute if you want to directly output the resulting string

example: 
<cf_changecase case="sentencecase" string="format this string" result="MyVar">
<cfoutput>#MyVar#</cfoutput>

or

<cf_changecase case="titlecase" string="format this string">
--->

<cfsetting enablecfoutputonly="no">
	
<cfparam name="Attributes.case" default="sentencecase">
<cfparam name="Attributes.string" default="">
<cfparam name="Attributes.result" default="">
<cfset ResultVar=Attributes.result>

<cfset strTemp=trim(Attributes.string)>
<cfswitch expression="#Attributes.case#">
	<cfcase value="sentencecase">
		<cfset strTemp=lcase(strTemp)>
		<cfset strTemp=ucase(left(strTemp,1)) & right(strTemp,len(strTemp)-1)>
	</cfcase>
	<cfcase value="titlecase">
		<cfset strTemp2="">
		<cfloop list="#strTemp#" index="currWord" delimiters=" ">
			<cfset strTemp2=strTemp2 & " " & ucase(left(currWord,1)) & right(currWord,len(currWord)-1)>
		</cfloop>
		<cfset strTemp=trim(strTemp2)>
	</cfcase>
	<cfcase value="lowercase">
		<cfset strTemp=lcase(strTemp)>
	</cfcase>
	<cfcase value="uppercase">
		<cfset strTemp=ucase(strTemp)>
	</cfcase>
</cfswitch>

<cfif ResultVar is "">
	<cfoutput>#strTemp#</cfoutput>
<cfelse>
	<cfset "caller.#ResultVar#"=strTemp>
</cfif>

<cfsetting enablecfoutputonly="no">
