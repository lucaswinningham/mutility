# Mutility
Mutility is for keeping track of record changes. When attempting to do data science on a database, it can be difficult and even impossible to retrieve historical data unless the database tracks data changes. Mutility intends to keep a database lossless of updates to data.

## Usage
Suppose you have a `Comment` model with `body` and `tag` columns of which you would like to track changes. You'll need to create a change model to track `Comment` changes.

```bash
$ rails generate model comment_change comment_id:integer body:text tag:string
$ rails db:migrate
```

You don't want a foreign key constraint in the `CommentChange` table such that you are still able to delete a `Comment` and retain its changes. Due to this, you'll have to manually assign the `Comment` association to your `CommentChange` model. Mutility uses this association to assign the foreign key.

##### app/models/comment_change.rb

```ruby
class CommentChange < ApplicationRecord
  belongs_to :comment
end

```

Now you can include Mutility in the `Comment` model to track changes to the `body` and `tag` columns.

##### app/models/comment.rb

```ruby
class Comment < ApplicationRecord
  include Mutility
  mutilize :body, :tag

  ...
end

```

Mutility will now track changes to the `Comment` model.

```bash
$ rails console
> comment = Comment.create body: 'some comment', tag: 'super cool'
> CommentChange.count
=> 0
> comment.update body: 'changed my mind'
> CommentChange.count
=> 1
> CommentChange.last
=> #<CommentChange id: 1, body: "some comment", tag: "super cool", created_at: "...", updated_at: "...">
> comment.update tag: 'not really that cool'
> CommentChange.count
=> 2
> CommentChange.last
=> #<CommentChange id: 2, body: "changed my mind", tag: "super cool", created_at: "...", updated_at: "...">
```

The change model can configured if you don't want the suffix `Change` for your models.

##### app/models/comment.rb

```ruby
class Comment < ApplicationRecord
  include Mutility
  mutilize :body, :tag, change_model: CommentDifference

  ...
end

```

The columns in your source model can be mapped to columns with different names in your change model.

##### app/models/comment.rb

```ruby
class Comment < ApplicationRecord
  include Mutility
  mutilize :body, :tag, map_columns: { body: :body_was }

  ...
end

```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'mutility'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install mutility
```

<!-- ## Contributing -->
<!-- Contribution directions go here. -->

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
