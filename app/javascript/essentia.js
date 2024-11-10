import { init } from 'essentia.js';

// Initialize Essentia
const essentia = init().then(() => {
  console.log('Essentia.js is ready');
});

// You can now use Essentia.js features
document.addEventListener("DOMContentLoaded", () => {
  const fileInput = document.getElementById("audio-file");

  fileInput.addEventListener("change", async (event) => {
    const file = event.target.files[0];
    if (file) {
      const arrayBuffer = await file.arrayBuffer();
      const audioContext = new AudioContext();
      const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);

      // Initialize Essentia
      const essentia = new Essentia(EssentiaWASM);

      // Perform analysis
      const channelData = audioBuffer.getChannelData(0); // Get first channel data
      const tempoResult = essentia.Tempo(channelData);

      console.log("Tempo:", tempoResult.tempo);
    }
  });
});
