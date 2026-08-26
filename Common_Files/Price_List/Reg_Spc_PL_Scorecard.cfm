<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="ID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">

<!-------- SORT ---------->
	<CFSET SQL_SORT_BY = "Price_List_ID">
	<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
		<CFCASE VALUE="ID">
			<CFSET SQL_SORT_BY = "Price_List_ID">
		</CFCASE>
		<CFCASE VALUE="DESCRIPTION">
			<CFSET SQL_SORT_BY = "Price_List_Description">
		</CFCASE>
		<CFCASE VALUE="DATE">
			<CFSET SQL_SORT_BY = "Created_Date">
		</CFCASE>
	</CFSWITCH>
	<CFIF FORM.SORT_ORDER NEQ "DESC">
		<CFSET FORM.SORT_ORDER = "ASC">
	</CFIF>
<!-------- SORT ---------->
 
<CFSET CustomerQueryType = 2>
<CFIF application.returned_customer_setting.Customer_Keyword EQ "Resers">
	<CFSET CustomerQueryType = 1>
</CFIF>

<cfif url.Show_Scorecard eq 1>
	<cfif CustomerQueryType EQ 1>
		<cfquery name="get_data" datasource="#application.datasource#">
			SELECT 		DISTINCT	Price_List_Description,
									Price_List_ID
						<!--- Created_Date --->
			FROM 		Price_List_Header
			WHERE
						EXISTS
						(
							SELECT 		top 1 Price_List_ID  
							FROM 		Price_List_Detail 
							WHERE 		Price_List_ID = Price_List_Header.Price_List_ID
										AND Active_Code = 'A' 
										AND CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) 
										AND End_Date >= CONVERT(Char(10),getdate(),101)	
						)
			ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
		</cfquery>
	<cfelseif CustomerQueryType EQ 2>
		<cfquery name="get_data" datasource="#application.datasource#">
			SELECT 		DISTINCT	Price_List_Description,
									Price_List_ID
						<!--- Created_Date --->
			FROM 		Price_List_Header
			WHERE
						EXISTS
						(
							SELECT 		top 1 Price_List_ID  
							FROM 		Price_List_Detail 
							WHERE 		Price_List_ID = Price_List_Header.Price_List_ID
										AND Active_Code = 'A' 
										AND CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101)
										AND End_Date >= CONVERT(Char(10),getdate(),101) 
										<!--- AND CONVERT(Char(10),End_Date,101) >= CONVERT(Char(10),getdate(),101)	 --->
						)
			ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
		</cfquery>
	</cfif>
<cfelseif url.Show_Scorecard eq 2>	
	<cfif CustomerQueryType EQ 1>
		<cfquery name="get_data" datasource="#Application.Datasource#">
			SELECT 		DISTINCT	Description 	Price_List_Description,
									Ship_To 		Price_List_ID
						<!--- Created_Date --->	
			FROM 		Price_List_Header_Special
			WHERE
						EXISTS
						(
							SELECT 		top 1 Ship_To
							FROM 		Price_List_Detail_Special
					
							WHERE 		Ship_To = Price_List_Header_Special.Ship_To 
										AND Active_Code = 'A' 
										AND CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) 
										AND CONVERT(Char(10),End_Date,101) >= Convert(Char(10),getdate(),101)
						)
			ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
		</cfquery>
	<cfelseif CustomerQueryType EQ 2>
		<cfquery name="get_data" datasource="#Application.Datasource#">
			SELECT 		DISTINCT	Price_List_ID 			Price_List_ID,
									Price_List_Description 	Price_List_Description
									
									<!--- 0 as Created_Date --->
			FROM 		Price_List_Header_Special
			WHERE
						EXISTS
						(
							SELECT 		top 1 Price_List_Header_Special_ID
							FROM 		Price_List_Detail_Special
					
							WHERE 		Price_List_Header_Special_ID = Price_List_Header_Special.Price_List_Header_Special_ID 
										AND Active_Code = 'A' 
										AND CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) 
										AND CONVERT(Char(10),End_Date,101) >= Convert(Char(10),getdate(),101)
						)
			ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
		</cfquery>
	</cfif>
		
