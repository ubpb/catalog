require "fileutils"
require "json"
require "openssl"
require "zip"

class Account::IdCardsController < Account::ApplicationController

  PKPASS_DRFAULT_CONTENT_DIR_PATH = Rails.root.join("app/assets/images/pkpass").to_s
  P12_CERT_PATH = Rails.root.join("config/cert/library-card-pass-o.p12").to_s
  WWDR_INTERMEDIATE_CERT_PATH = Rails.root.join("config/cert/AppleWWDRCAG4.cer").to_s

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

      format.pkpass do
        tmp_dir = create_tmp_pkpass_dir

        write_pass(tmp_dir)
        manifest_path = write_manifest(tmp_dir)
        write_signature(tmp_dir, manifest_path)

        tmp_file = zip_pkpass(tmp_dir)

        send_file(tmp_file.path, filename: "#{@ils_user.short_barcode}.pkpass",
                                 type: "application/vnd.apple.pkpass")
      ensure
        FileUtils.remove_entry(tmp_dir)
        tmp_file&.close
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

  def create_tmp_pkpass_dir
    tmp_dir = Dir.mktmpdir("pkpass_dir")

    # Copy default PkPass files into directory
    FileUtils.cp_r(PKPASS_DRFAULT_CONTENT_DIR_PATH + "/.", tmp_dir)

    tmp_dir
  end

  def write_pass(tmp_dir)
    team_id = Rails.application.credentials.dig(:pkpass, :team_id)
    pass_type_id = Rails.application.credentials.dig(:pkpass, :pass_type_id)

    pass =
      {
        "formatVersion": 1,
        "teamIdentifier": "#{team_id}",
        "passTypeIdentifier": "#{pass_type_id}",
        "serialNumber": "#{@ils_user.barcode}",
        "organizationName": "Universitätsbibliothek Paderborn",
        "description": "Bibliotheksausweis",
        "foregroundColor": "rgb(0,0,0)",
        "backgroundColor": "rgb(255,255,255)",
        "storeCard": {
          "secondaryFields": [
            {
              "key": "user_name",
              "value": "#{@ils_user.short_name_reversed}",
              "label": "Name"
            },
            {
              "key": "id_number",
              "value": "#{@ils_user.short_barcode}",
              "label": "Ausweisnummer"
            }
          ],
          "backFields": [
            {
              "key": "website_catalog",
              "label": "Katalog",
              "value": "https://katalog.ub.uni-paderborn.de/"
            },
            {
              "key": "website_ub",
              "label": "Webseite",
              "value": "https://ub.ub.uni-paderborn.de/"
            },
            {
              "key": "address",
              "label": "Adresse",
              "value": "Universitätsbibliothek Paderborn, Warburger Str. 100, 33098 Paderborn"
            },
            {
              "key": "email_address",
              "label": "Email",
              "value": "bibliothek@ub.uni-paderborn.de"
            }
          ]
        },
        "barcodes": [
          {
            "message": "#{@ils_user.barcode}",
            "format": "PKBarcodeFormatCode128",
            "messageEncoding": "iso-8859-1"
          },
          {
            "message": "#{@ils_user.barcode}",
            "format": "PKBarcodeFormatQR",
            "messageEncoding": "iso-8859-1"
          }
        ]
      }

    pass_path = tmp_dir + "/pass.json"
    File.open(pass_path, "w") do |f|
      f.write(pass.to_json)
    end

    pass_path
  end

  def write_manifest(tmp_dir)
    manifest = {}

    Dir.glob(tmp_dir + "/**").each do |file|
      manifest[File.basename(file)] = Digest::SHA1.hexdigest(File.read(file))
    end

    manifest_path = tmp_dir + "/manifest.json"
    File.open(manifest_path, "w") do |f|
      f.write(manifest.to_json)
    end

    manifest_path
  end

  def write_signature(tmp_dir, manifest_path)
    cert_pw = Rails.application.credentials.dig(:pkpass, :cert_pw)

    p12_certificate = OpenSSL::PKCS12.new(File.read(P12_CERT_PATH), cert_pw)
    wwdr_certificate = OpenSSL::X509::Certificate.new(File.read(WWDR_INTERMEDIATE_CERT_PATH))

    flag = OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
    signature = OpenSSL::PKCS7.sign(p12_certificate.certificate, p12_certificate.key, File.read(manifest_path),
                                    [wwdr_certificate], flag)

    signature_path = tmp_dir + "/signature"

    File.open(signature_path, "w") do |f|
      f.syswrite signature.to_der
    end
  end

  def zip_pkpass(tmp_dir)
    tmp_file = Tempfile.new("pkpass")

    Zip::OutputStream.open(tmp_file.path) do |z|
      Dir.glob(tmp_dir + "/**").each do |file|
        z.put_next_entry(File.basename(file))
        z.print IO.read(file)
      end
    end

    tmp_file
  end

  def remove_tmp_pkpass_dir(tmp_dir)
    FileUtils.rm_rf(tmp_dir)
  end

end
