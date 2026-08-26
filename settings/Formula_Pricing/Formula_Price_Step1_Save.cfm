<!------Old_Number_Of_Comms----->
<!------Formula_Price_Step1_Save.cfm----->
	<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="0">
	<CFIF FORM.Show_Details EQ "">
		<CFSET FORM.Show_Details = 0>
	</CFIF>
	<CFIF Rule_ID NEQ "">
		<CFQUERY NAME="Save_Rule_Basic_Info" DATASOURCE="#application.datasource#">
			UPDATE 	Formula_Pricing_Rule
			SET		Rule_Name	=	'#FORM.Rule_Name#',
					Show_Details = 1
			WHERE
					Formula_Pricing_Rule_ID = '#Rule_ID#'
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="Insert_Rule_Basic_Info" DATASOURCE="#application.datasource#">
			INSERT	INTO	
			Formula_Pricing_Rule	(Rule_Name, Number_Of_Comms, Show_Details, Active)
			VALUES 			('#FORM.Rule_Name#', #FORM.Number_Of_Comms#, 1, 1)
		</CFQUERY>
		<CFSET Rule_ID=Insert_Rule_Basic_Info.Formula_Pricing_Rule_ID>				
	</CFIF>

