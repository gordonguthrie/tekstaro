// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import $ from 'jquery'

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
  var csrf = $("input[name=_csrf_token]").val();
  var payload = {"text": text, "url": url, "title": title, "_csrf_token": csrf};
  $.ajax('/en/upload',
    {
      type: 'POST',  // http method
      data: payload,
      success: function (data, status, xhr) {
        var hash = data["channel"]
        join(hash)
      },
      error: function (data, status, xhr) {
        console.log(JSON.parse(data.responseText).error);
        var msg = JSON.parse(data.responseText).error
        $(".alert-danger").text(msg)
      }
    });
})

$("#tekstaro_search").click(function(e) {
  var search_term = $("#tekstaro_search_term").val();
  // null searches cause the back end to crash
  if (search_term === "") {
    return;
  }
  var csrf = $("input[name=_csrf_token]").val();
  var payload = {"search_term": search_term, "_csrf_token": csrf};
  $.ajax('/en/',
    {
      type: 'POST',  // http method
      data: payload,
      success: function (data, status, xhr) {
        var results = ""
        $.each(data["response"], function(x) {
          var text = data["response"][x]["text"];
          var annotations = data["response"][x]["annotations"];
          //console.log(text);
          //console.log(annotations);
          var start = 0;
          var html = "<p class='tekstaro_results'>";
          $.each(annotations, function(a) {
            var astart = annotations[a].start;
            var afinish = astart + annotations[a].length;
            var first = text.slice(start, astart);
            //console.log(first)
            var note = text.slice(astart, afinish);
            console.log("note is " + note + " going from " + astart + " to " + afinish)
            //console.log(note);
            html += first
             + "<span class='tekstaro_highlight'>"
             + note
             + "</span>";
           start = afinish;
          });
         var finale = text.slice(start, text.length);
         //console.log(finale)
         html += finale + "</p>";
         results += html
      });
      console.log($(".tekstaro_results"))
      $("#tekstaro_results").html(results)
      },
      error: function (data, status, xhr) {
        console.log(data)
        console.log(JSON.parse(data.responseText).error);
        var msg = JSON.parse(data.responseText).error
        $(".alert-danger").text(msg)
      }
    });
})
