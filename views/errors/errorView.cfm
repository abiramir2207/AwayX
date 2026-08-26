<cfoutput>
 <table border="0" cellpadding="10" cellspacing="0">
  <tr>
   <td valign="top"><img src="/images/event.gif" border="0" title=""></td>
   <td valign="top">
	<strong>
       We are sorry for the inconvenience, but we are unable to execute this action at this time.<br />
	   This event has been logged and is being addressed.<br /><br />
	   Event ##: #event.getValue('error_id')#
	</strong>
	<br /><br /><br />
	<H4 style="font-color:navy">#application.CompanyNameFull#</H4>
   </td>
  </tr>
 </table>
 <script language="javascript">  
	window.open('/Error_Reason_Frm.cfm?CFML_Error_Log_ID=#event.getValue("error_id")#&User_ID=&Program_ID=&Billback_ID=&Deduction_ID=','ErrorMessageComments','toolbar=no,width=450,height=365,resizable=no,scrollbars=no,left='+(window.screen.availWidth-750)+',top='+(window.screen.availHeight-420));
 </script>
</cfoutput>