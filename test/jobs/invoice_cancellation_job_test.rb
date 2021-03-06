require 'test_helper'

class InvoiceCancellationJobTest < ActiveJob::TestCase
  def setup
    super

    @invoice = invoices(:orphaned)
  end

  def test_overdue_invoices_are_cancelled_automatically
    InvoiceCancellationJob.perform_now

    @invoice.reload
    assert_equal('cancelled', @invoice.status)
    assert_equal('payment_not_received', @invoice.result.status)
  end

  def test_user_is_banned_if_exists
    payable = invoices(:payable)
    InvoiceCancellationJob.perform_now

    payable.reload
    assert_equal('cancelled', payable.status)
    assert_equal('payment_not_received', payable.result.status)

    assert(payable.user.banned?)
  end

  def test_paid_invoices_are_not_cancelled_automatically
    @invoice.mark_as_paid_at(Time.zone.now)
    InvoiceCancellationJob.perform_now

    @invoice.reload
    assert_equal('paid', @invoice.status)
  end
end
