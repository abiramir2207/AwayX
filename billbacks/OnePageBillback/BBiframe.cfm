<cfparam name="URL.page" default="/billbacks/capture/index.cfm">
<cfparam name="URL.id" default="">

<script>
	var newTabFrame = document.createElement("iframe");
	// newTabFrame.setAttribute("id", "newTabFrame");
	newTabFrame.setAttribute("src", <cfoutput>'#URL.page#'</cfoutput> + '&id= + <cfoutput>#URL.id#</cfoutput>');
	newTabFrame.setAttribute("frameBorder", "0");
	newTabFrame.setAttribute("hspace", "0");
	newTabFrame.setAttribute("onload", "resizeIframe(this);"); //For non-IE
	newTabFrame.setAttribute("style", "padding-top: 10px;");

	// add iframe to the last child of allTabContent - this should be the newly created dynamic div
	$("#allTabContent").children().last().html(newTabFrame);
	

	if (isIE = /*@cc_on!@*/false) { //For IE
		setTimeout(function () { resizeIframe(this) }, 500);
	} 

	function resizeIframe(obj) {
		obj.style.height = '100%';
		obj.style.width = '100%';
	}
</script>