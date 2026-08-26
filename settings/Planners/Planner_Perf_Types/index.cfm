<!----------------------------------------------------------------------------------
Name         :	index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/29/2016
Created By   : 	Anand Rao
Description  :
---------------------------------------------------------------------------------->
<cf_layout-bare jQueryUI='1.11.4' page_title="PlANNER: Performance Types">

<style>
	table.MAINTABLE tr { height:27px; line-height:27px; }
	table.MAINTABLE td { border-bottom: 1px dotted #CCC; }
	table.MAINTABLE td span { position: absolute; margin-left: -.5em; margin-top:2px; }
	.blue { color: blue !important; }
	p > a {
		margin-right: 25px;
	}
    span.label { position: relative; top: -3px; }
</style>

<cfscript>
	param name="url.iTab"			default="Active";
	param name="FORM.display_type"	default="Active";
	param name="form.display" 		default="active";
	param name="form.command" 		default="";

	plannerSettingsManagerCFC = CreateObject("component", "mvc.Models.Planner.PlannerSettingsManager");
	pagetitle = "<cfoutput>#Application.PlannerLabel#</cfoutput>: Performance Types";

	include_files = [ 	"/common_files/tabnav.css"
						,"/common_files/datatable.css"
						,"/Script/javascript/dom_common.js"
						,"/settings/planners/planners.js"
						,"/billbacks/settings/jscolor.js"
						,"/Script/javascript/dom_common.js"
						,"/settings/planners/planners.js"
						// ,"/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css"
						];
</cfscript>
<cfinclude template="/settings/settings_title.cfm">
<cf_include files=#arrayToList(include_files)#>

<!-------------------->
<!---  NAVIGATION  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<div class="nav">
    <ul class="nav">
        <li <cfif URL.itab EQ "Active">class="active"</cfif>>
            <a class="topnav" href="index.cfm?itab=active">active</a>
        </li>
        <li <cfif URL.itab EQ "inActive">class="active"</cfif>>
            <a class="topnav" href="index.cfm?itab=inactive">inactive</a>
        </li>
        <li <cfif URL.itab EQ "Add">class="active"</cfif>>
            <a class="topnav" href="index.cfm?itab=add">add new</a>
        </li>
		<cfif (URL.iTab EQ "EDIT")>
	        <li class="active">
	            <a class="topnav" href="index.cfm?itab=edit">edit</a>
	        </li>
	    </cfif>
    </ul>
</div>
<div style="clear:both"></div>

<FORM ACTION="Planner_Perf_Types_Action.cfm" METHOD="post" NAME="frmPlannerPerfTypes">

<script language="javascript">
	function RGBtoHex(R)
	{
		if (R ==null) return "000000";
		if (R=="#000") return "000000";
		if (R=="#fff") return "FFFFFF";
	}

	function RGBtoHex_main(R,G,B) {return toHex(R)+toHex(G)+toHex(B)}

	function toHex(N)
	{
		if (N==null) return "00";
	 	N=parseInt(N); if (N==0 || isNaN(N)) return "00";
	 	N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
	 	return "0123456789ABCDEF".charAt((N-N%16)/16)
		  + "0123456789ABCDEF".charAt(N%16);
	}

	function fnSetColorVals(choice,colorChoice)
	{
		curObject = eval("document.all." + choice);
		colorSet = eval("document.getElementById('"+ colorChoice + "').value");
		curObject.value = colorSet;
	}

	function selectAll(thisObj)
	{
		var chObjs = eval("document.all.CID");
		var bCheck = thisObj.checked;
		var i;
		if(chObjs && thisObj.name == 'CheckAll')
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					chObjs[i].checked = bCheck;
				}
			}
			else
			{
				chObjs.checked = bCheck;
			}
		}else{
				var chObjs = document.querySelectorAll("input[id='Default_Use']");
				for(var i=0; i< chObjs.length; i++){
					chObjs[i].checked=bCheck;
				}
		}
	}
</script>

<!----------------->
<!---  ACTIONS  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<p>
	<cfif URL.itab EQ "Active">
		<a href="##" onclick="submitPerfForm('save')"> #application.util.string.linkFormat("save")# </a>
		<a href="##" onclick="deactivateSelPerfTypes()"> #application.util.string.linkFormat("deactivate selected")# </a>

	<cfelseif URL.itab EQ "inActive">
		<a href="##" onclick="activateSelPerfTypes()"> #application.util.string.linkFormat("activate selected")# </a>
	</cfif>
