<cfparam name="printresults" default="0">
<!--- Dev Note: KAL; D7573 --->
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
	Select		scorecard_sort_option, scorecard_sort_method
	From		_Users_Settings
	Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>

<cfif printresults EQ 1>
	<CFSET Table_Width =  "700">
	<CFSET Status_Width=15>
	<CFSET Number_Width=110>
	<CFSET Type_Width=100>
	<CFSET Title_Width=160>
	<CFSET SD_Width=30>
	<CFSET ED_Width=30>
	<CFSET Quantity_Width=40>
	
	<CFSET Title_Len=60>
	<CFSET Type_Len=28>

<cfelse>

	<CFSET table_Width=910>	
	<CFSET Status_Width=45>
	<CFSET Number_Width=110>
	<CFSET Type_Width=140>
	<CFSET Title_Width=375>
	<CFSET SD_Width=40>
	<CFSET ED_Width=40>
	<CFSET Quantity_Width=80>
	<CFSET BusSeg_Width=65>
	<CFSET SCISSOR_Width=10>
	
	<CFSET Title_Len=60>
	<CFSET Type_Len=28>
</cfif>
<!--- Dev Note: Milan; D6320 --->
<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="AllSettings">
<CFIF AllSettings.getProgramScoreCard() NEQ 0>
	<CFSET Title_Width=250>
	<CFSET Operator_Width=125>
	<CFSET Title_Len=45>
</CFIF>

<!--- Dev Note: KAL; D7573 --->
<cfif Get_Settings.Recordcount>
	<CFSET Default_Sort = "#Get_Settings.scorecard_sort_option#">
	<CFSET Default_Sort_Order = "#Trim(Get_Settings.scorecard_sort_method)#">
<cfelse>
	<CFSET Default_Sort = "CT">
	<CFSET Default_Sort_Order = "ASC">	
</cfif>

<CFSET User_Position_Operator_List = "Created By, Requesting Approval,Approved By">