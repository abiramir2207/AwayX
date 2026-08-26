<!--- 
	CONFIGURATION PARAMS FOR CFX_JSpellCheck
	Company: CFDEV.COM
	Author: Pete Freitag
	Date: 01/01	
 --->

<!--- SEE THE DOCS FOR DETAILS ABOUT THESE ATTRIBUTES --->

<cfset Request.tlx = "c:/cfdev/spellchecker/lex/american.tlx">
<cfset Request.clx = "c:/cfdev/spellchecker/american.clx">
<cfset Request.userdict = "c:/cfdev/spellchecker/lex/userdic.tlx">

<!--- 
	Alternatly you can use the lexdir attribute, and it will append
	/american.clx, /american.tlx, and /userdic.tlx by default to the dir
 --->


<cfset Request.searchdepth = 50>
<!--- 
	The English phonetic comparator uses english language rules to form
	suggestions, it is faster than the typographical comparator, but can 
	only be used on English Dictionaries.
 --->
<cfset Request.englishphonetic = 1>
<cfset Request.striphtml = 1>
<!--- other option is wddx, only change this in your own apps --->
<cfset Request.format = "javascript">
<!--- 
	If the CF Server is only using one set of dictionary files, then it 
	can cache the spell checking object in memory, this provides significant
	performance increases (upwards of 30%).  So if possible keep this 
	attribute set to false
 --->
<cfset Request.multilingual = 0>
<cfset Request.Suggestions = 14>
