

<div style="margin:175px auto 0px auto; text-align:center; color:#555555; font-size:14px;#">
	
	one moment please...
	
</div>



<!--- ----------------------------------------------------------------------------------------- --->
<!--- CHECK TO SEE IF THE DELETE BIT IS SET TO 666 OR NOT. IF IT IS THE RECORD IS DELETED. --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfparam  name = "URL.actid" default = 0>

<cfif url.actid NEQ 0><!--- if id = 666, delete the record --->


		<cfquery name="delete_record" datasource="#db_connection#">
			DELETE FROM msg_ctr_admin_msgs
			WHERE msg_ctr_admin_id=<cfoutput>#url.msgid#</cfoutput>
		</cfquery>



<cfelse>

		<cfif form.msg_ctr_start_date gt form.msg_ctr_end_date>
            <script>                
        		setTimeout("window.history.back()",0000); // 0 milisecond delay                
            </script>
		<CFABORT>                
		</cfif>

			
			<cfif form.msg_ctr_admin_id EQ 0>

					<!--- if the message id is zero it means it is a new message --->
					<cfquery name="save_data" datasource="#db_connection#">
						INSERT INTO msg_ctr_admin_msgs 
							(
								msg_ctr_admin_txt, 
								msg_ctr_start_date, 
								msg_ctr_end_date
							)
						VALUES
							(
								'#form.msg_ctr_admin_txt#', 
								#createodbcdate(form.msg_ctr_start_date)#, 
								#createodbcdate(form.msg_ctr_end_date)# 
							)
					</cfquery>

			<cfelse>

					<!--- if the message id is NOT zero it means it is an update of an existing message --->
					<cfquery name="save_data" datasource="#db_connection#">
					UPDATE msg_ctr_admin_msgs
					SET 
						msg_ctr_admin_txt	=	'<cfoutput>#form.msg_ctr_admin_txt#</cfoutput>', 
					    msg_ctr_start_date	=	<cfoutput>#createodbcdate(form.msg_ctr_start_date)#</cfoutput>,
					    msg_ctr_end_date	=	<cfoutput>#createodbcdate(form.msg_ctr_END_date)#</cfoutput>
					WHERE 
						msg_ctr_admin_id=<cfoutput>#form.msg_ctr_admin_id#</cfoutput>
					</cfquery>
			
			
			</cfif>


</cfif>
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->





<!--- code used to refresh the parent window when this window closes --->
<script>
    window.onunload = refreshParent;
    function refreshParent() {
        window.opener.location.reload();
    }
</script>



<!--- used to auto close the window --->
<script language="javascript">
<!--
setTimeout("self.close();",1000)
//-->
</script> 