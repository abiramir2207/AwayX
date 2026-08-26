<cfsetting enablecfoutputonly="Yes">
<!------ displayLayer.cfm ----->
<cfparam name="Attributes.layerName" 	default="NoName">
<cfparam name="Attributes.height" 	default="">
<cfparam name="Attributes.width" 	default="">
<cfparam name="Attributes.overflow" 	default="">
<cfparam name="Attributes.bgColor" 	default="FFFFFF">
<cfparam name="Attributes.borderWidth" 	default="1">
<cfparam name="Attributes.borderColor" 	default="000000">
<cfparam name="Attributes.scroll" 	default="0">
<cfparam name="Attributes.show" 	default="0">
<cfparam name="Attributes.display" 	default="1">
<cfparam name="Attributes.fnSuffix" 	default="">
<cfoutput>
<cfif ThisTag.ExecutionMode EQ "start" AND thisTag.HasEndTag> 
<style type="text/css">	
	###Attributes.layerName#{<cfif NOT Attributes.show>visibility:hidden;</cfif>position:absolute; z-index:500; <cfif Attributes.width NEQ "">width:#Attributes.width#px;</cfif> <cfif Attributes.height NEQ "">height:#Attributes.height#px;</cfif> <cfif Attributes.overflow NEQ "">overflow:#Attributes.overflow#;</cfif> border:#Attributes.borderWidth#px solid ###Attributes.borderColor#;background-color:###Attributes.bgColor#; layer-background-color:###Attributes.bgColor#;}
</style>
<div id="#Attributes.layerName#">
</cfif>

<cfif ThisTag.ExecutionMode EQ "end" AND thisTag.HasEndTag> 
</div>

<script language="javaScript">
	var bDisplayLayerShow = #Attributes.show#;
	<cfif Attributes.display EQ "1">
	openDivWindow#Attributes.fnSuffix#();
	</cfif>
	function openDivWindow#Attributes.fnSuffix#()
	{		
		var divObj;
		var divName = "#Attributes.layerName#";

		divObj = document.getElementById(divName);
		//alert(divObj.style.display + "\n" + divObj.style.visibility);
		var winWidth = divObj.offsetWidth;
		var winHeight = divObj.offsetHeight;
		
		var wid,hei;		
		
			
		wid = document.body.clientWidth;
		hei = document.body.clientHeight;

		wid = (wid/2) - (winWidth/2);
		hei = (hei/2) - (winHeight/2);
		
		hei =  hei + document.body.scrollTop;
		
		/* For IE 10- Need to add "px". */
		wid = wid + 'px';
		hei = hei + 'px';

		if(divObj)
		{		
			divObj.style.left = wid;
			divObj.style.top = hei;
			divObj.style.visibility = "visible";
			bDisplayLayerShow = 1;
		}
		
		return false;
	}
	
	function closeDivWindow#Attributes.fnSuffix#()
	{			
		var divObj;
		var divName = "#Attributes.layerName#";
		
		divObj = document.getElementById(divName).style;
		divObj.visibility = "hidden";
		bDisplayLayerShow = 0;
		
		return false;
	}
	
	function scrollDivWindow#Attributes.fnSuffix#()
	{
		if(bDisplayLayerShow)
		{
			openDivWindow#Attributes.fnSuffix#();
		}
	}
	<cfif Attributes.scroll>
	document.body.onscroll=new Function ("scrollDivWindow#Attributes.fnSuffix#();");
	</cfif>
</script>
</cfif>
</cfoutput>
<cfsetting enablecfoutputonly="No">