const { ipcMain } = require("electron");
const { RNNoiseDenoiser, FRAME_SIZE } = require("../services/rnnoise");
const fs = require('fs');
const path = require('path');
const portAudio = require('naudiodon');

class AudioHandler {
    constructor() {
        this.denoiser = new RNNoiseDenoiser();
        this.virtualDeviceIndex = this.findVirtualDevice();
        this.ai = new portAudio.AudioIO({
            inOptions: {
              channelCount: 1,
              sampleFormat: portAudio.SampleFormat16Bit,
              sampleRate: 48000,
              deviceId: -1, 
              closeOnError: false
            }
        });
        this.ao = new portAudio.AudioIO({
            outOptions: {
              channelCount: 1,
              sampleFormat: portAudio.SampleFormat16Bit,
              sampleRate: 48000,
              deviceId: this.virtualDeviceIndex,
              closeOnError: false
            }
        });
        this.listen();
        this.start();
        this.audioInputBuffer = Buffer.alloc(0);
        this.inputFilePath = path.join(__dirname, 'input.pcm');
        this.outputFilePath = path.join(__dirname, 'output.pcm');
        this.inputFileStream = fs.createWriteStream(this.inputFilePath);
        this.outputFileStream = fs.createWriteStream(this.outputFilePath);
        this.denoiseOn = false;
    }
    findVirtualDevice(){
        const devices = portAudio.getDevices();
        const virtualCableIndex = devices.findIndex(device => 
            device.name.includes('CABLE Input') && device.maxOutputChannels > 0
        );

        if (virtualCableIndex === -1) {
            console.error('VirtualCable output device not found');
            process.exit(1);
        }
        return virtualCableIndex;
    }
    start() {
        this.ai.start();
        this.ao.start();
    }
    listen() {
        ipcMain.on('status', (event, data) => {
            if(data){
                this.denoiseOn = true;
            }else{
                this.denoiseOn = false;
            }
        })
        this.ai.on('data', (chunk) => {
            if(this.denoiseOn){
                this.processAudioChunk(chunk);
            }else{
                this.audioInputBuffer = Buffer.alloc(0);
                this.ao.write(chunk);
            }
        });
    }
    processAudioChunk(chunk) {
        this.audioInputBuffer = Buffer.concat([this.audioInputBuffer, chunk]);

        while (this.audioInputBuffer.length >= FRAME_SIZE * 2) {
            const frameBuffer = this.audioInputBuffer.slice(0, FRAME_SIZE * 2);
            this.audioInputBuffer = this.audioInputBuffer.slice(FRAME_SIZE * 2);

            this.writeInputToFile(frameBuffer);

            const denoiseChunk = this.denoiser.denoiseChunk(frameBuffer);

            this.writeOutputToFile(denoiseChunk);
            this.ao.write(denoiseChunk);
           
        }
    }

    writeInputToFile(inputChunk) {
        this.inputFileStream.write(inputChunk);
    }
    writeOutputToFile(denoiseChunk) {
        const buffer = Buffer.from(denoiseChunk.buffer);
        this.outputFileStream.write(buffer);
    }

    stop() {
        this.denoiser.close();
        if (this.inputFileStream) {
            this.inputFileStream.end();
        }
        if (this.outputFileStream) {
            this.outputFileStream.end();
        }
        this.ai.quit(); 
        this.ao.quit();
    }
}

module.exports = AudioHandler;