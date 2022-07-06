# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user
      can :change_email, User do |user|
        user == current_user &&
        user.user_group_code != "01" && # No PS
        user.user_group_code != "02"    # No PA
      end
    end
  end
end
