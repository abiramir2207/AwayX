<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 01-10-2019
  *  Dropdown menu button, adapted from w3schools.com
  *
  *  Usage example, including font-awesome dropdown icon from "/styles/font-awesome.min.css":
  *
        <div class="dropdown">
            <button onclick="ShowHideDropbtn()" id="dropbtn" class="button"> 
                Dropdown &nbsp; <i class="fa fa-caret-down btn-icon"></i>
            </button>

            <div id="myDropdown" class="dropdown-content">
                <a href="#copy">Copy</a>
                <a href="#delete">Delete</a>
                <a href="#update">Update</a>
            </div>
        </div>

  *
  * ====================================================================================================
--->

<style>

.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #FFF;
  margin-left: 10px;
  min-width: 80px;
  overflow: auto;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

.dropdown-content a {
  color: #343540;
  padding: 5px 10px;
  text-decoration: none;
  display: block;
}

.dropdown a:hover {background-color: #EDEEF2;}

/* Make sure any icon is clickable too */
button > * {
  pointer-events: none;
}

.show {display: block;}
</style>

<script>
    /* When the user clicks on the button, toggle between hiding and showing the dropdown content */
    function ShowHideDropbtn() {
        document.getElementById("myDropdown").classList.toggle("show");
    }


    /* when user clicks outside of the dropdown, close it if open */
    window.addEventListener("click", function(event) {
        // if (!event.target.matches('#dropbtn')) {     // IE has it's own method name
        let matches = event.target.matches ? event.target.matches('#dropbtn') : event.target.msMatchesSelector('#dropbtn');
        if (!matches) {
            let myDD = document.getElementById("myDropdown");
            if (myDD.classList.contains('show')) {
                myDD.classList.remove("show");
            }
        }
    })

</script>