require "barby/barcode/code_128"
require "barby/outputter/png_outputter"

class Account::IdCardsController < Account::ApplicationController

  before_action { add_breadcrumb t("account.id_cards.breadcrumb"), account_id_card_path }
  before_action :ensure_turbo_frame_request, except: [:download_printout]
  before_action :load_ils_user

  def show
    authorize!
  end

  def authorize
    @set_pin_form = PinForm.new

    if request.post?
      pin = params[:pin]&.to_s&.strip.presence

      if pin && @ils_user.has_pin_set? && (pin == @ils_user.pin)
        session[:id_card_authorized] = true
        session[:id_card_authorized_at] = Time.zone.now
        redirect_to account_id_card_path
      else
        reset_authorization!
        flash[:error] = t(".error_notice")
        redirect_to authorize_account_id_card_path
      end
    end
  end

  def set_pin
    @set_pin_form = PinForm.new(
      params.require(:pin_form).permit(:pin, :pin_confirmation)
    )

    if @set_pin_form.valid? && Ils.set_user_pin(current_user.ils_primary_id, @set_pin_form.pin)
      session[:id_card_authorized] = true
      session[:id_card_authorized_at] = Time.zone.now
      redirect_to account_id_card_path
    else
      render "authorize", status: :unprocessable_entity
    end
  end

  def download_printout
    pdf = generate_pdf_printout

    send_data(
      pdf,
      filename: "#{@ils_user.short_barcode}.pdf",
      type: "application/pdf",
      disposition: "attachment"
    )

    true
  end

  private

  def generate_pdf_printout
    upb_logo = Rails.root.join("etc/id-card-upb-logo.png").to_s
    ub_logo = Rails.root.join("etc/id-card-ub-logo.png").to_s
    barcode = Barby::Code128B.new(@ils_user.barcode)

    # Sizes
    box_height = mm_to_pt(54)
    box_width = mm_to_pt(86)
    box_left_margin = mm_to_pt(20)
    box_top_margin = mm_to_pt(20)
    box_padding = mm_to_pt(2)

    card_left_margin = box_left_margin + box_padding
    card_top_margin = box_top_margin + box_padding
    card_right_margin = box_width + box_left_margin

    # Compose the PDF
    composer_io = StringIO.new("".b)
    HexaPDF::Composer.create(composer_io, page_size: :A4, margin: [card_top_margin, card_right_margin, 0, card_left_margin]) do |pdf|
      pdf.style(:base, font: "Helvetica", font_size: 10, line_spacing: 1)
      # pdf.document.config["debug"] = true

      pdf.image(upb_logo, height: mm_to_pt(8), position: :float, margin: [0, 0], style: {align: :left})
      pdf.image(ub_logo, height: mm_to_pt(8), position: :default, margin: [0, 0], style: {align: :right})

      pdf.text("Bibliotheksausweis", margin: [mm_to_pt(9), 0, 0, 0], font: ["Helvetica", {variant: :bold}])

      pdf.image(StringIO.new(barcode.to_png(height: 25, xdim: 1, margin: 0).b), width: mm_to_pt(50), margin: [mm_to_pt(0.7), 0, 0, 0 ])

      pdf.text("Bibliotheksausweisnummer", margin: [mm_to_pt(5), 0, 0, 0])
      pdf.text(@ils_user.short_barcode, margin: [mm_to_pt(0.7), 0, 0, 0], font: ["Helvetica", {variant: :bold}])

      pdf.text("Name", margin: [mm_to_pt(2), 0, 0, 0])
      pdf.text(@ils_user.full_name_reversed, margin: [mm_to_pt(0.7), 0, 0, 0], font: ["Helvetica", {variant: :bold}])

      page_box = pdf.canvas.context.box
      pdf.canvas.line_width(0.2)
      pdf.canvas.rectangle(
        box_left_margin,
        page_box.height - box_height - box_top_margin,
        box_width,
        box_height,
        radius: 0
      ).stroke
    end

    # Create the PDF doc
    doc = HexaPDF::Document.new(io: composer_io)

    # Secure the PDF, allowing only printing
    doc.encrypt(
      owner_password: SecureRandom.hex(10),
      permissions: HexaPDF::Encryption::StandardSecurityHandler::Permissions::PRINT
    )

    # Write the PDF to an IO
    out_io = StringIO.new("".b)
    doc.write(out_io)

    # Return the PDF content
    out_io.string
  end

  def mm_to_pt(millimeter)
    millimeter.fdiv(25.4) * 72
  end

  def ensure_turbo_frame_request
    redirect_to account_root_path unless turbo_frame_request?
  end

  def load_ils_user
    @ils_user = current_user.ils_user(force_reload: true)
  end

  def reset_authorization!
    session[:id_card_authorized] = nil
    session[:id_card_authorized_at] = nil
  end

  def authorized?
    session[:id_card_authorized] == true && session[:id_card_authorized_at] >= 5.minutes.ago
  end

  def authorize!
    unless @ils_user.has_pin_set?
      reset_authorization!
      redirect_to authorize_account_id_card_path
      return false
    end

    unless authorized?
      reset_authorization!
      redirect_to authorize_account_id_card_path
      return false
    end

    true
  end

end
