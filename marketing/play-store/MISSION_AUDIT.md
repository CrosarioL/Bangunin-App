# Mission audit

| Mission | User action | Sensor/data | Success measurement and false-positive protection | Safety/accessibility | Data | Tier |
|---|---|---|---|---|---|---|
| None | Dismiss or snooze | None | Explicit button | Non-exercise alternative | No mission data | Free |
| Object Hunt | Photograph the registered object | Camera; stored reference | On-device 64-bin color-histogram cosine similarity >0.60; requires a valid reference. Similar colors can still false-pass. | Good lighting; reachable safe object | Reference retained locally until replaced/deleted; attempt deleted | Premium |
| Sky Photo | Photograph visible sky | Camera | Upper 40% must be bright and sufficiently blue/overcast-like; dark/incorrect colors fail | Never enter an unsafe outdoor area; use an alternative in bad conditions | Attempt deleted after check | Premium |
| Grass Photo | Photograph grass/green vegetation | Camera | More than 35% green-dominant pixels; similarly colored objects can false-pass | Do not walk into traffic/unsafe ground | Attempt deleted | Premium |
| Make Your Bed | Photograph the made bed | Camera | Lighting band plus distributed edge density and left/right visual balance; rejects blank/pocket/single-flat frames but cannot prove tidiness semantically | Keep walkways clear; limitation is disclosed | Attempt deleted | Premium |
| Squats | Place phone securely; complete full squats | Front camera pose landmarks | Both knee angles down <105° then up >158°; both sides confidence ≥0.65; 3 consecutive frames per state; ≥650 ms debounce | Do not hold phone; stop for pain/dizziness; choose photo mission if unsuitable | Frames/landmarks processed transiently, never saved/uploaded | Premium |
| Pushups | Place phone securely; complete standard two-arm pushups | Front camera pose landmarks | Both elbow angles down <100° then up >155°, body-line angle >145°; confidence, 3-frame state and debounce protections | No one-arm requirement; stable phone; stop for pain/dizziness; photo alternative | Frames/landmarks transient only | Premium |
| Custom sound | Choose a file or make a local recording for alarm playback | Microphone only when recording; system file picker | User confirms the selected/recorded sound; not a dismissal mission | Permission denial leaves bundled sounds available | Stored locally with its alarm; deleted when replaced/alarm deleted | Premium |
