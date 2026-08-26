<cfcomponent hint="Product Messages">
<!--- Another function for Volume messages is on components/volume/VolumeApplicator.cfc --->
		<cffunction name="GetMessageSettings" output="false" returntype="query">
			
		<cfargument name="Program_ID" type="string" required="true" />
		<cfargument name="DiscountType" type="numeric" required="true" />

		<!--- Get the message setting for the discount type being used on this page i.e. whether the message needs to be shown or not --->
		<cfquery name="qGetMessageSettings" datasource="#application.datasource#">
			SELECT	
					<cfif arguments.DiscountType eq 1>
					CASE 
					WHEN cmad.Show_Fixed_Prices_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_Fixed_Prices_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelseif  arguments.DiscountType eq 2>
					CASE 
						WHEN cmad.Show_Rebates_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_Rebates_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelseif  arguments.DiscountType eq 3>
					CASE 
						WHEN cmad.Show_Lump_Sums_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_Lump_Sums_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelseif  arguments.DiscountType eq 4>
					CASE 
						WHEN cmad.Show_Growth_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_Growth_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelseif arguments.DiscountType eq 5>
					CASE 
						WHEN cmad.Show_Formula_Pricing_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_Formula_Pricing_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelseif  arguments.DiscountType eq 8>
					CASE 
						WHEN cmad.Show_OffInvoice_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_OffInvoice_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelseif  arguments.DiscountType eq 10>
					CASE 
						WHEN cmad.Show_BidRequest_Related_Message = 1 AND RTRIM(LTRIM(pcpo.Discount_BidRequest_Product_Message)) ! = ''
							THEN '1' 
							ELSE '0' 
					END
					<cfelse>
					<!--- Some other discount types can be added in the future. I have added a zero (0) for avoiding an error --->
					'0'
					</cfif>
				As Message_Settings
					FROM Contract_Main_Aux_Data cmad			
						INNER JOIN Contract_Main cm
							ON cmad.Contract_Main_ID = cm.Contract_Main_ID
						INNER JOIN	Program_Control_Panel_Options pcpo
							ON (cm.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID)		
					WHERE cmad.Contract_Main_ID = #Program_ID#
		</cfquery>
			<cfreturn qGetMessageSettings />
				
		</cffunction>
	
</cfcomponent>