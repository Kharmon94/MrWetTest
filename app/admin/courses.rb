ActiveAdmin.register Course do
    # Permit the necessary parameters, including the thumbnail attachment.
    permit_params :title, :description, :price, :thumbnail
  
    # Customize the form for course creation/editing.
    form do |f|
      f.inputs "Course Details" do
        f.input :title
        f.input :description
        f.input :price
        f.input :thumbnail, as: :file, hint: (f.object.thumbnail.attached? ? image_tag(url_for(f.object.thumbnail.variant(resize_to_limit: [100, 100]))) : content_tag(:span, "No thumbnail yet"))
      end
      f.actions
    end
  
    # Customize the show page to display the thumbnail.
    show do
      attributes_table do
        row :title
        row :description
        row :price
        row :thumbnail do |course|
          if course.thumbnail.attached?
            image_tag url_for(course.thumbnail.variant(resize_to_limit: [300, 300])), alt: "Course Thumbnail"
          else
            "No thumbnail"
          end
        end
      end
      active_admin_comments
    end
  
    # Optionally, customize the index view.
    index do
      selectable_column
      id_column
      column :title
      column :price
      column :created_at
      column "Thumbnail" do |course|
        if course.thumbnail.attached?
          image_tag url_for(course.thumbnail.variant(resize_to_limit: [50, 50])), alt: "Thumbnail"
        else
          "No thumbnail"
        end
      end
      actions
    end
  end
  