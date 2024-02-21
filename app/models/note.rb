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

  validates :user_id, :title, :content, presence: true
  validates :type, presence: true, inclusion: { in: %w[review critique] }
  validate :valid_word_count

  enum type: { review: 0, critique: 1 }

  self.inheritance_column = :_type_disabled

  def word_count
    content.scan(/[\p{Alpha}\-']+/).length
  end

  def content_length
    return 'short' if word_count <= (utility&.short_content_length || 50)
    return 'medium' if word_count <= (utility&.medium_content_length || 100)
    'long'
  end

  def valid_word_count
    valid = content.nil? || content_length == 'short' || type != 'review'
    max_words = utility&.short_content_length || 50
    errors.add :content, I18n.t('note.word_count_validation', max_words: max_words) unless valid
  end
end
