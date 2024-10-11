const { app, BrowserWindow, Menu} = require("electron");
const AudioHandler = require("./src/main/audio");
const path = require('path');
let mainWindow;
const createWindow = async () => {
  mainWindow = new BrowserWindow({
    width: 250,
    height: 100,
    webPreferences:{
        nodeIntegration: false,
        contextIsolation: true,
        preload:  path.join(__dirname, 'preload.js')
    } 
  });
  await mainWindow.loadFile("src/renderer/index.html");
  // mainWindow.webContents.openDevTools();
}
app.whenReady().then(() => {
    createWindow();
    Menu.setApplicationMenu(null);
    new AudioHandler();
});3
app.on("window-all-closed", () => {
    if (process.platform != "darwin") 
        app.quit();
});

