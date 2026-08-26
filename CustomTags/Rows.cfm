<!--- CF_ROWS/CF_RESULTPAGES custom tags
		
What it does:
		The CF_ROWS Custom Tag is especially created for work with CF_ResultPages.
		See in that tag how they work together.
		Althought you can use CF_ROWS tag just for set the StartRow (for CFOUTPUT cases), the EndRow (for CFLOOP cases), and	the maxrows (for either).

Syntax:

CF_ROWS	
		<CF_Rows
		maxrows="number">
	
		MAXROWS
			Optional. Specifies the maxmium number of rows you want displayed
			in the output section. Default is 10.
			
Copy'n'paste:
			<cf_Rows>
			
			<cfoutput query="q" startrow="#StartRow#" maxrows="#MaxRows#"> 

			</cfoutput>
			
			
Copy'n'paste:
			<cf_Rows maxrows="12">
			
			<cfloop query="q" startrow="#StartRow#" endrow="#EndRow#">
			
			</cfloop>
			
Communication: 
			If you have any comment or suggestion for improve the tag,
			even a anecdote, write me at justapp@fruir.net. Thanks on Advance.
			My english's not so good although I intend to do it right.
			Feel free to help me in this way: send me the faults corrected and
			I'll fix. A lot of thanks.
			
Written by: Lluís Casany -  JustApp@fruir.net
			www.fruir.net/web/JustApp - The Lluís Casany's Comp Page
      Date: March 30, 2000
	  
Dedication: I dedicate these customs tags to all authentic'n'good people.

 --->
 <!--CF_ROWS Custom tag
	Lluís Casany
	http://www.fruir.net/web/JustApp -->
<!--- CF_ROWS code --->	
<cfif IsDefined('attributes.maxrows') and NOT IsDefined('caller.maxrows')>
	<cfset caller.maxrows = attributes.maxrows>
</cfif>

<!--- test --->
<cfif IsDefined('caller.maxrows_old')>
	<cfif caller.maxrows is not caller.maxrows_old>
	<cfset page_on = Int(StartRow/maxrows)>
	<cfset caller.StartRow = maxrows*page_on + 1>
		<!--- falta actualitzar el frompage --->
		<cfset caller.frompage_set = "x">
	</cfif>
</cfif>

<cfif NOT IsDefined('caller.maxrows')>
	<cfset caller.maxrows = 10>
</cfif>

<cfparam name="caller.StartRow" default="1">

<cfset caller.endrow = caller.maxrows + caller.StartRow - 1>


<!-- /end CF_ROWS -->