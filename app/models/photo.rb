class Photo < ActiveRecord::Base
  belongs_to :listing

  # has_attached_file :image,
  #                   :styles => { medium: '300x300>', thumb: '100x100>', landscape: '1800x1200#'},
  #                   :storage => :cloudinary,
  #                   :path => "/:class/:attachment/:id_partition/:style/:filename"


  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

end
