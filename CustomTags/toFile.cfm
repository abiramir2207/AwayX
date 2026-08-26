<!--- cf_toFile
## called to write records to a file
## modifies the defaults of cffile
## mws - 9-3-2004 --->

<cfparam name="attributes.fName" 	default="">
<cfparam name="attributes.nl" 	default="No">
<cfparam name="attributes.action" 	default="Append">
<cfparam name="attributes.data"		default="">

<cffile action="#attributes.action#" file="#attributes.fName#" output="#attributes.data#" addnewline="#attributes.nl#">

