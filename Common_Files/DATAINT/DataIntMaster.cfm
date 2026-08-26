
<!--- <table cellpadding="5" cellspacing="5" height="100%" align="left" width="100%">
<tr>
	<td width="10%" align="left" valign="top"><cfinclude template="dataIntCal.cfm">
			   
			   
	</td>
	
	
	<td width="80%" valign="top" height="100%"><iframe height="100%" width="100%" align="middle" frameborder="0" marginwidth="1" id="dataInt" name="dataInt" src="dataIntViewer.cfm"></iframe>
		
	</td>
</tr>
</table> --->






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is Mark's code --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 
<FRAMESET  COLS="150,*">
    <FRAME NAME="calendar" SRC="calendar.cfm" MARGINWIDTH="10" MARGINHEIGHT="10" SCROLLING="auto" FRAMEBORDER="0" NORESIZE>
    <FRAME NAME="mainwindow" SRC="dataIntViewer.cfm" MARGINWIDTH="10" MARGINHEIGHT="10" SCROLLING="auto" FRAMEBORDER="0" NORESIZE>
</FRAMESET>
 --->


 
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the replacement code that Frank created so the initial help file is displayed			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <cfif application.returned_customer_setting.customer_keyword is "Heinz"> --->
<FRAMESET COLS="150,*" FRAMEBORDER="0">
    <FRAME SRC="calendar.cfm" NAME="calendar" ID="calendar" FRAMEBORDER="0" SCROLLING="Auto" NORESIZE MARGINWIDTH="15" MARGINHEIGHT="0">
    <FRAME SRC="dataIntViewer_blank.cfm" NAME="dataIntMainwindow" ID="dataIntMainwindow" FRAMEBORDER="0" SCROLLING="Auto" NORESIZE MARGINWIDTH="0" MARGINHEIGHT="0">
</FRAMESET><noframes></noframes>
<!--- </cfif>  --->

