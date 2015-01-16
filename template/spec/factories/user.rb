FactoryGirl.define do
  to_create { |i| i.save }
  factory :user, class: Models::User do
    display_name { Faker::Name.title  }
    email { Faker::Internet.email(display_name) }
    role { :guest }
  end
end