<!-----------------------------------------------------------------------------

FILE NAME:		update_programs_to_latest_templates.cfm
DESCRIPTION:	This file throws a confirmation and on confirmation updates
              all the programs to the lates templates by calling the 
              stored procedure
CREATED BY:		Anand Rao/15-May-09
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

------------------------------------------------------------------------------> 

<style>
  #modifiedCont {border:thin solid Orange;width:460px;margin:15 0 10 10;padding:5;text-align:center;font-size:12px;color:red;background-color:White;font-weight:bold;}
  #modifiedContSaved {border:thin solid navy blue;width:460px;margin:15 0 10 10;padding:5;text-align:center;font-size:12px;color:black;background-color:White;font-weight:bold;}
  #body {font-family: Century Gothic;}
</style>

<body>
  <cfif isDefined("FORM") AND isDefined("FORM.Submit")>
    <!--- Call the stored procedure that updates the programs to the recent template version --->
    <cfstoredproc datasource="#application.datasource#" procedure="Set_programs_to_most_recent_template_version">
	  </cfstoredproc> 
    <br><br>
    <div id="modifiedContSaved">
      <br>
      The programs have been updated with the latest templates!!
      <br><br>
    </div>
    <br>
    <div align="center"><a href="#" onClick="self.close()" style="font-size:11;font-family:Arial;">Close Window</a></div>
  <cfelse> 
 
<form name="frmSubmit" action="update_programs_to_latest_templates.cfm" method="post">
	<div align="right"><a href="#" onClick="self.close()" style="font-size:11;font-family:Arial;">Close Window</a></div>

	<div align="center"><b>Update Programs to latest Templates</b></div>
  
  <div id="modifiedCont">
	 Are you sure that you want to update all the programs to the Latest template?<br>
   ***** This change is Irreversible ******<br>
   <br>
   
   <input type="submit" name="submit" value="Yes" style="width:35;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   <input type="button" value="No" onClick="javascript:window.close();" style="width:35;" >
</div>
 </form>
 </cfif>
 </body>