require 'bcrypt'
require 'pry' if development?
require 'pg'
# require_relative 'helpers.rb'

def create_user(params = [])
    password_digest = BCrypt::Password.create("#{params['password']}")
    sql = "INSERT INTO users (org_type, regulatory_authority, registration_num, org_name, individual_name, phone_num, email, password_digest) VALUES ($1, $2, $3, $4, $5, $6, $7, '#{password_digest}');"

    run_sql(sql,
    params['org_type'],
    params['regulatory_authority'],
    params['registration_num'],
    params['org_name'],
    params['individual_name'],
    params['phone_num'],
    params['email'],
    )
end