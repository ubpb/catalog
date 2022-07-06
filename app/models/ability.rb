# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user
      can :change_email, User do |user|
        user == current_user && !user.ils_primary_id.match?(/\APS|\APA/i)
      end
    end
  end
end
