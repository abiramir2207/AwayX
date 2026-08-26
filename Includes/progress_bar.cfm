<cfset x=1>			
<cfset IncludeProgressBar ="1"> 
<cfset Block ="">  
<br />
<table border="0" id ="Progress_Bar" cellpadding="0" cellspacing="0" align="CENTER">
<tr>
	<td align="center" id="ShowPercentProgress">&nbsp;</td>
</tr>
<tr>
<td>
	<table cellpadding="0" cellspacing="0" border="0" width="200">
		<tr>
			<td width="70"><span style="color:red;">Please wait:</span></td>
			<cfoutput>
			<cfloop condition="x LTE 10">
			<td style='background-color:ffffff;' align="left">
				<img src='' border="0" name='Block#X#' id='Block#X#' width="10" height="15">
			</td>
				<cfset x = x + 1>
			</cfloop>
			</cfoutput>
		</tr>
		<tr>
			<td colspan="100%" id="Display_Message" style='background-color:ffffff;' align="right">		
		</td>
		</tr>
	</table>
</td>
</tr>
</table>
<p>
<cfflush>