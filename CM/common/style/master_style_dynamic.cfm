<!------ scorecard_style_dynamic.cfm ----->
<cfcontent type="text/css">
<cfheader name="Content-Disposition" value="inline;filename=master_style_dynamic.css">
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfinclude template="/cm/common/Measurements.cfm">
<cfoutput>
##leftlinks{
	position:		absolute;
	top : 			#Evaluate(topBannerPadding + leftLinksTop)#px;
	left : 			#leftItemsLeft#px;
	width : 		#leftItemsWidth#px;
}

##messagewin{
	position :		absolute;
	top :			#Evaluate(topBannerPadding + leftLinksTop + leftLinksHeight)#px; 
	left : 			#leftItemsLeft#px;
}

##calendar{
	position:		absolute;
	top : 			#Evaluate(topBannerPadding + leftLinksTop + leftLinksHeight + leftMessageHeight + leftMessageArrows)#px;
	left : 			#leftItemsLeft#px;
	width : 		#leftItemsWidth#px;
}

##content{
	position: 		absolute;
	top : 			#Evaluate(topBannerPadding + leftLinksTop)#px;
	left : 			#leftItemsWidth#px;
	height:			98%;
	border: 		Solid 0px ##4169E1;
	padding :		0px;
}

</cfoutput>