<CFSET Prior_Level = Current_Level> 
<CFSET Current_Level = incrementvalue(Current_Level)>

<CFQUERY NAME="GetLevel_#Current_Level#_Categories" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Category_Level_#Current_Level#
	WHERE Category_Parent = '#evaluate("GetLevel_#Prior_Level#_Categories.Category_Level_ID")#'
</CFQUERY>

<UL>
	<CFIF evaluate("GetLevel_#Current_Level#_Categories.recordcount") GT 0>
	
		<CFLOOP QUERY="GetLevel_#Current_Level#_Categories">
			<LI>
				<CFOUTPUT>#evaluate("GetLevel_#Current_Level#_Categories.Category_Name")# - </CFOUTPUT>
				<CFIF Current_Level NEQ Total_Levels><CFINCLUDE TEMPLATE="level_include.cfm"></CFIF> 
			</LI>
		</CFLOOP>
	</CFIF>
			
			<LI>
				<CFOUTPUT><A HREF="javascript:newCategoryWindow(#Current_Level#, '#evaluate("GetLevel_#prior_Level#_Categories.category_level_id")#')">+</A></CFOUTPUT>
			</LI>	
				<CFSET Current_Level  = (Current_Level-1)>
				<CFSET Prior_Level = (Current_Level-1)>
			
</UL>

