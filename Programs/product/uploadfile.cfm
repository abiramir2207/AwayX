 <p id="uploadFileName">Select a file to upload:</p>
<INPUT SIZE="45" TYPE="file" NAME="File_Path" ID="File_Path" accept=".csv" onChange="uploadFile()">

<script>
  function uploadFile(){
    var x = document.getElementById("File_Path");
    var txt = "";
    if ('files' in x) {
      if (x.files.length == 0) {
        txt = "Select a file to upload.";
      } else {
        for (var i = 0; i < x.files.length; i++) {
         // txt += "<br><strong>" + (i+1) + ". file</strong><br>";
          var file = x.files[i];
          if ('name' in file) {
            txt += "name: " + file.name;
          }
          if ('size' in file) {
            txt += " size: " + file.size + " bytes <br>";
	    //alert('preview');
            previewFile();
          }
        }
      }
    }
    else {
      if (x.value == "") {
        txt += "Select a file to upload.";
      } else {
        txt += "The files property is not supported by your browser!";
        txt  += "<br>The path of the selected file: " + x.value; // If the browser does not support the files property, it will return the path of the selected file instead.
      }
    }
    document.getElementById("uploadFileName").innerHTML = txt;
  }


  function previewFile() {
    var file    = document.querySelector('input[type=file]').files[0];
    var reader  = new FileReader();

    reader.addEventListener("load", function () {
	/* Get the data from the file and send it to "uploadProductRates" function */
	uploadProductRates(reader.result);
    }, false);

    if (file) {
      reader.readAsDataURL(file);
    }
    // setTimeout (window.close, 2000);
  }

function uploadProductRates(data){
	let arrData = data.split(",");
	let decodedBase64String;
	let arrDecodedBase64String;
	let arrCleanedUpDecodedBase64 = []; //cleanedup array
	arrData = arrData[arrData.length - 1];
	/* The data received from the file is in base 64 format. "atob" function decoded it. */
	decodedBase64String = atob(arrData);
	arrDecodedBase64String = decodedBase64String.split("\n");

	arrDecodedBase64String.forEach(function(item){
		/* When the array is created, the array may have elements which are not needed. Typically, the length of those
		elements is either 1 or 0. Just to be safe, adding a leghth of 20. This way we will only get those elements of the array
		which have valid data. */
		if(item.length > 20){
			arrCleanedUpDecodedBase64.push(item);
		}
	});

	/* Call function to process this array. */
    window.opener.processFileData(arrCleanedUpDecodedBase64);
    //setTimeout (window.close, 500);
}
</script>