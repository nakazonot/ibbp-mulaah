$( document ).on('turbolinks:load', function() {
  if (!$('.main-page').length > 0) return;

  var input_wait = 500;
  var calc_tokens_price_fl = false;

  var coin_prices = false;
  var coin_prices_for_buy = false;
  var coin_for_total = false;
  var one_currency_on_balance = false;

  var calc_direction = $(".calculator .direction").attr('data-direction');
  var clipboard = new Clipboard('#refer-copy-link');
  set_default_calculator_amount();
  disable_buy_now_button();
  tab_content_qrcode();

  if ($('.calculator').length > 0) {
    get_coin_price();
  }

  if ($('.nav').length > 0) {
    currency_init();
  }

  if ($('.buy-tokens-form').length > 0) {
    get_coin_price_for_buy();
  }

  $("#coin-amount").off('input').on("input", function() {
    $(this).val(prepare_coin_number($(this).val()));
    get_coin_price_debounce();
  });

  $(".buy-tokens-form .coin-amount").off('input').on("input", function() {
      calc_tokens_price_fl = true;
      update_coin_amount_buy_form();
  });

  $(".buy-tokens-form .spend-all-checkbox .checkbox").off('change').on("change", function(e) {
    var buy_from_all_balance = $(this).find('input').prop('checked');
    if (buy_from_all_balance) {
      $('.input-number').prop('disabled', true);
      $('#btn-plus').prop('disabled', true);
      $('#btn-minus').prop('disabled', true);
      $('.buy-tokens-form .list-currency .current-currency').addClass('disabled');
      $('.buy-tokens-form .list-currency').addClass('disabled-list');
    } else {
      $('.input-number').prop('disabled', false);
      $('.buy-form-user-deposits').empty();
      $('#btn-plus').prop('disabled', false);
      $('#btn-minus').prop('disabled', false);
      $('.buy-tokens-form .list-currency .current-currency').removeClass('disabled');
      $('.buy-tokens-form .list-currency').removeClass('disabled-list');
      $('#total-price-box p').removeClass('coin-box-big');
      $('.price-box-separator').hide();
    }
    update_coin_amount_buy_form(buy_from_all_balance);
  });

  $(".buy-tokens-form .purchase-agreement .checkbox").off('change').on("change", function(e) {
    disable_buy_now_button();
  });

  $("#coin-price").off('input').on("input", function() {
    var active_currency = $('.calculator .list-currency a.current-currency').data('code');
    $(this).val(prepare_currency_number($(this).val(), active_currency));
    get_coin_for_total_debounce();
  });

  $('.calculator .list-currency .calculator-currency').on('click', function () {
    list_currency = $(this).closest('.list-currency');
    list_currency.find('a.current-currency').removeClass('current-currency');
    $(this).addClass('current-currency');

    select_coin_price(list_currency.find('a.current-currency').data('code'));
  });

  $('.buy-tokens-form .list-currency .calculator-currency').on('click', function () {
    list_currency = $(this).closest('.list-currency');
    list_currency.find('a.current-currency').removeClass('current-currency');
    $(this).addClass('current-currency');

    select_coin_price_for_buy(list_currency.find('a.current-currency').data('code'));
  });

  $('.list-currency .btn-select').on('click', function (e) {
    list_currency = $(this).closest('.list-currency');
    e.preventDefault();
    list_currency.toggleClass('open');
  });

  $('.list-currency .btn-group-vertical a').on('click', function (e) {
    e.preventDefault();

    $(this).closest('.list-currency')
      .removeClass('open')
      .find('.btn-select span').html($(this).find('span').html());
  });

  $(".calculator .direction").off('click').on("click", function(e) {
    calc_block = $(this).closest('.calculator');
    calc_direction = $(this).attr('data-direction');
    if (calc_direction == 'right') {
      get_coin_for_total_debounce();
      calc_direction = 'left';
      $(this).attr('data-direction', calc_direction);
      $(this).find('.fa').removeClass('fa-arrow-right').addClass('fa-arrow-left');
      $('#coin-amount').prop("disabled", true);
      $('#coin-price').prop("disabled", false);
    } else {
      get_coin_price_debounce();
      calc_direction = 'right';
      $(this).attr('data-direction', calc_direction);
      $(this).find('.fa').removeClass('fa-arrow-left').addClass('fa-arrow-right');
      $('#coin-amount').prop("disabled", false);
      $('#coin-price').prop("disabled", true);
    }
  });

  $("#contract-modal .accept").off('click').on("click", function(e) {
    contract_id = $(this).attr('data-contract-id');
    $.LoadingOverlay('show');
    $.ajax({
      url: '/coinbox/contract-accept',
      dataType: 'json',
      method: 'post',
      data: { contract_id: contract_id },
      success: function(response) {
        send_transaction_to_gtm(response);
        $("#contract-modal").modal('hide');
        location.reload();
      },
      error: function (xhr) {
        if (xhr.responseJSON && xhr.responseJSON['msg']) {
          update_coin_amount_buy_form($('#form-token-spend-all-checkbox').prop('checked'));
          update_actual_promocode();
          $("#contract-modal").modal('hide');

          toastr.error(xhr.responseJSON['msg']);
        }
      },
      complete: function (response) {
        $.LoadingOverlay('hide');
      }
    });
  });

  $("#myTabContent .get-address").off('click').on("click", function(e) {
    var currency_code = $(this).attr('data-code');
    get_address(currency_code);
  });

  $("#myTabContent .generate-invoices").off('click').on("click", function(e) {
    var currency_code = $(this).attr('data-code');
    $('#invoice-modal').attr('data-currency', currency_code).modal('show');
  });

  $("#generate-invoice-form").on("ajax:success", function(e, data, status, xhr) {
    $('#invoice-modal .validate-error').addClass('hide');
    $('#invoice-modal').modal('hide');
    $('#invoice-pdf-url').attr('href', data.pdf_url)
    $('#invoice-success-modal').modal('show');
  }).bind("ajax:error", function(e, xhr, status, error) {
    if (xhr.responseJSON['error'] == 'valid_error') {
      $('#invoice-modal .validate-error').removeClass('hide');
      var notificationText = '';
      $.each(xhr.responseJSON['messages'], function (i, val) {
        notificationText += '<li>'+ val + '</li>';
      });
      $('#invoice-modal .validate-error div').html(notificationText);
      toastr.error('Validation error');
    } else if (xhr.responseJSON['error']) {
      $('#invoice-modal .validate-error div').html('');
      toastr.error(xhr.responseJSON['error']);
    }
  }).bind("ajax:beforeSend", function(e, data, status, xhr) {
    $.LoadingOverlay('show');
  }).bind("ajax:complete", function(e, data, status, xhr) {
    $.LoadingOverlay('hide');
  });

  $(".buy-tokens-form .buy-now").off('click').on("click", function(e) {
    if (calc_tokens_price_fl) return;

    form = $(this).closest('.buy-tokens-form');
    var currency_code        = one_currency_on_balance ? form.find('.coin-price-currency').text() : form.find('.list-currency .current-currency').attr('data-code'),
        coin_amount          = form.find('.coin-amount').val(),
        coin_price           = form.find('.coin-price').text(),
        buy_from_all_balance = form.find('.checkbox input').prop('checked') && !one_currency_on_balance;
    if (coin_amount <= 0) return;
    $.ajax({
      url: '/coinbox/buy-coins',
      dataType: 'json',
      method: 'post',
      data: {
        currency: currency_code,
        coin_price: coin_price,
        coin_amount: coin_amount,
        buy_from_all_balance: buy_from_all_balance,
        purchase_agreement: check_purchase_agreement()
      },
      success: function(response) {
        var modal = $('#contract-modal');
        modal.find('.accept').attr('data-contract-id', response.contract.id);
        modal.find('.coin-amount').text(response.contract.info.coin_amount);
        modal.find('.token-pluralize').text(response.contract.info.coin_amount === 1 ? 'token' : 'tokens')
        modal.find('.coin-rate').text(parseFloat(response.contract.info.coin_rate));
        modal.find('.currency').text(response.contract.info.currency);
        modal.find('.coins-bonus').text(response.contract.info.coin_bonus_total);
        modal.find('.link-to-pdf').attr('href', response.contract_path);

        display_form_token_bonus();

        modal.modal('show');
      },
      error: function (xhr) {
        if (xhr.responseJSON && xhr.responseJSON['error']) {
          toastr.error(xhr.responseJSON['error']);
          update_coin_amount_buy_form(buy_from_all_balance);
        }
      }
    });
  });

  $("#agreement-modal .accept").off('click').on("click", function(e) {
    var modal = $('#agreement-modal');
    var currency_code = modal.attr('data-currency');
    $.LoadingOverlay('show');
    $.ajax({
      url: '/user/agreement',
      dataType: 'json',
      method: 'post',
      data: {},
      success: function(response) {
        modal.modal('hide');
        get_address(currency_code);
      },
      error: function (xhr) {
        if (xhr.responseJSON && xhr.responseJSON['error']) {
          toastr.error(xhr.responseJSON['error']);
        }
      },
      complete: function(response) {
        $.LoadingOverlay('hide');
      }
    });
  });

  $('#btn-plus').on('click', function() {
    var coin_amount = $('.coin-amount');
    coin_amount.val((parseFloat(prepare_coin_number(coin_amount.val())) + 1));
    update_coin_amount_buy_form();
  });

  $('#btn-minus').on('click', function() {
    var coin_amount = $('.coin-amount');
    value = parseFloat(prepare_coin_number(coin_amount.val())) - 1
    if (value < 0) value = 0;
    coin_amount.val(value);
    update_coin_amount_buy_form();
  });

  $('a[href^="#"]').on('click', function(event) {
    var target = $(this.getAttribute('href'));

    if( target.length ) {
      event.preventDefault();
        $('html, body').stop().animate({
          scrollTop: target.offset().top
        }, 800);
    }
  });


  $('.buy-tokens-form').on('submit', function(event) {
      event.preventDefault();
  });

  $('#btn-token-promocode-add').on('click', function(event) {
    event.preventDefault();
    var promocode = $('#input-form-token-promocode').val();
    add_promocode_to_current_user(promocode);
  });

  $('#input-form-token-promocode').on('keypress', function(event) {
    if (event.which === 13) {
      $('#btn-token-promocode-add').click();
    }
  });


  function add_promocode_to_current_user(promocode) {
    $.ajax({
      url: '/user/add-promocode',
      dataType: 'json',
      method: 'post',
      data: { promocode: promocode },
      success: function(response) {
        display_form_token_actual_promo(promocode);
        if (response['buy_tokens_promocode'] && $('.buy-tokens-form .buy-now').prop('disabled')) {
          location.reload();
          return false;
        }
        update_coin_amount_buy_form($('#form-token-spend-all-checkbox').prop('checked'));

        toastr.success(response['msg']);
      },
      error: function (xhr) {
        if (xhr.responseJSON && xhr.responseJSON['msg']) {
          toastr.error(xhr.responseJSON['msg']);
        }
      }
    });
  }

  function update_actual_promocode() {
    $.ajax({
      url: '/user/get-promocode',
      dataType: 'json',
      method: 'get',
      success: function(response) {
        display_form_token_actual_promo(response['code']);
      },
      error: function(xhr) {
      }
    })
  }

  function prepare_number(value_raw, round_num) {
    var value = value_raw.replace(/[^0-9|/.]/g,'');

    if (/^\./.test(value)) {
      value = value.replace(/[^0-9]/g, '');
    }
    if (/^0/.test(value) && !/^0\./.test(value)) {
      value = value.substr(1);
    }

    if (typeof round_num !== 'undefined' && value.indexOf('.') != -1) {
      value = value.substr(0, value.indexOf('.') + round_num + (round_num == 0 ? 0 : 1));
    }
    if (value.length === 0) return 0;
    return value;
  }

  function prepare_coin_number(value_raw) {
    return prepare_number(value_raw, gon.coin_precision);
  }

  function prepare_currency_number(value_raw, currency) {
    round_num = currency == gon.default_currency ? gon.usd_precision : gon.currency_precision
    return prepare_number(value_raw, round_num);
  }

  function get_address(currency_code) {
    var tab = $("#" + currency_code + ".tab-pane");
    $.LoadingOverlay('show');
    $.ajax({
      url: '/coinbox/get-address',
      dataType: 'json',
      method: 'post',
      data: { currency: currency_code },
      success: function(response) {
        tab.find('.get-address').addClass('hide');
        tab.find('.payment-block').removeClass('hide');
        tab.find(".payment-address").text(response.address);
        tab.find(".pubkey").text(response.pubkey);
        tab.find(".dest-tag").text(response.dest_tag);
        create_qrcode(tab.find(".quare-code"), response.address);
      },
      error: function (xhr) {
        if (xhr.responseJSON && xhr.responseJSON['error']) {
          toastr.error(xhr.responseJSON['error']);
        }
      },
      complete: function(response) {
        $.LoadingOverlay('hide');
      }
    });
  }

  function get_coin_price() {
    $.ajax({
      url: '/coinbox/coin-price',
      dataType: 'json',
      method: 'post',
      data: { coin_amount: parseFloat($("#coin-amount").val()) },
      success: function(response) {
        var active_currency = $('.calculator .list-currency a.current-currency').data('code');
        coin_prices = response.currencies;
        select_coin_price(active_currency);
        $("#coin-total").text(response.coin_amount_total);
        $("#coin-bonus").text(response.coin_amount_bonus);
        $("#coin-bonus-percent").text(response.bonus_percent + '%');
      }
    });
  }
  var get_coin_price_debounce = debounce(get_coin_price, input_wait);

  function get_coin_price_for_buy() {
    $.ajax({
      url: '/coinbox/coin-price',
      dataType: 'json',
      method: 'post',
      data: { coin_amount: parseFloat($(".buy-tokens-form .coin-amount").val()), use_promocode: 1 },
      success: function(response) {
        var active_currency = $('.buy-tokens-form .list-currency a.current-currency').data('code');
        coin_prices_for_buy = response.currencies;
        $('.buy-tokens-form .coins-bonus').text(response.coin_amount_bonus);
        display_form_token_bonus();
        select_coin_price_for_buy(active_currency);
        if (response.promocode !== undefined) {
          display_form_token_actual_promo(response.promocode.name, response.promocode.is_promo_token);
        } else {
          display_form_token_actual_promo(null);
        }
      },
      complete: function(response) {
        calc_tokens_price_fl = false;
      }
    });
  }
  var get_coin_price_for_buy_debounce = debounce(get_coin_price_for_buy, input_wait)

  function get_coin_for_total() {
    $.ajax({
      url: '/coinbox/coin-for-total',
      dataType: 'json',
      method: 'post',
      data: { amount: $("#coin-price").val() },
      success: function(response) {
        var active_currency = $('.list-currency a.current-currency').data('code');
        coin_for_total = response;
        select_coin_price(active_currency)
      }
    });
  }
  var get_coin_for_total_debounce = debounce(get_coin_for_total, input_wait);

  function get_coin_for_total_balance() {
    $.ajax({
      url: '/coinbox/coins-for-total-balances',
      dataType: 'json',
      method: 'post',
      data: { use_promocode: 1 },
      success: function(response) {
        if (!response.one_currency) {
          $('#total-price-box p').addClass('coin-box-big');
          $('.price-box-separator').show();
        }
        one_currency_on_balance = response.one_currency === true
        $('.buy-form-user-deposits').empty();
        for(var key in response.balances){
          $('.buy-form-user-deposits').append('<div>' + key +': ' + response.balances[key] + '</div>');
        }

        $('.buy-tokens-form .coin-amount').val(response.coin_amount);
        $('.buy-tokens-form .coin-price').text(response.coin_price);
        $('#contract-modal .coins-bonus').text(response.coin_amount_bonus);
        $('.buy-tokens-form .coin-price-currency').text(response.currency);
        $('.buy-tokens-form .coins-bonus').text(response.coin_amount_bonus);
        display_form_token_actual_promo(response.promocode !== undefined ? response.promocode.name : null, response.promocode.is_promo_token);
      }
    });
  }
  var get_coin_for_total_balance_debounce = debounce(get_coin_for_total_balance, input_wait);

  function currency_init() {
    if ($('.nav li.active').length == 0) {
      $('.nav li').first().addClass('active');
      $('.tab-content .tab-pane').first().addClass('active');
    }
  }

  function select_coin_price(active_currency) {
    if (calc_direction == 'right') {
      if (!coin_prices) return false;
      $("#coin-price").val(coin_prices[active_currency]);
    } else {
      if (!coin_for_total) return false;
      $("#coin-amount").val(coin_for_total[active_currency]['coin_amount']);
      $("#coin-total").text(coin_for_total[active_currency]['coin_total']);
      $("#coin-bonus").text(coin_for_total[active_currency]['coin_bonus']);
      $("#coin-bonus-percent").text(coin_for_total[active_currency]['bonus_percent'] + '%');
    }
  }

  function select_coin_price_for_buy(active_currency) {
    if (!coin_prices_for_buy) return false;
    $(".buy-tokens-form .coin-price").text(coin_prices_for_buy[active_currency]);
    $(".buy-tokens-form .coin-price-currency").text(active_currency);
  }

  $("#form-token-update").on("ajax:success", function(e, data, status, xhr) {
    toastr.success('Token receipt address has been saved');
    $('.get-address').attr('disabled', false);
  }).bind("ajax:error", function(e, xhr, status, error) {
    var notificationText = 'Can not save token receipt address';
    if (xhr.responseJSON['error'] ) {
        notificationText += ': ' + xhr.responseJSON['error'];
    }
    toastr.error(notificationText);
    $('.get-address').attr('disabled', true);
  });


  $("#promo-code-form").on("ajax:success", function(e, data, status, xhr) {
    toastr.success('Promo code has been saved');
    $('.not-promo-text').remove();
    if (calc_direction == 'right') {
      get_coin_price();
    } else {
      get_coin_for_total();
    }
  }).bind("ajax:error", function(e, xhr, status, error) {
    var notificationText = 'Can not save promo code';
    if (xhr.responseJSON['error'] ) {
        notificationText += ': ' + xhr.responseJSON['error'];
    }
    toastr.error(notificationText);
  });

  autosize( $('#user_promo_code'));

  function set_default_calculator_amount() {
    $('.buy-tokens-form .coin-amount').val(gon.min_coin_for_payment == 0 ? 1 : gon.min_coin_for_payment)
  }

  function update_coin_amount_buy_form(buy_from_all_balance) {
    if (buy_from_all_balance) {
      get_coin_for_total_balance_debounce();
    } else {
      var coin_amount = $(".buy-tokens-form .coin-amount");
      coin_amount.val(prepare_coin_number(coin_amount.val()));
      get_coin_price_for_buy_debounce();
    }
  }

  function display_form_token_bonus() {
    if (parseFloat($('.buy-tokens-form .coins-bonus').text()) > 0) {
      $('#form-token-label-bonus').show();
      $('.contract-modal-bonus-block').show();
      $('#bonus-amount-box').show();
    } else {
      $('#form-token-label-bonus').hide();
      $('.contract-modal-bonus-block').hide();
      $('#bonus-amount-box').hide();
    }
  }

  function display_form_token_actual_promo(promocode, is_promo_token) {
    if (promocode) {
      view_code = promocode
      if (is_promo_token) {
        view_code += ' (promotoken)';
      }
      $('.current-promocode').html(view_code);
      if (!$('#active-promotional-code-label').is(":visible")) {
        $('#active-promotional-code-label').show();
        $('#form-token-promocode-current-box').show();
        $('#add-promotional-code-label').toggleClass('col-md-12').toggleClass('col-md-5');
        $('#form-token-promocode-box').toggleClass('col-md-12').toggleClass('col-md-5');
      }
    } else if($('#active-promotional-code-label').is(":visible")) {
      $('#active-promotional-code-label').hide();
      $('#form-token-promocode-current-box').hide();
      $('#add-promotional-code-label').toggleClass('col-md-12').toggleClass('col-md-5');
      $('#form-token-promocode-box').toggleClass('col-md-12').toggleClass('col-md-5');
    }
  }

  function send_transaction_to_gtm(contract) {
    if (!gon || !gon.gtm_enabled) {
      return;
    }
    window.dataLayer = window.dataLayer || [];
    dataLayer.push({
     'ecommerce': {
       'currencyCode': contract.currency,
       'purchase': {
         'actionField': {
           'id': contract.contract.id,
           'affiliation': contract.coin_name,
           'revenue': contract.revenue,
           'tax': '0',
           'shipping': '0',
           'coupon': ''
         },
         'products': [{
           'name': contract.coin_name,
           'id': contract.contract.id,
           'price': contract.coin_price,
           'brand': contract.coin_name,
           'category': contract.coin_name,
           'variant': contract.coin_name,
           'quantity': contract.contract.info.coin_amount,
           'coupon': ''
          }]
       }
     },
     'event': 'gtm-ee-event',
     'gtm-ee-event-category': 'Enhanced Ecommerce',
     'gtm-ee-event-action': 'Purchase',
     'gtm-ee-event-non-interaction': 'False',
    });
  }

  function disable_buy_now_button() {
    button = $("#buy-coins-form .buy-now");
    check = check_purchase_agreement();
    if (check != null) {
      if (check) {
        button.prop('disabled', false);
      } else {
        button.prop('disabled', true);
      }
    }
  }

  function check_purchase_agreement() {
    checkboxes = $("#buy-coins-form .purchase-agreement .checkbox input");
    if (checkboxes.length == 0) return null;
    result = true;
    checkboxes.each(function (i, checkbox) {
      if (!$(this).prop('checked')) result = false;
    });
    return result;
  }

  function debounce(func, wait, immediate) {
    var timeout;
    return function() {
      var context = this, args = arguments;
      var later = function() {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  };

  function tab_content_qrcode() {
    $('#panel-make-deposit .quare-code').each(function() {
      if ($(this).attr('data-currency_code')) {
        create_qrcode($(this), $(this).attr('data-currency_code'));
      }
    });
  }

  function create_qrcode(container, text) {
    container.qrcode({text: text, size: 160, ecLevel: 'H'});
  }
});
