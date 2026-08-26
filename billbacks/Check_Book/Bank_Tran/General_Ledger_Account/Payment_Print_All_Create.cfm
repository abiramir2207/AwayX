

<CFQUERY NAME="Get_All" DATASOURCE="#Application.Datasource#">
	SELECT 		Payment_Data_Export_1_ID,
				Billback_ID,
				Payment_Trans_ID,
				Pay_Multi_Billbacks_ID PayMultiBillbacksID

	FROM 		Payment_Data_Export_1
		
	WHERE 		Paid = 0 AND 
				Deleted=0 AND 
				Saved=1
	ORDER BY	Pay_Multi_Billbacks_ID
</CFQUERY>

<CFSET Count = 0>
<CFSET Print_output = "">


<CFOUTPUT QUERY="Get_All">
	<CFSET Count = Count + 1>
	<CFSET URL.BBID = Billback_ID>
	<CFSET URL.Payment_Trans_ID = Payment_Trans_ID>
	<CFSET URL.Payment_Data_Export_1_ID = Payment_Data_Export_1_ID>
	<CFIF PayMultiBillbacksID NEQ "">
		<CFSET URL.Pay_Multi_Billbacks_ID = PayMultiBillbacksID>
	</CFIF>
	<CFINCLUDE TEMPLATE = "View_Edit_Approve_Content.cfm">
</CFOUTPUT>
<!--- <FONT COLOR="Red"><B><I>Please select Landscape Layout to get clear print out</I></B></FONT><BR> --->
<CFOUTPUT>#Print_Output#</CFOUTPUT>
<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">