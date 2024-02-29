class NoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :word_count, :created_at, :content, :content_length, :user
  belongs_to :user, serializer: UserSerializer
end
