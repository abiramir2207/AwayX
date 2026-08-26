<!---
	* ===========================================================================================
	*    @File: billbacks\2020\edit_billback_event_handlers.cfm
	*    @Author: Kal
	*    @Date: April 2020
	*
	* @Remarks: edit billback events & handlers
	* ===========================================================================================
--->

<script type="text/javascript" language="JavaScript">

	<!------------- variables, flags and formatters ------------->
	<!-------------  Constants ------------->
	const fmt_num_4_decimal = '00.0000';	// 4 decimal places, strip , and $ to save
	const fmt_num_2_decimal = '00.00';		// 2 decimal places, strip , and $ to save
	const fmt_num_no_decimal = '00';		// no decimal places; strip , and $ to save
	const fmt_4_decimal = '0,0.0000';		// 4 decimal places
	const fmt_2_decimal = '0,0.00';			// 2 decimal places
	const fmt_no_decimal = '0,0';			// no decimal places
	const fmt_$4_decimal = '$0,0.0000';		// 4 decimal places
	const fmt_$2_decimal = '$0,0.00';		// 2 decimal places
	const fmt_$no_decimal = '$0,0';			// no decimal places
	const fmt_date_mmddyyyy = 'mm/dd/yyyy'; // mm/dd/yyyy; moment().format('L')
	const fmt_date_mmddyy = 'mm/dd/yy';		// mm/dd/yy
	const fmt_dt = 'MMMM DD YYYY hh:mm:ss';
	const bbDateChange_Allowed = <cfoutput>#profileSettings.Change_BB_Start_End_Date#</cfoutput>;

	let bb_loaded = 0;				// flag to stop dataload again
	///let bb = {};					// billback MOVED UP TO EDIT_BILLBACK

	let objBBLock = {};
	let selectedVendor = {};		// vendor obj same as payee
	let selectedPayee = {};			// payee obj
	let importedPayee = {};
	let selectedProgram = {};
	let selectedDistributor = {};

	let arrBBAnalysts = [];
	let arrPayee = [];
	let arrProgram = [];
	let arrDistributor = [];
	let arrComponent = [];
	let arrPrgItem = [];
	let arrAllProducts = [];


	// variables for form elements
	let spans = document.querySelectorAll('span#record_count'); 	// toggle bar
	let analyst = document.querySelector('#analyst'); 	// analyst

	//first row : bbnumber, reference number, closing method, dates
	let bbNumber = document.querySelector('#bbNumber');
	let referenceNumber = document.querySelector('#referenceNumber');
	let closingMethod = document.querySelector('#closingMethod');
	let bbDate = document.querySelector('#bbDate');
	let startDate = document.querySelector('#startDate');
	let endDate = document.querySelector('#endDate');

	//second row : title, vendor, payye dates
	let title = document.querySelector('#title');
	let vendorId = document.querySelector('#vendorId');
	let oldVendorId = document.querySelector('#oldVendorId');
	let dpdPayee = document.querySelector('#dpdPayee');
	let oldPayeeId = document.querySelector('#oldPayeeId');
	let receivedDate = document.querySelector('#receivedDate');
	let postDate = document.querySelector('#postDate');

	// third row : summary, vendor info, payye info, notes
	// $
	let claimAmount = document.querySelector('#claimAmount');
	let expAmount = document.querySelector('#expAmount');
	let variedAmount = document.querySelector('#variedAmount');
	// Cs
	<cfif local.view_program_volume_uom  eq 1 or local.view_program_volume_uom eq 3 >
	let claimCs = document.querySelector('#claimCs');
	let expCs = document.querySelector('#expCs');
	let variedCs = document.querySelector('#variedCs');
	</cfif>
	// Lb
	<cfif local.view_program_volume_uom  eq 2 or local.view_program_volume_uom eq 3 >
	let claimLb = document.querySelector('#claimLb');
	let expLb = document.querySelector('#expLb');
	let variedLb = document.querySelector('#variedLb');
	</cfif>

	let vendorLabel = document.querySelector('.div15 label');
	let payeeLabel = document.querySelector('.div16 label');
	let notes = document.querySelector('.div17 #notes');

	let dpdProgram = document.querySelector('#dpdProgram');
	let prgLabel = document.querySelector('.div20 label');
	let dpdDistributor = document.querySelector('#dpdDistributor');
	let distLabel = document.querySelector('.div22 label');


	// convert CF variables/object to js
	<cfoutput>
	let bbDisplayAllComps = #application.util.query.get_setting('Billback_Display_All_Program_Components')#
	let defaultUserId = "#request.AccessStructure.user_id#"
	let oBBComp = #serializeJSON(application.util.struct.structSortLowerCase(bbComponent), "struct")#;
	let oPgmComp = #serializeJSON(application.util.struct.structSortLowerCase(pgmComponent), "struct")#;
	let oBBPDIR = #serializeJSON(application.util.struct.structSortLowerCase(bbPDIR), "struct")#;
	let arrAnalysts = #serializeJSON(application.util.struct.structSortLowerCase(analysts), "struct")#;
	let arrClosingMethdods = #serializeJSON(application.util.struct.structSortLowerCase(closingMethdods), "struct")#;
	let arrUoms = #serializeJSON(application.util.struct.structSortLowerCase(uoms), "struct")#;
	</cfoutput>

	<!------------- load all event listeners ------------->
	function loadBBEditEventListeners() {

		// vendor focus out - run duplicate check
		vendorId.addEventListener("focusout", checkBBDuplicates);
		// vendor change
		vendorId.addEventListener("change", vendorDataChange);
		// payee change
		dpdPayee.addEventListener("change", dpdPayeeChange);

		// program dropdown change
		// dpdProgram.addEventListener("change", dpdProgramChange);
		$(document).on('change', '#dpdProgram', dpdProgramChange);

		// distributor dropdown change
		// dpdDistributor.addEventListener("change", dpdDistributorChange);
		$(document).on('change', '#dpdDistributor', dpdDistributorChange);

		// products from program
		btnProdFromProg.addEventListener('click', prodFromPgm);
		// product rates from program
		btnProdRatesFromProg.addEventListener('click', prodRatesFromPgm);
		// search products
		btnProdSearch.addEventListener('click', prodSearch);
		// save bb
		btnSaveBB.addEventListener('click', set_billback);
		// continue btn
		btnContinue.addEventListener('click', nextAction);
	}


	<!------------- get billback data ------------->
	function load_billback(bbint){
		// create a chain of events
		let loadChain = new LoadChain();
		loadChain.push(function () { show_loader('Loading Data...'); });

		loadChain.push( function() { get_billback(bbint); });

		// display bb header data
		loadChain.push( function() { show_billback(); });

		// display bb prg dist items in grid
		loadChain.push( function() { glob.my_grid.api.setRowData( bb.bbprgdistitemrate ); });

		if (bbint){
			//get programs for the selected payee and dates and add programs from BB
			loadChain.push( function() { get_programs_list(); });

			// add components to the display
			loadChain.push( function() { show_components(); });

			// create attachment links
			loadChain.push(function () { buildViewDocsMenu(); });
		}
		// call the lock object;
		loadChain.push(function () { getLockUnlockBB(); });

		// hide show_loader
		loadChain.push(function () { $("div.loader").hide(); });

		/* This step starts the sequence of steps from STEP 1. */
		loadChain.start();
	}


	function get_billback(bbint){
		// show_loader('Loading Data...');
		if (!bb_loaded){
			$.ajax({
				url: "/mvc/models/Billback/BillbackManager.cfc"
				,type: "POST"
				,async: false
				,dataType: "json"
				,data: {
					method: "getBillbackJSON"
					,billbackIDInt: bbint
					,copyAction: 0
				}
			})
			.then( (response) => {
				bb_loaded++;	// set flag so bb doesnt load next time
				bb = response;
				selectedVendor = bb.bbheader.vendor;
				selectedPayee = bb.bbheader.payee;
				arrComponent = bb.bbcomponent;	// load bb components into array
				if (typeof window.parent.showSettlement !== "undefined") {
					window.parent.showSettlement();
				}
			})
			// .then($("div.loader").hide())
			.fail(data => {
				// $("div.loader").hide();
				alert('An error occurred.  ' + JSON.stringify(data));
			});
		}
	}

	// populate form fields from bb header data
	function show_billback(){
		// show_loader('Loading Data...');
		// if new bb keep defaults or dont display
		if (bb.bbheader.billbackidint){
			// collapsible header
			spans[0].innerText = bb.bbprgdistitemrate.length + ' records';
			spans[1].innerText = bb.bbheader.bbcode;
			spans[2].innerText = bb.bbheader.status.description;
			spans[3].innerText = ((bb.bbheader.uploadedbillback)
								? '[ ' + bb.bbheader.bbtype.description + '-ID : ' + bb.bbheader.uploadid + ' ]'
								: '[ ' + bb.bbheader.bbtype.description+  ' ]');
			spans[4].innerText = bb.bbheader.creator.fullname;

			analyst.value = bb.bbheader.analyst.idint;             // analyst
			closingMethod.value = bb.bbheader.closingmethod.id;   //closing method
		}

		//first row : bbnumber, reference number,  dates
		bbNumber.value        = bb.bbheader.bbnumber;
		referenceNumber.value = bb.bbheader.referencenumber;

		bbDate.value          = moment(bb.bbheader.bbdate, fmt_dt).format('L');
		startDate.value       = moment(bb.bbheader.startdate, fmt_dt).format('L');
		endDate.value         = moment(bb.bbheader.enddate, fmt_dt).format('L');

		//second row : title, vendor, payye dates
		title.value        = bb.bbheader.title;
		vendorId.value     = selectedVendor.payeeid 	// bb.bbheader.vendor.payeeid;
		oldVendorId.value  = selectedVendor.payeeid 	// bb.bbheader.vendor.payeeid;
		dpdPayee.value = selectedPayee.payeeid;		// bb.bbheader.payee.name;
		oldPayeeId.value = selectedPayee.payeeid;		// bb.bbheader.payee.name;
		receivedDate.value = moment(new Date(bb.receiveddate)).format('L');
		postDate.value     = moment(new Date(bb.postdate)).format('L');

		// third row : summary, vendor info, payye info, notes
		// $
		claimAmount.value  = numeral(bb.claimedamount).format(fmt_$2_decimal);
		expAmount.value    = numeral(bb.expectedamount).format(fmt_$2_decimal);
		variedAmount.value = numeral(bb.variedamount).format(fmt_$2_decimal);
		// Cs
		<cfif local.view_program_volume_uom  eq 1 or local.view_program_volume_uom eq 3 >
		claimCs.value  = numeral(bb.claimedcs).format(fmt_2_decimal);
		expCs.value    = numeral(bb.expectedcs).format(fmt_2_decimal);
		variedCs.value = numeral(bb.variedcs).format(fmt_2_decimal);
		</cfif>
		// Lb
		<cfif local.view_program_volume_uom  eq 2 or local.view_program_volume_uom eq 3 >
		claimLb.value  = numeral(bb.claimedlb).format(fmt_2_decimal);
		expLb.value    = numeral(bb.expectedlb).format(fmt_2_decimal);
		variedLb.value = numeral(bb.variedlb).format(fmt_2_decimal);
		</cfif>

		//notes
		notes.innerHTML = bb.bbnotes;

		if (bb.bbheader.billbackidint) {
			getPayeeList(selectedVendor.payeeid);
			show_selected_vendor(selectedVendor);
			show_selected_payee(selectedPayee);
		}

		if(bb.bbheader.status.id == 1 || bb.bbheader.billbackidint == 0){
			$('#btnContinue').html('Submit RFA');
		}
		else{
			$('#btnContinue').html('Deviations');
		}

		if(bb.bbheader.billbackidint == 0){
			$('#btnContinue').prop("disabled", true);
		}
		else{
			$('#btnContinue').prop("disabled", false);
		}

		// $("div.loader").hide();
		if (typeof window.parent.parent.refreshSearchRowFromEdit !== "undefined" && bb.bbheader.billbackidint != 0) {
			window.parent.parent.refreshSearchRowFromEdit(bb);
		}

	} // end: show_billback

	//get programs for the selected payee and dates
	function get_programs_list(prg_number=''){
		// show_loader('Loading programs...');
		if(selectedPayee.payeeid == ''){
			return;
		}
		$.ajax({
			url: "/mvc/models/Billback/BillbackEditSearchManager.cfc"
			,type: "POST"
			,async: false
			,dataType: "json"
			,data: {
				method: "getProgramListJSON",
				userId: defaultUserId,
				startDate: startDate.value,
				endDate: endDate.value,
				payee: JSON.stringify(selectedPayee),
				programNumber: prg_number
			}
		})
		.then((result) => set_program_list(result) )
		.then( set_bb_program_list() )
		.then( set_program_dropdown() )
		// .then( $("div.loader").hide() )
		.fail(data => {
			// $("div.loader").hide();
			alert('An error occurred.  ' + JSON.stringify(data));
		});
	}

	// set programs returned into arrProgram array
	function set_program_list(prgListArray){
		// prgListArray is of BBProgram typed obj and not Program typed obj
		arrProgram = []; 	// remove contents so reference pointers are updated
		if(prgListArray.length){
			arrProgram.push(...getArrUniqueObjs(prgListArray, "number"));
		}
	}

	// append programs from the bb into arrProgram
	function set_bb_program_list(){
		// get programs from bb
		// let  arrBBPrg = bb.bbprgdistitemrate.map(obj => obj.bbprogram);
		let  arrBBPrg = [];

		// get matching programs from rows bb detail (duplicates too)
		arrProgram.forEach(prg => {
			// get programs from all rows on bb (duplicates too)
			bb.bbprgdistitemrate.forEach(bbPDIR => {
				if (prg.number == bbPDIR.bbprogram.number) {
					bbPDIR.bbprogram = prg;
					arrBBPrg.push(prg);
				}
			});
			// get matching programs from comps on bb (duplicates too)
			arrComponent.find( bbComp => { if (prg.number == bbComp.programnumber) arrBBPrg.push(prg); });
		});

		arrProgram.push(...arrBBPrg);
		arrProgram = arrProgram.length ? getArrUniqueObjs(arrProgram, "number") : arrProgram; // remove duplicates

		// sort by program number
		arrProgram.sort((a, b)=> {
  			return (a.number < b.number) ? -1: 1;
		});

		// if there is any BB program, get its info and set it selectedProgram;
		arrBBPrg.length
			? get_program(arrBBPrg[0].programid)
			: (arrProgram.length ? get_program(arrProgram[0].programid) : '') ;
	}

	// populate the program dropdown
	function set_program_dropdown(){
		dpdProgram.innerHTML = ""; // clear the distributor dropdown
		let prgOptionList = dpdProgram.options;
		arrProgram.forEach( prg =>
			prgOptionList.add( new Option(`${prg.number} - ${prg.title}`, prg.programid) )
		);

		if (selectedProgram.programid) {
			// set program in dropdown;
			dpdProgram.value = selectedProgram.programid;
			$('#dpdProgram').select2({
					placeholder: {
						id: selectedProgram.programid, // the value of the option
						text: `${selectedProgram.number} - ${selectedProgram.title}`
					}
				});
		}
	}

	function get_program(programid) {
		/*
		get_program
		- gets prg info,
		- displays selectedPrg,
		- sets distributors & dist dropdown,
		- if payee = dist, sets dist as selected
		*/

		//get the program based on the payee and append
		let payee_type = '';
		if (!bbDisplayAllComps) {
			payee_type = selectedPayee.payeeid ? selectedPayee.payeetypeid : bb.bbheader.payee.payeetypeid;
		}

		// show_loader('Loading program data...');
		$.ajax({
			url: "/mvc/Models/Program/ProgramManager.cfc"
			,type: "POST"
			,async: false
			,dataType: "json"
			,data: {
				method: "getProgramJSON",
				programId: programid,
				bMarketPrice: 0,
				bProdRateItemDesc: 0,
				includeGroupMembers: 1,
				payeeType: payee_type,
				fromBillback: 1,
				bNewRateMP: 0,
				bLowerCase :1
			}
		})
		.then( (prg) => show_selected_program(prg) )
		.then( set_distributors() )
		.then( set_distributor_dropdown() )
		.then( set_components(selectedProgram.components) )
		.fail(data => {
			alert('An error occurred.  ' + JSON.stringify(data));
		});
	}

	// show the selected program or top 1 program
	function show_selected_program(prg){
		selectedProgram = prg;
		prgLabel.innerHTML = ` [ ${selectedProgram.number} ]
			<br> ${selectedProgram.title}
			<br> ${moment(selectedProgram.startdate, fmt_dt).format('L')} - ${moment(selectedProgram.enddate, fmt_dt).format('L')}`;
	}

	// get distributors from selectedProgram
	function set_distributors(){
		let arrAllDist = selectedProgram.distributors;
		arrDistributor = getArrUniqueObjs(arrAllDist, "shipto");
	}

	// populate the distributor dropdown
	function set_distributor_dropdown(){
		let tmpDist = {}; // placeholder

		dpdDistributor.innerHTML = ""; // clear the distributor dropdown
		let distOptionList = dpdDistributor.options;

		arrDistributor.forEach(dist => {
			distOptionList.add( new Option(`${dist.shipto} - ${dist.name}`, dist.customerid) )
			// find payee is dist then find payee in distributors and set as selected
			if (selectedPayee.payeetypeid == 1 && selectedPayee.payeeid == dist.shipto){
				tmpDist = dist;
			}
		});

		// if payee is operator; select the first dist in the dropdown
		if (selectedPayee.payeetypeid == 2 && arrDistributor.length) { tmpDist = arrDistributor[0]; }

		if ( Object.keys(tmpDist).length ){
			dpdDistributor.value = tmpDist.customerid;
			$('#dpdDistributor').select2({
				placeholder: {
					id: tmpDist.customerid, // the value of the option
					text: tmpDist.name
				}
			});
			show_selected_distributor(tmpDist);
		}
	}

	// show the selected distributor
	function show_selected_distributor(dist){
		selectedDistributor = dist;
		distLabel.innerHTML = ` ${selectedDistributor.name}
			<br> [${selectedDistributor.shipto}]
			<br> ${selectedDistributor.address.addressline1},
			${selectedDistributor.address.city}, ${selectedDistributor.address.state} ${selectedDistributor.address.zipcode} `;
	}

	function set_components(pgmComps){
		// add passed in components from selected program into BB(arrComponent/bbComponent). If user selects then set isselected flag.
		// when user changes program then the non selected comps are removed from the array(arrComponent/bbComponent)

		// remove non-selected components
		arrComponent = arrComponent.filter(comp => { return comp.isselected == 1 });

		let bValidComps = 0; // D30341: flag to hold if the program has valid components [no restrict from BB components]
		// loop thru the pgm components and only add the comps with matching payee type and the claim mechanism isnt resistricted from BB
		if (typeof(pgmComps) != "undefined" && pgmComps.length){
			pgmComps.forEach( prgComp => {
				if( (bbDisplayAllComps || (bb.bbheader.payee.payeetypeid == prgComp.paidto.paidtoid) )
					&& (!prgComp.claimmechanic.restrictbb || prgComp.claimmechanic.bautopay) )
				{
					bValidComps = 1; // D30341: set if there is a valid comp otherwise we will display no valid comps msg
					let compExists = 0;
					arrComponent.forEach( bbComp => {
						if ( bbComp.programnumber == selectedProgram.number &&
							(bbComp.programid == prgComp.programid || bbComp.bislatestversion == false) &&
							bbComp.componentnameid == prgComp.componentid &&
							bbComp.componenttypeid == prgComp.type &&
							// addl flags, can be removed if any issues in finding a match
							bbComp.componentname == prgComp.name &&
							bbComp.paidto.paidtoid == prgComp.paidto.paidtoid)
						{
							compExists = 1;
							if (bbComp.programid != prgComp.programid || bbComp.programcomponentid != prgComp.programcomponentid) {
								bbComp.programid = prgComp.programid;
								bbComp.programcomponentid = prgComp.programcomponentid;
							}

						}
					});
					// if prog comp isnt on the bb comps then add into the bb comps
					if (!compExists){
						// create a new BB Component to add
						let bbComp = JSON.parse(JSON.stringify(oBBComp));
						bbComp.programid = prgComp.programid;
						bbComp.componenttypeid = prgComp.type;
						bbComp.componentnameid = prgComp.componentid;
						bbComp.componentname = prgComp.name;
						bbComp.componentdesc = prgComp.compdescription;
						bbComp.componentamount = 0;
						bbComp.programnumber = prgComp.programnumber;
						bbComp.programtitle = prgComp.programtitle;
						bbComp.paidto = prgComp.paidto;
						bbComp.compdescription = prgComp.compdescription;
						bbComp.comprate = prgComp.comprate;
						bbComp.programcomponentid = prgComp.programcomponentid;
						// if there is only one component on the program and none on the BB, then set it as selected
						//if (pgmComps.length == 1 && arrComponent.length == 0) { bbComp.isselected = 1;}
						// add comp to bb
						arrComponent.push(bbComp);
					}
				}
			});
		}
		// D30341: Alert the user for no valid components and when the Billback is editable;
		// if (!bValidComps && bb.bbheader.locked == 1 && (bb.bbheader.status.id == 1 || bb.bbheader.status.id == 2)) {
		if (!bValidComps && (typeof (pgmComps) != "undefined") && (bb.bbheader.status.id == 1 || bb.bbheader.status.id == 2)) {
			noty({
				layout: "center", type: "error", timeout: 5000, killer: true,
				text: "There are no valid discounts on this program for the payee selected. <br> Select a different program or a different payee",
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
		}

		// call to display the components
		show_components();
	}

	function show_components(){
		let compContainer= document.querySelector('.comp-container');
		compContainer.innerHTML = "";
		arrComponent.forEach((comp, i) => {
			let amt = numeral(comp.componentamount).format(fmt_$2_decimal);
			let compItemDiv = document.createElement("div");
			compItemDiv.classList.add('comp-item');
			compItemDiv.innerHTML =
				` <input type="checkbox" class="editable" name="cb_${comp.programcomponentid}"
					${comp.isselected == 1 ? "checked" : ""}
					onchange="update_components(${i},this.name)">
					${comp.componentname}  [${comp.paidto.description}]
					<a href="##" onclick="displayProgram(${comp.programid})"> [${comp.programnumber}] </a>
					${comp.componenttypeid == '3'
						? `<input class="editable" type="text" name="amt_${comp.programcomponentid}" value="${amt}" onchange="update_components(${i},this.name)">`
						: ''
					}
				`;

			compContainer.appendChild(compItemDiv);
		});
	}

	function update_components(index,input_name){
		/* everytime a component is selected or removed; add/remove from bb.bbcomponent and zero the amount if Lumpsun
		if LS amount is made 0 then uncheck component */
		let inp_type = input_name.split("_")[0];
		let name_id = input_name.split("_")[1];
		let cb = $("input[name=cb_" + name_id +"]");
		let amt = $("input[name=amt_" + name_id +"]");

		if (inp_type == 'cb'){
			arrComponent[index].isselected = cb.prop("checked");
			/* if checked and amount field exists then focus; if not checked and amount filed exists set amout to zero */
			// cb.prop('checked') ? (amt.length ? amt.focus() : '') : (amt.length ? amt.val('0') : '');
			amt.length ? ( cb.prop('checked') ? amt.focus() : amt.val('$0') ): '';
		}else{
			// if LS amount is made 0 then uncheck component
			amt_val = numeral(amt.val()).format(fmt_num_2_decimal);
			if (amt_val == '' || amt_val == '0.00' || isNaN(amt_val) ){
				cb.prop('checked', false);
				arrComponent[index].isselected = false;
				amt.val('$0');
			}
			else{
				cb.prop('checked', true);
				arrComponent[index].isselected = true;
				amt.val(numeral(amt_val).format(fmt_$2_decimal));
			}
		}
		arrComponent[index].componentamount = numeral(amt.val()).format(fmt_num_2_decimal);
		update_summary();
	}

	// show the selected Vendor
	function show_selected_vendor(v) {
		selectedVendor = v;
		oldVendorId.value =  selectedVendor.payeeid;
		vendorLabel.innerHTML = ` ${selectedVendor.name}
				<br> ${selectedVendor.payeeid}
				<br> ${selectedVendor.address.addressline1}
				<br> ${selectedVendor.address.city}, ${selectedVendor.address.state} ${selectedVendor.address.zipcode} `;
	}

	// show the selected payee
	function show_selected_payee(payee) {
		if(payee === undefined){
			payee = {};
			payee.payeeid = '';
			payee.name = '';
			payee.address = {};
			payee.address.addressline1 =  '';
			payee.address.city =  '';
			payee.address.state =  '';
			payee.address.zipcode =  '';
		}

		selectedPayee = payee;
		dpdPayee.value = selectedPayee.payeeid;
		oldPayeeId.value = selectedPayee.payeeid;
		payeeLabel.innerHTML = ` ${selectedPayee.name}
			<br> ${selectedPayee.payeeid}
			<br> ${selectedPayee.address.addressline1}
			<br> ${selectedPayee.address.city}, ${selectedPayee.address.state} ${selectedPayee.address.zipcode} `;
	}

	// Check BB Duplicates
	function checkBBDuplicates() {

		if (vendorId.value.length) {
			show_loader('Checking Duplicates...');
			$.ajax({
				url: "/mvc/Models/Billback/BillbackManager.cfc"
				, type: "POST"
				, async: true
				, dataType: "json"
				, data: {
					method: "getDuplicateBillbacksJSON",
					returnformat: 'json',
					billbackIDInt: bb.bbheader.billbackidint,
					billbackNumber: bb.bbheader.bbnumber,
					vendorNumber: vendorId.value
				}
			})
			.then($("div.loader").hide())
			.then(data => {

				let arrErrors = [];
				let sErrorMsg = "";

				sErrorMsg = 'Duplicate Invoice Found';
				arrErrors.push(sErrorMsg);

				if (data.length) {
					data.forEach(hdr =>{
						if (hdr.bbcode !== null && hdr.bbcode.length) {
							sErrorMsg = `${hdr.bbcode} - ${hdr.title} - ${moment(hdr.startdate).format('L')} to ${moment(hdr.enddate).format('L')} - ${hdr.amount} - ${hdr.creator.fullname} - ${moment(hdr.createddate).format('L')}`;
							arrErrors.push(sErrorMsg);
						}
					});
					arrErrors.forEach(sErrorMsg => {
						noty({
							layout: "center", type: "error", timeout: 6000, killer: true, text: sErrorMsg,
							animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
						});
					});
				}
			})
			.fail(data => {
				$("div.loader").hide();
				alert('An error occurred.  ' + JSON.stringify(data));
			});

		}

	}

	function vendorDataChange() {
		// If existing vendor is empty - get vendor
		if (oldVendorId.value.length == 0 && vendorId.value.length) { getVendorData(vendorId.value); }

		/*
		 If existing vendor is not empty OR programs are not empty or distributors are not empty
			- If new val same as existing - do nothing
			- If new val is not same as existing vendor - warn about program and component info loss/removal
		*/
		if (oldVendorId.value.length && vendorId.value.length && (oldVendorId.value != vendorId.value)) {
			let sMsg = "Changing the payee on the billback will remove the program, component and item level details!<br> Do you want to continue";
			dhtmlx.modalbox({
				text: sMsg,
				title: "Confirm Vendor/Payee Change",
				buttons: ["Yes", "No"],
				callback: function (res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						clearBBProgCompItems();
						getVendorData(vendorId.value);
					} else { vendorId.value = oldVendorId.value; }
				}
			});
		}
	}

	// payee change
	function dpdPayeeChange(){
		let selectedVal = dpdPayee.options[dpdPayee.selectedIndex].value
		arrPayee.some((payee) => {
			if (payee.payeeid == selectedVal) { show_selected_payee(payee); }
		});
		get_programs_list();
	}

	function dpdProgramChange(){
		get_program(dpdProgram.options[dpdProgram.selectedIndex].value);
	}

	function dpdDistributorChange(){
		let selectedVal = dpdDistributor.options[dpdDistributor.selectedIndex].value
		arrDistributor.some((dist) => {
			if(dist.customerid == selectedVal){ show_selected_distributor(dist); }
		});
	}

	function clearBBProgCompItems(){
		console.log('clearBBProgCompItems');
	}

	function validate_bb_header(){
		// validate the header
		let bValid = true;
		let arrErrors = [];

		console.log('validate-bbheader');

		if (moment(bb.bbheader.startdate).isAfter(bb.bbheader.enddate)) {
			pushError('Start Date is after End Date');
		}

		if (bb.bbheader.closingmethod.id < 1) {
			pushError('Closing Method is required.');
		}

		if (!bb.bbheader.vendor || !bb.bbheader.vendor.payeeid) {
			pushError('Payee is required.'); // BSA Vendor
		}

		if (!bb.bbheader.payee || !bb.bbheader.payee.payeeid) {
			pushError('Account#  is required.'); // BSA Payee
		}

		if (bb.bbheader.bbnumber.length <= 0) {
			pushError('Please enter an invoice number');
		}
		if (bb.bbheader.title.length <= 0) {
			pushError('Please enter an invoice title');
		}

		if (!bValid) {
			arrErrors.forEach(sErrorMsg => {
				noty({
					layout: "center", type: "error", timeout: 5000, killer: true, text: sErrorMsg,
					animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
				});
			});
		}
		return bValid;

		function pushError(sErrorMsg) {
			bValid = false;
			arrErrors.push(sErrorMsg);
		}
	}

	function validate_bb_span(){
		let bValid = true;
		// BBEditManager.validateBBDates()
		/* Validate bb date range, confirm with users when any of these conditions exists:
		a.   billback span (start date to end date) is greater or equal to 500 days
		b.   billback start date is more than 500 day in the past (from today's date)
		c.   billback start date is more than 500 days in the future (from today's date) */
		let bb_span = moment(bb.bbheader.enddate).diff(bb.bbheader.startdate, 'days');
		let dtFarPast = moment().diff(bb.bbheader.startdate, 'days');
		let dtFarFuture = moment(bb.bbheader.startdate).diff(moment(), 'days');

		if (bb_span > 500 || dtFarPast > 500 || dtFarFuture > 500) {
			let sMsg = "Please confirm the billback start and end dates are accurate\nClick Yes to continue. Click No to update the dates";
			bValid = confirm(sMsg); // set result from confirmation
		}
		return bValid;
	}

	function validate_bb_components(){
		// validate bb component info ~ Flex: BBEditManager.validateComponents()
		let bValid = true;
		let arrErrors = [];
		let sErrorMsg = "";
		let bLumpsumComponentError = false;
		let bRebateFixedComponentError = false;
		let nErrorCount = 1;

		// if no comps exist or none are selected
		if (arrComponent.length == 0 || !arrComponent.some(bbComp => bbComp.isselected == 1) ) {
			// no comps on billback but if there are items or amounts; alert msg [no comp found for the Billback]
			// when there are no items or amounts on BB, dont check comps, so they can save a new BB with just payee info

			//if (bb.bbprgdistitemrate.length || bb.expectedamount || bb.expectedcs) {
			if (bb.bbprgdistitemrate.length) {
				bValid = false;
				sErrorMsg = `${nErrorCount}. No Component found for the Billback.`;
				arrErrors.push(sErrorMsg);
				nErrorCount++;
			}
		}
		else {
			// loop over each BBComp for LumpSum
			arrComponent.forEach(bbComp => {
				if (bbComp.isselected && bbComp.componenttypeid == 3 && ( bbComp.componentamount == 0 || isNaN(bbComp.componentamount) )) {
					bValid = false;
					bLumpsumComponentError = true;
					sErrorMsg = `${nErrorCount}. The lumpsum amount cannot be \$${bbComp.componentamount} for the component: ${bbComp.componentname} [ ${bbComp.programnumber} ]`;
					arrErrors.push(sErrorMsg);
					nErrorCount++;
				}
			});

			// loop over each BBComp for Rebate and Fixed.
			var lastPrgIDAdded = 0;

			bb.bbprgdistitemrate.forEach(bbPrg => {

				let bRebateFixedComponent = 0;

				// some prg might have older prgId so check against prg number
				bRebateFixedComponent = arrComponent.some(bbComp => {
					return (bbComp.isselected && (bbPrg.bbprogram.number == bbComp.programnumber) && (bbComp.componenttypeid == 1 || bbComp.componenttypeid == 2) );
				});

				if (bRebateFixedComponent == 0 && lastPrgIDAdded != bbPrg.bbprogram.programid) {
					bValid = false;
					bRebateFixedComponentError = true;
					sErrorMsg = `${nErrorCount}. No Rebate/Fixed Component found for the program: ${bbPrg.bbprogram.number}`;
					arrErrors.push(sErrorMsg);
					nErrorCount++;
					lastPrgIDAdded = bbPrg.bbprogram.programid;
				}

				/*
				// 05/20/16 - we now store discountType bbProdRate. Checking for discountType on product also.
				if (!(bbPrg.bbprodrate.discounttype == 1 || bbPrg.bbprodrate.discounttype == 2)) {
					// D60837 - See resolution notes. GM folks use items to report volume by applying a rebate/fixed component & then remove it and save.
					// Compromise fix is to let the users save products after removing fixed/rebate component and use rebate as default discount type.
					bbPrg.bbprodrate.discounttype = 2;
					// bRebateFixedComponentError = true;
					// sErrorItems = bbPDIR.bbProgram.number + ':' + bbPDIR.bbProdRate.itemNumber + '; ' + sErrorItems;
				}
				*/
			});
		}

		if (!bValid) {
			arrErrors.forEach(sErrorMsg => {
				noty({
					layout: "center", type: "error", timeout: 5000, killer: true, text: sErrorMsg,
					animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
				});
			});
		}
		return bValid;
	}

	function validate_bb_info(){
		// validate if BB has all the info ~ Flex: BBEditItemsPModel.validateBillback()

		let bbDatesWithinPgm = true;
		let sErrorMsg = 'Invoice dates are outside of Program dates!';

		let selPgmStart = moment(selectedProgram.startdate).format('L');
		let selPgmEnd = moment(selectedProgram.enddate).format('L');

		if (arrProgram.length){
			if (arrComponent.length){
				arrComponent.forEach(bbComp => {
					if (bbComp.isselected) {
						arrProgram.forEach(pgm =>{
							if ( bbDatesWithinPgm && bbComp.programnumber == pgm.number ){
								if ( moment(bb.bbheader.startdate).isBefore(moment(pgm.startdate)) || moment(bb.bbheader.enddate).isAfter(moment(pgm.enddate)) ) {
										bbDatesWithinPgm = false;
								}
							}
						});
					}
				});
				// check for selectedProgram only if bb dates are are still within pgm range;
				if (bbDatesWithinPgm
					&& (moment(bb.bbheader.startdate).isBefore(selPgmStart) || moment(bb.bbheader.enddate).isAfter(selPgmEnd)) )
				{
					bbDatesWithinPgm = false;
				}
			}

		}

		if(!bbDatesWithinPgm){
			noty({
				layout: "center", type: "warning", timeout: 5000, killer: true, text: sErrorMsg,
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
		}

		// return bbDatesWithinPgm;
		return true; // do a soft alert and not a hard stop.
	}

	function validate_bb_vol_rates(){
		let bValid = true;
		let bValidVolume = true;
		let bValidRate = true;

		let strVolMsg = "There are rows without volume. Please update!";
		let strRateMsg = "There are rows without rates. Please update!";

		// loop over each bbprgdistitemrate and validate volume and rate
		bb.bbprgdistitemrate.forEach(bbPrg => {

			if(bbPrg.bbprodrate.volume == 0 && bValidVolume == true){
				bValidVolume = false;
			}

			if(bbPrg.bbprodrate.rate == 0 && bValidRate == true){
					bValidRate = false;
			}
		});


		//if 0 volume display
		if(bValidVolume == false){
			bValid = false;
			noty({
					layout: "center", type: "error", timeout: 5000, killer: true, text: strVolMsg,
					animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
				});
		}

		//if 0 rate display
		if(bValidRate == false){
			bValid = false;
			noty({
					layout: "center", type: "error", timeout: 5000, killer: true, text: strRateMsg,
					animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
				});
		}

		return bValid;
	}


	function set_billback(){

		// filter items without item number and volume
		// use a builtin fn for filtering balnk item
		function filterBlankItem(bbPDIR) {
			return ((bbPDIR.bbprodrate.itemnumber != 0) ? true : false);
		}
		bb.bbprgdistitemrate = bb.bbprgdistitemrate.filter(filterBlankItem);
		glob.my_grid.api.setRowData(bb.bbprgdistitemrate);

		// update summary row
		update_summary();

		// set form data into BB obj and call save
		// analyst
		bb.bbheader.analyst = arrAnalysts.find( a => { return a.idint == analyst.value} );
		// creator
		if (bb.bbheader.creator.idint == 0)  bb.bbheader.creator.id = defaultUserId;

		//first row : bbnumber, reference number, closing method, dates
		bb.bbheader.bbnumber = bbNumber.value;
		bb.bbheader.referencenumber = referenceNumber.value;
		bb.bbheader.bbdate = moment(bbDate.value).format('L');
		bb.bbheader.startdate = moment(startDate.value).format('L');
		bb.bbheader.enddate = moment(endDate.value).format('L');

		bb.bbheader.approveddate =  moment(bb.bbheader.approveddate).format('L');
		bb.bbheader.bbreceiveddate =  moment(bb.bbheader.bbreceiveddate).format('L');
		bb.bbheader.checkdate =  moment(bb.bbheader.checkdate).format('L');
		bb.bbheader.createddate =  moment(bb.bbheader.createddate).format('L');
		bb.bbheader.paiddate =  moment(bb.bbheader.paiddate).format('L');
		bb.bbheader.requestapprovaldate = moment(bb.bbheader.requestapprovaldate).format('L');

		//closing method
		bb.bbheader.closingmethod = arrClosingMethdods.find( cm =>  { return cm.id == closingMethod.value} );

		//second row : title, vendor, payye dates
		bb.bbheader.title = title.value;
		bb.postdate = moment(postDate.value).format('L');
		bb.receiveddate = moment(receivedDate.value).format('L');

		// third row : summary, vendor info, payye info, notes
		// $
		bb.claimedamount =  numeral(claimAmount.value).format(fmt_num_2_decimal);
		bb.expectedamount =  numeral(expAmount.value).format(fmt_num_2_decimal);
		bb.variedamount =  numeral(variedAmount.value).format(fmt_num_2_decimal);

		// Cs
		<cfif local.view_program_volume_uom  eq 1 or local.view_program_volume_uom eq 3 >
		bb.claimedcs =  numeral(claimCs.value).format(fmt_num_2_decimal);
		bb.expectedcs =  numeral(expCs.value).format(fmt_num_2_decimal);
		bb.variedcs =  numeral(variedCs.value).format(fmt_num_2_decimal);
		</cfif>

		// Lb
		<cfif local.view_program_volume_uom  eq 2 or local.view_program_volume_uom eq 3 >
		bb.claimedlb = numeral(claimLb.value).format(fmt_num_2_decimal);
		bb.expectedlb = numeral(expLb.value).format(fmt_num_2_decimal);
		bb.variedlb = numeral(variedLb.value).format(fmt_num_2_decimal);
		</cfif>

		//bsa vendor > gm payee
		bb.bbheader.vendor = selectedVendor;
		//bsa payee > gm account
		bb.bbheader.payee = selectedPayee;
		//notes
		bb.bbnotes = notes.value;
		//bb comps
		bb.bbcomponent = arrComponent.filter(comp => { return comp.isselected == 1 });

		// call all validations and if all true call save
		// validate Components
		let bValidHeader = validate_bb_header();
		let bValidComps = validate_bb_components();
		let bValidSpan = validate_bb_span();
		let bValidPgmSpan = validate_bb_info();
		let bValidBBVolRates = validate_bb_vol_rates();

		if (bValidComps && bValidHeader && bValidSpan && bValidPgmSpan && bValidBBVolRates) save_billback();

	}

	function save_billback(){
		// call to save BB to DB. returns bbheader object. also populate the form
		show_loader('Saving Data...');

		let bbIntID = bb.bbheader.billbackidint;

		$.ajax({
			url: "/mvc/Models/Billback/BillbackEditManager.cfc"
			,type: "POST"
			,async: true
			,dataType: "json"
			,data: {
				method: "checkBillbackStatus",
				billbackidint: bbIntID
			}
		})
		.then(result => {
			$("div.loader").hide();
			$("#btnSaveBB").prop("readonly", true).prop("disabled", true);
			if (result.length && result[0].BILLBACK_STATUS_ID >= 3 && !bbDateChange_Allowed) {
				noty({ layout:"center", type:"information", text: "Approved invoice cannot be saved", timeout:3000,
						animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
				return false;
			}
			else{
				$.ajax({
					url: "/mvc/Models/Billback/BillbackEditManager.cfc"
					,type: "POST"
					,async: true
					,dataType: "json"
					,data: {
						method: "saveBillbackJSON",
						billback: JSON.stringify(bb)
					}
				})
				.then(result => {
					$("div.loader").hide();
					bb.bbheader = result;
					// We remove the zero LS comps; the index is out of sync in arrComponents, call the set_components again.
					if (typeof selectedProgram != "undefined") { set_components(selectedProgram.components); }

					//if its a new billback call reload search to display the new billback
					if (bbIntID == 0){
						lockUnlockBB(); // for new bb lock there isnt a bb_id to lock, so lock after save bb.
						parent.parent.reloadSearch();
					}
					else {
						if (typeof window.parent.parent.refreshSearchRowFromEdit !== "undefined") {
							window.parent.parent.refreshSearchRowFromEdit(bb);
						}
					}

					show_billback();
					//enable save button
					$("#btnSaveBB").prop("readonly", false).prop("disabled", false);
					noty({ layout:"center", type:"information", text: "Invoice "+bb.bbheader.bbcode+" saved", timeout:3000,
							animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50} });
					
				})
				.fail(result => {
					$("div.loader").hide();
					//enable save button
					$("#btnSaveBB").prop("readonly", false).prop("disabled", false);
					alert('An error occurred. ' + result.toString());
				});
			}
		})
	}

	function prodFromPgm(){
		// import all products from program not already added to the grid/bb obj
		let arrProdRate 	= selectedProgram.components[0].prodrate;
		let oDistributor	= selectedDistributor;
		let compExists 		=  false;
		let itemExists 		=  false;
		let discountType = 2; // default discount type = rebate

		//verify component is selected
		arrComponent.some( bbComp => {
			if (bbComp.isselected == 1 && selectedProgram.number == bbComp.programnumber && bbComp.componenttypeid != 3){
				discountType = bbComp.componenttypeid;
				compExists = true;
			}
		});

		if(compExists == false){
			noty({
				layout: "center", type: "information", timeout: 5000, killer: true, text: "Please select a component for the selected program",
				animation: { open: { height: 'toggle' }, close: { height: 'toggle' }, easing: 'swing', speed: 50 }
			});
			return;
		}

		arrProdRate.forEach( item => {

			itemExists = false;
			bb.bbprgdistitemrate.some( bbPrg => {
				if (selectedProgram.number == bbPrg.bbprogram.number && item.itemnumber == bbPrg.bbprodrate.itemnumber){
					itemExists = true;
				}
			});

			if(!itemExists){

				let bbPrgItem = JSON.parse(JSON.stringify(oBBPDIR));

				// program
				bbPrgItem.bbprogram.programid	= selectedProgram.programid;
				bbPrgItem.bbprogram.number		= selectedProgram.number;
				bbPrgItem.bbprogram.title		= selectedProgram.title;
				bbPrgItem.bbprogram.startdate	= new Date(selectedProgram.startdate);
				bbPrgItem.bbprogram.enddate		= new Date(selectedProgram.enddate);

				// distributor
				bbPrgItem.bbdistributor = oDistributor;

				// item
				bbPrgItem.bbprodrate.itemnumber 	= item.itemnumber;
				bbPrgItem.bbprodrate.itemguid 		= item.itemguid;
				bbPrgItem.bbprodrate.description 	= item.description;
				bbPrgItem.bbprodrate.netweight 		= parseFloat(item.netweight);
				bbPrgItem.bbprodrate.discounttype   = discountType;
				bbPrgItem.bbprodrate.volume			= 1;
				bbPrgItem.bbprodrate.uom			= {...item.uom}; // shallow copy
				// add the item
				bb.bbprgdistitemrate.push(bbPrgItem);
			}

		});

		glob.my_grid.api.setRowData( bb.bbprgdistitemrate );
	}

	function prodRatesFromPgm(){
		// update product rates from the program for products without a rate
		$.ajax({
			url: "/mvc/Models/Billback/BillbackManager.cfc"
			, type: "POST"
			, async: true
			, dataType: "json"
			, data: {
				method: "getProgramRatesJSON",
				bbPrgDistItemRate: JSON.stringify(bb.bbprgdistitemrate),
				bbComponent: JSON.stringify(arrComponent)
			}
		})
		.then(data => {
			$("div.loader").hide();
			bb.bbprgdistitemrate = data;
			glob.my_grid.api.setRowData( bb.bbprgdistitemrate );
			update_summary();
		})
		.fail(data => {
			$("div.loader").hide();
			alert('An error occurred.  ' + JSON.stringify(data));
		});
	}

	function prodSearch(){

		//clear existing products
		$('#ExistingProductList').val('');
		let lExistingProdList = '';

		// update already existing products
		bb.bbprgdistitemrate.forEach( bbPrg => {

			if(selectedProgram.number == bbPrg.bbprogram.number){
				if(lExistingProdList.length == 0){
					lExistingProdList = bbPrg.bbprodrate.itemguid;
				}
				else{
					lExistingProdList = lExistingProdList + ',' + bbPrg.bbprodrate.itemguid;
				}
			}
		});

		//set existing product list
		$('#ExistingProductList').val(lExistingProdList);
		// display product search popup
		NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=saveProduct&ReloadForm=1&DTPS_Program_ID=" + selectedProgram.programid + "&prgID=" + selectedProgram.programid + "", "productsearch", 800, 900, "yes", "yes");

	}

	function nextAction(){

		if(bb.bbheader.status.id == 1){
			$.ajax({
				url: "/mvc/Models/Billback/BillbackEditManager.cfc"
				,type: "POST"
				,async: true
				,dataType: "json"
				,data: {
					method: "runBillbackDeviationJSON",
					billbackIDInt: bb.bbheader.billbackidint,
					userId:		defaultUserId
				}
				,success: function( result ) {
					bb.bbheader.status = result;
					//if submit to rfa then we have to reload edit so deviations can reference the contentWindow
					parent.document.location = "editing.cfm?billback_Id=" + bb.bbheader.billbackidint;

					noty({
						layout: "center", type: "information", text: "Invoice " + bb.bbheader.bbcode + ":" + bb.bbheader.status.description, timeout:3000,
						animation: {open:{height:'toggle'}, close:{height:'toggle'}, easing:'swing',speed: 50}
					});

				}
			});
		}
		else{
			showDeviations();
		}
	}

	<!------------- Search Program PopUp ------------->
	function popupProgram() {
		$('#FilterType').val(selectedPayee.payeetypeid);
		$('#FilterDataList').val(selectedDistributor.customerid);
		$('#Program_List').val(selectedProgram.programid);
		NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=saveProgram&fieldname=Program_List&SELECTSINGLESEARCHRESULTONLY=1", "programswindow", 900, 900, "yes", "yes");
	}

	function saveProgram(){
		//save program
		let prgId = $('#Program_List').val();
		$('#Program_List').val('');
		selectedProgram.programid = prgId;
		set_program_dropdown();
		get_program(prgId);
	}

	<!------------- Search Customer & Vendor PopUp ------------->
	function popupCust() {
		//if(bEditable){
			NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=saveCust&SelectSingleSearchResultOnly=1&ReloadForm=1&Fieldname=Customer_ID&PageSource=bbCorrections2020", "custSearch", 800, 900, "yes", "yes");
		//}
	}

	function saveCust(){
		var custId = $('#Customer_ID').val();
		getDistributorData(custId);
	}

	function popupVend() {
		//if(bEditable){
			window.open('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=saveVend&Reloadform=1&Fieldname=Vendor_ID&PageSource=corrections&SelectSingleSearchResultOnly=1&DescFieldName=VendName','vendorMaster','width=900,height=900,scrollbars=1');
		//}
	}
	function saveVend(){
		var vId = $('#Vendor_ID').val();
		$("#vendorId").val(vId);
		getVendorData(vId);
	}


	function saveProduct() {

		//get products
		var prodId = $('#Product_List').val();

		$('#Product_List').val('');
		$('#ExistingProductList').val(prodId);

		// show_loader('Loading product data...');
		$.ajax({
			url: "/mvc/models/Billback/BillbackEditSearchManager.cfc"
			, type: "POST"
			, async: false
			, data: {
				method: "getProductDataJSON",
				lItemGuids: prodId
			}
			, error: function (xhr, status, error) { error_handler(arguments); }
			, success: function (result) {
				result = JSON.parse(result);
				let itemExists = false;

				result.forEach(function (item) {

					itemExists = false;
					bb.bbprgdistitemrate.some(bbPrg => {
						if (selectedProgram.number == bbPrg.bbprogram.number && item.itemnumber == bbPrg.bbprodrate.itemnumber) {
							itemExists = true;
						}
					});

					if (!itemExists) {

						let bbPrgItem = JSON.parse(JSON.stringify(oBBPDIR));

						let uom = new Object();

						uom.uomid = 1;
						uom.abbreviation = 'CS';
						uom.description = 'Cases';

						// program
						bbPrgItem.bbprogram.programid = selectedProgram.programid;
						bbPrgItem.bbprogram.number = selectedProgram.number;
						bbPrgItem.bbprogram.title = selectedProgram.title;
						bbPrgItem.bbprogram.startdate = new Date(selectedProgram.startdate);
						bbPrgItem.bbprogram.enddate = new Date(selectedProgram.enddate);

						// distributor
						bbPrgItem.bbdistributor = selectedDistributor;

						// item
						bbPrgItem.bbprodrate.itemnumber = item.itemnumber;
						bbPrgItem.bbprodrate.itemguid = item.itemguid;
						bbPrgItem.bbprodrate.description = item.description;
						bbPrgItem.bbprodrate.netweight = parseFloat(item.netweight);
						bbPrgItem.bbprodrate.discounttype = 2; //default to rebate; prg.type;
						bbPrgItem.bbprodrate.volume = 1;
						bbPrgItem.bbprodrate.uom = {...item.uom}; //shallow copy
						bb.bbprgdistitemrate.push(bbPrgItem);

						glob.my_grid.api.setRowData(bb.bbprgdistitemrate);
					}

					// $("div.loader").hide();
				});

			}
			, error: function (data) {
				// $("div.loader").hide();
				alert('An error occurred.  ' + data.toString());
			}
		})

	}

	function getDistributorData(custId){
		$.ajax({
			async: true
			,dataType: "json"
			,data: { 	method: "getDistributorDataJSON",
						distributorId: custId }
			//,dataType: "json"
			,success: function (data) {
				var dist = data[0];
				var distOptionList = dpdDistributor.options;
				distOptionList.add( new Option(`${dist.shipto} - ${dist.name}`, dist.customerid) );
				dpdDistributor.value = dist.customerid;
				$('#dpdDistributor').select2({
					placeholder: {
						id: dist.customerid, // the value of the option
						text: dist.name
					}
				});
				show_selected_distributor(dist);
			}
			,error: function (data) {
				alert('An error occurred.  ' + JSON.stringify(data) );
			}
			,type: "post"
			,url: "/mvc/Models/Billback/BillbackEditSearchManager.cfc"
			});
	}

	function getVendorData(vendId){
		// show_loader('Loading vendor...');
		$.ajax({
			async: true
			,dataType: "json"
			,data: { 	method: "getVendorDataJSON",
						vendorId: vendId }
			//,dataType: "json"
			,type: "post"
			,url: "/mvc/Models/Billback/BillbackEditSearchManager.cfc"
		})
		.then( data => {
			// set the vendor
			show_selected_vendor(data);
			getPayeeList(data.payeeid); //call to get payeeList
		})
		//.then($("div.loader").hide())
		.fail( data => {
			// $("div.loader").hide();
			alert('An error occurred.  ' + JSON.stringify(data));
		});
	}

	function getPayeeList(vendId) {
		// show_loader('Loading payee...');
		$.ajax({
			async: true
			,dataType: "json"
			,data: {
				method: "getPayeeListJSON",
				vendorId: vendId
			}
			,dataType: "json"
			,type: "post"
			,url: "/mvc/Models/Billback/BillbackEditSearchManager.cfc"
		})
		.then(data => {
			arrPayee = data;
			arrPayee.sort((a, b) => {
				return (a.name < b.name) ? -1 : 1;
			});
			set_payee_dropdown();
		})
		// .then( $("div.loader").hide() )
		.fail(data => {
			// $("div.loader").hide();
			alert('An error occurred.  ' + JSON.stringify(data));
		});
	}

	function set_payee_dropdown() {
		bPayeeExists = 0;
		dpdPayee.innerHTML = ""; // clear the payee dropdown
		let payeeOptionList = dpdPayee.options;
		arrPayee.forEach(payee => {
			payeeOptionList.add(new Option(payee.name, payee.payeeid))
			// find if selectedPayee is in the list set as selected
			if (bb.bbheader.payee.payeeid == payee.payeeid) {
				bPayeeExists = 1;
				show_selected_payee(payee);
			}
		});
		if (!bPayeeExists) {
			show_selected_payee(arrPayee[0]);
			dpdPayeeChange(); //fire payee change event
		 }
	}

	function displayProgram(id) {
		NewWindow('/CID_Wrapper.cfm?Program_ID=' +id +'&Page_Relocate=/scorecard/program_display.cfm', 'ViewProgram','800','600','Yes', 'Yes');
	}

</script>