class Admin::IdCardPrintoutsController < Admin::ApplicationController

  def index
    redirect_to new_admin_id_card_printout_path
  end

  def new
    @form = IdCardPrintoutForm.new
  end

  def create
    @form = IdCardPrintoutForm.new(
      params.require(:form).permit(:ils_id)
    )

    if @form.valid? && (ils_user = @form.ils_user).present?
      send_data(
        IdCardPdfGeneratorService.generate(ils_user),
        filename: "#{ils_user.short_barcode}.pdf",
        type: "application/pdf",
        disposition: "attachment"
      )
    else
      render :new, status: :unprocessable_entity
    end
  end

end
