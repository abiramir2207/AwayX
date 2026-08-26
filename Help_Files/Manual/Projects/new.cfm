<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Control Panel :: Projects </title>
	<script language="JavaScript">
<!--
function change(html){
  description.innerHTML=html
  description2.innerHTML=html
}
//-->
</script>
</head>

<body>
<strong><div id="description">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Project -- New or Edit</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr><td valign="top" colspan="2">If you are amending a project instead of creating one, you will be given the option to delete the program as following:</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/proj_deleteoption.gif"></td></tr>
<tr><td colspan="2">If you want to delete the project, select the delete this project option and click on [save data].  You will NOT receive a confirmation screen - the information will automatically be deleted.  Be sure you want to delete the information before choosing this option.</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/proj_new.gif"></td></tr>

<tr><td colspan="2">
If you are creating a new project or amending an existing project, you will be taken to this screen.  If you are amending a project, you will see the information that has already been entered.
<ul>
<li><em>Name:</em> Enter the name for your project in the bar at the top of the screen.  You must enter a name for your project.</li>
<li><em>Priority:</em> You can select the priority to which the project you are creating belongs.</li>
<li><em>Status:</em> Select the status for your project.  Options are Open and Closed.</li>
<li><em>Phase:</em> Enter the phase to which this project belongs.</li>
<li><em>Period:</em> Select the open and close dates for the period of the project.  The opening date is on the top.  You can enter the date in the field, select it from the calendar by clicking on the icon to the right of the field, or increment the date by one day using the up and down arrows.  The closing date is the bottom of the two dates.</li>
<li><a name="QBrands"></a><em>QBrands:</em>  Select the QBrands in the project.  You can open a selection window by clicking on [pick from list].  You will see the following screen:
<p align="Center">
<img src="../images/proj_qbrand.gif">
</p>
Select the Qbrands you are interested in by clicking on the boxes on the left.  When you are satisfied with your selections, click on [import selected Qbrands].  If you would like to import all Qbrands, click on [import all returned Qbrands].  To remove selected Qbrands, click on [remove all selected Qbrands]. 
</li> 
<li><em>Functional Area Responsible:</em> Select from the list of Functional Areas.</li>
<li><a name="Brokers"></a><em>Brokers:</em> Click on the [pick from list] link to select brokers for your program. It will open the following screen:
<p align="center">
<img src="../images/proj_broker.gif">
</p>
You can search for brokers by zone, region, line of business, status or name.  Once you have found the brokers you want to add, select them by checking on the box on the left.  (You can select all on a screen by clicking on the box in the orange bar at the top.)  You can choose all selected brokers by clicking on the [import selected brokers] link, select all brokers returned by the search by clicking on [import all returned brokers], or remove all selected brokers by clicking on the appropriate link.
</li>
<li><a name="Distributors"></a><em><cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>:</em> As in Qbrands and brokers, clicking on the [pick from list] link will open a new window which will allow you to select <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput>:
<p align="centeR">
<img src="../images/proj_distributor.gif">
</p>
You can search for <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> by family name, buying groups, line of business, status, zone, region, broker or name.  You can select or deselect <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> in the same way you did brokers.
</li>
<li><a name="Operators"></a><em><cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>:</em> Click on [pick from list] to see a list of <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput>.  The following screen will be presented:
<p align="Center">
<img src="../images/proj_operator.gif">
</p>
<cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> can be searched for by <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> name, the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> business name, city, type of <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>, location type and state.
</li>
<li><em>Value Lbs:</em> Select the value in pounds of the project.</li>
<li><em>Value $:</em> Enter the dollar value for the project.</li>
<li><em>Resources $:</em> You should enter the monetary resources required for this project here.</li>
<li><em>Sponsor:</em> Select the sponsor for this project from the list of projects.</li>
<li><em>Owner position:</em> Choose the owner position of the program from the available list.</li>
<li><em>CER/Acct Number:</em>  Enter the number of the account that will be responsible for paying for the project.</li>
<li><em>Support:</em> Enter the name of the person or department responsible for supporting this project.  This may or may not be the same as the Functional Area Responsible.</li>
<li><em>Budget $:</em> The budget available for this project should be entered here.</li>
<li><em>Actual $:</em> When you have ascertained the actual cost this program incurred, enter it here.</li>
<li><a name="Programs"></a><em>Programs associated with this project: </em>To associate a program or programs with the project you are creating or amending, click on the [pick from list] link.  The following window will be opened: 
<p align="center">
<img src="../images/proj_programs.gif">
</p>
You will be able to view and select all existing Work in Progress, Pre-Active, Active, and Expiring.  Click on the box to the left of the project you would like to add, and select [import selected programs]. 
</li> 
<li><em>Previously saved:</em> If you have previously saved programs, they will be displayed here.  You can remove a previously save program by unchecking the box next to the program name.</li>
<li><em>Recently selected:</em> The programs you have selected in this session will be displayed in the Recently selected section. If you wish to remove a program, uncheck the box next to the program number.</li>  
<li><em>Next Step/Updates:</em> You can enter any information about the next steps for the project in this box.</li>
<p>
Be sure you select [save data] when you are done entering or amending information.  If you do not save the data, everything you entered will be lost.
</p>

</ul>
</td></tr>

</table>
<p></p>
</div>

<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<cfinclude template="project_toc.cfm">
<cfinclude template="projects_updated.cfm">
</body>
</html>
