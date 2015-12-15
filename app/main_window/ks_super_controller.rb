class KSSuperController

  def object_entry
    @subview = @layout.get :outer_view
    {"Title" => @title, "subview"=> @subview}
  end
end
