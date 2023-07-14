$(document).ready(function() {
  $("#userName").focus(); 
});

// click a button if the Enter key is pressed, depending on which input has focus
$(document).keyup(function(event) {
  if (event.keyCode == 13) {
    if ($("#passwd").is(":focus")) {
      $("#btnLogin").click();      
    }
    if ($("#duoPasscode").is(":focus")) {
      $("#btn2FaLogin").click();      
    }
    if ($("#searchTerm").is(":focus")) {
      $("#btnAddTerm").click();      
    }
  }
});
