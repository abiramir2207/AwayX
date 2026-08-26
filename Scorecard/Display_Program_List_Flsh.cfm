
<!---get the search params in a struct...keep it in the include since it reads URL--->
<cfinclude template="ScoreCardStructParams.cfm">
<!---<cfset selectedStatus = stSearch.SCORECARDSTATUS & ":" & stSearch.AGREESTATUSID>--->
<cfset thisStatIdAgreeId = stSearch.scorecardStatus & ":" & stSearch.agreeStatusId>
<!---set some defaults an create the gateway object for remote calls--->
<cfset gateway = "http://#cgi.HTTP_HOST#/flashservices/gateway/"/>
<cfset servicePath = "Scorecard.Services.facade"/>
<cfset prgScr = createObject("component", servicePath)/>
<!---make the call for initial datagrid load--->
<cfinvoke component="#servicePath#" method="getProgramScore" returnvariable="qPrograms">
	<cfinvokeargument name="searchArg" value="#stSearch#">
</cfinvoke>

<!---get the data for the status select box--->
<cfset qprogramStatus = prgScr.getProgramStatus() />

<!---get the data for the favorites select box--->
<cfset qGetFavorites = prgScr.getFavorites(request.AccessStructure.User_ID) />


<!---Styles and Values used for cfform ans .as files--->
<cfsavecontent variable="actionClose">
	if(dynamicPanel.height != 0)
	{
		var obj = {b:dynamicPanel.height, c:0 - dynamicPanel.height,  d:400, t:0,  panel:dynamicPanel};
		_global.resizePanel(obj);
		_global.close = true;
	}
</cfsavecontent>
<cfsavecontent variable="actionOpen">
	switch(arguments[0].target)
	{
		case preferences: dynamicPanel.selectedIndex = 0; break;
		case languagesBtn: dynamicPanel.selectedIndex = 1; break;
		case about: dynamicPanel.selectedIndex = 2; break;
		case feedBackbtn: dynamicPanel.selectedIndex = 3; break;
	}
	if(dynamicPanel.height != ProgramScoreCard.heightDynamicPanel)
	{
		var obj = {b:dynamicPanel.height, c:ProgramScoreCard.heightDynamicPanel - dynamicPanel.height, d:500, t:0, panel:dynamicPanel};
		ProgramScoreCard.heightPreview = (Stage.height - _global.centerHeight -ProgramScoreCard.heightDynamicPanel)/7*3;
		ProgramScoreCard.heightPost = (Stage.height - _global.centerHeight -ProgramScoreCard.heightDynamicPanel)/7*4;
		_global.resizePanel(obj);
		_global.close = false;
	}
</cfsavecontent>
<cfsavecontent variable="onLoad">
	if(_global.loaded == undefined)
	{
	ProgramScoreCard.loadingDisplay = false;
	_root.ProgramScoreCard.pageDisplay = "999";
	_global.loaded = true;
	<cfoutput>
		_global.gatewayUrl = "#gateway#";
		_global.servicePath = "#servicePath#";
		_global.thisHost = "#CGI.HTTP_HOST#";
		<!---load the structure used to pass to the program search component. switches, profile id etc don't change--->
		_global.searchArgs = Array();
		<cfloop collection="#session.searchArg#" item="i">
			_global.searchArgs["#i#"] = "#structfind(session.searchArg, i)#";
		</cfloop>
		<!---load the request scope.  Remote cfc's do not invoke onRequest() method.  need to store it for remote calls--->
		_global.requestArgs = Array();
		_global.accessStructure = Array();
		<cfloop collection="#request.accessstructure#" item="i">
				_global.accessStructure["#i#"] = "#structfind(request.accessstructure, i)#";
		</cfloop>
	</cfoutput>
	display.html = true;
	<!---Set the record count for the initial load--->
	statusDisplay.html = true;
	statusDisplay.text = '<font color="black" style="text-align:right;"><b>&nbsp;&nbsp; <cfoutput>#qPrograms.recordcount#</cfoutput> &nbsp;Programs</b></font>';
	<!---Drag and drop functions--->
	Programs.dragEnabled=true;
	favorites.dragEnabled=true;
	Programs.multipleSelection=true;
	favorites.addEventListener('dragEnter', doDragEnter);
	favorites.addEventListener('dragDrop', doDragDropDG);
	favorites.addEventListener('dragOver', doDragOver);
	favorites.addEventListener('dragExit', doDragExit);
	<!---initTag();---><!---init the datasort--->
	   <!---  Programs.filterFunction=processFilter; --->
	}
