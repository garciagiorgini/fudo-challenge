# product_store.rb
class ProductStore
  @@products = {}
  @@next_id = 1
  class << self
    def add_async(name)
      id = @@next_id
      @@next_id += 1
      Thread.new do
      sleep 5
      @@products[id] = { id: id, name: name }
    end
    id
  end

    def all
      @@products.values
    end

    def clear
    @@products.clear
    @@next_id = 1
  end

    def find(id)
      @@products[id]
    end

    def delete(id)
      @@products.delete(id)
    end
  end
end
  