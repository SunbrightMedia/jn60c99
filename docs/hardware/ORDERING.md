# ORDERING — JLCPCB boards + LCSC parts in ONE shipment (LIVING, 2026-09-28)

Source: the official LCSC help page "Combine LCSC and JLCPCB Orders in One Shipment", saved by the user 2026-09-23
(text extracted verbatim below). This CORRECTS the from-memory steps given in chat on 2026-09-23 ("pick a combine option
at JLCPCB shipping"): the JLCPCB side is done by typing LCSC's warehouse as the shipping ADDRESS, and it cannot be changed
after checkout.

## Conditions (LCSC's words, condensed)
- Works for JLCPCB PCB, SMT, 3D, CNC, stencil orders.
- Both orders must use the SAME currency and the SAME customer ID.
- A combined order cannot ship to mainland China, and cannot be split once combined.
- Shipping is recalculated; LCSC tells you if you owe more.
- It fails if the LCSC order already shipped, or if the steps below were not followed.
- LCSC support (support@lcsc.com) handles LCSC orders and LCSC+JLCPCB combining. LCSC cannot combine several JLCPCB
  orders with each other — that is JLCPCB support (support@jlcpcb.com).

## Steps
1. At JLCPCB checkout, enter THIS shipping address (no change is possible after checkout):
   | field | value |
   |---|---|
   | Country/Region | Hong Kong, China |
   | State | NT |
   | City | KWAI CHUNG |
   | Street address | NOS.35/41 TAI LIN PAI ROAD |
   | Building/House no. | FTB1 2/F Gold Base IND. BLDG. |
   | Postal code | 999077 |
   | Recipient | "Sean Chan" (warehouse staff) or your own name |
   | Phone | (+852) 36112905 |
2. Then EITHER
   - **Case two (recommended, no LCSC order yet):** order at lcsc.com (upload `bom/MASTER_BOM_LCSC.csv` in the BOM Tool) and
     choose to combine with the JLCPCB order during LCSC checkout. If the JLCPCB order does not show, check the conditions
     above, then email support@lcsc.com.
   - **Case one (LCSC order already placed):** email support@lcsc.com at once to intercept it before it ships, and give both
     order numbers (LCSC + JLCPCB) asking for one shipment.
3. Pay the final shipping at LCSC. LCSC holds the parts until the boards arrive at the warehouse.

## Before paying
- Check the final shipping weight band; heavy parts (connectors, jacks) move it.
- `bom/README.md` lists the open BOM checks (4.7 k axial MPN row, FB1 C46550600, the 31 proposed JSTs).