</cfsavecontent>
<cfsavecontent variable="buttonStyle">
   corner-radius: 2;
    borderThickness: 0;
   fill-colors: #B4E055, #9FD32E;
   color: #ffffff;
</cfsavecontent>
<cfsavecontent variable="checkStyle">
	border-color: #66cc66;
	fill-colors: #FFCC00, #FFCC00
</cfsavecontent>
<cfsavecontent variable="panelStyle">
	panelBorderStyle:'roundCorners'; 
	themeColor:#FE7E00; 
	headerColors:#F2CB2A, #FFE57A;
	backgroundColor:#FFE57A;
	marginLeft: 0;
</cfsavecontent>
<cfsavecontent variable="contentPanelStyle">
	panelBorderStyle:'roundCorners';
	backgroundColor:#EFF7DF;
	headerColors:#CBEC84, #B0D660;
</cfsavecontent>

<table width="975" height="500" border="0" cellspacing="0" cellpadding="0" align="left">
  <tr>
    <td><!---<cfoutput>#qPrograms.recordcount#</cfoutput>--->
		<cfform name="ProgramScoreCard" format="flash" timeout="0"  width="100%" height="100%" skin="halogreen" preloader="true" onload="#onLoad#"> <!---onload="#onLoad#" style="marginTop:15; themeColor:##66cc00;"--->
			<cfformitem type="script">
				#include "filter.as"
				#include "getData.as"
				#include "dragEvents.as"
				<!---#include "DateSort.as"--->
				<!---#include "C:\Inetpub\wwwroot\AwayX\Scorecard\global.as"--->
			</cfformitem>
			<cfformgroup type="hbox" >
				<cfformgroup type="vbox" width="150" height="{Stage.height - 20}">
					<cfformgroup type="accordion" id="dynamicPanel" height="{Stage.height - 220}" style="#panelStyle#">
						<cfformgroup type="page" label="Status Filter" width="150">
							<!---<cfformgroup type="panel" label="Program Status Filter" style="#panelStyle#" >--->
								<cfselect tabindex="7" name="programStatus" query="qprogramStatus" height="{Stage.height - 300}" width="110" display="Contract_Status_Type_Desc" value="statIDagreeID" size="35" onchange="getData()" selected="#thisStatIdAgreeId#"/><!---getByStatus({statusId:programStatus.selectedItem.data});_global.setSelected(categories);--->		
							<!---</cfformgroup>--->
						</cfformgroup><!---End Page--->
						<cfformgroup type="page" label="Hot List" width="150">
							<!---<cfformgroup type="panel" label="Mass Approve" style="#panelStyle#">--->
								<!---<cfformitem type="text" height="25" style="marginLeft:10">Programs to Approve</cfformitem>--->
								<cfselect tabindex="8" name="favorites" height="{Stage.height - 345}" appendkey="Yes" insert="Yes" size="20" multiple="no" query="qGetFavorites" value="program_id" display="program_number" />
								<cfformgroup type="vertical">
									<cfinput type="button" name="remvFavorites" value="Remove" style="border-thickness:0; fill-colors:##F2CB2A, ##FF9A09; corner-radius: 2;" onClick="removeFavorites(favorites);" tooltip="Remove this program from Your Hot List"/>
									<cfinput type="button" name="gotoFavorite" value="Go" style="border-thickness:0; fill-colors:##F2CB2A, ##FF9A09; corner-radius: 2;" onClick="goToURL(favorites.selectedItem.data);" tooltip="Go View or Edit this Program"/>
									<!--- <cfinput type="button" name="savFavorites" value="Save" style="border-thickness:0; fill-colors:##F2CB2A, ##FF9A09; corner-radius: 2;" onClick="saveFavorites(favorites);"/> --->
								</cfformgroup>
							<!---</cfformgroup>---><!--- End current list --->
						</cfformgroup> <!---End Page--->
					</cfformgroup><!--- End tabNavigator --->
				</cfformgroup><!--- End vBox --->
				<cfformgroup type="vbox" >
					<cfformgroup type="panel" style="#contentPanelStyle# verticalGap:0;" label="Program ScoreCard Viewer" width="800"> 
						<cfformgroup type="hbox" style="verticalGap:4">
							<cfformgroup type="horizontal" style="marginTop:5; indicatorGap:1;" height="30">
										<cfinput type="text" name="filterInput" tabindex="1" label="Filter by:" onchange="applyFilter()" size="10" />
										<cfformitem type="text" width="20">in:</cfformitem>
										<cfinput type="checkBox" name="filterNumber" checked="true" label="Number" onClick="applyFilter()" style="#checkStyle#" tabindex="2" tooltip="Search Contract Number" />
										<cfinput type="checkBox" name="filterTitle" checked="true" label="Title" onClick="applyFilter()" style="#checkStyle#" tabindex="3" tooltip="Search Contract Title" />
										<cfinput type="checkBox" name="filterOper" checked="true" label="#application.returned_customer_setting.operator_label_singular#" onClick="applyFilter()" style="#checkStyle#" tabindex="4" tooltip="Search #application.returned_customer_setting.operator_label_singular# Name and Number" />
										<cfinput type="checkBox" name="filterDist" checked="true" label="#application.returned_customer_setting.distributor_label_singular#" onClick="applyFilter()" style="#checkStyle#" tabindex="5" tooltip="Search #application.returned_customer_setting.distributor_label_singular# Name and Number" />
										<cfinput type="checkBox" name="filterTemplate" checked="true" label="Type"	onClick="applyFilter()" style="#checkStyle#" tabindex="6" tooltip="Search Program Template Type" />
							<cfformgroup type="horizontal" style="marginRight:5; horizontalGap:0;" width="230">
										<cfformitem type="html" width="100" height="20" visible="{ProgramScoreCard.loadingDisplay}"><img src="loader.swf" hspace="0" vspace="0" width="100" height="14" align="left"></cfformitem>
										<cfinput width="115" type="text" name="statusDisplay" disabled="true" style="borderStyle:none; disabledColor:##444444;backgroundColor:##EFF7DF;"/><!---backgroundColor:##D1E7A2;--->
										<!---<cfformitem type="html" bind="{ProgramScoreCard.pageDisplay}"></cfformitem>--->		
							</cfformgroup>
							</cfformgroup>
							<cfformgroup type="hbox" style="themeColor:##9AC6FF;" >
									<cfgrid name="Programs" query="qPrograms" height="275" rowheight="20" rowheaders="no" tooltip="" onchange="getProgram()" >
										<cfgridcolumn display="no" name="Contract_Status_Type_IDX" header="" width="25" />
										<cfgridcolumn name="Contract_Number" header="Number" width="90" />
										<cfgridcolumn name="Created_Type" header="Program Type" width="200" />
										<cfgridcolumn name="Contract_Title" header="Title" width="250"/>
										<!---<cfgridcolumn display="no" name="OperatorID" header="#application.returned_customer_setting.operator_label_singular# ##" width="75"  />
										<cfgridcolumn display="no" name="ship_to" header="#application.returned_customer_setting.distributor_label_singular# ##" width="75"  />
