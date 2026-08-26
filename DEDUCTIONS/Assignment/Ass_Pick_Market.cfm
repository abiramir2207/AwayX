
<CFPARAM NAME="FORM.Form_Submit" DEFAULT="">

<!---  #Evaluate("get_customer_settings.#array_column_name[loopcount]#")# --->
<CFIF FORM.Form_Submit EQ 1>
	<!--- <CFDUMP VAR="#Form#">
	<CFABORT> --->
	<cfset useLakebaseFordel_Mk_Assigned = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_assignment")>
	<cfif useLakebaseFordel_Mk_Assigned>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_assignment",
				{ "service_market_id" = "not.is.null", "deleted" = "eq.0" },
				{ "deleted" = 1 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseFordel_Mk_Assigned = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseFordel_Mk_Assigned>
	<CFQUERY NAME="del_Mk_Assigned" DATASOURCE="#Application.Datasource#">
		UPDATE 		DD_Assignment 		
		
		SET			Deleted = 1
		
		WHERE		Service_Market_ID is Not null 
					AND Deleted = 0
	</CFQUERY>
	</cfif>
	<cfset useLakebaseForSet_back = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
	<cfif useLakebaseForSet_back>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_analyst",
				{ "deleted" = "eq.0" },
				{ "ass_market" = 0 }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForSet_back = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSet_back>
	<CFQUERY NAME="Set_back" DATASOURCE="#Application.Datasource#">
		UPDATE 	DD_Analyst
		
		SET		Ass_Market = 0
		
		WHERE	Deleted = 0	
	</CFQUERY>
	</cfif>


	
	<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.Record_count#">
		<CFIF isdefined("Market_ID_#LoopCount#")>
		
			<cfset useLakebaseForUp_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
			<cfif useLakebaseForUp_Analyst>
				<cftry>
					<cfset application.oLakebase.updateRows("dd_analyst",
						{ "analyst_user_id" = "eq.#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#", "deleted" = "eq.0" },
						{ "ass_market" = 1 }
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForUp_Analyst = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForUp_Analyst>
			<CFQUERY NAME="Up_Analyst" DATASOURCE="#Application.Datasource#">
				UPDATE 	DD_Analyst
			
				SET		Ass_Market = 1
			
				WHERE	Analyst_User_ID	=	'#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#' AND Deleted=0
			</CFQUERY>					
			</cfif>
			
			<CFLOOP LIST="#Evaluate("FORM.Market_ID_#LoopCount#")#" INDEX="Item">
				<cfset useLakebaseForinsert_data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_assignment")>
				<cfif useLakebaseForinsert_data>
					<cftry>
						<cfset application.oLakebase.insertRow("dd_assignment", {
							"analyst_user_id" = Evaluate("FORM.Analyst_User_ID_#LoopCount#"),
							"service_market_id" = Item
						})>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForinsert_data = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForinsert_data>
				<CFQUERY NAME="insert_data" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					
					DD_Assignment	(	Analyst_User_ID,
										Service_Market_ID	)
										
					VALUES			(	'#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#',
										'#Item#'	)
				</CFQUERY>
				</cfif>
			</CFLOOP>		
				
		</CFIF>
	</CFLOOP>
	
	<cfset useLakebaseForDecide_Location = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_assignment")>
	<cfif useLakebaseForDecide_Location>
		<cftry>
			<cfset Decide_Location = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_assignment", {
					"family_id" = "not.is.null",
					"deleted" = "eq.0",
					"limit" = "1"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDecide_Location = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDecide_Location>
	<CFQUERY NAME="Decide_Location" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM DD_Assignment WHERE Family_ID is not null and Deleted=0
	</CFQUERY>
	</cfif>
	<CFIF Decide_Location.recordcount GT 0>
		<CFLOCATION URL="index2.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="index2.cfm?Show_Step=4" ADDTOKEN="No">
	</CFIF>
	
	
<CFELSE>
<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
	SELECT 		DD_Analyst_ID,
				Analyst_User_ID,
				Name_First,
				Name_Last 

	FROM 		DD_Analyst 

	INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID

	WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0
	ORDER BY 	Name_First
</CFQUERY>

<CFQUERY NAME="MK_Lookup" DATASOURCE="#Application.Datasource#">
	SELECT 		Service_Markets.Service_Market_ID,
				Market_Name , 
				User_Positions.Position_Label,
				Market_Number    <!---32567--->
	FROM 		Service_Markets 
	INNER JOIN 	User_Positions
						ON User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
						AND User_Positions.Deleted = 0
	WHERE 		Service_Markets.Deleted = 0 AND 
				Service_Markets.Service_Market_ID Not in (	SELECT 	Service_Market_ID 
											FROM 	DD_Assignment 
											WHERE 	Deleted = 0	AND Service_Market_ID is not null	)

	ORDER BY	Market_Name
</CFQUERY>
<!--- 

 --->
<BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="left" WIDTH="600">
	
	<FORM NAME="Pk_Market" ACTION="Ass_Pick_Market.cfm" METHOD="Post">
	<INPUT TYPE="Hidden" NAME="Form_Submit" VALUE="1">
	<TR>
	<CFOUTPUT><INPUT TYPE="Hidden" NAME="Record_Count" VALUE="#Get_Analyst.recordcount#"></CFOUTPUT>
		<TD WIDTH="350"  VALIGN="Top">
		<CFLOOP QUERY="Get_Analyst">
		<CFOUTPUT><INPUT TYPE="Hidden" NAME="Analyst_User_ID_#currentrow#" VALUE="#Analyst_User_ID#"></CFOUTPUT>
		
		<CFQUERY NAME="Analyst_MK" DATASOURCE="#Application.Datasource#">
			SELECT  	DD_Assignment.Service_Market_ID,
						Market_Name,
						User_Positions.Position_Label,
					  Market_Number    <!---32567--->
			FROM 		DD_Assignment 
			INNER JOIN 	Service_Markets ON Service_Markets.Service_Market_ID = DD_Assignment.Service_Market_ID
			INNER JOIN 	User_Positions
						ON User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
						AND User_Positions.Deleted = 0
			WHERE 		Analyst_User_ID = '#Analyst_User_ID#' AND DD_Assignment.Deleted=0 AND Service_Markets.Deleted=0
			ORDER BY 	Market_Name
		</CFQUERY>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="<CFOUTPUT>#Name_First# #Name_Last#</CFOUTPUT>:"  
			TitleClosed="<CFOUTPUT>#Name_First# #Name_Last#</CFOUTPUT>:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="380px">	
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<!--- <TD VALIGN="Top" WIDTH="150" NOWRAP>&nbsp;&nbsp;</TD>			 --->
				<TD VALIGN="Top" WIDTH="250">
					<SELECT <CFOUTPUT>NAME="Market_ID_#currentrow#"</CFOUTPUT> SIZE="4" STYLE="WIDTH:340px" MULTIPLE>
						<CFOUTPUT QUERY="Analyst_MK">
							<OPTION VALUE="#Service_Market_ID#">#Analyst_MK.Market_Name# <cfif len(trim(Analyst_MK.Position_Label))>[#Analyst_MK.Position_Label#, #Analyst_MK.market_number#]</cfif></OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top" WIDTH="27" ALIGN="center">
					<CFOUTPUT><INPUT TYPE="BUTTON" NAME="Add_Market_#currentrow#" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('Service_Market_ID','Market_ID_#currentrow#', 1)" STYLE="WIDTH:25px"></CFOUTPUT><BR>
					<CFOUTPUT><INPUT TYPE="BUTTON" NAME="Remove_Market_#currentrow#" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Market_ID_#currentrow#','Service_Market_ID', 2)" STYLE="WIDTH:25px"></CFOUTPUT><BR>
					<CFOUTPUT><INPUT TYPE="BUTTON" NAME="Remove_All_#currentrow#" VALUE=">>" ONCLICK="Javascript: remove_all('Market_ID_#currentrow#','Service_Market_ID')" STYLE="WIDTH:25px"></CFOUTPUT><BR>
				</TD>
				<!--- <TD WIDTH="10">&nbsp;</TD> --->
			</TR>
			
		</TABLE>
		</CF_openLayer>
		</CFLOOP>
		</TD>
		<TD WIDTH="80">&nbsp;</TD>
		<TD ALIGN="Left" valign="top">
			<DIV STYLE="display:inline;" ID="Div_Service_Market_ID">
			<SELECT NAME="Service_Market_ID"  SIZE="26" MULTIPLE STYLE="WIDTH: 440px;">
				<CFOUTPUT QUERY="MK_Lookup">
					<OPTION VALUE="#MK_Lookup.Service_Market_ID#">#MK_Lookup.Market_Name#<cfif len(trim(MK_Lookup.Position_Label))>[#MK_Lookup.Position_Label#, #MK_Lookup.Market_Number#]</cfif></OPTION>
				</CFOUTPUT>
			</SELECT>
			</DIV>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><BR><CF_button
				button_name		=	""
				button_caption	=	"Assign Market"
				button_action	=	"Validate()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
							>
		</TD>
	</TR>
	</FORM>
</TABLE>

</CFIF>













<!--- <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="100%">	 
	
	<TR BGCOLOR="Navy" HEIGHT="23">
		<TD><FONT COLOR="White" WIDTH="100">&nbsp;&nbsp;<B>Analyst</B></FONT></TD>
		<TD><FONT COLOR="White"><B>Market Assigned</B></FONT></TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
		<TD><FONT COLOR="White"><B>Available Market </B></FONT></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" HEIGHT="20"></TD>
	</TR>
	
	
	
		<CFIF currentrow EQ 1>
			<CFSET Sel_Size =  recordcount Mod 2>
			<CFIF Sel_Size EQ 1>
				<CFSET Sel_Size =  (recordcount / 2) - .5>	
				<CFSET Sel_Size = (Sel_Size * 11) + 5>	
			<CFELSE>
				<CFSET Sel_Size =  (recordcount / 2)>
				<CFSET Sel_Size = (Sel_Size * 11)>
			</CFIF>
			
			<CFIF Sel_Size GT MK_Lookup.recordcount>
				<CFSET Sel_Size = MK_Lookup.recordcount>
			</CFIF>
			<TD WIDTH="300" VALIGN="Top" <CFOUTPUT>ROWSPAN="#recordcount#"</CFOUTPUT>>
				
			</TD>
		</CFIF>
	</TR>
	</CFLOOP>
	
	
</TABLE> --->



<SCRIPT SRC="/Deductions/Assignment/main_container.js"></SCRIPT>

<SCRIPT language="JavaScript">
function Validate()
{	
	var count = <CFOUTPUT>#Get_Analyst.recordcount#</CFOUTPUT>;		
	for (i=1; i<=count;i++)
	{	
		select_all("Market_ID_"+i);
	}
	
	document.Pk_Market.submit()
}

/*
function Validate()
{	alert()
	var count = <CFOUTPUT>#Get_Analyst.recordcount#</CFOUTPUT>;	
	if (document.Pk_Market.Service_Market_ID.options.length == 0)
	{
		for (i=1; i<=count;i++)
		{	
			select_all("Market_ID_"+i);
		}
		
		document.Pk_Market.submit()
	}
	else
	{
		alert("All markets must be assigned to an Analyst.");
	}	
}
*/
</SCRIPT>

<!------ add scroll 1 ----->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
	document.body.onscroll = new Function("settimeoutScroll()");
	var timeout1 = null;
	var sDiv = "Div_Service_Market_ID";
	function settimeoutScroll()
	{
		if(timeout1)
		{
			window.clearTimeout(timeout1);
		}
		timeout1 = window.setTimeout("scroll_div()", 0);
	}
	
	function scroll_div()
	{
		var oDiv = eval("document.all." + sDiv);
		var oCell = getParentObject(oDiv, "td");
		var tdTop = getTotalOffsetProperty(oCell, "body", "offsetTop", 0);
		var thisScroll = document.body.scrollTop;
		var divHeight = oDiv.offsetHeight;
		var divWidth = oDiv.offsetWidth;
		oCell.height = divHeight;
		oCell.width = divWidth;
		var cellHeight = oCell.offsetHeight;
		var nextTop = tdTop + thisScroll;
		if((nextTop + divHeight) > (tdTop + cellHeight))
		{
			nextTop = tdTop + cellHeight - divHeight;
		}
		oDiv.style.left = getTotalOffsetProperty(oDiv, "body", "offsetLeft", 0);
		oDiv.style.top = nextTop;
		oDiv.style.position = "absolute";	
	}
	
	
	
     <!-- 
		function switchLayer(lyrID, title, titleclosed, borderwidth, imageA,imageB, colorA,colorB) 
		{ 
			if (document.all.length) 
			{ 
				// Determine if the layer is currently expanded or collapsed: 
				var tmpStatus; 
				eval("tmpStatus = document.all.lyrGroup_"+ lyrID +".style.display"); 
				// OK, then now expand or collapse it... 
				if (tmpStatus == 'none') 
				{ 
					eval("document.all.lyrGroup_"+ lyrID +".style.display='block';"); 
					eval("document.all.border_"+ lyrID +".style.borderWidth='"+borderwidth+"px';"); 
					eval("document.all.title_"+ lyrID +".innerHTML='"+title+"';"); 
					tmpImage = imageA; 
					tmpColor = colorA; 
					<!------ show ----->
					var divObj = eval("document.all.lyrGroup_"+ lyrID);
					var selObj = divObj.getElementsByTagName("SELECT")[0];
					changeSelectWidth(selObj);
				} 
				else 
				{ 
					eval("document.all.lyrGroup_"+ lyrID +".style.display='none'"); 
					eval("document.all.border_"+ lyrID +".style.borderWidth='0px';"); 
					eval("document.all.title_"+ lyrID +".innerHTML='"+titleclosed+"';"); 
					tmpImage = imageB; 
					tmpColor = colorB; 
					<!------ hide ----->
				} 
				// If an image is used as the click-control, switch it... 
				if ((tmpImage != null) && (imageA != imageB)) 
				{ 
					eval("document.all.image_"+ lyrID +".src='"+tmpImage+"'"); 
				} 
				// If different title-colors are used, switch them... 
				if (tmpColor != '') 
				{ 
					eval("document.all.title_"+ lyrID +".style.color='"+tmpColor+"'"); 
				}
				scroll_div();		
			} 	   
		} 
	  
     //--> 
</SCRIPT>