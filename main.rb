require 'sinatra' 
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'bcrypt'
require_relative "db/helpers.rb"

enable :sessions

# **********
def current_user
  if session[:user_id] == nil
    return{}
  end
  run_sql("SELECT * FROM users WHERE id = #{session[:user_id]};")[0]
end

def logged_in?
  !!session[:user_id]
end

def existing_user?
  res = run_sql("SELECT * FROM users WHERE email = $1;", [params['email']])
  if res == nil
    return true
  else
    return false
  end
end

def org_type
  if session[:org_type].start_with?("N")
    return "consumer"
  else
    return "supplier"
  end
end

# **********


get '/' do
  erb :index
end

get '/main' do
  redirect '/login' unless logged_in?
  erb :main
end

get '/items' do
  redirect '/login' unless logged_in?
  res = run_sql("SELECT * FROM supplier_items")
  if res.count < 1
    redirect'/main'
  else
    supplier_list = res[0]
    erb :items_consumer, locals: {supplier_list: supplier_list}
  end

  # if org_type == 'supplier'
  #   res = run_sql("SELECT * FROM supplier_items WHERE org_name = #{session[:org_id]};")
  #   if res.count = 0 
  #     redirect '/main'
  #   else
  #   supplier_list = res[0]
  #   erb :items_supplier, locals: {supplier_list: supplier_list}
  #   end
  # else
  #   if res.count < 1 
  #     redirect '/main'
  #   else
  #     res = run_sql("SELECT * FROM supplier_items")
  #     supplier_list = res[0]
  #     erb :items_consumer, locals: {supplier_list: supplier_list}
  #   end
  # end

end

get '/items/new' do
  redirect '/login' unless logged_in?
  erb :new_item_form
end

post '/items' do
  redirect '/login' unless logged_in?
  sql = "INSERT INTO supplier_items (user_id, supplier, org_id, manufacturer, item_name, manufacturer_ref_num, quantity, item_type, item_desc, item_url, item_expiry_date, date_available_from, date_available_to, storage_location, storage_req, requester_user_id, requester_org_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, '0', '0');"
  run_sql(sql, [
    current_user()['id'], # same as session[:user_id]
    current_user()['org_name'],
    current_user()['org_id'],
    params['manufacturer'],
    params['item_name'],
    params['manufacturer_ref_num'],
    params['quantity'],
    params['item_type'],
    params['item_desc'],
    params['item_url'],
    params['item_expiry_date'],
    params['date_available_from'],
    params['date_available_to'],
    params['storage_location'],
    params['storage_req'],
  ])
  redirect "/items"
end


patch '/items/request/:id' do  #*************
  redirect '/login' unless logged_in?
  sql = "UPDATE supplier_items SET requester_user_id = #{current_user()['id']}, requester_org_id = #{current_user()['org_id']} WHERE  id = $1;"

  run_sql(sql,
    params['id'],
  )
  redirect "/items"
end

get '/items/:id' do
  redirect '/login' unless logged_in?
  if org_type == "supplier"
    res = run_sql("SELECT * FROM supplier_items WHERE id = $1, org_id = $2;", [params['id']], current_user()['org_id'])
    item = res[0]
    erb :show_item, locals: { item: item }
  end
  res = run_sql("SELECT * FROM supplier_items WHERE id = $1;", [params['id']])
  item = res[0]
  erb :show_item, locals: { item: item }

end

delete '/items/:id' do
  redirect '/login' unless logged_in?
  run_sql("DELETE FROM supplier_items WHERE id = $1;", [params['id']])
  redirect "/items/#{current_user()['id']}"
end

get '/items/:id/edit' do
  res = run_sql("SELECT * FROM supplier_items WHERE id = #{params['id']}")
  item = res[0]
  erb :edit_item_form, locals: { item: item }
end

patch '/items/:id' do
  sql = "UPDATE supplier_items SET user_id = $1, manufacturer = $2, item_name = $3, manufacturer_ref_num = $4, quantity = $5, item_type = $6, item_desc = $7, item_url = $8, item_expiry_date = $9, date_available_from = $10, date_available_to = $11, storage_location = $12, storage_req = $13 WHERE id = $14;"

  run_sql(sql, 
    current_user()['id'],
    params['manufacturer'],
    params['item_name'],
    params['manufacturer_ref_num'],
    params['quantity'],
    params['item_type'],
    params['item_desc'],
    params['item_url'],
    params['item_expiry_date'],
    params['date_available_from'],
    params['date_available_to'],
    params['storage_location'],
    params['storage_req'],
  )

  redirect "/items/#{current_user()['id']}"
end

# *********
get '/login/new' do
  erb :new_user_form
end

post '/login' do
  password_digest = BCrypt::Password.create("#{params['password']}")
  sql = "INSERT INTO users (email, password_digest) VALUES ($1, $2);"
  run_sql(sql, 
    params['email'],
    params['password']
    )

  # sql = "INSERT INTO users (org_type, regulatory_authority, registration_num, org_name, individual_name, phone_num, email, password_digest) VALUES ($1, $2, $3, $4, $5, $6, $7, '#{password_digest}');"

  # run_sql(sql,
  #   params['org_type'],
  #   params['regulatory_authority'],
  #   params['registration_num'],
  #   params['org_name'],
  #   params['individual_name'],
  #   params['phone_num'],
  #   params['email'],
  # )
  redirect '/login'
end

get '/login' do
  erb :login
end

post '/session' do
  records = run_sql("SELECT * FROM users WHERE email = $1;", [params['email']])
  if records.count > 0
  # if records.count > 0 && BCrypt::Password.new(records[0]['password_digest']) == params['password']
    logged_in_user = records[0]
    session[:user_id] = logged_in_user["id"]
    session[:org_type] = logged_in_user["org_type"]
    session[:org_id] = logged_in_user["org_id"]
    redirect '/main'
  else
    erb :login
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect '/'
end