// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


$(function() {
  $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd'
  });

  $('.button').button();

  $('#dialog-confirm').dialog({
    autoOpen: false,
    resizable: false,
    height:200,
    modal: true

  });
  $('.delete').click(function(e) {
    e.preventDefault();
    var url = $(this).attr('href');
    $.get(url, function(data) {
      $('#dialog-body').html(data);
    });
    $('#dialog-confirm').dialog('open');
  });

  $('.infowindow').hide();

  $('.status').hoverIntent(
    function(e) {
      var top_coordinate = e.pageY-115;
      $('.infowindow').css('top', top_coordinate+'px').fadeIn('fast');
    },
    function() {
      $('.infowindow').fadeOut();
    }
  );

  // $('#status-sort').change(function() {
  //   $('#sorter').submit();
  // });

  $('#upload-shapefile').click(function(e) {
    e.preventDefault();
    console.log('click');
    //move latlng div to -1625px left
    $('#latlng').animate({ left: '-1625'}, 300);
  });

  $('#upload-cancel').click(function(e) {
    e.preventDefault();
    $('#latlng').animate({ left: '-207'}, 300);
  });

  $('#choose-dms').click(function(e) {
    e.preventDefault();
    //move latlng div to -863px left
    $('#latlng').animate({ left: '-863'}, 300);
  });

  //convert DMS to Decimal:
  var latsign = 1;
  var lonsign = 1;
  var absdlat = 0;
  var absdlon = 0;
  var absmlat = 0;
  var absmlon = 0;
  var absslat = 0;
  var absslon = 0;

  //handle the lattitude
  $('#dlat').blur(function() {
    if($(this).val() < 0) {
      latsign = -1;
    }
    absdlat = Math.abs( Math.round($(this).val() * 1000000.0));
    if (absdlat > (90 * 1000000)) {
      alert(' Degrees Latitude must be in the range of -90 to 90. ');
      $('#dlat').val('');
    }
  });

  $('#mlat').blur(function() {
    $(this).val(Math.abs(Math.round($(this).val() * 1000000.0)/1000000));
    absmlat = Math.abs(Math.round($(this).val() * 1000000.0));
    if(absmlat >= (60 * 1000000)) {
      alert(' Minutes Latitude must be in the range of 0 to 59. ');
      $('#mlat').val('');
    }
  });

  $('#slat').blur(function() {
    $(this).val(Math.abs(Math.round($(this).val() * 1000000.0)/1000000));
    absslat = Math.abs(Math.round($(this).val() * 1000000.0));
    if (absslat > (59.99999999 * 1000000)) {
      alert(' Minutes Latitude must be 0 or greater \n and less than 60. ');
      $('#slat').val('');
    }
  });

  //handle the longitude
  $('#dlon').blur(function() {
    if($(this).val() < 0) {
      lonsign = -1;
    }
    absdlon = Math.abs( Math.round($(this).val() * 1000000.0));
    if(absdlon > (180 * 1000000)) {
      alert(' Degrees Longitude must be in the range of -180 to 180. ');
      $('#dlon').val('');
    }
  });

  $('#mlon').blur(function() {
    $(this).val(Math.abs(Math.round($(this).val() * 1000000.0)/1000000));
    absmlon = Math.abs(Math.round($(this).val() * 1000000));
    if (absmlon >= (60 * 1000000)) {
      alert(' Minutes Longitude must be in the range of 0 to 59. ');
    }
  });

  $('#slon').blur(function() {
    $(this).val(Math.abs(Math.round($(this).val() * 1000000.0)/1000000));
    absslon = Math.abs(Math.round($(this).val() * 1000000.0));
    if (absslon > (59.99999999 * 1000000)) {
      alert(' Minutes Latitude must be 0 or greater \n and less than 60. ');
      $('#slon').val('');
    }
  });

  //clicking the button does the math
  $('#convert-to-decimal').click(function(e) {
    e.preventDefault();
    $('#request_lat').val(Math.round(absdlat + (absmlat/60.0) + (absslat/3600.0) ) * latsign/1000000);
    $('#request_lng').val(Math.round(absdlon + (absmlon/60) + (absslon/3600) ) * lonsign/1000000);
    $('#latlng').animate({ left: '-207'}, 300);
    latsign=1;
    lonsign=1;
  });

  $('#convert-cancel').click(function(e) {
    e.preventDefault();
    $('#latlng').animate({ left: '-207'}, 300);
  });

  $('.tablesorter').tablesorter({
    headers: {
      6: {
        sorter: false
      },
      7: {
        sorter: false
      },
      8: {
        sorter: false
      }
    }
  });
});

