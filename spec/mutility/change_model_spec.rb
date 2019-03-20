describe Mutility do
  describe 'change model' do
    before :all do
      ActiveRecord::Migration.create_table :products do |t|
        t.float :price
        t.timestamps
      end

      ActiveRecord::Migration.create_table :product_differences do |t|
        t.integer :product_id
        t.float :price
        t.timestamps
      end

      class ProductDifference < ActiveRecord::Base
        belongs_to :product
      end

      class Product < ActiveRecord::Base
        include Mutility
        mutilize :price, change_model: ProductDifference
      end
    end

    after :all do
      ActiveRecord::Migration.drop_table :product_differences
      ActiveRecord::Migration.drop_table :products
    end

    let(:price_on_create) { 29.99 }

    let(:product) { Product.new price: price_on_create }

    let(:updated_price) { 24.99 }

    it 'should use a given change model if provided' do
      product.save
      expect { product.update price: updated_price }.to change { ProductDifference.count }.by(1)
    end
  end
end