--->										<!---<cfgridcolumn name="Contract_Start_Date" mask="MMM DD, YYYY" type="date" header="Start" width="90" />
										<cfgridcolumn name="Contract_End_Date" mask="MMM DD, YYYY" type="date" header="End" width="90"  />--->
									</cfgrid>
							</cfformgroup><!--- End hBox--->
						</cfformgroup><!--- End hBox main--->
					</cfformgroup><!---End Panel Program ScoreCard Viewer--->
					<cfformgroup type="panel" label="Preview" style="#contentPanelStyle# verticalGap:0;" width="800" height="125"><!---type="horizontal" style="#contentPanelStyle# verticalGap:0;marginRight:-10;" --->
						<cfformgroup type="horizontal" style="marginTop:0; indicatorGap:1;">
							<cfinput type="button" name="gotoPreview" value="Go" style="border-thickness:0; fill-colors:##F2CB2A, ##FF9A09; corner-radius: 2;" onClick="goToURL(Programs.selectedItem.Contract_Main_ID);" tooltip="Go View or Edit this Program">
							<cftextarea name="display" height="75"></cftextarea>	 <!---height="{ProgramScoreCard.heightPreview}"--->
						</cfformgroup>
					</cfformgroup>
				</cfformgroup><!--- End vBox --->
			</cfformgroup> <!---end hbox--->
					
		</cfform>
	</td>
  </tr>
</table>

<!---  <cfdump var="#ProgramScoreCard#">  --->

