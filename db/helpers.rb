require 'pg'

def run_sql(sql, params = [])
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'project_2'})
    res = db.exec_params(sql, params)
    db.close
    return res
  end