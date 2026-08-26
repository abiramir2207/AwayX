<!------Formula_Price_Display_Commodity_Data.cfm----->
<CFPARAM NAME="HOW_MANY_COMMS" 	DEFAULT="0">
<CFSET SubTotal_Weighted_Cost = 0>
<CFSET adjusted_today = release_Date> 

<!--- find the last friday --->
<CFSET LAST_FRIDAY = #DATEADD("d", -DAYOFWEEK(adjusted_today)+6-7, adjusted_today)#>

<CFSET Grand_Total = 0>
<CFSET Proper_Commodity = 0>
<CFIF Commodity_Data.recordCount GT 0>
	<CFLOOP QUERY="Commodity_Data">
		<CFSET Commodity_Values = "">
		<CFSET comm_symbol = Commodity_Data.Symbol>
		<CFSET comm_avg = "">
		<!--- calculate the size/number of data points of the sample  --->
		<CFIF Commodity_Data.Sample_Size_UOM EQ "weeks">
			<CFSET C_sample_size=Commodity_data.Sample_Size*7>
			
			<!--- set the number of days/data points lag --->
			<CFSET sample_lag=Commodity_Data.Point_In_Time*7>
	
			<!--- start date = last friday minus the lag number of days --->
			<CFSET startdate=createodbcdate(last_friday-sample_lag)>
			
			<!--- the begining of the sample period is the startdate variable --->
			<!--- the end of the sample period is the startdate minus the size of the sample plus 3  --->
			<!--- so that the period really ends on the monday: first day of the last week --->			
			<CFSET enddate=createodbcdate(startdate - C_sample_size + 3)>
			
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<!------Get Commodity Value from database----->
			<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
			<CFIF DateDiff("d", startdate, Now()) GTE 0>
				<!------<CFQUERY NAME="Commodity_Values" DATASOURCE="#application.datasource#">
					SELECT 	comm_datetime, COMM_LAST 
					FROM 	commodities 
					where 
							comm_symbol = '#comm_symbol#'
							and 
							comm_datetime <= #startdate#
							and 
							comm_datetime >= #enddate#
							and
							Comm_Flag = 1
							and
							comm_datetime = 							
							(select top 1 c1.comm_datetime
							from 	commodities c1
							where
									c1.comm_symbol = commodities.comm_symbol
									and
									c1.comm_datetime = commodities.comm_datetime
									and
									c1.Comm_Flag = 1
							order by comm_datetime DESC)
					order by comm_datetime desc
				</CFQUERY>		----->		
				<CFQUERY NAME="Commodity_Values" DATASOURCE="#application.datasource#">
					SELECT 	comm_datetime, COMM_LAST 
					FROM 	commodities 
					where 
							comm_symbol = '#comm_symbol#'
							and 
							comm_datetime <= #startdate#
							and 
							comm_datetime >= #enddate#
							and
							Comm_Flag = 1							
					group by comm_datetime, COMM_LAST
					order by comm_datetime desc
				</CFQUERY>		
			</CFIF>
			<CFSET Commodity_Start_Row = 1>
		<CFELSE>
			<CFSET sample_lag=Commodity_Data.Point_In_Time>
			<CFSET C_sample_size=Commodity_data.Sample_Size>
			
			<CFSET startdate=adjusted_today>										
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
			<!------Get Commodity Value from database----->
			<!------xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
			<CFIF DateDiff("d", startdate, Now()) GTE 0>
				<CFSET startdate=createodbcdate(startdate)>
				
				
				<!------
				<CFQUERY NAME="Commodity_Values" DATASOURCE="#application.datasource#">
					SELECT 	top #C_sample_size# comm_datetime, COMM_LAST 
					FROM 	commodities 
					where 
							comm_symbol = '#comm_symbol#'
							and 
							comm_datetime <= #startdate#
							and
							Comm_Flag = 1
							and
							comm_datetime = 
							(select top 1 c1.comm_datetime
							from 	commodities c1
							where
									c1.comm_symbol = commodities.comm_symbol
									and
									c1.comm_datetime = commodities.comm_datetime
									and
									c1.Comm_Flag = 1
							order by comm_datetime DESC)
							and
							commodities_id
							not in
							(
								SELECT 	top #sample_lag# c2.commodities_id
								FROM 	commodities c2
								where 
										c2.comm_symbol = '#comm_symbol#'
										and 
										c2.comm_datetime <= #startdate#
										and
										c2.Comm_Flag = 1
										and
										c2.comm_datetime = 
										(select top 1 c1.comm_datetime
										from 	commodities c1
										where
												c1.comm_symbol = c2.comm_symbol
												and
												c1.comm_datetime = c2.comm_datetime
												and
												c1.Comm_Flag = 1
										order by comm_datetime DESC)
								order by c2.comm_datetime desc
							)
					order by comm_datetime desc
				</CFQUERY>			----->
				
				
				<!------<CFQUERY NAME="Exclude_Commodity_Values" DATASOURCE="#application.datasource#">					
					SELECT 	top #sample_lag# c2.commodities_id
					FROM 	commodities c2
					where 
							c2.comm_symbol = '#comm_symbol#'
							and 
							c2.comm_datetime <= #startdate#
							and
							c2.Comm_Flag = 1
							and
							c2.comm_datetime = 
							(select top 1 c1.comm_datetime
							from 	commodities c1
							where
									c1.comm_symbol = c2.comm_symbol
									and
									c1.comm_datetime = c2.comm_datetime
									and
									c1.Comm_Flag = 1
							order by comm_datetime DESC)
					order by c2.comm_datetime desc							
				</CFQUERY>
				<CFSET Exclude_List = ValueList(Exclude_Commodity_Values.commodities_id, ",")>						
				<CFQUERY NAME="Commodity_Values" DATASOURCE="#application.datasource#">
					SELECT 	top #C_sample_size# comm_datetime, COMM_LAST 
					FROM 	commodities 
					where 
							comm_symbol = '#comm_symbol#'
							and 
							comm_datetime <= #startdate#
							and
							Comm_Flag = 1
							and
							comm_datetime = 
							(select top 1 c1.comm_datetime
							from 	commodities c1
							where
									c1.comm_symbol = commodities.comm_symbol
									and
									c1.comm_datetime = commodities.comm_datetime
									and
									c1.Comm_Flag = 1
							order by comm_datetime DESC)
							<CFIF Exclude_List NEQ "">
							and
							commodities_id
							not in (#Exclude_List#)
							</CFIF>
					order by comm_datetime desc
				</CFQUERY>----->
				
				
				<!------<CFQUERY NAME="Commodity_Values" DATASOURCE="#application.datasource#">
					SELECT 	top #Evaluate("#C_sample_size#+#sample_lag#")# comm_datetime, COMM_LAST 
					FROM 	commodities 
					where 
							comm_symbol = '#comm_symbol#'
							and 
							comm_datetime <= #startdate#
							and
							Comm_Flag = 1
							and
							comm_datetime = 
							(select top 1 c1.comm_datetime
							from 	commodities c1
							where
									c1.comm_symbol = commodities.comm_symbol
									and
									c1.comm_datetime = commodities.comm_datetime
									and
									c1.Comm_Flag = 1
							order by comm_datetime DESC)
					order by comm_datetime desc
				</CFQUERY>	----->	
				<CFQUERY NAME="Commodity_Values" DATASOURCE="#application.datasource#">
					SELECT 	top #Evaluate("#C_sample_size#+#sample_lag#")# comm_datetime, COMM_LAST 
					FROM 	commodities 
					where 
							comm_symbol = '#comm_symbol#'
							and 
							comm_datetime <= #startdate#
							and
							Comm_Flag = 1							
					group by comm_datetime, COMM_LAST
					order by comm_datetime desc
				</CFQUERY>	
			</CFIF>			
			<CFSET Commodity_Start_Row = sample_lag + 1>			
		</CFIF>
		
		<CFIF IsQuery(Commodity_Values)>
		<CFOUTPUT>		
		<CFSET SHOW_FORMULA_PRICING_DETAIL_INFO = 1>
		<CFSET HOW_MANY_COMMS = HOW_MANY_COMMS + 1>
		<CFIF ISDefined("THIS_PRODUCT_FORMULA_PRICING_RULA_NAME")>
		<CFSET AName_Program_Formula_Pricing_Rule_Comm_Data_ID = ReplaceNoCase(Program_Formula_Pricing_Rule_Comm_Data_ID, "-", "_", "all")>
		<D_A NAME="#AName_Program_Formula_Pricing_Rule_Comm_Data_ID#"></D_A>
		<TABLE BORDER="0" WIDTH="100%" <CFIF HOW_MANY_COMMS GT 1 AND NOT Fax_Version>CLASS="pageBreakBefore"</CFIF>>
			<CFIF IsDefined("Get_Program_Info")>
			<TR>
				<TD STYLE="font-size: 12px; color: NAVY;" NOWRAP COLSPAN="2">
				<SPAN STYLE="font-weight:bold; font-size: 12px;">[#Get_Program_Info.Contract_Number#]&nbsp;&nbsp;&nbsp;&nbsp;#Get_Program_Info.Contract_Title#</SPAN>
				</TD>
				<TD WIDTH="100%">&nbsp;</TD>
			</TR>
			</CFIF>
			<TR>
				<TD STYLE="font-size: 12px; color: NAVY;" NOWRAP><B>RULE NAME:</B></TD>
				<TD STYLE="font-size: 12px;" ALIGN="right" NOWRAP><B>#THIS_PRODUCT_FORMULA_PRICING_RULA_NAME#</B></TD>
				<TD WIDTH="100%">&nbsp;</TD>
			</TR>
			<TR>
				<TD COLSPAN="100%">
				<HR COLOR="Orange">
				</TD>
			</TR>
		</TABLE>
		</CFIF>
		<TABLE ALIGN="CENTER" WIDTH="80%">
		<TR>
		<TD>
		<TABLE CELLPADDING="0" CELLSPACING="0">
			<COLGROUP>
				<COL SPAN="1"></COL>
				<COL SPAN="1" WIDTH="20"></COL>
				<COL SPAN="1"></COL>
			</COLGROUP>
			<TR>
				<TD><B>Exchange:</B></TD>
				<TD></TD>
				<TD><B>#Commodity_Data.Exchange_Detail_Name#</B></TD>
			</TR>
			<TR>
				<TD><B>Commodity:</B></TD>
				<TD></TD>
				<TD><B>#Commodity_Data.Symbol_Description#</B></TD>
			</TR>
			<TR>
				<TD><B>Release Date:</B></TD>
				<TD></TD>
				<TD><B>#DateFormat(periods.Requested_Period_Info.Release_Date,'m/d/yyyy')#</B></TD>
			</TR>
			<TR>
				<TD><B>Lag:</B></TD>
				<TD></TD>
				<TD><B>#Commodity_Data.Point_In_Time# #Commodity_Data.Point_In_Time_UOM#</B></TD>
			</TR>
			<TR>
				<TD><B>Sample Size:</B></TD>
				<TD></TD>
				<TD><B>#Commodity_Data.Sample_Size# #Commodity_Data.Sample_Size_UOM#</B></TD>
			</TR>
		</TABLE>
		</CFOUTPUT>
		<TABLE BGCOLOR="Silver" CELLPADDING="2" CELLSPACING="1" WIDTH="300">
			<COLGROUP>
				<COL SPAN="1" WIDTH="10%"></COL>
				<COL SPAN="1" WIDTH="30%"></COL>
				<COL SPAN="2" ALIGN="RIGHT" WIDTH="30%"></COL>
			</COLGROUP>
			<TR BGCOLOR="Khaki">
				<TD><B>#</B></TD>
				<TD><B>Date</B></TD>
				<TD><B>Closing Price</B></TD>
				<TD><B>&#931; Closing Price</B></TD>
			</TR>
			<CFSET Comm_Total_Value = 0>
			<CFSET D_Counter = 0>
			<CFIF Commodity_Values.RecordCount GT 0>
			<CFOUTPUT QUERY="Commodity_Values" startrow="#Commodity_Start_Row#">
				<CFSET D_Counter = D_Counter + 1>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD BGCOLOR="White">#D_Counter#</TD>
				<TD BGCOLOR="White">#dateformat(Comm_Datetime, 'm/d/yyyy')#</TD>
				<TD BGCOLOR="White">#numberformat(Comm_Last, '_.____')#</TD>
				<CFSET Comm_Total_Value = Comm_Total_Value + Comm_Last>
				<TD BGCOLOR="White">#numberformat(Comm_Total_Value, '_.____')#</TD>
			</TR>
			</CFOUTPUT>
			<TR BGCOLOR="EEEEEE">
				<CFOUTPUT>
				<CFSET Total_Count = Commodity_Values.RecordCount - Commodity_Start_Row + 1>
				<CFSET Comm_Avg_Value = Comm_Total_Value / Total_Count>
				<TD COLSPAN="100%" ALIGN="Right" STYLE="FONT-SIZE:12px;"><B>Average Closing Price (#numberformat(Comm_Total_Value, '_.____')# / #Total_Count#) = #numberformat(Comm_Avg_Value, '_.____')#</B></TD>
				</CFOUTPUT>
			</TR>
			</CFIF>
		</TABLE>
		</CFIF>
		</TD>
		<TD WIDTH="100%">&nbsp;</TD></TR></TABLE>
	</CFLOOP>
</CFIF>