require "sinatra"
require "active_record"

set :bind, "0.0.0.0"
set :port, 8000
set :server, :puma

DB_PATH = File.expand_path("db/bbs.sqlite3", __dir__)

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: DB_PATH
)

unless ActiveRecord::Base.connection.data_source_exists?("posts")
  ActiveRecord::Schema.define do
    create_table :posts do |t|
      t.string :name, null: false
      t.text :body, null: false
      t.integer :parent_id
      t.timestamps
    end

    add_index :posts, :parent_id
    add_index :posts, :created_at
  end
end

class Post < ActiveRecord::Base
  belongs_to :parent, class_name: "Post", optional: true
  has_many :replies, class_name: "Post", foreign_key: "parent_id", dependent: :delete_all

  scope :roots, -> { where(parent_id: nil).order(created_at: :desc) }
  scope :children_oldest_first, -> { order(created_at: :asc) }

  validates :name, presence: true, length: { maximum: 30 }
  validates :body, presence: true, length: { maximum: 500 }
end

helpers do
  def esc(text)
    Rack::Utils.escape_html(text.to_s)
  end
end

get "/" do
  @posts = Post.roots.includes(:replies)
  erb :index
end

post "/posts" do
  name = params[:name].to_s.strip
  body = params[:body].to_s.strip
  parent_id = params[:parent_id].to_s.strip

  name = "匿名" if name.empty?
  parent = parent_id.empty? ? nil : Post.find_by(id: parent_id)
  post = Post.new(name: name, body: body, parent: parent)

  if post.save
    redirect "/"
  else
    halt 400, "投稿に失敗しました: #{post.errors.full_messages.join(', ')}"
  end
end
