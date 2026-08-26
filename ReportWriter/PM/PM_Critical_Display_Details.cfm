
<CFSAVECONTENT VARIABLE="Details">

<CFIF isdefined("URL.Send_Email")>
<BLOCKQUOTE>
</CFIF>

<STYLE>
<CFINCLUDE TEMPLATE="/Common_Files/Main_Style.css">
</STYLE>


<TABLE border="0" cellspacing="0" cellpadding="2" bgcolor="WhiteSmoke" <CFIF isdefined("URL.Print")>WIDTH="100%"<CFELSE>WIDTH="92%"</CFIF>>
	<TR>
		<TD width="125"></TD>
		<TD></TD>
		<TD width="80"></TD>
		<TD></TD>
		<TD width="80"></TD>
		<TD></TD>
		<TD width="125"></TD>
		<TD></TD>
	</TR>

<CFOUTPUT QUERY="Display_Critical">
	<CFIF isdefined("URL.Print") AND CurrentRow GT 1>	
	<TR>
		<TD><div class="pageBreakBefore"></div></TD>
	</TR>				
	</CFIF>
	<CFQUERY NAME="Get_Position" datasource="#application.datasource#">
		Select		Position_Label, User_Positions.User_Positions_ID
		From 		PM_Owner_Position
					INNER JOIN User_Positions	
					ON
					User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
		Where 		
					PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
	</CFQUERY>

	<CFQUERY NAME="Get_Programs" datasource="#application.datasource#">
		Select		distinct PM_Programs.*,
					Contract_Main.Contract_Title,
					Contract_Main.contract_main_id,
					Contract_Main.Deleted
		From		PM_Programs,
					Contract_Main
		Where		PM_Programs.PM_Item_Master_ID	like	'#PM_Item_Master_ID#'
					and
					Contract_Main.Contract_Number	=	PM_Programs.PM_Contract_Number
					and
					Contract_Main.Deleted			=	0
		order by	PM_Programs.PM_Contract_Number, Contract_Main.Deleted
	</CFQUERY>
	
	<CFQUERY NAME="Full_Type_Group_List" DATASOURCE="#application.datasource#">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_type_group_syntax#">
	</CFQUERY>
	
	<CFQUERY NAME="Saved_Type_Groups" DATASOURCE="#application.datasource#">
		SELECT 	Q_Brand_ID
		FROM	PM_Qbrands
		WHERE	PM_Qbrands.PM_Item_Master_ID	like	'#PM_Item_Master_ID#'
	</CFQUERY>
	
	<CFSET Saved_Type_Groups_List = ListQualify(ValueList(Saved_Type_Groups.Q_Brand_ID), "'")>
	
	<CFQUERY NAME="Get_QBrands" DBTYPE="Query">
		Select 	*
		FROM	Full_Type_Group_List
		WHERE
				1= 2
				<CFIF LEN(Saved_Type_Groups_List) GT 0>
				OR
				Full_Type_Group_List.Type_Group_Desc_ID IN
				(#PreserveSingleQuotes(Saved_Type_Groups_List)#)
				</CFIF>				
	</CFQUERY>
	
	<CFQUERY NAME="Get_Brokers" datasource="#application.datasource#">
		Select		distinct 
					BSA_Foodservice_Brokers.Broker_Name
		From		BSA_Foodservice_Brokers
		Where		
					BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN
					(
						SELECT 	PM_Brokers.BSA_Foodservice_Brokers_ID
						FROM	PM_Brokers
						WHERE	
								PM_Brokers.PM_Item_Master_ID	like	'#PM_Item_Master_ID#'
								AND
								PM_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
					)
		order by	BSA_Foodservice_Brokers.Broker_Name
	</CFQUERY>
	
	<CFQUERY NAME="Get_Distributors" datasource="#application.datasource#">
		Select		distinct BSA_Foodservice_Customers.Name
		From		BSA_Foodservice_Customers
		Where		
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
					(
						SELECT 	PM_Distributors.BSA_Foodservice_Customers_ID
						FROM	PM_Distributors
						WHERE	
								PM_Distributors.PM_Item_Master_ID	like	'#PM_Item_Master_ID#'
								AND
								PM_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					)
		order by	BSA_Foodservice_Customers.Name
	</CFQUERY>
	
	<CFQUERY NAME="Get_operators" datasource="#application.datasource#">
		Select		distinct BSA_Operator.Operator_Name
		From		BSA_Operator
		Where		
					BSA_Operator.BSA_Operator_ID IN
					(
						SELECT 	PM_operators.BSA_Operator_ID
						FROM	PM_operators
						WHERE	
								PM_operators.PM_Item_Master_ID	like	'#PM_Item_Master_ID#'
								AND
								PM_operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
					)
		order by	BSA_Operator.Operator_Name
	</CFQUERY>
	
	<CFQUERY NAME="Get_Notes" DATASOURCE="#application.datasource#">
		SELECT	PM_Notes.PM_Notes, Name_First + ' ' + Name_Last AS Full_Name, PM_Notes.Created_Date
		FROM	PM_Notes
				INNER JOIN _Users
				ON _Users.User_ID = PM_Notes.User_ID
		WHERE
				PM_Notes.PM_Item_Master_ID = '#PM_Item_Master_ID#'
		ORDER BY PM_Notes.Created_Date DESC 				
	</CFQUERY>
	
	<cfset useLakebaseForCheck_attachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForCheck_attachments>
	<cftry>
		<cfset Check_attachments = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_attachments", {
				"project_id" = "eq.#PM_Item_Master_ID#",
				"select" = "doc_id"
			}), "doc_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_attachments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_attachments>
