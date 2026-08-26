<style>
.disclaimer
{
	font-family : Arial;
	font-size : 7pt;
	color : #666666;
	text-decoration: italic;
}
</style>


<!--- Build file name --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
	<CFSET HTML_File_Path="\data_files\created\deductions\communications\rebill\#filename_email#.html">
	
	<CFIF NOT FileExists("#Application.Doc_Path##HTML_File_Path#")>
		<CFSET HTML_File_Path=HTML_File_Path>
	</cfif>

<cfoutput><!---Save the content of the previous page as a variable--->
<CFSAVECONTENT VARIABLE="Summary_Content">

<table width="80%" cellpadding="0" cellspacing="0" border="0">

<tr>
	<th colspan="2" align="center">
	<font color="navy">#RB_Name#</font>
	</th>
</tr>
<tr><td colspan="2"><hr width="100%" color="navy"></td></tr>
<tr>
	<td width="50%" valign="top">
	<strong>#application.returned_customer_setting.billto_label#:<br></strong>
	#RB_Name#<br>
		#RB_Address_1#<br>
		<cfif len(trim(RB_Address_2)) GT 0>
		#RB_Address_2#<br>
		</cfif>
		#RB_City#, #RB_State# #RB_ZipCode# <br>
		(#RB_Phone1#) #RB_Phone2##-RB_Phone3#
	</td>
	<td width="50%" valign="top">
	<strong>Deduction Information:<br></strong>
	Deduction Amount: #LSCurrencyFormat(RB_DD_Amount)#<Br>
	Deposit Date: #DateFormat(RB_DD_Date, 'MM/DD/YYYY')#<br>
	Reference: #RB_DD_Reference#<Br>
	Check Number: #RB_DD_Check_Number#
	</td>
</tr>

<tr>
<td colspan="2">
<hr color="navy">
</td>
</tr>

<tr>
	<td colspan="2">
&nbsp; <p></p>	
		#RB_DD_Rebill_Text#
<p></p>&nbsp; 
	</td>
</tr>
<tr><td colspan="2">
	<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.confidentiality_switch EQ 1>
			<hr color="navy">
			<font class="disclaimer">
			<cfoutput><em>#application.returned_customer_setting.confidentiality_content#</em></cfoutput>
			</font>
			<hr color="navy">
			</cfif></cfif> 
</td></tr>
</table>

</CFSAVECONTENT></cfoutput>



<!--- create usable directory information --->
<CFSET The_File_Location =Application.Doc_Path & HTML_File_Path>
<!--- end create usable directory information --->	

<!--- Save the file to the server --->
<cffile action="write" file="#The_File_Location#" output="#Summary_Content#">
