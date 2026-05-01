# 📡 Signals and Systems Projects

Welcome to my **Signals and Systems** repository! This repository contains the MATLAB implementations for five comprehensive computer assignments from the Signals and Systems course. 

The projects bridge the gap between theoretical concepts and real-world applications, covering topics such as signal processing, image processing, digital communications, steganography, and machine learning.

---

## 🛠️ Tech Stack
* **Language/Environment:** MATLAB
* **Key Domains:** Signal Processing, Image & Video Processing, Digital Communications, Machine Learning

---

## 📂 Projects Overview

### 1️⃣ Project 1: MATLAB Fundamentals & Radar Ranging
This project focuses on the basics of MATLAB and its application in practical signal processing scenarios.
* **MATLAB Basics:** Implementation of scalar, vector, and matrix operations, along with plotting continuous and discrete sinusoidal functions.
* **Parameter Estimation:** Extracting linear relationship parameters ($y = \alpha x + \beta$) using cost function minimization in both ideal and noisy environments.
* **Radar Distance Estimation:** Determining the distance of an object from a radar by utilizing cross-correlation and template matching to find the time delay of returned noisy signals.

### 2️⃣ Project 2: Automatic Number Plate Recognition (ANPR) & Speed Estimation
A deep dive into image and video processing to extract meaningful data from vehicles.
* **Custom Image Processing:** Converting RGB images to grayscale, applying binary thresholding, and removing small noise artifacts without relying on built-in high-level MATLAB functions (e.g., bypassing `bwlabel` and `bwareaopen`).
* **English & Persian ANPR:** Segmenting license plate characters and recognizing them via template matching/correlation against customized databases for both English and Persian characters.
* **Video Processing:** Estimating the average speed of a moving vehicle by analyzing a recorded video sequence.

### 3️⃣ Project 3: Image Steganography & Object Tracking
Exploring data hiding techniques and dynamic video tracking algorithms.
* **Steganography:** Encoding a 32-character English message (using 5 bits per character) into the Least Significant Bits (LSB) of specific 5x5 pixel blocks within a grayscale image.
* **Decoding & Noise Analysis:** Extracting the hidden text from the modified image and evaluating the robustness of this steganography method against channel noise.
* **Custom Object Tracking:** Developing a script (`myTracker.m`) to track a moving airplane in an Infrared (IR) video, featuring a dynamic bounding box that automatically resizes as the object approaches the camera.

### 4️⃣ Project 4: Amplitude Coding & Machine Learning
Bridging digital communication methods with predictive machine learning models.
* **Digital Communication (ASK):** Simulating wireless data transmission using Amplitude coding, where different bit sequences are represented by sinusoidal signals of varying amplitudes.
* **Noise vs. Bit Rate Analysis:** Decoding the signals using correlation and analyzing the fundamental trade-offs between bit rate, transmitter power, and error rates in the presence of Gaussian noise.
* **Machine Learning Classification:** Training a Linear SVM model using MATLAB's Classification Learner app on a `diabetes-training` dataset containing 6 medical features.
* **Feature Selection & Validation:** Evaluating the importance of individual features and predicting patient outcomes on a separate validation dataset.

### 5️⃣ Project 5: Fourier Analysis & Frequency Coding
Analyzing signals in the frequency domain and implementing frequency-based communication.
* **Discrete Fourier Transform:** Moving discrete-time signals to the frequency domain using `fft` and `fftshift`, and visualizing their magnitude and phase.
* **Frequency Resolution:** Investigating the impact of sampling rate ($f_s$) and signal duration ($T$) on frequency resolution and the ability to distinguish closely spaced frequencies.
* **Frequency Shift Keying (FSK):** Encoding binary messages into different frequencies rather than amplitudes to transmit data.
* **Bandwidth & Resilience:** Decoding FSK signals using FFT and demonstrating how increasing the frequency separation (using more bandwidth) improves system robustness against noise.

---

## 🚀 How to Run
1. Clone this repository to your local machine.
2. Open MATLAB and navigate to the respective project folder.
3. Run the main scripts (e.g., `pl.m`, `myTracker.m`) as described in each project's directory. Ensure you load the required `.mat` data files or images when prompted.
