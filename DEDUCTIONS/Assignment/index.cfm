<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset fore_Color="FFE083">
<cfoutput>

<style>
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Black;
		cursor:				pointer;
		BACKGROUND-COLOR: 	FFCE84;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				pointer;		
		BACKGROUND-COLOR: 	WhiteSmoke;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	
	
	
	TD.headernotselected
  {
   background-color 	: dddddd;
   border-bottom		: solid 1px black;
   cursor				: pointer;	
   color				: Black;   
  }
  TD.headerselected
  {   
   border-left			: solid 1px black;
   border-top			: solid 1px black;
   border-right			: solid 1px black;
   background-color 	: #fore_Color#;
   cursor				: pointer;	
   color				: White;
   TEXT-TRANSFORM		: uppercase;
  }
  TD.headerblank
  {
   border-bottom		: solid 1px black;
  }
  TD.headerspacer
  {
   border-bottom		: solid 1px black;
  }
  TD.headerlastone
  {
   border-left			: solid 1px black;
  }

</style>
<CFOUTPUT></CFOUTPUT>
<cfset useLakebaseForCheckAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForCheckAnalyst>
	<cftry>
		<cfset CheckAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", { "deleted" = "eq.false" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCheckAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckAnalyst>
	<CFQUERY NAME="CheckAnalyst" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Analyst WHERE Deleted=0
	</CFQUERY>
</cfif>

<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
	<cfset Step_List="View,Analyst,Default">
<CFELSE>
	<CFIF appSettings.getDDAssignmentBasedOnShrShipto()>
		<cfset Step_List="View,Analyst,Market,Customer,Supervisor,Default,Assign Supervisor">
	<CFELSE>
		<cfset Step_List="View,Analyst,Market,Family,Supervisor,Default,Assign Supervisor">
	</CFIF>
</CFIF>
<CFPARAM NAME="URL.Show_Step" DEFAULT="1">

<CFSET i = 1>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="100%" ALIGN="Center" ID="Table_Assign">
	<TR>			
	 	<TD class="headerblank">&nbsp;</TD>		
	 	<cfloop list="#Step_List#" index="thisIndex">
			<CFIF CheckAnalyst.Recordcount GT 0>
			<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index2.cfm?Show_Step=#i#">
			<CFELSE>
			<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index2.cfm?Show_Step=2">
			</CFIF>
	 		<cfif Len(Trim(thisIndex)) GT 0>	
	 			<TD width="120" 
			<cfif URL.Show_Step EQ i>
				class="headerselected" 		
			<cfelse>
				class="headernotselected" 
			</cfif>
		 		align="center" nowrap ID="PL_Type">
				<CFIF CheckAnalyst.Recordcount GT 0>
				<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index2.cfm?Show_Step=#i#"><B><nobr>#LCase(thisIndex)#</nobr></B></a>
				<CFELSE>
				<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index2.cfm?Show_Step=2"><B><nobr>#LCase(thisIndex)#</nobr></B></a>
				</CFIF>
				</TD></a>
		 		<cfif (i-1) lt Len(Step_List)>
					<td class="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></td>
				</cfif>
			</cfif>
			<CFSET i = i + 1>
		</cfloop>
	<td class="headerspacer" width="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></td>

	</TR>
</TABLE>
</cfoutput> 

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
function Change_Tab()
	{
		var aObj 	= getParentObject(event.srcElement,"A");
		var oTable_Assign = document.all.Table_Assign;
		var oCells = oTable_Assign.rows[0].cells;
		var i;
		var thisCell = getParentObject(event.srcElement,"TD");
		if(oCells)
		{
			for(i=0;i<oCells.length;i++)
			{
				if(oCells[i] == thisCell)
				{					
					oCells[i].className = "headerselected";
					//oCells[i].style.color = "white";
				}
				else
				{
					if(oCells[i].id)
					{
						oCells[i].className = "headernotselected";
					}
				}
			}
		}
		
		SRCURL = aObj.href;	
		//Sort_It(document.all.Price_List_Table_Headers.rows[0].cells[0]);	
		//event.cancelBubble = true;
	}

</SCRIPT>