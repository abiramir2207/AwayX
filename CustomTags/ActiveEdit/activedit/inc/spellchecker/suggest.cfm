<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>suggest spelling</title>
<script>
function spell() {
//CFX_JSpellCheck Output
<CFX_JSpellCheck
	searchdepth="#Request.searchdepth#" 
	clx="#Request.clx#" 
	tlx="#Request.tlx#" 
	userdict="#Request.userdict#" 
	englishphonetic="#Request.englishphonetic#" 
	format="#Request.format#"  
	suggestions="#Request.suggestions#"
	multilingual="#Request.multilingual#"
	striphtml="#Request.striphtml#"
	action="check" 
	words="#word#">
//CFX_JSpellCheck
	if (typeof(suggestions) == "undefined") { 
		var suggestions = new Array();
		suggestions[0] = new Array();
	}
	<cfoutput>
	parent.topframe.doSuggest("#word#", numMispelled, suggestions);
	</cfoutput>
}		
</script>
	
</head>

<body onload="spell()">

<font face="verdana" size="-2">
	<span name="viewer" id="viewer">&nbsp;&nbsp;Suggestions for <cfoutput>#word#</cfoutput></span>
</font>


</body>
</html>
