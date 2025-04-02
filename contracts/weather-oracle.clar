;; weather-oracle.clar
;; Provides verified climate information

(define-constant contract-owner tx-sender)

(define-map weather-data
  { location: (string-utf8 100), timestamp: uint }
  {
    temperature: int,
    rainfall: uint,
    humidity: uint,
    wind-speed: uint,
    is-extreme-event: bool
  }
)

(define-map authorized-data-providers
  { provider: principal }
  { authorized: bool }
)

;; Only authorized providers can update weather data
(define-public (update-weather-data
    (location (string-utf8 100))
    (timestamp uint)
    (temperature int)
    (rainfall uint)
    (humidity uint)
    (wind-speed uint)
    (is-extreme-event bool))
  (begin
    (asserts! (is-authorized-provider tx-sender) (err u403))
    (ok (map-insert weather-data
      { location: location, timestamp: timestamp }
      {
        temperature: temperature,
        rainfall: rainfall,
        humidity: humidity,
        wind-speed: wind-speed,
        is-extreme-event: is-extreme-event
      }
    ))
  )
)

(define-public (authorize-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u401))
    (ok (map-insert authorized-data-providers
      { provider: provider }
      { authorized: true }
    ))
  )
)

(define-public (revoke-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u401))
    (ok (map-delete authorized-data-providers { provider: provider }))
  )
)

(define-read-only (get-weather-data (location (string-utf8 100)) (timestamp uint))
  (map-get? weather-data { location: location, timestamp: timestamp })
)

(define-read-only (is-authorized-provider (provider principal))
  (default-to false (get authorized (map-get? authorized-data-providers { provider: provider })))
)
