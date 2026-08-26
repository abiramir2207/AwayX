<cfscript>
    function Track_Changes() {
        // retrieve the latest settings from _Application_Settings
        local.updated = queryExecute( " SELECT * FROM _Application_Settings ", { }, { datasource: application.datasource } );
        // compare with original settings and get back the list of columns with different values
        local.different_columns = createObject( "component", "components.udf" ).compareTopRows( this.original, local.updated, "INTERNAL_SETTINGS_UPDATED_ON" );

        local.sql = [];
        if ( isDefined( "request.accessStructure.name_first" ) and isDefined( "request.accessStructure.name_last" ) ) {
            // set up SQL session context for updated_by column
            local.sql.append( "EXEC sp_set_session_context 'Updated_By', '#request.accessStructure.name_first# #request.accessStructure.name_last#'" );
        }

        // gather insert statements to _Auditing tracking table for changed settings
        for ( local.column in local.different_columns ) {
                local.sql.append( "INSERT INTO _Auditing (
                                        Table_Name
                                        ,Column_Name
                                        ,New_Value
                                        ,Old_Value
                                        ,Updated_Type
                                    )
                                    SELECT  '_Application_Settings'
                                            , '#local.column#'
                                            , '#local.updated[ local.column ][ 1 ]#'
                                            , '#this.original[ local.column ][ 1 ]#'
                                            , 'Update'
                                    " );
        }
        local.sql.append( "EXEC sp_set_session_context 'Updated_By', NULL" );

        // commit the tracking changes
        queryExecute( local.sql.toList( ' ' ), { }, { datasource: application.datasource } );

        // refresh original query
	    this.original = queryExecute( " SELECT * FROM _Application_Settings ", { }, { datasource: application.datasource } );
    }
</cfscript>
