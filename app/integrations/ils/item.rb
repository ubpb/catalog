class Ils
  class Item < BaseStruct

    AVAILABILITY_STATES = {
      loanable: :loanable,
      restricted_loanable: :restricted_loanable,
      available: :available,
      unavailable: :unavailable,
      unknown: :unknown
    }.freeze

    attribute :id, Types::String
    attribute :call_number, Types::String.optional
    attribute :barcode, Types::String.optional
    attribute :is_in_place, Types::Bool.default(false)
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
      elsif is_in_place && location&.label =~ /magazin/i
        true
      else
        false
      end
    end

    def availability
      if is_in_place
        calculate_in_place_availability
      else
        calculate_not_in_place_availability
      end
    end

    private

    def calculate_in_place_availability
      if process_type.blank?
        if loanable?
          AVAILABILITY_STATES[:loanable]
        elsif restricted_loanable?
          AVAILABILITY_STATES[:restricted_loanable]
        else
          AVAILABILITY_STATES[:available]
        end
      else
        AVAILABILITY_STATES[:unavailable]
      end
    end

    def calculate_not_in_place_availability
      if process_type.present?
        AVAILABILITY_STATES[:unavailable]
      else
        AVAILABILITY_STATES[:unknown]
      end
    end

    def loanable?
      reg_exp = /normalausleihe|magazinausleihe/i

      policy&.label =~ reg_exp || temp_policy&.label =~ reg_exp
    end

    def restricted_loanable?
      reg_exp = /kurzausleihe|4-wochen-ausleihe|tagesausleihe|6-monats-ausleihe/i

      policy&.label =~ reg_exp || temp_policy&.label =~ reg_exp
    end

  end
end
