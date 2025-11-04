# Raga Training Feature

## Overview
A new interactive raga training feature has been added to Tala Shruti. This feature helps users practice singing ragas by providing real-time pitch detection and visual feedback.

## Current Implementation

### Raga: Mayamalavagowla
The feature currently supports the Mayamalavagowla raga with the following notes:
- S (Shadjam) - 261.63 Hz (C)
- R1 (Shuddha Rishabham) - 277.18 Hz (C#)
- G3 (Antara Gandharam) - 311.13 Hz (D#)
- M1 (Shuddha Madhyamam) - 349.23 Hz (F)
- P (Panchamam) - 392.00 Hz (G)
- D1 (Shuddha Dhaivatam) - 415.30 Hz (G#)
- N3 (Kakali Nishadam) - 466.16 Hz (A#)
- S (Upper Shadjam) - 523.25 Hz (C)

## Features

### 1. Shruti Selection
- Users can select their base shruti (C, C#, D, D#, E, F, F#, G, G#, A, A#, B)
- The raga notes automatically adjust to the selected shruti
- Tap the "Shruti" button at the top to change

### 2. Real-Time Pitch Detection
- Uses the device microphone to detect singing pitch
- Automatically adjusts for different octaves
- Smoothed frequency detection for stable readings

### 3. Visual Feedback
- Each note is displayed as a card showing:
  - Swara name (S, R1, G3, etc.)
  - Target frequency in Hz
  - Current detected frequency (when active)
- Active note is highlighted with a blue border and pulsing indicator
- Completed notes turn green with a checkmark
- Match percentage affects card color (green when close, yellow when getting there)

### 4. Progressive Learning
- Notes must be sung in sequence
- A note must be held correctly for ~8 consecutive detections to advance
- Once completed, the note turns green and the next note becomes active
- "Practice Again" button appears when all notes are completed

### 5. Input Level Meter
- Visual feedback showing microphone input level
- Helps ensure proper microphone positioning

## Files Added

1. **Tala Shruti/Models/Raga.swift**
   - Defines the Raga and RagaNote structures
   - Contains the Mayamalavagowla raga definition
   - Includes frequency matching logic with octave adjustment

2. **Tala Shruti/RagaTrainingManager.swift**
   - Manages audio input and pitch detection
   - Handles note progression logic
   - Adjusts raga to selected shruti
   - Uses autocorrelation for pitch detection

3. **Tala Shruti/RagaTrainingView.swift**
   - Main UI for the raga training feature
   - Displays note cards with progress
   - Shruti picker interface
   - Input level visualization

## Integration

The Raga Training page has been added as the 5th page in the main TabView (after Tuner), accessible by swiping left from the Tuner page.

## Usage

1. Open the app and swipe to the Raga Training page (after Tuner)
2. Select your preferred shruti using the "Shruti" button
3. Start singing the first note (S)
4. When you match the pitch correctly, the note will turn green
5. Continue to the next note
6. Complete all 8 notes to finish the exercise
7. Tap "Practice Again" to restart

## Technical Details

- Uses AVAudioEngine for real-time audio input
- Autocorrelation algorithm for pitch detection
- Frequency smoothing for stable readings
- Octave-aware frequency matching (tolerance: ±15 Hz)
- Requires 8 consecutive matches to advance to next note
- Automatically configures audio session for recording

## Future Enhancements

Potential additions:
- More ragas (Shankarabharanam, Kalyani, Kharaharapriya, etc.)
- Adjustable difficulty levels (tolerance settings)
- Speed/tempo variations
- Arohanam/Avarohanam practice modes
- Recording and playback of practice sessions
- Progress tracking and statistics
