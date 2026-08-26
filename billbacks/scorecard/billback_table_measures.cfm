<cfif NOT isDefined("businessSegmentsOn")>
	<!------ D10185 (DRK): Remove Segment Field on Billbacks if client doesn't use that feature.  ----->
	<!------ check if business segment is on at the application level ----->
	<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
	<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>
</cfif>

<cfif NOT isDefined("billbackSettingsManager")>
	<cfset billbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager") />
</cfif>
<cfset Default_sort_columns 			 = billbackSettingsManager.getDefaultSortOptions()>
<cfset Default_sort_option_for_Scorecard = Default_sort_columns.Default_sort_option_for_Scorecard />
<cfset Default_Sort_By 					 = Default_sort_columns.Default_Sort_By />

<CFSET table_Width=1250>
<!------ usual scorecard----->
<CFSET SpacerWidth=10>
<cfset SelectionWidth=18>

<!--- 
Note: All these width values have increased, to account for a higher resolution:
Earlier "tablw_width" was 1000 and has been increased to 1250 (above).
To account for this 25% increase, the width values have been increased by 25% also.
******************************************************************************
RESOLUTION: 1360 x 768
******************************************************************************
--->
<CFSET Status_Width=79>
<CFSET UPPNF_Width=68>
<CFSET Number_Width=137>
<CFSET BBD_Width=181>

<!---
"BB_Width" is not being used. "BBD_Width" is being used,instead.
<CFSET BB_Width=100>
--->

<!--- 
"Title_Width" is not being used. "Payee_And_Title_Width" is being used,instead.
<CFSET Title_Width=144>D25219: SOW - Enable mass paying of payables 
--->
<CFSET Payee_And_Title_Width=205><!--- D25219: SOW - Enable mass paying of payables --->

<!--- 
"SD_Width" and "ED_Width" are not being used. "Date_Width" is being used,instead.
<CFSET Title_Width=144>D25219: SOW - Enable mass paying of payables 
--->
<!---<CFSET SD_Width=50> D25219: SOW - Enable mass paying of payables --->
<!---<CFSET ED_Width=40> D25219: SOW - Enable mass paying of payables --->

<CFSET Date_Width = 112><!--- D25219: SOW - Enable mass paying of payables --->
<CFSET Amount_Width=95><!--- D25219: SOW - Enable mass paying of payables --->

<!--- 
"Segment_Width" is not being used. "Analyst_And_Segment_Width" is being used,instead.
<CFSET Segment_Width=70> 
--->
<CFSET Analyst_And_Segment_Width=87> <!--- put ANALYST on the Segment column --->

<!------ payement req scorecard----->
<CFSET PR_Status_Width=72>
<CFSET PR_Number_Width=137>
<CFSET PR_BBD_Width=50>

<CFSET PR_BB_Width=95>
<CFSET PR_Title_Width=254>
<CFSET PR_Payee_Width=135>

<CFSET PR_Amount_Width=87>

<CFSET PR_Prepared_By=115>
<CFSET PR_Approved_By=115>


<CFSET PR_Title_Len=40>
<CFSET PR_Ref_Num_Len=20>
<CFSET PR_Payee_Len=50>

<!------ payement req scorecard----->


<CFSET Title_Len=50>
<CFSET Ref_Num_Len=20>
<CFSET Payee_Len=50>


<CFPARAM name="Default_Sort" default="#Default_sort_option_for_Scorecard#"><!--- BBT --->
<CFPARAM name="Default_Sort_Order" default="#Default_Sort_By#"><!--- ASC --->