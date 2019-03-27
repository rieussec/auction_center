# encoding: UTF-8
require 'test_helper'

class PaymentOrderEveryPayTest < ActiveSupport::TestCase
  def setup
    super

    travel_to Time.zone.parse('2018-04-01 00:30:00 +0000')
    @payable_invoice = invoices(:payable)
    @orphaned_invoice = invoices(:orphaned)
    @user = users(:participant)

    response = {
          utf8:                '✓',
          _method:             'put',
          authenticity_token:  'OnA69vbccQtMt3C9wxEWigs5Gpf/7z+NoxRCMkFPlTvaATs8+OgMKF1I4B2f+vuK37zCgpWZaWWtyuslRRSwkw==',
          nonce:               '392f2d7748bc8cb0d14f263ebb7b8932',
          timestamp:           '1524136727',
          api_username:        'ca8d6336dd750ddb',
          transaction_result:  'completed',
          payment_reference:   'fd5d27b59a1eb597393cd5ff77386d6cab81ae05067e18d530b10f3802e30b56',
          payment_state:       'settled',
          amount:              '12.00',
          order_reference:     'e468a2d59a731ccc546f2165c3b1a6',
          account_id:          'EUR3D1',
          cc_type:             'master_card',
          cc_last_four_digits: '0487',
          cc_month:            '10',
          cc_year:             '2018',
          cc_holder_name:      'John Doe',
          hmac_fields:         'account_id,amount,api_username,cc_holder_name,cc_last_four_digits,cc_month,cc_type,cc_year,hmac_fields,nonce,order_reference,payment_reference,payment_state,timestamp,transaction_result',
          hmac: 'efac1c732835668cd86023a7abc140506c692f0d',
          invoice_id:          '1',
        }

    @every_pay = PaymentOrders::EveryPay.new(status: :issued, invoice: @orphaned_invoice,
                                             user: @user, response: response)

    @fake_every_pay = PaymentOrders::EveryPay.new(status: :issued, invoice: @payable_invoice,
                                                  user: @user)
  end

  def teardown
    super

    travel_back
  end

  def test_form_fields_are_filled_according_to_schema
    expected_fields = {
      api_username: 'api_user',
      account_id: 'EUR3D1',
      timestamp: '1522542600',
      amount: '12.00',
      transaction_type: 'charge',
      hmac_fields: 'account_id,amount,api_username,callback_url,customer_url,hmac_fields,nonce,order_reference,timestamp,transaction_type'
    }
    form_fields = @every_pay.form_fields
    expected_fields.each do |k, v|
      assert_equal(v, form_fields[k])
    end
  end

  def test_form_url_returns_the_constant
    assert_equal(PaymentOrders::EveryPay::URL, @every_pay.form_url)
  end

  def test_mark_invoice_as_paid_works_when_response_is_valid
    @every_pay.mark_invoice_as_paid

    assert(@every_pay.invoice.paid?)
    assert(@every_pay.valid_response?)
  end

  def test_mark_invoice_as_paid_does_not_work_when_response_is_invalid
    @fake_every_pay.mark_invoice_as_paid

    refute(@fake_every_pay.invoice.paid?)
    refute(@fake_every_pay.valid_response?)
  end
end
