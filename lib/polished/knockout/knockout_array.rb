# This class is used internally and you shouldn't need to initialize it
# yourself or worry too much whether an array is a standard array or a
# KnockoutArray
#
# It's essentially a wrapper around KO's observableArray
# http://knockoutjs.com/documentation/observableArrays.html
class KnockoutArray < Array
  # NOTE: this method has to be run right after a KnockoutArray is first
  # initialized
  def to_n
    array_value = super
    
    @ko_observable = `ko.observableArray(array_value)`
    
    @ko_observable
  end
  
  def to_json
    `ko.toJSON(#{@ko_observable})`
  end
  
  def serialize_js_data
    `ko.toJS(#{@ko_observable})`
  end
  
  def set_collection_class(class_name, collection_parent)
    @collection_class_name = class_name if class_name
    @collection_parent = collection_parent
  end
  
  def collection_check(obj)
    if @collection_class_name and obj.is_a?(Hash)
      Kernel.const_get(@collection_class_name).new_via_collection(obj, @collection_parent)
    else
      obj
    end
  end
  
  def concat(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
    end

    other.each do |item|
      self.send('<<', item)
    end

    self
  end
  
  def <<(obj)
    obj = collection_check(obj)
    
    ret = super(obj)
    
    `self.ko_observable.push(obj.$to_n())`
    
    ret
  end
  
  def unshift(obj)
    obj = collection_check(obj)
    
    ret = super(obj)
    
    `self.ko_observable.unshift(obj.$to_n())`
    
    ret
  end
  
  def slice!(index, length=1)
    ret = super(index, length)
    
    unless ret == nil
      `self.ko_observable.splice(index, length)`
    end
    
    ret
  end
  
  def delete_at(index)
    ret = super(index)
    
    unless ret == nil
      `self.ko_observable.splice(index, 1)`
    end
    
    ret
  end
  
  def delete(obj)
    obj_index = index(obj)
    ret = nil
    
    unless obj_index == nil
      ret = super(obj)
      `self.ko_observable.splice(obj_index, 1)`
    end
    
    ret
  end
  
  def clear()
    ret = super
    
    `self.ko_observable.removeAll()`
    
    ret
  end
end