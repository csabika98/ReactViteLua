local lapis = require("lapis")
local db = require("lapis.db")
local cjson = require("cjson")
local mongo = require("mongo")

local app = lapis.Application()
local client = mongo.Client("mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.2.6")
local mongo_db = client:getDatabase("my_database")
local collection = mongo_db:getCollection("my_collection")
app:enable("etlua")
app.layout = require "views.layout"



app:get("/", function(self)
  self.page_title = "Hello, World!"
  self.welcome_message = "Welcome to my dynamic Lapis page!"
  print("Page Title:", self.page_title)       -- Debugging statement
  print("Welcome Message:", self.welcome_message) -- Debugging statement
  return { render = "index" }
end)

app:get("/list", function(self)
  return { render = "list" }
end)

app:get("/basic", function(self)
  return { render = "basic" }
end)

app:get("/query", function(self)
  local res, err = db.query("select * from DATABASECHANGELOG")
  if not res then
    return { json = { error = err } }
  end
  self.results = res
  return { render = "query" }
end)

app:get("/mongo_query", function(self)
  local cursor = collection:find({})
  local results = {}
  for doc in cursor:iterator() do
    table.insert(results, doc)
  end
  self.results = results
  return { render = "mongo_query" }
end)


return app



