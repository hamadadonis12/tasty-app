# Toters Customer Journey — Inspiration & Gap Analysis for TastyLife

Captured live from the Toters app (`com.toters.customer`) on the Galaxy A35, 2026-06-20.
Goal: replicate the same end-to-end customer journey and polish in the TastyLife customer app.

Toters is the quality benchmark. This doc walks its journey screen by screen, names the
UX patterns worth copying, and maps each against what the TastyLife customer app has today
so we can see exactly what to build next.

> Note: Butler (Toters' "deliver/buy anything" concierge tab) is intentionally **out of scope** — not relevant to our food-ordering journey.

---

## The Toters journey (screen by screen)

### 1. Home / browse (long scrolling feed)
- Location selector in the header (`gaelle home fanar ▾`) + notification bell.
- Search bar ("Store name or item…").
- **Category rail**: All · Food · Fresh · Beauty · Market (horizontal, sticky-ish).
- **Filter chips**: Offers · Free Delivery · Top Rated · New, plus delivery-time + rating filter pills (e.g. `35–50 mins ★4.7`).
- **Promo cards** row: "up to 40% combos", "Daily Discounts", "First Order 50%".
- **Loyalty progress** inline: `Green · 240 Pts → 6 more orders by Jun 30 to reach Gold`.
- **Store Rewards**: per-store progress ("1 more order to earn LBP 250,500") with progress dots.
- **"Now on Toters"** new-store carousel (with Pre-Order badges).
- **"Toters Cup Combos"** bundle carousel: strikethrough original price + `SAVE LBP …` in red.
- **"All Stores"** list: large hero cards with discount badge, loyalty-earn badge, `AD` (sponsored) tag, and a favorite ❤ toggle.

### 2. Store / restaurant page
- **Skeleton loading** placeholders while data loads (not a spinner).
- Header actions: back, **Share**, **Favorite ❤**, **Search within store**.
- Store info card (logo, name, rating / delivery time / min order).
- Menu organized into **labeled sections** ("World Cup Offers").
- Menu rows: name · gray truncated description · **dual-currency price (LBP + USD)** · strikethrough original · `SAVE` in red · thumbnail · green **`+`** add button.
- Sticky bottom **loyalty bar**: "Spend X and earn a punch 👊".

### 3. Item detail + customization  ← the core of what we're missing
- Full-bleed hero image + close / share / favorite.
- Title + full description + price (with savings).
- **Modifier groups**, each clearly labeled:
  - Single-select **radio** groups ("Way Of Serving": Regular `+$0.00` / Flat `+$0.30`).
  - Multi-select **checkbox** groups ("Add Ingredients": Vegetables `+$0.50`, Ketchup `+$0.50`, Mayo `+$1.00`).
  - Each option shows its **incremental price**.
  - Combos nest a customization group **per component** (Zaatar / Cheese / Lahm Baajin each get their own).
- Sticky bottom bar: **quantity stepper (− n +)** + green **Add** button with a **live-updating total**.

### 4. Cart ("My Cart")
- **Punch-card progress bar** (LBP 0 →•→ 717,000).
- Cart item row: thumbnail, name, price, **customization summary** ("Way Of Serving: Regular… Read more"), delete icon, qty stepper.
- **"Please do not send cutlery"** toggle.
- **"Complete your order with"** cross-sell carousel.
- **`Saving LBP …`** highlight banner.
- **Saved payment methods** quick-select row.
- Bottom: **Add items** + **Checkout** (with running total).

### 5. Checkout
- Clean card sections, each with a **`Change`** action:
  - **Delivery time** ("In 15–30 mins").
  - **Delivery Address** — map thumbnail + address + **Add Driver Instructions**.
  - **Payment Method** — saved card.
  - **Toters Cash** — dual wallet (LBP/USD) with **Top up**.
- Sticky **Total Payment + Place order** bar.

### 6. Search
- Featured store · **Recent searches as chips** · curated **Collections** ("Track Your Meals").

### 7. Orders (list → details)
- **Past Orders** cards: store logo, delivered date/time, item summary ("+N other items"), dual-currency total, chevron.
- Each order card is **tappable → Order Details** screen:
  - Store card (name, delivered date/time) + delivery address.
  - **Driver name + favorite-driver ❤ toggle** (matches our "drivers you know by name" promise).
  - **Support** · **Reorder** · **Rate your order** actions.
  - "Your order" itemized list (thumbnail, qty, weight, per-item price).
  - **Receipt**: "You've saved X" banner · Subtotal (strikethrough) · Delivery Charge · Total · Total (USD) · Paid with (card) · **"You're earning N Pts"** · exchange-rate fine print.

### 8. Account
- Profile header + **loyalty tier** ("Green", points).
- Quick actions: Profile · Support · Payments · Language.
- **Wallet** (dual currency) · Promotions (Credits, Promo Code, Store Rewards) · Account details.

### Cross-cutting patterns (used everywhere)
- **Skeleton loaders** on every async screen (store, cart, orders) — never a bare spinner.
- **Dual-currency pricing** (local + USD) on every price.
- **Savings shown in red**, original price struck through.
- **Loyalty/gamification** woven into home, store, cart (progress bars, punch cards, tiers).
- Persistent **sticky action bars** (Add / View Cart / Checkout / Place order) with live totals.

---

## Where TastyLife stands today (from on-device testing + code review)

> **Correction (2026-06-20):** an earlier draft claimed the store/item/cart/checkout
> screens were missing. That was wrong — I only walked onboarding + the bottom-nav tabs
> on device and never tapped into a restaurant. The code **already has the full flow**
> and it is wired: `immersive_home_screen.dart` → `restaurant_detail_screen.dart` →
> `customize_order_screen.dart` → `cart_screen.dart` → `checkout_payment_screen.dart`.

What the customer app already has and does well:
- Onboarding: Splash → Language (FR/EN/Lingala/Kikongo) → Permissions → Phone+OTP (+243) → Address (map) → Home. Premium, with cross-fade transitions.
- Home: greeting, ETA badge, search, **Find My Craving** (AI), category chips, "Trending in Kinshasa", Order Again.
- **Restaurant page**: parallax hero, rating/ETA/fee stats, Menu/Reviews/Info tabs, menu rows with `+`, sticky bag bar.
- **Item customization**: hero image, modifier groups, sticky quantity + Add-to-Cart with live total.
- Cart, Checkout (payment), Orders history, Account (Gold tier + points, saved addresses, **Orange Money**).

## The gap — what's left to reach Toters parity

| # | Screen / pattern | Toters has | TastyLife status | Priority |
|---|--------|-----------|------------------|----------|
| 1 | Item customization — **multi-select add-ons** | ✅ checkbox groups ("Add Ingredients") | ✅ **DONE 2026-06-20** (radio + checkbox, caps, live total) | — |
| 2 | Store page menu **sections** (labeled groups) | ✅ ("World Cup Offers") | ❓ verify (single list vs sections) | **P1** |
| 3 | Cart cross-sell ("Complete your order with") | ✅ | ❓ verify | **P2** |
| 4 | "Don't send cutlery" toggle in cart | ✅ | ❓ verify | **P2** |
| 5 | Order tracking (live driver) | ✅ | `live_order_tracking_screen.dart` exists — verify | **P1** |
| 6 | Skeleton loaders on async screens | ✅ everywhere | ❓ verify across screens | **P1** |
| 7 | Search w/ recent chips + collections | ✅ | `smart_search_screen.dart` exists — verify depth | **P1** |
| 8 | Loyalty progress woven into home/store/cart | ✅ progress bars / punch cards | partial (points shown) | **P2** |

### What shipped on 2026-06-20
Added **multi-select modifier groups** to item customization (the one true gap in the flow):
- `ModifierGroup` model gained `multiSelect` + `maxSelect` ([menu_item.dart](../apps/customer/lib/models/menu_item.dart)).
- Customize screen renders checkbox groups with cap enforcement, an Optional/Required badge, and a live-updating total ([customize_order_screen.dart](../apps/customer/lib/screens/customer/customize_order_screen.dart)).
- Sample data on Poulet Moambe (spice level + add sides), Truffle Burger (cook temp + side + extras), Margherita (size + toppings) ([restaurant.dart](../apps/customer/lib/models/restaurant.dart)).
- Verified on the A35: ticking add-ons updates the total live; radio + checkbox rows visually aligned.

### Localization notes (keep these Tasty-specific, do NOT copy Toters' Lebanon assumptions)
- Currency: TastyLife uses **USD** (correct for DRC) — keep single currency unless we add CDF; do not copy LBP/USD dual display.
- Payments: **Orange Money / Airtel Money**, not Visa-first. Toters' saved-Visa checkout is the right *pattern*, wrong *rail*.
- Language: we already lead with FR + local languages — good, keep it.

## Recommended build order (P0 first)
1. **Restaurant/store page** — menu sections + item rows + sticky cart bar.
2. **Item detail + customization sheet** — radio + checkbox modifier groups, qty stepper, live total, sticky Add. This is the highest-craft screen; model it directly on Toters.
3. **Cart** — line items with customization summary, cross-sell, totals, cutlery toggle.
4. **Checkout** — delivery time / address / payment cards with `Change`, Orange Money first, sticky Place Order.
5. Wire **skeleton loaders** into all of the above from day one (matches our quality bar).

---
*Screenshots from this session are in the OS temp dir (`%TEMP%\toters_*.png`, `%TEMP%\tasty_*.png`).*
