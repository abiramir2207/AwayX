<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET URL.PageTitle="Payables: Manage GL Code	">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<cfset fore_Color="FFE083">
<CFOUTPUT>

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



<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
function Change_Tab()
	{
		var aObj 	= getParentObject(event.srcElement,"A");
		var oTable_Tab = document.all.Table_Tab;
		var oCells = oTable_Tab.rows[0].cells;
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


<cfset Step_List="Search,Log,Upload,Temp Log"><!--- Activate, --->
<CFPARAM NAME="URL.Show_Tab" DEFAULT="1">

<CFSET i = 1>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="100%" ALIGN="Center" ID="Table_Tab">
	<TR>			
	 	<TD class="headerblank">&nbsp;</TD>		
	 	<cfloop list="#Step_List#" index="thisIndex">
			<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index.cfm?Show_Tab=#i#">			
	 		<cfif Len(Trim(thisIndex)) GT 0>	
	 			<TD width="120" 
			<cfif URL.Show_Tab EQ i>
				class="headerselected" 		
			<cfelse>
				class="headernotselected" 
			</cfif>
		 		align="center" nowrap ID="PL_Type">
				<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="index.cfm?Show_Tab=#i#"><B><nobr>#LCase(thisIndex)#</nobr></B></a>				
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
</CFOUTPUT>

<CFIF URL.Show_Tab EQ 1>
	<CFINCLUDE TEMPLATE="Search_GL_Code.cfm">
<!--- <CFELSEIF URL.Show_Tab EQ 2>
	<CFINCLUDE TEMPLATE="Activate_GL_Code.cfm"> --->
<CFELSEIF URL.Show_Tab EQ 2>
	<CFIF IsDefined("URL.ShowLogDetails")>
		<CFINCLUDE TEMPLATE="GL_Code_Log_Details.cfm">
	<CFELSE>
		<CFINCLUDE TEMPLATE="GL_Code_Log.cfm">
	</CFIF>
<CFELSEIF URL.Show_Tab EQ 3>
	<CFINCLUDE TEMPLATE="Upload_GL_Code.cfm">
<CFELSEIF URL.Show_Tab EQ 4>
	<CFIF Isdefined("URL.ShowLogDetails")>
		<CFINCLUDE TEMPLATE="GL_Code_Log_Details.cfm">
	<CFELSE>
		<CFINCLUDE TEMPLATE="GL_Code_Log.cfm"> 
	</CFIF>
</CFIF>