<cfelse>
	<cfif CustomerQueryType EQ 1>
		<CFQUERY NAME="get_data" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT	Price_List_ID,
									Price_List_Description
						<!--- Created_Date  --->
		
			FROM 		Price_List_Header WHERE Price_List_ID Not In 
						(	SELECT 		DISTINCT(Price_List_ID) 
							FROM 		Price_List_Detail 
							
							WHERE 		Active_Code = 'A' AND 
										CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
										CONVERT(Char(10),End_Date,101) >= CONVERT(Char(10),getdate(),101)
						)
		
			UNION
		
			SELECT 		DISTINCT	Ship_To			Price_List_ID, 
									Description 	Price_List_Description
						<!--- Created_Date ---> 
		
			FROM 		Price_List_Header_Special WHERE Ship_to Not in
						(	SELECT 	DISTINCT(Ship_to) 
							FROM 	Price_List_Detail_Special
							
							WHERE 	Active_Code = 'A' AND 					
									CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
									CONVERT(Char(10),End_Date,101) >= Convert(Char(10),getdate(),101))
		
			ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
		</CFQUERY>
	<cfelseif CustomerQueryType EQ 2>
		<CFQUERY NAME="get_data" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT	Price_List_ID,
								Price_List_Description,
								0 AS Table_name
					<!--- Created_Date --->

	
		FROM 		Price_List_Header WHERE Price_List_ID Not In 
					(	SELECT 		DISTINCT(Price_List_ID) 
						FROM 		Price_List_Detail 
						
						WHERE 		Active_Code = 'A' AND 
									CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
									End_Date >= CONVERT(Char(10),getdate(),101)
					)
	
		UNION
	
		SELECT 		DISTINCT	Price_List_ID			Price_List_ID, 
								Price_List_Description 	Price_List_Description,
								1 AS Table_name
					<!--- Created_Date --->  
	
		FROM 		Price_List_Header_Special WHERE Price_List_Header_Special_ID Not in
					(	SELECT 	DISTINCT(Price_List_Header_Special_ID) 
						FROM 	Price_List_Detail_Special
						
						WHERE 	Active_Code = 'A' AND 					
								CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
								End_Date >= Convert(Char(10),getdate(),101))
	
		ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
	</CFQUERY>
	</cfif>
</cfif>

