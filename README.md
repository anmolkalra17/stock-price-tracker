# Stock Price Tracker

A SwiftUI app that shows live price updates for 25 stock symbols, with a detail screen per symbol.

> Prices are **simulated**. The app generates a random price change, sends it to `wss://ws.postman-echo.com/raw`, and applies the message the echo server returns. FX rates are hard-coded.

## Features

- Start / Stop live feed with a connection status indicator
- Sort by **price** or **price change**; tap a row for the detail screen (updates live)
- 7 regions: prices shown in local currency, plus a market-open/closed badge
- 6 languages: en, de, ja, hi, ar, zh-Hans (follows the device language)

## Architecture

MVVM + Repository, one shared `@Observable` repository so the list and detail screens update together.

```
View → ViewModel → StockRepositoryProtocol → StockRepository → WebSocketConnection
                                                               ├─ URLSessionWebSocketTask (app)
                                                               └─ MockWebSocketConnection (tests)
```

- Prices are stored in USD and converted only for display.
- `StockRepository` takes two optional hooks, `webSocketFactory` and `priceUpdateProvider`. The app leaves them empty (real socket, random prices); tests inject fakes.

## Unit Test Strategy

**Goals**

1. The feed lifecycle (start, stop, restart, failures) is deterministic and covered.
2. Business rules (sorting, FX, change %, market hours) are covered by fast, pure tests.
3. A missing or mismatched translation fails CI instead of shipping as a raw key.
4. Tests are isolated: no network, no UI, no randomness, so results are repeatable.

**Techniques**

| Layer | Technique | Tests |
|---|---|---|
| Models, formatting, market hours | Plain XCTest, boundary cases (9:30 / 16:00, weekends) | `StockModelTests`, `StockRegionalTests`, `PriceUpdateMessageTests` |
| Repository | Fake socket (`MockWebSocketConnection`) + scripted prices | `StockRepositoryTests` |
| ViewModels | Mock repository (`MockStockRepository`) | `StockListViewModelTests`, `StockListViewModelFeedTests`, `StockDetailViewModelTests` |
| Integration | Real repository + view models, fake socket only | `FeedIntegrationTests` |
| Localization | Parses every `Localizable.strings`: same keys, placeholders, no empty values | `LocalizationTests` |

- **Async without flakiness:** a `waitUntil` helper polls a condition (3 s timeout) instead of fixed sleeps; the fake socket is driven explicitly (`pushIncoming`, `pushIncomingFailure`).
- **Not covered:** the real `URLSession` socket path (check manually) and UI tests.

## Known Limitations

- All data is fake; "change" is relative to the previous tick, not the previous day.
- Status shows "Connected" as soon as the socket is requested, before the server confirms.
- Incoming prices are not validated.
- Translations are drafts and need native-speaker review.