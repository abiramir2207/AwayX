
<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM BB_ShortPay_Reason  
		WHERE		BB_ShortPay_Reason_ID			=	'#Form.RID#'
	</CFQUERY>	
</CFIF>

<CFIF Form.RID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		BB_ShortPay_Reason
						(SP_Reason_Code,SP_Reason_Description,Deleted)
		Values			('#FORM.SP_Reason_Code#','#Form.SP_Reason_Description#',#Form.Deleted#)
	</CFQUERY>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		BB_ShortPay_Reason
		
		SET 		SP_Reason_Code			=	'#FORM.SP_Reason_Code#',
					SP_Reason_Description 	=	'#Form.SP_Reason_Description#',
					Deleted					=	#Form.Deleted#
					
		WHERE		BB_ShortPay_Reason_ID		=	'#Form.RID#'
	</CFQUERY>
</CFIF>

<CFLOCATION URL="SP_ReasonCode.cfm" ADDTOKEN="No">
<CFABORT>