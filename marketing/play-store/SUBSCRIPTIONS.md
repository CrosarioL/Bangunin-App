# Google Play subscriptions

Create only these auto-renewing products:

| Product | Base plan ID (suggested) | Indonesia price | Trial |
|---|---|---:|---:|
| `bangunin.premium.monthly` | `monthly` | Rp49,000/month | 3 days |
| `bangunin.premium.yearly` | `yearly` | Rp199,000/year | 3 days |

For each product: **Monetize with Play > Products > Subscriptions > Create subscription**; enter the exact product ID; add an auto-renewing base plan; set availability; set the Indonesian price; save and activate. Then **Add offer**, select that base plan, choose new-customer eligibility, add a **Free trial** phase of 3 days, save, and activate the offer. Activate the subscription itself.

The app reads Play's localized recurring pricing phase and only labels a plan as a three-day trial when Play returns an actual `P3D` zero-price phase. Release builds use real billing; debug builds use the fake service unless explicitly overridden.

Test only from a Play internal/closed track with a license-testing account. Sideloaded builds generally cannot retrieve products. Test purchase, pending/canceled purchase, trial disclosure, renewal, cancellation, account hold, restore after reinstall, and **Manage subscription**. Do not add another Android payment method for these digital features.
