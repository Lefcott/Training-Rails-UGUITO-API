FactoryBot.define do
  factory :note do
    title { Faker::Book.title }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    type { 1 }
    user
  end
end
