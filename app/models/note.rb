# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :string           not null
#  type       :integer          not null
#  user_id    :bigint(8)        not null
#  utility_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user
  has_one :utility, through: :user

  validates :title, :content, :type, presence: true

  enum type: { review: 0, critique: 1 }

  self.inheritance_column = :_type_disabled

  def word_count
    content.scan(/[\p{Alpha}\-']+/).length
  end
end
