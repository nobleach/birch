class Request < ActiveRecord::Base
  attr_accessible :incident_name, :incident_id, :forest_name, :acres, :ignition_date,
    :percent_contained, :expected_containment_date, :shapefile_file_name, :shapefile_content_type,
    :shapefile_file_size, :lat, :lng, :assessment_start_date, :desired_delivery_date,
    :team_leader, :requestor_name, :requestor_email, :requestor_phone, :comments,
    :username, :status, :marker1_lat, :marker1_lng, :marker2_lat, :marker2_lng,
    :department, :requested_date, :supporting_agency

  prefix = ENV['RAILS_RELATIVE_URL_ROOT']
  #add paperclip for file upload:
  has_attached_file :shapefile,
    :url => "#{prefix}/shapefiles/:basename.:extension",
    :path => "#{Rails.public_path}/shapefiles/:basename.:extension"

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

  validates :requestor_name, :presence => true
  validates :requestor_email, :presence => true, :format => EMAIL_REGEX
  validates :requestor_phone, :presence => true
  validates :incident_name, :presence => true
  validates :ignition_date, :presence => true
  # validates :lat, :presence => true
  # validates :lng, :presence => true


  validates_attachment_size :shapefile, :less_than => 15.megabytes

  def upload
    if self.shapefile_file_name.nil?
      'None uploaded.'
    else
      #yes this is an icky FAT model...
      '<a href="'+self.shapefile.url+'">Download</a>'
    end
  end

  def self.convert_to_decimal_degrees(point)
    dd = point.scan(/(-?)(\d+)d(\d+)m(\d+)/).map do |o,x,y,z|
      positive_longitude = x.to_f+y.to_f/60+z.to_f/3600
      if o == '-'
        negative_longitude = positive_longitude * -1
        return negative_longitude
      end
      return positive_longitude
    end

  end
end
