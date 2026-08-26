<CFIF NOT IsDefined("DATE_GRAPH_HEIGHT")>
	<CFINCLUDE TEMPLATE="Date_Graph_Settings.cfm">
</CFIF>

<cfif not isDefined("genSettingsManager")>
	<!---get application settings--->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif> 

<CFQUERY NAME="Get_BB_Info" DATASOURCE="#application.datasource#">
	SELECT	Billback.Billback_ID, Billback.BB_Start_Date, Billback.BB_End_Date, Billback_Product.Product_ID, Billback.Billback_Payee_Type_ID,
			Contract_Main.Contract_Number, BB_Approved.Date_Approved,
			Billback_Product_Detail.BB_Product_Type_ID,
			Billback_Product.Distributor_ID,
			Billback.Uploaded_Billback,
			Billback_Allied.Tier
	FROM	Billback_Product_Detail
			INNER JOIN Billback_Product
			ON
			Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
			AND
			Billback_Product.Deleted = 0
			INNER JOIN Billback_Program
			ON
			Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
			AND
			Billback_Program.Deleted = 0
			INNER JOIN	Contract_Main
			ON
			(
					(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
			)
			INNER JOIN Billback
			ON
			Billback.Billback_ID = Billback_Program.Billback_ID
			AND
			Billback.Deleted = 0
			LEFT JOIN BB_Approved
			ON
			(
				(BB_Approved.Billback_ID = Billback.Billback_ID)
				AND
				(Billback.Billback_Status_ID >= 3)
			)
			LEFT JOIN Billback_Allied
			ON Billback_Allied.Billback_ID = Billback.Billback_ID
	WHERE
			Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
			AND
			Billback_Product_Detail.Deleted = 0
</CFQUERY>


<CFSET Billback_ID		=	Get_BB_Info.Billback_ID>
<CFSET BB_Start_Date	=	Get_BB_Info.BB_Start_Date>
<CFSET BB_End_Date		=	Get_BB_Info.BB_End_Date>
<CFSET BSA_Foodservice_Items_Master_ID = Get_BB_Info.Product_ID>
<CFSET Billback_Payee_Type_ID = Get_BB_Info.Billback_Payee_Type_ID>
<CFSET Date_Approved = Get_BB_Info.Date_Approved>
<CFSET Program_Number = Get_BB_Info.Contract_Number>
<CFSET BB_Product_Type_ID = Get_BB_Info.BB_Product_Type_ID />
<CFSET Associated_Distributor_ID = Get_BB_Info.Distributor_ID />

<cfset ProductReplacementID = "" />
<cfif appSettings.getProductReplacementEnabled()>
	<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
	<cfset ProductReplacementID = BillbackDeviationManager.getProductReplacementID(productId=BSA_Foodservice_Items_Master_ID)>
</cfif>

<CFINCLUDE TEMPLATE="BB_Payee.cfm">

<cfquery dataSource="#application.datasource#" NAME="getUseGPO">
	SELECT	dbo.udf_UseGPO('#Billback_ID#', #Get_BB_Info.Uploaded_Billback#) as UseGPO
</CFQUERY>
<cfset bUseGPO = getUseGPO.UseGPO />
	
<CFQUERY  dataSource="#application.datasource#" NAME="All_Overlapped_Billbacks">
	<cfif appSettings.Claims_at_Comp_Level>
		IF OBJECT_ID('tempdb..##Billback_Rebate') IS NOT NULL
		DROP TABLE ##Billback_Rebate

		select distinct Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, Program_Rebates_Component_Name
		into	##Billback_Rebate
		from 	Billback_Program_Rebate_Component
		inner join Contract_Main
		on		Contract_Main.Contract_Main_ID = Billback_Program_Rebate_Component.Billback_Program_ID
		where 	Billback_ID = '#Billback_ID#'
		and 	Billback_Program_Rebate_Component.deleted = 0
		and 	Billback_Program_Rebate_Component.checked = 'true'
	</cfif>
	
	/*SELECT	*
	FROM
	(*/
		SELECT	DISTINCT Billback.Billback_ID, Billback.BB_Start_Date, Billback.BB_End_Date
				, Billback.BB_Code, Billback.BB_Title, 0 AS THIS_BILLBACK
		FROM	Billback
					<CFIF Date_Approved NEQ "">
						<CFIF IsDate(Date_Approved)>
							INNER JOIN BB_Approved
							ON
							(
								(BB_Approved.Billback_ID = Billback.Billback_ID)
								AND
								(dbo.D_DATEDIFF('ms', BB_Approved.Date_Approved, '#Date_Approved#') >= 0)
								--(dbo.D_DATEDIFF('ms', BB_Approved.Date_Approved, #CreateODBCDateTime(Date_Approved)#) > 0)
								--(DATEDIFF(ms, BB_Approved.Date_Approved, #CreateODBCDateTime(Date_Approved)#) > 0)
							)
						</CFIF>
					</CFIF>
					INNER JOIN	Billback_Program
					ON
					(
						(Billback_Program.Billback_ID = Billback.Billback_ID)
						AND
						(Billback_Program.Deleted = 0)
					)
					INNER JOIN	Contract_Main
					ON
					(
						(Contract_Main.Contract_Number = '#Program_Number#')
						AND
						(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
					)
					<cfif appSettings.Claims_at_Comp_Level>
						left JOIN  Billback_Program_Rebate_Component
							on Billback_Program_Rebate_Component.billback_program_id = Contract_Main.contract_main_id 
							and Billback_Program_Rebate_Component.billback_id = billback.billback_id
					</cfif>
					INNER JOIN	Billback_Product
					ON
					(
						(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
						AND
						(Billback_Product.Deleted = 0)
						<CFIF BSA_Foodservice_Items_Master_ID NEQ "">
						AND
						(Billback_Product.Product_ID IN ('#BSA_Foodservice_Items_Master_ID#'<cfif ProductReplacementID neq "">,'#ProductReplacementID#'</cfif>))
						<CFELSE>
						AND
						(1=2)
						</CFIF>
						<CFIF Associated_Distributor_ID NEQ "">
						AND	Billback_Product.Distributor_ID = '#Associated_Distributor_ID#'
						</CFIF>
					)
					INNER JOIN	Billback_Product_Detail
							on 	Billback_Product_Detail.Billback_ID = billback.billback_id
							and Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
							and Billback_Product_Detail.deleted = 0
					INNER JOIN	BB_Item_Final
					ON
					(
						(BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID)
						AND
						(BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID)
						AND
						(BB_Item_Final.Deleted = 0)
					)
					INNER JOIN 	BB_Item_Final_Detail ON BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID AND
								BB_Item_Final_Detail.BB_Product_Type = #BB_Product_Type_ID# AND
								BB_Item_Final_Detail.Deleted = 0
			WHERE
				Billback.Deleted = 0
				AND
				Billback.Billback_Status_ID >= #DEVIATION_OVERLAPPED_BB_STATUS#
				AND 	Billback.Billback_Status_ID <> 8
				AND
				Billback.Billback_ID <> '#Billback_ID#'
				AND Billback.BB_Amount > 0
				
				<cfif bUseGPO AND Val(Get_BB_Info.Tier) NEQ 0>
				/* 82368 Either billback does not have Tier Or Overlapping billback has matcjing Tier. Tier will be populated only for GPO Tier billbacks */
				AND EXISTS (SELECT 1 FROM Billback_Allied BBOlapAllied WHERE BBOlapAllied.Billback_ID = Billback.Billback_ID AND BBOlapAllied.Tier = '#Val(Get_BB_Info.Tier)#')
				</cfif>
							
				<cfif appSettings.Claims_at_Comp_Level>
				AND (
						(	Billback_Product_Detail.BB_Product_Type_ID = 2
							AND Billback_Program_Rebate_Component.deleted = 0
							and Billback_Program_Rebate_Component.checked = 'true'
							and Billback_Program_Rebate_Component.Program_Rebates_Component_Name
								in ( 	select distinct Program_Rebates_Component_Name
										from ##Billback_Rebate as Billback_Rebate
										where Billback_Rebate.contract_number = contract_Main.contract_number
									)
							)
							or Billback_Product_Detail.BB_Product_Type_ID != 2
						)
				</cfif>
				
				<!--- 
				BJF: Commented ot match stored procedure
				<cfif appSettings.Claims_at_Comp_Level>
						AND (
								(	Billback_Product_Detail.BB_Product_Type_ID = 2
									AND Billback_Program_Rebate_Component.deleted = 0 
									and Billback_Program_Rebate_Component.checked = 'true' 
									and Billback_Program_Rebate_Component.Program_Rebates_Component_Name
										in ( 	select distinct Program_Rebates_Component_Name
												from Billback_Program_Rebate_Component
												where Billback_ID = '#Billback_ID#'
												and deleted = 0
												and billback_program_id = Billback_Program.Program_ID
												and checked = 'true'
											)
								)
								or 	Billback_Product_Detail.BB_Product_Type_ID != 2
						)
				</cfif>  --->
				<CFSWITCH EXPRESSION="#Billback_Payee_Type_ID#">
				<CFCASE VALUE="1">
				AND
				EXISTS
				(
					SELECT Billback_Distributor.Billback_Distributor_ID
					FROM	Billback_Distributor
					WHERE
							Billback_Distributor.Billback_ID = Billback.Billback_ID
							AND
							Billback_Distributor.Distributor_ID = '#Payee_ID#'						
							AND
							Billback_Distributor.Deleted = 0
							AND
							Billback.Billback_Payee_Type_ID = 1
				)
				</CFCASE>
				<CFCASE VALUE="2">
				AND
				EXISTS
				(
					SELECT Billback_Operator.Billback_Operator_ID
					FROM	Billback_Operator
					WHERE
							Billback_Operator.Billback_ID = Billback.Billback_ID
							AND
							Billback_Operator.Operator_ID = #Payee_ID#
							AND
							Billback_Operator.Deleted = 0
							AND
							Billback.Billback_Payee_Type_ID = 2	
						<CFIF Associated_Ship_To neq "">
							AND 
							Billback_Operator.Associated_Ship_To = '#Associated_Ship_To#'	
						</CFIF>
				)
				</CFCASE>
				<CFCASE VALUE="3">
				AND
				EXISTS
				(
					SELECT Billback_Broker.Billback_Broker_ID
					FROM	Billback_Broker
					INNER JOIN BSA_Foodservice_Brokers
					ON		BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
					AND		BSA_Foodservice_Brokers.Broker_Legcy_Shard = '#Payee_Number#'					
					WHERE
							Billback_Broker.Billback_ID = Billback.Billback_ID
							AND
							Billback_Broker.Deleted = 0
							AND
							Billback.Billback_Payee_Type_ID = 3
						<CFIF Associated_Ship_To neq "">
							AND 
							Billback_Broker.Associated_Ship_To = '#Associated_Ship_To#'	
						</CFIF>
				)
				</CFCASE>
				</CFSWITCH>				
				AND
				(
					(
						(DATEDIFF(d, #CreateODBCDate(BB_Start_Date)#, Billback.BB_Start_Date) >= 0)
						AND
						(DATEDIFF(d, Billback.BB_Start_Date, #CreateODBCDate(BB_End_Date)#) >= 0)
					)
					OR
					(
						(DATEDIFF(d, #CreateODBCDate(BB_Start_Date)#, Billback.BB_End_Date) >= 0)
						AND
						(DATEDIFF(d, Billback.BB_End_Date, #CreateODBCDate(BB_End_Date)#) >= 0)
					)
					OR
					(
						(DATEDIFF(d, Billback.BB_Start_Date, #CreateODBCDate(BB_Start_Date)#) >= 0)
						AND
						(DATEDIFF(d, #CreateODBCDate(BB_Start_Date)#, Billback.BB_End_Date) >= 0)
					)
					OR
					(
						(DATEDIFF(d, Billback.BB_Start_Date, #CreateODBCDate(BB_End_Date)#) >= 0)
						AND
						(DATEDIFF(d, #CreateODBCDate(BB_End_Date)#, Billback.BB_End_Date) >= 0)
					)
				)
			
		UNION
		
		SELECT	Billback.Billback_ID, Billback.BB_Start_Date, Billback.BB_End_Date
				--,DATEDIFF(d, Billback.BB_Start_Date, Billback.BB_End_Date) AS Number_Of_Days
				, Billback.BB_Code, Billback.BB_Title, 1 AS THIS_BILLBACK
		FROM	Billback_Product_Detail
				INNER JOIN	Billback_Product
				ON
				(
					(Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID)
					AND
					(Billback_Product.Deleted = 0)
				)
				INNER JOIN	Billback_program
				ON
				(
					(Billback_program.Billback_program_ID = Billback_Product.Billback_program_ID)
					AND
					(Billback_program.Deleted = 0)
				)
				INNER JOIN	Billback
				ON
				(
					(Billback.Billback_ID = Billback_program.Billback_ID)
					AND
					(Billback.Deleted = 0)				
				)
		WHERE
			Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
			AND
			Billback_Product_Detail.Deleted = 0
	/*) AS OTHER_BILLBACKS	
	ORDER BY BB_Start_Date*/
</CFQUERY>


<cfset useLakebaseForT_All_Overlapped_Billbacks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("all_overlapped_billbacks")>
<cfif useLakebaseForT_All_Overlapped_Billbacks>
	<cftry>
		<cfset T_All_Overlapped_Billbacks = application.oLakebase.toQuery(
			application.oLakebase.selectRows("all_overlapped_billbacks", {
				"order" = "bb_start_date.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForT_All_Overlapped_Billbacks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForT_All_Overlapped_Billbacks>
<CFQUERY NAME="T_All_Overlapped_Billbacks" DBTYPE="query">
	SELECT	*
	FROM	All_Overlapped_Billbacks
	ORDER BY BB_Start_Date
</CFQUERY>
</cfif>

<CFSET All_Overlapped_Billbacks = T_All_Overlapped_Billbacks>

<CFIF All_Overlapped_Billbacks.recordCount GT 0>
	<CFQUERY DBTYPE="QUERY" NAME="Last_Date">
		SELECT	BB_End_Date
		FROM	All_Overlapped_Billbacks
		ORDER BY BB_End_Date DESC
	</CFQUERY>
	
	<CFSET first_Date = All_Overlapped_Billbacks.BB_Start_Date>
	<CFSET last_Date = Last_Date.BB_End_Date>
	
	<CFSET Total_date_Span=DateDiff("d", first_Date, last_Date) + 1>
	
	
	<CFOUTPUT>
	<STYLE>
		TABLE.Date_Dev_Table
		{
			/*border-left:solid blue 1px;
			border-bottom:solid blue 1px;*/
		}
		
		TR.This_Billback TD
		{
			font-weight:bold;
		}
	</STYLE>
	
	</CFOUTPUT>
	
	
	<CFQUERY DBTYPE="QUERY" NAME="Get_All_Dates">
		SELECT	Billback_ID, BB_Start_Date AS This_Date, THIS_BILLBACK + 0 AS Date_Type
		FROM	All_Overlapped_Billbacks
		UNION
		SELECT	Billback_ID, BB_End_Date AS This_Date, THIS_BILLBACK + 2 AS Date_Type
		FROM	All_Overlapped_Billbacks	
	</CFQUERY>
	
	<CFQUERY DBTYPE="QUERY" NAME="Get_All_Dates_Ordered">
		SELECT	Billback_ID, This_Date, Date_Type
		FROM	Get_All_Dates
		ORDER BY 	This_Date, Date_Type
	</CFQUERY>
	
	<CFSET This_Billback_Intervals="">
	<CFSET Other_Billbacks_Started 	= 0>
	<CFSET This_Billback_Started 	= false>
	<CFSET Start_Counting			= false>
	<CFSET Total_Overlap			= 0>
	<CFSET D_First_Date				= "">
	<CFSET D_Last_Date				= "">
	<CFSET Stop_Loop				= false>
	<CFSET last_Mile_Stone			= "">
	
	
	<CFLOOP QUERY="Get_All_Dates_Ordered">	
		<CFIF Get_All_Dates_Ordered.Date_Type EQ 0>
			<!----- Other Billback STart ---->
			<CFIF This_Billback_Started EQ true>
				<CFSET Start_Counting = true>
				<CFIF Other_Billbacks_Started LTE 0>
					<CFSET D_First_Date	= Get_All_Dates_Ordered.This_Date>
					<CFIF DATEDIFF("d", last_Mile_Stone, Get_All_Dates_Ordered.This_Date) GTE 0>
						<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#last_Mile_Stone#~#DateAdd("d", -1, Get_All_Dates_Ordered.This_Date)#~A", ",")>
					</CFIF>
				</CFIF>
			</CFIF>
			<CFSET Other_Billbacks_Started 	= Other_Billbacks_Started + 1>
		<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 1>
			<!---- This Billback Start ---->
			<CFSET This_Billback_Started 	= true>
			<CFIF Other_Billbacks_Started GT 0>
				<CFSET Start_Counting = true>
				<CFSET D_First_Date	= Get_All_Dates_Ordered.This_Date>
			</CFIF>
			<CFSET last_Mile_Stone			= Get_All_Dates_Ordered.This_Date>
		<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 2>
			<!---- Other billback End ---->
			<CFSET Other_Billbacks_Started 	= Other_Billbacks_Started - 1>
			<CFIF Other_Billbacks_Started LTE 0>
				<CFIF Start_Counting>
					<CFSET D_Last_Date	= Get_All_Dates_Ordered.This_Date>
					<CFIF IsDate(D_First_Date) AND IsDate(D_Last_Date)>				
						<CFSET Total_Overlap = Total_Overlap + DateDiff("d", D_First_Date, D_Last_Date) + 1>
						<CFIF DATEDIFF("d", D_First_Date, D_Last_Date) GTE 0>
							<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#D_First_Date#~#D_Last_Date#~B", ",")>
						</CFIF>
						<CFSET last_Mile_Stone			= DateAdd("d", 1, Get_All_Dates_Ordered.This_Date)>
					</CFIF>
				</CFIF>
				<CFSET Start_Counting = false>
			</CFIF>
		<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 3>
			<!----- This Billback End ---->
			<CFIF Start_Counting>
				<CFSET D_Last_Date	= Get_All_Dates_Ordered.This_Date>
				<CFIF IsDate(D_First_Date) AND IsDate(D_Last_Date)>				
					<CFSET Total_Overlap = Total_Overlap + DateDiff("d", D_First_Date, D_Last_Date) + 1>
					<CFIF DATEDIFF("d", D_First_Date, D_Last_Date) GTE 0>
						<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#D_First_Date#~#D_Last_Date#~B", ",")>			
					</CFIF>
				</CFIF>
			<CFELSE>
				<CFIF DATEDIFF("d", last_Mile_Stone, Get_All_Dates_Ordered.This_Date) GTE 0>
					<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#last_Mile_Stone#~#Get_All_Dates_Ordered.This_Date#~A", ",")>	
				</CFIF>
			</CFIF>
			<CFSET This_Billback_Started 	= false>
			<CFSET Stop_Loop				= true>
			<CFSET Start_Counting			= false>		
		</CFIF>
		<!------
		<CFOUTPUT>
		#Get_All_Dates_Ordered.This_Date# - #Get_All_Dates_Ordered.Date_Type# <BR>
		Start_Counting - #Start_Counting#<BR>
		First_Date - #First_Date# <BR>
		Last_Date - #Last_Date# <BR>
		Total_Overlap - #Total_Overlap#<BR>	
		last_Mile_Stone - #last_Mile_Stone#<BR>
		#This_Billback_Intervals#<BR>	
		<HR>
		</CFOUTPUT>		
		----->
		<CFIF Stop_Loop>
			<CFBREAK>
		</CFIF>	
	</CFLOOP>
	
	<!--------
	<CFOUTPUT>#This_Billback_Intervals#</CFOUTPUT><HR>
	------->
	
	<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
		<COLGROUP>
			<COL SPAN="2" NOWARAP STYLE="FONT-WEIGHT:BOLD;"></COL>
			<COL SPAN="2" NOWARAP></COL>
			<COL SPAN="1" WIDTH=""></COL>
		</COLGROUP>
		<CFOUTPUT QUERY="All_Overlapped_Billbacks">
		<TR<CFIF THIS_BILLBACK EQ 1> CLASS="This_Billback"</CFIF>>
			<CFIF THIS_BILLBACK EQ 1>
				<CFSET This_Billback_Start_Date = BB_Start_Date>
				<CFSET This_Billback_End_Date = BB_End_Date>
			</CFIF>
			<CFSET BillbackDesc="Billback ## #BB_Code#">
			<TD>Billback</TD>
			<TD>&nbsp;:&nbsp;</TD>
			<TD>&nbsp;[#BB_Code#]</TD>
			<TD>&nbsp;#BB_Title#</TD>
			<TD>&nbsp;#DateFormat(BB_Start_Date, "mm/dd/yy")#</TD>
			<TD>&nbsp;-&nbsp;</TD>
			<TD>&nbsp;#DateFormat(BB_End_Date, "mm/dd/yy")#</TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFOUTPUT>
	</TABLE>
	<!------<CFSET show_Overlaps=true>----->
	
	<cfif All_Overlapped_Billbacks.recordcount GT 1>
		<p></p>
		<i>There are one or more competing billbacks for the same payee, program and item during the same claim period.<br>
			The volume deviation will consider the total purchased volume for the payee, less the volume claimed in the competing billbacks and the volume for this billback.<br>
		It is possible to have a billback overlap with no subsequent volume deviation.</i>
	</cfif>
	
	<HR COLOR="Orange">
	<CFOUTPUT>
	<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" CLASS="Date_Dev_Table" ALIGN="CENTER" ID="Date_Overlap_Table" BACKGROUND="/Images/Grid_Blue.gif">
	</CFOUTPUT>
		<cfsetting enableCFoutputOnly = "Yes"> 
		
		<CFLOOP QUERY="All_Overlapped_Billbacks">
			<CFSET Graph_Legend1 = "">
			<CFSET Graph_Legend2 = "">
			<CFSET Graph_Legend3 = "">
			<CFSET Graph_Legend_Script = "">
			<CFSILENT>
			<CFSET thisItem = All_Overlapped_Billbacks.CurrentRow & Replace(CreateUUID(), "-", "_", "all")>
			<CFSET Start_Date=BB_Start_Date>
			<CFSET End_Date=BB_End_Date>
			<CFIF THIS_BILLBACK EQ 1>
				<CFSET Image_Name="blue.gif">
				<CFSET GRAPH_SPAN_CLASS="GRAPHSPAN_BLUE">
			<CFELSE>
				<CFSET Image_Name="black.gif">
				<CFSET GRAPH_SPAN_CLASS="GRAPHSPAN_BLACK">
			</CFIF>
			<CFSET sDesc="Billback ## #BB_Code#">
			
			<CFSET This_Item_Empty_Span=DateDiff("d", first_Date, Start_Date)>
			<CFSET Empty_Image_len=(This_Item_Empty_Span * Max_Length)/Total_date_Span>
			</CFSILENT>
			<CFOUTPUT><TR><TD WIDTH="#Max_Length#">&nbsp;</TD></TR></CFOUTPUT>
				<CF_Graph_Full
							THIS_BILLBACK = "#THIS_BILLBACK#"
							This_Billback_Intervals = "#This_Billback_Intervals#"
							A_IMG="blue.gif"
							B_IMG="red.gif"
							A_CLASS="GRAPHSPAN_BLUE"
							B_CLASS="GRAPHSPAN_RED"
							Empty_Image_len="#Empty_Image_len#"
							Max_Length="#Max_Length#"
							Total_date_Span="#Total_date_Span#"
							thisItem="#thisItem#"
							START_DATE="#START_DATE#"
							END_DATE="#END_DATE#"
							GRAPH_SPAN_CLASS="#GRAPH_SPAN_CLASS#"
							sDesc="#sDesc#">
			<CFOUTPUT><TR><TD>&nbsp;</TD></TR></CFOUTPUT>
		</CFLOOP>
		<cfsetting enableCFoutputOnly = "No"> 
	<CFOUTPUT>
		<TR>
			<TD>&nbsp;
			</TD>
		</TR>
		<TFOOT>
			<TR>
				<TD COLSPAN="100%" ALIGN="RIGHT" BGCOLOR="White">&nbsp;
				</TD>
			</TR>
			<TR>
				<!--- STYLE="border-top:solid cccccc 1px;"--->
				<TD COLSPAN="1" ALIGN="LEFT" BGCOLOR="White">
				<!----
				<IMG SRC="/Images/Blue.gif" WIDTH="10" HEIGHT="#DATE_GRAPH_HEIGHT#">
				---->				
				<!------<SPAN CLASS="GRAPHSPAN_BLUE" STYLE="WIDTH:30px"></SPAN>----->
				<TABLE ALIGN="LEFT" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
				<TD CLASS="GRAPHSPAN_BLUE" STYLE="WIDTH:30px"></TD>
				</TR></TABLE>
				&nbsp;&nbsp;No #appSettings.getDeviationLabel()# portion of current billback<BR>
				<!----<IMG SRC="/Images/Red.gif" WIDTH="10" HEIGHT="#DATE_GRAPH_HEIGHT#">
				--->
				<!------<SPAN CLASS="GRAPHSPAN_RED" STYLE="WIDTH:30px"></SPAN>----->
				<TABLE ALIGN="LEFT" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
				<TD CLASS="GRAPHSPAN_RED" STYLE="WIDTH:30px"></TD>
				</TR></TABLE>
				&nbsp;&nbsp;#appSettings.getDeviationLabel()# portion of current billback<BR>
				<!---<IMG SRC="/Images/Black.gif" WIDTH="10" HEIGHT="#DATE_GRAPH_HEIGHT#">
				--->
				<!------<SPAN CLASS="GRAPHSPAN_BLACK" STYLE="WIDTH:30px"></SPAN>----->
				<TABLE ALIGN="LEFT" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
				<TD CLASS="GRAPHSPAN_BLACK" STYLE="WIDTH:30px"></TD>
				</TR></TABLE>
				&nbsp;&nbsp;Other Overlapped Billback
				</TD>
				<TD COLSPAN="1" ALIGN="RIGHT" BGCOLOR="White" NOWRAP>
				<CFIF USEIMGGRAPH>
				<CFSET scale=(Total_date_Span/Max_Length) * 20>
				<IMG SRC="/Images/Grid_Scale_Square.gif" BORDER="0" WIDTH="20" HEIGHT="20" ALIGN="absmiddle">&nbsp;=&nbsp;#scale# days</TD>
				</CFIF>
			</TR>
		</TFOOT>
	</TABLE>
	<CFIF ADDSCRIPT EQ "Yes">
	<SCRIPT LANGUAGE="javaScript">
	showDates();
	</SCRIPT>
	</CFIF>
	</CFOUTPUT>
</CFIF>