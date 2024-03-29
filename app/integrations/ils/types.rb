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

    HoldRequestStatus = Strict::Symbol
      .default(:unknown)
      .enum(
        :in_queue,      # In Warteschlange
        :on_hold_shelf, # Bereitgestellt
        :in_process,    # In Bearbeitung
        :unknown        # Unbekannt
      )

  end
end
