<!--------------------- get lookup table data reportLookup.cfm---------------------------------->

<!-----------------------------------------------------------------------
Get Status from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getStatus" datasource="#application.datasource#">
Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
From 	Contract_Status_Types
Where	
	Contract_Status_Type_ID > 3
Order By Contract_Status_Type_ID
</CFQUERY>
<!-----------------------------------------------------------------------
End - Get Status from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get Program Types from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getProgramTypes" datasource="#application.datasource#">
Select	ProgramControl_Panel_Options_ID,Created_Type
From 	Program_Control_Panel_Options
Where 	Deleted=0 AND Active=1 AND IsDominant = 1
Order By Created_Type
</CFQUERY>
<!-----------------------------------------------------------------------
End - Get Program Types from DB
--------------------------------------------------------------------------->

<!-----------------------------------------------------------------------
Get Program Types from DB
--------------------------------------------------------------------------->
<CFQUERY NAME="q_getGenericTypes" datasource="#application.datasource#">
Select	Generic_Type_ID, Generic_Type
From 	Generic_Type
Where	Generic_Type != 'Bid Request'
Order By Generic_Type
</CFQUERY>
<!-----------------------------------------------------------------------
End - Get Program Types from DB
--------------------------------------------------------------------------->
