class Account::IdCardsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.id_cards.breadcrumb"), account_id_card_path }
  before_action :load_ils_user

  def show
    respond_to do |format|
      format.html do
        ensure_turbo_frame_request
      end

      format.pkpass do
        temp_file = Tempfile.new()
        temp_file.write("FOO")
        temp_file.close

        send_file(temp_file.path, filename: "id_card.pkpass", type: "application/vnd.apple.pkpass")
      end
    end
  end

  def download_printout
    pdf = IdCardPdfGeneratorService.generate(@ils_user)

    send_data(
      pdf,
      filename: "#{@ils_user.short_barcode}.pdf",
      type: "application/pdf",
      disposition: "attachment"
    )

    true
  end

  private

  def ensure_turbo_frame_request
    redirect_to account_root_path unless turbo_frame_request?
  end

  def load_ils_user
    @ils_user = current_user.ils_user(force_reload: true)
  end

end
