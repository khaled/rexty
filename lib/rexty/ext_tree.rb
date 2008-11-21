module Rexty
  #
  # Encapsulates options for and handles tree data requests for a particular 
  # renders_ext_tree invocation
  #
  class ExtTree
    def initialize(name, options)
      @name = name
      @options = options
    end
    
    #
    # Define a tree node for a particular object type
    #
    def node(model_name, options={})
      @nodes ||= {}
      @nodes[model_name] = options
    end
    
    def get_data(controller, params)
      records = compute_records(controller, params)
      records.map do |x|
        underscore_name = x.class.name.underscore
        node_options = @nodes[underscore_name.to_sym]
        node_options ||= { :text => Proc.new {|x| x.class.name } }  # default node text to class name
        id_prefix = @options[:stable_ids] ? x.id : x.object_id.abs
        node = { :id => "#{id_prefix}-#{underscore_name}-#{x.id}", :dbid => x.id, :object_type => underscore_name }
        node[:leaf] = true if not node_options[:children]
        [:qtip, :text, :icon].each do |attribute|
          node[attribute] = invoke_or_send(controller, x, node_options[attribute]) if node_options[attribute]
        end
        data = node_options[:data] || {}
        data.each do |key, val|
          node[key] = invoke_or_send(controller, x, val) 
        end
        node
      end
    end
    
    private

    def invoke_or_send(controller, x, proc_or_symbol)
      case proc_or_symbol
        when Proc then controller.instance_exec(x, &proc_or_symbol)
        when Method then proc_or_symbol.call(x)
        when Symbol then x.send(proc_or_symbol)
        else proc_or_symbol
      end
    end
  
    def compute_records(controller, params)
      node_id = params[:node]
      if (node_id == "root")
        roots = @options[:roots]
        return roots.is_a?(Proc) ? controller.instance_eval(&roots) : roots.to_s.camelize.constantize.find(:all)
      else
        id_prefix, model_name, id = node_id.split("-")
        model_class = model_name.to_s.camelize.constantize
        children_method = @nodes[model_name.to_sym][:children]
        return children_method ? invoke_or_send(controller, model_class.find(id.to_i), children_method) : []
      end
    end
  end
end