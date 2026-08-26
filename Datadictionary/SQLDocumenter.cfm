
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Default values																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="Attributes.Datasource"	DEFAULT="">				<!--- DB DNS - REQUIRED				 --->
<CFPARAM NAME="Attributes.Username"		DEFAULT="sa">			<!--- DB User login - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Password"		DEFAULT="password">		<!--- DB Password - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Tables"		DEFAULT="Yes">			<!--- Show Tables - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Views"		DEFAULT="No">			<!--- Show Views - OPTIONAL			 --->
<CFPARAM NAME="Attributes.Storproc"		DEFAULT="No">			<!--- Show Stored Proc. - OPTIONAL	 --->
<CFPARAM NAME="Attributes.Triggers"		DEFAULT="No">			<!--- Show Triggers - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Color"		DEFAULT="Gray">			<!--- Table Colors - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Titlecolor"	DEFAULT="Black">		<!--- Title Colors - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Tablewidth"	DEFAULT="700">			<!--- Table width - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Tablepadding"	DEFAULT="3">			<!--- Table padding - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Tablespacing"	DEFAULT="1">			<!--- Table spacing - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Tableborder"	DEFAULT="1">			<!--- Table spacing - OPTIONAL		 --->
<CFPARAM NAME="Attributes.Fontface"		DEFAULT="Verdana">		<!--- Font used - OPTIONAL			 --->
<CFPARAM NAME="Attributes.Fontsize"		DEFAULT="11px">			<!--- Font size - OPTIONAL			 --->
<CFPARAM NAME="Attributes.Links"		DEFAULT="Yes">			<!--- Navigation links - OPTIONAL	 --->
<CFPARAM NAME="Attributes.Pagebreaks"	DEFAULT="Yes">			<!--- Print pagebreaks - OPTIONAL	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The Datasource must be supplied, all others are optional										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Attributes.Datasource EQ "">
	<BR><BR><BR><BR><BR><BR><BR><BR>
	<CENTER><H2>Please specify the DB connection...</H2></CENTER>
	<CFABORT>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Style sheet used to display output															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Attributes.Pagebreaks EQ "Yes">
	<CFSET Attributes.Pagebreaks="page-break-before: always;">
		<CFELSE>
	<CFSET Attributes.Pagebreaks="">
