require "barby/barcode/code_128"
require "barby/outputter/png_outputter"

class IdCardPdfGeneratorService < ApplicationService

  class << self

    delegate :generate, to: :new

  end

  def generate(ils_user)
    generate_pdf(ils_user)
  end

  private

  def generate_pdf(ils_user)
    upb_logo = Rails.root.join("etc/id-card-upb-logo.png").to_s
    ub_logo = Rails.root.join("etc/id-card-ub-logo.png").to_s
    barcode = Barby::Code128B.new(ils_user.barcode)

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
      pdf.text(ils_user.short_barcode, margin: [mm_to_pt(0.7), 0, 0, 0], font: ["Helvetica", {variant: :bold}])

      pdf.text("Name", margin: [mm_to_pt(2), 0, 0, 0])
      pdf.text(ils_user.full_name_reversed, margin: [mm_to_pt(0.7), 0, 0, 0], font: ["Helvetica", {variant: :bold}])

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

end
