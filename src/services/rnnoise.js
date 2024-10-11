const path = require('path');
const { app } = require('electron');

function getAddonPath() {
    if (app.isPackaged) {
        return path.join(process.resourcesPath, 'rnnoise.node');
    } else {
        return path.join(__dirname, '..','..', 'build', 'Release', 'rnnoise.node');
    }
}

const addonPath = getAddonPath();
console.log('Loading addon from:', addonPath); 

const RNNoise = require(addonPath);

const FRAME_SIZE = 480;
// const RNNoise = require("../build/Release/rnnoise.node");
// const FRAME_SIZE = 480;

class RNNoiseDenoiser {
    constructor() {
        this.denoiser = new RNNoise.RNNoiseWrapper();
    }

    denoiseChunk(audioBuffer) {
        if (audioBuffer.length !== FRAME_SIZE * 2) {
            throw new Error(`Audio chunk must have ${FRAME_SIZE} samples`);
        }
        const inputFrame = new Float32Array(FRAME_SIZE);
        for (let i = 0; i < FRAME_SIZE; i++) {
            inputFrame[i] = audioBuffer.readInt16LE(i * 2);
        }
        this.denoiser.processFrame(inputFrame);
        const outputBuffer = Buffer.alloc(FRAME_SIZE * 2);
        for (let i = 0; i < FRAME_SIZE; i++) {
            outputBuffer.writeInt16LE(Math.max(-32768, Math.min(32767, Math.round(inputFrame[i]))), i * 2);
        }
        return outputBuffer;
    }

    close() {
        this.denoiser.close();
    }
}

module.exports = { RNNoiseDenoiser, FRAME_SIZE };