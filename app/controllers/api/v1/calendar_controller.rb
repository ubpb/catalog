require "digest/sha2"

class Api::V1::CalendarController < Api::V1::ApplicationController
  include IcalDsl

  before_action :authenticate!

  def show
    loans      = load_all_loans
    provisions = load_all_provisions

    ics = to_raw_ics(loans: loans, provisions: provisions)

    respond_to do |format|
      format.text do
        render plain: ics
      end

      format.ics do
        render plain: ics
      end
    end
  end

  private

  def load_all_loans
    Ils.get_current_loans(
      current_user.ils_primary_id, {
        disable_pagination: true
      }
    ).loans
  end

  def load_all_provisions
    Ils.get_hold_requests(
      current_user.ils_primary_id
    ).select do |hold_request|
      hold_request.status == :on_hold_shelf
    end
  end

  def group_loans_by_due_date(loans)
    group = {}
    loans.each { |loan| (group[loan.due_date] ||= []) << loan }
    group
  end

  # def group_provisions_by_due_date(provisions)
  #   group = {}
  #   provisions.each { |provision| (group[provision.expiry_date] ||= []) << provision }
  #   group
  # end

  def to_raw_ics(loans: [], provisions: [])
    loans_url         = File.join(root_url, "/user/loans")
    holds_url         = File.join(root_url, "/user/holds")
    info_url          = "https://goo.gl/bbyjOc"  # http://www.ub.uni-paderborn.de/nutzen-und-leihen/ausleihkonditionen/
    fees_url          = "https://goo.gl/o5mhzt"  # http://www.ub.uni-paderborn.de/nutzen-und-leihen/gebuehren/
    opening_hours_url = "https://goo.gl/dWFbGo"  # http://www.ub.uni-paderborn.de/ueber-uns/oeffnungszeiten/

    loans_group = group_loans_by_due_date(loans)

    Calendar.build do
      item "VERSION", "2.0"
      item "PRODID", "-//Universitätsbibliothek Paderborn//Katalog//DE"
      item "METHOD", "PUBLISH"
      item "CALSCALE", "GREGORIAN"
      item "X-WR-CALNAME", "UB Paderborn - Leihfristen"
      item "X-WR-TIMEZONE", "Europe/Berlin"

      #
      # Leihfristen
      #
      loans_group.each_key do |due_date|
        loans  = loans_group.fetch(due_date)
        titles = loans.each_with_index.map do |loan, i|
          "#{i+1}. #{[loan.title, "Barcode: #{loan.barcode}"].map(&:presence).join(', ')}"
        end.join('\n')

        description = <<-EOS
Die Leihfrist für die folgenden Medien endet heute. Ab morgen fallen Gebühren an.
Bitte nutzen Sie Ihr Bibliothekskonto um Details zu sehen und um ggf. Verlängerungen zu veranlassen.

#{titles}

Bibliothekskonto: #{loans_url}
Informationen zu Ausleihe, Verlängerung und Rückgabe von Medien: #{info_url}
Informationen zu Gebühren: #{fees_url}
Bitte beachten Sie unsere Öffnungszeiten: #{opening_hours_url}
EOS
        block "VEVENT" do
          item "UID", (Digest::SHA2.new << "loans-#{due_date.to_s}").to_s
          item "CLASS", "PUBLIC"
          item "TRANSP", "TRANSPARENT"
          item "DTSTART;VALUE=DATE", due_date
          item "DTEND;VALUE=DATE", due_date
          item "SEQUENCE", "0"
          item "SUMMARY;LANGUAGE=de", "Leihfrist endet"
          item "DESCRIPTION", description, fold: true, escape: true
          item "X-MICROSOFT-CDO-BUSYSTATUS", "FREE"
          item "X-MICROSOFT-CDO-IMPORTANCE", "1"
          item "X-MICROSOFT-DISALLOW-COUNTER", "FALSE"
          item "X-MS-OLK-CONFTYPE", "0"

          #
          # Alarms will be ignored by most apps (ical (by default), Outlook) when
          # reading calendars from web resources due to security reasons (no one likes
          # to wake up at night because of silly alarm settings).
          # Outlook for example dosen't import alarms at any case. See
          # http://answers.microsoft.com/en-us/office/forum/office_2010-outlook/outlook-calendar-import-with-remindersalarms/7d5f9690-7309-4a4d-8b4c-788c093b5b36
          #
          #block "VALARM" do
          #  item "ACTION", "DISPLAY"
          #  item "DESCRIPTION", "Reminder"
          #  item "TRIGGER;VALUE=DATE-TIME", due_date.to_datetime.in_time_zone.change(hour: 9)
          #end
        end
      end

      #
      # Bereitstellungen
      #
      provisions.each.with_index do |provision, i|
        expiry_date = provision.expiry_date
        description = <<-EOS
Das folgende vorgemerkten Medium steht für Sie zur Abholung bereit.
Bitte nutzen Sie Ihr Bibliothekskonto um Details zu sehen und ggf. um Vormerkungen zu löschen, sollten Sie die Medien nicht mehr benötigen.

#{provision.title}, Barcode: #{provision.barcode}

Bibliothekskonto: #{holds_url}
Informationen zu Ausleihe, Verlängerung und Rückgabe von Medien: #{info_url}
Informationen zu Gebühren: #{fees_url}
Bitte beachten Sie unsere Öffnungszeiten: #{opening_hours_url}
EOS

        block "VEVENT" do
          item "UID", (Digest::SHA2.new << "provisions-#{expiry_date.to_s}").to_s
          item "CLASS", "PUBLIC"
          item "TRANSP", "TRANSPARENT"
          item "DTSTART;VALUE=DATE", Time.zone.today
          item "DTEND;VALUE=DATE", expiry_date
          item "SEQUENCE", "0"
          item "SUMMARY;LANGUAGE=de", "Eine Vormerkung kann abgeholt werden"
          item "DESCRIPTION", description, fold: true, escape: true
          item "X-MICROSOFT-CDO-BUSYSTATUS", "FREE"
          item "X-MICROSOFT-CDO-IMPORTANCE", "1"
          item "X-MICROSOFT-DISALLOW-COUNTER", "FALSE"
          item "X-MS-OLK-CONFTYPE", "0"
        end
      end
    end
  end

end
