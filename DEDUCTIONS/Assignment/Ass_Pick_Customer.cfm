<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">

<CFIF FORM.Form_Submitted EQ 1>
	<cfset useLakebaseFordel_Mk_Assigned = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_assignment")>
	<cfif useLakebaseFordel_Mk_Assigned>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_assignment",
				{ "family_id" = "not.is.null", "deleted" = "eq.0" },
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

		WHERE		Family_ID is Not null
					AND Deleted = 0
	</CFQUERY>
	</cfif>

	<cfset useLakebaseForSet_back = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
	<cfif useLakebaseForSet_back>
		<cftry>
			<cfset application.oLakebase.updateRows("dd_analyst",
				{ "deleted" = "eq.0" },
				{ "ass_customer" = 0 }
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

		SET		Ass_Customer = 0

		WHERE	Deleted = 0
	</CFQUERY>
	</cfif>

	<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.Record_count#">

		<CFIF isdefined("Cust_List_#LoopCount#")>
			<cfset useLakebaseForUp_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
			<cfif useLakebaseForUp_Analyst>
				<cftry>
					<cfset application.oLakebase.updateRows("dd_analyst",
						{ "analyst_user_id" = "eq.#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#", "deleted" = "eq.0" },
						{ "ass_customer" = 1 }
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

				SET		Ass_Customer = 1

				WHERE	Analyst_User_ID	=	'#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#' AND Deleted = 0
			</CFQUERY>
			</cfif>

			<CFLOOP LIST="#Evaluate("FORM.Cust_List_#LoopCount#")#" INDEX="Item">
				<cfset useLakebaseForinsert_data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_assignment")>
				<cfif useLakebaseForinsert_data>
					<cftry>
						<cfset application.oLakebase.insertRow("dd_assignment", {
							"analyst_user_id" = Evaluate("FORM.Analyst_User_ID_#LoopCount#"),
							"family_id" = Item
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
										Family_ID	)

					VALUES			(	'#Evaluate("FORM.Analyst_User_ID_#LoopCount#")#',
										'#Item#'	)
				</CFQUERY>
				</cfif>
			</CFLOOP>
		</CFIF>

	</CFLOOP>
	<cfset useLakebaseForDecide_Location = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
	<cfif useLakebaseForDecide_Location>
		<cftry>
			<cfset Decide_Location = application.oLakebase.toQuery(
				application.oLakebase.selectRows("dd_analyst", {
					"is_supervisor" = "eq.1",
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
		SELECT Top 1 * FROM DD_Analyst WHERE Is_Supervisor = 1 and Deleted=0
	</CFQUERY>
	</cfif>
	<CFIF Decide_Location.recordcount GT 0>
		<CFLOCATION URL="index2.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="index2.cfm?Show_Step=5" ADDTOKEN="No">
	</CFIF>
	<CFLOCATION URL="Index.cfm" ADDTOKEN="No">
<CFELSE>
	<CFQUERY NAME="Cust_Analyst" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Analyst_ID,
					Analyst_User_ID,
					Name_First,
					Name_Last

		FROM 		DD_Analyst

		INNER JOIN 	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID

		WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0
		ORDER BY	Name_First
	</CFQUERY>


	<CFQUERY NAME="Cust_Lookup" DATASOURCE="#Application.Datasource#">
		SELECT 		Family_ID,
					Family_Name,
					Family      <!---32567--->

		FROM 		Distributor_Family

		WHERE 		Deleted=0 AND
					Family_ID Not IN(	SELECT 	Family_ID
										FROM 	DD_Assignment
										WHERE 	Deleted=0 AND
												Family_ID is not null	)
		ORDER BY	Family_Name
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
		<FORM NAME="Pk_Customer" ACTION="Ass_Pick_Customer.cfm" METHOD="Post">
		<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="1">
		<CFOUTPUT><INPUT TYPE="Hidden" NAME="Record_count" VALUE="#Cust_Analyst.Recordcount#"></CFOUTPUT>
		<TR>
			<TD VALIGN="Top" WIDTH="350">
			<CFLOOP QUERY="Cust_Analyst">
			<CFOUTPUT>
				<INPUT TYPE="Hidden" NAME="Analyst_User_ID_#currentrow#" VALUE="#Analyst_User_ID#">
			</CFOUTPUT>

			<CFQUERY NAME="Analyst_Ct" DATASOURCE="#Application.Datasource#">
				SELECT 		DD_Assignment.Family_ID,	Family_Name,	Family     <!---32567--->
				FROM 		DD_Assignment
				INNER JOIN 	Distributor_Family
				ON Distributor_Family.Family_ID=DD_Assignment.Family_ID
				WHERE 		Analyst_User_ID = '#Analyst_User_ID#'
				AND DD_Assignment.Deleted=0
				AND	Distributor_Family.Deleted=0
				ORDER BY Family_Name ASC
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
				Width="300px">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD VALIGN="Top" HEIGHT="80" WIDTH="250"><BR>
						<SELECT <CFOUTPUT>NAME="Cust_List_#Currentrow#"</CFOUTPUT> SIZE="4" STYLE="WIDTH:250px" MULTIPLE>
							<CFOUTPUT QUERY="Analyst_Ct">
								<OPTION VALUE="#Family_ID#">#Analyst_Ct.Family_Name# [#trim(Analyst_Ct.Family)#]</OPTION>
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
			<TD WIDTH="20">&nbsp;</TD>
			<TD VALIGN="Top">
				<DIV STYLE="display:inline;" ID="Div_Customer_ID">
				<SELECT NAME="Cust_ID" MULTIPLE SIZE="26">
					<CFOUTPUT QUERY="Cust_Lookup">
						<OPTION VALUE="#Family_ID#">#Cust_Lookup.Family_Name# [#trim(Cust_Lookup.Family)#]</OPTION>
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
