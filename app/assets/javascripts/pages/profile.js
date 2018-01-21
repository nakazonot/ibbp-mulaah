$( document ).on('turbolinks:load', function() {
  var clipboard_promo_token = new Clipboard('#promo-token-address-copy-link');
  var clipboard_refer = new Clipboard('#refer-copy-link');

  $('#button-for-change-pasword').on('click', function(event) {
    event.preventDefault();
    $('#modal-change-password').modal('show');
    $('#modal-change-password input[type=password]').val('');
  });

  $("#change-password-form").on("ajax:success", function(e, data, status, xhr) {
    $('#modal-change-password .validate-error').addClass('hide');
    $('#modal-change-password').modal('hide');
    $('#modal-change-password input[type=password]').val('');
    toastr.success('Password changed successfully');
  }).bind("ajax:error", function(e, xhr, status, error) {
    if (xhr.responseJSON['error'] == 'valid_error') {
      $('#modal-change-password .validate-error').removeClass('hide');
      var notificationText = '';
      $.each(xhr.responseJSON['messages'], function (i, val) {
        notificationText += '<li>' + val + '</li>';
      });
      $('#modal-change-password .validate-error div').html(notificationText);
      toastr.error('Validation error');
    } else if (xhr.responseJSON['error']) {
      $('#modal-change-password .validate-error div').html('');
      toastr.error(xhr.responseJSON['error']);
    }
  }).bind("ajax:beforeSend", function(e, data, status, xhr) {
    $.LoadingOverlay('show');
  }).bind("ajax:complete", function(e, data, status, xhr) {
    $.LoadingOverlay('hide');
  });

  $('#btn-switch-2fa').on('click', function(event) {
    event.preventDefault();

    if ($(this).attr('data-2fa-status') === 'disabled') {
      if ($(this).attr('data-password-default') === 'false') {
        load_otp_secret();
        $('#modal-enable2fa-stage1').modal('show');
      } else {
        $('#modal-enable2fa-stage0-errors').html('');
        $('#modal-enable2fa-stage0').modal('show');
      }
    } else {
      $('#modal-disable2fa').modal('show');
    }
  });

  $('#btn-enable2fa-stage0-confirm').on('click', function(event) {
    event.preventDefault();
    create_password();
  });

  $('#btn-enable2fa-stage1-next').on('click', function(event) {
    event.preventDefault();
    $('#modal-enable2fa-stage1').modal('hide');
    $('#modal-enable2fa-stage2').modal('show');
  });

  $('#btn-enable2fa-stage2-back').on('click', function(event) {
    event.preventDefault();
    $('#modal-enable2fa-stage2').modal('hide');
    $('#modal-enable2fa-stage1').modal('show');
  });

  $('#btn-enable2fa-stage2-confirm').on('click', function(event) {
    event.preventDefault();
    enable_otp();
  });

  $('#btn-disable2fa-confirm').on('click', function(event) {
    event.preventDefault();
    disable_otp()
  });

  $('#btn-regenerate-backup-codes-next').on('click', function(event) {
    event.preventDefault();
    regenerate_backup_codes();
  });

  $('#btn-regenerate-backup-codes').on('click', function(event) {
    event.preventDefault();
    $('#modal-regenerate-backup-codes').modal('show');
  });

  $('.disable-submit-event').on('submit', function(event) {
    event.preventDefault();
  });

  $('#modal-regenerate-backup-codes').on('keypress', function(event) {
    if (event.which === 13) {
      $('#btn-regenerate-backup-codes-next').click()
    }
  });

  $('#modal-disable2fa').on('keypress', function(event) {
    if (event.which === 13) {
      $('#btn-disable2fa-confirm').click()
    }
  });

  $('#modal-enable2fa-stage1').on('keypress', function(event) {
    if (event.which === 13) {
      $('#btn-enable2fa-stage1-next').click();
    }
  });

  $('#modal-enable2fa-stage2').on('keypress', function(event) {
    if (event.which === 13) {
      $('#btn-enable2fa-stage2-confirm').click();
    }
  });

  $("#get-promo-token-address").off('click').on("click", function(e) {
    get_address();
  });

});

