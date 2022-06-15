# Aufzurufende URL:
# den Reversproxy
# http(s):\\ubtesa.uni-paderborn.de/cgi-bin/magbest_via_primo?para1=wert1&para2=wert2&...&parax=wertx
# oder direkt den Aleph-Apache-Webserver
# http:\\ubtesa.uni-paderborn.de:8991/cgi-bin/magbest_via_primo?para1=wert1&para2=wert2&...&parax=wertx

# Parameter sind:
# ---------------

# name            Nachname, Vorname
# ausweis         die Ausweisnummer

# JCHECK          Jahrgangspruefung der Zeitschriften, wenn vorhanden wird geprueft

# m1              fuer die Signatur der ersten Monografie
# k1              fuer den Kurztitel der ersten Monografie

# m2              2. Monografie
# k2

# m3              3. Monografie
# k3

# m4              4. Monografie
# k4

# z1              fuer die erste Zeitschriftensignatur
# j1              fuer das Jahr
# b1              fuer den Band
# s1              fuer die Seite

# z2              2. Zeitschrift
# j2
# b2
# s2

# z3              3. Zeitschrift
# j3
# b3
# s3

# z4              4. Zeitschrift
# j4
# b4
# s4

# Beispielaufruf:
# ---------------
# http:\\ubtesa.uni-paderborn.de:8991/cgi-bin/magbest_via_primo?name=Nachname,Vorname&ausweis=PA1012345678&m1=M43654&k1=Vertraute+Fremde&JCHECK=


# Antworten des CGI-Scripts         Was soll es bedeuten?
# -------------------------         ---------------------
# erfolg                            Bestellung wurde angenommen

# fehler_nicht_schonwieder          Diese Bestellung wurde bereits aufgegeben!
#                                   Bitte erkundigen Sie sich ggf. an der Ortsleihtheke, wann die von Ihnen
#                                   gewuenschte Literatur abholbereit ist

# fehler_bestellangaben             Bitte geben Sie die Signatur des gewuenschten Exemplares an.

# fehler_jahrgang_band              Bitte geben Sie den Jahrgang und/oder Nummer des Bandes an.

# fehler_jahr_in_ebene              Sie haben einen Jahrgang ab 1987 eingegeben!
#                                   Diese Zeitschriftenbaende finden Sie in der Regel nicht im Magazin sondern in
#                                   den Fachbibliotheken. Wenn Sie sicher sind, dass sich der von Ihnen
#                                   benoetigte Band im Magazin befindet, schalten Sie bitte im Eingabeformular die
#                                   Jahrgangspruefung aus.

# fehler_jahrgang_falsch            Sie haben den Zeitschriftenjahrgang ist nicht richtig eingegeben!
#                                   Bitte geben Sie das Jahr vierstellig ein.
#                                   Bitte beachten Sie dabei:
#                                   Im Magazin sind nur Jahrgaenge bis 1995 untergebracht.
#                                   Neuere Zeitschriftenbaende finden Sie in den Fachbibliotheken.

# IPAdr_nicht_erlaubt               Zugriff von dieser IP nicht erlaubt

# HTML-Formular zum Testen:
# -------------------------
# http://ubtesa.uni-paderborn.de/lokadm/magbest_via_primo.htm

# Anzeige der aktuellen Magazinbestellungen
# -----------------------------------------
# http://ubtesa.uni-paderborn.de/cgi-bin/zeigemagbest

class ClosedStackOrdersController < ApplicationController
  before_action :authenticate!
  before_action :setup
  before_action { add_breadcrumb(t("closed_stack_orders.breadcrumb"), new_closed_stack_order_path) }

  UNDEFINED_ERROR_MESSAGE = I18n.t("closed_stack_orders.undefined_error")

  def new
  end

  def create
    if @m1 == "BYH1141" && @k1.blank?
      flash[:error] = t(".microfiche_hint")
      redirect_on_error and return
    end

    url = Config[:closed_stack_orders, :url, default: "http://localhost:81/cgi-mag/magbest_via_katalog"]

    url_params = {
      name: current_user.name_reversed,
      ausweis: current_user.ils_primary_id,
      m1: @m1,
      k1: @k1,
      z1: @z1,
      j1: @j1,
      b1: @b1,
      s1: @s1
    }
    url_params["jcheck"] = "true" if @volume_check

    begin
      response_code = RestClient.get(url, params: url_params)&.body
    rescue RestClient::ExceptionWithResponse
      response_code = "undefined"
    end

    if response_code == "erfolg"
      flash[:success] = t(".success")
      redirect_to new_closed_stack_order_path
    else
      @error_message = case response_code
        when "fehler_nicht_schonwieder" then t(".errors.fehler_nicht_schonwieder")
        when "fehler_bestellangaben"    then t(".errors.fehler_bestellangaben")
        when "fehler_jahrgang_band"     then t(".errors.fehler_jahrgang_band")
        when "fehler_jahr_in_ebene"     then @volume_error = true ; t(".errors.fehler_jahr_in_ebene")
        when "fehler_jahrgang_falsch"   then t(".errors.fehler_jahrgang_falsch")
        else UNDEFINED_ERROR_MESSAGE
      end

      flash[:error] = @error_message
      redirect_on_error
    end
  end

private

  def redirect_on_error
    redirect_to new_closed_stack_order_path(
      params.permit(
        :m1, :k1, :z1, :j1, :b1, :s1, :volume_check
      ).to_h
    )
  end

  def setup
    @m1 = params[:m1]
    @k1 = params[:k1]
    @z1 = params[:z1]
    @j1 = params[:j1]
    @b1 = params[:b1]
    @s1 = params[:s1]
    @volume_check = params[:volume_check].present?
  end

end
