<!--- 
Custom tag: CF_TEXTAREAFORMAT
By: Charles Arehart, FigLeaf Software, carehart@figleaf.com, 202 797 5435
Created: 2/7/99

Purpose: An enhancement over the features offered by the CF function, paragraphformat. Whereas that function converts double carriage returns in a given string to a <p> tag, it does not convert a single carriage return to a <br>, nor does it convert multiple consecutive spaces to non-breaking spaces (&nbsp;), nor does it convert TAB characters into some fixed number of non-breaking spaces. As such, it does not entirely represent an approximation of what a user types into a a form's TEXTAREA input field.

This function does all three.

Eventually, it will be parameter driven to allow passing in whether to do any or all of these, as well as passing in the number of consecutive spaces to convert, and the number of spaces to use for a converted tab.

FORMAT:
<CF_TEXTAREAFORMAT INPUT="#inputval#" [OUTPUT="outputvar"]>

VARIABLES:
INPUT - required, name of the calling template variable holding the value to be converted. Note that it must be enclosed in pound signs to actually pass a value of the given variable to the custom tag. 
OUTPUT - optional, name of the calling template variable to hold the value once converted. If none is specified, the output is sent to a variable called "htmlformatted_string". 

DEFAULTS:
INPUT - null string. In no input variable is provided, a null result will be returned in the output variable.
OUTPUT - a variable called "htmlformatted_string"

USAGE EXAMPLE:
If you had a form prompting a user for a "Description" field as an INPUT TYPE=TEXTAREA, you could reflect the user's input in the form's ACTION page by calling this tag and displaying their input using CFOUTPUT.

Assuming you called this code from a form with a "description" field, you would use the following:
<CF_TEXTAREAFORMAT INPUT="#form.description#">
<CFOUTPUT>#htmlformatted_string#</CFOUTPUT>

If you have any questions, please send them to carehart@fgleaf.com.

--->





<cfparam name="attributes.input" default="">
<cfparam name="attributes.output" default="htmlformatted_string">
<cfset temp = attributes.input>
<cfset temp = replace(temp,chr(13)&chr(10)&chr(13)&chr(10),"<p>","all")>
<cfset temp = replace(temp,chr(13)&chr(10),"<br>","all")>
<cfset temp = replace(temp,chr(32)&chr(32)&chr(32),"&nbsp;&nbsp;&nbsp;","all")>
<cfset temp = replace(temp,chr(9),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","all")>

<cfset x = setvariable("caller."&attributes.output,temp)>


<!--- 

<cfparam name="attributes.input" default="">
<cfparam name="attributes.output" default="htmlformatted_string">
<cfset temp = attributes.input>
<cfset temp = replace(temp,chr(13)&chr(10)&chr(13)&chr(10),"<p>","all")>
<cfset temp = replace(temp,chr(13)&chr(10),"<br>","all")>
<cfset temp = replace(temp,chr(32)&chr(32)&chr(32),"&nbsp;&nbsp;&nbsp;","all")>
<cfset temp = replace(temp,chr(9),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","all")>

<cfset x = setvariable("caller."&attributes.output,temp)>
 --->