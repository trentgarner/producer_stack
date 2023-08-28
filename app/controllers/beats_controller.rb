class BeatsController < ApplicationController

  def index
    @beats = beat.all
  end

end
