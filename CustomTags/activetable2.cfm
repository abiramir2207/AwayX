<cfsetting enablecfoutputonly="yes">
<!--- 
	The following CF Tag has been developed by Yuriy V Maksymenko.
	http://www.activefeedback.com
	Customer Support: support@activefeedback.com
	Download Latest version: http://www.activefeedback.com/af/order/order1.cfm
	
	Updated Wednesday, June 21, 2000 by Orbwave Corporation
	http://www.orbwave.com/
	Customer Support: support@orbwave.com
	Download Latest version: http://www.orbwave.com/products/index.cfm
	
	Example: 

	<cf_activetable title="My Title">
		
		Place your content in here...		
		
	</cf_activetable>

 --->

<!--- List of Default Parameters  --->
<cfparam name="attributes.width" default="100%">
<cfparam name="attributes.height" default="">
<cfparam name="attributes.cellpadding" default="1">
<cfparam name="attributes.cellspacing" default="0">
<cfparam name="attributes.border" default="0">
<cfparam name="attributes.fontColor" default="brown">
<cfparam name="attributes.titleBarColor" default="dddddd">
<cfparam name="attributes.bodyColor" default="ffffff">
<cfparam name="attributes.title" default="Online Form">
<cfparam name="attributes.titleFontSize" default="1">

<!--- Scroll (DHTML option to scroll content within the table)  --->
<cfparam name="attributes.scroll" default="false">

<cfparam name="session.activepage" default="1">

<!--- Set to false if you don't want to display a button--->
<cfparam name="attributes.minimize" default="true">

<!--- Container ID is a random variable used to  --->
<cfparam name="attributes.containerid" default="#randrange(111111111,999999999)#">

<!--- Determine which browser is being used --->
<cfif cgi.user_agent contains "MS">
	<cfset browser = "ie">
<cfelse>
	<cfset browser = "ns">
</cfif>
	
<CFSWITCH expression="#ThisTag.ExecutionMode#">
    <CFCASE value='start'>

<!--- Start tag processing --->
<cfoutput>
<cfif attributes.minimize>
	<SCRIPT language=jscript>
	<!--
	function change_d#attributes.containerid#() {
		if (c#attributes.containerid#.style.display == "") {
		c#attributes.containerid#.style.display = "none";
	}
	 else{
		c#attributes.containerid#.style.display= "";
		}
	}
	-->
	</SCRIPT>
</cfif>
<div style="{ padding-left : 0; padding-right : 0; padding-top : 0; padding-bottom : 0; background-color : #attributes.bodyColor#; border-style : outset; border-width : thin; width:#attributes.width#; <cfif len(attributes.height)>height:#attributes.height#; </cfif><cfif attributes.scroll>overflow : scroll;</cfif>} ">			
	<table width="100%" cellpadding="#attributes.cellpadding#" cellspacing="#attributes.cellspacing#" border="0">
		<tr><td align="left" bgcolor="#attributes.titleBarColor#" height="10" valign="middle" nowrap width="100%">
				<cfif attributes.minimize>
					<BUTTON onclick="change_d#attributes.containerid#()" style=" HEIGHT: 15px; WIDTH: 15px; cursor : pointer; line-height : 3;"></BUTTON>&nbsp;
				</cfif>
			</td>
			<td bgcolor="#attributes.titleBarColor#" height="16" nowrap width="100%">
 				<font face="verdana,arial,helvetica" color="#attributes.fontColor#" size="#attributes.titleFontSize#">&nbsp;<b>#attributes.title#</b></font>
			</td>
		</tr>
	</table>
	<cfif attributes.minimize>			
		<DIV id="c#attributes.containerid#" STYLE="position:relative;top:0;left:0; <cfif browser eq "ie">display:none<cfelse>display:</cfif> ;">					
	<cfelse>
		<DIV id="c#attributes.containerid#" STYLE="position:relative;top:0;left:0; <cfif browser eq "ie">display:none<cfelse>display:</cfif> ;">					
	</cfif>
		<table width="100%" cellpadding="#attributes.cellpadding#" cellspacing="#attributes.cellspacing#" border="0" bordercolor="##808080">
		<tr><td colspan="2" bgcolor="#attributes.bodyColor#">
</cfoutput>
</CFCASE>
<!--- End of Wrapper --->
<CFCASE value='end'>
<cfif attributes.minimize>
	<!--- End tag processing --->
	<cfoutput>
		</td></tr></table></div></div>
	</cfoutput>
</cfif>
</CFCASE>
</CFSWITCH>
<cfsetting enablecfoutputonly="no">
