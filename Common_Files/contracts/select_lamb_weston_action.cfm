<cf_cryp type="de" string="#FORM.HQR_ID#" key="#request.key#">

<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->
<!---   Need to add user/company_main constriction to data    --->
<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->

<cfset aryComp = ArrayNew(2)>
<cfset aryProd = ArrayNew(2)>

	<cfoutput>
	<cfset fields = ListToArray(fieldnames)>
		<cfloop index="i" from="1" to="#ListLen(fieldnames)#">
			<cfif (Left(fields[i], 9) is "Incl_Prod")>
				<cfset prod = Evaluate(#fields[i]#)>
					<cfif (prod neq '')>
						<cfif Right(fields[i], 1) eq "_">
							<cfset fields[i] = Left(fields[i], Len(fields[i]) - 1)>
						</cfif>
						<cfset fields[i] = replace(fields[i], "__", "-", "ALL")>
						<cfset z = ListToArray(fields[i], "_")>
						<cfif #z[7]# IS "UPD">
							 <cfset useLakebaseForupdLambProductSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("lamb_requirements_products")>
<cfif useLakebaseForupdLambProductSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("lamb_requirements_products",
			{
				"program_component_id" = "eq.#z[2]#",
				"assoc_dist_id" = "eq.#z[3]#",
				"assoc_program_id" = "eq.#z[4]#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdLambProductSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdLambProductSettings>
<cfquery name="updLambProductSettings" datasource="#application.datasource#">
								 UPDATE lamb_requirements_products
								 Set deleted = 1
								 WHERE Program_Component_ID	= '#z[2]#'
								 AND Assoc_Dist_ID = #z[3]#
								 AND Assoc_Program_ID = #z[4]#
							</cfquery>
</cfif> 
						</cfif>
					</cfif>
			</cfif>
		</cfloop>
	</cfoutput>
	
   <cfoutput>
   	<cfset fields = ListToArray(fieldnames)>
			<cfloop index="i" from="1" to="#ListLen(fieldnames)#">
				<!--- // Component: Discount --->	
				<cfif (Left(fields[i], 15) is "Comp_Rate_Disco")>
					<cfset discount = Evaluate(#fields[i]#)>
					<cfif (discount neq '')>
					<cfif Right(fields[i], 1) eq "_">
						<cfset fields[i] = Left(fields[i], Len(fields[i]) - 1)>
					</cfif>
						<cfset fields[i] = replace(fields[i], "__", "-", "ALL")>
						<cfset z = ListToArray(fields[i], "_")>
						<!--- // dist_id == Distributor_ID --->
							<cfset dist_id = z[4]>
						<!--- // pcid == Program_Component_ID --->	
							<cfset pcid = z[5]>
						<!--- // HQRC_ID == HQ_Rebate_Component_ID --->
							<cfset HQRC_ID = z[6]>
						<!--- // APID == Assoc_Prog_ID --->	
							<cfset APID = z[7]>
						<!--- // not all have step values --->
							<cfif ArrayLen(z) gt 8>
								<cfset Step = z[9]>
							<cfelse>
								<cfset Step = 0>
							</cfif>
												
						<br><B>FIELDS:</B> <B>#fields[i]#</B><br>
						<B>DIST:</B> 		#dist_id#<br>
						<B>PCID: </B>		#pcid#<br>
						<B>HQRC_ID:</B> 	#HQRC_ID#<br>
						<B>APID: </B>		#APID#<br>
						<B>Step:</B> 		#Step# <br>
						<B>Discount:</B> 	#discount#<br><br>
						
						<!--- // set to array for query --->
						<cfset aryComp[i][1] = #dist_id#>
						<cfset aryComp[i][2] = #pcid#>
						<cfset aryComp[i][3] = #HQRC_ID#>
						<cfset aryComp[i][4] = #APID#>
						<cfset aryComp[i][5] = #discount#>
						<!--- // insert first five parts of component record --->
						<cfif #z[8]# IS "UPD"> 
							<cfset useLakebaseForupdLambSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("lamb_requirements")>
<cfif useLakebaseForupdLambSettings>
	<cftry>
		<cfset application.oLakebase.updateRows("lamb_requirements",
			{
				"hq_rebate_component_id" = "eq.#aryComp[i][3]#",
				"assoc_dist_id" = "eq.#aryComp[i][1]#"
			},
			{
				"hq_rebate_component_id" = "#aryComp[i][3]#",
				"comp_rate_discount" = "#aryComp[i][5]#",
				"assoc_dist_id" = "#aryComp[i][1]#",
				"assoc_program_id" = "#aryComp[i][4]#",
				"program_component_id" = "#aryComp[i][2]#",
				"hq_rebate_id" = "#cryp.value#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdLambSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdLambSettings>
<cfquery name="updLambSettings" datasource="#application.datasource#">
								 UPDATE lamb_requirements
									SET HQ_Rebate_Component_ID 	= #aryComp[i][3]#,
										Comp_Rate_Discount 		= #aryComp[i][5]#,
										Assoc_Dist_ID 			= #aryComp[i][1]#,
										Assoc_Program_ID 		= #aryComp[i][4]#,
										Program_Component_ID 	= '#aryComp[i][2]#',
										HQ_Rebate_ID 			= #cryp.value#
									WHERE
										HQ_Rebate_Component_ID 	= #aryComp[i][3]#
										AND Assoc_Dist_Id 		= #aryComp[i][1]#
							</cfquery>
</cfif>
						<cfelseif #z[8]# IS "INS">
							<cfset useLakebaseForinsLambSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("lamb_requirements")>
<cfif useLakebaseForinsLambSettings>
	<cftry>
		<cfset application.oLakebase.insertRow("lamb_requirements", {
			"hq_rebate_component_id" = "#aryComp[i][3]#",
			"comp_rate_discount" = "#aryComp[i][5]#",
			"assoc_dist_id" = "#aryComp[i][1]#",
			"assoc_program_id" = "#aryComp[i][4]#",
			"program_component_id" = "#aryComp[i][2]#",
			"hq_rebate_id" = "#cryp.value#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsLambSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsLambSettings>
<cfquery name="insLambSettings" datasource="#application.datasource#">
								INSERT INTO lamb_requirements
									(
										HQ_Rebate_Component_ID,
										Comp_Rate_Discount,
										Assoc_Dist_ID,
										Assoc_Program_ID,
										Program_Component_ID,
										HQ_Rebate_ID
									)
								Values
									(
										#aryComp[i][3]#,
										#aryComp[i][5]#,
										#aryComp[i][1]#,
										#aryComp[i][4]#,
										'#aryComp[i][2]#',
										#cryp.value#
									)
							</cfquery>
</cfif>
						</cfif>
					</cfif>
				</cfif>
				<!--- // Component: Delta --->
				<cfif (Left(fields[i], 15) is "Comp_Rate_Delta")>
					<cfset delta = Evaluate(#fields[i]#)>
					<cfif (delta neq '')>
						<!--- <cfset secndCut = #FindNoCase("_", fields[i], 20)# + 1> --->
						<cfset fields[i] = replace(fields[i], "__", "-", "ALL")>
						<cfset z = ListToArray(fields[i], "_")>
						<!--- // dist_id == Distributor_ID --->
						<cfset dst_id = z[4]>
						<!--- // pcid == Program_Component_ID --->
						<cfset pcid = z[5]>
						<!--- // HQRC_ID == HQ_Rebate_Component_ID --->
						<cfset HQRCo_ID = z[6]> 
						<!--- // APID == Assoc_Prog_ID --->	
							<cfset APrID = z[7]>
							
						<br><B>FIELDS:</B> <b>#fields[i]#</b><br>
						<B>DIST: </B>		#dist_id#<br>
						<B>PCID:</B> 		#pcid#<br>
						<B>HQRC_ID:</B> 	#HQRC_ID#<br>
						<B>DELTA:</B> 		#delta#<br><br>
						
						<!--- // set to array for query --->
						<cfset aryComp[i][6] = #delta#>
						<cfset aryComp[i][3] = #HQRCo_ID#>
						<cfset aryComp[i][1] = #dst_id#>
						<!--- // insert sixth and last part of component record --->
						<!--- <cfif #z[8]# IS "UPD">
							<cfquery name="updLambSettings" datasource="#application.datasource#">
								UPDATE lamb_requirements
								SET	Comp_Rate_Delta	 		 	= #aryComp[i][6]#
								WHERE HQ_Rebate_Component_ID 	= #aryComp[i][3]#
								AND Assoc_Dist_Id 				= #aryComp[i][1]#
								AND HQ_Rebate_ID 				= #cryp.value#
							</cfquery> 
						<cfelseif #z[8]# IS "INS"> --->
							<cfquery name="updLambSettings" datasource="#application.datasource#">
								UPDATE lamb_requirements
								SET	Comp_Rate_Delta	 		 	= #aryComp[i][6]#
								WHERE HQ_Rebate_Component_ID 	= #aryComp[i][3]#
								AND Assoc_Dist_Id 				= #aryComp[i][1]#
							</cfquery> 
						<!--- </cfif>  --->
					</cfif>
				</cfif> 
				<!--- // Products --->					
				<cfif (Left(fields[i], 9) is "Incl_Prod")>
				<cfset prod = Evaluate(#fields[i]#)>
					<cfif (prod neq '')>
						<cfset fields[i] = replace(fields[i], "__", "-", "ALL")>
						<cfset z = ListToArray(fields[i], "_")>
						<cfset p_dst_id = z[3]>
						<!--- // PUPC == Product_UPC --->
						<cfset PUPC_prod = z[4]>
						<!--- // PCID == Program_Component_ID --->
						<cfset PCID = z[5]> 
						<!--- // APID == Assoc_Prog_ID --->	
						<cfset APID = z[6]>
						<!--- // set to array for query --->
						
						<!--- // Products --->
						<B>FIELDS:</B> <b>#fields[i]#</b><br>
						<B>Dist:</B>  	#p_dst_id#<br>
						<B>UPC:</B>		#PUPC_prod#<br>
						<B>PCID:</B>  	#PCID#<br>
						<B>APID:'#prod#'</B>	#APID#<br><br>
						
					   	<cfset aryProd[i][1] = #PUPC_prod#>
					    <cfset aryProd[i][2] = #PCID#>
						<cfset aryProd[i][3] = #p_dst_id#>
						<cfset aryProd[i][4] = #APID#>
						<!--- // insert component products changes --->
						<cfset r = replace(fields[i], "-", "__", "ALL")>
						<cfif #z[7]# IS "UPD">
							 <cfquery name="updLambProductSettings" datasource="#application.datasource#">
								 UPDATE lamb_requirements_products
								 Set deleted = 0
								 WHERE 
								 (Assoc_Program_ID 	= #aryProd[i][4]#
								 AND Assoc_Dist_Id 	= #aryProd[i][3]#		
								 AND UPC			= '#aryProd[i][1]#')
							</cfquery>
						<cfelseif #z[7]# IS "INS">
							 <cfset useLakebaseForinsLambProductSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("lamb_requirements_products")>
<cfif useLakebaseForinsLambProductSettings>
	<cftry>
		<cfset application.oLakebase.insertRow("lamb_requirements_products", {
			"program_component_id" = "#aryProd[i][2]#",
			"upc" = "#aryProd[i][1]#",
			"assoc_dist_id" = "#aryProd[i][3]#",
			"assoc_program_id" = "#aryProd[i][4]#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsLambProductSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsLambProductSettings>
<cfquery name="insLambProductSettings" datasource="#application.datasource#">
								INSERT INTO lamb_requirements_products
									(
										Program_Component_ID,
										UPC,
										Assoc_Dist_ID,
										Assoc_Program_ID
									)
								Values
									(
										'#aryProd[i][2]#',
										'#aryProd[i][1]#',
										#aryProd[i][3]#,
										#aryProd[i][4]#
									 )
							</cfquery>
</cfif> 
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfoutput>
