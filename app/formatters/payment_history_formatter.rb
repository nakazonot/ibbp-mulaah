class PaymentHistoryFormatter
  include Concerns::Currency
  include ApplicationHelper

  def initialize(payment)
    @payment = payment
  end

  def view_data
      row = {
        date:                date_payment_history(@payment.created_at.in_time_zone),
        payment_type:        payment_types[@payment.payment_type],
        amount:              @payment.amount_buyer.to_f > 0 ? original_number_format(@payment.amount_buyer) : "—",
        currency:            @payment.currency_buyer.present? ? @payment.currency_buyer : "—",
        ico_currency_amount: @payment.ico_currency_amount.to_f > 0 ? ico_currency_number_format(@payment.ico_currency_amount) : "—",
        tokens:              @payment.iso_coin_amount.present? ? original_number_format(@payment.iso_coin_amount) : "—",
        description:         @payment.description.present? ? @payment.description : PaymentHistoryFormatter.descriptions[@payment.payment_type]
      }
      if @payment.buy_tokens_contract&.uuid.present? && Parameter.buy_tokens_agreement_enabled?
        row[:contract_path] = Rails.application.routes.url_helpers.contract_agreement_path(@payment.buy_tokens_contract.uuid, format: :pdf, download_url: true)
      end
      row[:invoice_url] = @payment.invoice.pdf_url if @payment.invoice.present? && @payment.invoice.pdf_url.present?
      row[:balance_pending] = @payment.payment_type == Payment::PAYMENT_TYPE_BALANCE && @payment.status == Payment::PAYMENT_STATUS_PENDING
      row
  end

  def self.descriptions
    {
      Payment::PAYMENT_TYPE_BALANCE                 => 'Deposit to your Balance.',
      Payment::PAYMENT_TYPE_PURCHASE                => 'Tokens Purchase.',
      Payment::PAYMENT_TYPE_BUY_TOKEN_BONUS         => 'ICO Stage Bonus.',
      Payment::PAYMENT_TYPE_REFERRAL_BOUNTY         => 'Referral Bounty.',
      Payment::PAYMENT_TYPE_REFERRAL_USER           => 'Referral Promo Bonus.',
      Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE => 'Referral Bounty.',
      Payment::PAYMENT_TYPE_REFERRAL_BONUS_BALANCE  => 'Referral Promo Bonus.',
      Payment::PAYMENT_TYPE_PROMOCODE_BONUS         => 'Promo code Bonus.',
      Payment::PAYMENT_TYPE_PROMOCODE_BOUNTY        => 'Promo code owner bonus.',
      Payment::PAYMENT_TYPE_REFUND                  => 'Refund',
      Payment::PAYMENT_TYPE_REFUND_TOKENS           => 'Refund tokens',
      Payment::PAYMENT_TYPE_TRANSFER_TOKENS         => 'Tokens transfer'
    }
  end

  private

  def payment_types
    {
      Payment::PAYMENT_TYPE_BALANCE                 => 'Deposit',
      Payment::PAYMENT_TYPE_PURCHASE                => 'Purchase',
      Payment::PAYMENT_TYPE_BUY_TOKEN_BONUS         => 'Bonus',
      Payment::PAYMENT_TYPE_REFERRAL_BOUNTY         => 'Referral',
      Payment::PAYMENT_TYPE_REFERRAL_USER           => 'Referral',
      Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE => 'Referral',
      Payment::PAYMENT_TYPE_REFERRAL_BONUS_BALANCE  => 'Referral',
      Payment::PAYMENT_TYPE_PROMOCODE_BONUS         => 'Promo code bonus',
      Payment::PAYMENT_TYPE_PROMOCODE_BOUNTY        => 'Promo code bonus',
      Payment::PAYMENT_TYPE_REFUND                  => 'Refund',
      Payment::PAYMENT_TYPE_REFUND_TOKENS           => 'Refund tokens',
      Payment::PAYMENT_TYPE_LOYALTY_BONUS           => 'Loyalty Bonus',
      Payment::PAYMENT_TYPE_TRANSFER_TOKENS         => 'Tokens transfer'
    }
  end
end
