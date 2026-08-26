<!--- 
FILE: 		BA Application - VolumeApplicator Component	
FILENAME:   VolumeApplicator.cfc											
CREATED:  	**/**/200* - ?
EDITED:   	11/20/2008 - Brad Lee MMCP/ACI [D17577 - line 2262]

FUNCTIONALITY: 
- Applies Volume... --->

<!--- COLDFUSION COMPONENT: VolumeApplicator
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
components.volume.VolumeApplicator
This component will carry out all methods for the volume applicator
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfcomponent displayname="Build Volume Packet" hint="Build Volume Packet">
	<!----------------- loadBasicInformation() -------------------->
   	<cffunction name="loadBasicInformation" output="true" hint="load with Basic Information values">
		<cfargument name="packetId" type="string" required="true" default="">
		<cfset this.packetId 				= arguments.packetId>
		<cfset this.Default_Sort_By = "Item">
		<cfset this.yearSpan = 365>
		
		<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="#this.Default_Sort_By#">
		<cfset this.Default_Sort_Order = "ASC">
		<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="#this.Default_Sort_Order#">		
		<cfset this.sortType = "text">
		<cfif NOT ListFindNoCase("item,upc,groupName,description,forecastVolume", FORM.SORT_BY)>
			<cfset FORM.SORT_BY = this.Default_Sort_By>
		</cfif>
		<cfif ListFindNoCase("forecastVolume", FORM.SORT_BY)>
			<cfset this.sortType = "numeric">
		</cfif>
		
		<cfif isDefined("URL.SORT_BY") and URL.SORT_BY neq "">
			<cfset FORM.SORT_BY = URL.SORT_BY >
		</cfif>
		
		<cfif isDefined("URL.SORT_ORDER") and URL.SORT_ORDER neq "">
			<cfset FORM.SORT_ORDER = URL.SORT_ORDER >
		</cfif>
		
		<CFSET this.Window_Max_Width 	= 790>
		
		<cfif isDefined("URL.action")>
			<cfset this.action			 			= URL.action>
		</cfif>
		
		<cfset this.pass_url					= "">
		<cfset this.pass_url					= Build_To_URL(this.pass_url, "packetId", this.packetId)>
		
		<cfset this.Volume_Packet_Builder = CreateObject("component", "components.volume.BuildVolumePacket")>
		<cfset this.packetId = this.Volume_Packet_Builder.init(this.packetId, 0)>

		<cfset this.volumePacket = this.Volume_Packet_Builder.getVolumePacket()>
		
		<cfif ArrayLen(this.volumePacket.products) LTE 0>
			<cfif this.volumePacket.canDoForecast>
				<cfset this.volumePacket.canDoForecastString = "There should be at least 1 product selected to do forecast">
			</cfif>
			<cfset this.volumePacket.canDoForecast = 0>			
		</cfif>
		<!---TSF: Label 9425 - Verify the distributor exists in the packet--->
		<cfif isDefined("this.volumePacket.distributors") and ArrayLen(this.volumePacket.distributors) LTE 0>
			<cfif this.volumePacket.canDoForecast>
				<cfset this.volumePacket.canDoForecastString = "There should be at least 1 distributor selected to do forecast">
			</cfif>
			<cfset this.volumePacket.canDoForecast = 0>
		</cfif>
		
		<cfset this.volumePacket.uomDesc 		= request.app_general_functions.getUOMDesc(this.volumePacket.uom)>
		<CFPARAM NAME="this.action" 	DEFAULT="#this.volumePacket.action#">
		
		<!------ Initialise ForecastInfo struct ----->
		<cfset this.forecastInfo = this.volumePacket.forecastInfo>
		
		<!------ load Volume UOT Struct ----->
		<cfif this.volumePacket.volumeMultiplier>
			<cfset this.defaultUOT = CreateObject("component", "components.volume.uotManager").get(this.volumePacket.volumeUOT) />
		<cfelse>
			<cfset this.defaultUOT = CreateObject("component", "components.volume.uotManager").get(0) />
			<cfset this.defaultUOT.setDesc(capitalizeStartLetters(this.volumePacket.appAreaKeyword)) />
			<cfset this.defaultUOT.setMultiplier(this.volumePacket.appAreaSpan) />
		</cfif>
	  <cfreturn this.volumePacket />
   	</cffunction>
	
	<cffunction name="gotoStepOne" output="true" hint="gotoStepOne">
		<!---- Show forecast or productlist ------->
		<cfscript>
			this.showAppAreaInfo();
		</cfscript>
		<cfif this.action EQ "forecast" AND this.volumePacket.canDoForecast>
			<CFSET this.showForecastForm()>
			<!---TSF: Label 6160--->
		<cfelseif this.action EQ "claim">
			<CFSET this.showClaimForm()>
		<cfelseif this.action EQ "list">
			<!---TSF: Label D6588 --->
			<!--- <CFSET this.showProductList()> --->
			<cfset this.showGrandTotal() />
		<cfelseif this.action EQ "loadforecast" AND this.volumePacket.canDoForecast>
			<cfset this.Load_From_Forecast 			= true>
			<!---TSF: Label D6588 --->
			<!--- <CFSET this.showProductList()> --->
			<cfset this.showGrandTotal() />
		<cfelseif this.action EQ "edit">
			<CFSET this.showProductList()>
		<cfelseif this.volumePacket.canDoForecast>			
			<CFSET Not_Null_Volume_Products = this.Get_Null_Volume_Product_List(1)>
			<CFSET Any_Proper_Volume = false>
			<CFIF Not_Null_Volume_Products.RecordCount GT 0>
				<CFSET Any_Proper_Volume = true>
			</CFIF>
			<CFIF Any_Proper_Volume>
				<CFSET D_Temp = this.showProductList()>
			<CFELSE>
				<CFSET D_Temp = this.showForecastForm()>
			</CFIF>
		<CFELSE>
			<CFSET D_Temp = this.showGrandTotal()>
		</CFIF>	
	</cffunction>
	
	
	<cffunction name="showForecastForm" output="true" hint="Show_Forecast_Form">
		<!---- Display the forecast form ------->		
		<CFSET this.showPleaseWait()>
		<SPAN ID="Hide_For_Please_Wait">
		<CFSET this.showForecastBasicInfo()>
		
		<CFSET Date_Error_Message = "Start can not be after the end and both must be before today">
		
		<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>	
		<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
			function resetDates(thisObj)
			{
				
				var thisForm 	= thisObj.form;
				var FromObj 	= thisForm.Forecast_From_Date;
				var ToObj 		= thisForm.Forecast_To_Date;
				
				var SpanArray 	= thisObj.value.split("~");
				ToObj.value 	= SpanArray[1];
				
				var ToObjAr 	= ToObj.value.split("/");
				var date1 		= new Date(ToObjAr[2], parseInt(ToObjAr[0], 10) - 1, ToObjAr[1]);
				var addDays 	= parseInt(SpanArray[0]);
				if(isNaN(addDays))
					addDays 	= 0;
				var fromDate 	= dateAdd("d", date1, (addDays * -1) + 1);
				
				var fromDateStr = "";
				fromDateStr 	= fromDateStr + PadString(fromDate.getMonth() + 1, 2, "0") + "/";				
				fromDateStr 	= fromDateStr + PadString(fromDate.getDate(), 2, "0") + "/";
				fromDateStr 	= fromDateStr + fromDate.getFullYear();				
				FromObj.value 	= fromDateStr;				
				recalc_Forecast_Span();
			}			
			
			function disableForecastOptions(index)
			{
				disableDiv("Forecast_Form_Div_" + index, false, false);
				disableDiv("Forecast_Form_Div_" + (3 - (index %  3)), true, false);
				document.all.Forecast_Option[Math.abs(1 - index)].checked = true;
				document.all.Forecast_Option[Math.abs(2 - index)].checked = false;
			}			
		</SCRIPT>
		
		<cf_MessageWindow>
		<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
		//changeOnBlur();
		function submitForecastForm()
		{


			event.returnValue = false;
			var dateErrObj = document.all.Forecast_Form_Dates;
			if(checkValid_Dates())
			{
				clearQueue(dateErrObj);
				disableForecastOptions(2);
				document.Forecast_Form.submit();
				show_please_wait(document.all.Hide_For_Please_Wait);
			}
			else
			{
				queueMessage("#Date_Error_Message#", dateErrObj);
				showMessageWindow();
			}
			
		}
		
		function changeOnBlur()
		{
			//document.all.Forecast_To_Date.onpropertychange = new Function("reset_Forecast_Span()");
			//document.all.Forecast_From_Date.onpropertychange = new Function("reset_Forecast_Span()");
		}
		function reset_Forecast_Span()
		{
			if(event.propertyName == "value")
			{
				recalc_Forecast_Span();							
			}
		}
		
		function checkValid_Dates()
		{
			var returnValue = true;
			var dToDate = build_Date(document.all.Forecast_To_Date.value);
			var dFromDate = build_Date(document.all.Forecast_From_Date.value);
			
			if(dToDate != null & dFromDate != null)
			{
				var today = new Date();
				returnValue = (days_between(dToDate, dFromDate, true) >= 0) && (days_between(today, dFromDate, true) >= 0) && (days_between(today, dToDate, true) >= 0);
				if(!returnValue)
				{	
					if(event.srcElement.tagName == "INPUT")
					{
						event.srcElement.style.border = "1px red solid";
					}
				}
				else
				{
					if(event.srcElement.tagName == "INPUT")
					{
						document.all.Forecast_From_Date.style.border = "1px gray solid";
						document.all.Forecast_To_Date.style.border = "1px gray solid";
					}
				}
			}
			return returnValue;
		}
		
		function recalc_Forecast_Span()
		{
			try
			{
				var toDate = document.all.Forecast_To_Date.value;
				var fromDate = document.all.Forecast_From_Date.value;
				var dToDate = build_Date(toDate);
				var dFromDate = build_Date(fromDate);
				
				if(dToDate != null & dFromDate != null)
				{
					var days = days_between(dToDate, dFromDate, true);
					if(days < 0)
					{
						days = 0;
					}
					else
					{
						days++;
					}							
					document.all.DIV_Curr_Forecast_Span.innerText = days;
					checkValid_Dates();
				}
			}
			catch(e)
			{
				alert(e.description);
			}
		}
		
		</SCRIPT>
		<CFSET D_Temp = this.showForecastSmallMenu(1)>
		
		<!------ Build the dynamic date spans ----->		
		<CFSET Date1 = DateAdd("d", -1, this.volumePacket.appAreaStartDate)>
		<cfif IsLeapYear(Year(this.volumePacket.appAreaEndDate)) AND Month(this.volumePacket.appAreaEndDate) EQ 12 AND Day(this.volumePacket.appAreaEndDate) EQ 31>
			<CFSET Year_Ago = DateAdd("yyyy", -1, DateAdd("d", -1, this.volumePacket.appAreaEndDate))>
		<cfelse>
			<CFSET Year_Ago = DateAdd("yyyy", -1, this.volumePacket.appAreaEndDate)>
		</cfif>

		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
		
		<CFSET Forecast_Span_Category = "Most recent">
		<CFSET Forecast_Span_Category_Date_End = "#DateFormat(DateAdd("d", -1, Now()), "mm/dd/yyyy")#">
		<CFSET DateSpanList = "#appSettings.getNumberOfDaysForMiniItemMaster()#">
		<cfset this.Default_Span_Len 			= ListFirst(ListFirst(DateSpanList, ","), "~")>
		<CFSET Forecast_To_Date 				= Forecast_Span_Category_Date_End>
		<!--- <cfset Forecast_To_Date 				= DateFormat(Year_Ago, "mm/dd/yyyy")> --->
		
		<CFSET Forecast_From_Date = DateAdd("d", Evaluate((this.Default_Span_Len*-1) + 1), Forecast_To_Date)>
		
		
		<FORM NAME="Forecast_Form" ACTION="Volume_Forecast_Action.cfm?#this.pass_url#" METHOD="post" STYLE="Display:Inline;">
			<INPUT TYPE="Hidden" NAME="packetId" VALUE="#this.packetId#">			
			<TABLE CELLPADDING="4" CELLSPACING="0" BORDER="0" ALIGN="center" WIDTH="600">
			<TR>
				<TD colspan="100%">
				<B>Select any date from either the 'Day Option' or the 'Date Option', and click the execute button to do the forecast</B>
				</TD>
			</TR>
			<TR>
				<TD ONCLICK="javaScript: disableForecastOptions(1);" STYLE="cursor:pointer;" ALIGN="center"><INPUT TYPE="CHECKBOX" CHECKED ID="Forecast_Option">
				<B>Day Option</B></TD>
				<TD ONCLICK="javaScript: disableForecastOptions(2);" STYLE="cursor:pointer;" ALIGN="center"><INPUT TYPE="CHECKBOX" ID="Forecast_Option" disabled>
				<B>Date Option</B>
				</TD>
			</TR>
			<TR VALIGN="top">
				<TD WIDTH="250" ALIGN="center">
					<DIV STYLE="DISPLAY:INLINE;" ID="Forecast_Form_Div_1">
					<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="100%">
					<CFSET counter=1>
					<CFLOOP LIST="#Forecast_Span_Category#" INDEX="This_Category" DELIMITERS=",">
					<CFSET Current_End_Date = ListGetAt(Forecast_Span_Category_Date_End, counter, ",")>
					<TR BGCOLOR="##FFE4B5">
						<TD COLSPAN="100%" NOWRAP><B>#This_Category#</B></TD>
					</TR>
					<CFSET bDisabled 	= false>
					<CFSET BGCOLOR 		= "White">
					<CFSET CH_DISABLED 	= "">
					<CFIF DATEDIFF("d", Now(), Current_End_Date) GT 0>
						<CFSET bDisabled 	= true>
						<CFSET BGCOLOR 		= "##EEEEEE">
						<CFSET CH_DISABLED 	= " DISABLED">
					</CFIF>
					
					<CFLOOP LIST="#DateSpanList#" INDEX="This_Item">
						<TR BGCOLOR="#BGCOLOR#">
							<TD BGCOLOR="White" STYLE="border-left:##FFE4B5 1px solid;">&nbsp;</TD>
							<TD NOWRAP>
								<CFIF bDisabled>
									<IMG SRC="/Images/radio_disabled.gif" title="#DateFormat(Current_End_Date, "mm/dd/yyyy")# is after today">
								<CFELSE>
									<INPUT<CFIF Forecast_To_Date EQ Current_End_Date AND this.Default_Span_Len EQ This_Item> CHECKED</CFIF> ONCLICK="javaScript: resetDates(this)" VALUE="#This_Item#~#DateFormat(Current_End_Date, "mm/dd/yyyy")#" TYPE="Radio" VALUE="" NAME="Radio1" #CH_DISABLED#>
								</CFIF>
							</TD>
							<TD NOWRAP STYLE="font-size:12px;">#This_Item#</TD>
							<TD NOWRAP>days before</TD>
							<TD NOWRAP>#DateFormat(Current_End_Date, "mm/dd/yyyy")#</TD>
							<TD BGCOLOR="#BGCOLOR#" STYLE="border-right:##FFE4B5 1px solid;">&nbsp;</TD>
						</TR>
					</CFLOOP>
					<CFSET counter=counter+1>
					</CFLOOP>
					<TR>
						<TD BGCOLOR="White" COLSPAN="100%" STYLE="border-top:##FFE4B5 1px solid;">&nbsp;</TD>
					</TR>
					</TABLE>
					</DIV>
				</TD>			
				<TD WIDTH="200">
					<DIV STYLE="DISPLAY:INLINE;" ID="Forecast_Form_Div_2">
					<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
					<TR>
						<TD><B>From</B>&nbsp;&nbsp;</TD>
						<TD><CF_EASYDATE2 FORMNAME="Forecast_Form" FIELDNAME="Forecast_From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Forecast_From_Date#" INP_ARGUMENTS="previous_value=""#dateFormat(Forecast_From_Date, "mm/dd/yyyy")#"" onpropertychange=""reset_Forecast_Span();"" STYLE=""border:1px gray solid;"""></TD>
					</TR>
					<TR>
						<TD><B>To</B>&nbsp;&nbsp;</TD>
						<TD><CF_EASYDATE2 FORMNAME="Forecast_Form" FIELDNAME="Forecast_To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Forecast_To_Date#" INP_ARGUMENTS="previous_value=""#dateFormat(Forecast_To_Date, "mm/dd/yyyy")#"" onpropertychange=""reset_Forecast_Span();"" STYLE=""border:1px gray solid;"""></TD>
					</TR>
					<TR>
						<TD COLSPAN="2" ALIGN="center"><B><DIV STYLE="DISPLAY:INLINE" ID="DIV_Curr_Forecast_Span">#Evaluate(DateDiff("d", Forecast_From_Date, Forecast_To_Date) + 1)#</DIV>&nbsp;days</B></TD>
					</TR>
					</TABLE>
					</DIV>					
					<BR><BR>
					<FONT COLOR="red">#Date_Error_Message#</FONT><BR>
					<DIV align="center">
					<SPAN ID="Forecast_Form_Dates">&nbsp;&nbsp;&nbsp;</SPAN>
					<CF_button
						button_name		=	""
						button_caption	=	"execute"
						button_action	=	"submitForecastForm()"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"execute"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>	
					<!------ <B><FONT COLOR="FF0000">[</FONT><a HREF="void(0);" ONCLICK="javaScript: return submitForecastForm()">execute</a><FONT COLOR="FF0000">]</FONT></B> ----->
					</DIV>
				</TD>
				<TD ALIGN="center" WIDTH="100">				
				</TD>
			</TR>
			</TABLE>		
		</FORM>
		<SCRIPT LANGUAGE="JavaScript">
			disableForecastOptions(1);
		</SCRIPT>
		</SPAN>
	</cffunction>
	
	<!----------------- showForecastSmallMenu() -------------------->
	<cffunction name="showForecastSmallMenu" output="true" hint="showForecastSmallMenu">		
		<cfargument name="pageID" type="numeric" required="false" default="1">
		<style>
			.selMenu
			{
				background-color: ##FFFFBB;
			}
			.disabledMenu
			{
				background-color: ##EEEEEE;
				color: ##AAAAAA;
			}
		</style>
		<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="#this.Window_Max_Width#">
			<TR>
				<TD>
					<table WIDTH="50%" ALIGN="center">
						<tr>
							<CFIF this.volumePacket.canDoForecast>
								<cfset forecastUrl = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action","forecast")#" />
								<td style="border:1px solid navy;" <cfif Arguments.pageID EQ 1>CLASS="selMenu"</cfif> align="center" width="25%">
									<B><a HREF="#forecastUrl#" title="start forecast...">automated forecast</a></B>
								</td>
							<CFELSE>
								<td style="border:1px solid navy;" CLASS="disabledMenu" align="center" width="25%" title="#this.volumePacket.canDoForecastString#">
									<B>automated forecast</B>
								</td>
							</CFIF>
							<CFIF this.forecastInfo.priorForecast>
								<cfset loadFCUrl = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action","loadforecast")#" />
								<td style="border:1px solid navy;" <cfif Arguments.pageID EQ 2>CLASS="selMenu"</cfif> align="center" width="25%">
									<B><a HREF="#loadFCUrl#" title="view the forecast volume for all the products....">prior forecast</a></B>
								</td>
							<CFELSE>
								<td style="border:1px solid navy;" CLASS="disabledMenu" align="center" width="25%" title="There are no prior forecasts">
									<B>prior forecast</B>
								</td>
							</CFIF>
							<CFIF this.volumePacket.canDoClaimForecast and ArrayLen(this.volumePacket.operators)>
								<cfset claimUrl = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action","claim")#" />
								<td style="border:1px solid navy;" <cfif Arguments.pageID EQ 4>CLASS="selMenu"</cfif> align="center" width="25%">
									<B><a HREF="#claimUrl#" title="view the volume claimed for all the products....">claim forecast</a></B>
								</td>
							<cfelse>
								<td style="border:1px solid navy;" CLASS="disabledMenu" align="center" width="25%" title="There are no operators to forecast">
									<B>claim forecast</B>
								</td>
							</CFIF>
							<cfset listFCUrl = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action","list")#" />
							<td style="border:1px solid navy;" <cfif Arguments.pageID EQ 3>CLASS="selMenu"</cfif> align="center" width="25%">
								<B><a HREF="#listFCUrl#" title="view the current volume for all the products....">manual estimate</a></B>
							</td>		
						</tr>
					</table>
				</TD>
			</TR>
		</TABLE>
   	</cffunction>
	
	
	<cffunction name="doForecast" output="true" hint="Do_Forecast">
		<!---- Will be called on forecast form submit, call the sp ------->
		<cfargument name="accessStructure" type="struct" required="true" default="">
		
		<CFPARAM NAME="Forecast_To_Date" 	DEFAULT="#Now()#">
		<CFPARAM NAME="Forecast_From_Date" 	DEFAULT="#Now()#">
		
		<CFTRANSACTION ACTION="BEGIN">
			<CFTRY>
				<!------ check whether a forecast exist already ----->
				
				<cfif this.forecastInfo.priorForecast>
					<cfset useLakebaseForCheck_Prior_Forecast = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("forecast")>
