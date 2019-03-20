describe Mutility do
  describe 'core' do
    before :all do
      ActiveRecord::Migration.create_table :comments do |t|
        t.string :name
        t.integer :age, null: false
        t.boolean :is_tall
        t.timestamps
      end

      ActiveRecord::Migration.create_table :comment_changes do |t|
        t.integer :comment_id
        t.string :name
        t.integer :age
        t.boolean :is_tall
        t.timestamps
      end

      class CommentChange < ActiveRecord::Base
        belongs_to :comment
      end

      class Comment < ActiveRecord::Base
        include Mutility
        mutilize :name, :age, :is_tall

        validates :name, presence: true, allow_blank: false
      end
    end

    after :all do
      ActiveRecord::Migration.drop_table :comment_changes
      ActiveRecord::Migration.drop_table :comments
    end

    let(:name_on_create) { 'Lucas' }
    let(:age_on_create) { 26 }
    let(:is_tall_on_create) { true }

    let(:comment) do
      Comment.new name: name_on_create, age: age_on_create, is_tall: is_tall_on_create
    end

    let(:updated_name) { 'Luke' }
    let(:updated_age) { 27 }

    it 'does not create change record on insert' do
      expect { comment.save }.to change { CommentChange.count }.by(0)
    end

    it 'does not create change record on update if no changes' do
      comment.save
      expect { comment.update comment.attributes }.to change { CommentChange.count }.by(0)
    end

    context 'when unsuccessful update' do
      it 'does not create change record due to active record validation failure' do
        comment.save
        expect { comment.update name: '' }.to change { CommentChange.count }.by(0)
      end

      it 'does not create change record due to database constraints' do
        comment.save
        expect { comment.update age: nil }.to(
          raise_error(ActiveRecord::NotNullViolation).and(change { CommentChange.count }.by(0))
        )
      end
    end

    it 'creates change record on update' do
      comment.save
      expect { comment.update name: updated_name }.to change { CommentChange.count }.by(1)
    end

    it 'creates change record with old attributes on update' do
      comment.save
      comment.update name: updated_name, age: updated_age

      comment_change = CommentChange.find_by comment: comment
      expect(comment_change.name).to eq(name_on_create)
      expect(comment_change.age).to eq(age_on_create)
      expect(comment_change.is_tall).to eq(is_tall_on_create)
    end
  end
end
