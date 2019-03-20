describe Mutility do
  describe 'column mapping' do
    before :all do
      ActiveRecord::Migration.create_table :posts do |t|
        t.text :body
        t.integer :votes
        t.string :tag
        t.timestamps
      end

      ActiveRecord::Migration.create_table :post_changes do |t|
        t.integer :post_id
        t.text :body_was
        t.integer :votes_were
        t.string :tag
        t.timestamps
      end

      class PostChange < ActiveRecord::Base
        belongs_to :post
      end

      class Post < ActiveRecord::Base
        include Mutility
        mutilize :body, :votes, :tag, map_columns: { body: :body_was, votes: :votes_were }
      end
    end

    after :all do
      ActiveRecord::Migration.drop_table :post_changes
      ActiveRecord::Migration.drop_table :posts
    end

    let(:body_on_create) { 'Hello world!' }
    let(:votes_on_create) { 5 }
    let(:tag_on_create) { 'create' }

    let(:post) { Post.new body: body_on_create, votes: votes_on_create, tag: tag_on_create }

    let(:updated_body) { 'Hello update!' }
    let(:updated_votes) { 6 }
    let(:updated_tag) { 'update' }

    it 'should assign change columns with overridden mappings' do
      post.save
      post.update body: updated_body, votes: updated_votes, tag: updated_tag

      post_change = PostChange.find_by post: post
      expect(post_change.body_was).to eq(body_on_create)
      expect(post_change.votes_were).to eq(votes_on_create)
      expect(post_change.tag).to eq(tag_on_create)
    end
  end
end