</p>
</cfoutput>

<!---------------->
<!---  ACTIVE  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif URL.itab EQ "Active">
	<cfset perfTypesActive = plannerSettingsManagerCFC.getPerfTypeInfo(type="Active") />
	<cfset form.display = "" />

	<p>Click & drag rows using the mouse to place them in a desired priority sequence. The top row has the highest priority.</p>
	<table width="70%" border="0" cellpadding="1" cellspacing="0" class="MAINTABLE">
		<!---- HEAD ----->
		<tr id="HEADER" bgcolor="#FFCE84">
			<td width="15">
				<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);" style="margin-left: 10px;">
			</td>
			<td nowrap>
				<b>Priority</b>
			</td>
			<td nowrap>
				<B>Description</B>
			</td>
			<td nowrap>
				<B>Color</B>
			</td>
			<td nowrap>
				<B>Every Day Low Price</B>
			</td>
			<td>
				<B>Slotting</B>
			</td>
			<td>
				<B>Accrual</B>
			</td>

			<td>
				<B>Duration [weeks]</B>
			</td>
			<td>
				<B>Days < start [days]</B>
			</td>
			<td>
				<B>Days < end [days]</B>
			</td>
			<td align="left">
				<INPUT TYPE="checkbox" NAME="Default" onClick="javaScript: selectAll(this);" style="margin-left: 10px;"> Default
			</td>
		</tr>
		<cfoutput>
			<input type="hidden" name="sortOrders" id="sortOrders" value="#ValueList(perfTypesActive.Sort_Order)#">
		</cfoutput>

		<cfoutput query="perfTypesActive">
			<tr class="ui-state-default">
				<td width="15"><span class="ui-icon ui-icon-arrowthick-2-n-s"></span> &nbsp;
					<input type="checkbox" name="CID" value="#perfTypesActive.Planner_Perf_Types_ID#">
				</td>
				<td>
					#Sort_Order#
					<input type="hidden" name="priority_#perfTypesActive.Planner_Perf_Types_ID#" value="#Sort_Order#" class="order">
				</td>
				<td>
					<a href="index.cfm?itab=Edit&perfID=#perfTypesActive.Planner_Perf_Types_ID#" class="blue">#perfTypesActive.Description#</a>
				</td>
			 	<td style="color:#application.util.string.foregroundColor( perfTypesActive.color )#">
					<input class="color {valueElement:'clrSel_#Planner_Perf_Types_ID#',styleElement:'clrSel_#Planner_Perf_Types_ID#'}"
						id="clrSel_#Planner_Perf_Types_ID#" onchange="javascript:fnSetColorVals('clrSelected_#Planner_Perf_Types_ID#','clrSel_#Planner_Perf_Types_ID#');"
						title="Click to pick the color" style="background:###color#;cursor:pointer;" value="#Color#">
					<input type="hidden" name="clrSelected_#Planner_Perf_Types_ID#" value="#color#"/>
				</td>
				<td>
					<input name="Everyday_Price" type="radio" value="#Planner_Perf_Types_ID#" <cfif perfTypesActive.Everyday_Price eq 1>checked</cfif> />
				</td>
				<td>
					<input name="slotting_#perfTypesActive.Planner_Perf_Types_ID#" type="checkbox" <cfif perfTypesActive.Slotting eq 1>checked</cfif>>
				</td>
				<td>
					<input name="Accrual" type="radio" value="#Planner_Perf_Types_ID#" <cfif perfTypesActive.Accrual eq 1>checked</cfif> />
				</td>

				<td>
					<input name="Default_Duration_#perfTypesActive.Planner_Perf_Types_ID#" type="textbox" value="#Default_Duration#" onKeyUp="clenseText(this, '0123456789')"; size="5"/>
				</td>
				<td>
					<input name="Default_Delivery_Days_Start_#perfTypesActive.Planner_Perf_Types_ID#" type="textbox" value="#Default_Delivery_Days_Start#" onKeyUp="clenseText(this, '0123456789')"; size="5"/>
				</td>
				<td>
					<input name="Default_Delivery_Days_End_#perfTypesActive.Planner_Perf_Types_ID#" type="textbox" value="#Default_Delivery_Days_End#" onKeyUp="clenseText(this, '0123456789')"; size="5"/>
					<input name="allow_duplicate_programs_#perfTypesActive.Planner_Perf_Types_ID#" type="hidden" value="#perfTypesActive.Allow_Duplicate_Programs#"/>
				</td>
				<td>
					&nbsp;&nbsp;<input type="checkbox" name="Default_Use_#perfTypesActive.Planner_Perf_Types_ID#" value="1"  <cfif perfTypesActive.Default_Use eq '1'>checked</cfif> id="Default_Use">
				</td>
			</tr>
		</cfoutput>
	</table>
	<cfoutput>
	<p>
			<a href="##" onclick="submitPerfForm('save')"> #application.util.string.linkFormat("save")# </a>
	</p>
	</cfoutput>

