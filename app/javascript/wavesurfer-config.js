

// Define your Wavesurfer configuration
const wavesurferConfig = {
  container: 'body',
  height: 74,
  splitChannels: false,
  normalize: true,
  waveColor: '#bcb9b8',
  progressColor: '#f24545',
  cursorColor: '#212529',
  cursorWidth: 3,
  barWidth: 3,
  barGap: null,
  barRadius: null,
  barHeight: null,
  barAlign: '',
  minPxPerSec: 1,
  fillParent: true,
  url: '/wavesurfer-code/examples/audio/audio.wav',
  mediaControls: true,
  autoplay: false,
  interact: true,
  dragToSeek: true,
  hideScrollbar: true,
  audioRate: 1,
  autoScroll: true,
  autoCenter: true,
  sampleRate: 48000
};

// Initialize Wavesurfer with the configuration
const wavesurfer = WaveSurfer.create(wavesurferConfig);

// Load your audio file
wavesurfer.load(wavesurferConfig.url);
