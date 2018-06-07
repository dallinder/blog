require 'pg'

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
    sql = "INSERT INTO posts(post, name, period) VALUES ($1, $2, $3)"

    query(sql, post_info, post_name, period)
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
end