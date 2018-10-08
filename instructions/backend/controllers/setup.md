## Controllers

<!--

###### test/test_helper.rb

```ruby
...

module ActionDispatch
  class IntegrationTest
    def get(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def post(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def patch(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def put(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def head(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def delete(path, obj = {})
      super(path, intercept_obj(obj))
    end

    private

    def intercept_obj(obj)
      obj[:params] = obj[:params].to_json if obj[:params]
      obj[:headers] = { 'CONTENT_TYPE' => 'application/json' }.merge(obj[:headers]) if obj[:headers]
      obj
    end
  end
end

```

-->

