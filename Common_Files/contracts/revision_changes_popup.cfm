<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Revision Changes</title>
</head>

<body>
<cfparam name="url.programid" default="0">
<cfparam name="url.parentid" default="0">
<cfparam name="url.programspan" default="0">
<cfset RevisionProgramManager = CreateObject("component","components.programs.ReviseLog") />
<cfset PrgChanges = RevisionProgramManager.PrgChanges(url.programid)>
<TABLE CLASS="Maintable" CELLPADDING="4" CELLSPACING="0" WIDTH="80%" align="center">
<CFIF PrgChanges.operators_removed GT 1 or PrgChanges.operators_added GT 1>
<CFIF PrgChanges.operators_added GT 1>
<cfset PrgOprAdded = RevisionProgramManager.getOperatorsChanged(url.programid,url.parentid,1)><!--- Dinesh --->
<cfif PrgOprAdded.recordcount GT 0>
	<TR BGCOLOR="FFCE84" VALIGN="top"> 
		<TD ID="header" VALIGN="top"><B>Operators Added</B></TD>
	</TR>
	<cfoutput query="PrgOprAdded">
	<TR BGCOLOR="f4f4f4" VALIGN="top">
	<td align="left">#PrgOprAdded.Child_Name# - #PrgOprAdded.Child_Legacy_Id#
	</td>
	</TR>
	</cfoutput>
</cfif>
</CFIF>

<CFIF PrgChanges.operators_removed GT 1>
<cfset PrgOprRemoved = RevisionProgramManager.getOperatorsChanged(url.parentid,url.programid,1)>
<cfif PrgOprAdded.recordcount GT 0>
	<TR BGCOLOR="FFCE84" VALIGN="top"> 
		<TD ID="header" VALIGN="top"><B>Operators Removed</B></TD>
	</TR>
	<cfoutput query="PrgOprRemoved">
<TR BGCOLOR="f4f4f4" VALIGN="top">
	<td align="left">#PrgOprRemoved.Child_Name# - #PrgOprRemoved.Child_Legacy_Id#
	</td>
	</TR>
	</cfoutput>
</cfif>
</CFIF>
</CFIF>



<CFIF PrgChanges.products_removed GT 1 or PrgChanges.products_added GT 1>
	<CFIF PrgChanges.products_added GT 1>
	<cfset PrgPrdAdded = RevisionProgramManager.getProductsChanged(url.programid,url.parentid,1)>
		<cfif PrgPrdAdded.recordcount GT 0>
			<TR BGCOLOR="FFCE84" VALIGN="top"> 
				<TD ID="header" VALIGN="top"><B>Products Added</B></TD>
			</TR>
			<cfoutput query="PrgPrdAdded" group="type_code_desc">
			<TR bgcolor="CCFFCC">
			<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="CCFFCC">#Type_Code_Desc#</TD>
			</tr>
			<cfoutput>
			<TR BGCOLOR="f4f4f4" VALIGN="top">
			<td align="left">#PrgPrdAdded.First_Name# - #PrgPrdAdded.First_ItemNumber#
			</td>
			</TR>
			</cfoutput>
			</cfoutput>
		</cfif>
	</CFIF>
	
	<CFIF PrgChanges.products_removed GT 1>
		<cfset PrgPrdRemoved = RevisionProgramManager.getProductsChanged(url.parentid,url.programid,1)>
		<cfif PrgPrdRemoved.recordcount GT 0>
			<TR BGCOLOR="FFCE84" VALIGN="top"> 
				<TD ID="header" VALIGN="top"><B>Products Removed</B></TD>
			</TR>
			<cfoutput query="PrgPrdRemoved" group="type_code_desc">
			<TR bgcolor="CCFFCC">
			<TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="CCFFCC">#Type_Code_Desc#</TD>
			</tr>
			<cfoutput>
			<TR BGCOLOR="f4f4f4" VALIGN="top">
			<td align="left">#PrgPrdRemoved.First_Name# - #PrgPrdRemoved.First_ItemNumber#
			</td>
			</TR>
			</cfoutput>
			</cfoutput>
		</cfif>
	</CFIF>
</CFIF>



<CFIF PrgChanges.distributors_removed GT 1 or PrgChanges.distributors_added GT 1>
<CFIF PrgChanges.distributors_added GT 1>
<cfset PrgDisAdded = RevisionProgramManager.getDistributorsChanged(url.programid,url.parentid,1)>
<cfif PrgDisAdded.recordcount GT 0>
	<TR BGCOLOR="FFCE84" VALIGN="top"> 
		<TD ID="header" VALIGN="top"><B>Distributors Added</B></TD>
	</TR>
	<cfoutput query="PrgDisAdded">
	<TR BGCOLOR="f4f4f4" VALIGN="top">
	<td align="left">#PrgDisAdded.child_name# - #PrgDisAdded.child_shr_ship_to#
	</td>
	</TR>
	</cfoutput>
</cfif>
</CFIF>

<CFIF PrgChanges.distributors_removed GT 1>
<cfset PrgDisRemoved = RevisionProgramManager.getDistributorsChanged(url.parentid,url.programid,1)>
<cfif PrgDisRemoved.recordcount GT 0>
	<TR BGCOLOR="FFCE84" VALIGN="top"> 
		<TD ID="header" VALIGN="top"><B>Distributors Removed</B></TD>
	</TR>
	<cfoutput query="PrgDisRemoved">
	<TR BGCOLOR="f4f4f4" VALIGN="top">
	<td align="left">#PrgDisRemoved.child_name# - #PrgDisRemoved.child_shr_ship_to#
	</td>
	</TR>
	</cfoutput>
