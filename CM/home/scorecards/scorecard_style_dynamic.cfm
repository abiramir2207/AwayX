<!------ scorecard_style_dynamic.cfm ----->
<cfcontent type="text/css">
<cfheader name="Content-Disposition" value="inline;filename=scorecard_style_dynamic..css">
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfinclude template="/cm/common/Measurements.cfm">
<cfoutput>
##topbanner{
	position: 		absolute;
	top : 			#topBannerPadding#px;
	left : 			#topBannerPadding#px;
	width : 		#innerWinMaxWidth#px;
	height :		#topBannerHeight#px;
}

##tasks{
	position:		absolute;
	top : 			#Evaluate(topBannerHeight + scorecardPadding)#px;
	left : 			#scorecardPadding#px;
	width : 		#scorecardWidth#px;
	height : 		#scorecardHeight#px;
}

##activities{
	position:		absolute;
	top : 			#Evaluate(topBannerHeight + scorecardPadding)#px;
	left : 			#Evaluate(scorecardPadding + scorecardWidth + scorecardPadding)#px;
	width : 		#scorecardWidth#px;
	height : 		#scorecardHeight#px;
}

##campaigns{
	position:		absolute;
	top : 			#Evaluate(topBannerHeight + scorecardPadding)#px;
	left : 			#Evaluate(scorecardPadding + scorecardWidth + scorecardPadding + scorecardWidth + scorecardPadding)#px;
	width : 		#scorecardWidth#px;
	height : 		#scorecardHeight#px;
}

##weeklyscoreard{
	position:		absolute;
	top : 			#Evaluate(topBannerHeight + scorecardPadding + scorecardHeight + scorecardPadding)#px;
	left : 			#scorecardPadding#px;
	width : 		#innerWinMaxWidth#px;
}
</cfoutput>