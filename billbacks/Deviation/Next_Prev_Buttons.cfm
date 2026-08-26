<!-----------------------------------------------------------------------
Next Prev Button
------------------------------------------------------------------------>

<CFPARAM NAME="MAX_LEVEL" 	DEFAULT=0>
<CFPARAM NAME="THIS_STEP_LEVEL_IN_LIST" 	DEFAULT="">
<CFIF NOT isDefined("Billback_Amount_Match")>
	<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Amount_Match">
		SELECT	CONVERT(Char(10),Billback.Deviation_Ran_Date,101) Deviation_Ran_Date, Billback.Deviation_Ran_By, _Users.Name_First + ' '+ _Users.Name_Last Ran_By,
		Billback.BB_Amount,
		-----------------Total Amount claimed for this program
		(IsNUll((SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
		FROM	Billback_Program
			INNER JOIN	Billback_Product
			ON
			(   (Billback_Product.Billback_ID = '#Billback_ID#') 
				AND
				(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_Product.Deleted = 0)
			)
			INNER JOIN	Billback_Product_Detail
			ON
			(   Billback_Product_Detail.Billback_ID = '#Billback_ID#' 
				AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				AND
				(LEN(Billback_Product_Detail.BB_Rate) > 0)
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
			)
		WHERE
		Billback_Program.Billback_ID = Billback.Billback_ID
		AND
		Billback_Program.Deleted = 0
		), 0)  + 
		IsNull((SELECT	SUM(CAST(Billback_Program_Lumpsum_Component.Amount AS FLOAT))
		FROM	Billback_Program
			INNER JOIN	 Billback_Program_Lumpsum_Component
			ON
			(
				(Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				( Billback_Program_Lumpsum_Component.Deleted = 0)
			)
		WHERE
			Billback_Program.Billback_ID = Billback.Billback_ID
			AND
			Billback_Program.Deleted = 0
		), 0)
		) AS BB_Item_Summary
		-----------------Total Amount claimed for this program
		FROM	Billback
		LEFT JOIN _Users ON _Users.User_ID = Billback.Deviation_Ran_By
		WHERE	
			Billback.Billback_ID = '#Billback_ID#'
			AND
			Billback.Deleted = 0
	</CFQUERY>
</CFIF>
<CFOUTPUT>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
<script language="JavaScript">
function runAll(sUrl)
{
	location.href = sUrl;
	disableButton("TD_RUN_ALL", true, false);	
	return false;	
}
function runOverride()
{
	document.all.volume_override.value = 1;
	disableButton("TD_RUN_Override", true, false);
	submitForm();	
	return false;	
}
function runOverride2()
{
	document.all.rate_override.value = 1;
	disableButton("TD_RATE_Override", true, false);
	submitForm();	
	return false;	
}
function continueApproval()
{
	submitForm();
	disableButton("TD_RUN_CONTINUE_APPROVAL", true, false);	
	return false;	
}
</script>
<CFIF SHOW_NEXT_PREV EQ 1>
	<CFSET LinkTDWidth = 80>
	<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
	 		<TR>
			<TD COLSPAN="100%">
				&nbsp;
			</TD>
		</TR>
		<!------------
		<CFIF Billback_Amount_Match.recordCount GT 0>
			<CFIF Billback_Amount_Match.BB_Dollar_Amount_Mismatch NEQ 0>
			<TR ALIGN="CENTER">
				<TD COLSPAN="100%">
				<CFOUTPUT>
				<B><FONT COLOR="Red">
				Billback Amount is <CFIF Billback_Amount_Match.BB_Dollar_Amount_Mismatch LT 0>less<CFELSE>greater</CFIF>
				 than calculated Billback amount by #NumberFormat(Abs(Billback_Amount_Match.BB_Dollar_Amount_Mismatch), "(_.__)")#
				<BR>You can approve a Billback only if it matches. 
				</FONT></B>
				</CFOUTPUT>
				</TD>
			</TR>
			</CFIF>
		</CFIF>	
		------------------->
		<TR>
			<TD COLSPAN="100%">
				<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
			</TD>
		</TR>
		<TR>
		<!--- <TD ALIGN="LEFT">
			<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
			<TR>
			<CFLOOP INDEX="i" FROM="1" TO="#MAX_LEVEL#">	
				<CFIF (THIS_STEP_LEVEL_IN_LIST EQ i) OR (THIS_STEP_LEVEL_IN_LIST EQ 0 AND i EQ MAX_LEVEL)>
					<CFSET BGCOLOR = "999999">
					<CFSET FORECOLOR = "White">
					<CFSET BORDERCOLOR = "999999">
					<CFSET IMGSTR = "1.gif">
				<CFELSE>
					<CFSET BGCOLOR = "White">
					<CFSET FORECOLOR = "Black">
					<CFSET BORDERCOLOR = "999999">
					<CFSET IMGSTR = "2.gif">
				</CFIF>
				<!-----
				<TD BGCOLOR="#BGCOLOR#" STYLE="border:2px solid ###BORDERCOLOR#" WIDTH="18" HEIGHT="18" ALIGN="center" TITLE="#ListGetAt(VALIDATION_STEPS_DESC, i, ",")#"><FONT COLOR="#FORECOLOR#" SIZE="2"><B>#i#</B></FONT></TD>
				----->
				<TD><IMG SRC="/Images/Deviations/#IMGSTR#" BORDER="0" TITLE="#ListGetAt(VALIDATION_STEPS_DESC, i, ",")#"></TD>
				<CFIF i LT MAX_LEVEL>
				<TD><IMG SRC="/Images/Deviations/3.gif" BORDER="0"></TD>
				</CFIF>
			</CFLOOP>
			</TR>
			</TABLE>
		</TD> --->
<!--- 		<TD NOWRAP STYLE="font-size: 10px">&nbsp;
		<CFIF BB_UP NEQ 1>
			<CFIF THIS_STEP_LEVEL_IN_LIST GT 1 AND RUN_ROUTINES EQ 1 AND THIS_STEP_LEVEL_IN_LIST NEQ 0>
				<CFSET BorderColor = "Red">
				<CFSET TextColor = "Blue">
				<CFSAVECONTENT VARIABLE="DisplayText">
					<A HREF="Deviation.cfm?BBID=#Billback_ID#&STEP_LEVEL=#ListGetAt(VALIDATION_STEPS, Evaluate("#THIS_STEP_LEVEL_IN_LIST#-1"), ",")#">
					previous
					</A>
				</CFSAVECONTENT>
			<CFELSE>
				<CFSET BorderColor = "999999">
				<CFSET TextColor = "999999">
				<CFSET DisplayText = "previous">
			</CFIF>		
			<B>
			<FONT COLOR="#BorderColor#">[</FONT>
				<FONT COLOR="#TextColor#">
						#DisplayText#
				</FONT>
			<FONT COLOR="#BorderColor#">]</FONT>
			</B>
		</CFIF>
		</TD>
		<CFIF BB_UP NEQ 1>
			<CFIF THIS_STEP_LEVEL_IN_LIST LT MAX_LEVEL AND RUN_ROUTINES EQ 1 AND THIS_STEP_LEVEL_IN_LIST NEQ 0>
				<CFSET BorderColor = "Red">
				<CFSET TextColor = "Blue">
				<CFSAVECONTENT VARIABLE="DisplayText">
					<A HREF="Deviation.cfm?BBID=#Billback_ID#&STEP_LEVEL=#ListGetAt(VALIDATION_STEPS, Evaluate("#THIS_STEP_LEVEL_IN_LIST#+1"), ",")#">
					next
					</A>
				</CFSAVECONTENT>
			<CFELSE>
				<CFSET BorderColor = "999999">
				<CFSET TextColor = "999999">
				<CFSET DisplayText = "next">
			</CFIF>
			<TD NOWRAP STYLE="font-size: 10px">&nbsp;
			<B>
			<FONT COLOR="#BorderColor#">[</FONT>
				<FONT COLOR="#TextColor#">
					#DisplayText#				
				</FONT>
			<FONT COLOR="#BorderColor#">]</FONT>
			</B>
		</CFIF>	
		</TD> --->
		<TD NOWRAP STYLE="font-size: 10px" ID="TD_RUN_ALL" on <CFIF Billback_Amount_Match.Deviation_Ran_Date NEQ ""><CFOUTPUT>TITLE="Last Ran By: #Billback_Amount_Match.Ran_By# &##13;Date: #Billback_Amount_Match.Deviation_Ran_Date# "</CFOUTPUT></CFIF>>&nbsp;
			<CFIF Deviation_Ran_Date NEQ "" OR (RUN_ROUTINES EQ 1 AND THIS_STEP_LEVEL_IN_LIST LT MAX_LEVEL AND THIS_STEP_LEVEL_IN_LIST NEQ 0)>
				<CFSET BorderColor = "Red">
				<CFSET TextColor = "Blue">
				<CFSAVECONTENT VARIABLE="DisplayText">
					<CFIF Deviation_Ran_Date NEQ "">
						<CFSET STEP_LEVEL_Value = 1>
					<CFELSE>						
						<CFSET STEP_LEVEL_Value = #ListGetAt(VALIDATION_STEPS, Evaluate("#THIS_STEP_LEVEL_IN_LIST#"), ",")#>
					</CFIF>			
					<A HREF="##" ONCLICK="javaScript: return runAll('Deviation_Do_All.cfm?BBID=#Billback_ID#&STEP_LEVEL=#STEP_LEVEL_Value#')">
					run all
					</A>
				</CFSAVECONTENT>
			<CFELSE>
				<CFSET BorderColor = "999999">
				<CFSET TextColor = "999999">
				<CFSET DisplayText = "run all">
			</CFIF>
			<B>
			<FONT COLOR="#BorderColor#">[</FONT>
				<FONT COLOR="#TextColor#">
				 #DisplayText#				
				</FONT>
			<FONT COLOR="#BorderColor#">]</FONT>
			</B>
		</TD>	
		<CFIF Deviation_Ran_Date NEQ "" OR ((THIS_STEP_LEVEL_IN_LIST EQ MAX_LEVEL OR RUN_ROUTINES EQ 0 OR THIS_STEP_LEVEL_IN_LIST EQ 0) AND BB_Status LT 3)>
			<CFIF Billback_Amount_Match.recordCount GT 0>
				<!--- <CFIF 
				(BB_UP EQ 0 AND BB_PNF EQ 0 AND Get_Profile_Settings.BB_Approve EQ 1)
				OR
				((BB_UP EQ 1 OR BB_PNF EQ 1) AND (Get_Profile_Settings.BB_Approve_Critical EQ 1))
				> --->
					<CFSET Amount_Diff = Billback_Amount_Match.BB_Amount - Billback_Amount_Match.BB_Item_Summary>	
					<CFSET Amount_Diff = Amount_Diff * 100>
					<CFSET Amount_Diff = Round(Amount_Diff)>
					<CFSET Amount_Diff = Amount_Diff/100>
					<CFIF Amount_Diff EQ 0>
					
						<!--- DEV NOTE: 11061 Check Deviations and Set Deviated Bit--->	
						<cfquery name="evaluate_deviations" datasource="#application.datasource#">
							EXEC BB_DEVIATION_CHECK @BILLBACK_ID = '#Billback_ID#'
						</cfquery>
						
						<CFSET Print_Button_Show 		= 1>
						<CFSET Email_Button_Show 		= 1>
						<CFSET Fax_Button_Show 			= 1>
						<TD NOWRAP STYLE="font-size: 10px" ID="TD_RUN_CONTINUE_APPROVAL">
							<B>
							<FONT COLOR="Red">[</FONT>
								<FONT COLOR="Blue">
									
										<A HREF="javascript:void(0);" onClick="javascript: return continueApproval();">
											continue
										</A>
									
								</FONT>
							<FONT COLOR="Red">]</FONT>
							</B>							
						</TD>
						
						<cfif Get_Profile_Settings.BB_Volume_Override>
						<TD NOWRAP STYLE="font-size: 10px;" ID="TD_RUN_Override">&nbsp;
							<B>
							<FONT COLOR="Red">[</FONT>
								<FONT COLOR="Blue">
									
										<A HREF="javascript:void(0);" onClick="javascript: return runOverride('Deviation.cfm?BBID=#Billback_ID#&volume_override=true');">
											Volume Override
										</A>
									
								</FONT>
							<FONT COLOR="Red">]</FONT>
							</B>

							
						</TD>
						</cfif>
					   <cfif Get_Profile_Settings.BB_Rate_Override>
						    <td STYLE="font-size: 10px;" ID="TD_RATE_Override">&nbsp;
							<B>
							<FONT COLOR="Red">[</FONT>
								<FONT COLOR="Blue">
									
										<A HREF="javascript:void(0);" onClick="javascript: return runOverride2('Deviation.cfm?BBID=#Billback_ID#&rate_override=true');">
											Rate Override
										</A>
									
								</FONT>
							<FONT COLOR="Red">]</FONT>
							</B>							
						</td>
						</cfif>
						<cfset showCountNoCount = 1>
					<CFELSE>					
						<TD NOWRAP STYLE="font-size: 10px">&nbsp;
							<B>
							<FONT COLOR="Red">[</FONT>
								<FONT COLOR="Blue">
									
										<A HREF="/billbacks/capture/basic_information_form.cfm?BBID=#Billback_ID#">
											edit
										</A>
									
								</FONT>
							<FONT COLOR="Red">]</FONT>
							</B>
						</TD>
					</CFIF><!-------- <CFIF Billback_Amount_Match.BB_Dollar_Amount_Mismatch EQ 0> ---------->
				<!--- <CFELSE>
					<TD>&nbsp;
					<B>
					<FONT SIZE="2" COLOR="999999">[</FONT>
						<FONT SIZE="2" COLOR="999999">
							continue
						</FONT>
					<FONT SIZE="2" COLOR="999999">]</FONT>
					</B>	
					</TD>
				</CFIF> ---><!---------- <cfif (BB_UP EQ 0 AND BB_PNF EQ 0) OR (Get_Profile_Settings.BB_Approve_Critical) GT 0>-------------->				
			<CFELSE>
				<TD STYLE="font-size: 10px">&nbsp;
				<B>
				<FONT COLOR="999999">[</FONT>
					<FONT COLOR="999999">
						continue
					</FONT>
				<FONT COLOR="999999">]</FONT>
				</B>	
				</TD>
			</CFIF><!------------ <CFIF Billback_Amount_Match.recordCount GT 0> -------------->
		<CFELSE>
			<TD STYLE="font-size: 10px">&nbsp;
				<B>
				<FONT COLOR="999999">[</FONT>
					<FONT COLOR="999999">
						continue
					</FONT>
				<FONT COLOR="999999">]</FONT>
				</B>	
			</TD>
		</CFIF>
		</TR>
		<tr>
		 <td height="5">&nbsp;</td>
		</tr>
	</TABLE>
<CFELSEIF BB_Status GTE 3 AND (SHOW_PRINT_VERSION EQ 0 AND SHOW_FAX_EMAIL_VERSION EQ 0)>
	<CFSET Print_Button_Show 		= 1>
	<CFSET Email_Button_Show 		= 1>
	<CFSET Fax_Button_Show 			= 1>
</CFIF>
<!-----------------------------------------------------------------------
Next Prev Button
------------------------------------------------------------------------>
</CFOUTPUT>