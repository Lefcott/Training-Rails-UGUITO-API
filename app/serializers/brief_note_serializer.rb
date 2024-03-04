class BriefNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :content_length
end