</cfif>
</CFIF>
</CFIF>

<!--- D32777: [view revision changes] from margin page START --->

		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
							
							<cfquery name="Changes" datasource="#application.datasource#">
								SELECT   Parent.Contract_title AS Parent_title, Parent.contract_start_date AS Parent_Start_Date, Parent.Contract_end_date AS Parent_End_Date, 
											 Child.Contract_title AS Child_title, Child.contract_start_date AS Child_Start_Date, Child.Contract_end_date AS Child_End_date
								FROM    Contract_main Parent, contract_main Child
								WHERE   Parent.contract_main_id = #url.parentid# AND Child.contract_main_id = #url.programid#
							</cfquery>
				<!--- Title Change START--->					
							<cfif Changes.Parent_title NEQ  Changes.Child_title>
								<TR BGCOLOR="FFCE84" VALIGN="top"> 
									<TD ID="header" VALIGN="top"><B>Title Change</B></TD>
								</TR>
								<TR BGCOLOR="f4f4f4" VALIGN="top">
									<TD align="left"><B>From :  </B><cfoutput>#Changes.Parent_title#</cfoutput></TD>
								</TR>
								<TR BGCOLOR="f4f4f4" VALIGN="top">
									<TD align="left"><B>To :  </B><cfoutput>#Changes.Child_title#</cfoutput></TD>
								</TR>
							</cfif>
				<!--- Title Change END--->
			
				<!--- Date	Change START --->	
							<cfif (Changes.Parent_Start_Date NEQ Changes.Child_Start_Date)>
								<TR BGCOLOR="FFCE84" VALIGN="top"> 
									<TD ID="header" VALIGN="top"><B>Start Date Change</B></TD>
								</TR>
								<TR BGCOLOR="f4f4f4" VALIGN="top">
									<TD align="left"><cfoutput>From :   #Changes.Parent_Start_Date#     <br>  To :  #Changes.Child_Start_Date#</cfoutput></TD>
								</TR>								
							<cfelseif (Changes.Parent_End_Date NEQ Changes.Child_End_Date)>	
								<TR BGCOLOR="FFCE84" VALIGN="top"> 
									<TD ID="header" VALIGN="top"><B>End Date Change</B></TD>
								</TR>
								<TR BGCOLOR="f4f4f4" VALIGN="top">
									<TD align="left"><cfoutput>From :   #Changes.Parent_End_Date#     <br>  To :  #Changes.Child_End_Date#</cfoutput></TD>
								</TR>
							</cfif>
				<!--- Date	Change END --->					

				<!--- Volume Change START --->	
							<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
									Select		Volume_UOT_ID
									From		_Users_Settings
									Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
							</CFQUERY>
							<cfset ParentVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(#url.parentid#, #url.programspan#, #Get_Settings.Volume_UOT_ID#) />
							<cfset ChildVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(#url.programid#, #url.programspan#, #Get_Settings.Volume_UOT_ID#) />
										
						<cfif appSettings.getViewProgramVolumeUOM() EQ 2>

								<cfif NOT find(trim(numberformat(round(ChildVolQty.ProgramQtglbs),'___,___,___,___,___,___')), trim(numberformat(round(ParentVolQty.ProgramQtglbs),'___,___,___,___,___,___')))>
										<TR BGCOLOR="FFCE84" VALIGN="top"> 
											<TD ID="header" VALIGN="top"><B>Volume Change</B></TD>
										</TR>
										<TR BGCOLOR="f4f4f4" VALIGN="top">
											<TD align="left">
												<cfoutput>
														<b>From :  </b> #trim(numberformat(round(ChildVolQty.ProgramQtglbs),'___,___,___,___,___,___'))# Pounds <br>
														<b>To :  </b>#trim(numberformat(round(ParentVolQty.ProgramQtglbs),'___,___,___,___,___,___'))# Pounds
												</cfoutput>
											</TD>
										</TR>									
								</cfif>	
								
						<cfelse>
								
								<cfif NOT find(trim(numberformat(round(ChildVolQty.ProgramQtgCases),'___,___,___,___,___,___')), trim(numberformat(round(ParentVolQty.ProgramQtgCases),'___,___,___,___,___,___')))>
										<TR BGCOLOR="FFCE84" VALIGN="top"> 
											<TD ID="header" VALIGN="top"><B>Volume Change</B></TD>
										</TR>
										<TR BGCOLOR="f4f4f4" VALIGN="top">
											<TD align="left">
												<cfoutput>
														<b>From :  </b> #trim(numberformat(round(ChildVolQty.ProgramQtgCases),'___,___,___,___,___,___'))# Cases    <br>
														<b>To :  </b>#trim(numberformat(round(ParentVolQty.ProgramQtgCases),'___,___,___,___,___,___'))# Cases
												</cfoutput>
											</TD>
										</TR>	
								</cfif>	
								
				 		</cfif>	

					<!--- Volume Change END --->	
<!--- D32777: [view revision changes] from margin page END --->
</TABLE>

<TABLE ALIGN="center"><TR>
		<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		></td>
</tr>
</td>
</body>
</html>
