//= require jquery
//= require jquery_ujs
//= require active_admin/base
//= require arctic_admin
//= require momentjs
//= require bootstrap
//= require bootstrap-datetimepicker-3
//= require active_admin/select2
//= require daterangepicker

$( document ).ready(function() {
  $('#ico_stage_date_start').datetimepicker({format: 'YYYY-MM-DD HH:mm'});
  $('#ico_stage_date_end').datetimepicker({format: 'YYYY-MM-DD HH:mm'});
  $('#promocode_expires_at').datetimepicker({format: 'YYYY-MM-DD HH:mm'});
  $('#user_kyc_date').datetimepicker({format: 'YYYY-MM-DD HH:mm'});

  $('#promocode_owner_id').select2({
    allowClear: true,
    placeholder: "Select a user"
  });

  $('#ico_stage_buy_token_promocode_id').select2({
    allowClear: true,
    placeholder: "Select a promocode"
  });

  get_date_ranges();

  $('#range-picker').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format('YYYY-MM-DD') + ' - ' + picker.endDate.format('YYYY-MM-DD'));
    $('#range-picker-form').submit();
  });

  $('#range-clear').on('click', function(event) {
    event.preventDefault();
    $('#range-picker').val('');
    $('#range-picker-form').submit();
  });

  $('.close').on('click', function(event) {
    $(this).closest('.bootstrap-modal').hide();
  });

  $('.btn-close-modal').on('click', function(event) {
    $(this).closest('.bootstrap-modal').hide();
  });

  $('.btn-delete-user').on('click', function() {
    hide_action_menu();

    var btn       = $(this);
    var email     = btn.attr('data-user-email');
    var id        = btn.attr('data-user-id');
    var confirmed = btn.attr('data-confirmed') === 'true';

    if (confirmed === false) {
      var modal       = $('#user-delete-modal');
      var input       = modal.find('#user-email');
      var btn_submit  = modal.find('#btn-user-delete');

      modal.find('#modal-user-delete-id').html(id);
      modal.find('#modal-user-delete-email').html(email);

      btn_submit.attr('disabled', true);
      btn_submit.on('click', function() {
        btn.attr('data-confirmed', true);
        $('.btn-delete-user[data-user-id="' + id + '"]')[0].click();
      });

      input.val('');
      input.on('input', function() {
        btn_submit.attr('disabled', this.value !== email);
      });

      modal.show();
    }

    return confirmed;
  });

  $('.btn-activate-user').on('click', function() {
    hide_action_menu();

    var btn       = $(this);
    var email     = btn.attr('data-user-email');
    var id        = btn.attr('data-user-id');
    var confirmed = btn.attr('data-confirmed') === 'true';

    if (confirmed === false) {
      var modal   = $('#user-activate-modal');

      modal.find('#modal-user-activate-email').html(email);
      modal.find('#btn-activate-modal').on('click', function() {
        btn.attr('data-confirmed', true);
        $('.btn-activate-user[data-user-id="' + id + '"]')[0].click();
      });

      modal.show();
    }

    return confirmed;
  });

  $("#kyc_permission_country_list").select2();
});

function hide_action_menu() {
  $('.dropdown_menu_list_wrapper').hide();
}

function get_date_ranges() {
  $.get({
    url: '/admin/dashboard/generate_date_ranges',
    dataType: 'json',
    success: function(response) {
      enable_range_picker(response);
    },
    error: function (xhr) {
    }
  });
}


function enable_range_picker(ranges) {
  var range_picker = $('#range-picker');
  var starting_at  = range_picker.data('starting-at');
  var ending_at    = range_picker.data('ending-at');

  range_picker.daterangepicker({
    autoApply: false,
    autoUpdateInput: false,
    startDate: starting_at,
    endDate: ending_at,
    locale: {
      format: 'YYYY-MM-DD'
    },
    ranges: ranges
  });

  if (starting_at !== undefined && ending_at !== undefined) {
    range_picker.val(starting_at + ' - ' + ending_at);
  }
}