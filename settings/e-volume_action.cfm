<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF Form.Payables_Expect_Volume_Purchase_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Purchase_Period_other)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>
<CFIF Form.Payables_Expect_Volume_Purchase_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Purchase_Period_other))>
		<CFSET Payables_Expect_Volume_Purchase_Period=evaluate(Payables_Expect_Volume_Purchase_Period_other)>
</CFIF>


<CFIF Form.Payables_Expect_Volume_Aggregation_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Aggregation_Period_other)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>
<CFIF Form.Payables_Expect_Volume_Aggregation_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Aggregation_Period))>
		<CFSET Payables_Expect_Volume_Aggregation_Period=evaluate(Payables_Expect_Volume_Aggregation_Period_other)>
</CFIF>


<CFIF Form.Payables_Expect_Volume_Offset_Period EQ 1 AND isnumeric(trim(Form.Payables_Expect_Volume_Offset_Period)) EQ 0>
		You must enter a number here...
		<CFABORT>
</CFIF>
<CFIF Form.Payables_Expect_Volume_Offset_Period EQ 1 AND isnumeric(trim(Payables_Expect_Volume_Offset_Period))>
		<CFSET Payables_Expect_Volume_Offset_Period=evaluate(Payables_Expect_Volume_Offset_Period_other)>
</CFIF>





<CFIF Form.up_sv EQ 0>
	<CFQUERY NAME="Insert_Data" datasource="#application.datasource#">
		INSERT INTO _Users_Settings
			(
				Payables_Expect_Volume_Purchase_Period,
				Payables_Expect_Volume_Aggregation_Period,
				Payables_Expect_Volume_Offset_Period,
				Payables_Expect_Volume_Highlight,
				Payables_Expect_Volume_Date_Updated
			)
		VALUES
			(
				'#Payables_Expect_Volume_Purchase_Period#',
				'#Payables_Expect_Volume_Aggregation_Period#',
				'#Payables_Expect_Volume_Offset_Period#',
				'#Payables_Expect_Volume_Highlight#',
				 #Date_Updated#
			)
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
		UPDATE	_Users_Settings
		SET		Payables_Expect_Volume_Purchase_Period		=	'#Payables_Expect_Volume_Purchase_Period#',
				Payables_Expect_Volume_Aggregation_Period	=	'#Payables_Expect_Volume_Aggregation_Period#',
				Payables_Expect_Volume_Offset_Period		=	'#Payables_Expect_Volume_Offset_Period#',
				Payables_Expect_Volume_Highlight			=	'#Payables_Expect_Volume_Highlight#',
				Payables_Expect_Volume_Date_Updated			=	 #Date_Updated#
		WHERE	User_ID										=	'#User_ID#'
	</CFQUERY>
</CFIF>


<CFLOCATION URL="e-volume_form.cfm?ID=#createuuid()#" ADDTOKEN="No">


