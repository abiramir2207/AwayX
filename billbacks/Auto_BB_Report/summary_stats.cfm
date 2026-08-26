<!---------------------------------------------------------------------------------------------------------------------
      File Name:  \billbacks\Auto_BB_Report\summary_stats.cfm
   Created Date:  2016 April
         Author:  Chris Nguyen
        Purpose:  Display auto pay summary stats WR 48219

        Remarks:
----------------------------------------------------------------------------------------------------------------------->
   <cfsavecontent variable="variables.uncompressed">
    	<cfparam name="form.select_date" default="">
        <cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css"/>
		<style>
		form[name=search], form[name=csv] {
			margin: 0;
			padding: 0;
		}
		#search_criteria {
			padding:10px;
			text-align: left;
			width: 89.95%;
		}
		a.search {
			margin: 0 22px;
		}
		.label {
			font-weight: bold;
			letter-spacing: 0.5px;
			margin-right: 10px;
		}
		#data_table {
			width: 60%;
			margin-left:10px;
		}
		.lg {
			width: 10%;
		}
		.med {
			width: 18%;
		}
		.right {
			text-align: right;
		}
		tr.header {
			height: 23px;
		}
		tr.month {
			height: 17px;
		}
		</style>
		<cfoutput>
		
		<!--- 108967: Autopay access by Segment / Anand Rao / 15-Nov-2021 --->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>
				
		<!--- TODO :: The query below is too slow!! Need to have a SQL job to generate & save report content into new tables --->
		<cfif len(form.select_date) NEQ 0>
		
		<cfquery name="deleteTbl" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_BB_Auto_1') IS NOT NULL
			DROP TABLE ##tmp_BB_Auto_1

			IF OBJECT_ID('tempdb..##tmp_BB_Auto_2') IS NOT NULL
			DROP TABLE ##tmp_BB_Auto_2

			IF OBJECT_ID('tempdb..##tmp_autopay_bb') IS NOT NULL
			DROP TABLE ##tmp_autopay_bb
		</cfquery>

		<cfquery name="variables.stats" datasource="#application.datasource#">
			DECLARE @Date_Start DATE, @Date_End DATE
			SET @Date_End = '#form.select_date#'
			SET @Date_End = DATEADD(m, 1, @Date_End)
			/* End date is end of the Month (user searched Month) */
			SET @Date_End = DATEADD(day, -1, @Date_End)
			
			SET @Date_Start = DATEADD(year, -1, @Date_End)
			/* Start date is one year before the End end */
			SET @Date_Start = DATEADD(day, 1, @Date_Start)

			
			SELECT  B.Billback_ID, 
					B.BB_Code,  
					B.BB_End_Date,
					CM.Contract_Number, 
					BA.Paid_Amount,
					BA.Pullback_applied_Amount,
					PB.BB_Auto_Program_Pay_Period_ID,
					PB.BB_Auto_Report_id,
					PB.[Status]
					<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>		
						,CM.Business_Segment_ID
						,BS.Business_Unit_ID
						,BS.Business_Unit_Desc
					</cfif>
			INTO	 ##tmp_BB_Auto_1
			FROM	Billback B
			INNER JOIN BB_Approved BA
			ON	BA.Billback_ID = B.Billback_ID 
			INNER JOIN Billback_Program BPG
			ON    BPG.Billback_ID = B.Billback_ID
			AND   BPG.Deleted = 0
			INNER JOIN Contract_Main CM
			ON    CM.Contract_Main_ID = BPG.Program_ID                 
			INNER JOIN BB_Auto_Program_Pay_Period PB
			ON PB.BillBack_ID = B.Billback_ID
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
				LEFT JOIN Business_Segment BS ON BS.Business_Segment_ID = CM.Business_Segment_ID
			</cfif>
			WHERE B.Deleted = 0
			AND	B.Billback_Status_ID >= 2
			AND	B.Auto_Billback = 1 
			AND	B.BB_End_Date BETWEEN @Date_Start AND @Date_End

			CREATE CLUSTERED INDEX tmp_BB_Auto_1_C ON ##tmp_BB_Auto_1(Billback_ID)
			
			SELECT BB_ID AS Billback_ID
					,SUM(ISNULL(Amount_Earned, 0))Amount_Earned 
					,SUM(ISNULL(Cases_Invoiced, 0)) AS Cases_Invoiced
					,SUM(ISNULL(Pounds_Invoiced, 0)) AS Pounds_Invoiced
			INTO	##tmp_BB_Auto_2
			FROM	BB_Auto_Accrual_Log
			WHERE	BB_ID in (SELECT Billback_ID FROM ##tmp_BB_Auto_1)
			GROUP BY BB_ID
			
			CREATE CLUSTERED INDEX tmp_BB_Auto_2_C ON ##tmp_BB_Auto_2(Billback_ID)                  
			
			SELECT	a1.Billback_ID
					,a1.BB_Code
					,a1.Contract_Number
					,CAST(DATENAME(MM,a1.BB_End_Date) As varchar(9)) + ' ' + CAST(Year(a1.BB_End_Date) As varchar(4)) As Month_Year
					,YEAR(a1.BB_End_Date) As DateYearNum
					,MONTH(a1.BB_End_Date) As DateMonthNum
					,a1.BB_Auto_Report_id 					
					,SUM(ISNULL(a2.Amount_Earned, 0)) AS amount
					,SUM(ISNULL(a2.Cases_Invoiced, 0)) AS Cases_Invoiced
					,SUM(ISNULL(a2.Pounds_Invoiced, 0)) AS Pounds_Invoiced
					,ISNULL(a1.Pullback_applied_Amount, 0) AS Pullback_Dollars
					,a1.Paid_Amount AS Net_Amount
					,SUM(CASE a1.Status WHEN 4 THEN 0 ELSE ISNULL(a2.Amount_Earned, 0) END) as RFA_Amount
					,CASE a1.Status WHEN 4 THEN 0 ELSE a1.Paid_Amount END as RFA_Net_Amount
					,COUNT(DISTINCT Contract_Number) as Num_Programs
					<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
						,a1.Business_Segment_ID
						,a1.Business_Unit_ID
						,a1.Business_Unit_Desc
					</cfif>
					
			INTO  ##tmp_autopay_bb
			FROM	##tmp_BB_Auto_1 a1
			INNER JOIN ##tmp_BB_Auto_2 a2
			ON	a1.Billback_ID = a2.Billback_ID
			GROUP BY 
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>a1.Business_Segment_ID, </cfif>
			a1.Billback_ID, a1.BB_Code, a1.Contract_Number, a1.BB_End_Date, ISNULL(a1.Pullback_applied_Amount, 0), a1.Paid_Amount, a1.Status, a1.BB_Auto_Report_id
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>, a1.Business_Unit_ID, a1.Business_Unit_Desc</cfif>
							
			SELECT	Month_Year,
					DateYearNum,
					DateMonthNum,
					SUM(Amount) as Amount,
					SUM(Cases_Invoiced) as Cases_Invoiced,
					SUM(Pounds_Invoiced) as Pounds_Invoiced,
					SUM(Pullback_Dollars) as Pullback_Dollars,
					SUM(Net_Amount) as Net_Amount,
					SUM(RFA_Net_Amount) as RFA_Net_Amount,
					COUNT(DISTINCT Contract_Number) as Num_Programs
					<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
					,Business_Segment_ID
					,Business_Unit_ID
					,Business_Unit_Desc
					</cfif>
			FROM  ##tmp_autopay_bb
			GROUP BY Month_Year,DateYearNum,DateMonthNum <cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>,Business_Unit_Desc,Business_segment_ID, Business_Unit_ID </cfif>
			ORDER BY DateYearNum DESC, DateMonthNum DESC <cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>,Business_Unit_Desc</cfif>
		</cfquery>
		</cfif>	


		<div id="search_criteria">
			<form name="search" method="post">
				<label class="label" for="select_date">Select Month:</label>
				<select name="select_date" id="select_date">
					<cfset variables.today = now()>
					<cfset variables.optgroup_year = year(variables.today)>
					<cfset variables.start_date = createDate(year(variables.today), month(variables.today), 1)>
					<option value=""></option>
					<cfloop from="1" to="24" index="variables.counter">
						<!--- group by year --->
						<cfif year(variables.start_date) neq variables.optgroup_year>
							<optgroup label="- #year(variables.start_date)# -">
							<cfset variables.optgroup_year = year(variables.start_date)>
						</cfif>
						<cfset variables.start_date_short = dateFormat(variables.start_date,'short')>
						<option value="#variables.start_date_short#" <cfif form.select_date eq variables.start_date_short>selected=selected</cfif>>#dateFormat(variables.start_date, "mmmm yyyy")#</option>
						<!--- move to previous month --->
						<cfset variables.start_date = dateAdd("m", -1, variables.start_date)>
					</cfloop>
		            </optgroup>
				</select>
				<a href="##" class="search" onclick="search_data()">#application.util.string.actionLinkFormat2( "search" )#</a>
				<cfif form.select_date neq "">
					<a href="##" class="search" onclick="export_to_csv()">#application.util.string.actionLinkFormat2( "export" )#</a>
				</cfif>
			</form>  <!--- name="search" --->
            <!--- export to csv form --->
            <form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
                <input type="hidden" name="csv_text" id="csv_text">
                <input type="hidden" name="csv_file_name">
            </form>
		</div>  	 <!--- id="search_criteria" --->

		<table id="data_table" class="datagrid" style="width:800px;">
			<thead>
				<tr class="header">
					<th style="width:100px;">Month</th>
					<th style="width:90px;">Net RFA</th>
					<th style="width:130px;">Net Approved ($)</th>
					<th style="width:90px;">Recapture </th>
					<th style="width:100px;">Cases</th>
					<th style="width:80px;">Lbs</th>
					<th style="width:60px;">Programs</th>
					<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
						<th style="width:60px;"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></th>
					</cfif>	
					
				</tr>
			</thead>
			<tbody>
				<!--- time selection has not been made - display empty table --->
				<!--- TODO :: Remove hard-coded condition and read data from new summary tables --->
				<cfif len(form.select_date) EQ 0>
					<cfloop from="1" to="12" index="variables.counter">
						<tr class="month">
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
								<td>&nbsp;</td>
							</cfif>
						</tr>
					</cfloop>
				<cfelse>
					<cfloop query="variables.stats">
						<tr class="month">
							<td>#variables.stats.Month_Year#</td>
							<td>#dollarFormat(variables.stats.RFA_Net_Amount)#</td>
							<td>#dollarFormat(variables.stats.Net_Amount)#</td>
							<td>#dollarFormat(variables.stats.Pullback_Dollars)#</td>
							<td>#NumberFormat(variables.stats.Cases_Invoiced, "," )#</td>
							<td>#NumberFormat(variables.stats.Pounds_Invoiced, "," )#</td>
							<td>#variables.stats.Num_Programs#</td>
							<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
								<td><nobr>#variables.stats.Business_Unit_Desc#</nobr></td>
							</cfif>
						</tr>
					</cfloop>
				</cfif>
			</tbody>
		</table>
		</cfoutput>

		<cfinclude template="/common_files/jQuery.cfm">
    	<cfmodule template="/customTags/include.cfm" file_to_include="/script/javascript/table2csv.js, /script/javascript/jquery.noty.packaged.min.js"/>

		<script>
		function search_data() {
			if (!jQuery("#select_date").val()) {
				alert( "Please select a month from the dropdown first." );
				return false;
			}
			please_wait( "Searching for information, please wait..." );
			jQuery("form[name=search]").submit();
		};
		function please_wait( msg ) {
		    noty( {    text: msg
		            ,layout: 'bottom'
		              ,type: 'information'
		            ,killer: true
		          });
		    /* disable onclick event on a tags */
		    jQuery("#search_criteria a").prop("onclick", null);
		};
		function export_to_csv() {
		    jQuery('input[name=csv_file_name]').val( "summary_stats_"
		                                             + Math.random().toString(36).slice(2)
		                                             + ".csv" );
		    jQuery("#csv_text").val( jQuery('table#data_table').table2CSV() );
		    jQuery("#csv_form").submit();
		};
		</script>
	</cfsavecontent>
	<cfoutput>#variables.uncompressed#</cfoutput>