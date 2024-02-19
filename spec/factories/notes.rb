FactoryBot.define do
  factory :note do
    title { "MyString" }
    content { "MyString" }
    type { 1 }
    user { nil }
  end
end
