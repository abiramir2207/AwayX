<BR><BR>


		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<TABLE ALIGN="center" CELLPADDING="20" CELLSPACING="0">
		<TR>
			<TD rowspan="3" VALIGN="top">
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><IMG SRC="/images/awayx_icon.gif" ALT="" BORDER="0"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="2" HEIGHT="1"></TD>
						<TD>&nbsp;&nbsp;<SPAN CLASS="title2" STYLE="COLOR:black;"><CFOUTPUT>#application.CompanyName#</CFOUTPUT>.net</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="2"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="2"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="175" HEIGHT="2"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;faq<BR>
							&nbsp;&nbsp;what's new<BR>
							&nbsp;&nbsp;comming soon<BR>
							&nbsp;&nbsp;about <CFOUTPUT>#application.CompanyName#</CFOUTPUT><BR>
							&nbsp;&nbsp;contact us<BR>
							&nbsp;&nbsp;statistics (how many contracts, payables etc.)<BR>
							&nbsp;&nbsp;last updated dates<BR>
							&nbsp;&nbsp;xxxxxx xxxxxxxxxx xxxxxxxxxx<BR>
						</TD>
					</TR>
				</TABLE>
			</TD>
			
			<TD VALIGN="top">
			<CFIF request.AccessStructure.User_Rights_ID LT 3000>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><IMG SRC="/images/contracts_icon_not.gif" ALT="" BORDER="0"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;&nbsp;<SPAN CLASS="title2" STYLE="COLOR:gray;">contracts</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							<SPAN STYLE="COLOR:gray;">
							&nbsp;&nbsp;create<BR>
							&nbsp;&nbsp;search<BR>
							&nbsp;&nbsp;product blaster!<BR>
							&nbsp;&nbsp;hq <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s
							</SPAN>
						</TD>
					</TR>
				</TABLE>
			<CFELSE>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><A HREF="/common_files/contracts/index.cfm"><IMG SRC="/images/contracts_icon.gif" ALT="" BORDER="0"></A></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:BLACK;">contracts</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;<A HREF="/common_files/contracts/contract_create_1_form.cfm">create</A><BR>
							&nbsp;&nbsp;<A HREF="/common_files/contracts/contract_search.cfm">search</A><BR>
							&nbsp;&nbsp;<A HREF="/common_files/contracts/broadcast_products/select_products.cfm">product blaster!</A><BR>
							&nbsp;&nbsp;<A HREF="/common_files/hq_rebates/hq_rebate_create_1_form.cfm">hq <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s</A>
						</TD>
					</TR>
				</TABLE>
			</CFIF>		
			</TD>
			<TD VALIGN="top">
			<CFIF request.AccessStructure.User_Rights_ID LT 4000>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><IMG SRC="/images/payables_icon_not.gif" ALT="" BORDER="0"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:gray;">payables</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							<SPAN STYLE="COLOR:gray;">
							&nbsp;&nbsp;create<BR>
							&nbsp;&nbsp;search<BR>
							&nbsp;&nbsp;upload
							</SPAN>
						</TD>
					</TR>
				</TABLE>
			<CFELSE>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><A HREF="/common_files/payables2/index.cfm"><IMG SRC="/images/payables_icon.gif" ALT="" BORDER="0"></A></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:BLACK;">payables</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;<A HREF="/common_files/payables2/payable_create_1_form.cfm">create</A><BR>
							&nbsp;&nbsp;<A HREF="/common_files/payables2/payable_search_form.cfm">search</A><BR>
							&nbsp;&nbsp;<A HREF="/uploads/payables.cfm">upload</A>
						</TD>
					</TR>
				</TABLE>
			</CFIF>
			</TD>
		</TR>
		<TR>
			<TD VALIGN="top">
			<CFIF request.AccessStructure.User_Rights_ID LT 2000>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><IMG SRC="/images/profiles_icon_not.gif" ALT="" BORDER="0"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:gray;">profiles</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							<SPAN STYLE="COLOR:gray;">
							&nbsp;&nbsp;brokers<BR>
							&nbsp;&nbsp;<cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput><BR>
							&nbsp;&nbsp;<cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput><BR>
							&nbsp;&nbsp;products<BR>
							&nbsp;&nbsp;freight calculator
							</SPAN>
						</TD>
					</TR>
				</TABLE>
			<CFELSE>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><A HREF="/common_files/admin.cfm"><IMG SRC="/images/profiles_icon.gif" ALT="" BORDER="0"></A></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:BLACK;">profiles</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;<A HREF="/profiles/brokers/index.cfm">brokers</A><BR>
							&nbsp;&nbsp;<A HREF="/profiles/distributors/index.cfm"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></A><BR>
							&nbsp;&nbsp;<A HREF="/profiles/operators/index.cfm"><cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></A><BR>
							&nbsp;&nbsp;<A HREF="/profiles/products/index.cfm">products</A><BR>
							&nbsp;&nbsp;<A HREF="/profiles/freight_charges/index.cfm">freight calculator</A>
						</TD>
					</TR>
				</TABLE>
			</CFIF>
			</TD>
			<TD VALIGN="top">
		
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><A HREF="/reports/index.cfm"><IMG SRC="/images/reports_icon.gif" ALT="" BORDER="0"></A></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:BLACK;">reports</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="50"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;<A HREF="/reports/report_wizard_3.cfm">report wizard</A><BR>
							&nbsp;&nbsp;<A HREF="/reports/canned/index.cfm">formatted reports</A>
						</TD>
					</TR>
				</TABLE>
		
			</TD>
		</TR>
		<TR>
			<TD VALIGN	"top">
			<CFIF request.AccessStructure.User_Rights_ID LT 4000>
			 	<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><IMG SRC="/images/pda_icon_not.gif" ALT="" BORDER="0"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:gray;">pda exports</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIHEIGHT="75"GHT="65"></TD>
						<TD VALIGN="top">
							<SPAN STYLE="COLOR:gray;">
							&nbsp;&nbsp;receive data<BR>
							&nbsp;&nbsp;send data
							</SPAN>
						</TD>
					</TR>
				</TABLE>
			<CFELSE>
			 	<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><A HREF="/pda_stuff/index.cfm"><IMG SRC="/images/pda_icon.gif" ALT="" BORDER="0"></A></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:BLACK;">pda exports</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIHEIGHT="75"GHT="65"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;<A HREF="/pda_stuff/index.cfm">receive data</A><BR>
							&nbsp;&nbsp;<A HREF="/pda_stuff/index.cfm">send data</A>
						</TD>
					</TR>
				</TABLE>
			</CFIF>
			</TD>
			<TD VALIGN="top">
			<CFIF request.AccessStructure.User_Rights_ID LT 3000>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><IMG SRC="/images/settings_icon_not.gif" ALT="" BORDER="0"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:gray;">settings</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIHEIGHT="75"GHT="65"></TD>
						<TD VALIGN="top">
							<SPAN STYLE="COLOR:gray;">
							&nbsp;&nbsp;change password<BR>
							&nbsp;&nbsp;preferences<BR>
							&nbsp;&nbsp;view mail log
							</SPAN>
						</TD>
					</TR>
				</TABLE>
			<CFELSE>
				<TABLE border="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD><A HREF="/settings/index.cfm"><IMG SRC="/images/settings_icon.gif" ALT="" BORDER="0"></A></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD>&nbsp;<SPAN CLASS="title2" STYLE="COLOR:BLACK;">settings</SPAN></TD>
					</TR>
					<TR>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIDTH="150" HEIGHT="1"></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD BGCOLOR="Silver"><IMG SRC="/images/fill.gif" WIHEIGHT="75"GHT="65"></TD>
						<TD VALIGN="top">
							&nbsp;&nbsp;<A HREF="/settings/control_panel.cfm">change password</A><BR>
							&nbsp;&nbsp;<A HREF="/settings/control_panel.cfm?Tab=2">preferences</A><BR>
							&nbsp;&nbsp;<A HREF="/administrivia/view_email_log.cfm">view mail log</A>
						</TD>
					</TR>
				</TABLE>
			</CFIF>
			</TD>
		</TR>
		</TABLE>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

