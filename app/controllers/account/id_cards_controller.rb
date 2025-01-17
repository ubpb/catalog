class Account::IdCardsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.id_cards.breadcrumb"), account_id_card_path }
  before_action :load_ils_user

  def show
    respond_to do |format|
      format.html do
        ensure_turbo_frame_request
      end

      format.pdf do
        pdf = IdCardPdfGeneratorService.generate(@ils_user)

        send_data(
          pdf,
          filename: "#{@ils_user.short_barcode}.pdf",
          type: "application/pdf",
          disposition: "attachment"
        )
      end

      if helpers.pkpass_enabled?
        format.pkpass do
          pkpass = IdCardPkpassGeneratorService.generate(@ils_user)

          send_data(
            pkpass,
            filename: "#{@ils_user.short_barcode}.pkpass",
            type: "application/vnd.apple.pkpass",
            disposition: "attachment"
          )
        end
      end
    end
  end

  private

  def ensure_turbo_frame_request
    redirect_to account_root_path unless turbo_frame_request?
  end

  def load_ils_user
    @ils_user = current_user.ils_user(force_reload: true)
  end

end
