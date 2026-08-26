<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<html>
<head>
	<title>Applied <cfoutput>#appsettings.getPullbackLabel()#</cfoutput></title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>

<cfinclude template="/get_access_profile.cfm">

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<cfparam name="url.BB_ID" default="" />
<cfparam name="url.fromdeletepage" default="0" />
<cfparam name="url.inline" default="0" />

<cfif url.BB_ID NEQ "">

					<!----------------- Add Spinner ------------------------>
					 <cfif url.fromdeletepage EQ 0>
						<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
						 <br><br><br>
						 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
						 <br><br><br>
						</SPAN>
					
					<SCRIPT>
						document.all.PleaseWaitMessage.style.display='none';
					</SCRIPT>
					</cfif>
					<!----------------- Add Spinner ------------------------>
					
					<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
					
					<!--- Get all the Opr and Local Dis BB that are already applied to this current Dis Corp BB --->
					<cfset GetBillbackstoApply = PullbackManager.GetBillbackstoApply(Dis_BB_Id=url.BB_ID,appliedpullbacks=1)>
					
					<!--- Check if any Growth pullback amount is applied to this current BB --->
					<cfset checkifBBhasGrowth = PullbackManager.checkifBBhasGrowth(url.BB_Id,1)>
					
					<cfif checkifBBhasGrowth.recordcount GT 0>
					<cfloop query="checkifBBhasGrowth">
						<cfset temp = QueryAddRow(GetBillbackstoApply)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_billback_id", checkifBBhasGrowth.pullback_billback_id )>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_from_program_number", checkifBBhasGrowth.pullback_from_program_number)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "BB_title",checkifBBhasGrowth.BB_title)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_reference",checkifBBhasGrowth.bb_reference )>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_code",checkifBBhasGrowth.bb_code )>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_start_date", checkifBBhasGrowth.bb_start_date)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_end_date",checkifBBhasGrowth.bb_end_date )>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "contract_number",checkifBBhasGrowth.contract_number )>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "revision_version", checkifBBhasGrowth.revision_version)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "discount_type_desc", checkifBBhasGrowth.discount_type_desc)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "discount_type_id", checkifBBhasGrowth.discount_type_id)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "Product_BB_Volume_LB", checkifBBhasGrowth.Volume_LB)>
						<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_amount", checkifBBhasGrowth.pullback_amount)>
					</cfloop>
					</cfif>
					
					<cfquery name="SortBillbackstoApply" dbtype="query">
							select * 
							from GetBillbackstoApply
							order by bb_end_date desc, pullback_billback_id, contract_number, name 
					</cfquery>
					
					
					<FORM ACTION="pullbacksapply_action.cfm" METHOD="post" NAME="ApplyPullbacksAction" STYLE="DISPLAY:INLINE">
					<TABLE width="100%" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center">
								 <TR  bgcolor="ffce84"><!--- ffcc33 --->
											 <TD>&nbsp;</TD>
											 <TD id="header" valign="top"><cfif url.fromdeletepage EQ 0><input name="pullback_check_all" type="checkbox" onClick="selectall(this);" checked></cfif><strong>Billback Id</strong></TD>
											 <TD id="header" valign="top"> <strong>Reference Id</strong></TD>
											 <TD id="header" valign="top"> <strong>Title</strong></TD>
											 <TD id="header" valign="top"> <strong>Start Date</strong></TD>
											 <TD id="header" valign="top"> <strong>End Date</strong></TD>
								 </TR>
					 <cfif GetBillbackstoApply.recordcount GT 0>
							 <cfoutput query="SortBillbackstoApply" group="pullback_billback_id">
							 	<cfset strPullbackBillbackID = replace(pullback_billback_id,'-','_','ALL') />
										 <TR bgcolor="8B0000"><!--- C6FFC6 --->
													 <TD>&nbsp;</TD>
													 <TD valign="top" style="font-size: 12px; color:white;"><cfif url.fromdeletepage EQ 0><span ID="checkAllPullbacks"><input name="pullback_check_all_bb" type="checkbox" onClick="selectall(this,'#strPullbackBillbackID#');" checked></span></cfif>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#BB_Code#</TD>
													 <TD valign="top" style="font-size: 12px; color:white;">#BB_reference#</TD>
													 <TD valign="top" style="font-size: 12px; color:white;">#BB_title#</TD>
													 <TD valign="top" style="font-size: 12px; color:white;">#dateformat(BB_Start_Date,"mm/dd/yyyy")#</TD>
													 <TD valign="top" style="font-size: 12px; color:white;">#dateformat(BB_End_Date,"mm/dd/yyyy")#</TD>
										 </TR>
										 <TR>
													<TD colspan="100%" style="border:none;">
																	<TABLE width="98%" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center">
																	 <TR bgcolor="ffce84"><!--- FFE083 --->
																				<TD>&nbsp;</TD>
																				<TD valign="top"> <strong>Contract Number<br>#application.returned_customer_setting.Shard_Ship_To_Label#</strong></TD>
																				<TD valign="top"> <strong>Item<br>Description</strong></TD>
																				<TD valign="top"> <strong>Discount<br>Type</strong></TD>
																				<TD valign="top"> <strong>Vol. CS</strong></TD>
																				<TD valign="top"> <strong>#appsettings.getPullbackLabel()#<br> %</strong></TD>
																				<TD valign="top"> <strong>Rate/CS</strong></TD>
																				<cfif appSettings.getBudgetsFunctionalityOn()>
																				<TD valign="top"> <strong>Net Due</strong></TD>
																				</cfif>
																				<TD valign="top"> <strong>#appsettings.getPullbackLabel()# <br>Amt.</strong></TD>
														 			</TR>
									 <cfoutput> 
											 <cfif Evaluate(SortBillbackstoApply.currentRow mod 2) eq 0>
												<cfset tmpBgColor = "FFFFFF" />
											<cfelse>
												<cfset tmpBgColor = "ccffcc" />
											</cfif>
									 <cfif discount_type_id NEQ 4>
																	 <TR bgcolor="#tmpBgColor#">
																		 <cfset uniqueKey = "#pullback_billback_id#_#discount_type_id#_#product_id#_#customer_id#" />
																				 <TD valign="top"> <cfif url.fromdeletepage EQ 0><span ID="checkAllPullbacks#strPullbackBillbackID#"><span ID="checkAllPullbacks"><input type="checkbox" name="pullback_billback_ids" checked value="#uniqueKey#" pullbackAmount="#pullback_amount#"></span></span><cfelse>&nbsp;</cfif></TD>
																				 <TD>#application.oBBReportGet.getProgramLink("#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif>",Contract_Main_ID)#
																					 <br>#name#<br>(#shr_ship_to#)
																				</TD>
																				 <TD width="200" valign="top">#Item#<br>#Description#</TD>
																				  <TD>#Discount_type_desc#</TD>
																				<cfif Product_BB_Volume_LB neq "">
																					<cfset Product_BB_Volume_CS = Product_BB_Volume_LB / net_weight />
																				<cfelse>
																					<cfset Product_BB_Volume_CS = Product_BB_Volume_LB />
																				</cfif>
																				 <TD>#numberformat(Product_BB_Volume_CS,'_,___,___,___,___')#</TD>
																				 <TD>#pullback_percent#</TD>
																				<cfif paid_rate neq "">
																					<cfset paid_rate_cs = paid_rate * net_weight />
																				<cfelse>
																					<cfset paid_rate_cs = paid_rate />
																				</cfif>
																				 <TD>$#numberformat(paid_rate_cs,'999,999,999.9999')#</TD>
																				<cfif appSettings.getBudgetsFunctionalityOn()>
																				 <TD>#DollarFormat(Budget_Recapture_Amount)#</TD>
																				</cfif>
																				 <TD>#DollarFormat(pullback_amount)#</TD>
																				 <input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_budget" value="#Budget_Recapture_Amount#">
																				 <input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_amount" value="#pullback_amount#">
																				<input type="Hidden" name="pullback_billback_#replace(uniqueKey,'-','_','ALL')#_rate" value="#paid_rate#">
																	 </TR>
									 <cfelse>
									 <!------ 
									 <cfset PullbackManager.ExecuteGrowthSP(url.BB_ID,pullback_billback_id)> 
									 <cfset GrowthPullbackAmount = PullbackManager.GrowthPullbackAmount(url.BB_ID,pullback_billback_id)>
									  ----->
																	 <TR bgcolor="ffff99">
																				<TD>  <cfif url.fromdeletepage EQ 0><span ID="checkAllPullbacks"><input type="checkbox" name="pullback_billback_growth_ids" checked value="#pullback_billback_id#" pullbackAmount="#pullback_amount#"></span><cfelse>&nbsp;</cfif>  </TD>
																				<cfif url.fromdeletepage EQ 0>
																				<input type="hidden" name="growthamount_#replace(pullback_billback_id,'-','_','ALL')#" value="#GrowthPullbackAmount#">
																				<input type="hidden" name="growthvolume_#replace(pullback_billback_id,'-','_','ALL')#" value="#Product_BB_Volume_LB#">
																				</cfif>
																				<TD><strong>#Replace(Contract_Number,"000-","")#-<cfif len(revision_version) eq 4>#right("#revision_version#", 4)#<cfelseif len(revision_version) eq 5>#right("#revision_version#", 5)#<cfelse>#right("000#revision_version#", 3)#</cfif></strong></TD>
																				<TD width="200"><A HREF="##" onClick="javaScript: submitfordetails('#pullback_billback_id#','#url.BB_ID#','#GrowthPullbackAmount#','#Product_BB_Volume_LB#');" TITLE="View #appsettings.getPullbackLabel()# Details">View Details</A></TD>
																				<TD>Growth</TD>
																				<TD>#numberformat(Product_BB_Volume_LB,'_,___,___,___,___')#</TD>
																				<TD>&nbsp;</TD>
																				<TD>&nbsp;</TD>
																				<TD>#dollarformat(pullback_amount)#</TD>
																	</TR>
									 </cfif>
									  </cfoutput> 
							 										</TABLE>
							 			</TD>
								 </TR>
							 </cfoutput>
					 
												<TR>
															<cfset GetPullbackInfo = PullbackManager.getPullbackAppliedInfo(url.BB_Id) />
															<input type="hidden" name="Dis_BB_Id" value="<cfoutput>#url.BB_ID#</cfoutput>">
															<input type="hidden" name="unapplypullbacks" value="1">
															<TD colspan="100%" align="right" style="border:none;"><strong>Total <cfoutput>#Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)# Amount: #DollarFormat(GetPullbackInfo.Pullback_applied_Amount)#</cfoutput></strong></TD>
												<TR>
					<cfelse>
												<TR>
															<TD colspan="100%">No Billbacks available to apply.</TD>
												</TR>
					</TABLE>
					</FORM>
					</cfif>
					
					
					
					<TABLE align="center">
						<TR>
								<cfif GetBillbackstoApply.recordcount GT 0 and url.fromdeletepage EQ 0>
										<TD align="left">
												<cfif Get_Profile_Settings.BB_UnApply_Pullback>
															<CF_button
															button_name		=	""
															button_caption	=	"un-apply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
															button_action	=	"UnApplyPullbacks();"
															button_type		=	"javascript_link"
															button_width	=	"150"
															button_color	=	"Navy"
															button_tip		=	"UnApply <cfoutput>#appsettings.getPullbackLabel()#</cfoutput>"
															font_color		=	"White"
															font_size		=	"12"
															font_weight		=	"bold"
															>
												<cfelse>
															<CF_smallLink 
															title = "un-apply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>" 
															url = "##"
															enabled = 0
															>
												</cfif> 
										</TD>
								</cfif>
						 
										<TD align="left">
												<cfif url.inline EQ 0>
														<CF_button
														button_name		=	""
														button_caption	=	"close"
														button_action	=	"window.close();"
														button_type		=	"javascript_link"
														button_width	=	"150"
														button_color	=	"Navy"
														button_tip		=	"Close Window"
														font_color		=	"White"
														font_size		=	"12"
														font_weight		=	"bold" >
												</cfif>
										</TD>
						</TR>
					</TABLE>