<CFOUTPUT>
<form name="PL_Scorecard" action="Reg_Spc_PL_Scorecard.cfm?Show_Scorecard=#URL.Show_Scorecard#" method="post">
</CFOUTPUT>
	<cfparam name="FORM.startrow"  default="1">
   	<cfparam name="FORM.frompage"   default="1">
   	<cfparam name="FORM.pageLength"  default=15>
   	<cfset startrow=FORM.startrow>
   	<cfset frompage=FORM.frompage>
   	<cf_Number_of_Rows maxrows="#FORM.pageLength#">

	<cfoutput>
   	<input type="hidden" value = "#FORM.frompage#" name="frompage">
	<input type="hidden" value = "#FORM.StartRow#" name="startrow">
	<input type="hidden" value = "#FORM.SORT_BY#" name="SORT_BY">
	<input type="hidden" value = "#FORM.SORT_ORDER#" name="SORT_ORDER">
	</cfoutput>
	
	
	<table class="Maintable" border="0" cellpadding="3" cellspacing="0" width="500" align="center">
		<cfoutput query="get_data" startrow="#StartRow#" maxrows="#MaxRows#">
		
		<cfif url.Show_Scorecard NEQ 3>
			<tr bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#" valign="top">
				<td width="100">
				<cfif url.Show_Scorecard eq 1>					
					&nbsp;&nbsp;<font color="red" size="2"><b>[</b></font> <a href="Price_List_Detail.cfm?PL_ID=#Price_List_ID#&type=1" onclick="NewWindow(this.href,'P_List','850','600','Yes No');return false;">#Price_List_ID#</a> <font color="red" size="2"><b>]</b></font>
				<cfelseif url.Show_Scorecard eq 2>								
					&nbsp;&nbsp;<font color="red" size="2"><b>[</b></font> <a href="Price_List_Detail.cfm?type=2&PL_ID=#Price_List_ID#" onclick="NewWindow(this.href,'P_List','850','600','Yes No');return false;">#Price_List_ID#</a> <font color="red" size="2"><b>]</b></font>				
				</cfif>
				</td>
				<td width="400">#Price_List_Description#</td>				
				<!--- <CFQUERY NAME="Get_Created_Date" DATASOURCE="#Application.Datasource#">
					SELECT Top 1 Start_Date 
					FROM <CFIF url.Show_Scorecard EQ 1>
							Price_List_Header
						<CFELSE>
							Price_List_Header_Special
						</CFIF>
					WHERE Price_List_ID = #Price_List_ID#
				</CFQUERY>
				<td width="100">&nbsp;&nbsp;&nbsp;#Dateformat(Get_Created_Date.Created_date,"mm/dd/yyyy")#</td>			 --->
			</tr>
		<cfelse>
			<tr bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#" valign="top">
				<td width="100" title="No details available for this price list.">
					&nbsp;&nbsp;<font size="2"><b>[</b></font> #Price_List_ID# <font size="2"><b>]</b></font>&nbsp;
				</td>
				<td width="400">#Price_List_Description#&nbsp;</td>
				<!---<CFQUERY NAME="Get_Created_Date" DATASOURCE="#Application.Datasource#">
					SELECT Top 1 Created_Date 
					FROM <CFIF Table_name EQ 0>
							Price_List_Header
						<CFELSE>
							Price_List_Header_Special
						</CFIF>
					WHERE Price_List_ID = #Price_List_ID#
				</CFQUERY>
				 <td width="100">&nbsp;&nbsp;&nbsp;#Dateformat(Get_Created_Date.Created_date,"mm/dd/yyyy")# </td> --->		<!---  --->	
			</tr>	
		</cfif>
		</cfoutput>	
	</table>
	
</form>

<!------ 
<cfif url.Show_Scorecard eq 1>
	
	<cfquery name="get_data" datasource="#application.datasource#">
		SELECT 		Price_List_Description,
					Price_List_ID,
					Created_Date
					
		FROM 		Price_List_Header
		ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
	</cfquery>
	
	
<cfelseif url.Show_Scorecard eq 2>	
	<cfquery name="get_data" datasource="#Application.Datasource#">
		SELECT 		Description 	Price_List_Description,
					Ship_To 		Price_List_ID,
					Created_Date
					
		FROM 		Price_List_Header_Special
		
		ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
	</cfquery>
	
		
<cfelse>
<CFQUERY NAME="get_data" DATASOURCE="#Application.Datasource#">
	SELECT 		Price_List_ID,
				Price_List_Description,
				Created_Date 

	FROM 		Price_List_Header WHERE Price_List_ID Not In 
				(	SELECT 		DISTINCT(Price_List_ID) 
					FROM 		Price_List_Detail 
					
					WHERE 		Active_Code = 'A' AND 
								CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
								CONVERT(Char(10),End_Date,101) >= CONVERT(Char(10),getdate(),101)
				)

	UNION

	SELECT 		Ship_To			Price_List_ID, 
				Description 	Price_List_Description,
				Created_Date 

	FROM 		Price_List_Header_Special WHERE Ship_to Not in
				(	SELECT 	DISTINCT(Ship_to) 
					FROM 	Price_List_Detail_Special
					
					WHERE 	Active_Code = 'A' AND 					
							CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
							CONVERT(Char(10),End_Date,101) >= Convert(Char(10),getdate(),101))

	ORDER BY 	#SQL_SORT_BY# #FORM.SORT_ORDER#
</CFQUERY>
</cfif>

<CFOUTPUT>
<form name="PL_Scorecard" action="Reg_Spc_PL_Scorecard.cfm?Show_Scorecard=#URL.Show_Scorecard#" method="post">
</CFOUTPUT>
	<cfparam name="FORM.startrow"  default="1">
   	<cfparam name="FORM.frompage"   default="1">
   	<cfparam name="FORM.pageLength"  default=15>
   	<cfset startrow=FORM.startrow>
   	<cfset frompage=FORM.frompage>
   	<cf_Number_of_Rows maxrows="#FORM.pageLength#">

	<cfoutput>
   	<input type="hidden" value = "#FORM.frompage#" name="frompage">
	<input type="hidden" value = "#FORM.StartRow#" name="startrow">
	<input type="hidden" value = "#FORM.SORT_BY#" name="SORT_BY">
	<input type="hidden" value = "#FORM.SORT_ORDER#" name="SORT_ORDER">
	</cfoutput>
	
	
	<table class="Maintable" border="0" cellpadding="3" cellspacing="0" width="598" align="center">
		<cfoutput query="get_data" startrow="#StartRow#" maxrows="#MaxRows#">
		<cfif url.Show_Scorecard eq 1>
			<cfquery name="check_data" datasource="#Application.Datasource#">
				SELECT 		top 1 *  
			
				FROM 		Price_List_Detail 
		
				WHERE 		Price_List_ID = '#Price_List_ID#' AND Active_Code = 'A' AND 
							CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
							CONVERT(Char(10),End_Date,101) >= CONVERT(Char(10),getdate(),101)				
			</cfquery>
		<cfelseif url.Show_Scorecard eq 2>
			<cfquery name="Check_data" datasource="#Application.Datasource#">
				SELECT 		top 1 * 
				FROM 		Price_List_Detail_Special
		
				WHERE 		Ship_To='#Price_List_ID#' AND Active_Code = 'A' AND 
							CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
							CONVERT(Char(10),End_Date,101) >= Convert(Char(10),getdate(),101)
			</cfquery>
		<cfelse>
			<cfquery name="check_data" datasource="#Application.Datasource#">
				SELECT 		top 1 *  
			
				FROM 		Price_List_Detail 
		
				WHERE 		Price_List_ID = '#Price_List_ID#' AND Active_Code = 'A' AND 
							CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
							CONVERT(Char(10),End_Date,101) >= CONVERT(Char(10),getdate(),101)				
			</cfquery>
		</cfif>
		
		
		<cfif check_data.recordcount NEQ 0 AND url.Show_Scorecard NEQ 3>
			<tr bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#" valign="top">
				<td width="100">
				<cfif url.Show_Scorecard eq 1>					
					&nbsp;&nbsp;<font color="red" size="2"><b>[</b></font> <a href="Price_List_Detail.cfm?PL_ID=#Price_List_ID#&type=1" onclick="NewWindow(this.href,'P_List','850','600','Yes No');return false;">#Price_List_ID#</a> <font color="red" size="2"><b>]</b></font>
				<cfelseif url.Show_Scorecard eq 2>
					&nbsp;&nbsp;<font color="red" size="2"><b>[</b></font> <a href="Price_List_Detail.cfm?type=2&PL_ID=#Price_List_ID#" onclick="NewWindow(this.href,'P_List','850','600','Yes No');return false;">#Price_List_ID#</a> <font color="red" size="2"><b>]</b></font>				
				</cfif>
				</td>
				<td width="400">#Price_List_Description#</td>
				<td width="100">&nbsp;&nbsp;&nbsp;#Dateformat(Created_date,"mm/dd/yyyy")#</td>			
			</tr>
		<cfelseif check_data.recordcount EQ 0 AND url.Show_Scorecard EQ 3>
			<tr bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#" valign="top">
				<td width="100" title="No details available for this price list.">
					&nbsp;&nbsp;<font size="2"><b>[</b></font> #Price_List_ID# <font size="2"><b>]</b></font>
				</td>
				<td width="400">#Price_List_Description#</td>
				<td width="100">&nbsp;&nbsp;&nbsp;#Dateformat(Created_date,"mm/dd/yyyy")#</td>			
			</tr>	
		</cfif>
		</cfoutput>	
	</table>
	
</form> ----->
	<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="PL_Scorecard"
    query="get_data"
    maxpages="25"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>
</body>
</html>
