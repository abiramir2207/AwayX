<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
	<META HTTP-EQUIV="Cache-Control" CONTENT="no-store">
</HEAD>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">


<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br><br><br>
 <center>
 <SPAN CLASS="title2">loading.....</SPAN>
 </center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Scorecard section																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<STYLE>
	.mystyle
		{
			position:absolute; 				width:300px; 
			height:200px; 					z-index:1; 
			border: 1px none #000000; 		visibility: hidden;
		}
	.no_access
	{
		color:gray;
	}
</STYLE>

<cfparam name="URL.Category" 	default="programs">

<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1>
<B>
<FONT COLOR="Red">[</FONT>
&nbsp;<A HREF="scorecard.cfm?Category=programs">programs</A>&nbsp;
<FONT COLOR="Red">]</FONT>
</B>
<CFELSE>
<CFIF URL.Category EQ "programs">
	<CFSET URL.Category = "billbacks">
</CFIF>
<B>
<FONT COLOR="Red">[</FONT>
&nbsp;<font class="no_access">programs</font>&nbsp;
<FONT COLOR="Red">]</FONT>
</B>
</CFIF>


<CFIF Get_Profile_Settings.PM_Access EQ 1>
<B>
<FONT COLOR="Red">[</FONT>
&nbsp;<A HREF="scorecard.cfm?Category=projects">projects</A>&nbsp;
<FONT COLOR="Red">]</FONT>
</B>
</CFIF>
<!---<CFIF application.returned_customer_setting.show_billback EQ 1  ---> 
<CFIF application.appSettingsGet.getBillback_Module()>
<B>
<FONT COLOR="Red">[</FONT>
&nbsp;<A HREF="scorecard.cfm?Category=billbacks">billbacks</A>&nbsp;
<FONT COLOR="Red">]</FONT>

</B>
<CFELSE>
<CFIF URL.Category EQ "billbacks">
	<CFSET URL.Category = "">
</CFIF>
<B>
<FONT COLOR="Red">[</FONT>
&nbsp;<font class="no_access">billbacks</font>&nbsp;
<FONT COLOR="Red">]</FONT>

</B>
</CFIF>
<BR>

<CFSWITCH EXPRESSION="#URL.Category#">
	<CFCASE VALUE="programs">
		<DIV ID="programs" CLASS="mystyle"	STYLE="visibility: visible;">
		<CFINCLUDE TEMPLATE="/scorecard/index.cfm"></DIV>
	</CFCASE>
	<CFCASE VALUE="projects">
		<DIV ID="projects" CLASS="mystyle" STYLE="visibility: visible;">
		<CFINCLUDE TEMPLATE="/ReportWriter/pm/PM_scorecard.cfm"></DIV>
	</CFCASE>
	<CFCASE VALUE="billbacks">
		<DIV ID="billbacks" CLASS="mystyle" STYLE="visibility: visible;">
		<CFINCLUDE TEMPLATE="/billbacks/scorecard/scorecard_home.cfm"></DIV> 
	</CFCASE>
</CFSWITCH>


<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
</BODY>
</HTML>
