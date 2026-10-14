"""
Create the SQLite database shop.db from schema.sql and fill it with synthetic data.
Only the Python standard library is used.

Usage:
    python build_db.py
"""
import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).parent
DB = ROOT / "shop.db"
random.seed(7)

CITIES = ["Moscow", "Saint Petersburg", "Kazan", "Yekaterinburg", "Novosibirsk", "Samara"]
CATALOG = {
    "Laundry":    [("Ariel Pods 30", 1190), ("Tide Gel 2L", 890), ("Lenor Softener", 450)],
    "Hair Care":  [("Pantene Shampoo", 420), ("H&S Shampoo", 460), ("Herbal Essences", 390)],
    "Oral Care":  [("Oral-B Toothbrush", 320), ("Oral-B iO Electric", 5990), ("Blend-a-med Paste", 190)],
    "Shaving":    [("Gillette Fusion5", 1490), ("Gillette Mach3 Blades", 1290), ("Venus Razor", 890)],
    "Baby Care":  [("Pampers Diapers M", 1590), ("Pampers Wipes", 290), ("Pampers Pants L", 1690)],
}
FIRST = ["Anna", "Ivan", "Maria", "Dmitry", "Olga", "Sergey", "Elena", "Pavel", "Irina", "Alexey"]
LAST = ["Ivanov", "Petrov", "Smirnov", "Kuznetsov", "Popov", "Sokolov", "Lebedev", "Kozlov"]
START, END = date(2025, 1, 1), date(2026, 6, 30)


def rand_date(a: date, b: date) -> date:
    return a + timedelta(days=random.randint(0, (b - a).days))


def main() -> None:
    DB.unlink(missing_ok=True)
    con = sqlite3.connect(DB)
    con.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))

    products, pid = [], 1
    for category, items in CATALOG.items():
        for name, price in items:
            products.append((pid, name, category, price))
            pid += 1
    con.executemany("INSERT INTO products VALUES (?, ?, ?, ?)", products)

    customers = []
    for cid in range(1, 1501):
        customers.append((
            cid,
            f"{random.choice(FIRST)} {random.choice(LAST)}",
            random.choices(CITIES, weights=[35, 20, 12, 12, 11, 10])[0],
            rand_date(START, END - timedelta(days=30)).isoformat(),
            random.choices(["organic", "ads", "referral"], weights=[50, 35, 15])[0],
        ))
    con.executemany("INSERT INTO customers VALUES (?, ?, ?, ?, ?)", customers)

    orders, items, oid = [], [], 1
    for cid, _, _, signup, channel in customers:
        # referral customers are more loyal, ads customers churn faster
        mean_orders = {"organic": 4, "ads": 2.5, "referral": 6}[channel]
        n_orders = max(1, int(random.expovariate(1 / mean_orders)))
        for _ in range(n_orders):
            d = rand_date(date.fromisoformat(signup), END)
            status = random.choices(["delivered", "cancelled", "returned"], weights=[88, 8, 4])[0]
            orders.append((oid, cid, d.isoformat(), status))
            # cheaper everyday products are bought more often than expensive ones
            weights = [1 / prod[3] ** 0.5 for prod in products]
            basket = {p[0]: p for p in random.choices(products, weights=weights, k=random.randint(1, 4))}
            for prod in basket.values():
                discount = random.choice([1, 1, 1, 0.9, 0.8])
                items.append((oid, prod[0], random.randint(1, 3), round(prod[3] * discount, 2)))
            oid += 1
    con.executemany("INSERT INTO orders VALUES (?, ?, ?, ?)", orders)
    con.executemany("INSERT INTO order_items VALUES (?, ?, ?, ?)", items)
    con.commit()

    for table in ["customers", "products", "orders", "order_items"]:
        print(f"{table:<12}{con.execute(f'SELECT COUNT(*) FROM {table}').fetchone()[0]:>7}")
    con.close()


if __name__ == "__main__":
    main()
