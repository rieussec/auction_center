module PaymentOrders
  class Paypal < PaymentOrder
    CONFIG_NAMESPACE = 'paypal'.freeze

    # Base interface for creating payments.
    def form_fields
        []
    end

    def self.config_namespace_name
      CONFIG_NAMESPACE
    end

    def self.icon
      AuctionCenter::Application.config
                                .customization
                                .dig('payment_methods', config_namespace_name, 'icon')
    end

    # Where to send the POST request with payment creation.
    def form_url
        items = Array.new
        item = {}
        item[:name] = invoice.items.first.name
        item[:price] = invoice.total.to_s
        item[:currency] = 'EUR'
        item[:quantity] = 1
        items << item

        payment = PayPal::SDK::REST::Payment.new({
          intent: "sale",
          payer: {
            payment_method: "paypal"
          },
          redirect_urls: {
            return_url: return_url,
            cancel_url: return_url,
          },
          transactions: [{
            item_list: {
              items: items
            },
            amount: {
              total: invoice.total.to_s,
              currency: "EUR"
            },
            description: invoice.items.first.name
          }]
        })
        if payment.create
            return payment.links.find { |v| v.method == "REDIRECT"}.href
        end
        return_url
    end

    # Perform necessary checks and mark the invoice as paid
    def mark_invoice_as_paid
      return unless valid_response?
      paypal_payment = PayPal::SDK::REST::Payment.find(response['paymentId'])
      return unless paypal_payment.execute(payer_id: response['PayerID'])

      paid!
      invoice.mark_as_paid_at(Time.now.getutc)
    end

    # Check if response is there and if basic security methods are fullfilled.
    def valid_response?
      response['paymentId'] && response['PayerID']
    end
  end
end
