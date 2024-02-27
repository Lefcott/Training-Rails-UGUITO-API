FactoryBot.define do
  factory :note do
    title { Faker::Book.title }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    type { Note.types.values.sample }
    user
  end
end
