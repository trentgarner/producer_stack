class BeatsController < ApplicationController

  def index
    @beats = Beat.all
  end

end
