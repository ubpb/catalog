class Ils
  class Item < BaseStruct
    AVAILABILITIES = [:available, :restricted_available, :unavailable, :unknown].freeze

    attribute :id, Types::String
    attribute :call_number, Types::String.optional
    attribute :barcode, Types::String.optional
    attribute :is_available, Types::Bool.default(false) # TODO: should be named is_loanable
    attribute :reshelving_time, Types::Time.optional
    attribute :policy, Ils::ItemPolicy.optional
    attribute :library, Ils::Library.optional
    attribute :location, Ils::Location.optional
    attribute :process_type, Ils::ProcessType.optional
    attribute :due_date, Types::Time.optional
    attribute :due_date_policy, Types::String.optional
    attribute :is_requested, Types::Bool.default(false)
    attribute :public_note, Types::String.optional
    attribute :expected_arrival_date, Types::Date.optional
    attribute :arrival_date, Types::Date.optional
    attribute :description, Types::String.optional
    attribute :physical_material_type, CodeLabelType.optional

    attribute :is_in_temp_location, Types::Bool.default(false)
    attribute :temp_location, Ils::Location.optional
    attribute :temp_policy, Ils::ItemPolicy.optional
    attribute :temp_due_back_date, Types::Date.optional

    # Sorting items in the discovery is dependent on various
    # factors that can only be decided on controller level.
    # To give controllers a way to set a sorting strategy we add
    # this optional sort_key field.
    attribute :sort_key, Types::String.optional

    # For journals this flag indicates if the issue is expected for arrival
    # or is a current "unbound" issue. This flag can be used to filter out
    # "bounded" issues.
    def expected_or_current_issue?
      expected_issue? || current_issue?
    end

    # Erwartete Hefte haben Materialart = "Heft", expected_arrival_date gesetzt und
    # ein leeres arrival_date.
    def expected_issue?
      physical_material_type&.code == "ISSUE" &&
        expected_arrival_date.present? &&
        arrival_date.blank?
    end

    # Aktuelle Hefte haben Materialart = "Heft", ein arrival_date gesetzt
    def current_issue?
      physical_material_type&.code == "ISSUE" && arrival_date.present?
    end

    def closed_stack_orderable?
      if location&.code == "04"
        false
      elsif is_in_temp_location
        false
      elsif is_available && location&.label =~ /magazin/i
        true
      else
        false
      end
    end

    def availability
      if is_available == true
        :available
      elsif is_restricted_available?
        :restricted_available
      elsif is_available == false
        :unavailable
      else
        :unknown
      end
    end

    private

    def is_restricted_available?
      restricted_available_codes = [
        "23", # Tischapparat
        "30", # Kurzausleihe
        "31", # Magazin-Kurzausleihe
        "32", # Nicht ausleihbar
        "33", # Seminarapparat
        "34", # Kurzausleihe
        "35", # Kurzausleihe
        "36", # Kurzausleihe
        "37", # Nicht ausleihbar
        "38", # Nicht ausleihbar
        "40", # Kurzausleihe
        "41", # Nicht ausleihbar
        "42", # Nicht ausleihbar
        "43", # Handapparat
        "44", # Nicht ausleihbar
        "47", # Magazin-Kurzausleihe
        "48", # Nicht ausleihbar
        "49", # Nicht ausleihbar
        "50", # Nicht ausleihbar
        "53", # 4-Wochen-Ausleihe
        "55", # Nicht ausleihbar
        "58", # Nicht ausleihbar
        "60", # Nicht ausleihbar
        "61", # Magazin-5-Tage-Ausleihe
        "68", # Magazin-Präsenzausleihe
      ]

      restricted_available_codes.include?(policy&.code)
    end

  end
end
