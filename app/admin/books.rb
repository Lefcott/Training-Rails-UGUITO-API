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
      f.input :utility_id
      f.input :user_id
    end
    f.actions
  end
end
