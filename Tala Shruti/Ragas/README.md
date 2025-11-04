# Ragas Folder

This folder contains individual raga definitions. Each raga is defined in its own Swift file.

## How to Add a New Raga

1. Create a new Swift file in this folder (e.g., `ShankarabharanamRaga.swift`)
2. Copy the template below
3. Fill in the raga name and notes
4. Add the raga to `RagaRegistry.swift` in the `registerRagas()` method
5. The raga will automatically appear in the app!

## Template

```swift
//
//  YourRagaNameRaga.swift
//  Tala Shruti
//
//  [Raga Name] - [Melakarta Number or Description]
//  Arohanam: [ascending scale]
//  Avarohanam: [descending scale]
//

import Foundation

struct YourRagaNameRaga: RagaDefinition {
    let name = "Your Raga Name"
    
    let notes: [RagaNote] = [
        RagaNote(swaraName: "S", frequency: 130.0),    // C3

        RagaNote(swaraName: "S", frequency: 260.0)     // C4
    ]
}
```

## Frequency Reference (C3 Octave)

Based on your voice:
- S (Sa): 130 Hz
- R1 (Shuddha Rishabham): 140 Hz
- R2 (Chatushruti Rishabham): 147 Hz
- G2 (Sadharana Gandharam): 156 Hz
- G3 (Antara Gandharam): 165 Hz
- M1 (Shuddha Madhyamam): 175 Hz
- M2 (Prati Madhyamam): 185 Hz
- P (Panchamam): 200 Hz
- D1 (Shuddha Dhaivatam): 210 Hz
- D2 (Chatushruti Dhaivatam): 220 Hz
- N2 (Kaisiki Nishadam): 235 Hz
- N3 (Kakali Nishadam): 250 Hz
- S (Upper Sa): 260 Hz

## Current Ragas

1. **Mayamalavagowla** (15th Melakarta)
   - S R1 G3 M1 P D1 N3 S

2. **Hindolam** (Pentatonic)
   - S G2 M1 D1 N2 S
