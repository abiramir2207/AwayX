<!--
  * ==================================================================================================== 
  *  program_search_tools.cfm
  *  @Author: Sharon Harris
  *    @Date: 2018-07-13 
  * 
  * @Remarks:   
  *  This file contains the Program Search Tools tab feature.
  *
  *  
  * ==================================================================================================== 
-->


<cfoutput>
    <div class="active-panel">
        <div  style="margin-top:30px; margin-bottom:30px;">
            <button type="button" onClick="doDocs(1)" class="button alt" style="margin-left:50px; margin-bottom: 10px;">Upload Documents</button>
            <!--- Only if the profile allows, should a user be allowed to search for documents --->
            <cfif Get_Profile_Settings.Search_Documents eq 1>
                <button type="button" onClick="doDocs(2)" class="button alt" style="margin-left:50px">Search Documents</button>
            </cfif>
        </div>
    </div>

</cfoutput>

<script>
    function doDocs(type){
        selectPrograms();

        if(selected_programs != ''){   
            if(type == 1) {
                /* upload documents */
                NewWindow("/common_files/documents/upload_mass_documents.cfm?FormName=Programs&ProgramList="+selected_programs,"Upload","600","300","yes","yes");
            }
            else {
                /* search documents */
                /* SAH How to get rid of the Flex parameters? */
                NewWindow("/common_files/documents/Attach_Document.cfm?FormName=flex&FlexAppName=SearchProgramMain&ProgramList="+selected_programs,"Search","850","600","yes","yes");
            }
        }
        else {
            alert ("Please select at least one Program");
        }
    }

</script>