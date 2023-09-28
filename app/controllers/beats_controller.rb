class BeatsController < ApplicationController
  before_action :set_beat, only: [:show, :edit, :update, :destroy]
  before_action :validate_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @beats = Beat.all
  end

  def new
    @beat = Beat.new
  end

  def create
    @beat = current_user.beats.new(beat_params)
    if @beat.save
      redirect_to @beat, notice: 'Beat upload was successful!'
    else
      render :new, alert: 'Beat was not uploaded.'
    end
  end
  
  def show
  end  

  def edit
  end 

  def update
    @beat = Beat.find(params[:id])
    if @beat.update(beat_params)
      redirect_to @beat, notice: 'Beat was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @beat = Beat.find(params[:id])
    @beat.destroy
    redirect_to beats_path, notice: 'Beat was successfully removed.'
  end

  private

  def beat_params
    params.require(:beat).permit(:title, :artist, :genre, :description, :duration, :price,
                                 :license_type, :sample_rate, :bit_depth, :tags, :cover_art, :beat)
  end

  def set_beat
    @beat = Beat.find_by(id: params[:id])
    redirect_to beats_path, alert: 'Beat not found' if @beat.nil?
  end

  def validate_user
    unless @beat.user == current_user
      flash[:alert] = 'You are not authorized to perform this action.'
      redirect_to beats_path
    end
  end

end

