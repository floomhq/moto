---
name: geo
description: >
  Geographic data validator for aviation and travel applications. Use when user says
  "geo audit", "check airports", "validate routes", "geo skill", "check geographic data",
  "verify iata codes", "check distances", or when reviewing any code/data that involves
  airport codes (IATA/ICAO), city-to-airport mappings, country codes (ISO 3166),
  flight distances, flight time estimates, flag URLs, or route feasibility.
  Also use for timezone validation, coordinate checks, and geopolitical accuracy
  (country names, disputed territories, naming conventions).
---

# Geographic Data Validator

Systematic validation of geographic data in aviation/travel applications.

## Audit Process

Run each validation category. Flag every error. Score each category 0-10.

---

## Category 1: IATA Airport Code Validation

### Checks
- [ ] **Code format**: All IATA codes are exactly 3 uppercase letters.
- [ ] **Code existence**: Every code maps to a real, operational airport.
- [ ] **Code currency**: No closed/decommissioned airports (e.g., TXL closed 2020).
- [ ] **Multi-airport cities**: Correct airport chosen for the city.
  - Berlin: BER (not TXL or SXF, both closed)
  - London: LHR (Heathrow), LGW (Gatwick), STN (Stansted), LTN (Luton), LCY (City)
  - New York: JFK (Kennedy), EWR (Newark), LGA (LaGuardia)
  - Tokyo: NRT (Narita), HND (Haneda)
  - Paris: CDG (Charles de Gaulle), ORY (Orly)
  - Istanbul: IST (Istanbul Airport, not SAW which is Sabiha Gokcen)
  - Mumbai: BOM (not MUM)
  - Rome: FCO (Fiumicino, not CIA Ciampino for international)
- [ ] **Primary airport**: For programmatic pages, use the PRIMARY international airport.

### Common IATA Mistakes
| Wrong | Right | Why |
|-------|-------|-----|
| TXL | BER | Berlin Tegel closed Nov 2020 |
| SXF | BER | Berlin Schonefeld renamed to BER |
| SAW | IST | Istanbul Airport (IST) is the main hub since 2019 |
| MUC | MUC | Correct (Munich) |
| HAM | HAM | Correct (Hamburg) |
| FRA | FRA | Correct (Frankfurt) |
| DUS | DUS | Correct (Dusseldorf) |

---

## Category 2: City Name Accuracy

### Checks
- [ ] **English names**: Using standard English city names (not local names in English context).
  - Mumbai (not Bombay), Beijing (not Peking), Kolkata (not Calcutta)
  - BUT: standard English names where established (Munich not Munchen, Rome not Roma)
- [ ] **German names**: Using standard German city names in DE context.
  - Munchen (not Munich), Rom (not Rome), Lissabon (not Lisbon)
  - BUT: keep English for international cities (New York, not Neuyork)
- [ ] **Slug consistency**: Slugs use English city names regardless of locale.
  - `munich-to-istanbul` (not `muenchen-nach-istanbul`)
