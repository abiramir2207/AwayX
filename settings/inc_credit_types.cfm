		<cfoutput>
		<TR id="id_excludecredit" style="display:none;">		
			<TD align="right" class="Orangline" valign="top"><B>Exclude these Credit Types:</B><br/>
			<CF_button
				button_name		=	""
				button_caption	=	"select"
				button_action	=	"openDivWindow();"
				button_type		=	"javascript_link"
				button_width	=	"75"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
			</TD>
			<TD><!---
				<div width="100%" style="overflow:auto;height:#divHeight#px;background-color:white;">
				<cfloop query="qGetCreditTypes">				
					<input type="checkbox" name="Credit_Type_Select" value="#Credit_Type_ID#" <cfif ListFind(alreadySelectedCreditTypeExclusionList, Credit_Type_ID)>checked</cfif>>#Credit_Type# #Credit_Type_Description#<br>
				</cfloop>
				</div>--->
				
				<!--- Div to display the selected credit types using xml/xsl --->
				<div id="oDivSelectedCreditType">
				<table border="0" width="400">
				<cfloop query="qGetCreditTypes">
					<tr id="ID_Credit_Type_Select_#Credit_Type_ID#" <cfif ListFind(alreadySelectedCreditTypeExclusionList, Credit_Type_ID) eq 0>style="display:none";</cfif>>
						<td width="25"><img src="/images/scissor.gif" title="remove this credit type" style="cursor: pointer;" onclick="showCreditType('#Credit_Type_ID#',false);"></td>
						<td width="25">&nbsp;&nbsp;&nbsp;#Credit_Type#</span></td>						
						<td width="350">&nbsp;#Credit_Type_Description#</span></td>
					</tr>
				</cfloop>
				</table>

				<input type="hidden" name="Credit_Type_Select" id="Credit_Type_Select" value="#alreadySelectedCreditTypeExclusionList#">
				</div>
				
				<!--- Below is the div/window which will show / hide so users can check/uncheck the credit types  --->
				<cfmodule
					template="/customtags/displayLayer.cfm"
					layerName="oDivSelectCreditTypes"
					width="600"
					height="400"
					overflow="auto"
					bgColor="ffffff"
					scroll="1"
					display="0"
					>
				<br>
				<table cellpadding="0" cellspacing="0" width="95%">
				<tr>
					<td width="33%">&nbsp;
					</td>
					<td width="34%" align="center" style="font-weight:bold;font-size:14px;">Select Credit Types</td>
					<td width="33%" align="right">
					<CF_smallLink 
						title = "close" 
						url = "##"
						parameters = "onClick=""javascript: closeDivWindow();return false;"""
					>
					</td>
				</tr>
				</table>
				<table border="0" width="95%" CLASS="MAINTABLE" cellpadding="0" cellspacing="0">
					<tr BGCOLOR="FFE083">
						<cfset ListOfCreditTypes = "#ValueList(qGetCreditTypes.Credit_Type_ID, ",")#">
						<td  width="8%"><cfoutput><input type="checkbox"  name="checkall" id ="checkall"  onclick="selectAllCreditType('#ListOfCreditTypes#');"></cfoutput></td>
						<td  width="30%">Credit Type</td>
						<td>Description</td>
					</tr>
				</table>
				<table border="0" width="400">
				<cfloop query="qGetCreditTypes">
					<tr>
						<td>&nbsp;<input type="checkbox" name="CreditTypeList_#Credit_Type_ID#" id="CreditTypeList_#Credit_Type_ID#" <cfif ListFind(alreadySelectedCreditTypeExclusionList, Credit_Type_ID)>checked</cfif> onclick="showCreditType('#Credit_Type_ID#',this.checked);"></td>
						<td width="150">&nbsp;&nbsp;&nbsp;#Credit_Type#</span></td>
						<td width="150">&nbsp;#Credit_Type_Description#</span></td>
					</tr>
				</cfloop>
				</table>
				</cfmodule>
				<!--- Above is the div/window which will show / hide so users can check/uncheck the credit types  --->
			</TD>			
		</TR>
		</cfoutput>