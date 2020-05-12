class SearchEngine
  module Contract
    include Operation::TryOperation

    def get_record(record_id, options = {})
      try_operation(__method__, record_id, options)
    end

    def search(search_request, options = {})
      try_operation(__method__, search_request, options)
    end

  end
end
