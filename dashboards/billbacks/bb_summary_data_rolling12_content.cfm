<!--- ----------------------------------------------------------------------------------------- --->
<CFPARAM NAME="content" DEFAULT='nodata.cfm'>
<CFPARAM NAME="primarycolor" DEFAULT='##CCCCCC'>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="redirector.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<!--- main query to retrieve all data --------------------------------------------------------- --->
<cfquery name="getdata" datasource="#Application.Datasource#">

    SELECT * from
		(
			select		top 12 
						Dashboards_BB_Summary_ID, 
						batch_id, 
						period_desc,
						#data_field# as data
			from		Dashboards_BB_Summary 
			where		Dashboards_BB_Record_Type_Lookup_ID = 3 
			order by	Dashboards_BB_Summary_ID desc
		)
	a
	order by Dashboards_BB_Summary_ID
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- make array from the query data retrieved. required for the udf functions ---------------- --->
<cfset dbdata_array = listToArray(valueList(getdata.data)) />
<!--- ----------------------------------------------------------------------------------------- --->


<!--- get average of the data in the array ----------------------- --->
<cfset data_average=Mean(dbdata_array)>

<!--- get minimum of the data in the array ----------------------- --->
<cfset data_minimum=#ArrayMin(dbdata_array)#>

<!--- get maximum of the data in the array ----------------------- --->
<cfset data_maximum=#ArrayMax(dbdata_array)#>

<!--- get std deviation of the data in the array ----------------------- --->
<cfset data_stddev=#StdDevPop(dbdata_array)#>


<div style="font-size:18px; color:#FFA500; border-bottom:2px #FFA500 solid; padding:10px 0px 0px 0px; margin: 10px 15px 15px 15px;">

<cfoutput>#page_name# (last 12 months)</cfoutput>
</div>

<table cellpadding="5" cellspacing="5" border="0" width="900" align="center">	
	<tr>
		<td valign="top" width="150" bgcolor="#373737" align="center">
		
			<table cellpadding="0" cellspacing="1" border="0">	

				<cfoutput query="GETDATA"> 
				<TR>
					<TD class="grid_data" nowrap>#period_desc#</TD>
					<TD class="grid_data" style="text-align:right;">#numberformat(data, '9,999,999')#</TD>
				</TR>
				</cfoutput>

				<TR>
					<TD colspan="100%" nowrap><hr noshade style="border: 1px solid #FFA500;" /></TD>
				</TR>

				<TR>
					<TD class="grid_data" nowrap>Minimun:</TD>
					<TD class="grid_data" nowrap><cfoutput>#numberformat(data_minimum, '9,999,999')#</cfoutput></TD>
				</TR>

				<TR>
					<TD class="grid_data" nowrap>Maximum</TD>
					<TD class="grid_data" nowrap><cfoutput>#numberformat(data_maximum, '9,999,999')#</cfoutput></TD>
				</TR>

				<TR>
					<TD class="grid_data" nowrap>Average</TD>
					<TD class="grid_data" nowrap><cfoutput>#numberformat(data_average, '9,999,999')#</cfoutput></TD>
				</TR>

				<TR>
					<TD class="grid_data" nowrap>Std. Dev.</TD>
					<TD class="grid_data" nowrap><cfoutput>#numberformat(data_stddev, '9,999,999')#</cfoutput></TD>
				</TR>

			</TABLE>
		
		</td>
		<td valign="top" width="750" bgcolor="#373737">


			<cfchart   
				format=						"png"  
				chartheight=				"450"  
				chartwidth=					"750" 
				foregroundcolor=			"##FFFFFF"  
				databackgroundcolor=		"##000000" 
				fontsize=					"12"
				showlegend=					"yes"
				backgroundcolor=			"##373737">  
				<cfchartseries type="bar" query="getdata" itemcolumn="period_desc" valuecolumn="data" serieslabel="Monthly Data" seriescolor="#primarycolor#">
				</cfchartseries>
				<cfchartseries type="line" serieslabel="Average Data" seriescolor="##ffffff" markerstyle="none">
					<cfloop query="getdata">
						<cfchartdata item="#period_desc#" value="#data_average#">
					</cfloop>
				</cfchartseries>
			</cfchart> 


		</td>
	</tr>
</table>

