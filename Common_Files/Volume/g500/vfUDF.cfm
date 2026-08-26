<!---------------------------------------------------------------------------------------------------------------------
			Template: \Common_Files\Volume\g500\vfUDF.cfm
			Date:     Dec 15 2011
			Author:   Chris Nguyen
			Purpose:  Volume Forecast User-Defined Functions Library

			Remarks:  This include requires:

			           - application.oVfManager:  instantiated volume forcast manager object

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="const.volumeFormat"  default="-999,999,999">
<cfparam name="const.percentFormat" default="-999.00">

<cffunction name="deltaValue" output="false" returntype="String" hint="Return delta value/percentage based on this year volume and last year volume">
	<cfargument name="ty" required="true" hint="I am this year volume">
	<cfargument name="ly" required="true" hint="I am last year volume">
	<cfargument name="percentage" required="false" type="boolean" default="false" hint="Optional percentage indicator, if value is true delta percentage is calculated and returned">

	<cfif not arguments.percentage>
		<cfreturn NumberFormat(val(arguments.ty) - val(arguments.ly), const.volumeFormat)>
	<cfelseif val(arguments.ly) eq 0>
		<cfreturn "100%">
	<cfelse>
			<cfreturn NumberFormat((val(arguments.ty) - val(arguments.ly)) / val(arguments.ly) * 100, const.percentFormat) & '%'>
	</cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="marketsList" output="true" hint="I create the current positions and below drop-down">
	<cfargument name="byPlanID" required="false" default="0">
	
  <cfset qCurrPositionAndBelowMarkets = application.oVfManager.getCurrPositionAndBelowVF( arguments.byPlanID )>
  <select id="marketslist">
  <cfif qCurrPositionAndBelowMarkets.recordCount gt 1>
    <option id="v451=#qCurrPositionAndBelowMarkets.vf_Plan_Id#&l143=summary">SUMMARY</option>  
  </cfif>
  <cfoutput query="qCurrPositionAndBelowMarkets">
  <option <cfif qCurrPositionAndBelowMarkets.VF_Level_ID eq url.l143>selected</cfif> id="v451=#qCurrPositionAndBelowMarkets.vf_Plan_Id#&l143=#qCurrPositionAndBelowMarkets.VF_Level_ID#">#qCurrPositionAndBelowMarkets.Level_Name#</option>
  </cfoutput>
  </select>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="volumeFormat" output="false" hint="Return volume format/percentage">
	<cfargument name="amt" required="true" hint="I am the volume amount">
	<cfargument name="nullForZero" required="false" type="boolean" default="false" hint="Optional argument, if it is true (default) a blank string is returned when volume amount is zero">
	<cfargument name="percentage" required="false" type="boolean" default="false" hint="Optional argument, if it is false (default) a formatted volume percentage is returned">

	<cfif val(arguments.amt) eq 0>
		<cfif arguments.nullForZero>
			<cfreturn "">
		<cfelseif arguments.percentage>
			<cfreturn NumberFormat(val(arguments.amt), const.percentFormat) & '%'>
		<cfelse>
			<cfreturn "0">
		</cfif>
	<cfelse>
		<cfif arguments.percentage>
			<cfreturn NumberFormat(arguments.amt, const.percentFormat) & '%'>
		<cfelse>
			<cfreturn NumberFormat(arguments.amt, const.volumeFormat)>
		</cfif>
	</cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="QuarterName" output="false" hint="I return the name of a quarter.">
	<cfargument name="quarterNumber" required="true" hint="I am the quarter number.">

	<cfswitch expression="#arguments.quarterNumber#">
		<cfcase value="1"> <cfreturn '1st Quarter'> </cfcase>
		<cfcase value="2"> <cfreturn '2nd Quarter'> </cfcase>
		<cfcase value="3"> <cfreturn '3rd Quarter'> </cfcase>
		<cfcase value="4"> <cfreturn '4th Quarter'> </cfcase>
		<cfdefaultcase>
			<cfreturn ''>
		</cfdefaultcase>
  </cfswitch>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="removeURLfields" output="false" hint="I return a new query string with some URL fields removed">
  <cfargument name="URLfields" required="true" type="string" hint="I am the list of url parameters to remove">

  <cfscript>
    var l = {};
    l.result = [];
  </cfscript>

  <!---scan thru all url parameters in query string--->
  <cfloop collection="#url#" item="l.url">
    <cfif listFindNoCase(arguments.URLfields, l.url) eq 0 >
      <cfset arrayAppend(l.result, l.url & '=' & url[ l.url ])>
    </cfif>
  </cfloop>

  <cfreturn arrayToList(l.result, '&')>
</cffunction>

