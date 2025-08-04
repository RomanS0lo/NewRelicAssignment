# New Relic iOS Challenge

Simple iOS app that shows cat breeds from the Cat Facts API. Built for the New Relic coding challenge.

## What it does

- Shows a list of cat breeds (loads 30 at a time)
- Tap a cat to see more details
- Tracks how long API calls take
- Shows metrics about performance

## Requirements met

✓ Paginated list (30 items per batch)  
✓ Uses Cat Facts API (https://catfact.ninja)  
✓ Detail view when you tap a cat  
✓ Tracks API response times  
✓ Shows device info and metrics  
✓ Navigation between views  

## How to run

1. Open `NewRelic.xcodeproj` in Xcode
2. Hit run - that's it

Needs iOS 14+ and internet connection.

## What I built

- **AllCatsViewController** - main list with infinite scroll
- **CatDetailsViewController** - shows breed details
- **MetricsViewController** - performance stats
- **CatFetcher** - handles API calls
- **NetworkMonitor** - tracks response times

## Testing

Run tests with Cmd+U. Added mocking for the network layer so tests work offline.

## Notes

- Added pull-to-refresh because it felt weird without it
- Error handling for network issues
- Decent loading states so you know something's happening

The code is pretty straightforward - nothing fancy but gets the job done and handles edge cases properly.

## Structure

```
NewRelic/
├── AllCats/           # Main list view
├── CatDetails/        # Detail view  
├── MetricsScene/      # Performance metrics
└── Network/           # API and data models
```

That's about it. The app works well and covers all the requirements.