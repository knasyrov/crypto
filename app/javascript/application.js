// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"


/*
$(document).on('ready', function() {
    console.log('!!!!!!!!!!!!!readdfdsafdfdy')
    console.log('readu!!!!!!!!!!!!!!');

    $('select#transaction_in_addr').on('change', function() {
        option = $(this).find('option:selected');
        if (option) {
            balance = option.val();
            console.log('eee = ', balance);
            $('input#balance').val(balance);
        }
    });

    $('#transaction_in_value').on('change', function() {
        balance = $('select#address').find('option:selected').val();

        in_value = Math.round($('#transaction_in_value').val() || 0)
        fee = Math.round(in_value * 0.03) // 3 %
        out = in_value + fee
        change = balance - out
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

    $('select#address').trigger('change');
});

$(document).on('turbo:load', function() {
    console.log('!!!!!!!!!!!!!load');

    $('select#transaction_in_addr').on('change', function() {
        var option = $(this).find('option:selected');
        if (option) {
            var balance = option.val();
            console.log('eee = ', balance);
            $('input#balance').val(balance);
        }
    });

    $('#transaction_in_value').on('change', function() {
        var balance = $('select#address').find('option:selected').val();

        in_value = Math.round($('#transaction_in_value').val() || 0)
        fee = Math.round(in_value * 0.03) // 3 %
        out = in_value + fee
        change = balance - out
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

    $('select#address').trigger('change');
  });

  $(document).on('turbo:ready', function() {
    console.log('!!!!!!!!!!!!!ready')
  });
  */