<CFQUERY NAME="Check_attachments" DATASOURCE="#Application.Datasource#">
		SELECT Doc_ID FROM Contract_Attachments WHERE Project_ID = '#PM_Item_Master_ID#'
	</CFQUERY>
</cfif>
	
	<TR BGCOLOR="##C6FFC6">
		<TD colspan="100%" width="100%" STYLE="border-bottom: solid 1px blue;"><CFIF isdefined("URL.Print")><BR><BR></CFIF>
		<B>#ucase(PM_Acct_Project)#</B>		
		&nbsp;&nbsp;
		<CFIF Not isdefined("URL.Send_Email")>
		<CFIF Check_attachments.recordcount GT 0><IMG SRC="/images/doc.gif" ALT="This project has #Check_attachments.recordcount# attached document(s)" height="16" width="13"></CFIF></TD>
		</CFIF>
	</TR>
	<TR>
		<TD nowrap align="right" valign="top"><B>Priority:</B></TD>
		<TD valign="top">#PM_Priority_Description#</TD>
		<TD align="right" nowrap valign="top"><B>Value - lbs:</B></TD>
		<TD valign="top">#numberformat(PM_Value_Pounds, '_,___,___,___')#</TD>
		<TD nowrap align="right" valign="top"><B>Functional Area:</B></TD>
		<TD valign="top">#PM_Far_Description#</TD>
		<TD align="right" nowrap valign="top"><B>Sponsor:</B>					
		</TD>
		<TD valign="top" WIDTH="150">#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#&nbsp;
		<!------<a href="MAILTO:#Get_sponsor.PM_Sponsor_Email#?subject=#PM_Acct_Project# project"><IMG src="/Images/email_small.gif" border="0"></a>----->		
		</TD>
	</TR>
	<TR>
		<TD nowrap align="right" valign="top"><B>Status:</B></TD>
		<TD valign="top">#PM_Status_Description#</TD>
		<TD align="right" nowrap valign="top"><B>Value - $:</B></TD>
		<TD valign="top">#numberformat(PM_Value_Dollars, '_,___,___,___')#</TD>
		<TD align="right" nowrap valign="top"><B>Support:</B></TD>
		<TD valign="top">#PM_Support#</TD>
		<TD align="right" nowrap valign="top"><B>Timeline:</B></TD>
		<TD valign="top">#dateformat(PM_Start_Date, 'm/d/yy')# - #dateformat(PM_End_Date, 'm/d/yy')#</TD>
	</TR>
	<TR>
		<TD nowrap align="right" valign="top"><B>Phase:</B></TD>
		<TD valign="top">#PM_Phase_Description#</TD>
		<TD align="right" nowrap valign="top"><B>Budget - $:</B></TD>
		<TD valign="top">#numberformat(PM_Ext_Budget, '_,___,___,___')#</TD>
		<TD align="right" nowrap valign="top"><B>Resources - $:</B></TD>
		<TD valign="top">#numberformat(PM_Resources, '_,___,___,___')#</TD>
		<TD align="right" nowrap valign="top"><B>Actual - $:</B></TD>
		<TD valign="top">#numberformat(PM_Actual, '_,___,___,___')#</TD>
	</TR>
	<TR>
		<TD nowrap align="right" valign="top"><B>CER/Acct number:</B></TD>
		<TD valign="top">#PM_CER#</TD>					
		<!------<TD COLSPAN="4"></TD>----->
		<TD></TD><TD></TD><TD></TD><TD></TD>
	</TR>
	<CFSET colCount = 4>
	<CFSET colPercent = 100 / colCount>
	<TR>
		<TD VALIGN="TOP" ALIGN="RIGHT">
		<B>Owner Positions:</B><BR>
		</TD>
		<TD COLSPAN="100%">					
		<CFIF Get_Position.recordCount GT 0>
			<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
			<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
			<TR>
			<CFSET Mycounter=0> 
			<CFLOOP QUERY="Get_Position">					
           	   	<TD STYLE="border-bottom: 1px silver solid">				
				<FONT SIZE="1">#Position_Label#</FONT></TD> 
	            <CFSET Mycounter=Mycounter+1> 
              		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR>'))# 
             	    </CFLOOP>
			<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
				<TD></TD>
			</cfloop> 
			</TABLE>
		</CFIF>
		</TD>
	</TR>
	<TR>
		<TD VALIGN="TOP" ALIGN="RIGHT">
		<B>#application.returned_customer_setting.type_group_label_plural#:</B><BR>
		</TD>
		<TD COLSPAN="100%">					
		<CFIF Get_QBrands.recordCount GT 0>
			<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
			<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
			<TR>
			<CFSET Mycounter=0> 
			<CFLOOP QUERY="Get_QBrands"> 					
          	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#TYPE_GROUP_DESC#</FONT></TD> 
            <CFSET Mycounter=Mycounter+1> 
             		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR>'))# 
             	    </CFLOOP>
			<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
				<TD></TD>
			</cfloop> 
			</TABLE>
		</CFIF>
		</TD>
	</TR>
	<TR>
		<TD VALIGN="TOP" ALIGN="RIGHT">
		<B>#application.returned_customer_setting.broker_label_plural#:</B><BR>
		</TD>
		<TD COLSPAN="100%">
		<CFIF Get_Brokers.recordCount GT 0>
			<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
			<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
			<TR>
			<CFSET Mycounter=0> 
			<CFLOOP QUERY="Get_Brokers"> 					
          	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#Broker_Name#</FONT></TD> 
            <CFSET Mycounter=Mycounter+1> 
             		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR>'))# 
             	    </CFLOOP>
			<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
				<TD></TD>
			</cfloop>
			</TABLE>
		</CFIF>	  
		</TD>
	</TR>
	<TR>
		<TD VALIGN="TOP" ALIGN="RIGHT">
		<B>#application.returned_customer_setting.distributor_label_plural#:</B><BR>
		</TD>
		<TD COLSPAN="100%">
		<CFIF Get_Distributors.recordCount GT 0>
			<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
			<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
			<TR>
			<CFSET Mycounter=0> 
			<CFLOOP QUERY="Get_Distributors"> 					
          	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#Name#</FONT></TD> 
            <CFSET Mycounter=Mycounter+1> 
             		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR>'))# 
             	    </CFLOOP> 
			<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
				<TD></TD>
			</cfloop>
			</TABLE>					
		</CFIF>
		</TD>
	</TR>	
	<TR>
		<TD VALIGN="TOP" ALIGN="RIGHT">
		<B>#application.returned_customer_setting.Operator_label_plural#:</B><BR>
		</TD>
		<TD COLSPAN="100%">
		<CFIF Get_Operators.recordCount GT 0>
			<TABLE BORDER="0" WIDTH="100%" CELLSPACING="1" CELLPADDING="0"> 
			<COLGROUP><COL SPAN="4" WIDTH="#colPercent#%"></COLGROUP>
			<TR>
			<CFSET Mycounter=0> 
			<CFLOOP QUERY="Get_Operators"> 					
          	   	<TD STYLE="border-bottom: 1px silver solid"><FONT SIZE="1">#Operator_Name#</FONT></TD> 
            <CFSET Mycounter=Mycounter+1> 
             		#IIf(Mycounter Mod colCount,DE(''),DE('</TR><TR>'))# 
             	    </CFLOOP> 
			<cfloop index="LoopCount" from="#Mycounter#" to="#colCount#">
				<TD></TD>
			</cfloop>
			</TABLE>
		</CFIF>
		</TD>
	</TR>		
	<TR>
		<TD nowrap align="right" valign="top"><B>Programs:</B></TD>
		<TD colspan="100%" valign="top" width="100%">

			<!--- Show contracts associated with this project --->
			<CFLOOP QUERY="Get_Programs">
				<CF_CRYP type="en" key="#request.key#" string="#contract_main_id#">
				<CFSET CID = cryp.value>
				<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="95%">
				<TR VALIGN="top">
					<TD NOWRAP STYLE="border-bottom: 1px silver solid"><B>#Get_Programs.PM_Contract_Number#</B></TD>
					<TD WIDTH="100%" STYLE="border-bottom: 1px silver solid"><SPAN STYLE="FONT-SIZE:10PX;">#left(Get_Programs.Contract_Title, 100)#...</SPAN></TD>
				</TR>
				</TABLE>
			</CFLOOP>

		</TD>
	</TR>
	<TR>
		<TD nowrap align="right" valign="top"><B>Next Step/Update:</B></TD>
		<TD colspan="100%" valign="top" width="100%">
		<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="95%">						
		<CFLOOP QUERY="Get_Notes">
		<TR VALIGN="top">
			<TD STYLE="border-bottom: 1px silver solid">#Full_Name#</TD>
			<TD STYLE="border-bottom: 1px silver solid">#DateFormat(Created_Date, "mm/dd/yyyy")#</TD>					
			<TD STYLE="border-bottom: 1px silver solid" WIDTH="80%">
			#PM_Notes#
			</TD>
			</TR>					
		</CFLOOP>
		</TABLE>
		</TD>
	</TR>
	<TR>
		<TD colspan="100%" valign="top" width="100%"><BR></TD>
	</TR>
	<TR>
		<TD colspan="100%" valign="top" width="100%" bgcolor="FFFFFF"><BR></TD>
	</TR>
	
</CFOUTPUT>
	
</TABLE>
<CFIF isdefined("URL.Send_Email")>
<BLOCKQUOTE>
</CFIF>

</CFSAVECONTENT>