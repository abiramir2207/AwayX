<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">

<CFIF FORM.Form_Submitted EQ 1>
	
	<CFQUERY NAME="del_Supervisor_Assigned" DATASOURCE="#Application.Datasource#">
		UPDATE 		DD_Analyst 				
		SET			Supervisor_ID = NULL		
		WHERE		Supervisor_ID is Not null 
					AND Deleted = 0
	</CFQUERY>
	
	<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.Record_count#">
	
		<CFIF isdefined("Cust_List_#LoopCount#")>		
			<CFLOOP LIST="#Evaluate("FORM.Cust_List_#LoopCount#")#" INDEX="Item">
				<cfset useLakebaseForUpAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
				<cfif useLakebaseForUpAnalyst>
					<cftry>
						<cfset application.oLakebase.updateRows("dd_analyst",
							{ "analyst_user_id" = "eq.#Item#", "deleted" = "eq.false" },
							{ "supervisor_id" = Evaluate("FORM.Analyst_User_ID_#LoopCount#") }
						)>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForUpAnalyst = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForUpAnalyst>
					<cfset useLakebaseForUp_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForUp_Analyst>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_analyst",
			{
				"analyst_user_id" = "eq.#Item#",
				"deleted" = "eq.0"
			},
			{
				"supervisor_id" = "#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUp_Analyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUp_Analyst>
<CFQUERY NAME="Up_Analyst" DATASOURCE="#Application.Datasource#">
						UPDATE 	DD_Analyst
						SET		Supervisor_ID = '#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#'
						WHERE	Analyst_User_ID	=	'#Item#' AND Deleted = 0
					</CFQUERY>
</cfif>
				</cfif>
			</CFLOOP>
		</CFIF>
		
	</CFLOOP>

	<CFLOCATION URL="Index2.cfm" ADDTOKEN="No">
<CFELSE>
	<CFQUERY NAME="Cust_Analyst" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Analyst_ID,
					Analyst_User_ID,
					Name_First,
					Name_Last 

		FROM 		DD_Analyst 

		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID

		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0 AND Is_Supervisor = 1			
		ORDER BY 	Name_First
	</CFQUERY>
	
	
	<CFQUERY NAME="Cust_Lookup" DATASOURCE="#Application.Datasource#">
		SELECT 		Analyst_User_ID,					
					Name_First,
					Name_Last 

		FROM 		DD_Analyst 

		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID

		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0 AND Is_Supervisor <> 1 AND Supervisor_ID IS NULL	
		ORDER BY 	Name_First
	</CFQUERY>
	
	<SCRIPT SRC="/Deductions/Assignment/main_container.js"></SCRIPT>
	
	<SCRIPT language="JavaScript">
	function Validate()
	{	
		var count = <CFOUTPUT>#Cust_Analyst.recordcount#</CFOUTPUT>;	
		var assigned = 0;
		for (i=1; i<=count;i++)
		{	
			var checkAssign =  eval("document.all.Cust_List_"+i+".options.length");				
			if (assigned == 0)
			{
				if (checkAssign != 0)
				{
					assigned = 1;
				}
			}
			select_all("Cust_List_"+i);
		}
		if (assigned == 1)
		{
			document.Pk_Customer.submit();
		}
		else
		{
			alert("Please assign at least a customer to an Analyst.")
		}		
	}
	</SCRIPT>
	
	
	
	<!--- <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
		<TR>
			<TD><B><FONT COLOR="red">Step 3 of 4</FONT></B></TD>
		</TR>
	</TABLE> --->
	
	<BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="left" >
		<FORM NAME="Pk_Customer" ACTION="Pick_Supervisor_For_Analyst.cfm" METHOD="Post">
		<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="1"> 
		<CFOUTPUT><INPUT TYPE="Hidden" NAME="Record_count" VALUE="#Cust_Analyst.Recordcount#"></CFOUTPUT>	
		<TR>
			<TD VALIGN="Top" WIDTH="300">
			<CFLOOP QUERY="Cust_Analyst">
			<CFOUTPUT>
				<INPUT TYPE="Hidden" NAME="Analyst_User_ID_#currentrow#" VALUE="#Analyst_User_ID#">				
			</CFOUTPUT>		
			
			<CFQUERY NAME="Analyst_Ct" DATASOURCE="#Application.Datasource#">
				SELECT 		DD_Analyst_ID,
							Analyst_User_ID,
							Name_First,
							Name_Last 
		
				FROM 		DD_Analyst 
		
				INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID
		
				WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0 AND Is_Supervisor = 0	AND Supervisor_ID = '#Analyst_User_ID#'
				ORDER BY 	Name_First				
			</CFQUERY>	
			<CF_openLayer
				Border="Yes"
				BorderSize="1"  
				BorderColor="orange"  
				Image="/images/plus2.gif"
				ImageOpen="/images/minus2.gif"
				Title="<CFOUTPUT>#Name_First# #Name_Last#</CFOUTPUT>:"  
				TitleClosed="<CFOUTPUT>#Name_First# #Name_Last#</CFOUTPUT>:"  
				TitleTooltip="Click to Show/Hide details"  
				TitleFont="font"  
				TitleColor="Blue"  
				TitleSize="9"  
				IsClosed="Yes"  
				Width="100%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
				<TR>					
					<TD VALIGN="Top" HEIGHT="80" WIDTH="250"><BR>
						<SELECT <CFOUTPUT>NAME="Cust_List_#Currentrow#"</CFOUTPUT> SIZE="4" STYLE="WIDTH:250px" MULTIPLE>
							<CFOUTPUT QUERY="Analyst_Ct">
								<OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last #</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<TD WIDTH="20">&nbsp;</TD>
					<TD VALIGN="Top" WIDTH="27"><BR>
						<CFOUTPUT><INPUT TYPE="BUTTON" NAME="Add_Cust_#currentrow#" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('Cust_ID','Cust_List_#Currentrow#',1)" STYLE="WIDTH:25px"></CFOUTPUT><BR>
						<CFOUTPUT><INPUT TYPE="BUTTON" NAME="Remove_Cust_#currentrow#" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Cust_List_#Currentrow#','Cust_ID', 2)" STYLE="WIDTH:25px"></CFOUTPUT><BR>
						<CFOUTPUT><INPUT TYPE="BUTTON" NAME="Remove_All_#currentrow#" VALUE=">>" ONCLICK="Javascript: remove_all('Cust_List_#Currentrow#','Cust_ID')" STYLE="WIDTH:25px"></CFOUTPUT><BR>
					</TD>
					<!--- <TD WIDTH="20">&nbsp;</TD> --->
				</TR>
			</TABLE>
			</CF_openLayer>
			</CFLOOP>
			</TD>
			<TD WIDTH="50">&nbsp;</TD>
			<TD VALIGN="Top">
				<DIV STYLE="display:inline;" ID="Div_Customer_ID">
				<SELECT NAME="Cust_ID" MULTIPLE SIZE="22" STYLE="WIDTH:200px">
					<CFOUTPUT QUERY="Cust_Lookup">
						<OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION>
					</CFOUTPUT>
				</SELECT>
				</DIV>
			</TD>
		</TR>	
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
				<CFIF Cust_Analyst.recordcount GT 0>
					<CF_button
					button_name	=	""
					button_caption	=	"save data"
					button_action	=	"Validate()"
					button_type	=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								>
				</CFIF>
			</TD>
		</TR>
		</FORM>	
	</TABLE>
	
	</CFIF> 
	
	
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
	document.body.onscroll = new Function("settimeoutScroll()");
	var timeout1 = null;
	var sDiv = "Div_Customer_ID";
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
	
	
	
	

