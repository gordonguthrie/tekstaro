// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

global.$ = global.jQuery = $;

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import {socket, join} from "./socket"

var tekstaro = function () {

  var build_results = function (data) {
    var results = ""
    var html = ""
    if (data.length === 0) {
      html = "<p>No results match</p>"
    } else {
      $.each(data, function(x) {
        var text = data[x]["text"]
        var annotations = data[x]["annotations"]
        var title = data[x]["title"]
        var url = data[x]["url"]
        var paragraph_sequence = data[x]["paragraph_sequence"].toString()
        var start = 0
        html += "<p class='tekstaro_results tekstaro_tight'>"
        $.each(annotations, function(a) {
          var astart = annotations[a].start
          var afinish = astart + annotations[a].length
          var first = text.slice(start, astart)
          var note = text.slice(astart, afinish)
          html += first
            + "<span class='tekstaro_highlight'>"
            + note
            + "</span>"
          start = afinish
        });
        var finale = text.slice(start, text.length)
        html += finale + "</p>"
        html += "<a href='" + url + "' class='tekstaro_small'>" + title + " (paragraph " + paragraph_sequence + ")</a>"
        html += "<hr />"
      })
    }
    return results += html
  }

  var build_parse_results = function (data) {
    if (data.length === 0) {
      return ""
    } else {
      $(".tekstaro_results_header").addClass("tekstaro_hidden")
      var html = ""
      $.each(data, function(x) {
        var details = data[x]["details"]
        var affixes = data[x]["affixes"]
        html += "<p class='tekstaro_results tekstaro_tight tekstaro_highlight'>"
        html += data[x]["word"]
        html += " (" + data[x]["root"] + ")"
        html += "</p>"
        html += "<p class='tekstaro_results tekstaro_tight tekstaro_small'>"
        html += data[x]["note"]
        html += "</p>"
        $.each(details, function(x) {
          html += "<p class='tekstaro_results tekstaro_tight tekstaro_small'>" + details[x] + "</p>"
        })
        $.each(affixes, function(x) {
          html += "<p class='tekstaro_results tekstaro_tight tekstaro_small'>"
          + affixes[x]["meaning"]
          + " (<span class='tekstaro_highlight'>"
          + affixes[x]["element"]
          + "</span>)"
          + "</p>"
        })
      })
    }
    return html
  }

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

  $("#tekstaro_search_term").keyup(function(e) {
    var search_term = $("#tekstaro_search_term").val();
    // null searches cause the back end to crash
    if (search_term === "") {
      return;
    }
    $(".phx-hero").addClass("tekstaro_hidden");
    var locale =  document.documentElement.lang;
    var payload = {"search_term": search_term, "locale": locale};
    $.ajax('/api/parse',
      {
        type: 'POST',  // http method
        data: payload,
        success: function (data, status, xhr) {
          var html = build_parse_results(data["response"]["data"])
          $("#tekstaro_search_words").html(html)
          $(".tekstaro_search_header").removeClass("tekstaro_hidden")
        },
        error: function (data, status, xhr) {
          console.log(data)
          console.log(JSON.parse(data.responseText).error);
          var msg = JSON.parse(data.responseText).error
          $(".alert-danger").text(msg)
        }
      });
  });

  $("#tekstaro_search").click(function(e) {
    var search_term = $("#tekstaro_search_term").val();
    // null searches cause the back end to crash
    if (search_term === "") {
      return;
    }
    $(".phx-hero").addClass("tekstaro_hidden");
    var payload = {"search_term": search_term};
    $.ajax('/api/search',
    {
      type: 'POST',  // http method
      data: payload,
      success: function (data, status, xhr) {
        var results = ""
        results = build_results(data["response"]["data"])
        $("#tekstaro_results").html(results)
        $(".tekstaro_results_header").removeClass("tekstaro_hidden")
      },
      error: function (data, status, xhr) {
        console.log(data)
        console.log(JSON.parse(data.responseText).error);
        var msg = JSON.parse(data.responseText).error
        $(".alert-danger").text(msg)
      }
    })
  })

 var do_explore_corpus = function () {

  var currentmenu = $("#activate_tekstaro_menu").data("menu")
  // if we are not on the explore page then wig out
  if (currentmenu != "tekstaro_menu_browse") {
    console.log("bombing out early");
    return;
  }

  var init_fn = function () {
   var checked_radio_button = $("input:radio[name='browse']:checked")[0].value;
   var checked_class = ".tekstaro_" + checked_radio_button;
   $(checked_class).removeClass("tekstaro_hidden");
  };

  var browse_change_fn = function (e) {
    var class_to_show = ".tekstaro_" + e.target.value;
    $(".tekstaro_hideable").addClass("tekstaro_hidden");
    $(class_to_show).removeClass("tekstaro_hidden");
    if ((class_to_show != ".tekstaro_smallword") && (class_to_show != ".tekstaro_krokodilo")) {
      $(".tekstaro_hide_on_load").removeClass("tekstaro_hidden");
    } else {
      $(".tekstaro_hide_on_load").addClass("tekstaro_hidden");
    }
  };

  var browse_fn = function (e) {
    console.log("browse clicked");
    var checked_radio_button = $("input:radio[name='browse']:checked")[0].value;
    console.log(checked_radio_button);
    var selections = $(".tekstaro_" + checked_radio_button + " input");
    console.log(selections);
    $.each(selections, function (n) {
      console.log(n);
      console.log(selections[n].name);
      console.log(selections[n].checked);
    })
  }

  init_fn()
  $("input:radio[name='browse']").change(browse_change_fn);
  $("#tekstaro_browse").click(browse_fn);

};

 var do_menu = function () {
  $(".teskaro_menu_active").removeClass("teskaro_menu_active");
  var currentmenu = "." + $("#activate_tekstaro_menu").data("menu");
  $(currentmenu).addClass("teskaro_menu_active");
 }

 do_menu();

 do_explore_corpus();

}

window.onload = tekstaro
