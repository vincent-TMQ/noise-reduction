# Rnnoise-Denoiser

Rnnoise-Denoiser is an Electron-based application that provides real-time noise suppression using the RNNoise algorithm. This application is designed to enhance audio quality by reducing background noise during voice communications or recordings.


## Installation

To install Rnnoise-Denoiser, follow these steps:

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/rnnoise-denoiser.git
   ```
2. Navigate to the project directory:
   ```
   cd rnnoise-denoiser
   ```
3. Install the dependencies:
   ```
   npm install
   ```

## Usage

To run the application in development mode:

```
npm start
```

This will start the Electron app, and you should see the application window open.

## Building the Application

To build the application for distribution:

```
npm run build
```

This command will create installable packages for your operating system. The output installers will be added to the `dist/` directory.

## VB-Cable Integration

This application uses VB-Cable for audio routing. The installer will attempt to install VB-Cable if it's not already present on your system. After installation, you may need to restart your computer to ensure VB-Cable is properly configured.

## Troubleshooting

If you encounter any issues:
1. Ensure all dependencies are correctly installed by running `npm install` again.
2. Check that VB-Cable is properly installed and configured in your system's audio settings.
3. If you're having trouble with the build process, make sure you have the necessary build tools for your operating system.

## Contributing

Contributions to Rnnoise-Denoiser are welcome. Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

If you have any questions or feedback, please open an issue in the GitHub repository.

Thank you for using Rnnoise-Denoiser!