</CFIF>
<CFOUTPUT>
<STYLE TYPE="text/css">
	BODY,TD		{font-family:#Attributes.Fontface#;	font-size:#Attributes.Fontsize#;}
	P.BreakHere	{#Attributes.Pagebreaks#}
</STYLE>
</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Report Header																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<B>
	<FONT SIZE="+2">
		<CFOUTPUT>#Attributes.Datasource#</CFOUTPUT>
	</FONT>
	 . 
	 <FONT SIZE="+1">
	 	<CFOUTPUT>#dateformat(now(),'mm/dd/yy')#</CFOUTPUT>
	</FONT>
</B>
<HR COLOR="#FF0000">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Navivation Links at the top of the page														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FONT SIZE="1" COLOR="#FF0000">
<CFIF Attributes.Links EQ "Yes">
	<B>
	<CFIF Attributes.Tables EQ "Yes">
		|&nbsp;
		<A HREF="#tables">tables</A>
	</CFIF>
	<CFIF Attributes.Views EQ "Yes">
		&nbsp;|&nbsp;
		<A HREF="#views">views</A>
	</CFIF>
	<CFIF Attributes.Storproc EQ "Yes">
		&nbsp;|&nbsp;
		<A HREF="#storeproc">stored procedures</A>
	</CFIF>
	<CFIF Attributes.Triggers EQ "Yes">
		&nbsp;|&nbsp;
		<A HREF="#triggers">triggers</A>
	</CFIF>
		&nbsp;|
	</B>
<BR><BR>
</CFIF>
</FONT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Tables																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Attributes.Tables EQ "Yes">
	<A NAME="tables"></A>
	<CFOUTPUT>
		<TABLE BGCOLOR="#Attributes.Titlecolor#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
		<TR>
			<TD STYLE="color: white; font-size:14px" WIDTH="100%"><B>TABLES</B></TD>
			<TD><CFIF Attributes.Links EQ "Yes"><A HREF="##top" STYLE="color: white; font-weight: bold;">top</A></CFIF></TD>
		</TR>
	</TABLE>
	<P CLASS="BreakHere">
	</CFOUTPUT>
	
	<CFQUERY NAME="Get_Tables" DATASOURCE="#Attributes.Datasource#" USERNAME="#Attributes.Username#" PASSWORD="#Attributes.Password#">
		SELECT		sysObjects.Name,
					sysObjects.Crdate
		FROM		sysObjects
		WHERE		sysObjects.Type		=	'U'
		ORDER BY	sysObjects.Name
	</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generate the list of tables with links to the details											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
</CFOUTPUT>
	<TR>
		<CFSET tablecounter=0>
		<CFOUTPUT QUERY="Get_Tables">
		<TD BGCOLOR="White"><A HREF="###Name#" STYLE="font-size:10px;">#lcase(Name)#</A></TD>
		<CFSET tablecounter=tablecounter+1>
		#IIf(tablecounter Mod 3,DE(''),DE('</TR><TR>'))#
		</CFOUTPUT>
</TABLE>
<BR>

	<CFLOOP QUERY="Get_Tables">
		<CFQUERY NAME="Get_Table_Fields" DATASOURCE="#Attributes.Datasource#" USERNAME="#Attributes.Username#" PASSWORD="#Attributes.Password#">
			EXEC sp_columns @table_name = '#Get_Tables.Name#'
		</CFQUERY>
	
		<CFOUTPUT>
		<A NAME="#Name#"></A>
		<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
		</CFOUTPUT>
			<TR><TD COLSPAN="100%"><FONT SIZE="2" COLOR="White"><B><CFOUTPUT>#ucase(Get_Tables.Name)#</CFOUTPUT></B></FONT> - <A HREF="#tables" STYLE="color:white;">back</A></TD></TR>
			<TR STYLE="font-weight:bold;" BGCOLOR="White" VALIGN="bottom">
				<TD WIDTH="175">Field Name</TD>
				<TD WIDTH="100">SQL<BR>Data Type</TD>
				<TD WIDTH="100">Size</TD>
				<TD WIDTH="75">Precision</TD>
				<TD WIDTH="50">Scale</TD>
				<TD WIDTH="75">ODBC<BR>Data Type</TD>
				<TD WIDTH="50">Required</TD>
			</TR>
			<CFOUTPUT QUERY="Get_Table_Fields">
				<TR BGCOLOR="White">
					<TD>#COLUMN_NAME#&nbsp;</TD>
					<TD>#TYPE_NAME#&nbsp;</TD>
					<TD>#LENGTH#&nbsp;</TD>
					<TD>#PRECISION#&nbsp;</TD>
					<TD>#SCALE#&nbsp;</TD>
					<TD>#DATA_TYPE#&nbsp;</TD>
					<TD>#IS_NULLABLE#&nbsp;</TD>
				</TR>		
			</CFOUTPUT>
		</TABLE>
		<CFFLUSH>
		<P CLASS="BreakHere">
	</CFLOOP>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Views																							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Attributes.Views EQ "Yes">
	<BR><BR><BR>
	<A NAME="views"></A>
	<CFOUTPUT>
		<TABLE BGCOLOR="#Attributes.Titlecolor#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
		<TR>
			<TD STYLE="color: white; font-size:14px" WIDTH="100%"><B>VIEWS</B></TD>
			<TD><CFIF Attributes.Links EQ "Yes"><A HREF="##top" STYLE="color: white; font-weight: bold;">top</A></CFIF></TD>
		</TR>
	</TABLE>
	<P CLASS="BreakHere">
	</CFOUTPUT>
	
	<CFQUERY NAME="Get_Views" DATASOURCE="#Attributes.Datasource#" USERNAME="#Attributes.Username#" PASSWORD="#Attributes.Password#">
		SELECT		sysObjects.Name,
					sysObjects.Crdate
		FROM		sysObjects
		WHERE		sysObjects.Type		=	'V'
		ORDER BY	sysObjects.Name
	</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generate the list of views with links to the details											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
</CFOUTPUT>
	<TR>
		<CFSET viewcounter=0>
		<CFOUTPUT QUERY="Get_Views">
		<TD BGCOLOR="White"><A HREF="###Name#" STYLE="font-size:10px;">#lcase(Name)#</A></TD>
		<CFSET viewcounter=viewcounter+1>
		#IIf(viewcounter Mod 3,DE(''),DE('</TR><TR>'))#
		</CFOUTPUT>
</TABLE>
<BR>

	<CFLOOP QUERY="Get_Views">
		<CFQUERY NAME="Get_View_Fields" DATASOURCE="#Attributes.Datasource#" USERNAME="#Attributes.Username#" PASSWORD="#Attributes.Password#">
			EXEC sp_columns @table_name = '#Get_Views.Name#'
		</CFQUERY>
	
		<CFOUTPUT>
		<A NAME="#Name#"></A>
		<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
		</CFOUTPUT>
			<TR><TD COLSPAN="100%"><FONT SIZE="2" COLOR="White"><B><CFOUTPUT>#ucase(Get_Views.Name)#</CFOUTPUT></B></FONT> - <A HREF="#views" STYLE="color:white;">back</A></TD></TR>
			<TR STYLE="font-weight:bold;" BGCOLOR="White" VALIGN="bottom">
				<TD WIDTH="175">Field Name</TD>
				<TD WIDTH="100">SQL<BR>Data Type</TD>
				<TD WIDTH="100">Size</TD>
				<TD WIDTH="75">Precision</TD>
				<TD WIDTH="50">Scale</TD>
				<TD WIDTH="75">ODBC<BR>Data Type</TD>
				<TD WIDTH="50">Required</TD>
			</TR>
			<CFOUTPUT QUERY="Get_View_Fields">
				<TR BGCOLOR="White">
					<TD>#COLUMN_NAME#&nbsp;</TD>
					<TD>#TYPE_NAME#&nbsp;</TD>
					<TD>#LENGTH#&nbsp;</TD>
					<TD>#PRECISION#&nbsp;</TD>
					<TD>#SCALE#&nbsp;</TD>
					<TD>#DATA_TYPE#&nbsp;</TD>
					<TD>#IS_NULLABLE#&nbsp;</TD>
				</TR>		
			</CFOUTPUT>
		</TABLE>
		<CFFLUSH>
		<P CLASS="BreakHere">
	</CFLOOP>
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Stored Procedures																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Attributes.Storproc EQ "Yes">
	<BR><BR><BR>
	<A NAME="storeproc"></A>
	<CFOUTPUT>
		<TABLE BGCOLOR="#Attributes.Titlecolor#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
		<TR>
			<TD STYLE="color: white; font-size:14px" WIDTH="100%"><B>STORED PROCEDURES</B></TD>
			<TD><CFIF Attributes.Links EQ "Yes"><A HREF="##top" STYLE="color: white; font-weight: bold;">top</A></CFIF></TD>
		</TR>
	</TABLE>
	<P CLASS="BreakHere">
	</CFOUTPUT>
	
	<CFQUERY NAME="Get_Sto_Proc" DATASOURCE="#Attributes.Datasource#" USERNAME="#Attributes.Username#" PASSWORD="#Attributes.Password#">
		SELECT		sysObjects.Name,		sysObjects.ID,			syscomments.ID,
					syscomments.number,		syscomments.colid,		syscomments.status,
					syscomments.texttype,	syscomments.language,	syscomments.encrypted,
					syscomments.compressed,	syscomments.text
		FROM		sysObjects,				syscomments
		WHERE		sysObjects.Type		=	'P'
					AND
					sysObjects.ID		=	syscomments.ID
		ORDER BY	sysObjects.Name
	</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generate the list of stored procedures with links to the details								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
</CFOUTPUT>
	<TR>
		<CFSET stoproccounter=0>
		<CFOUTPUT QUERY="Get_Sto_Proc">
		<TD BGCOLOR="White"><A HREF="###Name#" STYLE="font-size:10px;">#lcase(Name)#</A></TD>
		<CFSET stoproccounter=stoproccounter+1>
		#IIf(stoproccounter Mod 3,DE(''),DE('</TR><TR>'))#
		</CFOUTPUT>
</TABLE>
<BR>
	
	<CFLOOP QUERY="Get_Sto_Proc">
	<CFOUTPUT>
		<A NAME="#Name#"></A>
		<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
			<TR><TD COLSPAN="100%"><FONT SIZE="2" COLOR="White"><B>#ucase(Name)#</B></FONT> - <A HREF="##storeproc" STYLE="color:white;">back</A></TD></TR>
			<TR VALIGN="top">
				<TD BGCOLOR="White">
					<TABLE BORDER="0" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#">
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>id</B></TD>
							<TD>#id#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>number</B></TD>
							<TD>#number#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>colid</B></TD>
							<TD>#colid#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>status</B></TD>
							<TD>#status#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>texttype</B></TD>
							<TD>#texttype#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>language</B></TD>
							<TD>#language#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>encrypted</B></TD>
							<TD><CFIF encrypted EQ 1>Yes<CFELSE>No</CFIF>&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>compressed</B></TD>
							<TD><CFIF compressed EQ 1>Yes<CFELSE>No</CFIF>&nbsp;</TD>
						</TR>
					</TABLE>
				</TD>
				<TD WIDTH="100%" BGCOLOR="White">
					<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="100%">
						<TR BGCOLOR="White">
							<TD>
								<CF_PHORMAT>#text#&nbsp;</CF_PHORMAT>
							</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
		</TABLE>
	</CFOUTPUT>
	<CFFLUSH>
	<P CLASS="BreakHere">
	</CFLOOP>

</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Report on the database Triggers																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Attributes.Triggers EQ "Yes">
	<BR><BR><BR>
	<A NAME="triggers"></A>
	<CFOUTPUT>
		<TABLE BGCOLOR="#Attributes.Titlecolor#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
		<TR>
			<TD STYLE="color: white; font-size:14px" WIDTH="100%"><B>TRIGGERS</B></TD>
			<TD><CFIF Attributes.Links EQ "Yes"><A HREF="##top" STYLE="color: white; font-weight: bold;">top</A></CFIF></TD>
		</TR>
	</TABLE>
	<P CLASS="BreakHere">
	</CFOUTPUT>
	
	<CFQUERY NAME="Get_Triggers" DATASOURCE="#Attributes.Datasource#" USERNAME="#Attributes.Username#" PASSWORD="#Attributes.Password#">
		SELECT		sysObjects.Name,		sysObjects.ID,			syscomments.ID,
					syscomments.number,		syscomments.colid,		syscomments.status,
					syscomments.texttype,	syscomments.language,	syscomments.encrypted,
					syscomments.compressed,	syscomments.text
		FROM		sysObjects,				syscomments
		WHERE		sysObjects.Type		=	'TR'
					AND
					sysObjects.ID		=	syscomments.ID
		ORDER BY	sysObjects.Name
	</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generate the list of triggers with links to the details										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
</CFOUTPUT>
	<TR>
		<CFSET triggercounter=0>
		<CFOUTPUT QUERY="Get_Triggers">
		<TD BGCOLOR="White"><A HREF="###Name#" STYLE="font-size:10px;">#lcase(Name)#</A></TD>
		<CFSET triggercounter=triggercounter+1>
		#IIf(triggercounter Mod 3,DE(''),DE('</TR><TR>'))#
		</CFOUTPUT>
</TABLE>
<BR>

	<CFLOOP QUERY="Get_Triggers">
	<CFOUTPUT>
		<A NAME="#Name#"></A>
		<TABLE BGCOLOR="#Attributes.Color#" BORDER="#Attributes.Tableborder#" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#" WIDTH="#Attributes.Tablewidth#">
			<TR><TD COLSPAN="100%"><FONT SIZE="2" COLOR="White"><B>#ucase(Name)#</B></FONT> - <A HREF="##triggers" STYLE="color:white;">back</A></TD></TR>
			<TR VALIGN="top">
				<TD BGCOLOR="White">
					<TABLE BORDER="0" CELLPADDING="#Attributes.Tablepadding#" CELLSPACING="#Attributes.Tablespacing#">
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>id</B></TD>
							<TD>#id#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>number</B></TD>
							<TD>#number#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>colid</B></TD>
							<TD>#colid#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>status</B></TD>
							<TD>#status#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>texttype</B></TD>
							<TD>#texttype#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>language</B></TD>
							<TD>#language#&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>encrypted</B></TD>
							<TD><CFIF encrypted EQ 1>Yes<CFELSE>No</CFIF>&nbsp;</TD>
						</TR>
						<TR BGCOLOR="White" VALIGN="top">
							<TD><B>compressed</B></TD>
							<TD><CFIF compressed EQ 1>Yes<CFELSE>No</CFIF>&nbsp;</TD>
						</TR>
					</TABLE>
				</TD>
				<TD WIDTH="100%" BGCOLOR="White">
					<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="100%">
						<TR BGCOLOR="White">
							<TD><CF_PHORMAT>#text#&nbsp;</CF_PHORMAT></TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
		</TABLE>
	
	</CFOUTPUT>
	</CFLOOP>
	
	<CFFLUSH>
	<P CLASS="BreakHere">
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 																									
																										
			Author        			Frank Lopes															
			Copyright     			Frank Lopes, 2002, All rights reserved								
			Version       			1.4																	
			Date Originally Coded	April 13, 2002														
			Last Modified Date		April 15, 2002														
																										
																										
	===============================================================================================		
												WARNING													
	===============================================================================================		
																										
	<CF_SQLdocumenter> retrieves from a given datasource all details associated with its tables, views,	
	stored procedures and triggers. This includes complete stored procedures code, table fields, data	
	types, data defaults, precision, scale etc.															
																										
	However a warning is appropriate at this point:														
																										
	It is not uncommon for a large database to have hundreds or thousands of tables, views, triggers or	
	stored procedures. This tag if asked to retrieve all these objects will do so without regard		
	for the amount of data being retrieved. Depending of the number of items and the complexity of 		
	the objects (for example the number of table fields ), it may take several minutes to output all 	
	of the data. Database load/traffic should be taken in consideration before using this tag.			
																										
	It is recommended that you experiment with the minimum configuration, which will retrieve only		
	the details of the database tables.																	
																										
	As a point of reference, when this tag is applied to the demo Northwind DB that comes with Sql		
	Server 2000, it generates 180Kb of data creating 8,000 lines of output.								
																										
	We are not responsible for any unexpected large volumes of data being generated.					
																										
	===============================================================================================		
																										
	Parameter usage																						
	---------------																						
	Datasource=		"the name of the datasource												- Required	
	Username=		"the user login to the db												- Optional	
	Password=		"the password of the user login											- Optional	
	Tables=			"yes/no view or not the db tables										- Optional	
	Views=			"yes/no view or not the db views										- Optional	
	Storproc=		"yes/no view or not the db stored procedures							- Optional	
	Triggers=		"yes/no view or not the db triggers										- Optional	
	Color=			"name of the color used by the outputed tables: blue, gray etc			- Optional	
	Titlecolor=		"name of the color used by the titles: blue, gray etc					- Optional	
	Tablewidth=		"width of the outputed data: in pixels									- Optional	
	Tablepadding=	"padding used by the outputed data: in pixels							- Optional	
	Tablespacing=	"spacing used by the outputed data: in pixels							- Optional	
	Tableborder=	"width of the table borders used by the outputed data: in pixels		- Optional	
	Fontface=		"name of the font used: verdana, arial etc 								- Optional	
	Fontsize=		"size of the font used: in pixels 										- Optional	
	Links=			"yes/no view naviagtion links at the top of the page 					- Optional	
	Pagebreaks=		"yes/no create page breaks so that each page only prints one object 	- Optional	
																										
																										
	Example 1																							
	---------																							
	Minimum use will display the data associated with the DB tabes.	Tables are allways displayed by		
	default:																							
																										
		<CF_SQLdocumenter Datasource="northwind">														
																										
																										
	Example 2																							
	---------																							
	Show only the stored procedures with the title in red.Since tables always come by default, you		
	must specificaly set the Tables parameter to "No":													
																										
		<CF_SQLdocumenter Datasource="northwind" Titlecolor="Red" Tables="no" Storproc="yes">			
																										
																										
	Example 3																							
	---------																							
	The tag in its full glory, all of the parameters:													
																										
		<CF_SQLdocumenter																				
		Datasource=		"northwind"																		
		Username=		"sa"																			
		Password=		"password"																		
		Tables=			"yes"																			
		Views=			"yes"																			
		Storproc=		"yes"																			
		Triggers=		"yes"																			
		Color=			"gray"																			
		Titlecolor=		"black"																			
		Tablewidth=		"700"																			
		Tablepadding=	"1"																				
		Tablespacing=	"1"																				
		Tableborder=	"0"																				
		Fontface=		"verdana"																		
		Fontsize=		"11px"																			
		Links=			"Yes"																			
		Pagebreaks=		"Yes">																			
																										
																										
	===============================================================================================		
												WARNING													
	===============================================================================================		
																										
	<CF_SQLdocumenter> retrieves from a given datasource all details associated with its tables, views,	
	stored procedures and triggers. This includes complete stored procedures code, table fields, data	
	types, data defaults, precision, scale etc.															
																										
	However a warning is appropriate at this point:														
																										
	It is not uncommon for a large database to have hundreds or thousands of tables, views, triggers or	
	stored procedures. This tag if asked to retrieve all these objects will do so without regard		
	for the amount of data being retrieved. Depending of the number of items and the complexity of 		
	the objects (for example the number of table fields ), it may take several minutes to output all 	
	of the data. Database load/traffic should be taken in consideration before using this tag.			
																										
	It is recommended that you experiment with the minimum configuration, which will retrieve only		
	the details of the database tables.																	
																										
	As a point of reference, when this tag is applied to the demo Northwind DB that comes with Sql		
	Server 2000, it generates 180Kb of data creating 8,000 lines of output.								
																										
	We are not responsible for any unexpected large volumes of data being generated.					
																										
	===============================================================================================		
																										
																									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

