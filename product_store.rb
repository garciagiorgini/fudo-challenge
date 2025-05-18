# product_store.rb
class ProductStore
    def initialize
      @products = {}
      @next_id = 1
    end
  
    def add_async(name)
      id = @next_id
      @next_id += 1
      Thread.new do
        sleep 5
        @products[id] = { id: id, name: name }
      end
      id
    end
  
    def all
      @products.values
    end
  end
  