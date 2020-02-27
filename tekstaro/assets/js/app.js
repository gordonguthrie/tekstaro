// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import $ from "jquery"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import {socket, join} from "./socket"

$("#tekstaro_upload").click(function(e) {
  var text = $("#tekstaro_text").val();
  var url = $("#tekstaro_url").val();
  var title = $("#tekstaro_title").val();
  var payload = {"text": text, "url": url, "title": title}
  $.ajax('/api/upload',
    {
      type: 'POST',  // http method
      data: payload,
      success: function (data, status, xhr) {
        var hash = data["channel"]
        join(hash)
      },
      error: function (data, status, xhr) {console.log("error");}
});
})
