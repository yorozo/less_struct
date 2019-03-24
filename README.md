# LessStruct - less open OpenStruct

Unlike OpenStruct, LessStruct raises NoMethodError when you try to read un-assigned attributes, and that leads to less bugs in your code. Plus, LessStruct supports ease-of-use data caching on Redis.

```ruby
less_struct = LessStruct.new(a: 1)
# instantiate class just like OpenStruct

less_struct.a # => 1 # obviously it is readable
less_struct.b # => raises NoMethodError
less_struct.b = 2
less_struct.b # => 2 # now it is readable after assignment

less_struct.add(c: 3, d: 4) # multiple assignment
less_struct.c # => 3
less_struct.d # => 4
less_struct.to_h
# => {"a"=>1, "b"=>2, "c"=>3, "d"=>4}

less_struct.del(:b, :d) # multiple deletion
less_struct.to_h
# => {"a"=>1, "c"=>3}

less_struct.optional.e # => nil
# with "optional" notation it behaves just like OpenStruct
# so in this case, it returns nil for un-assigned attributes

less_struct.optional.e ||= 5
less_struct.optional.e ||= 50
# typical initializing assignment case with "optional" notation
less_struct.to_h
# => {"a"=>1, "c"=>3, "e"=>5}

LessStruct.use_to_h_with_symbol_key_y = true
# set this true if you want "to_h" method to return Hash instance with symbol key
less_struct.to_h
# => {:a=>1, :c=>3, :e=>5}

```

And Redis data caching works like this.

```ruby
class UserCache < LessStruct::Entity::Redis
  def self.config_redis_duration
    60 * 60 * 3 # 3 hours (time in seconds)
  end
end
# define your own class that inherits base class for config and class-based namespacing in Redis

data = { name: "Eren Yeager", age: 19, active_y: true }
# some data from external api or heavy calculation
user_cache = UserCache.new(data).save
# create/update cache with "save" method

id = user_cache.id
# => "1550156891197_d8b85a43"
# "id" is auto assigned if not given

user_found = UserCache.find(id)
user_found.to_h
# => {"name"=>"Eren Yeager", "age"=>19, "active_y"=>true,
# "redis_duration"=>10800, "redis_set_at"=>2019-02-14 15:08:11 UTC, "redis_end_at"=>2019-02-14 18:08:11 UTC,
# "kind"=>"less.user_cache", "id"=>"1550156891197_d8b85a43"}
#
# meta info such as "redis_end_at" can be disabled with config

UserCache.delete(id)
# deletes the data on Redis

UserCache.clear
# deletes all data of the same kind

```
To customize config, inherit base class (LessStruct::Entity::Redis) and override class methods. Default config in base class is as follows.

```ruby
class LessStruct
  module Entity
    class Redis
      def self.config_entity_kind
        nil
      end
      # If nil is set, snakecase-like class name is used as entity's kind.
      # e.g. SomeModule::SomeClass -> "some_module.some_class"

      def self.config_entity_kind_prefix
        "less"
      end
      # resulting entity's kind will be like "less.some_module.some_class"
      # Set nil if prefix is not needed.

      def self.config_entity_id_auto_y
        true
      end
      # Set false if you don't need auto-setting of entity's id.

      def self.config_redis_duration
        60 * 60 * 1
      end
      # Set any integer as time (seconds). Setting this 0 means "no expiration".

      def self.config_redis_meta_info_y
        true
      end
      # Set false if you don't want add meta info such as redis_duration and redis_end_at.

      def self.config_redis_format_json_y
        false
      end
      # If your data contains just simple types such as String, Integer and boolean,
      # using Json as Redis store format might be a possible choice.
    end
  end
end
```

## Redis connection

Set ENV["LESS_STRUCT_REDIS_URL"] or Redis.current will be used as default Redis connection.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'less_struct'
```

And then execute: $ bundle

Or install it yourself as:

    $ gem install less_struct


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yorozo/less_struct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

