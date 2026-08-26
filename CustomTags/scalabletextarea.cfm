
<CFTRY>
	<CFIF NOT thistag.hasendtag>
		<FONT COLOR="RED">cf_scalabletextarea: This tag must have an end tag.</FONT>
		<cfexit>
	</CFIF>
	
<cfif THISTAG.EXECUTIONMODE IS "Start">
	<!--- Set some default values --->
	<cfparam name="Attributes.name" default="textarea">
	<cfparam name="Attributes.cols" default="30">
	<cfparam name="Attributes.rows" default="5">
	<cfparam name="Attributes.incrementLabel" default="<b>&gt;&gt;</b>">
	<cfparam name="Attributes.decrementLabel" default="<b>&lt;&lt;</b>">
	<cfparam name="Attributes.disabled" default="0">

	<cfoutput>
	<!--- The resize only works in IE, so only show the links if it is IE
	otherwise, simply show a plain text area --->
	<cfif find("MSIE", #HTTP_USER_AGENT#, 1)>
			<!--- Decrement Rows--->
			<a href="javascript:;" 
			   onClick="javascript:document.getElementById('#Attributes.name#').cols=#Attributes.cols#;javascript:document.getElementById('#Attributes.name#').rows=#Attributes.rows#;"
			   ondblClick="javascript:document.getElementById('#Attributes.name#').cols=document.getElementById('#Attributes.cols#');javascript:document.getElementById('#Attributes.name#').rows=document.getElementById('#Attributes.rows#');"
			   >#Attributes.decrementLabel#</a>	 
		
			<!--- Increment Rows--->		 
		 	<a href="javascript:;" 
			   onClick="javascript:document.getElementById('#Attributes.name#').cols=document.getElementById('#Attributes.name#').cols+10;javascript:document.getElementById('#Attributes.name#').rows=document.getElementById('#Attributes.name#').rows+5;"
			   ondblClick="javascript:document.getElementById('#Attributes.name#').cols=document.getElementById('#Attributes.name#').cols+10;javascript:document.getElementById('#Attributes.name#').rows=document.getElementById('#Attributes.name#').rows+5;"
			   >#Attributes.incrementLabel#</a>
			<br>
			<!--- Hidden field for storing the changing size (rows) values --->
			<input type="hidden" name="#Attributes.name#_Sizing" value="">
		</cfif>	
	</cfoutput>
<cfelseif THISTAG.EXECUTIONMODE IS "END">
	<cfoutput>
		<!--- Write out the textarea tag --->
		<textarea 
			<!--- loop over and write out the attributes being passed in through the cf_scalabletextarea tag --->
			<cfloop collection="#attributes#" item="i">
				<!--- Don't need to display the label attributes --->
				<CFIF #i# IS NOT "incrementLabel" AND #i# IS NOT "decrementLabel">
				<CFIF i neq "disabled">
				#i#="#attributes[i]#"
				</CFIF>
				</CFIF>
			</cfloop>
			required
			<cfif Attributes.disabled eq 1>DISABLED STYLE="background-color: cccccc"</cfif>
			>#thistag.generatedcontent#</textarea>
	</cfoutput>
	<!--- Set generated content to blank so we don't display it twice --->
	<cfset thistag.generatedcontent = "">
</cfif>

<CFCATCH type="Any">
<FONT COLOR="RED">cf_scalabletextarea: Unknown error in cf_scalabletextarea custom tag.</FONT>
</CFCATCH>	  
</CFTRY>		

	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 
|| BEGIN FUSEDOC ||

Brent V. Ertz
brent@earthnet.net
5/23/2001

|| RESPONSIBILITIES ||

I display a resizeable/scalable textarea form element along with links/buttons to perform the resizing.

|| ATTRIBUTES ||

 [name]: a STRING
 [cols]: an INTEGER
 [rows]: an INTEGER
 [incrementLabel]: a STRING
 [decrementLabel]: a STRING
 [disabled]: a BOOLEAN
 [readonly]: a BOOLEAN
 [wrap]: a STRING (off|soft|hard)
 [dir]: a STRING (rtl|ltr)
 [lang]: a STRING

*All attributes that are passed in through the <cf_scalabletextarea> tag will be returned back out in the <textarea> tag.
ie - <cf_scalabletextarea onClick="alert('Hello')">  will return  <textarea  onClick="alert('Hello')">

|| END FUSEDOC ||



<CFTRY>
	<CFIF NOT thistag.hasendtag>
		<FONT COLOR="RED">cf_scalabletextarea: This tag must have an end tag.</FONT>
		<cfexit>
	</CFIF>
	
<cfif THISTAG.EXECUTIONMODE IS "Start">
	<!--- Set some default values --->
	<cfparam name="Attributes.name" default="textarea">
	<cfparam name="Attributes.cols" default="30">
	<cfparam name="Attributes.rows" default="5">
	<cfparam name="Attributes.incrementLabel" default="<b>&gt;&gt;</b>">
	<cfparam name="Attributes.decrementLabel" default="<b>&lt;&lt;</b>">
	
	<cfoutput>
	<!--- The resize only works in IE, so only show the links if it is IE
	otherwise, simply show a plain text area --->
	<cfif find("MSIE", #HTTP_USER_AGENT#, 1)>
			<!--- Decrement Rows--->
			<a href="javascript:;" 
			   ondblClick="javascript:#Attributes.name#.rows=1;#Attributes.name#_Sizing.value=1;"
			   onClick="javascript:#Attributes.name#.rows=5;#Attributes.name#_Sizing.value=#Attributes.name#.rows;" 
			   >#Attributes.decrementLabel#</a>	 
		
			<!--- Increment Rows--->		 
		 	<a href="javascript:;" 
			   ondblClick="javascript:#Attributes.name#.rows=30;#Attributes.name#_Sizing.value=30;" 
			   onClick="javascript:#Attributes.name#.rows=#Attributes.name#.rows+5;#Attributes.name#_Sizing.value=#Attributes.name#.rows;"
			   >#Attributes.incrementLabel#</a>
			<br>
			<!--- Hidden field for storing the changing size (rows) values --->
			<input type="hidden" name="#Attributes.name#_Sizing" value="">
		</cfif>	
	</cfoutput>
<cfelseif THISTAG.EXECUTIONMODE IS "END">
	<cfoutput>
		<!--- Write out the textarea tag --->
		<textarea 
			<!--- loop over and write out the attributes being passed in through the cf_scalabletextarea tag --->
			<cfloop collection="#attributes#" item="i">
				<!--- Don't need to display the label attributes --->
				<CFIF #i# IS NOT "incrementLabel" AND #i# IS NOT "decrementLabel">
				<CFIF i neq "disabled">
				#i#="#attributes[i]#"
				</CFIF>
				</CFIF>
			</cfloop>
			<cfif Attributes.disabled eq 1>DISABLED  STYLE="background-color: cccccc"</cfif>
			>#thistag.generatedcontent#</textarea>
	</cfoutput>
	<!--- Set generated content to blank so we don't display it twice --->
	<cfset thistag.generatedcontent = "">
</cfif>

<CFCATCH type="Any">
<FONT COLOR="RED">cf_scalabletextarea: Unknown error in cf_scalabletextarea custom tag.</FONT>
</CFCATCH>	  
</CFTRY>		
	
 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
