/*
 * Quick-and-dirty JS for inserting a table of content inside a DIV with the id
 * "contents". The table of content is a series of nested UL and LI elements,
 * prefixed with an H1 containing the text "0 Contents". This H1 comes in
 * addition to the single static H1 expected by HTML best practices. It looks
 * "right" and should not confuse search engines etc. since they do not execute
 * Javascript code.
 */
if (document.getElementById) onload = function () {
  var contents = document.getElementById("contents");
  var lists = contents_lists();
  contents.appendChild(contents_header()); // TRICKY: Must be done after contents_lists().
  contents.appendChild(lists);
}

/*
 * Create a table of contents H1.
 */
function contents_header() {
  var h = document.createElement("h1");
  var text = document.createTextNode("Contents");
  h.appendChild(text);
  return h;
}

/*
 * Create nested UL/LI lists for the table of content.
 */
function contents_lists() {
  var container;
  var indices = [];
  foreach_h_element(function (h, level) {
    container = pop_container(container, indices, level);
    container = push_container(container, indices, level);
    var id = indices.join(".");
    container.appendChild(list_element(id, h));
    h.insertBefore(header_anchor(id), h.firstChild);
  });
  return pop_container(container, indices, 1);
}

/*
 * Apply a lambda to all H elements in the DOM. We skip the single H1 element;
 * otherwise it would just have the index "1" which would be prefixed to all
 * other headers.
 */
function foreach_h_element(lambda) {
  var elements = document.getElementsByTagName("*");
  for (var e in elements) {
    var h = elements[e];
    if (!/^h[2-9]$/i.test(h.tagName)) continue;
    var level = h.tagName.substring(1, 2) - 1;
    lambda(h, level);
  }
}

/*
 * Pop indices (and UL containers) until reaching up to a given level.
 */
function pop_container(container, indices, level) {
  while (indices.length > level) {
    container = container.parentNode;
    indices.pop();
  }
  return container;
}

/*
 * Push indices (and UL containers) until reaching doen to a given level.
 */
function push_container(container, indices, level) {
  while (indices.length < level) {
    // TRICKY: push a 0 for the very last new level, so the ++ at the end
    // will turn it into a 1.
    indices.push(indices.level < level - 1);
    var ul = document.createElement("ul");
    if (container) {
      container.appendChild(ul);
    }
    container = ul;
  }
  indices[indices.length - 1]++;
  return container;
}

/*
 * Create a LI for an H element with some id.
 */
function list_element(id, h) {
  var a = document.createElement("a");
  a.href = "#" + id;
  a.innerHTML = id + "&nbsp;" + h.innerHTML;
  var li = document.createElement("li");
  li.appendChild(a);
  return li;
}

/*
 * Create an anchor for an H element with some id.
 */
function header_anchor(id) {
  var text = document.createTextNode(id + " ");
  var a = document.createElement("a");
  a.id = id;
  a.appendChild(text);
  return a;
}
