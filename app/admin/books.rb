ActiveAdmin.register Book do
  permit_params :genre, :author, :image, :title, :publisher, :year, :utility_id, :user_id

  index do
    selectable_column
    id_column
    column :genre
    column :author
    column :image
    column :title
    column :publisher
    column :year
    actions
  end

  filter :genre
  filter :author
  filter :utility
  filter :title
  filter :publisher
  filter :year

  form do |f|
    f.inputs do
      f.input :genre
      f.input :author
      f.input :image
      f.input :title
      f.input :publisher
      f.input :year
      f.input :utility_id, label: 'Utility', as: :select, collection: Utility.all.map { |utility|
        [utility.name, utility.id]
      }
      f.input :user_id, label: 'User', as: :select, collection: User.all.map { |user|
        ["#{user.last_name}, #{user.first_name}", user.id]
      }
    end
    f.actions
  end
end
