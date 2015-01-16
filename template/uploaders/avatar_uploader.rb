module Uploaders
  class Avatar < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    # include CarrierWave::MiniMagick

    # Choose what kind of storage to use for this uploader:
    storage :file
    # storage :fog

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # Provide a default URL as a default if there hasn't been a file uploaded:

    # Create different versions of your uploaded files:
    version :thumb do
      process :resize_to_fit => [50, 50]
    end
  end
end