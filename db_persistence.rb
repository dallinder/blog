require 'pg'
require 'date'
require 'time'

class Database
	def initialize(logger)
		@db = if Sinatra::Base.production?
						 PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "blog")
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def add_post(post_info, post_name, period)
    sql = "INSERT INTO posts(post, name, period, post_time) VALUES ($1, $2, $3, $4)"
    time = DateTime.now.strftime("%H:%M")

    query(sql, post_info, post_name, period, time)
  end

  def get_all_posts(period)
    sql = "SELECT * FROM posts WHERE period = $1"

    result = query(sql, period)

    result.map do |tuple|
      { id: tuple["id"], name: tuple['name'], period: tuple['period'], post: tuple['post'],
        post_date: tuple["post_date"], post_time: tuple["post_time"] }
    end
  end

  def delete_post(id)
    sql = "DELETE FROM posts WHERE id = $1"

    query(sql, id);
  end

  def get_user(user)
    sql = "SELECT * FROM users WHERE (username = $1)"

    result = query(sql, user)

    result.map do |tuple|
      { username: tuple['username'], password: tuple['password']}
    end
  end

  def check_number_users
    sql = "SELECT count(*) AS exact_count FROM users"

    result = query(sql)

    result.map do |tuple|
      { number_of_users: tuple['exact_count']}
    end
  end

  def add_user(user, pass)
    sql = "INSERT INTO users(username, password) VALUES ($1, $2)"

    query(sql, user, pass)
  end
end