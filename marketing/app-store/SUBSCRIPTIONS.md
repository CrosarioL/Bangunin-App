# App Store subscriptions

Create one subscription group named **Bangunin Premium**.

| Product | Product ID | Duration | Indonesia price | Introductory offer |
|---|---|---:|---:|---|
| Bangunin Premium Monthly | `bangunin.premium.monthly` | 1 month | Choose the closest available tier to Rp49,000 | 3 days free |
| Bangunin Premium Yearly | `bangunin.premium.yearly` | 1 year | Choose the closest available tier to Rp199,000 | 3 days free |

For each product:

1. Add Indonesian and English display names/descriptions.
2. Set availability to the intended countries.
3. Add an introductory offer: **Free**, **3 Days**, available to new subscribers.
4. Complete subscription review information and add a paywall screenshot.
5. Keep both products in the same group so one user holds only one Bangunin Premium plan.
6. Submit the first subscription products with app version 1.0.0.

Suggested localizations:

- Indonesian monthly: `Bangunin Premium Bulanan` / `Semua misi premium dan fitur Bangunin Premium, ditagih setiap bulan.`
- Indonesian yearly: `Bangunin Premium Tahunan` / `Semua misi premium dan fitur Bangunin Premium, ditagih setiap tahun.`
- English monthly: `Bangunin Premium Monthly` / `All premium missions and Bangunin Premium features, billed monthly.`
- English yearly: `Bangunin Premium Yearly` / `All premium missions and Bangunin Premium features, billed yearly.`

The app reads the localized App Store price and only advertises the trial when StoreKit returns an eligible free-trial offer. Restore Purchases and Apple’s Manage Subscriptions page are linked in the app.
