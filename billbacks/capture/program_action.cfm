<!--- <cfquery name="deleteExistingProducts" datasource="#Application.Datasource#">
	UPDATE Billback_Product
	SET Deleted = 1
	WHERE Billback_ID = '#FORM.BillBack_ID#'
</cfquery> --->









<CFABORT>
<cfloop index="FormFiedlName" list="#FORM.Fieldnames#" delimiters=",">
	 <!--- <cfoutput>#FormFiedlName#</cfoutput> --->
	<CFSET tempArray = listtoarray(FormFiedlName,"Z")>
	<!--- <CFDUMP var="#tempArray#"><HR> --->
	
	<CFIF ArrayLen(tempArray) EQ 5>
		<CFIF tempArray[5] EQ "VOLUME">
			<CFSET Volume = evaluate("FORM.#FormFiedlName#")>
			<CFSET UOM = evaluate("FORM.#tempArray[1]#Z#tempArray[2]#Z#tempArray[3]#Z#tempArray[4]#ZUOM")>			
			<CFSET Rate = evaluate("FORM.#tempArray[1]#Z#tempArray[2]#Z#tempArray[3]#Z#tempArray[4]#ZBB_Amount")>
			<CFSET Product_Type_ID = evaluate("FORM.#tempArray[1]#Z#tempArray[2]#Z#tempArray[3]#Z#tempArray[4]#ZRateType")>
						
			<cfquery name="saveProductInfo" datasource="#Application.Datasource#">
				UPDATE
						Billback_Product
				SET
						BB_Product_Quantity = '#Volume#',
						BB_Product_UOM		= '#UOM#',
						BB_Rate = '#Rate#',
						BB_Product_Type_ID = '#Product_Type_ID#'
						
				WHERE
						Billback_ID			= '#replace(tempArray[2],"_","-","ALL")#'
						AND
						Billback_Program_ID = '#replace(tempArray[3],"_","-","ALL")#'
						AND
						Billback_Product_ID	= '#replace(tempArray[4],"_","-","ALL")#'
			</cfquery>			
		</CFIF>
	</CFIF>
</CFLOOP>