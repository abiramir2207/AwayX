<cfscript>	
writedump(server.smtpServerSettings );
 mail =  {
	 "server":"smtp.sendgrid.net",
	 "username":"apikey",
	 "password":"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"
	 }
server.smtpServerSettings = mail;

writedump(server.smtpServerSettings );
</cfscript>
	
