module Workflow
  module Adapter
    module Mongoid
      def self.included(klass)
        klass.send :include, InstanceMethods
      end
      module InstanceMethods
        def load_workflow_state
          send(self.class.workflow_column)
        end

        def persist_workflow_state(new_value)
          update_attributes(self.class.workflow_column => new_value)
        end

        def before_validation
          attributes[self.class.workflow_column] = current_state.to_s
          super
        end
      end
    end
  end
end

module Mongoid
  module Document
    module ClassMethods
      def workflow_adapter; Workflow::Adapter::Mongoid end
    end
  end
end