class BooksController < BlocWorks::Controller
  def welcome
    @book = "Eloquent Ruby"
    render(:welcome)#, book: "Eloquent Ruby"
  end

  def index
    @books = Book.all
    render(:index)
  end

  # def show
  #   # data = Rack::Request.new(@env)
  #   # id = data.params["id"].to_i
  #   id = params["id"].to_i
  #   @book = Book.find_one(id)
  #   render(:show)
  # end

  def show
    id = params['id'].to_i
    # if id < 1 || id.nil?
    #   redirect action: 'error', message: 'Invalid ID'
    # end
     book = Book.find(id)
     render :show, book: book
  end

  def display
    redirect  action: show, id: params['id']
  end

  def amazon
    redirect 'https://www.amazon.com/'
  end

  # /books/error
  def error
    redirect '/error'
  end
end

# /books/1/display
# /books/1/show
