require "test_helper"

module Mastering
  class SoxMasteringServiceTest < ActiveSupport::TestCase
    setup do
      @service = SoxMasteringService.new
      @tempfile = Tempfile.new(["producer_stack_test", ".wav"])
      @tempfile.write("test")
      @tempfile.flush
    end

    teardown do
      @tempfile.close!
    end

    test "raises error when SoX is missing" do
      original_command_available = @service.method(:command_available?)
      @service.singleton_class.send(:define_method, :command_available?) { |_cmd| false }

      assert_raises(SoxMasteringService::MissingDependencyError) do
        @service.process(@tempfile.path, original_filename: "test.wav")
      end
    ensure
      @service.singleton_class.send(:define_method, :command_available?, original_command_available)
    end

    test "returns result when processing succeeds" do
      fake_status = Struct.new(:success?).new(true)

      original_command_available = @service.method(:command_available?)
      original_gather_details = @service.method(:gather_details)

      @service.singleton_class.send(:define_method, :command_available?) { |_cmd| true }
      @service.singleton_class.send(:define_method, :gather_details) { |_path| {} }

      original_capture3 = Open3.method(:capture3)
      Open3.singleton_class.send(:define_method, :capture3) do |*args|
        if args.first == 'sox' && args.include?('-b')
          output_index = args.index('-b') + 2
          File.write(args[output_index], 'audio data')
        end
        ['', '', fake_status]
      end

      result = @service.process(@tempfile.path, original_filename: "Test Mix.wav")

      assert_instance_of SoxMasteringService::Result, result
      assert File.exist?(result.output_path)
      assert_match %r{^/mastered/}, result.public_url
    ensure
      FileUtils.rm_f(Dir[Rails.root.join('public', 'mastered', '*')])
      @service.singleton_class.send(:define_method, :command_available?, original_command_available)
      @service.singleton_class.send(:define_method, :gather_details, original_gather_details)
      Open3.singleton_class.send(:define_method, :capture3, original_capture3)
    end

    test "supports additional presets" do
      fake_status = Struct.new(:success?).new(true)
      original_command_available = @service.method(:command_available?)
      original_gather_details = @service.method(:gather_details)

      @service.singleton_class.send(:define_method, :command_available?) { |_cmd| true }
      @service.singleton_class.send(:define_method, :gather_details) { |_path| {} }

      captured_args = nil
      original_capture3 = Open3.method(:capture3)
      Open3.singleton_class.send(:define_method, :capture3) do |*args|
        if args.first == 'sox' && args.include?('-b')
          captured_args = args.dup
          output_index = args.index('-b') + 2
          File.write(args[output_index], 'audio data')
        end
        ['', '', fake_status]
      end

      result = @service.process(@tempfile.path, original_filename: "Test Mix.wav", preset: :lofi)

      assert_instance_of SoxMasteringService::Result, result
      assert_not_nil captured_args
      assert_includes captured_args, 'lowpass'
      assert_includes captured_args, 'contrast'
    ensure
      FileUtils.rm_f(Dir[Rails.root.join('public', 'mastered', '*')])
      @service.singleton_class.send(:define_method, :command_available?, original_command_available)
      @service.singleton_class.send(:define_method, :gather_details, original_gather_details)
      Open3.singleton_class.send(:define_method, :capture3, original_capture3)
    end
  end
end
