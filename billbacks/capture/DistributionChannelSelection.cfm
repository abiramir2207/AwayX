<!-----------------------------------------------------------------------------

FILE NAME:		DistributionChannelSelection.cfm
DESCRIPTION:		 
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao		7-Jun-2018		Created
------------------------------------------------------------------------------>  
 
<cfset LabelComp 		= Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetBSVar2Label	= LabelComp.getGeneralLabels('BS_Var_2') />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset RedistributorDefaultSegmentBSVar2 = Trim(appSettings.get_Setting('Redistributor_default_Segment_BS_Var_2')) />
 
<cfparam name="URL.BBID" default="0" >
<cfparam name="URL.PRGID" default="0" >
<cfparam name="URL.BBPRGID" default="0" >
<cfparam name="URL.showEditLink" default="0" >


<script>
function redirectToSummaryPage()
{
	window.opener.location.href = "/Billbacks/capture/Billback_Summary.cfm?BBID=<CFOUTPUT>#URL.BBID#</CFOUTPUT>&Show_Details=1";
	window.close();
}
</script>	

<!--- <cfparam name="URL.DISTID" default="0" > --->
<cfoutput>
	<!---
	<cfquery name="qGetDSChannels" datasource="#application.datasource#">
		SELECT DISTINCT BS_Var_2 FROM Business_Segment WHERE Active = 1 AND Deleted = 0 AND BS_Var_2 IS NOT NULL
	</cfquery>
	--->
	<cfset useLakebaseForgetDSChannelForProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main") AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForgetDSChannelForProgram>
	<cftry>
		<cfset getDSChannelForProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("contract_main", {
				"contract_main_id" = "eq.#URL.PRGID#",
				"select" = "business_segment_id,contract_number,contract_title"
			}, "business_segment_id", "business_segment", "business_segment_id", "bs_var_2"), "business_segment_id,contract_number,contract_title,bs_var_2"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDSChannelForProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDSChannelForProgram>
<cfquery name="getDSChannelForProgram" datasource="#application.datasource#">
		SELECT 
			BS.BS_Var_2,CM.Business_Segment_ID,CM.Contract_Number,CM.Contract_Title 
		FROM 
			Contract_Main CM
			INNER JOIN 
				Business_Segment BS ON BS.Business_Segment_ID = CM.Business_Segment_ID 
			WHERE 
				CM.Contract_Main_ID = #URL.PRGID#
	</cfquery>
</cfif>
	<cfquery name="getDSChannelForDist" datasource="#application.datasource#">
		SELECT BDC.Billback_ID,BDC.Billback_Program_ID,BDC.Billback_Distribution_Channel_ID,BDC.Distributor_ID,BDC.BS_Var_2,BSAFC.Name,BSAFC.Ship_To, BSAFC.Cust_Suffix, CM.Contract_Number 
			FROM Billback_Distribution_Channel BDC
		INNER JOIN BSA_foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID = BDC.Distributor_ID
		INNER JOIN dbo.Billback_Program BP ON BP.Billback_Program_ID = BDC.Billback_Program_ID
		INNER JOIN Contract_main CM ON CM.Contract_Main_ID = BP.Program_ID
		WHERE 
			BDC.Billback_Program_ID = '#URL.BBPRGID#' AND BDC.Billback_ID = '#URL.BBID#' AND BDC.Deleted = 0
	</cfquery>
 
<cfif (isDefined("FORM.Submitted") AND FORM.Submitted EQ 1)>
	<cfloop query="getDSChannelForDist">
		<cfif IsDefined("FORM.selDC_#getDSChannelForDist.Billback_Distribution_Channel_ID#")>
			<cfset frmBSVar2 = Evaluate("FORM.selDC_#getDSChannelForDist.Billback_Distribution_Channel_ID#")>
		
			<cfif (getDSChannelForDist.BS_Var_2 NEQ frmBSVar2)>
				<cfset useLakebaseForqUpdDSChannels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distribution_channel")>
