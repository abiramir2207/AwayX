<script language ="javascript">
	function ConfirmDelete(deletetype)
	{
		if(deletetype ==1){
			if(confirm("Are you sure that you want to delete the temporary rebate files ?")){
				location.href="/scheduled/clear_rebate_files.cfm?DeleteSource=Appsetting";
			}
		}

		else if(deletetype ==2){
			if(confirm("Are you sure that you want to delete the other temporary files ?")){
				location.href="/Common_Files/contracts/Delete_Temp_Files/Delete_Temp_Files.cfm?DeleteSource=Appsetting";
			}
		}
	}
</script>

	<div align="right"><a href="#" onClick="self.close()" style="font-size:11;font-family:Arial;">close window</a></div>

	<div align="center"><b>DELETE FILES</b></div>

<table align="center" cellspacing="3" cellpadding="3">
	<tr>
		<td>Temporary rebate files - <a href="#" onClick="ConfirmDelete(1); return false;">Delete</a></td>
	</tr>
	<tr>
		<td>Other temporary files - <a href="#" onClick="ConfirmDelete(2); return false;">Delete</a></td>
	</tr>
</table>