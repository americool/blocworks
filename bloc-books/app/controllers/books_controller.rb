class BooksController < BlocWorks::Controller
  def welcome
    @book = "Eloquent Ruby"
    render(:welcome)#, book: "Eloquent Ruby"
  end

  def index
    @books = Book.all
    render(:index)
  end

  def show
    # data = Rack::Request.new(@env)
    # id = data.params["id"].to_i
    id = params["id"].to_i
    @book = Book.find_one(id)
    render(:show)
  end
end
