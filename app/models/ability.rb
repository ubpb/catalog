# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user
      can :change_email, User do |user|
        user == current_user &&
          user.ils_user.user_group.code != "01" && # No PS
          user.ils_user.user_group.code != "02"    # No PA
      end
    end
  end
end
