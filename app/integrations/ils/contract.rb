class Ils
  module Contract
    include Operation::TryOperation

    #
    # Authenticates a user.
    #
    # @param username [String] a username.
    # @param password [String] a password.
    # @return [true, false] `true` if the user has been authenticated successfully,
    #   `false` otherwise.
    #
    def authenticate_user(username, password)
      try_operation(__method__, username, password)
    end

    #
    # Get user details.
    #
    # @param username [String] a username.
    # @return [Ils::User, nil] returns the user with the given username
    #   or `nil` if the user doesn't exists.
    #
    def get_user(username)
      try_operation(__method__, username)
    end

    #
    # Get the loans for a user.
    #
    # @param user_id [String] a user ID.
    # @param options [Hash] an options hash. Optional.
    # @option options :disable_pagination [Bool] disbale pagination. Optional. Default value: false.
    #   If disabled, all loans will be returned.
    # @option options :per_page [Integer] number of loans to return per page. Optional. Default value: 10.
    # @option options :page [Integer] the page to return. Optional. Default value: 1.
    # @return Ils::GetLoansResult current loans.
    #
    def get_current_loans(user_id, options = {})
      try_operation(__method__, user_id, options)
    end

    #
    # Get the former loans for a user.
    #
    # @param user_id [String] a user ID.
    # @param options [Hash] an options hash. Optional.
    # @option options :per_page [Integer] ... Optional. Default value: 10.
    # @option options :page [Integer] ... Optional. Default value: 1.
    # @return Ils::GetLoansResult former loans.
    #
    def get_former_loans(user_id)
      try_operation(__method__, user_id)
    end

    #
    # Renews all loaned items for a user.
    #
    # @param user_id [String] a user ID
    # @return [Array<Ils::RenewLoanResult>] List of renew results.
    #
    def renew_loans(user_id)
      try_operation(__method__, user_id)
    end

    #
    # Renews a loaned item for a user.
    #
    # @param user_id [String] a user ID
    # @param loan_id [String] a loan ID
    # @return [Ils::RenewLoanResult] Renew result.
    #
    def renew_loan(user_id, loan_id)
      try_operation(__method__, user_id, loan_id)
    end

    #
    # Get the active fees for a user.
    #
    # @param user_id [String] a user ID
    # @return [Array<Ils::Fee>] List of fees
    #
    def get_fees(user_id)
      try_operation(__method__, user_id)
    end

    #
    # Get the hold requests for a user.
    #
    # @param user_id [String] a user ID.
    # @return [Array<Ils::HoldRequest>] List of hold requests.
    #
    def get_hold_requests(user_id)
      try_operation(__method__, user_id)
    end

    #
    # Cancels a hold request for a user
    #
    # @param user_id [String] a user ID.
    # @param hold_request_id [String] a hold request ID.
    # @return [true, false] `true` if the hold request has been canceled successfully,
    #   `false` otherwise
    #
    def cancel_hold_request(user_id, hold_request_id)
      try_operation(__method__, user_id, hold_request_id)
    end

    #
    # Get the items for a record.
    #
    # @param record_id [String] a record ID.
    # @return [Array<Ils::Item>] List of items for the given record ID. The  array
    #   is empty if no items (or a record with that ID) exists.
    #
    def get_items(record_id)
      try_operation(__method__, record_id)
    end

  end
end
