<cfsetting enablecfoutputonly="yes">
<!--- 
	the following cf tag has been developed by yuriy v maksymenko.
	http://www.activefeedback.com
	customer support: support@activefeedback.com
	download latest version: http://www.activefeedback.com/af/order/order1.cfm
	
	example: 

	<cf_activetable title="my title">
		
		place your content in here...		
		
	</cf_activetable>

 --->

<!--- list of default parameters  --->
<cfparam name="attributes.width" default="100%">
<cfparam name="attributes.height" default="">
<cfparam name="attributes.cellpadding" default="1">
<cfparam name="attributes.cellspacing" default="0">
<cfparam name="attributes.border" default="0">
<cfparam name="attributes.bgcolor1" default="808080">
<cfparam name="attributes.bgcolor2" default="midnightblue">
<cfparam name="attributes.bgcolor3" default="ffffcc">
<cfparam name="attributes.title" default="online form">

<!--- scroll (dhtml option to scroll content within the table)  --->
<cfparam name="attributes.scroll" default="false">

<cfparam name="session.activepage" default="1">

<!--- set to false if you don't want to display a button--->
<cfparam name="attributes.minimize" default="true">

<!--- container id is a random variable used to  --->
<cfparam name="attributes.containerid" default="#randrange(111111111,999999999)#">

<cfswitch expression="#thistag.executionmode#">
    <cfcase value='start'>
	
        <!--- start tag processing --->
<cfoutput>
<cfif attributes.minimize>
<script language=jscript>
<!--
function change_d#attributes.containerid#() {
if (c#attributes.containerid#.style.display == "") {
c#attributes.containerid#.style.display = "none";
//document.personalizer.structure.value = "111";
}
 else{
c#attributes.containerid#.style.display= "";
//document.personalizer.structure.value="222";
}
}
function set()
{
c#attributes.containerid#.style.display = "none";
}
function aclose() {
c#attributes.containerid#.style.display = "none";
}

function aopen() {
c#attributes.containerid#.style.display = "";
}
-->
</script>
</cfif>
<body onLoad="set()">
<div style="{ padding-left : 3; padding-right : 3; padding-top : 2; padding-bottom : 5; background-color : buttonface; border-style : outset; border-width : thin; width:#attributes.width#; <cfif len(attributes.height)>height:#attributes.height#; </cfif><cfif attributes.scroll>overflow : scroll;</cfif>} ">			
			<table cellpadding="#attributes.cellpadding#" cellspacing="#attributes.cellspacing#" border="0">
				<tr><td bgcolor="#attributes.bgcolor2#" height="16" nowrap>
	  				<font face=verdana,arial,helvetica color=ffffff size="1">
						&nbsp;<b>#attributes.title#</b>
          			</font>
					</td>
					<td align="right" bgcolor="#attributes.bgcolor2#" height="10" valign="middle" nowrap width="100%">
						<cfif attributes.minimize>				
							<font face=verdana,arial,helvetica color=ffffff size="1">
								<!--container:#attributes.containerid# &nbsp;&nbsp;-->
								<b>Click Here--></b>
							</font>
							<button onclick="change_d#attributes.containerid#()" style=" height: 15px; width: 15px; cursor : pointer; line-height : 3;"></button>
						</cfif>
					</td>
				</tr>
			</table>
			<cfif attributes.minimize>			
				<div id="c#attributes.containerid#" style="position:relative;top:0;left:0; display: ;">					
			<cfelse>
				<div id="c#attributes.containerid#" style="position:relative;top:0;left:0; display: ;">					
			</cfif>
				<table width="100%" cellpadding="#attributes.cellpadding#" cellspacing="#attributes.cellspacing#" border="0" bordercolor="##808080">
				<tr><td colspan=2 bgcolor="#attributes.bgcolor3#">
</cfoutput>
</cfcase>
<!--- end of wraper --->
<cfcase value='end'>
<cfif attributes.minimize>
	<!--- end tag processing --->
	<cfoutput>
		</td></tr></table>
		</div>
	</div>
	</cfoutput>
</cfif>
</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="no">
</body>
