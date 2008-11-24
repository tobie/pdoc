module Documentation
  class Doc < Treetop::Runtime::SyntaxNode
    include Enumerable

    def each
      elements.first.elements.map { |e| e.elements.last }.each { |tag| yield tag }
    end
    
    # Returns an array of all deprecated object.
    def deprecated
      select { |e| e.deprecated? }
    end
    
    # Returns an array of all documented aliases.
    def aliases
      select { |e| e.alias? }
    end
    
    # return an array of all documented KlassMethod instances.
    def klass_methods
      select { |e| e.is_a?(KlassMethod) }
    end

    # return an array of all documented InstanceMethod instances.
    def instance_methods
      select { |e| e.is_a?(InstanceMethod) }
    end

    # return an array of all documented Constructor instances.
    def constructors
      select { |e| e.is_a?(Constructor) }
    end

    # return an array of all documented Constant instances.
    def constants
      select { |e| e.is_a?(Constant) }
    end

    # return an array of all documented Namespace instances.
    def namespaces
      select { |e| e.is_a?(Namespace) }
    end

    # return an array of all documented KlassProperty instances.
    def klass_properties
      select { |e| e.is_a?(KlassProperty) }
    end

    # return an array of all documented InstanceProperty instances.
    def instance_properties
      select { |e| e.is_a?(InstanceProperty) }
    end

    # return an array of all documented Utility instances.
    def utilities
      select { |e| e.is_a?(Utility) }
    end

    # return an array of all documented Mixin instances.
    def mixins
      select { |e| e.is_a?(Mixin) }
    end
    
    # return an array of all documented Klass instances.
    def klasses
      select { |e| e.is_a?(Klass) }
    end
    
    # find_by_name allows you to search through all the documented instances based on the 
    # instances Base#full_name.
    # For example:
    #
    #     PDoc::Parser.new("prototype.js").parse.root.find_by_name("Element#update")
    #
    # Return an instance of InstanceMethod corresponding to "Element#update".
    def find_by_name(name)
      find { |e| e.full_name == name }
    end
    
    def descendants
      select { |e| e.is_a?(Namespace) || e.is_a?(Utility) }
    end
    
    # Returns an array of all documented instances which are global variables.
    def globals
      select { |e| e.global? }.sort_by { |e| e.name }
    end
    alias children globals
    
    # Returns an array of all documented Section instances.
    def sections
      select { |e| e.is_a?(Section) }.sort_by { |e| e.name }
    end
    
    def inspect
      to_a.inspect
    end
    
    # Returns the total number of documented instances
    def size
      to_a.length
    end
  end
  
  class Base < Treetop::Runtime::SyntaxNode
    # Returns an instance of Doc (the root of the tree outputed by the PDoc::Parser).
    def root
      parent.parent.parent
    end
    
    # True if the instance was tagged as deprecated.
    def deprecated?
      tags.include?("deprecated") || ancestors.any? { |a| a.deprecated? }
    end
    
    # True if the instance is a global variable.
    def global?
      namespace_string.empty?
    end
    
    # True if the instance is an alias.
    def alias?
      tags.include?("alias of")
    end
    
    # If instance is tagged as an alias, alias_of returns the corresponding object.
    # It will return nil otherwise.
    def alias_of
      if alias?
        a = tags.find { |tag| tag.name == "alias of" }.value
        root.find_by_name(a)
      else
        nil
      end
    end
    
    # Returns an array of all aliases of this instance.
    def aliases
      root.select { |a| a.alias_of == self }
    end
    
    # Returns an instance of Tags::Tags.
    def tags
      start.elements.last.empty? ? [] : start.elements.last
    end
    
    # Returns the instance's class name.
    def klass_name
      ebnf.klass_name
    end
    
    # Returns the instance's name. For example:
    #     root.find_by_name("Element#update").name
    #     # -> "update"
    def name
      ebnf.name
    end
    
    # Returns the instance's full_name. For example:
    #     root.find_by_name("Element#update").full_name
    #     # -> "Element#update"
    def full_name
      ebnf.full_name
    end
    
    # Returns the instance's namespace_string. Note that event if the instance is an method or property,
    # the klass_name is not included in that string. So for example:
    #
    #     root.find_by_name("Ajax.Request#request").namespace_string
    #     # -> "Ajax"
    def namespace_string
      ebnf.namespace
    end
    
    # Returns the section this instance belongs to. If no section has been 
    # specified in the tags, it iterates through the ancestors until it finds one.
    def section
      if tags.include?("section")
        value = tags.find { |tag| tag.name == "section" }.value
        root.sections.find { |s| s.name == value }
      else
        namespace.section
      end
    end
    
    # Returns the Klass instance if object is a class, nil otherwise.
    def klass
      nil
    end
    
    # Returns the instance's closests namespace or nil when instance or instance's
    # Klass is a global.
    def namespace
      namespace_string.empty? ? nil : root.find_by_name(namespace_string)
    end
    
    # If instance is a global, returns its Section. Else its Namespace.
    def doc_parent
      namespace ? namespace : section
    end
    
    # Recursively collects all of instance's doc_parent and returns them
    # as an ordered array.
    def ancestors
      [doc_parent].concat(doc_parent.ancestors)
    end
    
    # Returns all direct descendants of instance.
    def children
      root.descendants.select { |d| d.namespace === self }.sort_by { |e| e.name }
    end
    
    # Returns all descendants of instance.
    def descendants
      results = children
      children.inject(results) { |r, c| r.concat(c.descendants) } unless children.empty?
      results
    end
    
    def description
      text.to_s
    end
    
    def id
      name.downcase.gsub('$', "dollar")
    end
    
    def inspect
      "#<#{self.class} #{full_name}>"
    end
  end
  
  class Section < Base
    # Returns section's name
    def name
      section.name
    end

    # Returns section's id
    def id
      section.id
    end

    # Returns section's full_name
    def full_name
      section.full_name
    end

    # Returns section's title
    def title
      section.title
    end

    # Returns section's description
    def description
      section.description
    end

    # Returns section's text
    def text
      section.text
    end
    
    # Returns nil.
    def klass_name
      nil
    end
    
    # Returns false.
    def global?
      false
    end
    
    # Returns nil.
    def namespace
      nil
    end
    
    # Returns an empty string.
    def namespace_string
      ""
    end
    
    # Returns nil.
    def section
      nil
    end
    
    # Returns nil.
    def doc_parent
      nil
    end
    
    # Returns an empty array.
    def ancestors
      []
    end
    
    def children
      root.children.select { |d| d.section === self }.sort_by { |e| e.name }
    end
    
    def descendants
      root.descendants.select { |d| d.section === self }.sort_by { |e| e.name }
    end
    
    # Returns "section".
    def type
      "section"
    end
  end
  
  class Method < Base
    def klass
      namespace
    end
    
    def ebnf_expressions
      ebnf.elements.map { |e| e.elements.last }
    end

    def klass_name
      ebnf_expressions.first.klass_name
    end

    def full_name
      ebnf_expressions.first.full_name
    end

    def name
      ebnf_expressions.first.name
    end

    def methodized?
      ebnf_expressions.first.methodized?
    end
    
    def namespace_string
      ebnf_expressions.first.namespace
    end
    
    def arguments
      args = argument_descriptions.elements
      args ? args.first.elements :  []
    end
    
    def signature
      ebnf_expressions.first.signature
    end
    
    def returns
      ebnf_expressions.first.returns
    end
    
    def fires
      events.empty? ? [] : events.to_a
    end
  end
  
  class Property < Base
    def klass
      namespace
    end
  end
  
  class KlassMethod < Method
    def klass
      namespace.is_a?(Klass) ? namespace : nil
    end
    
    def klass_name
      klass ? klass.name : nil
    end
    
    def type
      "class method"
    end
  end
  
  class Utility < Method
    def related_to
      if tags.include?("related to")
        namespace = tags.find { |tag| tag.name == "related to" }.value
        root.find_by_name(namespace)
      else
        nil
      end
    end
    
    def section
      if r = related_to
        r.section
      elsif tags.include?("section")
        value = tags.find { |tag| tag.name == "section" }.value
        root.sections.find { |s| s.name == value }
      else
        nil
      end
    end
    
    def type
      "utility"
    end
  end
  
  class InstanceMethod < Method
    def type
      "instance method"
    end
  end
  
  class Constructor < Method
    def namespace_string
      ebnf_expressions.first.namespace
    end
    
    def type
      "constructor"
    end
  end
  
  class KlassProperty < Property
    def type
      "class property"
    end
  end
  
  class InstanceProperty < Property
    def type
      "instance property"
    end
  end
  
  class Constant < Base
    def klass
      namespace.is_a?(Klass) ? namespace : nil
    end
    
    def klass_name
      klass ? klass.name : nil
    end
    
    def type
      "constant"
    end
  end
  
  class Namespace < Base
    def mixins
      ebnf.mixins.map { |m| root.find_by_name(m.full_name) }
    end
    
    def mixin?
      false
    end
    
    def klass?
      false
    end
    
    # Returns a sorted array of KlassProperty
    def klass_properties
      root.klass_properties.select { |e| e.namespace === self }.sort_by { |e| e.name }
    end

    # Returns a sorted array of KlassMethod
    def klass_methods
      root.klass_methods.select { |e| e.namespace === self }.sort_by { |e| e.name }
    end

    # Returns a sorted array of InstanceProperty
    def instance_properties
      root.instance_properties.select { |e| e.namespace === self }.sort_by { |e| e.name }
    end

    # Returns a sorted array of InstanceMethod
    def instance_methods
      root.instance_methods.select { |e| e.namespace === self }.sort_by { |e| e.name }
    end

    # Returns a sorted array of Constant
    def constants
      root.constants.select { |e| e.namespace === self }.sort_by { |e| e.name }
    end
    
    def all_methods
      klass_methods.concat(instance_methods).sort_by { |e| e.name }
    end
    
    def children
      root.descendants.select { |e| e.namespace === self }.sort_by { |e| e.name }
    end
    
    def related_utilities
      root.utilities.select { |e| e.related_to === self }.sort_by { |e| e.name }
    end
    
    def type
      "namespace"
    end
  end
  
  class Klass < Namespace
    def klass?
      true
    end
    
    def subklass?
      ebnf.subklass?
    end
    
    def superklass?
      !subklasses.empty?
    end
    
    def superklass
      subklass? ? root.find_by_name(ebnf.superklass.text_value) : nil
    end
    
    def subklasses
      root.klasses.select { |k| k.superklass === self }
    end
    
    def methodized_methods
      instance_methods.select { |e| e.methodized? }
    end
    
    def constructor
      root.constructors.find { |c| c.namespace === self }
    end
    
    def all_methods
      c = constructor 
      c ? (super << c).sort_by { |e| e.name } : super
    end
    
    def type
      "class"
    end
  end
  
  class Mixin < Namespace
    def mixin?
      true
    end
    
    def type
      "mixin"
    end
  end
end