<cfif useLakebaseForqUpdDSChannels>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_distribution_channel", {
			"billback_id" = "#getDSChannelForDist.Billback_ID#",
			"billback_program_id" = "#getDSChannelForDist.Billback_Program_ID#",
			"distributor_id" = "#getDSChannelForDist.Distributor_ID#",
			"bs_var_2" = "#frmBSVar2#",
			"created_date" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdDSChannels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdDSChannels>
<cfquery name="qUpdDSChannels" datasource="#application.datasource#">
					INSERT INTO Billback_Distribution_Channel
						(Billback_ID, Billback_Program_ID, Distributor_ID, BS_Var_2, Created_Date)
					VALUES
					(
						'#getDSChannelForDist.Billback_ID#', '#getDSChannelForDist.Billback_Program_ID#','#getDSChannelForDist.Distributor_ID#','#frmBSVar2#',getDate()
					)					
					UPDATE 
						Billback_Distribution_Channel  
					SET 
						Deleted = 1,
						Deleted_By =  '#request.AccessStructure.User_ID#',
						Deleted_date = GetDate()
					WHERE  
						Billback_Distribution_Channel_ID = #getDSChannelForDist.Billback_Distribution_Channel_ID#
			</cfquery>
</cfif>
		</cfif>
	<!--- <div align="center"><font color="red">#qGetBSVar2Label.General_Labels_Label#: #FORM.selDC# has been updated.</font></div><br><br> --->
		</cfif>
	</cfloop>
	<script>
	redirectToSummaryPage();
	</script>
</cfif>	
<html>
<head>
	<title>#qGetBSVar2Label.General_Labels_Label#</title>
<script language="JavaScript">
	function submitForm()
	{
		var thisForm = document.all.frmDSSelection;
		thisForm.submit();
		return false;
	}

	function closeWindow()
	{
		window.close();
	}
</script>
<style>
wrapper {
  display: flex;
}
	 ##left {
	  float: left;
	  width: 65%;
	  overflow: hidden;
	}
	
	##right {
	  overflow: hidden;
	}
	

.divTable{
	display: table;
	
	width: 100%;
}
.divTableRow {
	display: table-row;
}
.divTableCell, .divTableHead {
	border: 0px solid ##999999;
	display: table-cell;
	padding: 3px 10px;
}
.divTableHeading {
	background-color: ##FFCE84;
	display: table-header-group;
	font-weight: bold;
}
.divTableFoot {
	background-color: ##EEE;
	display: table-footer-group;
	font-weight: bold;
}
.divTableBody {
	display: table-row-group;
}	
 
</style>
</head>

<body>
 
<cfif (URL.PRGID NEQ 0)>
	<table border="0" cellpadding="2" cellspacing="0" width="100%">
		<tr>
			<td aligh="left" bgcolor="##A7CAF2" width="100%" height="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
				<span style="color:white; font-size:14px; font-weight: bold; padding-left:5px;">#qGetBSVar2Label.General_Labels_Label# Assignment: #getDSChannelForProgram.Contract_Number#</span>
			</td>
		</tr>
	</table>

<form name="frmDSSelection" id="frmDSSelection" action="DistributionChannelSelection.cfm?PRGID=#URL.PRGID#&BBPRGID=#URL.BBPRGID#&BBID=#URL.BBID#&showEditLink=#URL.showEditLink#" method="post">		
<!--- <FIELDSET STYLE="padding:5px; width: 360px;height:85px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#qGetBSVar2Label.General_Labels_Label# </LEGEND> --->
<br> 
<b>	Current #qGetBSVar2Label.General_Labels_Label# for this Program: #getDSChannelForProgram.BS_Var_2#</b>
<br><br>
<TABLE width="98%" BORDER="0" CELLPADDING="1" CELLSPACING="0"  >
		<tr bgcolor="FFCE84">
			<td>
				<strong>Distributor</strong>
			</td>
			<td>
				<strong>#qGetBSVar2Label.General_Labels_Label#</strong>
			</td>
		</tr>	

	<cfloop query="getDSChannelForDist">
		<cfset dcForReDist = 0 />
		<cfif (Trim(getDSChannelForDist.Cust_Suffix) EQ "R" AND RedistributorDefaultSegmentBSVar2 NEQ "")>
			<cfset dcForReDist = RedistributorDefaultSegmentBSVar2 />
		</cfif>
		<cfset useLakebaseForqGetDSChannelFromDistMapping = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_salesorg_mapping")>
