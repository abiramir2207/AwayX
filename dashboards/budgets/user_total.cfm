<!--- ----------------------------------------------------------------------------------------- --->

<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
    SELECT *

    FROM   dashboards_budget_weekly_summary

    WHERE  user_id = '#request.AccessStructure.User_ID#'

</cfquery>

<!--- ----------------------------------------------------------------------------------------- --->

<!--- 
49FB11F4-AAF5-4AC5-15994D128A934A0A	Angela Letourneau
4A027CD6-B323-1E5E-690959375A110CC9	Brenda Grubbs
4A2D0B73-0895-028A-ACD0CCA7BC9E5B5A	Denny Ruff
4A0D0002-D8E8-0F2E-0E28CD2B44EECB54	Gene Coats
49EFA4C2-0B66-3A32-8F1D49AC1847ECEF	Heather Irimi
4A153540-9A7A-5C8D-3742F689831CE00C	Jim Holacka
4A4FF190-E0C0-5B43-1B324D3EEC7A912E	Jim Smith
4A33310D-DA78-5CFC-00DE0EA26564F613	John Reilly
4A70BBC1-07C8-B7C7-0A3BF0C3F8EDFC2F	Leon Lyon
4A7AAC6D-B135-BA24-A0FB45101EC75C3C	Nancy Muller
4A40A790-9253-EEA3-D7E6C19C129E659A	Randy Baker
49E65BD8-B90A-480A-CF18BCEE52B8DB01	Robert Romano
4A1BBEF2-BF58-E087-FE5CAE374E20212B	Shawn Rener
4A56CE74-9A67-8702-1D922DC6A44E5972	Tom Gonzalez
4A5D5196-F754-B0DB-6582B91119B4E451	Tom Johns
4A254451-BDAD-83AD-AEE41055564B3322	Vic Nwachukwu
 --->



<!--- ----------------------------------------------------------------------------------------- --->
<div class="user_name">
	<cfoutput>#ucase(Get_Data_1.user_name)#</cfoutput>
</div>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->

<table border="0" cellspacing="10" cellpadding="0">
  <tr>
    <td>
		<!--- COMMITED ----------------------------------------------------------------------------------------- --->

            <div class="chart_title">Budget Allocation</div>

            <cfchart   
                format=						"png"  
                chartheight=				"240"  
                chartwidth=					"445"  
                showlegend=					"no"  
                backgroundcolor=			"000000"  
                labelformat=				"currency"  
                foregroundcolor=			"bbbbbb"  
                show3d=						"no"  
                databackgroundcolor=		"000000"  
                showxgridlines=				"no"  
                showygridlines=				"yes"  
                >  
                <cfchartseries type="bar" seriescolor="##FF3300" paintstyle="light" colorlist="##FF9900,##009900,##FF3300"> 
                    <cfchartdata item = "Budget" value = #Val(Get_Data_1.budget_dollars)/1000#>
                    <cfchartdata item = "Commit" value = #Val(Get_Data_1.budget_dollars_commit)/1000#>
                    <cfchartdata item = "Paid" value = #Val(Get_Data_1.budget_dollars_paid)/1000#>
                </cfchartseries>
            </cfchart> 

    </td>
    <td>
		<!--- PAID ----------------------------------------------------------------------------------------- --->
        
            <div class="chart_title">Per EQ Case...</div>

            <cfchart 
                format =					"png" 
                chartHeight = 				"240" 
                chartwidth =				"445" 
                showxgridlines=				"yes" 
                showygridlines=				"no"
                gridlines=					"9"
                foregroundcolor =			"##FFFFFF" 
                databackgroundcolor =		"##000000" 
                labelformat =				"currency"
                backgroundcolor =			"##000000"
                > 
    
                <cfchartseries type="horizontalbar" paintstyle="shade" colorlist="##ffffff,##ffffff,##ffffff"> 
                    <cfchartdata item = "Budget" value = #Val(Get_Data_1.budget_dollars_per_eqc)#>
                    <cfchartdata item = "Commit" value = #Val(Get_Data_1.budget_commit_per_eqc)#>
                    <cfchartdata item = "Paid" value = #Val(Get_Data_1.budget_paid_per_eqc)#>
                </cfchartseries>
            </cfchart>

    </td>
  </tr>
</table>

<cfoutput>

<table width="900" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td class="grid_column_title">&nbsp;</td>
		<td class="grid_column_title">Budget</td>
		<td class="grid_column_title">Commit</td>
		<td class="grid_column_title">Paid</td>
	</tr>
	<cfif Get_Data_1.recordcount>
	<tr>
		<td class="grid_legend">dollars</td>
		<td class="grid_data">#mydollarformat(Get_Data_1.budget_dollars)#&nbsp;</td>
		<td class="grid_data">#mydollarformat(Get_Data_1.budget_dollars_commit)#&nbsp;</td>
		<td class="grid_data">#mydollarformat(Get_Data_1.budget_dollars_paid)#&nbsp;</td>
	</tr>
	<tr>
		<td class="grid_legend">balance</td>
		<td class="grid_data">n/a</td>
		<td class="grid_data">#mydollarformat(Get_Data_1.budget_commit_bal)#&nbsp;</td>
		<td class="grid_data">#mydollarformat(Get_Data_1.budget_paid_bal)#&nbsp;</td>
	</tr>
	<tr>
		<td class="grid_legend">percent</td>
		<td class="grid_data">n/a</td>
		<td class="grid_data">#numberformat(Get_Data_1.budget_commit_percent*100, "___._")#%&nbsp;</td>
		<td class="grid_data">#numberformat(Get_Data_1.budget_paid_percent*100, '___._')#%</td>
	</tr>
	<tr>
		<td class="grid_legend">equivalent cases</td>
		<td class="grid_data">#numberformat(Get_Data_1.budget_eq_cs, ',')#&nbsp;</td>
		<td class="grid_data">n/a</td>
		<td class="grid_data">n/a</td>
	</tr>
	<tr>
		<td class="grid_legend">per eq case</td>
		<td class="grid_data">#dollarformat(Get_Data_1.budget_dollars_per_eqc)#&nbsp;</td>
		<td class="grid_data">#dollarformat(Get_Data_1.budget_commit_per_eqc)#&nbsp;</td>
		<td class="grid_data">#dollarformat(Get_Data_1.budget_paid_per_eqc)#&nbsp;</td>
	</tr>
	</cfif>
</table>

</cfoutput>

<br />

