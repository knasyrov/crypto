import { Application } from "@hotwired/stimulus"
import jquery from "jquery"
window.jQuery = jquery
window.$ = jquery

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

console.log("ASASAS2");

$(document).on('turbo:load', function() {
    console.log('!!!!!!!!!!!!!load');

    $('select#transaction_in_addr').on('change', function() {
        var option = $(this).find('option:selected');
        if (option) {
            var balance = option.val().split('|');
            console.log('eee = ', balance[1]);
            $('input#balance').val(balance[1]);
        }
    });

    $('#transaction_in_value').on('change', function() {
        var balance = $('select#transaction_in_addr').find('option:selected').val().split('|');

        var in_value = Math.round($('#transaction_in_value').val() || 0)
        var fee = Math.round(in_value * 0.03) // 3 %
        var out = in_value + fee
        var change = balance[1] - out
        // комиссия
        // fee = 

        // сдача
        //$('input#in_value').val(in_value);
        $('input#fee_value').val(fee);
        $('input#out_value').val(out);
        $('input#change_value').val(change);
        console.log("in_value = ", in_value);
        console.log("fee = ", fee);
        console.log("будет списано = ", out);
        console.log("сдача = ", change)

    });

    $('select#transaction_in_addr').trigger('change');
  });

  $(document).on('turbo:ready', function() {
    console.log('!!!!!!!!!!!!!ready')
  });