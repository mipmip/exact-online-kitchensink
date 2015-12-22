class ShowHidePrefsWindowController  < NSWindowController
  def layout
    @layout ||= ShowHidePrefsWindowLayout.new(@meta)
  end

  def init_with_meta(parent_object, meta)
    @meta = meta
    @parent_object = parent_object

    init

  end

  def updateSettings
    defaults = NSUserDefaults.standardUserDefaults
    @workingDir = defaults.stringForKey(RootPathKey)
    @url = defaults.stringForKey(UrlKey)
  end

  def init
    super.tap do
      self.window = layout.window
      prepare_views
    end
  end

  def close_window
    layout.window.close
  end

  def prepare_views

    @save_button = @layout.get(:save_button)
    @save_button.target = self
    @save_button.action = 'save_prefs'

    @cancel_button = @layout.get(:cancel_button)
    @cancel_button.target = self
    @cancel_button.action = 'close_window'

    @field_outlets = {}

    @meta['all_attributes'].each do | attr |
      @field_outlets[attr['name']] = @layout.get(attr['name'].to_sym)
    end

  end

  def save_prefs

    meta_assoc = {}
    @meta['all_attributes'].each do | attr |
      meta_assoc[attr['name']] = attr
    end

    data_to_save= {}
    @field_outlets.each do |k,f|
      if f.state.zero?
        data_to_save[k.underscore] = false
      else
        data_to_save[k.underscore] = true
      end
    end

    defaults = NSUserDefaults.standardUserDefaults
    defaults.setObject(data_to_save,forKey: "showhide_#{@meta['end_point']}")

    close_window

    @parent_object.reinit_table_columns

  end
end
