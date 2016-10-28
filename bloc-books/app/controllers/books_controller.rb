class BooksController < BlocWorks::Controller
  def welcome
    @book = "Eloquent Ruby"
    render(:welcome)#, book: "Eloquent Ruby"
  end
end
