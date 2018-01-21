$( document ).on('turbolinks:load', function() {
  if (!$('.close-page').length > 0) return;

  if ($('.nav li.active').length == 0) {
    $('.nav li').first().addClass('active');
    $('.tab-content .tab-pane').first().addClass('active');
  }
});