- [ ] **City-airport alignment**: City name matches the airport's actual city.
  - FRA is in Frankfurt (correct), not "Frankfurt am Main" in slugs
  - NRT is Narita but city should be "Tokyo" (that's where travelers mean)
  - FCO is Fiumicino but city should be "Rome"
  - ORY is Orly but city should be "Paris"
  - LHR is Heathrow but city should be "London"

### Slug Generation Rules
```
lowercase(english_city_name_origin) + "-to-" + lowercase(english_city_name_destination)
```
Use the CITY name, not the airport name. "hamburg-to-london" not "hamburg-to-heathrow".

---

## Category 3: Country Code Validation (ISO 3166-1 Alpha-2)

### Checks
- [ ] **Format**: All country codes are exactly 2 uppercase letters.
- [ ] **Existence**: Every code is a valid ISO 3166-1 alpha-2 code.
- [ ] **Currency**: Using current codes (not historical).
- [ ] **Geopolitical sensitivity**: Correct handling of disputed territories.
  - Taiwan: TW (ISO standard, but some APIs use CN)
  - Kosovo: XK (not ISO standard but widely used)
  - Palestine: PS
  - Hong Kong: HK (not CN)
  - Macau: MO (not CN)

### Flag URL Validation (flagcdn.com)
```
https://flagcdn.com/{width}x{height}/{lowercase_country_code}.png
```
- Country code MUST be lowercase in URL: `de` not `DE`
- Standard sizes: 16x12, 20x15, 24x18, 28x21, 32x24, 40x30, 48x36, 56x42, 64x48, 80x60
- Retina: use 2x size in srcSet (e.g., 40x30 base, 80x60 2x)
- Some codes don't have flags on flagcdn (e.g., XK for Kosovo)

---

## Category 4: Flight Distance & Time Estimates

### Checks
- [ ] **Great-circle distance**: Within 5% of actual great-circle distance between airports.
- [ ] **Flight time formula**: `distance_km / 850 + 0.5 hours` (850 km/h avg cruise + 30min taxi/climb/descend).
- [ ] **Reasonableness check**: Flight times match reality within 15%.

### Reference Distances (verify against these)
| Route | Distance (km) | Typical Flight Time |
|-------|-------------:|-------------------:|
| BER-LHR | 930 | 1h 55m |
| FRA-JFK | 6,200 | 8h 30m |
| MUC-IST | 1,580 | 2h 45m |
| BER-CDG | 880 | 1h 50m |
| FRA-DEL | 6,600 | 8h 00m |
| FRA-BKK | 9,000 | 11h 00m |
| FRA-DXB | 4,850 | 6h 00m |
| BER-BCN | 1,500 | 2h 35m |
| BER-AMS | 580 | 1h 25m |
| FRA-NRT | 9,350 | 11h 30m |
| BER-JFK | 6,400 | 9h 00m |

### Stops Classification
| Distance (km) | Typical Stops |
|---------------:|:-------------|
| < 1,500 | Direct (0 stops) |
| 1,500 - 4,000 | Direct or 1 stop |
| 4,000 - 8,000 | Direct (major hubs) or 1 stop |
| > 8,000 | Direct or 1-2 stops |

### Flags
- Flight time < 45 min: verify route exists (too short for commercial)
- Flight time > 18 hours: verify this is a real route (may need 1+ stops)
- Distance > 15,000 km: almost certainly requires a stop

---

## Category 5: Route Feasibility

### Checks
- [ ] **Route actually exists**: Airlines operate scheduled service on this route (direct or common 1-stop).
- [ ] **Seasonal routes**: Flag routes that are seasonal only (e.g., summer charters).
- [ ] **Hub logic**: Origin-destination pairing makes geographic sense.
  - FRA-DEL: Yes (Lufthansa hub to major Indian city)
  - HAM-NRT: Questionable (no direct, would connect via FRA/MUC)
- [ ] **Airline availability**: Named airlines actually fly this route.
- [ ] **Directional logic**: For reverse routes, verify demand exists (diaspora corridors, business travel).

### German Hub Routes (verified operational)
| Hub | Primary Long-Haul Destinations (Direct Service) |
|-----|--------------------------------------------------|
| FRA | JFK, EWR, ORD, LAX, SFO, YYZ, DEL, BOM, BKK, SIN, HKG, NRT, HND, PEK, DXB, DOH, JNB, GRU, BOG |
| MUC | JFK, ORD, LAX, DEL, BKK, SIN, HKG, NRT, PEK, DXB, DOH, JNB |
| BER | JFK (seasonal), DXB, IST, ATH, BCN, AMS, LHR, CDG, FCO, LIS |
| HAM | LHR, IST, BCN, ATH, DXB (mostly European, limited long-haul) |
| DUS | JFK (seasonal), DXB, IST, ATH, BCN, PMI |

---

## Category 6: Geopolitical Accuracy

### Checks
- [ ] **Conflict zone alignment**: Routes flagged as "near conflict zone" actually pass near that zone.
  - BER-IST: Passes near Black Sea / Ukraine zone (correct)
  - FRA-DEL: Passes near Iran/Pakistan airspace (correct)
  - FRA-BKK: Overflies Iran or detours south (correct to flag)
  - BER-LHR: Does NOT pass near any conflict zone (correct to not flag)
- [ ] **Safety level accuracy**: Zone risk levels match current data.
- [ ] **Country name sensitivity**: Using internationally recognized names.
  - "Turkiye" (official) vs "Turkey" (common English): use "Turkey" in English context
  - "Myanmar" (official) vs "Burma": use "Myanmar"
- [ ] **Airspace routing**: Commercial flights may not fly the great-circle route due to airspace restrictions. Flagging conflict zones should consider actual likely routing, not just great-circle proximity.

---

## Scoring

| Category | Score | Notes |
|----------|------:|-------|
| 1. IATA Code Validation | /10 | |
| 2. City Name Accuracy | /10 | |
| 3. Country Code Validation | /10 | |
| 4. Distance & Time Estimates | /10 | |
| 5. Route Feasibility | /10 | |
| 6. Geopolitical Accuracy | /10 | |
| **Overall** | **/10** | Average |

**Passing score: 9/10 overall. Geographic errors in production are factual errors that destroy user trust.**

---

## Quick Audit Command

When invoked as `/geo`, validate all geographic data in the current plan or code. Check every IATA code, city name, distance, flight time, and route feasibility. Output the scoring table with specific errors found.

## Data Sources for Verification
- Airport codes: IATA official list, airportcodes.io, Wikipedia "List of airports by IATA code"
- Distances: Great Circle Mapper (gcmap.com), or calculate from coordinates using Haversine formula
- Flight times: Google Flights actual results, airline schedules
- Country codes: ISO 3166-1, restcountries.com API
- Conflict zones: EUROCONTROL NOTAMs
