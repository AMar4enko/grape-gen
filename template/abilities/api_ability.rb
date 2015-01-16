class ApiAbility
  include CanCan::Ability
  def initialize(user)
    return unless user
    alias_action :view, :create, :update, :delete, to: :crud

    can :update_profile, user
    can :view, Models::User
    can :update, Models::User, { id: user.id }

    if user.role == :admin
      can :crud, :all
    end
  end
end