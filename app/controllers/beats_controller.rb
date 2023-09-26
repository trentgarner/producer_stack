class BeatsController < ApplicationController

  def index
    @beats = Beat.all
  end

  def new
    @beat = Beat.new
  end

  def create
    @beat = Beat.new(beat_params)
    @beat.beat_content_type = params[:beat][:beat].content_type  # Set content type
  
    puts "Beat Content Type: #{@beat.beat_content_type}" 
  
    if @beat.save
      redirect_to @beat, notice: 'Beat upload was successful!'
    else
      render :new, alert: 'Beat was not uploaded.'
    end
  end

  def stream_audio
    @beat = Beat.find(params[:id])
    send_file @beat.beat.path, type: @beat.beat_content_type
  end  
  
  def show
    @beat = Beat.find(params[:id])
    puts @beat.inspect
  end  

  private

  def beat_params
    params.require(:beat).permit(
      :title, :artist, :genre, :description, :duration, :price, :license_type,
      :sample_rate, :bit_depth, :tags, :cover_art, :beat
    )
  end

end
