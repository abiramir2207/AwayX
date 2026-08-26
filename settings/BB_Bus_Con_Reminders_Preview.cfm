<cfinvoke component="components.settings.BusinessConsiderationsReminderBB" method="get" returnvariable="qBizConRemindersBB">
<html>
<head>
	<title>Business Considerations Reminders Preview</title>
		<style type="text/css">
		table {
				margin-right:10px;
				border-collapse:collapse;
				width:750px
				}
		th 	  { font-size:9pt;
				color:#000000;
				font-weight:550;
				font-family:verdana;
				text-align:left;
				padding-left:5px;
				background-color:#FFCE84;
				}
		td 	  {	font-size:8pt;
				color:#000000;
				padding-left:5px;
				font-family:verdana;
				vertical-align:top;
				}
		pre	  {
				font-size:8pt;
				color:#000000;
				font-family:verdana;
			  }
		td.norecords  {	font-size:8pt;
						color:#770022;
						font-family:verdana;
						padding-left:5px;
						text-align:center;
						}
		.header { font-size:11pt;
				  font-weight:bold;
				  color:#000000;
				  font-family:verdana;
				  text-align:left;
				  width:750px;
				  }
		textarea { width:725px;
				   height:75;
				   margin-top:5px;
				   margin-bottom:5px;
				   margin-right:10px;
				   margin-left:10px;
				   font-family:verdana;
				   }
		p.bodyheader 	{ font-size:10pt;
						  color:#22006F;
						  font-family:verdana;
						  font-weight:bold;
						  }
		/* Reminders */
		div.heading {font-size:12pt;font-family:verdana;}
		div.heading p {font-size:8pt;font-style:italic;font-family:verdana;margin:1px;margin-left:10px;padding:1px;font-weight:500;}
		div.heading ol {font-size:8pt;font-style:italic;font-family:verdana;font-weight:500;}
		div.heading ul {font-size:8pt;font-style:italic;font-family:verdana;font-weight:500;}
		div.heading span {font-weight:bold;font-size:10pt;}			  
						  
		a	{ font-family:verdana;
			  font-size:10pt;
			  font-weight:700;
			  color:dark blue;
			  }
		.likelink	{ font-family:verdana;
					  font-size:9pt;
					  font-weight:700;
					  color:blue;
					  background-color:white;
					  }
	</style>
	</style>
	</head>
	<body>
	<p class="header" style="display:inline">Business Considerations:</p>
	<HR><div class="heading" align="left">
		 <cfoutput>
		 	<span style="font-size:10pt;font-style:italic;"><b>Reminders:<b></span>
			#qBizConRemindersBB.business_considerations_reminders_txt#
		</cfoutput>
	</div>
	<HR>
	<TABLE width="#frmWidth#" align="center" border="1">

	  <TBODY>
		<TR>
		  <TH width="90">DATE</TH>
		  <TH width="120">USERNAME</TH>
		  <TH width="90">ACTION</TH>
		  <TH width="450">NOTES</TH>
		</TR>
		<TR>
		  <TD align="middle" colSpan="4">No Matching Records Found</TD>
		</TR>
		<TR>
		  <TD align="middle" colSpan="4">[ <A onClick="javascript:window.close();" href="##">close
			  window</A> ] </TD>
		</TR>
	  </TBODY>
	</TABLE>
</body>
</html>