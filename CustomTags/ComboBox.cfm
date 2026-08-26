<!-- Check to see that required attribute NAME is present, and that displaylist and valueslist have the same number of elements. -->

<CFIF #ParameterExists(Attributes.NAME)#>
<CFELSE>
	<P><B>ERROR!  CF_ComboBox requires the attribute NAME.  NAME determines the INPUT and SELECT element names in the HTML form.</B></P>
	<CFSET ERROR = 1>
</CFIF>

<CFIF #ListLen(Attributes.valuelist)# IS NOT #ListLen(Attributes.displaylist)#>
	<P><B>ERROR!  CF_ComboBox requires The display list an the value list must have the same number of members in order to correctly build an HTML select box.</B></P>
	<CFSET ERROR = 1>
</CFIF>

<CFIF #ParameterExists(ERROR)#><P>Please check the calling template.</P><CFABORT></CFIF>

<!-- Determine which javascript method is needed -->
<CFIF #ParameterExists(attributes.method)#>
	<CFSET tempmethod = ' on' & #attributes.method#>
<CFELSE>
	<CFSET tempmethod = ' onChange'>
</CFIF>

<!-- Check to see if user entered a custom message for the empty state in the drop-down list.  If not, use the default specified here. -->

<CFIF #ParameterExists(Attributes.emptymsg)#>
	<CFSET temptymsg = #Attributes.emptymsg#>
<CFELSE>
	<CFSET temptymsg = "Type in a new value or select one from this list.">
</CFIF>

<!-- Check to see if the user entered a custom size for the text box.  If not, use the default specified here. -->

<CFIF #ParameterExists(Attributes.size)#>
	<CFSET tempsize = #Attributes.size#>
<CFELSE>
	<CFSET tempsize = 20>
</CFIF>

<!-- Name the elements in the form according to the name attribute. -->
<CFSET textbox = "new" & #Attributes.name#>
<CFSET listbox = "old" & #Attributes.name#>


<CFOUTPUT>




	<!--The TextBox-->
	<INPUT TYPE = "text" NAME ="#textbox#" <CFIF #ParameterExists(Attributes.SIZE)#> SIZE = #Attributes.size#</CFIF><CFIF #ParameterExists(Attributes.maxlength)#> MAXLENGTH = #Attributes.maxlength#</CFIF> #tempmethod# = "#listbox#.options[0].selected=true">

	<!--The Select Element-->
	<SELECT NAME = "#listbox#" SIZE = "1" SINGLE onChange = "#textbox#.value=#listbox#.value">
	
</CFOUTPUT>

<CFIF #ParameterExists(Attributes.compareto)#>
	<OPTION VALUE = ""><CFOUTPUT>#temptymsg#</CFOUTPUT>
	<CFLOOP FROM = "1" TO = #ListLen(Attributes.valuelist)# INDEX = "theLoop">
		<CFOUTPUT><OPTION VALUE = #ListGetAt(Attributes.valuelist,
theLoop)#</CFOUTPUT><CFIF #ListGetAt(Attributes.valuelist, theLoop)# IS
#Attributes.compareto#> SELECTED</CFIF>><CFOUTPUT>#ListGetAt(Attributes.displaylist,
theLoop)#</CFOUTPUT>
	</CFLOOP>
<CFELSE>
	<OPTION VALUE = "" SELECTED><CFOUTPUT>#temptymsg#</CFOUTPUT>
	<CFLOOP FROM = 1 TO = #ListLen(Attributes.valuelist)#  INDEX = "theLoop">
		<CFOUTPUT><OPTION VALUE = #ListGetAt(Attributes.valuelist,
theLoop)#>#ListGetAt(Attributes.displaylist, theLoop)#</CFOUTPUT>
	</CFLOOP>
</CFIF>
</SELECT>
