<!------ nextPage.cfm ----->
<cfset form.nextCommand = "view" />

<!------ check if there is any analysts set up ----->
<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />

<cfif qGetAnalysts.recordCount EQ 0>

	<cfset form.nextCommand = "analyst" />
	
<cfelse>
	
	<!------ check if there is any default analysts set up ----->
	<cfset qGetDefaultAnalyst = billbackAssignmentManager.getAnalysts(bDefaultAnalyst = 1) />
	
	<cfif qGetDefaultAnalyst.recordCount EQ 0>

		<cfset form.nextCommand = "analyst" />
	
	<cfelse>
	
		<!------ check if all markets are assigned to some market ----->
		<cfset qGetAvailableMarkets = billbackAssignmentManager.getAvailableMarkets() />
		
		<cfif qGetAvailableMarkets.recordCount GT 0>

			<cfset form.nextCommand = "market" />

		<cfelse>
		
			<!------ check if there is any supervisor set up ----->
			<cfset qGetSupervisors = billbackAssignmentManager.getSupervisors() />
			
			<cfif qGetSupervisors.recordCount EQ 0>

				<cfset form.nextCommand = "supervisor" />
				
			<cfelse>
				<cfif form.nextCommand eq "supervisor">
					<!------ check if there is supervisor assigned to all analysts ----->
					<cfset qGetAvailableAnalysts = billbackAssignmentManager.getAvailableAnalysts() />
				
					<cfif qGetAvailableAnalysts.recordCount GT 0>

						<cfset form.nextCommand = "assign-supervisor" />
					
					</cfif>
				<cfelse>
					<!------ check if there is any director set up ----->
					<cfset qGetDirectors = billbackAssignmentManager.getDirectors() />
			
					<cfif qGetDirectors.recordCount EQ 0>

						<cfset form.nextCommand = "director" />
				
					<cfelse>
			
						<!------ check if there is supervisor assigned to all analysts ----->
						<cfset qgetAvailableSupervidors = billbackAssignmentManager.getAvailableSupervidors() />
				
						<cfif qgetAvailableSupervidors.recordCount GT 0>

							<cfset form.nextCommand = "assign-director" />
					
						</cfif>
					</cfif>
				
				</cfif>				
			</cfif>
			
		</cfif>
	
	</cfif>
	
</cfif>
