module AttachmentDeletable
  extend ActiveSupport::Concern

  class_methods do
    def removable_attachment_for(*attachment_names)
      attachment_names.each do |attachment|
        attr_accessor :"remove_#{attachment}"

        define_method :"purge_#{attachment}_if_requested" do
          if ActiveModel::Type::Boolean.new.cast(send("remove_#{attachment}"))
            send(attachment).purge
          end
        end

        before_save :"purge_#{attachment}_if_requested"
      end
    end
  end
end