<cfif useLakebaseForCheck_Prior_Forecast>
	<cftry>
		<cfset Check_Prior_Forecast = application.oLakebase.toQuery(
			application.oLakebase.selectRows("forecast", {
				"forecast_id" = "eq.#this.volumePacket.forecastId#",
				"select" = "forecast_id"
			}), "forecast_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_Prior_Forecast = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_Prior_Forecast>
<CFQUERY NAME="Check_Prior_Forecast" DATASOURCE="#application.datasource#">
						SELECT	Forecast_ID
						FROM	Forecast
						WHERE
								Forecast_ID = #this.volumePacket.forecastId#
					</CFQUERY>
</cfif>
					<cfif Check_Prior_Forecast.recordCount EQ 0>
						<cfset this.forecastInfo.priorForecast = false>
					</cfif>
				</cfif>
				
				<cfif this.forecastInfo.priorForecast>
					<!------ update ----->
					<CFQUERY NAME="Update_Forecast_Info" DATASOURCE="#application.datasource#">
						UPDATE	Forecast
						SET	
							Forecast_From_Date			= #CreateODBCDate(Forecast_From_Date)#,
							Forecast_To_Date			= #CreateODBCDate(Forecast_To_Date)#,
							Forecast_Update_Date		= GetDate(),
							Forecast_Update_User_ID		= '#Arguments.AccessStructure.User_ID#',
							Forecast_App_Area			= #this.volumePacket.appArea#,
							App_Area_Start_Date			= #CreateODBCDateTime(this.volumePacket.appAreaStartDate)#, 
							App_Area_End_Date			= #CreateODBCDateTime(this.volumePacket.appAreaEndDate)#
						WHERE
								Forecast_ID = #this.volumePacket.forecastId#
					</CFQUERY>
				<cfelse>
					<!------ insert ----->
					<CFQUERY NAME="Insert_Forecast_Info" DATASOURCE="#application.datasource#">
						SET NOCOUNT ON
		
						INSERT INTO	Forecast
						(Forecast_From_Date, Forecast_To_Date, Forecast_Update_User_ID, Forecast_App_Area, App_Area_Start_Date, App_Area_End_Date)
						VALUES
						(#CreateODBCDate(Forecast_From_Date)#, #CreateODBCDate(Forecast_To_Date)#, '#Arguments.AccessStructure.User_ID#', #this.volumePacket.appArea#, #CreateODBCDateTime(this.volumePacket.appAreaStartDate)#, #CreateODBCDateTime(this.volumePacket.appAreaEndDate)#)
						
						SELECT Forecast_ID = @@IDENTITY
						SET NOCOUNT OFF
					</CFQUERY>
					
					<cfset this.volumePacket.forecastId = Insert_Forecast_Info.Forecast_ID>
				</cfif>
				
				<!------ delete distributors ----->
				<CFQUERY NAME="Delete_Distributors" DATASOURCE="#application.datasource#">
					DELETE
					FROM	Forecast_Distributor
					WHERE
							Forecast_Distributor.Forecast_ID = #this.volumePacket.forecastId#
				</CFQUERY>
				
				<!------ Insert Distributors ----->
				<cfset distArray = this.volumePacket.distributors>
				<cfset distLen = ArrayLen(distArray)>
				
				<cfloop index="i" from="1" to="#distLen#">
					<CFQUERY NAME="Insert_Distributor" DATASOURCE="#application.datasource#">
						INSERT INTO	Forecast_Distributor
						(Forecast_ID, Distributor_ID)
						VALUES
						(#this.volumePacket.forecastId#, '#distArray[i]#')
					</CFQUERY>
				</cfloop>
				
				<!------ delete products ----->
				<CFQUERY NAME="Delete_products" DATASOURCE="#application.datasource#">
					DELETE
					FROM	Forecast_Product
					WHERE
							Forecast_Product.Forecast_ID = #this.volumePacket.forecastId#
				</CFQUERY>
				
				<cfset prodArray = this.volumePacket.products>
				<cfset prodLen = ArrayLen(prodArray)>
				
				<cfloop index="i" from="1" to="#prodLen#">
				
					<!---first check to see if there is an entry for this forecast product combination--->
					<cfquery name="qCheckForEntry" datasource="#application.datasource#">
						SELECT 	*
						FROM	Forecast_Product
						WHERE	Forecast_ID = 	#trim(this.volumePacket.forecastId)#
						AND		Product_ID =	'#trim(prodArray[i].productId)#'
					</cfquery>
						
					<cfif not qCheckForEntry.RecordCount>
							
						<CFQUERY NAME="Insert_Product" DATASOURCE="#application.datasource#">
							INSERT INTO	Forecast_Product
							(Forecast_ID, Product_ID)
							VALUES
							(#this.volumePacket.forecastId#, '#prodArray[i].productId#')
						</CFQUERY>
					</cfif>
				</cfloop>
				
				<CFSTOREDPROC PROCEDURE="GET_FORECAST_VOLUME" datasource="#application.datasource#">
					<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@@C_Program_ID"	VALUE="#this.volumePacket.forecastId#">
					<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_Start_Date"	VALUE="#DateFormat(Forecast_From_Date, "mm/dd/yyyy")#">
					<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_TIMESTAMP"	DBVARNAME="@@C_End_Date"	VALUE="#DateFormat(Forecast_To_Date, "mm/dd/yyyy")#">
				</CFSTOREDPROC>
				
				
				<CFQUERY NAME="Get_All_Forecast_Volumes" DATASOURCE="#application.datasource#">
					SELECT	Product_ID,
							<cfif this.volumePacket.uom EQ 1>
							Forecast_Volume.Volume_CS
							<cfelse>
							Forecast_Volume.Volume_LB
							</cfif> as forecastVolume
					FROM	Forecast_Volume
					WHERE
								Forecast_Volume.Forecast_ID = #this.volumePacket.forecastId#
				</CFQUERY>
				
				<cfset this.volumePacket.distributorsNotInAppArea = 0>
				<cfset this.volumePacket.distributorsNotInForecast = 0>
				<cfset this.volumePacket.proudctsNotInForecast = 0>
				<cfloop index="i" from="1" to="#prodLen#">
					<CFQUERY NAME="getForecastVolume" dbtype="query">
						SELECT	forecastVolume
						FROM	Get_All_Forecast_Volumes
						WHERE
								Product_ID = '#prodArray[i].productId#'
					</CFQUERY>
					<cfif getForecastVolume.recordCount GT 0>
						<cfset prodArray[i].forecastVolume = getForecastVolume.forecastVolume>
					<cfelse>
						<cfset prodArray[i].forecastVolume = 0>
					</cfif>
					<cfset prodArray[i].doneForecast = 1>
				</cfloop>
				
				<cfscript>
					this.Volume_Packet_Builder.volumePacket = this.volumePacket;
					this.Volume_Packet_Builder.setForecastId(this.volumePacket.forecastId);
					this.Volume_Packet_Builder.setAction("loadforecast");
					this.packetId = this.Volume_Packet_Builder.saveVolumePacket();
				</cfscript>
				
				<CFTRANSACTION ACTION="COMMIT">
				<CFCATCH>
					<CFTRANSACTION ACTION="ROLLBACK">
					<CFRETHROW>
				</CFCATCH>
			</CFTRY>
		</CFTRANSACTION>		
	</cffunction>
	
	<cffunction name="copyForecast" output="true" hint="copyForecast">
		<cfargument name="forecastId" type="string" required="true" default="0">
		<cfset oldForecastId = arguments.forecastId>
		<cfset forecastId = 0>
		<cfif NOT Isnumeric(oldForecastId) OR oldForecastId EQ "" OR oldForecastId EQ 0>
			<cfset oldForecastId = 0>			
		</cfif>
		
		<cfif oldForecastId NEQ 0>
	
			<CFQUERY NAME="Check_Prior_Forecast" DATASOURCE="#application.datasource#">
				SELECT	Forecast_ID
				FROM	Forecast
				WHERE
						Forecast_ID = #oldForecastId#
			</CFQUERY>
			<cfif Check_Prior_Forecast.recordCount EQ 0>
				<cfset oldForecastId = 0>
			</cfif>
			
			<cfif oldForecastId NEQ 0>
				<CFTRANSACTION ACTION="BEGIN">
					<CFTRY>
						<CFQUERY NAME="Insert_Forecast" DATASOURCE="#application.datasource#">
							SET NOCOUNT ON
							INSERT INTO Forecast
									(Forecast_From_Date, Forecast_To_Date, Forecast_Update_Date, Forecast_Update_User_ID, Forecast_App_Area, App_Area_Start_Date, App_Area_End_Date)
							SELECT
									Forecast_From_Date, Forecast_To_Date, Forecast_Update_Date, Forecast_Update_User_ID, Forecast_App_Area, App_Area_Start_Date, App_Area_End_Date
							FROM	Forecast
							WHERE
									Forecast_ID = #oldForecastId#
							SELECT Forecast_ID = @@IDENTITY
							SET NOCOUNT OFF
						</CFQUERY>
						<cfset forecastId = Insert_Forecast.Forecast_ID>
						
						<!------ delete distributors ----->
						<CFQUERY NAME="Delete_Distributors" DATASOURCE="#application.datasource#">
							DELETE
							FROM	Forecast_Distributor
							WHERE
									Forecast_Distributor.Forecast_ID = #forecastId#
						</CFQUERY>
						
						<!------ Insert Distributors ----->
						<CFQUERY NAME="Insert_Distributor" DATASOURCE="#application.datasource#">
							INSERT INTO	Forecast_Distributor
									(Forecast_ID, Distributor_ID)
							SELECT
									#forecastId#, Distributor_ID
							FROM	Forecast_Distributor
							WHERE
									Forecast_Distributor.Forecast_ID = #oldForecastId#
						</CFQUERY>
						
						<!------ delete operators ----->
						<CFQUERY NAME="Delete_Operators" DATASOURCE="#application.datasource#">
							DELETE
							FROM	Forecast_Operator
							WHERE
									Forecast_Operator.Forecast_ID = #forecastId#
						</CFQUERY>
						
						<!------ Insert operators ----->
						<CFQUERY NAME="Insert_Operators" DATASOURCE="#application.datasource#">
							INSERT INTO	Forecast_Operator
									(Forecast_ID, BSA_Operator_ID)
							SELECT
									#forecastId#, BSA_Operator_ID
							FROM	Forecast_Operator
							WHERE
									Forecast_Operator.Forecast_ID = #oldForecastId#
						</CFQUERY>
						
						<!------ delete products ----->
						<CFQUERY NAME="Delete_products" DATASOURCE="#application.datasource#">
							DELETE
							FROM	Forecast_Product
							WHERE
									Forecast_Product.Forecast_ID = #forecastId#
						</CFQUERY>
						
						<CFQUERY NAME="Insert_Product" DATASOURCE="#application.datasource#">
							INSERT INTO	Forecast_Product
									(Forecast_ID, Product_ID)
							SELECT
									#forecastId#, Product_ID
							FROM	Forecast_Product
							WHERE
									Forecast_Product.Forecast_ID = #oldForecastId#
						</CFQUERY>
						
						<!------ delete forecast volume ----->
						<CFQUERY NAME="Delete_Volume" DATASOURCE="#application.datasource#">
							DELETE
							FROM	Forecast_Volume
							WHERE
									Forecast_Volume.Forecast_ID = #forecastId#
						</CFQUERY>
						
						<!------ Insert forecast volume ----->
						<CFQUERY NAME="Insert_Volume" DATASOURCE="#application.datasource#">
							INSERT INTO	Forecast_Volume
									(Forecast_ID, Product_ID, Volume_CS, Volume_LB)
							SELECT
									#forecastId#, Product_ID, Volume_CS, Volume_LB
							FROM	Forecast_Volume
							WHERE
									Forecast_Volume.Forecast_ID = #oldForecastId#
						</CFQUERY>
							
						<CFTRANSACTION ACTION="COMMIT">
						<CFCATCH>
							<CFTRANSACTION ACTION="ROLLBACK">
							<CFRETHROW>
						</CFCATCH>
					</CFTRY>
				</CFTRANSACTION>
			</cfif>
		</cfif>		
		<cfreturn forecastId>			
	</cffunction>
	
	<!----------------- showClaimForm() -------------------->
	<cffunction name="showClaimForm" output="true">
	
		<CFSET this.showPleaseWait()>
		<SPAN ID="Hide_For_Please_Wait">
		<CFSET this.showForecastBasicInfo()>
		<CFSET D_Temp = this.showForecastSmallMenu(4)>
		<cfset defaultStart = DateAdd("yyyy", -1, "#this.volumePacket.appAreaStartDate#") />
		<cfset defaultEnd = DateAdd("yyyy", -1, "#this.volumePacket.appAreaEndDate#") />
		<FORM NAME="Claim_Forecast_Form" ACTION="Volume_Claim_Action.cfm?#this.pass_url#" METHOD="post" STYLE="Display:Inline;">
			<INPUT TYPE="Hidden" NAME="packetId" VALUE="#this.packetId#">			
				<br>
				<DIV align="center">
					<b>Select a date range for claim history:</b>
					<br><br>
					<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
						<TR>
							<TD><B>From</B>&nbsp;&nbsp;</TD>
							<TD><CF_EASYDATE2 FORMNAME="Claim_Forecast_Form" FIELDNAME="Claim_From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#defaultStart#"></TD>
						</TR>
						<TR>
							<TD><B>To</B>&nbsp;&nbsp;</TD>
							<TD><CF_EASYDATE2 FORMNAME="Claim_Forecast_Form" FIELDNAME="Claim_To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#defaultEnd#"></TD>
						</TR>
					</TABLE>
					<br>
					<CF_button
						button_name		=	""
						button_caption	=	"execute"
						button_action	=	"document.Claim_Forecast_Form.submit();"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"execute"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</DIV>		
		</FORM>
		
	</cffunction>
	
	<!----------------- doClaimForecast() -------------------->
	<cffunction name="doClaimForecast" output="true" hint="doClaimForecast">
		<cfargument name="startDate" type="date" required="false" default="" />
		<cfargument name="endDate" type="date" required="false" default="" />
		
		<cfstoredproc procedure="SP_GET_CLAIM_FORECAST" datasource="#application.datasource#">
								
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#this.volumePacket.appAreaID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@@START_DATE" null="no" value="#arguments.startDate#">
			<cfprocparam type="In" CFSQLType="CF_SQL_DATE" dbVarName = "@@END_DATE" null="no" value="#arguments.endDate#">
					
		</cfstoredproc>
		
		<cfquery name="qGetAllOperatorSums" datasource="#application.datasource#">
			SELECT	Paid_CS,
					Paid_LB,
					Product_ID
			FROM	Claim_Forecast
			WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#this.volumePacket.appAreaID#" />	
		</cfquery>
		
		<cfset this.Volume_Packet_Builder.setProductsWithZeroVolume(0) />
		<cfset claimDateSpan = DateDiff("d", arguments.startDate, arguments.endDate) />
		<cfset lOperator = ArrayToList(this.volumePacket.operators) />
		<cfset prodArray = this.volumePacket.products>
		<cfset prodLen = ArrayLen(prodArray)>
		<cfloop index="i" from="1" to="#prodLen#">
			<!---get the paid sum for these operator/product combinations--->
			<cfset useLakebaseForqGetOperatorSums = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetalloperatorsums")>
<cfif useLakebaseForqGetOperatorSums>
	<cftry>
		<cfset qGetOperatorSums = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetalloperatorsums", {
				"product_id" = "eq.#prodArray[i].productId#",
				"select" = "paid_cs,paid_lb"
			}), "paid_cs,paid_lb"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOperatorSums = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOperatorSums>
<cfquery name="qGetOperatorSums" dbtype="query">
				SELECT	Paid_CS,
						Paid_LB
				FROM 	qGetAllOperatorSums
				WHERE	Product_ID = '#prodArray[i].productId#'
			</cfquery>
</cfif>
			
			<cfset tmpClaimVolume = 0 />
			<!---handle for UOM if we get a record set back--->
			<cfif qGetOperatorSums.RecordCount>
				<cfif this.volumePacket.UOM eq 1>
					<cfset tmpClaimVolume = qGetOperatorSums.Paid_CS />
				<cfelse>
					<cfset tmpClaimVolume = qGetOperatorSums.Paid_LB />
				</cfif>
			</cfif>
			<CFSET tmpProdVol = Round((tmpClaimVolume / claimDateSpan) * this.defaultUOT.getMultiplier())>
			<cfset this.volumePacket.products[i].productVolume = tmpProdVol />
			<!---if volume is zero increment the zero volume count--->
			<cfif tmpProdVol lte 0>
				<cfset this.Volume_Packet_Builder.setProductsWithZeroVolume(this.Volume_Packet_Builder.getProductsWithZeroVolume() + 1) />
			</cfif>
		</cfloop>

		<cfscript>
			this.Volume_Packet_Builder.volumePacket = this.volumePacket;
			this.packetId = this.Volume_Packet_Builder.saveVolumePacket();
		</cfscript>
				
	</cffunction>
	
	<cffunction name="showProductList" output="true" hint="showProductList">
	
		<CFSET this.showPleaseWait(2)>
		<SPAN ID="Hide_For_Please_Wait">
		<!---TSF: Label D6588 --->
<!--- 	TSF: Commented for Volume paging		
		<cfif this.action EQ "loadforecast">
			<CFSET D_Temp = this.showForecastBasicInfo()>
			<CFSET this.showForecastSmallMenu(2)>
		<cfelse>
			<CFSET this.showForecastSmallMenu(3)>
		</cfif> --->
		<CFSET this.showVolumeApplicator(ArrayLen(this.volumePacket.products))>
		<cfset showAnnualVolume = 1>
		<cfif this.volumePacket.showVolumeCap>
			<cfset showAnnualVolume = 0>
		</cfif>
		
		<CFSET This_Template_Name = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", this.action)#">
		<CFSET Save_Template_Name = "Volume_Applicator_Action.cfm?#this.pass_url#">
		<CFSET Parent_Template_Name = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", "list")#">

		<STYLE>
			.MainHead TD
			{
				font-size: 12px;
			}
			.DIV_HIDE_OVERFLOW
			{
				overflow:hidden;
				display:inline;
			}
			TABLE.Maintable TD 
			{
				border:none;
			}
			.BlackBorder
			{
				border:1px solid black;
			}
			.RedBorder
			{
				border:1px solid red;
			}
			.BlueBorder
			{
				border:1px solid blue;
			}
			.GreenBorder
			{
				border:1px solid ##C71585;
			}
		</STYLE>
		<CFSET Good_Input_Border = "BlackBorder">
		<CFSET Bad_Input_Border = "RedBorder">
		<CFIF this.action EQ "loadforecast">
			<CFSET Good_Input_Border = "BlueBorder">
		</CFIF>
		<CFSET Edited_Input_Border = "GreenBorder">
		
		<cf_MessageWindow>
		<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/math_functions.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
		<CFOUTPUT>
		var Contract_Span = #this.volumePacket.appAreaSpan#;
		</CFOUTPUT>
		function ConvertToUOM(UOM_1_Value, To_UOM, Net_Weight)
		{
			var UOM_2_Value = 0;
			if(To_UOM == 1)//to case
			{
				if(Net_Weight != 0)
				{
					UOM_2_Value = UOM_1_Value / Net_Weight;
				}
			}
			else//to lb
			{
				UOM_2_Value = UOM_1_Value * Net_Weight;
			}
			return UOM_2_Value;
		}
		
		function Volume_Cap_Changed(thisObj)
		{
			var newValue = parseFloat(thisObj.value);
			if(isNaN(newValue))
			{
				newValue = 0
			}
			if(newValue <= 0)
			{
				thisObj.className = "#Bad_Input_Border#";
			}
			else
			{
				thisObj.className = "#Good_Input_Border#";
			}
		}
		
		function change_Volume_UOM_Value(thisObj)
		{
			var newVal2 = null;
			var AnnualNewVal1 = "";
			var AnnualNewVal2 = "";
			
			var pgm_totalobj = null;
			
			var newVal1 = parseFloat(thisObj.value);			
			if(isNaN(newVal1))
			{
				newVal1 = 0
			}
			//showAnnualVolume
			<cfif showAnnualVolume>
			var oAnnual_pair = document.getElementById(thisObj.annual_pair);
			</cfif>
			var pair_volume_field = thisObj.pair_volume_field;
			var obj_pair_volume_field = document.getElementById(pair_volume_field);
			//showAnnualVolume
			<cfif showAnnualVolume>
			var oAnnual_pair2 = document.getElementById(obj_pair_volume_field.annual_pair);
			</cfif>
			if(isNaN(newVal1))
			{
				newVal1 = 0;
			}
			
			if(!isNaN(newVal1))
			{				
				var dailyVolume = newVal1/#this.defaultUOT.getMultiplier()#;
				AnnualNewVal1 = dailyVolume * #this.yearSpan#;
				//annual volume for same uom
							
				//get the other uom pair
				if(pair_volume_field)
				{
					
					var netweight = parseFloat(thisObj.netweight);
					if(!isNaN(netweight))
					{					
						if(thisObj.current_uom == 1)//cs
						{
							AnnualNewVal2 = AnnualNewVal1 * netweight;
							newVal2 = ConvertToUOM(newVal1, 2, netweight);
							AnnualNewVal2 = ConvertToUOM(AnnualNewVal1, 2, netweight);
							pgm_totalobj = document.all.DIV_Program_Total_CS;
						}
						else//lb
						{
							newVal2 = ConvertToUOM(newVal1, 1, netweight);
							AnnualNewVal2 = ConvertToUOM(AnnualNewVal1, 1, netweight);
							pgm_totalobj = document.all.DIV_Program_Total_LB;
						}
					}//if(!isNaN(netweight))
				}//if(pair_volume_field)	
			}//if(!isNaN(newVal1))			
			thisObj.value = removeExponentialFormatting(newVal1);
			obj_pair_volume_field.value = removeExponentialFormatting(Math.round(newVal2));
			//TSF: Label D6588
			setParentFormFields(thisObj.name, thisObj.value);
			setParentFormFields(obj_pair_volume_field.name, obj_pair_volume_field.value);
			//showAnnualVolume
			<cfif showAnnualVolume>
			oAnnual_pair.value = removeExponentialFormatting(Math.round(AnnualNewVal1));
			oAnnual_pair.innerText = format_Volume(removeExponentialFormatting(AnnualNewVal1));
			oAnnual_pair.title = format_Volume(removeExponentialFormatting(AnnualNewVal1));
			oAnnual_pair2.value = removeExponentialFormatting(Math.round(AnnualNewVal2));
			oAnnual_pair2.innerText = format_Volume(removeExponentialFormatting(AnnualNewVal2));
			oAnnual_pair2.title = format_Volume(removeExponentialFormatting(AnnualNewVal2));
			</cfif>
	
			var suffix_text1, suffix_text1;
			if(thisObj.current_uom == 1)
			{
				suffix_text1 = "_CS";
				suffix_text2 = "_LB";				
			}
			else
			{
				suffix_text1 = "_LB";
				suffix_text2 = "_CS";
			}
			if(eval("document.all.DIV_Program_Total" + suffix_text1)){
			adjustThisTotalValue(eval("document.all.DIV_Program_Total" + suffix_text1), thisObj);			
			adjustThisTotalValue(eval("document.all.DIV_Program_Total" + suffix_text2), obj_pair_volume_field);
			}
			//showAnnualVolume			
			<cfif showAnnualVolume>
			if(eval("document.all.DIV_Program_Total" + suffix_text1)){
			adjustThisTotalValue(eval("document.all.DIV_Annual_Total" + suffix_text1), oAnnual_pair);
			adjustThisTotalValue(eval("document.all.DIV_Annual_Total" + suffix_text2), oAnnual_pair2);
			}
			</cfif>
		
			//TSF: Label D6588
			/*TSF: Removed for volume paging
			<cfif this.volumePacket.canSaveTotalQuantity>
			if(pgm_totalobj != null)
			{
				var totalProgramValue = Math.round(pgm_totalobj.total_value);
				
				totalProgramValue = totalProgramValue * (#this.volumePacket.appAreaSpan# / #this.defaultUOT.getMultiplier()#);
				
				document.all.DIV_Program_Volume.innerText = format_Volume(removeExponentialFormatting(Math.round(totalProgramValue)));
			}
			</cfif>
			*/
			
			
			if(thisObj.current_uom == "#this.volumePacket.UOM#")
			{
				var Err_Check_Obj = thisObj;
				var Err_Check_Obj_Value = newVal1;
			}
			else
			{
				var Err_Check_Obj = obj_pair_volume_field;
				var Err_Check_Obj_Value = Math.round(newVal2);
			}
			if(Err_Check_Obj_Value <= 0)
			{
				Err_Check_Obj.className = "#Bad_Input_Border#";
			}
			else
			{
				Err_Check_Obj.className = "#Good_Input_Border#";
			}
			
			//originalValue
			adjustTableWidth();
		}
		
		
		function adjustThisTotalValue(tot_div, thisObj)
		{
			var total_value = parseInt(tot_div.total_value);			
			total_value = total_value - parseInt(thisObj.previous_value);			
			total_value = total_value + Math.round(thisObj.value);
			thisObj.previous_value = Math.round(thisObj.value);
			tot_div.total_value = removeExponentialFormatting(Math.round(total_value));
			tot_div.innerText = format_Volume(total_value);			
		}
		
		function format_Volume(vol)
		{
			//return formatToDecimalPlaces(vol, 2);
			return formatWithComma(Math.round(vol), 3, false);
		}
		
		
		function sort_by_This(thisVal, thisOrder)
		{
			document.MyForm.SORT_BY.value = thisVal;
			document.MyForm.SORT_ORDER.value = thisOrder;			
			document.MyForm.submit();
			return false;
		}
		
		function save_volume(CloseStatus)
		{
			event.returnValue = false;
			var Total_Product_Volume = 0;
			var ErrorCount = 0;
			var sErr = "";
			for(var i=0;i<CheckVolumeFields.length;i++)
			{				
				
				tempVolumeObject = eval("document.all." + CheckVolumeFields[i]);
				tempVolumeObjectSpan	= eval("document.all." + SP_VolumeFields[i])
				
				Total_Product_Volume = Total_Product_Volume + parseInt(tempVolumeObject.value);
				sErr = checkThisVolume(tempVolumeObject.value);
				
				if(sErr.length > 0)
				{
					ErrorCount++;
					queueMessage(sErr, tempVolumeObjectSpan);
				}
				else 
				{
					clearQueue(tempVolumeObjectSpan);
				}
				
				/////check for volume cap field
				<cfif this.volumePacket.showVolumeCap>
				<cfif this.volumePacket.VolumeCapRequired>
				var volCapObj = eval("document.all.Volume_Cap_" + Field_Name_End[i]);
				var volCapErrObj = eval("document.all.Err_Volume_Cap_" + Field_Name_End[i]);
				sErr = checkThisVolume(volCapObj.value);
					
				if(sErr.length > 0)
				{
					ErrorCount++;
					queueMessage(sErr, volCapErrObj);
				}
				else 
				{
					clearQueue(volCapErrObj);
				}
				</cfif>
				</cfif>
			}
			
			var Contract_Quantity = <CFOUTPUT>#this.volumePacket.totalQuantity#</CFOUTPUT>;
			if(ErrorCount==0)
			{
				
				var checkVolume = true;
				//TSF: Label D6588
				/*TSF: Modified for volume paging
				<cfif this.volumePacket.canSaveTotalQuantity>
					<cfif NOT this.volumePacket.allProductsSelected>
					if(document.all.Save_Program_Volume.checked)
					{
						checkVolume = false;
					}
					<cfelse>
					checkVolume = false;
					</cfif>
				</cfif>
				
				
				<cfif this.volumePacket.avgQuantityApplicator>
				if(Contract_Quantity != Total_Product_Volume && checkVolume)
				{
					if(confirm("The total #this.volumePacket.appAreaKeyword# volume you have entered (" + Total_Product_Volume + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>) does not equal the calculated total #this.volumePacket.appAreaKeyword# volume (" + Contract_Quantity + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>). Press OK to continue or CANCEL to adjust."))
					{
						save_volume_submit(1);
					}
				}
				<cfelse>
				if(1==2)
				{
				}
				</cfif>
				else
				{
					save_volume_submit(1);
				}
				*/
				save_volume_submit(1,CloseStatus);
			}
			else
			{
				showMessageWindow();
			}
			return false;
		}
		
		function checkThisVolume(sVol)
		{
			var sErr = "";
			var iVol = parseFloat(sVol);
			if(isNaN(iVol))
			{
				sErr = "Invalid volume";
			}
			else if(sVol.length == 0)
			{
				sErr = "Enter a volume";
			}
			<!---If 1, allow there to be a zero volume--->
			<cfif this.volumePacket.ZeroVolume IS 0> 
			else if(iVol <= 0)
			{
				sErr = "Volume should be greater than zero";
			}
			</cfif>
			return sErr;
		}
		
		function save_volume_submit(bApply,CloseStatus)
		{
			opener.document.MyForm.action = "<CFOUTPUT>#Save_Template_Name#</CFOUTPUT>";
			opener.document.MyForm.bApply.value = bApply;
			opener.document.MyForm.Save_From_Edit.value = 1;
			opener.document.MyForm.submit();
			/*	If the user clicks on "save/close" option. Milan - 9607 */
			if(CloseStatus == 1){
			window.close();
			show_please_wait(document.all.Hide_For_Please_Wait);
			}
			
		}
		
		function cancel_volume()
		{
			opener.window.location.href = "<CFOUTPUT>#Parent_Template_Name#</CFOUTPUT>";
			window.close();
		}
		
		function adjustTableWidth()
		{
			adjustThisTD("TD_Checkbox");
			adjustThisTD("TD_Item");
			adjustThisTD("TD_Description");
			adjustThisTD("TD_Forecast_CS");
			adjustThisTD("TD_Forecast_LB");
			adjustThisTD("TD_Annual_CS");
			adjustThisTD("TD_Annual_LB");
			adjustThisTD("TD_Program_CS");
			adjustThisTD("TD_Program_LB");
			adjustThisTD("TD_Program_Error_CS");
			adjustThisTD("TD_Program_Error_LB");
			adjustThisTD("TD_Volume_Cap");
		}
		
		function adjustThisTD(TDName)
		{
			var tCells = document.getElementsByName(TDName);
			var i, tCellLen;
			tCellLen = tCells.length;
			if(tCellLen >= 2)
			{
				tCells[0].style.width = tCells[1].offsetWidth;
			}
			if(tCellLen >= 3)
			{
				tCells[tCellLen-1].style.width = tCells[1].offsetWidth;
			}
		}
		//TSF: Label D6588
		function setParentFormFields(oFormName, oFormVal)
		{
			if (opener.document.all.MyForm)
			{
				var openerFormObj = opener.document.all.MyForm;
				var thisForm = opener.document.all.MyForm;
				if (eval("openerFormObj." + oFormName))
				{
					var opnFrmFld = eval("openerFormObj." + oFormName);
					opnFrmFld.value = oFormVal;
				}
			}
		}
		//TSF: Label D6588
		function getParentVals(oFormName)
		{
			var rVal = 0;
			if (opener.document.all.MyForm)
			{
				var opnrFormObj = opener.document.all.MyForm;
				if (eval("opnrFormObj." + oFormName))
				{
					var opnFrmFldVal = eval("opnrFormObj." + oFormName + ".value");
					rVal = opnFrmFldVal;
				}
			}
			
			return rVal;
		}
		document.body.onload = new Function("adjustTableWidth();setDetailDivHeight();");
		document.body.onresize = new Function("setDetailDivHeight();");
		</SCRIPT>
		
		<FORM METHOD="post" ACTION="#This_Template_Name#" NAME="MyForm" STYLE="DISPLAY:INLINE;">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
		<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">		
		<INPUT TYPE="Hidden" NAME="packetId" VALUE="#this.packetId#">
		
		<TABLE border="0" cellspacing="1" cellpadding="2" CLASS="MainHead" WIDTH="#this.Window_Max_Width#" BGCOLOR="##ffce84">
		<cfif NOT this.volumePacket.volumeMultiplier OR this.forecastInfo.priorForecast>
		<TR VALIGN="top" BGCOLOR="White">
			<TD COLSPAN="3"></TD>
			<CFIF this.forecastInfo.priorForecast>
			<TD COLSPAN="2" ID="header" ALIGN="center" STYLE="border:none;">			
			<B>#DateFormat(this.forecastInfo.forecastFromDate, "mm/dd/yyyy")# - #DateFormat(this.forecastInfo.forecastToDate, "mm/dd/yyyy")# (#this.forecastInfo.forecastSpan#)</B>
			</TD>
			<TD COLSPAN="2"></TD>
			<CFELSE>
			<TD COLSPAN="2"></TD>
			</CFIF>			
			<TD COLSPAN="10" ID="header" ALIGN="center" STYLE="border:none;">
			<cfif NOT this.volumePacket.volumeMultiplier>
			<B>#DateFormat(this.volumePacket.appAreaStartDate, "mm/dd/yyyy")# - #DateFormat(this.volumePacket.appAreaEndDate, "mm/dd/yyyy")# (#this.volumePacket.appAreaSpan#)</B>
			</cfif>
			</TD>
		</TR>
		</cfif>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<TD ROWSPAN="2" align="center" ID="TD_Checkbox"><INPUT Name="allbox" TYPE="Checkbox" onclick="CHSelectAll('Ch_Product_Volume_', this.checked);" TITLE="Click here to select all Products"></TD>
			<TD ROWSPAN="2" align="left" ID="TD_Item">
				<cfset this.showSortString("groupName", "Group ")>
				<B>/</B><BR>
				<cfset this.showSortString("Item", "#application.returned_customer_setting.item_label# ##")>
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
				<B>/</B><BR>
				<cfset this.showSortString("UPC", "#application.returned_customer_setting.upc_label#")>
				</cfif></cfif>
				</TD>
			<TD ROWSPAN="2" align="left" ID="TD_Description">
			<cfset this.showSortString("Description", "Description")>
			</TD>			
			<CFIF this.forecastInfo.priorForecast>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>Historical Volume</B></TD>
			</CFIF>
			<cfif showAnnualVolume>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>Annual Volume</B></TD>
			</cfif>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>#this.defaultUOT.getDesc()# Volume</B></TD>
			<cfif this.volumePacket.showVolumeCap>
			<TD COLSPAN="1" STYLE="border-bottom:2px solid black;" align="center"><B>#this.defaultUOT.getDesc()# Cap</B></TD>
			</cfif>
		</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<CFIF this.forecastInfo.priorForecast>
			<cfif this.volumePacket.uom EQ 1>
			<TD ALIGN="right" ID="TD_Forecast_CS"><cfset this.showSortString("forecastVolume", "Case", "Historical Value")></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>Pound</B></TD>
			<cfelse>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><cfset this.showSortString("forecastVolume", "Pound", "Historical Value")></TD>
			</cfif>			
			</CFIF>
			<cfif showAnnualVolume>
			<TD ALIGN="right" ID="TD_Annual_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Annual_LB"><B>Pound</B></TD>
			</cfif>
			<TD ALIGN="right" ID="TD_Program_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Program_LB"><B>Pound</B></TD>
			<cfif this.volumePacket.showVolumeCap>
			<TD ALIGN="right" ID="TD_Volume_Cap">&nbsp;</TD>
			</cfif>
		</TR>
		</TABLE>
		<CFSET Volume_Col_Min_Width = 80>		
		</CFOUTPUT>
		<span ID="SP_Details" class="Scroll_Table_Body" STYLE="width:#Evaluate(this.Window_Max_Width+20)#px;height:100px;overflow:auto;border-bottom:1px solid ##93BEE2;">
		<TABLE border="0" cellspacing="1" cellpadding="2" CLASS="Maintable" WIDTH="#this.Window_Max_Width#" ID="Table_Product_List" BGCOLOR="##93BEE2">
		<script>
			var CheckVolumeFields = new Array();
			var SP_VolumeFields = new Array();
			var Field_Name_End = new Array();
		</script>
		
		<cfsilent>
		<CFSET Forecast_Total_CS = 0>
		<CFSET Forecast_Total_LB = 0>
		<CFSET Annual_Total_CS = 0>
		<CFSET Annual_Total_LB = 0>
		<CFSET Program_Total_CS = 0>
		<CFSET Program_Total_LB = 0>
		
		<cfset prodArray = this.volumePacket.products>
		<cfset prodArray = sortArrayOfStructs(prodArray, FORM.SORT_BY, FORM.SORT_ORDER)>
		<cfset prodLen = ArrayLen(prodArray)>
		<cfparam name="url.startElem" default="1" />
		<cfparam name="maxElem" default="250" />
		<!---handle for the last page of products--->
		<cfset endElem = Int(maxElem + url.startElem - 1) />
		<cfif endElem gt prodlen>
			<cfset endElem = prodlen />
		</cfif>
		<cfset anyGroupLevel_1 = this.volumePacket.allProductsSelected />
		<cfset n = 1 />
		</cfsilent>
		<!---if there are no products then display message--->
		<cfif prodLen eq 0>
			<tr ID="header" BGCOLOR="FFFFFF">
				<td ID="header"><b>There are no products for the selected groups.</b></td>
			</tr>
		</cfif>
		<cfloop index="i" from="#url.startElem#" to="#endElem#">
			<cfsilent>
			<cfif i gt 1>
				<cfset n = i - 1 />
			</cfif>
			<cfset BSA_Foodservice_Items_Master_ID 	= prodArray[i].productId>
			<cfset Net_Weight 							= prodArray[i].netWeight>
			<cfset Description 							= prodArray[i].description>
			<cfset Item		 							= prodArray[i].item>
			<cfset UPC		 							= prodArray[i].upc>
			<cfset productUOM							= prodArray[i].productUOM>
			<cfset productVolume 						= prodArray[i].productVolume>
			<cfset productGroupLevel 					= prodArray[i].productGroupLevel>
			<cfset forecastVolume 						= prodArray[i].forecastVolume>
			<cfset doneForecast							= prodArray[i].doneForecast>
			<cfset productVolumeCap						= prodArray[i].productVolumeCap>
			<cfset groupName							= prodArray[i].groupName>
			<cfset groupId								= prodArray[i].groupId>
			<cfset prevGroupId							= prodArray[n].groupId>
			</cfsilent>
			<cfif NOT anyGroupLevel_1 OR productGroupLevel EQ 1>
				<cfsilent>
				<CFSET FieldNameEnd = request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID)>
				<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
				<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">
				<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
				<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">
				<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
				<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">
				</cfsilent>
				<script>
					<cfif this.volumePacket.UOM EQ 1>
						CheckVolumeFields[CheckVolumeFields.length] = "#Input_CS_Name#";
						SP_VolumeFields[SP_VolumeFields.length] = "#Err_PS_CS_Name#";
						//FieldNameEnd
					<CFELSE>
						CheckVolumeFields[CheckVolumeFields.length] = "#Input_LB_Name#";
						SP_VolumeFields[SP_VolumeFields.length] = "#Err_PS_LB_Name#";
					</cfif>
					Field_Name_End[Field_Name_End.length] = "#FieldNameEnd#";
				</script>
				<cfsilent>
				<CFSET Annual_Volume_CS = "">
				<CFSET Annual_Volume_LB = "">
				<CFIF this.forecastInfo.priorForecast>
					<CFIF this.volumePacket.UOM EQ 1>
						<CFSET Forecast_Volume_CS 	= forecastVolume>
						<CFSET Forecast_Volume_LB 	= ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
					<CFELSE>
						<CFSET Forecast_Volume_LB 	= forecastVolume>
						<CFSET Forecast_Volume_CS 	= ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
					</CFIF>
				<CFELSE>
					<CFSET Forecast_Volume_CS = 0>
					<CFSET Forecast_Volume_LB = 0>
				</CFIF>
				<CFSET Volume_Good = true>
				<CFIF this.volumePacket.UOM EQ 1><!---- program UOM is CS ---->
					<CFIF this.action EQ "loadforecast"><!---- load from forecast table ---->
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_CS)#">
					<CFELSE>						
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#productVolume#">
					</CFIF>
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
					<CFIF This_Volume_CS NEQ 0 AND IsNumeric(This_Volume_CS)>
						<CFSET Annual_Volume_CS 			= ConvertToAnnualVolume(This_Volume_CS)>
						<CFSET Annual_Volume_LB 			= ConvertToAnnualVolume(This_Volume_LB)>
					</CFIF>
					
					<CFSET LB_Input_Class = Good_Input_Border>
					<CFSET CS_Input_Class = Good_Input_Border>
					<CFIF This_Volume_CS LTE 0>
						<CFSET CS_Input_Class = Bad_Input_Border>
						<CFSET Volume_Good = false>
					</CFIF>
				<CFELSE><!---- program UOM is LB ---->
					<CFIF this.action EQ "loadforecast">
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_LB)#">
					<CFELSE>
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#productVolume#">
					</CFIF>
					
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>					
					<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
					<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>
					
					<CFSET CS_Input_Class = Good_Input_Border>
					<CFSET LB_Input_Class = Good_Input_Border>
					<CFIF This_Volume_LB LTE 0>
						<CFSET LB_Input_Class = Bad_Input_Border>
						<CFSET Volume_Good = false>
					</CFIF>
				</CFIF>
				<!------ Volume Cap ----->	
				<CFSET Form_Name_Volume_Cap = "Volume_Cap_#FieldNameEnd#">
				<cfparam name="FORM.#Form_Name_Volume_Cap#" 	default="#productVolumeCap#">
				<cfset productVolumeCap = Evaluate("FORM.#Form_Name_Volume_Cap#") />
				<CFSET Volume_Cap_Input_Class = Good_Input_Border>
				<cfif this.volumePacket.VolumeCapRequired>
					<CFIF productVolumeCap LTE 0>
						<CFSET Volume_Cap_Input_Class = Bad_Input_Border>
					</CFIF> 
				</cfif>
				</cfsilent>
				<SCRIPT language="JavaScript">
					function changeCheckColor(thisObj)
					{
						var bgColor = "White";
						if(event.propertyName == "checked")
						{
							var trObj = getParentObject(thisObj, "tr");
							if(thisObj.checked)
							{
								bgColor = "##FFF7E5";
							}
							trObj.bgColor = bgColor;
						}
					}
				</SCRIPT>
		
				<cfif groupId neq prevGroupId or i eq 1>
					<tr ID="header" BGCOLOR="ccffcc">
						<td colspan="100%" ID="header"><b>#groupName#</b></td>
					</tr>
				</cfif>
				<TR VALIGN="top" <CFIF Volume_Good>BGCOLOR="white"<CFELSE>BGCOLOR="FFF7E5"</CFIF><CFIF this.forecastInfo.priorForecast AND NOT doneForecast> TITLE="This product is not part of the forecast"</CFIF>>
				
					<TD align="center" ID="TD_Checkbox"><span ID="checkBoxCollection"><INPUT onpropertychange="changeCheckColor(this);" type="Checkbox" NAME="Ch_Product_Volume_#FieldNameEnd#" VALUE="1" <CFIF NOT Volume_Good>checked</CFIF>></span></TD>
					<TD NOWRAP ID="TD_Item">
						#ITEM#<cfif Len(ITEM) EQ 0>#RepeatString("&nbsp;", 6)#</cfif>
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
						<BR>#UPC#
						</cfif></cfif>
					</TD>
					<TD ID="TD_Description">#Description#</TD>

					<CFIF this.forecastInfo.priorForecast>
					<TD valign="middle" ALIGN="right" ID="TD_Forecast_CS" WIDTH="#Volume_Col_Min_Width#" <CFIF doneForecast>STYLE="cursor:pointer;color:blue;" onClick="Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"</CFIF>><DIV ID="Forecast_cs_#FieldNameEnd#" STYLE="display:none">#Forecast_Volume_CS#</DIV><DIV style="display:inline;"><CFIF doneForecast>#this.FormatVolume(Forecast_Volume_CS)#<CFELSE><IMG SRC="/Images/exclamation_1.gif" title="This product is not part of the forecast"></CFIF></DIV>&nbsp;</TD>
					<TD valign="middle" ALIGN="right" ID="TD_Forecast_LB" WIDTH="#Volume_Col_Min_Width#" <CFIF doneForecast>STYLE="cursor:pointer;color:blue;" onClick="Show_Forecast_Details('#BSA_Foodservice_Items_Master_ID#');"</CFIF>><DIV ID="Forecast_lb_#FieldNameEnd#" STYLE="display:none">#Forecast_Volume_LB#</DIV><DIV style="display:inline;"><CFIF doneForecast>#this.FormatVolume(Forecast_Volume_LB)#<CFELSE><IMG SRC="/Images/exclamation_1.gif" title="This product is not part of the forecast"></CFIF></DIV>&nbsp;</TD>
					</CFIF>
					<cfif showAnnualVolume>
					<TD valign="middle" ALIGN="right" ID="TD_Annual_CS" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_cs_#FieldNameEnd#" previous_value="#this.FormatVolume(Annual_Volume_CS, 0)#" value="#this.FormatVolume(Annual_Volume_CS, 0)#">#this.FormatVolume(Annual_Volume_CS)#</DIV></TD>
					<TD valign="middle" ALIGN="right" ID="TD_Annual_LB" WIDTH="#Volume_Col_Min_Width#"><DIV CLASS="DIV_HIDE_OVERFLOW" STYLE="WIDTH:#Volume_Col_Min_Width#px;" ID="annual_lb_#FieldNameEnd#" previous_value="#this.FormatVolume(Annual_Volume_LB, 0)#" value="#this.FormatVolume(Annual_Volume_LB, 0)#">#this.FormatVolume(Annual_Volume_LB)#</DIV></TD>
					</CFIF>
					<TD valign="middle" ALIGN="right" ID="TD_Program_CS" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
						<SPAN ID="#Err_PS_CS_Name#">&nbsp;</SPAN>&nbsp;				
						<INPUT STYLE="text-align:right;width:#Evaluate(Volume_Col_Min_Width-9)#px;" CLASS="#CS_Input_Class#" SIZE="3" TYPE="Text" NAME="#Input_CS_Name#" VALUE="#this.FormatVolume(This_Volume_CS, 0)#" SIZE="10" onfocus="this.style.backgroundColor='##F0E68C'" onblur="this.style.backgroundColor='White'" ONKEYPRESS="javaScript: return Allow_Key_List('0123456789');" ONKEYUP="javaScript: Numeric_Key_Only(this, false, false);" onChange="change_Volume_UOM_Value(this);" pair_volume_field="#Input_LB_Name#" annual_pair="annual_cs_#FieldNameEnd#" Forecast_pair="Forecast_cs_#FieldNameEnd#" netweight="#Net_Weight#" current_uom="1" previous_value="#this.FormatVolume(This_Volume_CS, 0)#">
			
					</TD>
		
					<TD valign="middle" ALIGN="right" ID="TD_Program_LB" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
						<SPAN ID="#Err_PS_LB_Name#">&nbsp;</SPAN>&nbsp;
						<INPUT STYLE="text-align:right;width:#Evaluate(Volume_Col_Min_Width-9)#px;" CLASS="#LB_Input_Class#" SIZE="3" TYPE="Text" NAME="#Input_LB_Name#" VALUE="#this.FormatVolume(This_Volume_LB, 0)#" SIZE="10" onfocus="this.style.backgroundColor='##F0E68C'" onblur="this.style.backgroundColor='White'" ONKEYPRESS="javaScript: return Allow_Key_List('0123456789');" ONKEYUP="javaScript: Numeric_Key_Only(this, false, false);" onChange="change_Volume_UOM_Value(this);" pair_volume_field="#Input_CS_Name#" annual_pair="annual_lb_#FieldNameEnd#" Forecast_pair="Forecast_lb_#FieldNameEnd#" netweight="#Net_Weight#" current_uom="2" previous_value="#this.FormatVolume(This_Volume_LB, 0)#">			
						<script>
						<cfif this.volumePacket.uom eq 1>
							document.MyForm.#Input_CS_Name#.value = getParentVals('#Input_CS_Name#');
							change_Volume_UOM_Value(document.MyForm.#Input_CS_Name#);
						<cfelse>
							document.MyForm.#Input_LB_Name#.value = getParentVals('#Input_LB_Name#');
							change_Volume_UOM_Value(document.MyForm.#Input_LB_Name#);
						</cfif>
						</script>
					</TD>
					<cfif this.volumePacket.showVolumeCap>
					<TD valign="middle" ALIGN="right" ID="TD_Volume_Cap" WIDTH="#Evaluate(Volume_Col_Min_Width+20)#">
						<SPAN ID="Err_Volume_Cap_#FieldNameEnd#">&nbsp;</SPAN>&nbsp;
						<INPUT STYLE="text-align:right;width:#Evaluate(Volume_Col_Min_Width-9)#px;" CLASS="#Volume_Cap_Input_Class#" SIZE="3" TYPE="Text" NAME="#Form_Name_Volume_Cap#" <cfif isNumeric(productVolumeCap)>VALUE="#this.FormatVolume(productVolumeCap, 0)#"</cfif> SIZE="10" onfocus="this.style.backgroundColor='##F0E68C'" onblur="this.style.backgroundColor='White'" ONKEYPRESS="javaScript: return Allow_Key_List('0123456789');" ONKEYUP="javaScript: Numeric_Key_Only(this, false, false);" <cfif this.volumePacket.VolumeCapRequired>></cfif>onChange="Volume_Cap_Changed(this);">#productUOM#
						<script>
							document.MyForm.#Form_Name_Volume_Cap#.value = getParentVals('#Form_Name_Volume_Cap#');
						</script>
					</TD>
					</cfif>
				</TR>

				<cfsilent>
				<cfif anyGroupLevel_1 AND productGroupLevel EQ 1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= RoundVolume(This_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= This_Volume_LB>
					</CFIF>
				<cfelseif NOT anyGroupLevel_1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= Forecast_Total_CS + RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= Forecast_Total_LB + RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= Annual_Total_CS + RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= Annual_Total_LB + RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= Program_Total_CS + RoundVolume(This_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
					</CFIF>
				</cfif>
				</cfsilent>
				
			</cfif>
			
		</CFLOOP>
		<CFSET Program_Total_CS = Round(Program_Total_CS) />
		<CFSET Program_Total_LB = Round(Program_Total_LB) />
		</TABLE>		
		</span>
		<!---this is the paging section--->
		<table>
			<tr>
				<td>
					<cfset pages = Ceiling(prodLen / maxElem) />
					<cfparam name="nextStartPoint" default="1" />
					<cfparam name="isEnabled" default="1" />
					<cfloop index="index" from="1" to="#pages#">
						<cfset Paging_Template = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action","edit")#" />
						<cfset Paging_Template = "#Build_To_URL(Paging_Template, "startElem", nextStartPoint)#" />
						<cfset Paging_Template = "#Build_To_URL(Paging_Template, "SORT_BY", form.SORT_BY)#" />
						<cfset Paging_Template = "#Build_To_URL(Paging_Template, "SORT_ORDER", form.SORT_ORDER)#" />
						<cfset isEnabled = 1 />
						<cfif url.startElem eq nextStartPoint>
							<cfset isEnabled = 0 />
						</cfif>
						<CF_smallLink 
							title = "#index#" 
							url = "#Paging_Template#"
							parameters = ""
							enabled="#isEnabled#"
						>
						<cfset nextStartPoint = Int(nextStartPoint + maxElem) />
					</cfloop>
				</td>
			</tr>
		</table>
		<TABLE border="0" cellspacing="1" cellpadding="2" ID="Totals_TABLE" CLASS="MainHead" WIDTH="#this.Window_Max_Width#">
		<TR ID="header" VALIGN="top" BGCOLOR="##FFFFFF">
			<TD align="center" ID="TD_Checkbox" BGCOLOR="white">&nbsp;</TD>
			<TD align="left" ID="TD_Item" BGCOLOR="white">&nbsp;</TD>
			<TD align="right" ID="TD_Description" BGCOLOR="white"><B>Total volume :</B></TD>
			<CFIF this.forecastInfo.priorForecast>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>#this.FormatVolume(Forecast_Total_CS)#</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>#this.FormatVolume(Forecast_Total_LB)#</B></TD>
			</CFIF>
			<cfif showAnnualVolume>
			<TD ALIGN="right" ID="TD_Annual_CS"><DIV ID="DIV_Annual_Total_CS" total_value="#this.FormatVolume(Annual_Total_CS, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Annual_Total_CS)#</DIV></TD>
			<TD ALIGN="right" ID="TD_Annual_LB"><DIV ID="DIV_Annual_Total_LB" total_value="#this.FormatVolume(Annual_Total_LB, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Annual_Total_LB)#</TD>
			</cfif>
			<TD ALIGN="right" ID="TD_Program_CS"><DIV ID="DIV_Program_Total_CS" total_value="#this.FormatVolume(Program_Total_CS, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Program_Total_CS)#</DIV></TD>
			<TD ALIGN="right" ID="TD_Program_LB"><DIV ID="DIV_Program_Total_LB" total_value="#this.FormatVolume(Program_Total_LB, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Program_Total_LB)#</DIV></TD>
			<cfif this.volumePacket.showVolumeCap>
			<TD ALIGN="right" ID="TD_Volume_Cap">&nbsp;</TD>
			</cfif>
		</TR>
		</TABLE>
		<TABLE BORDER="0" WIDTH="#this.Window_Max_Width#" ID="Save_Link_TABLE" CELLPADDING="0" CELLSPACING="0">
			<TR VALIGN="top">
				<TD ROWSPAN="100%" WIDTH="15%">
				<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="border:1px ##00BFFF solid;" WIDTH="100%">
					<TR>
						<TD WIDTH="10">&nbsp;</TD>
						<TD><INPUT DISABLED TYPE="Text" CLASS="#Good_Input_Border#" STYLE="width:15px;height:10px;"></TD>
						<TD>&nbsp;&nbsp;&nbsp;<CFIF this.action EQ "loadforecast">Forcast volume. </CFIF>Valid volume</TD>
					</TR>
					<TR>
						<TD WIDTH="10">&nbsp;</TD>
						<TD><INPUT DISABLED TYPE="Text" CLASS="#Bad_Input_Border#" STYLE="width:15px;height:10px;"></TD>
						<TD>&nbsp;&nbsp;&nbsp;Invalid volume</TD>
					</TR>
				</TABLE>
				</TD>
				<TD COLSPAN="3" ALIGN="center" STYLE="color:##800000;font-size:11px;">
				<sup>*</sup>All values are rounded to the nearest whole number
				</TD>
			</TR>
			<!---TSF: Label D6588 --->
<!--- 		TSF: Removed for new volume
			<cfif this.volumePacket.canSaveTotalQuantity>
			<TR>
				<TD COLSPAN="3" ALIGN="center">
				<CFIF this.volumePacket.UOM EQ 1>
					<CFSET Total_Program_Volume = Program_Total_CS>
				<CFELSE>
					<CFSET Total_Program_Volume = Program_Total_LB>
				</CFIF>
				
				<CFSET Total_Program_Volume = Total_Program_Volume * (this.volumePacket.appAreaSpan / this.defaultUOT.getMultiplier()) />
				<cfif anyGroupLevel_1><INPUT TYPE="Hidden" NAME="Save_Program_Volume" VALUE="1"><INPUT TYPE="Checkbox" DISABLED CHECKED>
				<cfelse><INPUT TYPE="Checkbox" NAME="Save_Program_Volume" VALUE="1" CHECKED>
				</cfif>
				Save&nbsp;<DIV ID="DIV_Program_Volume" STYLE="DISPLAY:INLINE;font-weight:bold;">#this.FormatVolume(Total_Program_Volume)#</DIV>&nbsp;as #this.volumePacket.appAreaKeyword# quantity				
				</TD>
			</TR>
			</cfif> --->
			<TR>
				<TD ALIGN="right" WIDTH="33%">
					<INPUT TYPE="Hidden" NAME="bApply" VALUE="0">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="javascript:void(0);" onclick="save_volume(0);return false;"><FONT SIZE="2">save</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
				<TD ALIGN="center" WIDTH="33%">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="javascript:void(0);" onclick="save_volume(1);return false;"><FONT SIZE="2">save/close</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
				<TD ALIGN="left" WIDTH="33%">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="javascript:void(0);" onclick="cancel_volume();"><FONT SIZE="2">cancel</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
			</TR>
		</TABLE>
		<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
		var oDiv;
		function setDetailDivHeight()
		{
			oDiv = document.all.SP_Details;
			oDiv.style.height = getDetailsDivHeight();	
		}
		function getDetailsDivHeight()
		{
			var retunValue = "";
			var oTable_Product_List = document.all.Table_Product_List;
			var oRows = oTable_Product_List.rows;
			if(oRows.length > 0)
			{
				var lastRow = oRows[oRows.length-1];
				var lastRowTop = getTotalOffsetProperty(lastRow, "body", "offsetTop", 0);
				maxHeight = document.body.clientHeight;

				var oSave_Link_TABLE_offsetHeight = 0;
				var oSave_Link_TABLE = document.all.Save_Link_TABLE;
				var Totals_TABLE = document.all.Totals_TABLE;
					
				if(oSave_Link_TABLE)
				{
					oSave_Link_TABLE_offsetHeight = oSave_Link_TABLE_offsetHeight + oSave_Link_TABLE.offsetHeight;
				}
				if(Totals_TABLE)
				{
					oSave_Link_TABLE_offsetHeight = oSave_Link_TABLE_offsetHeight + Totals_TABLE.offsetHeight;
				}
				lastRowTop = lastRowTop + oSave_Link_TABLE_offsetHeight;
				maxHeight = maxHeight - oSave_Link_TABLE_offsetHeight - 20;
				
				if(lastRowTop < maxHeight)
				{
					maxHeight = lastRowTop;					
				}
				else
				{
					maxHeight = maxHeight;
				}
				
				getTotalOffsetProperty(oDiv, "body", "offsetTop", 0);
				retunValue = (maxHeight - getTotalOffsetProperty(oDiv, "body", "offsetTop", 0));
				var detailsTableHeight = oTable_Product_List.offsetHeight + 1;
				if(retunValue > detailsTableHeight)
				{
					retunValue = detailsTableHeight;
				}
				if(retunValue <=0)
				{
					retunValue = 30;
				}			
				retunValue = retunValue + "px";
			}
			return retunValue;
		}
		function Show_Forecast_Details(Product_ID)
		{
			event.returnValue = false;
			NewWindow('Volume_Forcast_Detail.cfm?PID=' + Product_ID + '&packetID=#this.packetId#', 'Forecast_Detail','750','600','Yes', 'Yes')
		}
		</SCRIPT>
		</FORM>
		</SPAN>
		
	</cffunction>	
	
	<!---TSF: Label D6588 --->
	<cffunction name="showGrandTotal" output="true" hint="showGrandTotal">
	
		<CFSET this.showPleaseWait(2)>
		<SPAN ID="Hide_For_Please_Wait">
		<cfparam name="form.Save_From_Forecast" default="0" />
		<cfif this.action EQ "loadforecast">
			<CFSET D_Temp = this.showForecastBasicInfo()>
			<CFSET this.showForecastSmallMenu(2)>
			<cfset form.Save_From_Forecast = 1 />
		<cfelse>
			<CFSET this.showForecastSmallMenu(3)>
		</cfif>
		<cfset showAnnualVolume = 1>
		<cfif this.volumePacket.showVolumeCap>
			<cfset showAnnualVolume = 0>
		</cfif>
		
		<CFSET This_Template_Name = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action", this.action)#">
		<CFSET Save_Template_Name = "Volume_Applicator_Action.cfm?#this.pass_url#">
		<cfset Edit_Template = "#CGI.SCRIPT_NAME#?#Build_To_URL(this.pass_url, "action","edit")#" />

		<cfset numNoVolume = 0 />
		<!---get a count of how many products don't have volume if zero volume is turned off--->
		<cfset zeroVolume = this.Volume_Packet_Builder.getZeroVolume() />
		<cfif not zeroVolume>
			<!---get a count of products with null or zero--->
			<CFSET numNoVolume = this.Volume_Packet_Builder.getProductsWithZeroVolume()>
		</cfif>
		<!---if volume isn't good then display count--->
		<cfif numNoVolume>
			<font color="red">
				<b>There #IIF(numNoVolume GT 1, DE('are'), DE('is'))# #numNoVolume# product#IIF(numNoVolume GT 1, DE('s'), DE(''))# without proper volume!</b>
			</font>
		</cfif>
		<STYLE>
			.MainHead TD
			{
				font-size: 12px;
			}
			.DIV_HIDE_OVERFLOW
			{
				overflow:hidden;
				display:inline;
			}
			TABLE.Maintable TD 
			{
				border:none;
			}
			.BlackBorder
			{
				border:1px solid black;
			}
			.RedBorder
			{
				border:1px solid red;
			}
			.BlueBorder
			{
				border:1px solid blue;
			}
			.GreenBorder
			{
				border:1px solid ##C71585;
			}
		</STYLE>
		<cfsilent>
		<CFSET Good_Input_Border = "BlackBorder">
		<CFSET Bad_Input_Border = "RedBorder">
		<CFIF this.action EQ "loadforecast">
			<CFSET Good_Input_Border = "BlueBorder">
		</CFIF>
		<CFSET Edited_Input_Border = "GreenBorder">
		</cfsilent>
		<cf_MessageWindow>
		<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
		<SCRIPT SRC="/Script/javascript/math_functions.js"></SCRIPT>
		<SCRIPT LANGUAGE="JavaScript">
		
		<!--- Retrieve global volumes requirements from the program template. ---->
		
		<cfset this.templatesettings = this.getTemplateVolume(this.volumePacket.AppAreaID)>
		<cfset this.VolumeMessageSettings = this.getMessageSettings(this.volumePacket.AppAreaID)>
		
		function replaceCharacters(conversionString,inChar,outChar)
		{
		  var convertedString = conversionString.split(inChar);
		  convertedString = convertedString.join(outChar);
		  return convertedString;
		}

		function save_volume()
		{
			event.returnValue = false;
			var Total_Product_Volume = 0;
			var ErrorCount = 0;
			var sErr = "";
			
			var program_lbs = 0;
			var program_cs = 0;
			var program_volume = 0;
			
			program_cs = replaceCharacters(DIV_Program_Total_CS.innerText,",","");			
			program_lbs = replaceCharacters(DIV_Program_Total_LB.innerText,",","");
			program_volume = replaceCharacters(DIV_Program_Volume.innerText,",","");
										
			program_cs = parseInt(program_cs);
			if(isNaN(program_cs)){
				program_cs = 0;}		
			
			program_lbs = parseInt(program_lbs);
			if(isNaN(program_lbs)){
				program_lbs = 0;}
		
			program_volume = parseInt(program_volume);
			if(isNaN(program_volume)){
				program_volume = 0;}
		
		
			var Contract_Quantity = <CFOUTPUT>#this.volumePacket.totalQuantity#</CFOUTPUT>;
			if(ErrorCount==0)
			{
				var checkVolume = true;
				<cfif this.volumePacket.canSaveTotalQuantity>
					<cfif NOT this.volumePacket.allProductsSelected>
					if(document.all.Save_Program_Volume.checked)
					{
						checkVolume = false;
					}
					<cfelse>
					checkVolume = false;
					</cfif>
				</cfif>
				
				<cfif this.templatesettings.Max_Global_Volume>
					<cfif this.volumePacket.UOM EQ 1>
						<!--- if (Total_Product_Volume > #this.templatesettings.Max_Global_Volume_Size_CS#){--->
						if ( program_cs > #this.templatesettings.Max_Global_Volume_Size_CS#){
							//check the totalvolume vs the template volume limit for cases
							alert("The total <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume you have entered (" + program_cs + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>) exceeds the template maximum <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume of <CFOUTPUT>#this.templatesettings.Max_Global_Volume_Size_CS#</CFOUTPUT>.\nPlease adjust the volume accordingly.");
							return false;
						}
					<cfelse>
						if ( program_lbs > #this.templatesettings.Max_Global_Volume_Size_LBS#){
							//check the totalvolume vs the template volume limit for lbs
							alert("The total <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume you have entered (" + program_lbs + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>) exceeds the template maximum <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume of <CFOUTPUT>#this.templatesettings.Max_Global_Volume_Size_LBS#</CFOUTPUT>.\nPlease adjust the volume accordingly.");
							return false;
						}
					</cfif>
				</cfif>
				
				<cfif this.templatesettings.Min_Global_Volume>
					<cfif this.volumePacket.UOM EQ 1>
						if ( program_cs < #this.templatesettings.Min_Global_Volume_Size_CS#){
							//check the totalvolume vs the template volume limit for cases
							alert("The total <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume you have entered (" + program_cs + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>) is less than the template minimum <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume of <CFOUTPUT>#this.templatesettings.Min_Global_Volume_Size_CS#</CFOUTPUT>.\nPlease adjust the volume accordingly.");
							return false;
						}
						
					<cfelse>
						if ( program_lbs < #this.templatesettings.Min_Global_Volume_Size_LBS#){
							//check the totalvolume vs the template volume limit for lbs
							alert("The total <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume you have entered (" + program_lbs + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>) is less than the template minimum <CFOUTPUT>#this.volumePacket.appAreaKeyword#</CFOUTPUT> volume of <CFOUTPUT>#this.templatesettings.Min_Global_Volume_Size_LBS#</CFOUTPUT>.\nPlease adjust the volume accordingly.");
							return false;
							}
					</cfif>
				</cfif>
				
				<cfif this.volumePacket.avgQuantityApplicator>
				if(Contract_Quantity != program_volume && checkVolume)
				{
					if(confirm("The total #this.volumePacket.appAreaKeyword# volume you have entered (" + program_volume + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>) does not equal the calculated total #this.volumePacket.appAreaKeyword# volume (" + Contract_Quantity + " <CFOUTPUT>#this.volumePacket.uomDesc#</CFOUTPUT>). Press OK to continue or CANCEL to adjust."))
					{
						save_volume_submit(1,1);
					}
				}
				<cfelse>
				if(1==2)
				{
				}
				</cfif>
				else
				{
					save_volume_submit(1,1);
				}
			}
			else
			{
				showMessageWindow();
			}
			return false;
		}
		
		function checkThisVolume(sVol)
		{
			var sErr = "";
			var iVol = parseFloat(sVol);
			if(sVol.length == 0)
			{
				sErr = "Enter a volume";
			}
			else if(isNaN(iVol))
			{
				sErr = "Invalid volume";
			}
			<!---If 1, allow there to be a zero volume--->
			<cfif this.volumePacket.ZeroVolume IS 0> 
			else if(iVol <= 0)
			{
				sErr = "Volume should be greater than zero";
			}
			</cfif>
			return sErr;
		}
		
		/* The function has a second argument "CloseStatus" which does nothing. I added that argument here bcoz there is another
			function with the same name, which needed to be changed and I do not know which function call is going to which function 
			Milan - 9607 */
		function save_volume_submit(bApply,CloseStatus)
		{
			document.MyForm.action = "<CFOUTPUT>#Save_Template_Name#</CFOUTPUT>";
			document.MyForm.bApply.value = bApply;
			document.MyForm.submit();
			show_please_wait(document.all.Hide_For_Please_Wait);
		}
		
		function edit_volume()
		{
			window.open('#Edit_Template#','EditWindow','width=825,height=700,top=0,left=100,scrollbars=no,resizable=no');
		}

		function VolumeMessageWindow()
		{
		winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no'
		window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#this.volumePacket.AppAreaID#&Volume=1","VolumeMessageWindow",winprops);
		}
		
		function adjustTableWidth()
		{
			adjustThisTD("TD_Description");
			adjustThisTD("TD_Forecast_CS");
			adjustThisTD("TD_Forecast_LB");
			adjustThisTD("TD_Annual_CS");
			adjustThisTD("TD_Annual_LB");
			adjustThisTD("TD_Program_CS");
			adjustThisTD("TD_Program_LB");
			adjustThisTD("TD_Program_Error_CS");
			adjustThisTD("TD_Program_Error_LB");
			adjustThisTD("TD_Volume_Cap");
		}
		
		function adjustThisTD(TDName)
		{
			var tCells = document.getElementsByName(TDName);
			var i, tCellLen;
			tCellLen = tCells.length;
			if(tCellLen >= 2)
			{
				tCells[0].style.width = tCells[1].offsetWidth;
			}
			if(tCellLen >= 3)
			{
				tCells[tCellLen-1].style.width = tCells[1].offsetWidth;
			}
		}
		document.body.onload = new Function("adjustTableWidth();");
		</SCRIPT>
		
		<FORM METHOD="post" ACTION="#This_Template_Name#" NAME="MyForm" STYLE="DISPLAY:INLINE;">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
		<INPUT TYPE="Hidden" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">		
		<INPUT TYPE="Hidden" NAME="packetId" VALUE="#this.packetId#">
		<INPUT TYPE="Hidden" NAME="Save_From_Forecast" VALUE="#form.Save_From_Forecast#">
		
		<TABLE border="0" cellspacing="1" cellpadding="2" CLASS="MainHead" WIDTH="#this.Window_Max_Width#" BGCOLOR="##ffce84">
		<cfif NOT this.volumePacket.volumeMultiplier OR this.forecastInfo.priorForecast>
		<TR VALIGN="top" BGCOLOR="White">
			<TD rowspan="4" align="right" BGCOLOR="white" valign="bottom" STYLE="border:none;">
				<B>Total volume :</B>
			</TD>
			<CFIF this.forecastInfo.priorForecast>
			<TD COLSPAN="2" ID="header" ALIGN="center" STYLE="border:none;">			
			<B>#DateFormat(this.forecastInfo.forecastFromDate, "mm/dd/yyyy")# - #DateFormat(this.forecastInfo.forecastToDate, "mm/dd/yyyy")# (#this.forecastInfo.forecastSpan#)</B>
			</TD>
			<TD COLSPAN="2"></TD>
			<CFELSE>
			<TD COLSPAN="2"></TD>
			</CFIF>			
			<TD COLSPAN="10" ID="header" ALIGN="center" STYLE="border:none;">
			<cfif NOT this.volumePacket.volumeMultiplier>
			<B>#DateFormat(this.volumePacket.appAreaStartDate, "mm/dd/yyyy")# - #DateFormat(this.volumePacket.appAreaEndDate, "mm/dd/yyyy")# (#this.volumePacket.appAreaSpan#)</B>
			</cfif>
			</TD>
		</TR>
		</cfif>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">			
			<CFIF this.forecastInfo.priorForecast>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>Historical Volume</B></TD>
			</CFIF>
			<cfif showAnnualVolume>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>Annual Volume</B></TD>
			</cfif>
			<TD COLSPAN="2" STYLE="border-bottom:2px solid black;" align="center"><B>#this.defaultUOT.getDesc()# Volume</B></TD>
			<cfif this.volumePacket.showVolumeCap>
			<TD COLSPAN="1" STYLE="border-bottom:2px solid black;" align="center"><B>#this.defaultUOT.getDesc()# Cap</B></TD>
			</cfif>
		</TR>
		<TR ID="header" BGCOLOR="##ffce84" VALIGN="bottom">
			<CFIF this.forecastInfo.priorForecast>
			<cfif this.volumePacket.uom EQ 1>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>Pound</B></TD>
			<cfelse>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>Pound</B></TD>
			</cfif>			
			</CFIF>
			<cfif showAnnualVolume>
			<TD ALIGN="right" ID="TD_Annual_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Annual_LB"><B>Pound</B></TD>
			</cfif>
			<TD ALIGN="right" ID="TD_Program_CS"><B>Case</B></TD>
			<TD ALIGN="right" ID="TD_Program_LB"><B>Pound</B></TD>
			<cfif this.volumePacket.showVolumeCap>
			<TD ALIGN="right" ID="TD_Volume_Cap">&nbsp;</TD>
			</cfif>
		</TR>
		<CFSET Volume_Col_Min_Width = 80>		
		</CFOUTPUT>

		<script>
			var CheckVolumeFields = new Array();
			var SP_VolumeFields = new Array();
			var Field_Name_End = new Array();
		</script>
		
		<cfsilent>
		<CFSET Forecast_Total_CS = 0>
		<CFSET Forecast_Total_LB = 0>
		<CFSET Annual_Total_CS = 0>
		<CFSET Annual_Total_LB = 0>
		<CFSET Program_Total_CS = 0>
		<CFSET Program_Total_LB = 0>
		
		<cfset prodArray = this.volumePacket.products>
		<cfset prodArray = sortArrayOfStructs(prodArray, FORM.SORT_BY, FORM.SORT_ORDER)>
		<cfset prodLen = ArrayLen(prodArray)>
		
		<cfset anyGroupLevel_1 = this.volumePacket.allProductsSelected />
		<cfset n = 1 />
		</cfsilent>
		<!---if there are no products then display message--->
		<cfif prodLen eq 0>
			<tr ID="header" BGCOLOR="FFFFFF">
				<td ID="header"><b>There are no products for the selected groups.</b></td>
			</tr>
		</cfif>

		<cfloop index="i" from="1" to="#prodLen#">

			<cfsilent>
			<cfif i gt 1>
				<cfset n = i - 1 />
			</cfif>
			
			<cfset BSA_Foodservice_Items_Master_ID 	= prodArray[i].productId>
			<cfset Net_Weight 							= prodArray[i].netWeight>
			<cfset Description 							= prodArray[i].description>
			<cfset Item		 							= prodArray[i].item>
			<cfset UPC		 							= prodArray[i].upc>
			<cfset productUOM							= prodArray[i].productUOM>
			
			<cfset productVolume 						= prodArray[i].productVolume>
			<cfset productGroupLevel 					= prodArray[i].productGroupLevel>
			<cfset forecastVolume 						= prodArray[i].forecastVolume>
			<cfset doneForecast							= prodArray[i].doneForecast>
			<cfset productVolumeCap						= prodArray[i].productVolumeCap>
			<cfset groupName							= prodArray[i].groupName>
			<cfset groupId								= prodArray[i].groupId>
			<cfset prevGroupId							= prodArray[n].groupId>
			</cfsilent><cfif NOT anyGroupLevel_1 OR productGroupLevel EQ 1><cfsilent>
				<CFSET FieldNameEnd = request.app_general_functions.replaceHyphen(BSA_Foodservice_Items_Master_ID)>
				<CFSET Input_CS_Name = "Product_Volume_#FieldNameEnd#_CS">
				<CFSET Input_LB_Name = "Product_Volume_#FieldNameEnd#_LB">
				
				<CFSET Forecast_Volume_CS = "Forecast_Volume_#FieldNameEnd#_CS">
				<CFSET Forecast_Volume_LB = "Forecast_Volume_#FieldNameEnd#_LB">
				
				<CFSET Err_PS_CS_Name = "error_Vol_#FieldNameEnd#_cs">
				<CFSET Err_PS_LB_Name = "error_Vol_#FieldNameEnd#_lb">
				</cfsilent>
				<script><cfif this.volumePacket.UOM EQ 1>
						CheckVolumeFields[CheckVolumeFields.length] = "#Input_CS_Name#";
						SP_VolumeFields[SP_VolumeFields.length] = "#Err_PS_CS_Name#";						
					<CFELSE>
						CheckVolumeFields[CheckVolumeFields.length] = "#Input_LB_Name#";
						SP_VolumeFields[SP_VolumeFields.length] = "#Err_PS_LB_Name#";
					</cfif>Field_Name_End[Field_Name_End.length] = "#FieldNameEnd#";
				</script>
				<cfsilent>
				<CFSET Annual_Volume_CS = "">
				<CFSET Annual_Volume_LB = "">
				<CFIF this.forecastInfo.priorForecast>
					<CFIF this.volumePacket.UOM EQ 1>
						<CFSET Forecast_Volume_CS 	= forecastVolume>
						<CFSET Forecast_Volume_LB 	= ConvertToUOM(Forecast_Volume_CS, 2, Net_Weight)>
					<CFELSE>
						<CFSET Forecast_Volume_LB 	= forecastVolume>
						<CFSET Forecast_Volume_CS 	= ConvertToUOM(Forecast_Volume_LB, 1, Net_Weight)>
					</CFIF>
				<CFELSE>
					<CFSET Forecast_Volume_CS = 0>
					<CFSET Forecast_Volume_LB = 0>
				</CFIF>
				<CFSET Volume_Good = true>
				<CFIF this.volumePacket.UOM EQ 1><!---- program UOM is CS ---->
					
					<CFIF this.action EQ "loadforecast"><!---- load from forecast table ---->
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_CS)#">
					<CFELSE>						
						<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#productVolume#">
					</CFIF>
					
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_CS, 2, Net_Weight)#">
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>
					<CFIF This_Volume_CS NEQ 0 AND IsNumeric(This_Volume_CS)>
						<CFSET Annual_Volume_CS 			= ConvertToAnnualVolume(This_Volume_CS)>
						<CFSET Annual_Volume_LB 			= ConvertToAnnualVolume(This_Volume_LB)>
					</CFIF>
					
					<CFSET LB_Input_Class = Good_Input_Border>
					<CFSET CS_Input_Class = Good_Input_Border>
					<CFIF This_Volume_CS LTE 0>
						<CFSET CS_Input_Class = Bad_Input_Border>
						<CFSET Volume_Good = false>
					</CFIF>
				<CFELSE><!---- program UOM is LB ---->
					<CFIF this.action EQ "loadforecast">
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#ConvertToProgramVolume(Forecast_Volume_LB)#">
					<CFELSE>
						<CFPARAM NAME="FORM.#Input_LB_Name#" 	DEFAULT="#productVolume#">
					</CFIF>
					
					<CFSET This_Volume_LB 					= Evaluate("FORM.#Input_LB_Name#")>					
					<CFPARAM NAME="FORM.#Input_CS_Name#" 	DEFAULT="#ConvertToUOM(This_Volume_LB, 1, Net_Weight)#">
					<CFSET This_Volume_CS 					= Evaluate("FORM.#Input_CS_Name#")>
					<CFSET Annual_Volume_CS 				= ConvertToAnnualVolume(This_Volume_CS)>
					<CFSET Annual_Volume_LB 				= ConvertToAnnualVolume(This_Volume_LB)>
					
					<CFSET CS_Input_Class = Good_Input_Border>
					<CFSET LB_Input_Class = Good_Input_Border>
					<CFIF This_Volume_LB LTE 0>
						<CFSET LB_Input_Class = Bad_Input_Border>
						<CFSET Volume_Good = false>
					</CFIF>
				</CFIF>
				<!------ Volume Cap ----->	
				<CFSET Form_Name_Volume_Cap = "Volume_Cap_#FieldNameEnd#">
				<cfparam name="FORM.#Form_Name_Volume_Cap#" 	default="#productVolumeCap#">
				<cfset productVolumeCap = Evaluate("FORM.#Form_Name_Volume_Cap#") />
				<CFSET Volume_Cap_Input_Class = Good_Input_Border>
				<cfif this.volumePacket.VolumeCapRequired>
					<CFIF productVolumeCap LTE 0>
						<CFSET Volume_Cap_Input_Class = Bad_Input_Border>
					</CFIF> 
				</cfif>
				</cfsilent>
				<INPUT TYPE="hidden" NAME="#Input_CS_Name#" VALUE="#this.FormatVolume(This_Volume_CS, 0)#">
				<INPUT TYPE="hidden" NAME="#Input_LB_Name#" VALUE="#this.FormatVolume(This_Volume_LB, 0)#">
				<cfsilent>
                <!--- D17577 RBL 11/20/08 [begin] ...
				thought:
				<cfif isNumeric(productVolumeCap) AND productVolumeCap>TYPE="Text"<cfelse>TYPE="Hidden"</cfif>
				inserted the following instead:
				#iif(isNumeric(productVolumeCap) AND productVolumeCap,de("TYPE='Text'"),de("TYPE='Hidden'"))#
				and modified the following:
				<cfif isNumeric(productVolumeCap)>VALUE="#this.FormatVolume(productVolumeCap, 0)#"</cfif>
				as the following:
				#iif(isNumeric(productVolumeCap),de("VALUE='#this.FormatVolume(productVolumeCap, 0)#'"),de(""))#
				D17577 RBL 11/20/08 [end] --->
				</cfsilent><cfif this.volumePacket.showVolumeCap><!--- D17577 RBL 11/20/08 [begin] ---><INPUT NAME="#Form_Name_Volume_Cap#" #iif(isNumeric(productVolumeCap) AND productVolumeCap,de("TYPE='Text'"),de("TYPE='Hidden'"))# #iif(isNumeric(productVolumeCap),de("VALUE='#this.FormatVolume(productVolumeCap, 0)#'"),de(""))# /><!--- D17577 RBL 11/20/08 [end] ---></cfif><cfsilent>
				<cfif anyGroupLevel_1 AND productGroupLevel EQ 1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= RoundVolume(This_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= This_Volume_LB>
					</CFIF>
				<cfelseif NOT anyGroupLevel_1>
					<CFIF IsNumeric(Forecast_Volume_CS)>
						<CFSET Forecast_Total_CS 	= Forecast_Total_CS + RoundVolume(Forecast_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Forecast_Volume_LB)>
						<CFSET Forecast_Total_LB 	= Forecast_Total_LB + RoundVolume(Forecast_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_CS)>
						<CFSET Annual_Total_CS 		= Annual_Total_CS + RoundVolume(Annual_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(Annual_Volume_LB)>
						<CFSET Annual_Total_LB 		= Annual_Total_LB + RoundVolume(Annual_Volume_LB)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_CS)>
						<CFSET Program_Total_CS 	= Program_Total_CS + RoundVolume(This_Volume_CS)>
					</CFIF>
					<CFIF IsNumeric(This_Volume_LB)>
						<CFSET Program_Total_LB 	= Program_Total_LB + This_Volume_LB>
					</CFIF>
				</cfif>
		</cfsilent></cfif></CFLOOP>
		<CFSET Program_Total_CS = Round(Program_Total_CS) />
		<CFSET Program_Total_LB = Round(Program_Total_LB) />
		<TR ID="header" VALIGN="top" BGCOLOR="##FFFFFF">
			<CFIF this.forecastInfo.priorForecast>
			<TD ALIGN="right" ID="TD_Forecast_CS"><B>#this.FormatVolume(Forecast_Total_CS)#</B></TD>
			<TD ALIGN="right" ID="TD_Forecast_LB"><B>#this.FormatVolume(Forecast_Total_LB)#</B></TD>
			</CFIF>
			<cfif showAnnualVolume>
			<TD ALIGN="right" ID="TD_Annual_CS"><DIV ID="DIV_Annual_Total_CS" total_value="#this.FormatVolume(Annual_Total_CS, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Annual_Total_CS)#</DIV></TD>
			<TD ALIGN="right" ID="TD_Annual_LB"><DIV ID="DIV_Annual_Total_LB" total_value="#this.FormatVolume(Annual_Total_LB, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Annual_Total_LB)#</TD>
			</cfif>
			<TD ALIGN="right" ID="TD_Program_CS"><DIV ID="DIV_Program_Total_CS" total_value="#this.FormatVolume(Program_Total_CS, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Program_Total_CS)#</DIV></TD>
			<TD ALIGN="right" ID="TD_Program_LB"><DIV ID="DIV_Program_Total_LB" total_value="#this.FormatVolume(Program_Total_LB, 0)#" STYLE="font-weight:bold;">#this.FormatVolume(Program_Total_LB)#</DIV></TD>
			<cfif this.volumePacket.showVolumeCap>
			<TD ALIGN="right" ID="TD_Volume_Cap">&nbsp;</TD>
			</cfif>
		</TR>
		</TABLE>
		<TABLE BORDER="0" WIDTH="#this.Window_Max_Width#" ID="Save_Link_TABLE" CELLPADDING="0" CELLSPACING="0">
			<TR VALIGN="top">
				<TD ROWSPAN="100%" WIDTH="200" align="right">&nbsp;
				</TD>
				<TD COLSPAN="3" ALIGN="center" STYLE="color:##800000;font-size:11px;">
				<sup>*</sup>All values are rounded to the nearest whole number
				</TD>
			</TR>
			<cfif this.volumePacket.canSaveTotalQuantity>
			<TR>
				<TD COLSPAN="3" ALIGN="center">
				<CFIF this.volumePacket.UOM EQ 1>
					<CFSET Total_Program_Volume = Program_Total_CS>
				<CFELSE>
					<CFSET Total_Program_Volume = Program_Total_LB>
				</CFIF>
				
				<CFSET Total_Program_Volume = Total_Program_Volume * (this.volumePacket.appAreaSpan / this.defaultUOT.getMultiplier()) />
				<cfif anyGroupLevel_1><INPUT TYPE="Hidden" NAME="Save_Program_Volume" VALUE="1"><INPUT TYPE="Checkbox" DISABLED CHECKED>
				<cfelse><INPUT TYPE="Checkbox" NAME="Save_Program_Volume" VALUE="1" CHECKED>
				</cfif>
				Save&nbsp;<DIV ID="DIV_Program_Volume" STYLE="DISPLAY:INLINE;font-weight:bold;">#this.FormatVolume(Total_Program_Volume)#</DIV>&nbsp;as #this.volumePacket.appAreaKeyword# quantity				
				</TD>
			</TR>
			</cfif>
			<TR>
				<TD width="25%" align="middle">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="##" onclick="<cfif this.VolumeMessageSettings.Message_Settings eq 1>VolumeMessageWindow();<cfelse>edit_volume();</cfif>return false;"><FONT SIZE="2">edit</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
				<TD align="middle" WIDTH="25%">
					<INPUT TYPE="Hidden" NAME="bApply" VALUE="0">
					<INPUT TYPE="Hidden" NAME="Save_From_Edit" VALUE="0">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="void(0);" onclick="save_volume();return false;"><FONT SIZE="2">apply</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
				<TD align="middle" WIDTH="25%">
					<B><FONT SIZE="2" COLOR="FF0000">[</FONT> <a HREF="void(0);" onclick="save_volume_submit(0,1);return false;"><FONT SIZE="2">close</FONT></a> <FONT SIZE="2" COLOR="FF0000">]</FONT></B>
				</TD>
			</TR>
		</TABLE>
		</FORM>
		</SPAN>

	</cffunction>
	
	<!----------------- saveProductVolume() -------------------->
	<cffunction name="saveProductVolume" output="true" hint="saveProductVolume">
		
		<CFPARAM NAME="FORM.Save_Program_Volume" 	DEFAULT="0">
		<CFPARAM NAME="FORM.Save_From_Edit" 		DEFAULT="0">
		<CFPARAM NAME="FORM.Save_From_Forecast" 		DEFAULT="0">
		<cfset this.volumePacket.saveTotalVolume = FORM.Save_Program_Volume>
		
		<!---if Zero Volume is not allowed then get the number of items that have zero volume--->
		<cfset bZeroVolume = this.Volume_Packet_Builder.getZeroVolume() />
		<cfif not bZeroVolume>
			<cfset this.Volume_Packet_Builder.setProductsWithZeroVolume(0) />
			<cfset zeroVolCount = 0 />
		</cfif>
		
		<cfif form.bApply EQ 1>
			<cfset this.volumePacket.volumeAction			= "apply">
			<!---update volume in volume packet only if we are saving from edit mode--->
			<cfif FORM.Save_From_Edit eq 1 or FORM.Save_From_Forecast eq 1>
				<!---- save product volume ---->
				<cfset prodArray = this.volumePacket.products>
				<cfset prodLen = ArrayLen(prodArray)>
				
				<cfloop index="i" from="1" to="#prodLen#">
					<cfset FieldNameEnd = request.app_general_functions.replaceHyphen(prodArray[i].productId)>
					<cfif this.volumePacket.UOM EQ 1>
						<cfset This_Volume_Field = "Product_Volume_#FieldNameEnd#_CS">
					<cfelse>
						<cfset This_Volume_Field = "Product_Volume_#FieldNameEnd#_LB">
					</cfif>
					<cfif isDefined("FORM.#This_Volume_Field#")>
						<cfset thisVolume = Evaluate("FORM.#This_Volume_Field#")>
						<cfset prodArray[i].productVolume = thisVolume>
					</cfif>
					
					<cfif isDefined("FORM.Volume_Cap_#FieldNameEnd#")>
						<cfset thisVolumeCap = Evaluate("FORM.Volume_Cap_#FieldNameEnd#")>
						<cfset prodArray[i].productVolumeCap = thisVolumeCap>
					</cfif>
					
					<cfif not bZeroVolume>
						<cfif not isNumeric(prodArray[i].productVolume) or prodArray[i].productVolume lte 0>
							<cfset zeroVolCount = zeroVolCount + 1 />
						</cfif>
					</cfif>
				</cfloop>
				
				<cfif not bZeroVolume>
					<cfset this.Volume_Packet_Builder.setProductsWithZeroVolume(zeroVolCount) />
				</cfif>
				
			</cfif>
		<cfelse>
			<cfset this.volumePacket.volumeAction			= "cancel">
		</cfif>

		<cfscript>
			this.Volume_Packet_Builder.volumePacket = this.volumePacket;
			this.packetId = this.Volume_Packet_Builder.saveVolumePacket();
		</cfscript>
		<cfif FORM.Save_From_Edit eq 1>
			<script>
				<cfoutput>window.location.href="/Common_Files/Volume/Volume_Applicator.cfm?packetId=#this.packetId#&action=list&Contract_ID=#this.volumePacket.AppAreaID#";</cfoutput>
			</script>
		<cfelse>
			<script>
				<cfoutput>window.location.href="#this.volumePacket.appAreaReturnToFile#?packetId=#this.packetId#&Contract_ID=#this.volumePacket.AppAreaID#";</cfoutput>
			</script>
		</cfif>

	</cffunction>
	
	
	<!----------------- showForecastDetail() -------------------->
	<cffunction name="showForecastDetail" output="true" hint="showForecastDetail">
		<cfargument name="productId" type="string" required="true" default="">
		<cfset productId = arguments.productId>
		
		<cfset useLakebaseForGet_Product_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGet_Product_Info>
	<cftry>
		<cfset Get_Product_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#productId#",
				"select" = "item,upc,description"
			}), "item,upc,description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Product_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Product_Info>
<CFQUERY NAME="Get_Product_Info" DATASOURCE="#application.datasource#">
			SELECT	Item, UPC, Description
			FROM	BSA_Foodservice_Items_Master
			WHERE
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#productId#'
		</CFQUERY>
</cfif>
		
		<cfquery name="get_Distributor_Invoice_Value" datasource="#application.datasource#">
			SELECT	Product_Customer_Group.Cases_Invoiced AS Volume_CS,
					Product_Customer_Group.Pounds_Invoiced AS Volume_LB,
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, 
					BSA_Foodservice_Customers.Name, 
					BSA_Foodservice_Customers.Ship_To
			FROM 	Forecast_Distributor					
					INNER JOIN Product_Customer_Group ON
					Product_Customer_Group.Customer_ID = Forecast_Distributor.Distributor_ID
					AND Product_Customer_Group.Product_ID = '#productId#'
					LEFT JOIN BSA_Foodservice_Customers ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Forecast_Distributor.Distributor_ID
					AND BSA_Foodservice_Customers.Deleted = 0
			WHERE 	Forecast_ID = #this.volumePacket.forecastId#
			ORDER BY Volume_CS DESC
		</cfquery>
		
		<SCRIPT LANGUAGE="JavaScript">
		function Show_Invoice_Details(Dist_ID)
		{
			NewWindow('Volume_Invoice_Detail.cfm?PID=#productId#&packetID=#this.packetId#&DID=' + Dist_ID, 'Forecast_Invoice_Detail','700','500','Yes', 'Yes')
			return false;
		}
		</SCRIPT>
		<SPAN CLASS="Title3" STYLE="font-weight:bold;">Product: <SPAN STYLE="font-weight:normal;">#Get_Product_Info.Item# - #Get_Product_Info.UPC# - #Get_Product_Info.Description#</SPAN></SPAN>
		<CFIF get_Distributor_Invoice_Value.RecordCount GT 0>
			<CFSET Total_Volume_CS = 0>
			<CFSET Total_Volume_LB = 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="90%">
			<TR BGCOLOR="##FFCE84" VALIGN="bottom">
				<TD>&nbsp;</TD>
				<TD ID="header" NOWRAP width="75"><B>#application.returned_customer_setting.shard_ship_to_label#</B></TD>
				<TD ID="header" WIDTH="80%"><B>Name</B></TD>				
				<TD ID="header" ALIGN="RIGHT" NOWRAP><B>Volume (CS)</B></TD>
				<TD ID="header" width="30">&nbsp;</TD>
				<TD ID="header" ALIGN="RIGHT" NOWRAP><B>Volume (LB)</B></TD>
			</TR>
			<CFLOOP QUERY="get_Distributor_Invoice_Value">
				<CFSET Total_Volume_CS = Total_Volume_CS + Volume_CS>
				<CFSET Total_Volume_LB = Total_Volume_LB + Volume_LB>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD>&nbsp;</TD>
				<TD>#Ship_To#</TD>
				<TD>#Name#</TD>
				<CFSET A_START = "">
				<CFSET A_END = "">
				<CFIF Volume_LB NEQ 0>
					<CFSET A_START = "<A HREF=""void(0);"" onClick=""javaScript:return Show_Invoice_Details('#BSA_Foodservice_Customers_ID#');"">">
					<CFSET A_END = "</A>">
				</CFIF>
<!--- 				<TD ALIGN="RIGHT">#A_START##this.FormatVolume(Volume_CS)##A_END#</TD>
				<TD>&nbsp;</TD>
				<TD ALIGN="RIGHT">#A_START##this.FormatVolume(Volume_LB)##A_END#</TD> --->
				<TD ALIGN="RIGHT">#this.FormatVolume(Volume_CS)#</TD>
				<TD>&nbsp;</TD>
				<TD ALIGN="RIGHT">#this.FormatVolume(Volume_LB)#</TD>
			</TR>
			</CFLOOP>
			<TR ALIGN="CENTER">
				<TD COLSPAN=3 ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
				<B>Total Volume (&##931; Volume) = </B>
				</TD>
				<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right">
				<CFSET data = Total_Volume_CS>
				<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#</B></SPAN>"></CFIF>
				<CFSET data = this.FormatVolume(Total_Volume_CS)>
				<B>#data#</B>
				</TD>
				<TD></TD>
				<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right">
				<CFSET data = Total_Volume_LB>
				<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#</B></SPAN>"></CFIF>
				<CFSET data = this.FormatVolume(Total_Volume_LB)>
				<B>#data#</B>
				</TD>
			</TR>
			</TABLE>			
		<CFELSE>
			<BR><BR><B>This product doesn't have any forecast detail information</B>
		</CFIF>
	</cffunction>
	
	<!----------------- showForecastInvoiceDetail() -------------------->
	<cffunction name="showForecastInvoiceDetail" output="true" hint="showForecastInvoiceDetail">
		<cfargument name="Product_ID" type="string" required="true" default="">
		<cfargument name="Distributor_ID" type="string" required="true" default="">
		
		<CFQUERY NAME="Get_Product_Info" DATASOURCE="#application.datasource#">
			SELECT	Item, UPC, Description
			FROM	BSA_Foodservice_Items_Master
			WHERE
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#Arguments.Product_ID#'
		</CFQUERY>
		<cfset useLakebaseForGet_Distributor_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGet_Distributor_Info>
	<cftry>
		<cfset Get_Distributor_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#Arguments.Distributor_ID#",
				"select" = "name,ship_to"
			}), "name,ship_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Distributor_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Distributor_Info>
<CFQUERY NAME="Get_Distributor_Info" DATASOURCE="#application.datasource#">
			SELECT	Name, Ship_to
			FROM	BSA_Foodservice_Customers
			WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Arguments.Distributor_ID#'
		</CFQUERY>
</cfif>
		<CFQUERY NAME="Get_Invoice_Detail" DATASOURCE="#application.datasource#">
			SELECT	
					ISNULL(Cases_Invoiced,0) AS Volume_CS,
					ISNULL(Pounds_Invoiced,0) AS Volume_LB,
					Invoice_Header.Invoice_Version + '-' + Invoice_Header.Order_Number AS Invoice_Number, 
					Invoice_Header.Invoice_Date, Shared_Invoice_Number
			FROM	Invoice_Header
					INNER JOIN Invoice_Detail
					ON
					Invoice_Detail.Invoice_Header_ID = Invoice_Header.Invoice_Header_ID
					AND Invoice_Detail.Deleted = 0
					AND Invoice_Detail.BSA_Foodservice_Items_Master_ID = '#Arguments.Product_ID#'
					AND Invoice_Header.Invoice_Date >= #CreateODBCDate(this.forecastInfo.forecastFromDate)# 
					AND Invoice_Header.Invoice_Date <= #CreateODBCDate(this.forecastInfo.forecastToDate)# 
			WHERE
					Invoice_Header.BSA_Foodservice_Customers_ID = '#Arguments.Distributor_ID#'
					AND Invoice_Header.Deleted = 0
			ORDER BY Invoice_Header.Invoice_Date
		</CFQUERY>
		<SPAN CLASS="Title3" STYLE="font-weight: bold;">
		Product: <SPAN STYLE="font-weight:normal;">#Get_Product_Info.Item# #Get_Product_Info.UPC# #Get_Product_Info.Description#</SPAN>
		<BR>Distributor: <SPAN STYLE="font-weight:normal;">#Get_Distributor_Info.Ship_To# #Get_Distributor_Info.Name#</SPAN>
		</SPAN>
		<CFIF Get_Invoice_Detail.RecordCount GT 0>
			<CFSET Total_Volume_CS = 0>
			<CFSET Total_Volume_LB = 0>
			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" CLASS="Maintable" WIDTH="90%">
			<TR BGCOLOR="##FFCE84" VALIGN="bottom">
				<TD>&nbsp;</TD>
				<TD ID="header" NOWRAP WIDTH="50%"><B>Invoice Number</B></TD>
				<TD ID="header" NOWRAP WIDTH="100"><B>Invoice Date</B></TD>
				<TD ID="header" NOWRAP WIDTH="200"><B>Secondary Invoice ##</TD>
				<TD ID="header" ALIGN="RIGHT" NOWRAP><B>Volume (CS)</B></TD>
				<TD ID="header" width="30">&nbsp;</TD>
				<TD ID="header" ALIGN="RIGHT" NOWRAP><B>Volume (LB)</B></TD>
			</TR>
			<CFLOOP QUERY="Get_Invoice_Detail">
				<CFSET Total_Volume_CS = Total_Volume_CS + Volume_CS>
				<CFSET Total_Volume_LB = Total_Volume_LB + Volume_LB>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD>&nbsp;</TD>
				<TD>#Invoice_Number#</TD>
				<TD>#DateFormat(Invoice_Date, 'mm/dd/yyyy')#</TD>
				<TD>#Shared_Invoice_Number#</TD>					
				<TD ALIGN="RIGHT">#this.FormatVolume(Volume_CS)#</TD>
				<TD>&nbsp;</TD>
				<TD ALIGN="RIGHT">#this.FormatVolume(Volume_LB)#</TD>
			</TR>
			</CFLOOP>
			<TR ALIGN="CENTER">
				<TD COLSPAN="4" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
				<B>Total Volume (&##931; Volume) = </B>
				</TD>
				<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right">
				<CFSET data = this.FormatVolume(Total_Volume_CS)>
				<B>#data#</B>
				</TD>
				<TD></TD>
				<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right">
				<CFSET data = this.FormatVolume(Total_Volume_LB)>
				<B>#data#</B>
				</TD>
			</TR>
			</TABLE>
		</CFIF>
		
	</cffunction>
	
	
	<!----------------- showVolumeApplicator() -------------------->
	<cffunction name="showVolumeApplicator" output="true" hint="showVolumeApplicator">
		<cfargument name="productCount" type="numeric" required="true" default="">
		
		<SCRIPT LANGUAGE="JavaScript">
		function applyGlobalVolume(volumeToApply, whichBox, global)
		{
			var Field_Name_End_Len = Field_Name_End.length;

			SetParentFormValues(volumeToApply,<cfoutput>#this.volumePacket.uom#</cfoutput>,whichBox, global);

			for(var i=0;i<Field_Name_End_Len;i++)
			{
			/* Leave the "global == 1" (calculate volume for all the products) as the first condition as that condition is being 
			used for hidden variables. As the other condition, which checks for the "checked value" does not exist for the hidden 
			variable, the function does not complete it's job */		   
				if(global == 1 || eval("document.all.Ch_Product_Volume_" + Field_Name_End[i] + ".checked"))
				{
					if(whichBox == 2)
					{
						imp_obj = eval("document.all.Volume_Cap_" + Field_Name_End[i]);
					}
					else
					{
						imp_obj = eval("document.all." + CheckVolumeFields[i]);
					}
					imp_obj.value = volumeToApply;
					if(whichBox == 1)
					{
						change_Volume_UOM_Value(imp_obj);
					}
				}
			}
		}

		function SetParentFormValues(volumeToApply,UOM,whichBox,global){
		 var Parentfrm = opener.document.all.MyForm;
		 if(whichBox == 1 && global == 1){
			 for(i=0; i<Parentfrm.elements.length; i++){
			 	if(Parentfrm.elements[i].type == "hidden"){				
					if(UOM == 1){
						if(Parentfrm.elements[i].name.indexOf("Product_Volume") != -1 && Parentfrm.elements[i].name.indexOf("_CS") != -1){
						Parentfrm.elements[i].value = volumeToApply;
						}				
					}
					else{
						if(Parentfrm.elements[i].name.indexOf("Product_Volume") != -1 && Parentfrm.elements[i].name.indexOf("_LB") != -1){
						Parentfrm.elements[i].value = volumeToApply;
						}
					}
				}
				
			 }
		}
	  }
		</SCRIPT>
		<TABLE WIDTH="#this.Window_Max_Width#" BORDER="0" CELLPADDING="2" CELLSPACING="0">
		<TR>
			<TD COLSPAN="<cfif this.volumePacket.avgQuantityApplicator>4<cfelse>2</cfif>"  STYLE="border-top:1px navy solid;"><B>Volume Applicator</B></TD>
			<TD STYLE="border-top:1px navy solid;"><B>Overage Applicator</B></TD>			
		</TR>	
		<TR>
		<cfif this.volumePacket.avgQuantityApplicator>
		<cfset prodLen = ArrayLen(this.volumePacket.products)>
		<TD VALIGN="top" width="35%">		
			<CFSET AverageVolume = 1>
			<CFIF prodLen GT 0>
				<CFSET AverageVolume = trim(Round(this.volumePacket.totalQuantity / prodLen))>
				<CFSET AverageVolume = AverageVolume * (this.defaultUOT.getMultiplier() / this.volumePacket.appAreaSpan) />
			</CFIF> 
				
			<CFIF AverageVolume EQ 0>
				<CFSET AverageVolume = 1>
			</CFIF>
			<input type="hidden" name="formAverageVolume" value="<CFOUTPUT>#Round(AverageVolume)#</CFOUTPUT>">
			<FONT SIZE="2">
			Assign a calculated volume of: <CFOUTPUT><div id="AverageVolume" STYLE="DISPLAY:INLINE;">#trim(numberformat(Round(AverageVolume), '___,___,___,___,___'))#</div>&nbsp;#this.volumePacket.uomDesc#</CFOUTPUT>
			<BR>
			<CF_smallLink 
				title = "apply volume"
				url = "##"
				parameters = "onClick=""javascript: applyGlobalVolume(document.all.formAverageVolume.value, 1,0);return false;"""
			>
			<cfparam name="url.startElem" default="1" />
			<br />
			<CF_smallLink 
				title = "apply volume globally"
				url = "##"
				parameters = "onClick=""javascript: applyGlobalVolume(document.all.formAverageVolume.value, 1,1);return false;"""
			>
			<cfif this.volumePacket.showVolumeCap>
			<br />
			<CF_smallLink 
				title = "apply cap"
				url = "##"
				parameters = "onClick=""javascript: applyGlobalVolume(document.all.formAverageVolume.value, 2,0);return false;"""
			>
			</cfif>
			</LI>
			</FONT>		
		</TD>
		<TD WIDTH="50" ALIGN="center">
		<div><strong>&nbsp;OR&nbsp;</strong></div>
		</TD>
		</cfif>		
		<TD VALIGN="top" width="35%">			
			<FONT SIZE="2">
			Enter volume per item:&nbsp;<input TYPE="Text" SIZE="1" NAME="globalVolume" ONKEYUP="clenseText(this,'0123456789')">
			<BR>
			<CF_smallLink 
				title = "apply volume (#this.volumePacket.uomDesc#)" 
				url = "##"
				parameters = "onClick=""javascript: applyGlobalVolume(document.all.globalVolume.value, 1,0);return false;"""
			>
			<br />
			<CF_smallLink 
				title = "apply volume globally (#this.volumePacket.uomDesc#)" 
				url = "##"
				parameters = "onClick=""javascript: applyGlobalVolume(document.all.globalVolume.value, 1,1);return false;"""
			>
			
			<cfif this.volumePacket.showVolumeCap>
			<br />
			<CF_smallLink 
				title = "apply cap" 
				url = "##"
				parameters = "onClick=""javascript: applyGlobalVolume(document.all.globalVolume.value, 2,0);return false;"""
			>
			</cfif>
			</LI>
			</FONT>
		</TD>
		<SCRIPT LANGUAGE="JavaScript">
			function ApplyOverage(global)
			{
				var overage_val = parseFloat(document.all.Overage_Value.value);
				var overage_uom = document.all.Overage_UOM.value;
				var apply_source = 0;
				if(document.all.Apply_Overage_On[0].checked)
				{
					apply_source = 1;
				}
				else if(document.all.Apply_Overage_On[1].checked)
				{
					apply_source = 2;
				}
				else
				{
					alert("Overage Applicator: Select an option");
					return false;
				}
				if(!isNaN(overage_val))
				{
					ApplyThisOverage(overage_val, overage_uom, apply_source, global);
				}
				else
				{
					alert("Overage Applicator: Enter a proper value");
				}
				return false;
			}
			
			function Calc_Overage(val, overage, qty_UOM)
			{	
				// <!--- Dev Note: KAL; D8092 --->
				if(qty_UOM ==1){
					var overaged_val = Math.round(val + ((val * overage) / 100));}
				else{
					var overaged_val = (val + ((val * overage) / 100));}
				return (overaged_val);
			}
			
			function ApplyThisOverage(iVal, sUOM, apply_source, global)
			{
				event.returnValue = false;
				var tempVolumeObject, Forecast_pair, overaged_Value;
	
				for(var i=0;i<CheckVolumeFields.length;i++)
				{

					//Forecast_pair
					if(global== 1 || eval("document.all.Ch_Product_Volume_" + Field_Name_End[i] + ".checked"))
					{
						tempVolumeObject = eval("document.all." + CheckVolumeFields[i]);
	
						if(apply_source == 2)
						{
							Forecast_pair = tempVolumeObject;
							if(Forecast_pair)
							{
								overaged_Value = parseFloat(Forecast_pair.value);
								overaged_Value = Calc_Overage(overaged_Value, iVal, Forecast_pair.current_uom);
								tempVolumeObject.value = overaged_Value;
								change_Volume_UOM_Value(tempVolumeObject);
							}
						}
						else
						{
							Forecast_pair = eval("document.all." + tempVolumeObject.Forecast_pair);
							if(Forecast_pair)
							{
								overaged_Value = parseFloat(Forecast_pair.innerText);
								overaged_Value = Calc_Overage(overaged_Value, iVal, tempVolumeObject.current_uom);							
								tempVolumeObject.value = ConvertToProgramVolume(overaged_Value);
								change_Volume_UOM_Value(tempVolumeObject);
							}
						}
					}
				}
			/* The value of 1 is being passed for whichBox, so that the "SetParentFormValues" can diiferentiate between
			   calculating volume and Volume Cap. 1 is for calculating volume */
			//SetParentFormValues(tempVolumeObject.value,<cfoutput>#this.volumePacket.uom#</cfoutput>,1, global);
			}
			<CFIF this.forecastInfo.priorForecast>
			function ConvertToProgramVolume(Forecast_Volume)
			{
				var return_Value = 0;
				
				var volMultiplier = #this.defaultUOT.getMultiplier()#;
				
				var Forecast_Span = #this.forecastInfo.forecastSpan#;
				if(Forecast_Span > 0 && Forecast_Volume > 0)
				{
					return_Value = (Forecast_Volume / Forecast_Span) * volMultiplier;					
				}
				return return_Value;
			}
			</CFIF>
			
			function overage_keyup(thisObj, uom_select_name)
			{
				var uom_Select = eval("document.all." + uom_select_name);
				var char_Restriction = ".-0123456789";
				
				//clenseText(thisObj, char_Restriction);
				var returnValue = Numeric_Key_Only(thisObj, true, true);
				
				var tValue = thisObj.value;
				if(returnValue)
				{
					if((/\.(\d){3,}?$/.test(tValue)))
					{
						tValue = formatToDecimalPlaces(tValue, 3);
						thisObj.value = tValue;
					}
					var originalValue = tValue;
					var bNegative = "";
					if(parseFloat(originalValue) < 0)
					{
						bNegative = "-";
					}					
					tValue = Math.abs(originalValue);
					tValue = parseInt(tValue);
					if(tValue >= 100)
					{
						tValue = 99.999;
						thisObj.value = bNegative + tValue;
					}					
				}
				
			}	
		</SCRIPT>
		<TD WIDTH="50" ALIGN="center"><DIV><strong>&nbsp;&nbsp;</strong></DIV></TD>
		<TD ID="header" WIDTH="30%" VALIGN="top">
		<!------ 
		allow only 
		negative sign				= 1
		2 digits before decimal		= 2
		decimal pint				= 1
		3 digits after decimal		= 3
		Total						= 7
		 ----->
		<INPUT TYPE="Text" NAME="Overage_Value" maxlength="7" VALUE="" SIZE="4" ONKEYPRESS="javaScript: return Allow_Key_List('-.0123456789');" ONKEYUP="overage_keyup(this, 'Overage_UOM')">
		<SELECT NAME="Overage_UOM">
			<OPTION VALUE="%" SELECTED>%</OPTION> 
		</SELECT>
		<br />
		<FONT SIZE="2">
		<CF_smallLink 
			title = "apply volume" 
			url = "##"
			parameters = "onClick=""javascript: ApplyOverage(0);return false;"""
		>
		<br />
		<CF_smallLink 
			title = "apply volume to page" 
			url = "##"
			parameters = "onClick=""javascript: ApplyOverage(1);return false;"""
		>
		</FONT>
		<BR>
		<INPUT TYPE="RADIO" NAME="Apply_Overage_On" <CFIF NOT this.forecastInfo.priorForecast>DISABLED</CFIF>>Historical Value
		<INPUT TYPE="RADIO" NAME="Apply_Overage_On">#this.defaultUOT.getDesc()# Value		
		</TD>
		</TR>
		<tr>
			<td colspan="100%" STYLE="border-top:1px navy solid;">		
			<strong>You have to select a volume for each item. You may apply the same volume to all the items using the above tool, or you may specify the volume for each item below.  Click on the apply button when you are done.<br></strong>
			</td>
		</tr>
	</table>
	</cffunction>
	
	
	<!----------------- showForecastBasicInfo() -------------------->
   	<cffunction name="showForecastBasicInfo" output="true" hint="showForecastBasicInfo">
		<cfif this.forecastInfo.priorForecast>
		<TABLE WIDTH="#this.Window_Max_Width#" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-top:1px navy solid;border-bottom:1px navy solid;">
		<TR>
		<TD>
		<TABLE ALIGN="left" CELLPADDING="2" CELLSPACING="0" BORDER="0" BORDERCOLOR="Orange">
		<TR>
			<TD STYLE="font-size:13px;color:Navy;">
				<TABLE WIDTH="100%">
				<TR>
				<TD>Last forecast was done by <B>#this.forecastInfo.forecastUpdateUser#</B> on <B>#DateFormat(this.forecastInfo.forecastUpdateDate, "mm/dd/yyyy")#</B></TD>
				</TR>
				<TR>
				<TD><B>Forecast Span:</B> #DateFormat(this.forecastInfo.forecastFromDate, "mm/dd/yyyy")# - #DateFormat(this.forecastInfo.forecastToDate, "mm/dd/yyyy")# (#this.forecastInfo.forecastSpan# days)</TD>
				</TR>
				<cfif this.volumePacket.allDistributorsSelected>
					<TR>
					<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;You have selected 'All #LCase(application.returned_customer_setting.distributor_label_plural)#'</TD>
					</TR>
				<cfelse>
				<CFIF this.volumePacket.distributorsNotInAppArea GT 0>
					<TR>
					<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;There <CFIF this.volumePacket.distributorsNotInAppArea GT 1>are<CFELSE>is</CFIF> #this.volumePacket.distributorsNotInAppArea# <CFIF this.volumePacket.distributorsNotInAppArea GT 1>#LCase(application.returned_customer_setting.distributor_label_plural)#<CFELSE>#LCase(application.returned_customer_setting.distributor_label_singular)#</CFIF> who exist in the recent forecast but does not exist in the #this.volumePacket.appAreaKeyword#</TD>
					</TR>
				</CFIF>
				<CFIF this.volumePacket.distributorsNotInForecast GT 0>
					<TR>
					<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;There <CFIF this.volumePacket.distributorsNotInForecast GT 1>are<CFELSE>is</CFIF> #this.volumePacket.distributorsNotInForecast# <CFIF this.volumePacket.distributorsNotInForecast GT 1>#LCase(application.returned_customer_setting.distributor_label_plural)#<CFELSE>#LCase(application.returned_customer_setting.distributor_label_singular)#</CFIF> who exist in the #this.volumePacket.appAreaKeyword# but does not exist in the recent forecast</TD>
					</TR>
				</CFIF>
				</cfif>
				<cfif this.volumePacket.allProductsSelected>
					<TR>
					<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;You have selected 'All Products'</TD>
					</TR>
				<cfelse>
				<CFIF this.volumePacket.proudctsNotInForecast GT 0>
					<TR>
					<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;There <CFIF this.volumePacket.proudctsNotInForecast GT 1>are<CFELSE>is</CFIF> #this.volumePacket.proudctsNotInForecast# product<CFIF this.volumePacket.proudctsNotInForecast GT 1>s</CFIF> that exist in the #this.volumePacket.appAreaKeyword# but does not exist in the recent forecast</TD>
					</TR>
				</CFIF>
				</cfif>
				<CFIF isDate(this.volumePacket.forecastInfo.appAreaStartDate) AND IsDate(this.volumePacket.forecastInfo.appAreaEndDate)>
				<CFIF DATEDIFF("d", this.volumePacket.forecastInfo.appAreaStartDate, this.volumePacket.appAreaStartDate) NEQ 0 OR DATEDIFF("d", this.volumePacket.forecastInfo.appAreaEndDate, this.volumePacket.appAreaEndDate) NEQ 0>
					<TR>
					<TD STYLE="color:red"><IMG SRC="/Images/exclamation_1.gif">&nbsp;The #this.volumePacket.appAreaKeyword# span during last forecast was #DateFormat(this.volumePacket.forecastInfo.appAreaStartDate, "mm/dd/yyyy")# - #DateFormat(this.volumePacket.forecastInfo.appAreaEndDate, "mm/dd/yyyy")#</TD>
					</TR>					
				</CFIF>
				</CFIF>
				</TABLE>
			</TD>
		</TR>
		</TABLE>
		</TD>
		</TR>
		</TABLE>
		<CFELSE>
			<HR COLOR="Orange">
			<B>This #this.volumePacket.appAreaKeyword# doesn't have any prior forecast information</B>
		</CFIF>
	</cffunction>
	
	<!----------------- showAppAreaInfo() -------------------->
	<cffunction name="showAppAreaInfo" output="true" hint="showAppAreaInfo">
		<TABLE BGCOLOR="FFE4B5" WIDTH="#this.Window_Max_Width#">
		<TR>
		<TD>
		<SPAN CLASS="Title2" STYLE="color:black;">
		#this.volumePacket.appAreaTitle#
		<BR>
		#capitalizeStartLetters(this.volumePacket.appAreaKeyword)# Span: <SPAN STYLE="font-weight:normal;">#DateFormat(this.volumePacket.appAreaStartDate, "mm/dd/yyyy")# - #DateFormat(this.volumePacket.appAreaEndDate, "mm/dd/yyyy")# (#this.volumePacket.appAreaSpan# days)</SPAN>
		</SPAN>
		</TD>
		</TR>
		</TABLE>
   	</cffunction>
	
	
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Common Functions
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

	<!----------------- convertToUOM() -------------------->
   	<cffunction name="convertToUOM" output="false" hint="convertToUOM">
		<cfargument name="UOM_1_Value" type="string" required="true" default="">
		<cfargument name="To_UOM" type="numeric" required="true" default="">
		<cfargument name="Net_Weight" type="numeric" required="true" default="">
		<CFSET UOM_2_Value = "">
		<CFSET UOM_1_Value = arguments.UOM_1_Value>
		
		<CFIF IsNumeric(UOM_1_Value)>
			<CFIF arguments.To_UOM EQ 1><!---- convert to case ---->
				<CFIF UOM_1_Value NEQ 0 AND IsNumeric(UOM_1_Value) AND Net_Weight NEQ 0 AND IsNumeric(Net_Weight)>
					<CFSET UOM_2_Value = UOM_1_Value / Net_Weight>
				<CFELSEIF UOM_1_Value EQ 0>
					<CFSET UOM_2_Value = 0>
				<CFELSEIF Net_Weight EQ 0>
					<CFSET UOM_2_Value = UOM_1_Value>
				</CFIF>
			<CFELSE><!---- convert to pounds ---->
				<CFSET UOM_2_Value = UOM_1_Value * Net_Weight>
			</CFIF>
		</CFIF>
		
		<cfreturn UOM_2_Value>
	</cffunction>
	
	<!----------------- convertToProgramVolume() -------------------->
   	<cffunction name="convertToProgramVolume" output="false" hint="convertToProgramVolume">
		<cfargument name="Forecast_Volume" type="string" required="true" default="">
		<CFSET Return_Program_Volume = 1>
		<CFIF this.forecastInfo.forecastSpan GT 0 AND IsNumeric(Arguments.Forecast_Volume) AND IsNumeric(this.forecastInfo.forecastSpan)>
			<CFIF Arguments.Forecast_Volume GT 0>
				<CFSET Return_Program_Volume = Round((Arguments.Forecast_Volume / this.forecastInfo.forecastSpan) * this.defaultUOT.getMultiplier())>
				<cfif Return_Program_Volume eq 0><cfset Return_Program_Volume = 1 /></cfif>				
			</CFIF>
		</CFIF>
		<cfreturn Return_Program_Volume>
	</cffunction>
	
	<!----------------- ConvertToAnnualVolume() -------------------->
   	<cffunction name="ConvertToAnnualVolume" output="false" hint="ConvertToAnnualVolume">
		<cfargument name="Program_Volume" type="string" required="true" default="">
		<CFSET Return_Annual_Volume = "">
		<cfset volumeStoredSpan = this.volumePacket.appAreaSpan>
		<cfif this.defaultUOT.getMultiplier()>
				<cfset volumeStoredSpan =this.defaultUOT.getMultiplier()>
		</cfif>
		<CFIF IsNumeric(volumeStoredSpan) AND volumeStoredSpan GT 0 AND IsNumeric(Arguments.Program_Volume)>
			<CFSET Return_Annual_Volume = (Arguments.Program_Volume / volumeStoredSpan) * this.yearSpan>
		</CFIF>
		<cfreturn Return_Annual_Volume>
	</cffunction>
	
	<!----------------- formatVolume() -------------------->
   	<cffunction name="formatVolume" output="false" hint="Format Volume">
		<cfargument name="Volume" type="string" required="true" default="">
		<cfargument name="AddComma" type="numeric" required="false" default="1">
		
		<CFIF AddComma EQ 1>
			<cfset formatted_volume = NumberFormat(RoundVolume(Arguments.Volume), "(___,___,___,___,___")>
		<CFELSE>
			<cfset formatted_volume = RoundVolume(Arguments.Volume)>
		</CFIF>
							
		<cfreturn formatted_volume/>
	</cffunction>
	
	<!----------------- RoundVolume() -------------------->
   	<cffunction name="RoundVolume" output="false" hint="Round Volume">
		<cfargument name="Volume" type="string" required="true" default="">
		
		<cfset rounded_volume = Arguments.Volume>
		
		<cfif rounded_volume EQ "">
			<cfset rounded_volume = 0>
		</cfif>
		
		<cfset rounded_volume = Round(rounded_volume)>
							
		<cfreturn rounded_volume/>
	</cffunction>
	
	<!----------------- Build_To_URL() -------------------->
   	<cffunction name="Build_To_URL" output="false" hint="Build_To_URL">
		<cfargument name="sOriginal" type="string" required="true" default="">
		<cfargument name="sName" type="string" required="true" default="">
		<cfargument name="sValue" type="string" required="true" default="">
		<cfset addValue = "#Arguments.sName#=#Arguments.sValue#">
		<cfset sReturnValue = Arguments.sOriginal>
		<cfif NOT ListFindNoCase(sReturnValue, addValue, "&")>
			<cfset sReturnValue = ListAppend(sReturnValue, addValue, "&")>
		</cfif>
		<cfreturn sReturnValue>
	</cffunction>
	
	<!----------------- Show_Please_Wait() -------------------->
   	<cffunction name="showPleaseWait" output="true" hint="Show_Please_Wait">
		<cfargument name="type" type="numeric" required="false" default="1">
		<cfif Arguments.type EQ 1>
			<CFSET PW_Type = "volume_applicator">
		</cfif>
		<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER" STYLE="display:none">
		<br><br><br>
		<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		<br><br><br>
		</SPAN>
		<CFFLUSH>
		<SCRIPT>
		function show_please_wait(hideForm)
		{
			document.all.PleaseWaitMessage.style.display = "";
			hideForm.style.display = "none";
		}
		</SCRIPT>
	</cffunction>
	
	<!----------------- showSortString() -------------------->
   	<cffunction name="showSortString" output="true" hint="showSortString">
		<cfargument name="Sort_Value" type="string" required="true" default="">
		<cfargument name="Display_Text" type="string" required="true" default="">
		<cfargument name="Display_Title" type="string" required="false" default="#Arguments.Display_Text#">
		<cfset This_Sort_Order = "ASC">
		<CFSET Img_String = "">
		
		<CFIF Arguments.Sort_Value EQ FORM.SORT_BY>
			
			<CFSET Img_String = "<IMG SRC=""/Images/down_1.gif"">">
			<CFIF FORM.SORT_ORDER EQ "ASC">
				<CFSET Img_String = "<IMG SRC=""/Images/up_1.gif"">">
				<cfset This_Sort_Order = "DESC">
			</CFIF>
		</CFIF>
		<A TITLE="Sort by #Arguments.Display_Title#" HREF="##" OnClick="JavaScript: return sort_by_This('#Arguments.Sort_Value#', '#This_Sort_Order#');"><B>#Arguments.Display_Text#</B></A>&nbsp;#Img_String#
	</cffunction>
	
	<!----------------- sortArrayOfStructs() -------------------->
   	<cffunction name="sortArrayOfStructs" output="true" hint="sortArrayOfStructs">
		<cfargument name="oArray" type="array" required="true" default="">
		<cfargument name="sStructPath" type="string" required="true" default="">
		<cfargument name="sortOrder" type="string" required="false" default="ASC">

		<cfset oArray = arguments.oArray>
		<cfset arrayLen = ArrayLen(oArray)>
		<cfset newArray = ArrayNew(1)>		
		<cfloop index="i" from="1" to="#arrayLen#">
			<cfset newArray = insertToArrayOfStructs(newArray, prodArray[i], arguments.sStructPath, arguments.sortOrder)>
		</cfloop>
		
		<cfreturn newArray>
	</cffunction>
	
	<!----------------- insertToArrayOfStructs() -------------------->
   	<cffunction name="insertToArrayOfStructs" output="true" hint="insertToArrayOfStructs">
		<cfargument name="oArray" type="array" required="true" default="">
		<cfargument name="oStruct" type="struct" required="true" default="">
		<cfargument name="sStructPath" type="string" required="true" default="">
		<cfargument name="sortOrder" type="string" required="false" default="ASC">
		<cfset oArray = arguments.oArray>
		<cfset arrayLen = ArrayLen(oArray)>
		
		<cfset insertPos = arrayLen + 1>
		<cfset checkStructVal = Evaluate("arguments.oStruct.#arguments.sStructPath#")>
		<cfloop index="i" from="1" to="#arrayLen#">
			<cfset currCheckStructVal = Evaluate("oArray[#i#].#arguments.sStructPath#")>
			<cfif arguments.sortOrder EQ "DESC">
				<!------ DESC ----->
				<cfif this.sortType EQ "text">
					<cfif CompareNoCase(checkStructVal, currCheckStructVal) GTE 0>
						<cfset insertPos = i>
						<cfbreak>
					</cfif>
				<cfelse>
					<cfif checkStructVal GTE currCheckStructVal>
						<cfset insertPos = i>
						<cfbreak>
					</cfif>
				</cfif>				
			<cfelse>
				<!------ ASC ----->
				<cfif this.sortType EQ "text">				
					<cfif CompareNoCase(checkStructVal, currCheckStructVal) LTE 0>
						<cfset insertPos = i>
						<cfbreak>
					</cfif>
				<cfelse>
					<cfif checkStructVal LTE currCheckStructVal>
						<cfset insertPos = i>
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfif insertPos GT arrayLen>
			<cfset ArrayAppend(oArray, arguments.oStruct)>
		<cfelse>
			<cfset ArrayInsertAt(oArray, insertPos, arguments.oStruct)>
		</cfif>
		<cfreturn oArray>
	</cffunction>

	<!----------------- capitalizeStartLetters() -------------------->
   	<cffunction name="capitalizeStartLetters" output="false" hint="capitalizeStartLetters">
		<cfargument name="sValue" type="string" required="true" default="">
		
		<cfset returnValue = " " & Arguments.sValue>
		
		<cfset returnValue = REReplaceNoCase(returnValue, " +", " ")>
		
		<cfset i = 0>
		<cfset capsPlace = REFind(" [a-z]", returnValue)>
		<cfloop condition="capsPlace GT 0 AND i LT 5">			
			<cfset smallString = Mid(returnValue, capsPlace + 1, 1)>
			<cfset bigString = chr(asc(smallString) - 32)>
			<cfset returnValue = Replace(returnValue, " #smallString#", " #bigString#")>
			<cfset i = i + 1>
			<cfset capsPlace = REFind(" [a-z]", returnValue)>
		</cfloop>
		
		<cfreturn returnValue>
	</cffunction>
	
		<cffunction name="getTemplateVolume" output="false" hint="getTemplateVolume">
		<cfargument name="contract_main_id" type="numeric" required="true" default="0">

		<cfquery datasource="#application.datasource#" name="templateVolumes">
			select 	top 1 Contract_Main.Contract_Main_ID, 
					Program_Control_Panel_Options.Max_Global_Volume, 
					Program_Control_Panel_Options.Max_Global_Volume_Size_CS, 
					Program_Control_Panel_Options.Max_Global_Volume_Size_LBS, 
					Program_Control_Panel_Options.Min_Global_Volume, 
					Program_Control_Panel_Options.Min_Global_Volume_Size_CS, 
					Program_Control_Panel_Options.Min_Global_Volume_Size_LBS
			from 	Program_Control_Panel_Options inner join contract_main 
			on 		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			where 	Contract_Main_ID = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="integer">
			order by Contract_Main_ID DESC
		</cfquery>	
		<cfreturn templateVolumes>
	</cffunction>

	<cffunction name="getMessageSettings" output="false" hint="get Message while editinG volume">
		<cfargument name="contract_main_id" type="numeric" required="true" default="0">

		<cfquery datasource="#application.datasource#" name="qMessageSettings">
			SELECT 	
				CASE
					WHEN cmad.Show_Volume_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Volume_Related_Message)) ! = ''
						THEN '1' 
						ELSE '0' 
				END
					As Message_Settings
			FROM 	Contract_Main_Aux_Data cmad			
						INNER JOIN Contract_Main cm
							ON cmad.Contract_Main_ID = cm.Contract_Main_ID
						INNER JOIN	Program_Control_Panel_Options pcpo
							ON (cm.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID)	 
			WHERE 	cmad.Contract_Main_ID = <cfqueryparam value="#arguments.contract_main_id#" cfsqltype="integer">
		</cfquery>	 
		<cfreturn qMessageSettings>
	</cffunction>
</cfcomponent>
