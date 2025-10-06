const defaultConfig = {
  container: null,
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

export function buildWaveSurferConfig(overrides = {}) {
  return { ...defaultConfig, ...overrides };
}

if (typeof window !== 'undefined') {
  window.buildWaveSurferConfig = buildWaveSurferConfig;
}
