# Google Play subscriptions

Create these in Play Console only after the app record for `app.bangunin` exists.

## Monthly

- Subscription product ID: `bangunin.premium.monthly`
- Product name: Bangunin Premium Monthly
- Base plan ID: `monthly-autorenew`
- Billing period: Monthly, auto-renewing
- Indonesia price: Rp 49,000
- Default rest-of-world reference price: USD 4.99, then review Google's regional conversions
- Offer ID: `three-day-trial`
- Eligibility: New customer acquisition; never had any subscription in this app
- Phase: 3 days free, then the monthly base plan

## Yearly

- Subscription product ID: `bangunin.premium.yearly`
- Product name: Bangunin Premium Yearly
- Base plan ID: `yearly-autorenew`
- Billing period: Yearly, auto-renewing
- Indonesia price: Rp 199,000
- Default rest-of-world reference price: USD 29.99, then review Google's regional conversions
- Offer ID: `three-day-trial`
- Eligibility: New customer acquisition; never had any subscription in this app
- Phase: 3 days free, then the yearly base plan

## Required checks

1. Activate both base plans and offers in every intended region.
2. Add localized Indonesian and English product names, descriptions, and benefits.
3. Add the account owner's payments profile and Indonesian payout bank.
4. Add tester Gmail accounts under Settings > License testing.
5. Install only from a Play test-track link when testing purchases; sideloaded builds cannot retrieve live Play products reliably.
6. Confirm the app displays the localized renewal price returned by Google, not a hard-coded price.
7. Test purchase, cancellation, expiry, restore, pending payment, and already-owned behavior.

