class BooksController < Blocworks::Controller
  def welcome
    render :welcome, book: "Eloquent Ruby"
  end
end