<!------------------>
<!---  INACTIVE  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfelseif URL.itab EQ "inActive">
	<cfset perfTypesinActive = plannerSettingsManagerCFC.getPerfTypeInfo(type="inActive") />

	<table width="50%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
		<!---- HEAD ----->
		<tr ID="HEADER" BGCOLOR="#FFCE84">
			 <td width="15">
				<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
			</td>
			<td STYLE="font-size:11px;" nowrap>
				<b>Priority</b>
			</td>
			<td STYLE="font-size:11px;" nowrap>
				<B>Description</B>
			</td>
			<td STYLE="font-size:11px;" nowrap>
				<B>Color</B>
			</td>
		</tr>

		<cfoutput query="perfTypesinActive">

		<tr <cfif CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
			 <td width="15"><INPUT TYPE="checkbox" NAME="CID" value="#Planner_Perf_Types_ID#"></td>
			<td>
				#Sort_Order#
			</td>

			<td class="blue">
				#Description#
			</td>
		 	<td>
				 #color#
			</td>
		</tr>
		</cfoutput>
	</table>


<!------------->
<!---  ADD  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfelseif URL.itab EQ "Add">
	<cfset getMaxSortOrder = plannerSettingsManagerCFC.getMaxSortOrder() />
	<cfif getMaxSortOrder.Max_Sort_Order EQ "">
		<cfset curPriorityVal = 1>
	<cfelse>
		<cfset curPriorityVal = getMaxSortOrder.Max_Sort_Order + 1 />
	</cfif>
	<cfoutput>
	<table width="40%" BORDER="0" CELLPADDING="3" CELLSPACING="2" >
		<tr bgcolor="CCFFCC">
			<td> <strong>Priority:</strong></td><td>#curPriorityVal#</td>
		</tr>
		<tr bgcolor="FFFFFF">
			<td><strong>Description:</strong></td>
			<td><input type="text" name="txtDescription"></td>
		</tr>
		<tr bgcolor="CCFFCC">
			<td><strong>Color: </strong></td>
			<td>
				<cfset color="FFFFFF" />
				<input class="color {valueElement:'clrSel',styleElement:'clrSel'}" id="clrSel"
					onchange="javascript:fnSetColorVals('clrSelected','clrSel');"
					title="Click to pick the color" style="background:###color#;cursor:pointer;" value="#Color#">
				<input type="hidden" name="clrSelected" value="#Color#"/>
			</td>
		</tr>
		<tr bgcolor="FFFFFF">
			<td><b>Slotting</b></td>
			<td><input type="checkbox" name="slotting"></td>
		</tr>
		<tr bgcolor="CCFFCC">
            <td><b>Allow Duplicate #Application.PlannerPrgLabel#?</b></td>
			<td><input type="checkbox" name="allow_duplicate_programs"><span class="label">Skip checking duplicate #Application.PlannerPrgLabel#</span></td>
		</tr>

		<tr bgcolor="FFFFFF">
			<td><b>Duration [weeks]</b></td>
			<td><input type="textbox" name="Default_Duration" value=""></td>
		</tr>
		<tr bgcolor="CCFFCC">
			<td><b>Days < start [days]</b></td>
			<td><input type="textbox" name="Default_Delivery_Days_Start" value=""></td>
		</tr>
		<tr bgcolor="FFFFFF">
			<td><b>Days < end [days]</b></td>
			<td><input type="textbox" name="Default_Delivery_Days_End" value=""></td>
		</tr>
		<tr bgcolor="CCFFCC">
			<td><b>Use Default</b></td>
			<td><input type="checkbox" name="Default_Use"></td>
		</tr>
	</table>

	<input type="hidden" name = "curSortOrder" value = "#curPriorityVal#" />
	<p>
		<a href="##" onclick="submitPerfForm('add')"> #application.util.string.linkFormat("save")# </a>
	</p>
	</cfoutput>