function enable_otp() {
  $.ajax({
    url: '/one-time-password/enable',
    dataType: 'json',
    method: 'post',
    data: { code: $('#input-enable2fa-stage2-code').val() },
    success: function(response) {
      $('#btn-switch-2fa').val('Disable 2FA').attr('data-2fa-status', 'enabled');
      $('#btn-regenerate-backup-codes').prop('disabled', false);
      $('#modal-enable2fa-stage2').modal('hide');

      response['codes'].forEach(function(item, i, arr) {
        $('#step3-backup-codes').append('<li>' + item + '</li>')
      });
      $('#modal-backup-codes').modal('show');

      toastr.success(response['msg']);
    },
    error: function (xhr) {
      toastr.error(xhr.responseJSON['msg']);
    }
  });
}

function regenerate_backup_codes() {
  $.ajax({
    url: '/one-time-password/regenerate-backup-codes',
    dataType: 'json',
    method: 'post',
    data: { password: $('#input-regenerate-backup-codes-password').val() },
    success: function(response) {
      $('#step3-backup-codes').empty();
      response['codes'].forEach(function(item, i, arr) {
        $('#step3-backup-codes').append('<li>' + item + '</li>')
      });

      $('#modal-regenerate-backup-codes').modal('hide');
      $('#modal-backup-codes').modal('show');

      toastr.success(response['msg']);
    },
    error: function (xhr) {
      toastr.error(xhr.responseJSON['msg']);
    }
  });
}

function disable_otp() {
  $.ajax({
    url: '/one-time-password/disable',
    dataType: 'json',
    method: 'post',
    data: { password: $('#input-disable2fa-password').val() },
    success: function(xhr) {
      $('#btn-switch-2fa').val('Enable 2FA').attr('data-2fa-status', 'disabled');
      $('#btn-regenerate-backup-codes').prop('disabled', true);
      $('#modal-disable2fa').modal('hide');
      toastr.success(xhr['msg']);
    },
    error: function (xhr) {
      toastr.error(xhr.responseJSON['msg']);
    }
  });
}

function create_password() {
  $.ajax({
    url: '/one-time-password/create-password',
    dataType: 'json',
    method: 'post',
    data: {
      password:              $('#input-enable2fa-0-password').val(),
      password_confirmation: $('#input-enable2fa-0-password-confirmation').val()
    },
    success: function(xhr) {
      load_otp_secret();

      $('#btn-switch-2fa').attr('data-password-default', 'false');
      $('#modal-enable2fa-stage0').modal('hide');
      $('#modal-enable2fa-stage1').modal('show');

      toastr.success(xhr['msg']);
    },
    error: function (xhr) {
      var errorsHTML = '';
      $.each(xhr.responseJSON['msg'], function (i, val) {
        errorsHTML += '<li>' + val + '</li>';
      });

      $('#modal-enable2fa-stage0-errors').html(errorsHTML);
    }
  });
}

function load_otp_secret() {
  $.ajax({
    url: '/one-time-password/generate-secret',
    dataType: 'json',
    method: 'get',
    success: function(xhr) {
      $('#enable2fa-stage1-qr-code').html(xhr['qr_code']);
      $('#enable2fa-stage1-account-name').html(xhr['label']);
      $('#enable2fa-stage1-key').html(xhr['secret']);
    },
    error: function (xhr) {
    }
  });
}

function get_address() {
  $.LoadingOverlay('show');
  $.ajax({
    url: '/profile/get-promo-token-address',
    dataType: 'json',
    method: 'post',
    data: {},
    success: function(response) {
      $('#promo-token-address-box').text(response.address);
      $('#get-promo-token-address').addClass('hide');
      $('#promo-token-address-copy-link').removeClass('hide');
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