<cfelse>
	 <div align="center"><strong>Invalid Billback Number</strong></div>
</cfif>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js"/>
<script>
		function UnApplyPullbacks()
				{
							var obj = window.checkAllPullbacks;
							var pullbackselected = false;
							var totalAmountSelected = 0, currentAmount;
									if(obj != null)
									{
												if(obj.length)
														{
																for(var x=0; x<obj.length;x++)
																		{
																				box = getFirstChild(obj[x])
																				if(box.checked)
																						{
																							pullbackselected = true;					
																						}
																				else
																						{
																							currentAmount = parseFloat(box.pullbackAmount);
																							if(isNaN(currentAmount)) currentAmount = 0;
																							totalAmountSelected = totalAmountSelected + currentAmount;
																						}
																		}
														}
												else
														{
																	box = getFirstChild(obj)
																	if(box.checked)
																			{
																				pullbackselected = true;				
																			}
																	else
																			{
																				currentAmount = parseFloat(box.pullbackAmount);
																				if(isNaN(currentAmount)) currentAmount = 0;
																				totalAmountSelected = totalAmountSelected + currentAmount;
																			}
														}
									}
							
							if (pullbackselected == false)
									{ 
											alert("Please select atleast one pullback to apply");
									}
							else
									{
										document.all.ApplyPullbacksAction.submit();
									}
							
							//document.all.ApplyPullbacksAction.submit();
					
				}
		function selectall(headercheckbox)
		{
			var obj, bblevel;
			if(arguments[1])
			{
				obj = eval("window.checkAllPullbacks" + arguments[1]);
				bblevel = 1;												
			}
			else
			{
				obj = window.checkAllPullbacks;
				bblevel = 0;
			} 
			
			if(obj != null)
			{
				if(obj.length)
				{
					for(var x=0; x<obj.length;x++)
					{
						box = getFirstChild(obj[x]);
						if(bblevel) box = getFirstChild(box);
						
						if(box.disabled == false)
						{
							box.checked = headercheckbox.checked;
						}
						else
						{
							box.disabled = true;
						}
					}
				}
				else
				{
					box = getFirstChild(obj);
					if(bblevel) box = getFirstChild(box);
					box.checked = headercheckbox.checked;
				}
			}
		}
		function submitfordetails(opr_BB_id,dis_BB_id,growth_pullback_amount,growth_pullback_volume)
				{
						NewWindow('/billbacks/approval/viewdetailsonpullbacks.cfm?dis_BB_id='+dis_BB_id+'&opr_BB_Id='+opr_BB_id+'&Growthpullbackamount='+growth_pullback_amount+'&growthpullbackvolume='+growth_pullback_volume+'&appliedpullback=1','pullbackviewdetails','800','620','Yes', 'No');
				}
</script>