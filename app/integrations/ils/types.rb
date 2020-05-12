class Ils
  module Types
    include Dry.Types()

    ProcessStatus = Strict::Symbol
      .default(:unknown)
      .enum(
        :bookbinder,       # Buchbinder
        :claimed_lost,     # Angeblich Verlust
        :claimed_returned, # Angeblich zurück
        :expected,         # Erwartet
        :in_process,       # In Bearbeitung
        :loaned,           # Entliehen
        :lost,             # Verlust
        :missing,          # Vermisst
        :on_hold,          # Bereitgestellt
        :on_shelf,         # Im Regal
        :ordered,          # Bestellt
        :reshelving,       # Wird zurückgestellt
        :scrapped,         # Ausgesondert
        :unknown,          # Unbekannt
      )

    AvailabilityStatus = Strict::Symbol
      .default(:unknown)
      .enum(
        :available,            # Verfügbar
        :restricted_available, # In der Bibliothek/eingeschränkt verfügbar
        :not_available,        # Nicht verfügbar
        :unknown,              # Unbekannt
      )

    HoldRequestStatus = Strict::Symbol
      .default(:requested)
      .enum(
        :requested, # Vorgemerkt
        :on_hold,   # Bereitgestellt
        :in_process # In Bearbeitung
      )

  end
end
