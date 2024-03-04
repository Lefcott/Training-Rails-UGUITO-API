# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :string           not null
#  type       :integer          not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user
  has_one :utility, through: :user

  validates :title, :content, presence: true
  validates :type, presence: true, inclusion: { in: %w[review critique] }
  validate :validate_word_count

  enum type: { review: 0, critique: 1 }

  self.inheritance_column = :_type_disabled

  scope :with_type, lambda { |type, order|
    where(with_type_filter(type)).order(created_at: order)
  }

  def word_count
    content.scan(/[\p{Alpha}\-']+/).length
  end

  def content_length
    return 'short' if word_count <= utility.short_content_length
    return 'medium' if word_count <= utility.medium_content_length
    'long'
  end

  def validate_word_count
    invalid = content && content_length != 'short' && type == 'review'
    max_words = utility.short_content_length
    errors.add :content, I18n.t('note.word_count_validation', max_words: max_words) if invalid
  end

  def self.with_type_filter(type)
    return {} if type.blank?
    { type: type }
  end

  def self.with_type_filter(type)
    return {} if type.blank?
    { type: type }
  end
end
