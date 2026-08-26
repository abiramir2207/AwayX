<!---
  * ==================================================================================================== 
  *    @File: /settings/ADL/add_item.cfm
  *  @Author: Sharon Harris
  *    @Date: May 2021
  * 
  * @Remarks: Authorized Distribution List - Add a new item to an ADL list
  *			This page is shown as a modal/popup when clicking from Add Item button on adl_edit
  *
  * ==================================================================================================== 
--->
<cfparam name="url.adlId" default="" />
<cfscript>
	param name="form.item_start_date" default="";
	param name="form.item_end_date" default="";

</cfscript>

<cf_include files="/common_files/jQuery.cfm, /common_files/jQueryUI.cfm, /styles/css-loader.css">
	<style>
		* { box-sizing: border-box; margin: 0; padding: 0; }
		body { padding: 10px; }
		.hidden { display: none; }
		label {
			display: inline-block;
			/* width: 70px; */
			text-align: left;
			font-weight: bold;
			margin-right: 2px;
		}
		label.date { min-width: 55px; }
		div.inputs { margin: 15px; }
		div#actions { margin-top: 20px; margin-left: 10px; }
		input[type=radio], input[type=checkbox] {
			position: relative;
			top: 2px;
			margin: 3px 3px 3px 4px;
		}
		input[type="text"] {
			border: 1px solid #97999B;
			border-radius: .15rem;
			padding: 0 3px;
		}
		input.date { width: 70px; }
		label.ifLike { margin-left: 25px; margin-top: 10px;}
		.likeFields { display: none; }
		input[name="useLike"]:checked ~ .likeFields { display: block; } 	/* show sibling div when checked */
		input.perc { width: 55px; }
	</style>


	<cfoutput>
	<form>
		<div class="inputs">
			<label>Item</label>
			<button class="button">Search Items</button>
		</div>

		<div class="inputs">
			<label class="" title="">
				<input type="radio" name="rdoIncExc" value="inc_exc" checked="checked">
					Include
			</label>
			<br>
			<label class="" title="">
				<input type="radio" name="rdoIncExc" value="inc_exc">
					Exclude
			</label>
		</div>

		<div class="inputs">
			<label class="date">Start Date</label> 
			<input type="text" class="date" name="item_start_date" readonly="readonly" value="#form.item_start_date#">
			<br><br>
			<label class="date">End Date</label>
			<input type="text" class="date" name="item_end_date" readonly="readonly" value="#form.item_end_date#">
		</div>

		<div class="inputs">
			<input type="checkbox" name="useLike" style="margin-right:5px;">
			<label for="useLike">Like another Item</label>
			<div class="likeFields">
				<label class="ifLike">Like Item</label>
				<button class="button">Search Items</button>
				<br>
				<label class="ifLike">% of Like Item</label>
				<input class="perc" type="number" placeholder="100.0" required min="0" value="100"  
					title="Percentage, like 66.6" pattern="^\d+(?:\.\d{1,1})?$" 
					<!--- onblur="this.style.borderColor=/^\d+(?:\.\d{1,1})?$/.test(this.value)?'inherit':'red'" > % --->
					> %
			</div>

		</div>


	</form>
	</cfoutput>

	<div id="actions">
        <button class="button create recommended disabled">Save</button>
        <button class="button cancel">Cancel</button>
    </div>


	<script>
        const PERCENTAGE_FORMAT = '(0.0)';

		// Cancel button closes the modal popup
		$("button.cancel").click(function(){
			parent.dhx_window_close();
		});

		// Init the date pickers
        $(".date").datepicker({
            changeMonth: true
			,changeYear: true
            ,showButtonPanel: false
            // ,minDate: // today onward
            ,onClose: function(selectedDate) {
                if ($(this).attr("name") == "item_start_date") {
                    $("input[name=item_end_date]").datepicker( "option", "minDate", selectedDate );
                }
            }
        });

	</script>