<!-------------->
<!---  EDIT  --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfelseif URL.itab EQ "Edit">
	<cfscript>
		getMaxSortOrder = plannerSettingsManagerCFC.getMaxSortOrder();
		getPerfTypeInfo = plannerSettingsManagerCFC.getPerfTypeInfo(type='Active',perf_id=URL.perfID);
		curPriorityVal = getMaxSortOrder.Max_Sort_Order + 1;
	</cfscript>
	<cfoutput>
	<table width="40%" BORDER="0" CELLPADDING="3" CELLSPACING="2" >
		<tr bgcolor="CCFFCC">
			<td> <strong>Priority:</strong></td><td><input type="text" name = "curSortOrder" value="#getPerfTypeInfo.Sort_Order#"></td>
		</tr>
		<tr bgcolor="FFFFFF">
			<td><strong>Description:</strong></td>
			<td><input type="text" name="txtDescription" value="#getPerfTypeInfo.Description#"></td>
		</tr>
		<tr bgcolor="CCFFCC">
			<td><strong>Color: </strong></td>
			<td>
				<cfset color="FFFFFF" />
				<input class="color {valueElement:'clrSel',styleElement:'clrSel'}" id="clrSel"
					onchange="javascript:fnSetColorVals('clrSelected','clrSel');" title="Click to pick the color"
					style="color:#application.util.string.foregroundColor( getPerfTypeInfo.color )#;background:###color#;cursor:pointer;"
					value="#getPerfTypeInfo.Color#">
				<input type="hidden" name="clrSelected" value="#getPerfTypeInfo.Color#"/>
			</td>
		</tr>
		<tr bgcolor="FFFFFF">
			<td><b>Slotting:</b></td>
			<td><input type="checkbox" name="slotting" <cfif getPerfTypeInfo.Slotting eq '1'>checked</cfif>></td>
		</tr>
		<tr bgcolor="CCFFCC">
            <td><b>Allow Duplicate Programs?</b></td>
            <td>
                <input type="checkbox" id="allow_duplicate_programs" name="allow_duplicate_programs" <cfif getPerfTypeInfo.allow_duplicate_programs eq '1'>checked</cfif>>
                <label for="allow_duplicate_programs">
                    <span class="label">Skip checking duplicate programs</span>
                </label>
            </td>
		</tr>

		<tr bgcolor="FFFFFF">
			<td><b>Duration [weeks]</b></td>
			<td><input type="textbox" name="Default_Duration" value="#getPerfTypeInfo.Default_Duration#"></td>
		</tr>
		<tr bgcolor="CCFFCC">
			<td><b>Days < start [days]</b></td>
			<td><input type="textbox" name="Default_Delivery_Days_Start" value="#getPerfTypeInfo.Default_Delivery_Days_Start#"></td>
		</tr>
		<tr bgcolor="FFFFFF">
			<td><b>Days < end [days]</b></td>
			<td><input type="textbox" name="Default_Delivery_Days_End" value="#getPerfTypeInfo.Default_Delivery_Days_End#"></td>
		</tr>
		<tr bgcolor="CCFFCC">
			<td><b>Use Default</b></td>
			<td><input type="checkbox" name="Default_Use" value="1" <cfif getPerfTypeInfo.Default_Use eq '1'>checked</cfif>></td>
		</tr>
	</table>
	<input type="hidden" name="Planner_Perf_Types_Id" value = "#getPerfTypeInfo.Planner_Perf_Types_ID#" />
	<p>
		<a href="##" onclick="submitPerfForm('edit')"> #application.util.string.linkFormat("save")# </a>
	</p>
	</cfoutput>
</cfif>

<cfoutput>
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
</cfoutput>
</form>

<script>
	$("table.MAINTABLE tbody").sortable({ axis: 'y' });
</script>
</cf_layout-bare>
