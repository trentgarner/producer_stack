class MasteringController < ApplicationController
  before_action :authenticate_user!

  def index; end

  def upload
    file = params[:audio_file]
    preset = params[:preset].presence&.to_sym || :standard

    unless file.present?
      flash[:error] = 'No audio file uploaded.'
      return redirect_to mastering_index_path
    end

    tempfile = Tempfile.new(['producer_stack_master', File.extname(file.original_filename)])
    tempfile.binmode
    tempfile.write(file.read)
    tempfile.flush

    service = mastering_service_class.new
    result = service.process(tempfile.path, original_filename: file.original_filename, preset: preset)

    @mastering_result = result
    flash.now[:notice] = 'Mastered track is ready! Download below.'
    render :index
  rescue Mastering::SoxMasteringService::MissingDependencyError => e
    flash[:error] = e.message
    redirect_to mastering_index_path
  rescue Mastering::SoxMasteringService::ProcessingError => e
    Rails.logger.error("Mastering failed: #{e.message}")
    flash[:error] = 'We could not master this file. Please try another track.'
    redirect_to mastering_index_path
  ensure
    tempfile.close! if tempfile
  end

  private

  def mastering_service_class
    Mastering::SoxMasteringService
  end
end
