require "fileutils"
require "json"
require "openssl"
require "zip"

class IdCardPkpassGeneratorService

  PKPASS_CONFIG_DIR = Rails.root.join("config", "pkpass").freeze
  PKPASS_ASSETS_DIR = PKPASS_CONFIG_DIR.join("assets").freeze
  PKPASS_CERTS_DIR = PKPASS_CONFIG_DIR.join("certs").freeze
  P12_CERT_PATH = PKPASS_CERTS_DIR.join("library-card-pass.p12").freeze
  WWDR_INTERMEDIATE_CERT_PATH = PKPASS_CERTS_DIR.join("AppleWWDRCAG4.cer").freeze
  PKPASS_TMP_DIR = Rails.root.join("tmp", "pkpass").freeze

  class << self

    delegate :generate, to: :new

  end

  def generate(ils_user)
    tmp_dir = prepare_tmp_dir
    copy_assets(tmp_dir)
    create_pass_content(tmp_dir, ils_user)
    create_manifest(tmp_dir)
    create_signature(tmp_dir)
    create_pkpass(tmp_dir)
  ensure
    remove_tmp_dir(tmp_dir)
  end

  private

  def prepare_tmp_dir
    # Make sure the base temporary directory exists where we will store the generated pkpass files
    FileUtils.mkdir_p(PKPASS_TMP_DIR)
    # Create a temporary directory for the pkpass file
    tmp_dir = Dir.mktmpdir("", PKPASS_TMP_DIR)
    # Return the temporary directory for the pkpass file
    tmp_dir
  end

  def copy_assets(tmp_dir)
    Dir.each_child(PKPASS_ASSETS_DIR) do |asset|
      FileUtils.copy_file(File.join(PKPASS_ASSETS_DIR, asset), File.join(tmp_dir, asset))
    end
  end

  def remove_tmp_dir(tmp_dir)
    FileUtils.remove_entry(tmp_dir, true)
  end

  def create_pass_content(tmp_dir, ils_user)
    team_id = Rails.application.credentials.dig(:pkpass, :team_id)
    pass_type_id = Rails.application.credentials.dig(:pkpass, :pass_type_id)

    pass =
      {
        "formatVersion": 1,
        "teamIdentifier": "#{team_id}",
        "passTypeIdentifier": "#{pass_type_id}",
        "serialNumber": "#{ils_user.barcode}",
        "organizationName": "Universitätsbibliothek Paderborn",
        "description": "Bibliotheksausweis",
        "foregroundColor": "rgb(0,0,0)",
        "backgroundColor": "rgb(255,255,255)",
        "storeCard": {
          "secondaryFields": [
            {
              "key": "user_name",
              "value": "#{ils_user.short_name_reversed}",
              "label": "Name"
            },
            {
              "key": "id_number",
              "value": "#{ils_user.short_barcode}",
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
            "message": "#{ils_user.barcode}",
            "format": "PKBarcodeFormatCode128",
            "messageEncoding": "iso-8859-1"
          },
          {
            "message": "#{ils_user.barcode}",
            "format": "PKBarcodeFormatQR",
            "messageEncoding": "iso-8859-1"
          }
        ]
      }

    File.open(File.join(tmp_dir, "pass.json"), "w") do |f|
      f.write(pass.to_json)
    end

    true
  end

  def create_manifest(tmp_dir)
    manifest = {}

    Dir.glob(File.join(tmp_dir, "**")).each do |file|
      manifest[File.basename(file)] = Digest::SHA1.hexdigest(File.read(file))
    end

    File.open(File.join(tmp_dir, "manifest.json"), "w") do |f|
      f.write(manifest.to_json)
    end

    true
  end

  def create_signature(tmp_dir)
    manifest_path = File.join(tmp_dir, "manifest.json")
    cert_pw = Rails.application.credentials.dig(:pkpass, :cert_pw)

    p12_certificate = OpenSSL::PKCS12.new(File.read(P12_CERT_PATH), cert_pw)
    wwdr_certificate = OpenSSL::X509::Certificate.new(File.read(WWDR_INTERMEDIATE_CERT_PATH))

    flag = OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
    signature = OpenSSL::PKCS7.sign(p12_certificate.certificate, p12_certificate.key, File.read(manifest_path),
                                    [wwdr_certificate], flag)

    File.open(File.join(tmp_dir, "signature"), "w") do |f|
      f.syswrite(signature.to_der)
    end
  end

  def create_pkpass(tmp_dir)
    tmp_file = Tempfile.new("", PKPASS_TMP_DIR)

    Zip::OutputStream.open(tmp_file.path) do |z|
      Dir.glob(File.join(tmp_dir, "**")).each do |file|
        z.put_next_entry(File.basename(file))
        z.print File.read(file)
      end
    end

    File.read(tmp_file)
  ensure
    tmp_file.close
    tmp_file.unlink
  end

end
