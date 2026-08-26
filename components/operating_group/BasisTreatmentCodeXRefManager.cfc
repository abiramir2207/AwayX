<cfcomponent displayname="BasisTreatmentCodeXRefManager" hint="Basis Treatment Code XRef Manager" extends="components.Base">


	<cffunction name="init" returntype="components.Operating_Group.BasisTreatmentCodeXRefManager" output="false">	
		<cfreturn this />		
	</cffunction>
	
	<cffunction name="getBasisTreatmentCodeXRef" output="false" returntype="query">
		
		<cfquery name="qGetBasisTreatmentCodeXRef" datasource="#application.datasource#">			
			SELECT 	Basis_Code.Basis_Code_ID Basis_Code_Number,
					Treatment_Code.Treatment_Code_ID Treatment_Code_Number,
					Basis_Code.Basis_Code_Master_ID,
					Treatment_Code.Treatment_Code_Master_ID
			FROM 	BasisTreatment_Code_XRef
			
			INNER JOIN Basis_Code
			ON		Basis_Code.Basis_Code_ID = BasisTreatment_Code_XRef.Basis_Code_ID
			
			INNER JOIN Treatment_Code
			ON		Treatment_Code.Treatment_Code_ID = BasisTreatment_Code_XRef.Treatment_Code_ID
			
			WHERE	BasisTreatment_Code_XRef.Deleted = 0
			
		</cfquery>
		
		<cfreturn qGetBasisTreatmentCodeXRef />
		
	</cffunction>
	
</cfcomponent>