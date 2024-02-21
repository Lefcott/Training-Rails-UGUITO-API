FactoryBot.define do
  factory :note do
    user
    title { Faker::Book.title }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    type { Note.types.values.sample }
    utility
  end
end