<cfif useLakebaseForqGetDSChannelFromDistMapping>
	<cftry>
		<cfset qGetDSChannelFromDistMapping = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_salesorg_mapping", {
				"bsa_foodservice_customers_id" = "eq.#getDSChannelForDist.Distributor_ID#",
				"order" = "distribution_channel.asc",
				"select" = "ship_to,distribution_channel,bsa_foodservice_customers_id,updated_date,created_date"
			}), "ship_to,distribution_channel,bsa_foodservice_customers_id,updated_date,created_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDSChannelFromDistMapping = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDSChannelFromDistMapping>
<cfquery name="qGetDSChannelFromDistMapping" datasource="#application.datasource#">
			SELECT 
				Ship_To,
				Distribution_Channel,
				BSA_Foodservice_Customers_ID,
				Updated_Date,
				Created_Date
			FROM 
				Distributor_SalesOrg_Mapping 
			WHERE 
				BSA_Foodservice_Customers_ID = '#getDSChannelForDist.Distributor_ID#'
			ORDER BY Distribution_Channel
		</cfquery>
</cfif>
		<cfset useLakebaseForqGetDSChannelFromUnion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetdschannelfromdistmapping")>
<cfif useLakebaseForqGetDSChannelFromUnion>
	<cftry>
		<cfset qGetDSChannelFromUnion = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetdschannelfromdistmapping", {
				"select" = "distribution_channel as bs_var_2"
			}), "distribution_channel as bs_var_2"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDSChannelFromUnion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDSChannelFromUnion>
<cfquery name="qGetDSChannelFromUnion" dbtype="query">
			SELECT Distribution_Channel AS BS_Var_2 FROM qGetDSChannelFromDistMapping
		</cfquery>
</cfif>
		<tr>
			<td>#getDSChannelForDist.Name#(#getDSChannelForDist.Ship_To#)</td>
		<!--- 	<td align="right"><B>Pick the #qGetBSVar2Label.General_Labels_Label# for this Distributor: </td> --->
			<td>
			<cfif (URL.showEditLink EQ 1)>
 				<select name="selDC_#getDSChannelForDist.Billback_Distribution_Channel_ID#" id="selDC_#getDSChannelForDist.Billback_Distribution_Channel_ID#">
					<option value="" SELECTED>NONE</option>
						<cfloop query="qGetDSChannelFromUnion">
							<option value="#qGetDSChannelFromUnion.BS_Var_2#" <cfif getDSChannelForDist.BS_Var_2 EQ qGetDSChannelFromUnion.BS_Var_2>selected</cfif> >#qGetDSChannelFromUnion.BS_Var_2#</option>
						</cfloop>
						<cfif (dcForReDist NEQ 0)><option value="#dcForReDist#" <cfif getDSChannelForDist.BS_Var_2 EQ dcForReDist>selected</cfif>>#dcForReDist#</option></cfif>
				</select>
			<cfelse>	
				#getDSChannelForDist.BS_Var_2#
			</cfif>	
			</td>
		</tr>
		</cfloop>
		
		<tr>
			<td colspan="100%"  align="center"><br>
				<table>
					<tr>
					<cfif (URL.showEditLink EQ 1)>
						<td align="right">
						
								<CF_button
									button_name		=	""
									button_caption	=	"Save"
									button_action	=	"return submitForm();"
									button_type		=	"javascript_link"
			 						button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>
						</td>
					</cfif>
					<td align="left">		
						<CF_button
								button_name		=	""
								button_caption	=	"Close Window"
								button_action	=	"return closeWindow();"
								button_type		=	"javascript_link"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
							>
					</td>
				</tr>
				</table>	
			</td>
		</tr>
	</table>
<!--- </FIELDSET> --->
<input type="hidden" name="submitted" id="submitted" value="1">
</form>
</cfif><!--- <cfif (URL.PRGID NEQ 0)> ---> 
</cfoutput>
</body>
</html>
 