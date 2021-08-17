console.log("Hello world!")

function updateHostnameText() {
  let items = document.querySelectorAll(".hostname");
  for (i=0; i<items.length; i++) {
    items[i].innerHTML = window.location.hostname;
  }
};

function updateLinkHostnames() {
  let items = document.querySelectorAll("a");
  for (i=0; i<items.length; i++) {
    let url = new URL(items[i].href)
    if (url.hostname == "127.0.0.1") {
      url.hostname = window.location.hostname;
    }
    items[i].href = url.href;
  }
}

// Vanilla JS alternative to $(document).ready()
document.addEventListener("DOMContentLoaded", function(){
  updateHostnameText()
  updateLinkHostnames()
});
