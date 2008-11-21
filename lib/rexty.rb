module Rexty
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def renders_ext_tree(name, options={}, &proc)
      tree = ExtTree.new(name, options)
      tree.instance_eval(&proc)
      define_method("#{name}_tree_data".to_sym) do
        render :text => tree.get_data(self, params).to_json
      end
    end
  end
  
end

ActionController::Base.send :include, Rexty