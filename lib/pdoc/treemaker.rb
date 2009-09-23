module PDoc
  class Treemaker
    include Models
    
    def initialize(doc_fragments = [])
      doc_fragments.each do |attributes|
        object = Base.instantiate(attributes)
        object.register_on(root.registry)
      end

      doc_fragments.each do |attributes|
        parent_id = attributes[:parent_id]
        parent = parent_id ? root.find(parent_id) : root
        object = registry.find(attributes[:id])
        object.parent = parent
        object.attach_to_parent(parent)
      end
    end

    def root
      @root ||= Root.new
    end
  end
end