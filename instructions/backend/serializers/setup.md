## Serializers

<!-- perhaps move all this into the controller markdown -->

<!-- double check this is necessary, seems like it shouldn't be -->

```bash
$ mkdir app/serializers
```

###### config/application.rb

```ruby
...

module Backend
  class Application < Rails::Application
    ...

    # Added

    # Lazy load serializers
    config.autoload_paths += Dir[Rails.root.join('app/serializers/**/*')]
  end
end

```

<!-- should there be testing of these serializers? -->
<!-- probably, everything else is tested -->
<!-- next iteration do testing -->

#### Users

#### Subs

```bash
$ rails g serializer Super created_at updated_at
```

###### spec/serializers/super_serializer.rb

###### app/serializers/super_serializer.rb

```bash
$ mkdir app/serializers/models
```

##### Subs

```bash
$ mkdir app/serializers/models/subs
$ rails g serializer Sub name
$ mv app/serializers/sub_serializer.rb app/serializers/models
$ rails g serializer SubIndex
$ rails g serializer SubShow
$ rails g serializer SubCreate
$ mv app/serializers/sub_{index,show,create}_serializer.rb app/serializers/models/subs
```

###### spec/serializers/models/sub_serializer.rb

###### app/serializers/models/sub_serializer.rb

###### app/serializers/models/subs/sub_index_serializer.rb

###### app/serializers/models/subs/sub_show_serializer.rb

<!-- think about only keeping the default serializer and the index one -->

##### Posts

```bash
$ mkdir app/serializers/models/posts
$ rails g serializer Post title url body active
$ mv app/serializers/post_serializer.rb app/serializers/models
$ rails g serializer postIndex
$ mv app/serializers/post_index_serializer.rb app/serializers/models/posts
```

###### spec/serializers/models/post_serializer.rb

###### app/serializers/models/post_serializer.rb

###### app/serializers/models/posts/post_index_serializer.rb

##### Salts

```bash
$ mkdir app/serializers/models/salts
$ rails g serializer Salt salt_string
$ mv app/serializers/salt_serializer.rb app/serializers/models
$ rails g serializer saltShow
$ rails g serializer saltCreate
$ mv app/serializers/salt_{show,create}_serializer.rb app/serializers/models/salts
```

###### spec/serializers/models/salt_serializer.rb

###### app/serializers/models/salt_serializer.rb

###### app/serializers/models/salts/salt_show_serializer.rb

###### app/serializers/models/salts/salt_create_serializer.rb

##### Nonces

```bash
$ mkdir app/serializers/models/nonces
$ rails g serializer Nonce nonce_string expiration_at
$ mv app/serializers/nonce_serializer.rb app/serializers/models
$ rails g serializer nonceCreate
$ mv app/serializers/nonce_create_serializer.rb app/serializers/models/nonces
```

###### spec/serializers/models/nonce_serializer.rb

###### app/serializers/models/nonce_serializer.rb

###### app/serializers/models/nonces/nonce_create_serializer.rb

##### Sessions

```bash
$ mkdir app/serializers/models/sessions
$ rails g serializer Session session_string expiration_at
$ mv app/serializers/session_serializer.rb app/serializers/models
$ rails g serializer sessionCreate
$ mv app/serializers/session_create_serializer.rb app/serializers/models/sessions
```

###### spec/serializers/models/session_serializer.rb

###### app/serializers/models/session_serializer.rb

###### app/serializers/models/sessions/session_create_serializer.rb

##### Users

```bash
$ mkdir app/serializers/models/users
$ rails g serializer User name
$ mv app/serializers/user_serializer.rb app/serializers/models
$ rails g serializer userShow
$ mv app/serializers/user_show_serializer.rb app/serializers/models/users
```

###### spec/serializers/models/user_serializer.rb

###### app/serializers/models/user_serializer.rb

###### app/serializers/models/users/user_show_serializer.rb


