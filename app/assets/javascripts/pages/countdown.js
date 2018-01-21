$( document ).on('turbolinks:load', function() {

  if ($('#sidebar-countdown').length) {
    var flipcountdown_box = $("#flipcountdown-box");
    flipcountdown_box.flipcountdown({
      size: 'sm',
      beforeDateTime: flipcountdown_box.data('date-end')
    });

    countdownSetLabelsWidth('#sidebar-countdown', 24);
    countdownObserver('#sidebar-countdown', 24);
  }

  if ($('#panel-countdown').length) {
    var panel_flipcountdown_box = $('#panel-flipcountdown-box');
    panel_flipcountdown_box.flipcountdown({
      size: 'md',
      beforeDateTime: panel_flipcountdown_box.data('date-end')
    });

    countdownSetLabelsWidth('#panel-countdown', 36);
    countdownObserver('#panel-countdown', 36);
  }

  function countdownSetLabelsWidth(countdownSelector, digitWidth) {
    var countdownBox  = $(countdownSelector);
    var labels        = countdownBox.find('.flipcountdown-footer-labels');
    var cells         = new Array(labels.length).fill(0);
    var index         = 0;

    countdownBox.find('div.xdsoft_flipcountdown div').each(function() {
      if (this.className === 'xdsoft_digit') {
        cells[index]++;
      } else if (this.className === 'xdsoft_digit xdsoft_space') {
        index++;
      }
    });

    labels.each(function(i) {
      $(this).css('width', digitWidth * cells[i++] + 'px');
    });
  }

  function countdownObserver(countdownSelector, digitWidth) {
    var target    = $(countdownSelector)[0];
    var config    = { childList: true, subtree: true };
    var observer  = new MutationObserver(function( mutations ) {
      mutations.forEach(function( mutation ) {
        if (mutation.removedNodes.length > 0 || mutation.addedNodes.length > 0) {
            countdownSetLabelsWidth(countdownSelector, digitWidth);
        }
      });
    });

    observer.observe(target, config);
  }
});