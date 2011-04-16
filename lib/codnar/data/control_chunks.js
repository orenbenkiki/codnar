/*
 * Quick-and-dirty JS for inserting a "+"/"-" control for chunk visibility next
 * to each chunk's name. By default, all chunks are hidden.
 */
function inject_chunk_controls() {
  var name_div;
  foreach_chunk_elements(function(div) {
    name_div = div;
  }, function(html_div) {
    var control_span = document.createElement("span");
    var hide = function() {
      control_span.innerHTML = "+";
      html_div.style.display = "none";
    }
    var show = function() {
      control_span.innerHTML = "&#8211;"; // Vertical bar.
      html_div.style.display = "block";
    }
    name_div.onclick = function() {
      html_div.style.display == "block" ? hide() : show();
    }
    hide(); // Initializes html_div.style.display
    control_span.className = "control chunk";
    name_div.insertBefore(control_span, name_div.firstChild);
  })
}

/*
 * Loop on all DIV elements that contain a chunk name, or that contain chunk
 * HTML. Assumes that they come in pairs - name first, HTML second.
 */
function foreach_chunk_elements(name_lambda, html_lambda) {
  var div_elements = document.getElementsByTagName("div");
  for (var e in div_elements) {
    var div = div_elements[e];
    classes = " " + div.className + " ";
    if (!/ chunk /.test(classes)) continue;
    if (/ name /.test(classes)) name_lambda(div);
    if (/ html /.test(classes)) html_lambda(div);
  }
}

/* Only invoke it after all helper functions are defined. */
inject_chunk_controls();
