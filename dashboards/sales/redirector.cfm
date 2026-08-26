
<cfswitch expression="#content#">

    <cfcase value="98585297663642398510508237795561">
		<cfset page_name="Last 12 months of sales">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_of_sales.cfm">
	</cfcase>

    <cfcase value="62526295576456889892265726733504">
		<cfset page_name="Latest Month vs SPLY">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="latest_month_vs_sply.cfm">
	</cfcase>

    <cfcase value="20917823871927189723493795557513">
		<cfset page_name="Last 12 Months vs. SPLY - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_vs_sply.cfm">
	</cfcase>



<!--- 
    <cfcase value="37615493198208507187706498289220">
		<cfset page_name="Last 12 Months vs. SPLY - cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_vs_sply_cs.cfm">
	</cfcase>

    <cfcase value="4824c5c3abd9498eadfc89e826ee40ef">
		<cfset page_name="Last 12 Months vs. SPLY - pounds">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_vs_sply_pounds.cfm">
	</cfcase>

    <cfcase value="58988149921442618161067424961114">
		<cfset page_name="Last 12 Months vs. SPLY - equivalent cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_vs_sply_eqcs.cfm">
	</cfcase>

 --->

    <cfcase value="99636049761723214009329786677254">
		<cfset page_name="detail sales data view - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="data_grid1.cfm">
	</cfcase>

    <cfcase value="14830905970411369197884647941590">
		<cfset page_name="region detail data view">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="data_grid2.cfm">
	</cfcase>

    <cfcase value="98966406792759293476740818989949">
		<cfset page_name="last 12 months vs goal - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_vs_goal.cfm">
	</cfcase>

    <cfcase value="10164312353993657002544185373860">
		<cfset page_name="last 12 months: actual, goal, forecast - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="last_12_months_vs_goal_forecast.cfm">
	</cfcase>

    <cfcase value="50493201990712445824981794589105">
		<cfset page_name="sales volume - regions - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="level_1_sales.cfm">
	</cfcase>

    <cfcase value="30263359365706554689441457485833">
		<cfset page_name="sales volume - sub-regions">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="level_2_sales.cfm">
	</cfcase>

    <cfcase value="75251999172743704019406752138638">
		<cfset page_name="sales volume - territories">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="level_3_sales.cfm">
	</cfcase>

    <cfcase value="40953630284217705370007273260487">
		<cfset page_name="to go sales pace - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="goal_target_actual1.cfm">
	</cfcase>

    <cfcase value="d94effeef77a45068d581641bd1a40e4">
		<cfset page_name="monthly variance vs goals - eq. cases">
		<cfset data_month="">
		<cfset data_quarter="">
		<cfset data_year="">
		<cfset content="goal_target_actual2.cfm">
	</cfcase>






    <cfdefaultcase>
		<cfset page_name="dashboard :: sales">
	</cfdefaultcase>

</cfswitch>