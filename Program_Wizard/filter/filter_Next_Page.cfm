
<!------ filter_Next_Page.cfm ----->

<cfif filterPageName NEQ "">
	<CFSET ThisURL = "/program_wizard/Template_Filters.cfm"/>
	<cfset bCurrentPage = 0 />
	<CFSET F_Counter = 1>
	<CFLOOP LIST="#PAGE_TITLES#" INDEX="ThisMenuItem">
		<CFSET ThisPageName = ListGetAt(PAGE_NAMES, F_Counter, ",")>
		<cfif bCurrentPage>
			<!---<CFSET ThisURL = ListGetAt(PAGE_URLS, F_Counter, ",")>--->
			<cfoutput>
				<!--- positionfilter.cfm uses an iframe, so we need to figure out which fram to send the locate to --->
				<script type="text/javascript" language="JavaScript">
					var arrFrames = parent.document.getElementsByTagName("IFRAME");
					for (var i = 0; i < arrFrames.length; i++) {

					  if(arrFrames[i].id == "positionSearchFrame" || arrFrames[i].id == "mpIframe"){
					  	var doc = parent.parent.document;
					  }
					  else{
					  	var doc = parent.document;
					  }
					}
					doc.getElementById('mainwindow').src = '#ThisURL#?id=#ID#&tfId=#form.rdoFilter#&filterPageName=#ThisPageName#';
				</script>
			
			</cfoutput>
			<!---<cflocation addtoken="No" url="#ThisURL#?id=#ID#&tfId=#form.rdoFilter#&filterPageName=#ThisPageName#" />--->
		</cfif>
		<br> <!---<cfoutput>#ThisPageName# :: #filterPageName#</cfoutput>--->
		<CFIF ThisPageName EQ filterPageName>
			<cfset bCurrentPage = 1 />
		</CFIF>
		<CFSET F_Counter = F_Counter + 1>
	</CFLOOP>
	<cfoutput>
	<script type="text/javascript" language="JavaScript">
		var arrFrames = parent.document.getElementsByTagName("IFRAME");
					for (var i = 0; i < arrFrames.length; i++) {

					  if(arrFrames[i].id == "positionSearchFrame"|| arrFrames[i].id == "mpIframe"){
					  	var doc = parent.parent.document;
					  }
					  else{
					  	var doc = parent.document;
					  }
					}
		doc.getElementById('mainwindow').src = '/program_wizard/template_filters.cfm?id=#ID#&tfId=#form.rdoFilter#&bContinue=1';
	</script>
	</cfoutput>
	<!---<cflocation addtoken="No" url="/program_wizard/template_filters.cfm?id=#ID#&tfId=#form.rdoFilter#&bContinue=1">--->
</cfif>